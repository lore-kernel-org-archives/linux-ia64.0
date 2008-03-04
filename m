From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 04 Mar 2008 17:05:06 +0000
Subject: [PATCH] New way of storing MCA/INIT logs
Message-Id: <47CD8142.7050207@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------040901070805040308050508"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------040901070805040308050508
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a lock free, yet safe way of storing MCA/INIT logs.
You will not end up with logs mixed up from different MCAs.

The MCAs/INITs are rare.
There is no use wasting much permanent resources.
Should you see a burst of events, they are not uncorrelated.
Only the recovered events are treated. Should you miss one,
you'll see it later :-)
With the others, you will not be able to store them on disk anyway.

There are IA64_MAX_MCA_INIT_BUFS log buffers for the MCA, and
another IA64_MAX_MCA_INIT_BUFS log buffers for the INIT handler.

IA64_MAX_MCA_INIT_BUFS >= 2.

There is no per CPU log buffer.

The first (IA64_MAX_MCA_INIT_BUFS - 1) logs and the very last one are
stored only.
The last one gets overwritten if there are too many logs there.

The admin. info. is in a structure ia64_mca_init_buf_t, see in mca.h.

Handling the first (IA64_MAX_MCA_INIT_BUFS - 1) log buffers is
straight forward: you increment an atomic variable (_b_cnt) and
you use as index to _buf[IA64_MAX_MCA_INIT_BUFS - 1].
Having completed the log, you set the corresponding validity bit (_valid).

Otherwise you race (incl. with the nested handlers) for the last buffer:
- Increment the atomic generation counter (_gen_cnt).
- You own the last log buffer while no one else has got a higher
  generation count.
- The log data is broken up into 4-byte chunks and they are stamped with
  the generation count. They are written together as an atomic64_t into
  the last buffer (*_last_buf)[] by use of a compare-and-swap primitive
  to make sure that no one with higher generation count has passed by in
  the mean time.
- (*_last_buf)[0] is a marker:
  * Before writing the log data into the rest of (*->_last_buf)[], you
    set the marker to say "not done" (LAST_LOG_DONE bit off).
  * Having finished, you set the marker to say "done" (LAST_LOG_DONE bit on).

This is how the code backs down if someone writes the same buffer with
a higher generation count:

       do {
               tmp = atomic64_read(p);		// p => las log buffer
               /*
                * If you can see a higher generation count than yours,
                * then you are not the last - bail out.
                */
               if (GET_GEN_CNT(tmp) > gen_cnt)
                       return -1;
       } while (cmpxchg_rel(p, tmp, COMPOSE_AT_VAL(gen_cnt, value)) != tmp);

The code does not assume that the rendezvous always works.

The salinfo side verifies that every element of the last log buffer is
of the same generation.
If there is no log left, it clears _b_cnt.
There is no "shift" of the logs in the buffers at the salinfo side.

Well, the the old code is not cleaned up and the integration into the
salinfo side in not yet quit smooth, but you can judge the idea...

Thanks,

Zoltan Menyhart


--------------040901070805040308050508
Content-Type: text/plain;
 name="tmp2"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tmp2"

--- linux-2.6.24/arch/ia64/kernel/mca.c	2008-03-04 15:47:35.000000000 +0100
+++ linux-2.6.24-new/arch/ia64/kernel/mca.c	2008-03-04 15:54:35.000000000 +0100
@@ -183,6 +183,92 @@
 #define	MCA_IRQ_SAFE	1	/* NOT called from the MCA/INIT handlers */
 
 
+ia64_mca_init_buf_t ia64_MCA_logs;		/* Log buffers for the MCA handler */
+ia64_mca_init_buf_t ia64_INIT_logs;		/* Log buffers for the INIT handler */
+unsigned int max_SAL_log_size;			/* From SAL_GET_STATE_INFO_SIZE() */
+
+EXPORT_SYMBOL(ia64_MCA_logs);			// For testing purposes
+
+/*
+ * Store the "last log".
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns non zero on failure.
+ */
+static int
+ia64_last_log_write(
+	ia64_mca_init_buf_t	* const bp,	/* Where to save the log */
+	const void		* const log,	/* The SAL log to save */
+	unsigned int		size)		/* Its actual size in u32 units */
+{
+	const u32		*src = (u32 *) log;
+	atomic64_t		*p = &(*bp->_last_buf)[0];
+	unsigned int		const gen_cnt = ia64_fetchadd4_acq(&bp->_gen_cnt, 1) + 1;
+
+	/* Set the marker saying "not done" */
+	if (set_last_buf_item(p++, gen_cnt, smp_processor_id()) != 0)
+		return -1;			/* You are NOT the last one */
+	/* Sore the actual log size in u32 units */
+	if (set_last_buf_item(p++, gen_cnt, size) != 0)
+		return -1;			/* You are NOT the last one */
+	/*
+	 * The log data is broken up into 4-byte chunks and they are stamped with
+	 * the generation count. They are written together as an atomic64_t.
+	 */
+	while (size-- > 0)
+		if (set_last_buf_item(p++, gen_cnt, *src++) != 0)
+			return -1;		/* You are NOT the last one */
+	/* Set the marker saying "done" */
+	return set_last_buf_item(&(*bp->_last_buf)[0], gen_cnt,
+						smp_processor_id() | LAST_LOG_DONE);
+}
+
+/*
+ * Try to pick up a buffer for MCA/INIT log coming from SAL_GET_STATE_INFO().
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns the buffer index, or -1 on failure.
+ */
+static int
+ia64_get_mca_init_log_buf(
+	ia64_mca_init_buf_t	* const bp)	/* Log buffer admin. info. */
+{
+	unsigned int		idx;		/* Index to ->_buf[] */
+
+	idx = ia64_fetchadd4_acq(&bp->_b_cnt, 1);	/* Returns the old value */
+	if (idx < IA64_MAX_MCA_INIT_BUFS - 1)
+		return idx;
+	else
+		return -1;
+}
+
+/*
+ * Set up the log buffers for the MCA/INIT handlers.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns non zero on failure.
+ */
+static inline int
+ia64_mca_init_bufs_set_up(
+	ia64_mca_init_buf_t	* const bp)	/* Log buffer for the MCA/INIT handler */
+
+{
+	unsigned int		i;
+
+	/* The regular log buffers.
+	 * Add 4 bytes for the CPU number and 4 more for the actual log size.
+	 */
+	for (i = 0; i < IA64_MAX_MCA_INIT_BUFS - 1; i++)
+		if ((bp->_buf[i] = alloc_bootmem(max_SAL_log_size + 8)) == NULL)
+			return 1;
+	i = (max_SAL_log_size + sizeof(u32) - 1) & ~(sizeof(u32) - 1);
+	/*
+	 * The "last log buffer": 4 data bytes are stored in each atomic64_t.
+	 * Add 4 bytes for the marker item and 4 more for the actual log size.
+	 */
+	return (bp->_last_buf = alloc_bootmem(2 * (i + 8))) != NULL;
+}
+
 /*
  * Push messages into buffer, print them later if not urgent.
  */
@@ -323,19 +409,6 @@
 	while (1)
 		cpu_relax();
 }
-/*
- * IA64_MCA log support
- */
-#define IA64_MAX_LOGS		2	/* Double-buffering for nested MCAs */
-#define IA64_MAX_LOG_TYPES      4   /* MCA, INIT, CMC, CPE */
-
-typedef struct ia64_state_log_s
-{
-	spinlock_t	isl_lock;
-	int		isl_index;
-	unsigned long	isl_count;
-	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
-} ia64_state_log_t;
 
 static ia64_state_log_t ia64_state_log[IA64_MAX_LOG_TYPES];
 
@@ -367,21 +440,22 @@
 static void __init
 ia64_log_init(int sal_info_type)
 {
-	u64	max_size = 0;
-
 	IA64_LOG_NEXT_INDEX(sal_info_type) = 0;
 	IA64_LOG_LOCK_INIT(sal_info_type);
 
 	// SAL will tell us the maximum size of any error record of this type
-	max_size = ia64_sal_get_state_info_size(sal_info_type);
-	if (!max_size)
+	max_SAL_log_size = ia64_sal_get_state_info_size(sal_info_type);
+	if (!max_SAL_log_size)
 		/* alloc_bootmem() doesn't like zero-sized allocations! */
 		return;
 
 	// set up OS data structures to hold error info
-	IA64_LOG_ALLOCATE(sal_info_type, max_size);
-	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_size);
-	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_size);
+	IA64_LOG_ALLOCATE(sal_info_type, max_SAL_log_size);
+	memset(IA64_LOG_CURR_BUFFER(sal_info_type), 0, max_SAL_log_size);
+	memset(IA64_LOG_NEXT_BUFFER(sal_info_type), 0, max_SAL_log_size);
+	if (ia64_mca_init_bufs_set_up(&ia64_MCA_logs) != 0 ||
+				ia64_mca_init_bufs_set_up(&ia64_INIT_logs) != 0)
+		printk(KERN_WARNING "WARNING: MCA/INIT log buffer set up failed\n");
 }
 
 /*
@@ -517,7 +591,8 @@
 int cpe_vector = -1;
 int ia64_cpe_irq = -1;
 
-static irqreturn_t
+// static					// For testing purposes
+irqreturn_t
 ia64_mca_cpe_int_handler (int cpe_irq, void *arg)
 {
 	static unsigned long	cpe_history[CPE_HISTORY_LENGTH];
@@ -570,6 +645,9 @@
 	return IRQ_HANDLED;
 }
 
+EXPORT_SYMBOL(ia64_mca_cpe_int_handler);	// For testing purposes
+
+
 #endif /* CONFIG_ACPI */
 
 #ifdef CONFIG_ACPI
@@ -1190,6 +1268,45 @@
 }
 
 /*
+ * Helper for ia64_mca_handler().
+ */
+int
+ia64_mca_handler_helper(
+	unsigned int			* const size_p,	/* -> actual size of the log */
+	void				* const log,	/* SAL log buffer */
+	struct ia64_sal_os_state	* const sos)
+{
+	unsigned int			size;		/* Actual size of the log */
+	int				recover;
+
+	/* Get the MCA error record */
+	size = ia64_sal_get_state_info(SAL_INFO_TYPE_MCA, (u64 *) log);
+	if (size_p != NULL)
+		*size_p = size;
+
+	/* MCA error recovery */
+	recover = ia64_mca_ucmc_extension != NULL &&
+					ia64_mca_ucmc_extension(log, sos);
+	if (recover) {
+		sal_log_record_header_t *rh = log;
+		rh->severity = sal_log_severity_corrected;
+		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
+		sos->os_status = IA64_MCA_CORRECTED;
+	} else {
+		/* Dump buffered message to console */
+		ia64_mlogbuf_finish(1);
+#ifdef CONFIG_KEXEC
+		atomic_set(&kdump_in_progress, 1);
+#endif
+	}
+	return recover;
+}
+
+/* Placed after ia64_mca_handler(). Hopefully, it will not be inlined. */
+static int
+ia64_mca_handler_last_log(struct ia64_sal_os_state * const sos);
+
+/*
  * ia64_mca_handler
  *
  *	This is uncorrectable machine check handler called from OS_MCA
@@ -1214,6 +1331,7 @@
 		 struct ia64_sal_os_state *sos)
 {
 	int recover, cpu = smp_processor_id();
+	int log_buf_idx;
 	struct task_struct *previous_current;
 	struct ia64_mca_notify_die nd =
 		{ .sos = sos, .monarch_cpu = &monarch_cpu };
@@ -1255,34 +1373,29 @@
 		while (cpu_isset(cpu, mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
         }
+	/*
+	 * Try to pick up a buffer for the log coming from SAL_GET_STATE_INFO().
+	 */
+	if ((log_buf_idx = ia64_get_mca_init_log_buf(&ia64_MCA_logs)) >= 0){
+		l_buf_t	* const p = ia64_MCA_logs._buf[log_buf_idx];
+		
+		recover = ia64_mca_handler_helper(&p->_log_size, p->_data, sos);
+		p->_cpu = smp_processor_id();
+		/*
+		 * Tell salinfo that this log is valid.
+		 * Don't use set_bit(), ".rel" semantics is required.
+		 */
+		set_bit_rel(log_buf_idx, ia64_MCA_logs._valid);
+	} else
+		recover = ia64_mca_handler_last_log(sos);
 
-	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, MCA_IRQ_NOTSAFE);
-
-	/* MCA error recovery */
-	recover = (ia64_mca_ucmc_extension
-		&& ia64_mca_ucmc_extension(
-			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
-			sos));
+	if (!recover)
+		monarch_cpu = -1;	/* Do we really care??? */
 
-	if (recover) {
-		sal_log_record_header_t *rh = IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA);
-		rh->severity = sal_log_severity_corrected;
-		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
-		sos->os_status = IA64_MCA_CORRECTED;
-	} else {
-		/* Dump buffered message to console */
-		ia64_mlogbuf_finish(1);
-#ifdef CONFIG_KEXEC
-		atomic_set(&kdump_in_progress, 1);
-		monarch_cpu = -1;
-#endif
-	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			== NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
-
 	if (atomic_dec_return(&mca_count) > 0) {
 		int i;
 
@@ -1307,6 +1420,26 @@
 	monarch_cpu = -1;	/* This frees the slaves and previous monarchs */
 }
 
+/*
+ * Helper routine for ia64_mca_handler() when only the last log buffer is available.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ * It is placed after ia64_mca_handler(). Hopefully, it will not be inlined.
+ * Don't want buff[max_SAL_log_size] always be on the stack...
+ */
+static int
+ia64_mca_handler_last_log(
+	struct ia64_sal_os_state	* const sos)
+{
+	unsigned char	buff[max_SAL_log_size];
+	int		recover;
+	unsigned int	size;
+
+	if ((recover = ia64_mca_handler_helper(&size, buff, sos)))
+		(void) ia64_last_log_write(&ia64_MCA_logs, buff,
+						(size + sizeof(u32) - 1) / sizeof(u32));
+	return recover;
+}
+
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd);
 static DECLARE_WORK(cmc_enable_work, ia64_mca_cmc_vector_enable_keventd);
 
--- linux-2.6.24/include/asm-ia64/mca.h	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-new/include/asm-ia64/mca.h	2008-02-29 16:38:13.000000000 +0100
@@ -161,6 +161,129 @@
 
 DECLARE_PER_CPU(u64, ia64_mca_pal_base);
 
+/*
+ * IA64_MCA log support
+ */
+#define IA64_MAX_LOGS		2	/* Double-buffering for nested MCAs */
+#define IA64_MAX_LOG_TYPES      4   /* MCA, INIT, CMC, CPE */
+
+/*
+ * IA64_MCA log support:
+ * used for SAL_GET_STATE_INFO() data by the MCA/INIT handlers.
+ */
+#define	IA64_MAX_MCA_INIT_BUFS	3
+#if	IA64_MAX_MCA_INIT_BUFS < 2
+#error	Min. 2 buffers required
+#endif
+
+typedef struct ia64_state_log_s
+{
+	spinlock_t	isl_lock;
+	int		isl_index;
+	unsigned long	isl_count;
+	ia64_err_rec_t  *isl_log[IA64_MAX_LOGS]; /* need space to store header + error log */
+} ia64_state_log_t;
+
+/*
+ * These structures below describe the global buffers available for an MCA or an
+ * INIT handler to store SAL_GET_STATE_INFO() data.
+ *
+ * Note: there is no use saving non-recovered MCAs: there will be no chance for
+ * such a log to hit the permanent storage device.
+ *
+ * The rules are:
+ * - The first (IA64_MAX_MCA_INIT_BUFS - 1) logs and the very last one are
+ *   stored only.
+ * - The last one gets overwritten if there are too many logs there.
+ * - if (->_b_cnt <= IA64_MAX_MCA_INIT_BUFS), then ->_b_cnt counts the in-use
+ *   buffers. There is no lost log if (->_b_cnt < IA64_MAX_MCA_INIT_BUFS).
+ * - if (->_b_cnt => IA64_MAX_MCA_INIT_BUFS), then ->_gen_cnt is incremented
+ *   each time the last buffer gets over-written.
+ *
+ * The MCA/INIT handler plays as follows:
+ * - It fetches and increments ->_b_cnt in an atomic way.
+ * - If (previous value < IA64_MAX_MCA_INIT_BUFS - 1), then it can simply store
+ *   its log into ->_buf[ previous value ]. Having done that, it sets the
+ *   corresponding ->_valid bit.
+ * - Otherwise it races (incl. with the nesting handlers) for the last buffer:
+ *   + It increments ->_gen_cnt in an atomic way to obtain its generation count.
+ *   + It owns the last log buffer while no one else has got a higher generation
+ *     count.
+ *   + The log data is broken up into 4-byte chunks and they are stamped with
+ *     the generation count. They are written together as an atomic64_t into
+ *     (*->_last_buf)[] by use of a compare-and-swap primitive to make sure
+ *     that no one with higher generation count has passed by in the mean time.
+ *   + (*->_last_buf)[0] is a marker:
+ *     * Before writing the log data into the rest of (*->_last_buf)[], the
+ *       MCA/INIT handler sets the marker to say "not done"
+ *       (LAST_LOG_DONE bit off).
+ *     * Having finished, it sets the marker to say "done"
+ *       (LAST_LOG_DONE bit on).
+ *
+ * The salinfo side polls ->_b_cnt:
+ * - Once their corresponding ->_valid bit is set, it is safe to read, at any
+ *   time, without any further precaution, the first
+ *   MIN(IA64_MAX_MCA_INIT_BUFS - 1, ->_b_cnt) buffer entries.
+ * - The salinfo side can clear the ->_valid bits at any time with atomic bit
+ *   operations. While ->_b_cnt is not reset to 0, the log buffers are not reused.
+ * - If (->_b_cnt > IA64_MAX_MCA_INIT_BUFS - 1), then the last buffer is read as
+ *   follows:
+ *   + Pick up ->_gen_cnt.
+ *   + Verify the marker (*->_last_buf)[0], it should have the bit LAST_LOG_DONE
+ *     on. (Otherwise come back later...)
+ *   + While reading (*->_last_buf)[], verify if the generation count in each
+ *     item is the same. (Otherwise restart...)
+ * - The salinfo side can reset ->_b_cnt to 0 with an atomic operation, provided
+ *   it has not changed. (Otherwise restart...)
+ */
+
+typedef struct l_buf_s {
+	u32		_cpu;
+	u32		_log_size;
+	u8		_data[];
+} l_buf_t;
+
+typedef struct ia64_mca_init_buf_s {
+	l_buf_t		*_buf[IA64_MAX_MCA_INIT_BUFS - 1];
+	atomic_t	_b_cnt;		/* Counts the in-use _buf[]'s */
+	u32		_valid[DIV_ROUND_UP(IA64_MAX_MCA_INIT_BUFS - 1, 32)];
+	atomic64_t	(*_last_buf)[0];
+	atomic_t	_gen_cnt;	/* Generation counter for _last_buf[] */
+	u32		_gen_seen;	/* Generation seen by salinfo */
+//	u32		_buf_seen;	/* ->_buf[i] seen by salinfo */
+} ia64_mca_init_buf_t;
+
+/* For the marker item of (*->_last_buf)[0]: */
+#define	LAST_LOG_DONE		(1 << 31)
+
+/* Macros for (*->_last_buf)[]: */
+#define	GET_GEN_CNT(x)		((u32) x)		/* Generation counter */
+#define	GET_LOG_DATA(x)		((u32) (x >> 32))	/* Log data */
+#define	COMPOSE_AT_VAL(gc, dt)	((u32) gc | ((u64) dt << 32))
+
+/*
+ * Store a 4-byte value into (*->_last_buf)[i].
+ */
+static inline int
+set_last_buf_item(
+	atomic64_t	* const p,		/* == &(*->_last_buf)[i] */
+	unsigned int	const gen_cnt,		/* Generation count */
+	u32		const value)
+{
+	u64		tmp;
+
+	do {
+		tmp = atomic64_read(p);
+		/*
+		 * If you can see a higher generation count than yours,
+		 * then you are not the last - bail out.
+		 */
+		if (GET_GEN_CNT(tmp) > gen_cnt)
+			return -1;
+	} while (cmpxchg_rel(p, tmp, COMPOSE_AT_VAL(gen_cnt, value)) != tmp);
+	return 0;
+}
+
 #else	/* __ASSEMBLY__ */
 
 #define IA64_MCA_CORRECTED	0x0	/* Error has been corrected by OS_MCA */
--- linux-2.6.24/arch/ia64/kernel/salinfo.c	2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-new/arch/ia64/kernel/salinfo.c	2008-03-04 17:06:48.000000000 +0100
@@ -49,10 +49,15 @@
 #include <asm/sal.h>
 #include <asm/uaccess.h>
 
+#include <asm/mca.h>
+
 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
 MODULE_LICENSE("GPL");
 
+extern ia64_mca_init_buf_t ia64_MCA_logs;	/* Log buffers for the MCA handler */
+extern ia64_mca_init_buf_t ia64_INIT_logs;	/* Log buffers for the INIT handler */
+
 static int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
 
 typedef struct {
@@ -283,8 +288,20 @@
 static void
 salinfo_timeout (unsigned long arg)
 {
+	unsigned long flags;
+
 	ia64_mlogbuf_dump();
-	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
+	if (atomic_read(&ia64_MCA_logs._b_cnt) > 0 ){
+		spin_lock_irqsave(&data_saved_lock, flags);
+		salinfo_work_to_do(salinfo_data + SAL_INFO_TYPE_MCA);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+	}
+	if (atomic_read(&ia64_INIT_logs._b_cnt) > 0 ){
+		spin_lock_irqsave(&data_saved_lock, flags);
+		salinfo_work_to_do(salinfo_data + SAL_INFO_TYPE_INIT);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+	}
+//	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
 	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_INIT);
 	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
 	add_timer(&salinfo_timer);
@@ -298,6 +315,136 @@
 	return 0;
 }
 
+
+#define	MIN(a, b)	(a < b ? a : b)
+
+
+/*
+ * Copy the "last log" into some regular buffer.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns 1 if the last log has successfully been fetched.
+ */
+static inline int
+copy_last_log(
+	const atomic64_t	*p,		/* On entry: p == &(*->_last_buf)[2] */
+	u32			*dest,
+	unsigned int		const gen,
+	unsigned int		size)		/* SAL log size in u32 units */
+{
+	u64			tmp;
+
+	while (size-- > 0){
+		tmp = atomic64_read(p++);
+		if (GET_GEN_CNT(tmp) != gen)
+			return 0;
+		*dest++ = GET_LOG_DATA(tmp);
+	}
+	return 1;
+}
+
+/*
+ * Fetch the "last log" created by ia64_last_log_write() in mca.c.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns 0 if the last log has successfully been fetched.
+ */
+static inline int
+fetch_last_log(
+	ia64_mca_init_buf_t	* const bp,	/* Where to look for the logs */
+	struct salinfo_data	* const data)
+{
+	unsigned int		gen;
+	const atomic64_t	*p;
+	u64			tmp;
+
+//	printk("%s(%p,...): type: %d, CPU: %d\n", __FUNCTION__, bp, data->type, smp_processor_id());
+	for (;; schedule()) {
+		gen = atomic_read(&bp->_gen_cnt);	/* Generation counter for _last_buf[] */
+		p = &(*bp->_last_buf)[0];
+//		printk("gen: 0x%x, _last_buf: %p\n", gen, p);
+		tmp = atomic64_read(p++);		/* The marker */
+		if (GET_GEN_CNT(tmp) != gen)
+			continue;
+		tmp = GET_LOG_DATA(tmp);
+		if (!(tmp & LAST_LOG_DONE))
+			continue;
+		tmp = atomic64_read(p++);		/* SAL log size in u32 units */
+		if (GET_GEN_CNT(tmp) != gen)
+			continue;
+		if (copy_last_log(p, (void *) data->log_buffer, gen, GET_LOG_DATA(tmp)))
+			break;
+	}
+	data->log_size = GET_LOG_DATA(tmp) * sizeof(u32);
+	bp->_gen_seen = gen;
+	return 0;
+}
+
+#define	JUST_TEST_LOGS		0
+#define	DO_FETCH_LOG		1
+
+/*
+ * Check to see if we have already seen all the logs in *bp.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns 1 if some logs are available.
+ */
+static int
+any_log_available(
+	ia64_mca_init_buf_t	* const bp,	/* Where to look for the logs */
+	struct salinfo_data	* const data,
+	unsigned int		const mode)	/* JUST_TEST_LOGS, DO_FETCH_LOG */
+{
+	l_buf_t			*p;
+	unsigned int		const b_cnt = atomic_read(&bp->_b_cnt);
+	unsigned int		const idx_limit = MIN(IA64_MAX_MCA_INIT_BUFS - 1, b_cnt);
+	unsigned int		i;
+
+//	printk("%s(0x%p,... %d): mode: %d\n", __FUNCTION__, bp, data->type, mode);
+	for (i = 0; i < idx_limit; i++)
+		if (test_bit(i, bp->_valid)){
+			p = bp->_buf[i];
+//			printk("valid bit #%d, buf; %p\n", i, p);
+			if (mode == JUST_TEST_LOGS)
+				return 1;
+			data->log_size = p->_log_size;
+			memcpy(data->log_buffer, p->_data, p->_log_size);
+			clear_bit(i, bp->_valid);
+			/*
+			 * Check to see if all the buffers have been consumed.
+			 */
+			for (i = 0; i < idx_limit; i++)
+				if (test_bit(i, bp->_valid))
+					return 1;
+			if (b_cnt < IA64_MAX_MCA_INIT_BUFS ||
+					bp->_gen_seen == atomic_read(&bp->_gen_cnt)){
+				/*
+				 * Clear ->_b_cnt. It can fail.
+				 * ... will be seen next time...
+				 */
+				(void) cmpxchg(&bp->_b_cnt, b_cnt, 0);
+			}
+			return 1;
+		}
+	if (atomic_read(&bp->_gen_cnt) == bp->_gen_seen)
+		return 0;
+	if (mode == JUST_TEST_LOGS)
+		return 1;
+	if (fetch_last_log(bp, data))
+		return 1;
+	/*
+	 * Check to see if all the buffers have been consumed.
+	 */
+	for (i = 0; i < IA64_MAX_MCA_INIT_BUFS - 1; i++)
+		if (test_bit(i, bp->_valid))
+			return 1;
+	/*
+	 * Clear ->_b_cnt. It can fail. ... will be seen next time...
+	 */
+	(void) cmpxchg(&bp->_b_cnt, b_cnt, 0);
+	return 1;
+}
+
 static ssize_t
 salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t *ppos)
 {
@@ -317,29 +464,35 @@
 	}
 
 	n = data->cpu_check;
-	for (i = 0; i < NR_CPUS; i++) {
-		if (cpu_isset(n, data->cpu_event)) {
-			if (!cpu_online(n)) {
-				cpu_clear(n, data->cpu_event);
-				continue;
+//	printk("CPU %d: %s(): data->cpu_check: %d, data->cpu_event: %016lx\n", smp_processor_id(),
+//					__FUNCTION__, n, data->cpu_event.bits[0]);	// :-)
+	if (atomic_read(&ia64_MCA_logs._b_cnt) > 0 || atomic_read(&ia64_INIT_logs._b_cnt) > 0){
+//		printk("%d %d\n", atomic_read(&ia64_MCA_logs._b_cnt), atomic_read(&ia64_INIT_logs._b_cnt));
+		cpu = any_online_cpu(cpu_online_map);
+	} else {
+		for (i = 0; i < NR_CPUS; i++) {
+			if (cpu_isset(n, data->cpu_event)) {
+				if (!cpu_online(n)) {
+					cpu_clear(n, data->cpu_event);
+					continue;
+				}
+				cpu = n;
+				break;
 			}
-			cpu = n;
-			break;
+			if (++n == NR_CPUS)
+				n = 0;
 		}
-		if (++n == NR_CPUS)
-			n = 0;
-	}
-
-	if (cpu == -1)
-		goto retry;
 
-	ia64_mlogbuf_dump();
+		if (cpu == -1)
+			goto retry;
 
-	/* for next read, start checking at next CPU */
-	data->cpu_check = cpu;
-	if (++data->cpu_check == NR_CPUS)
-		data->cpu_check = 0;
+		ia64_mlogbuf_dump();
 
+		/* for next read, start checking at next CPU */
+		data->cpu_check = cpu;
+		if (++data->cpu_check == NR_CPUS)
+			data->cpu_check = 0;
+	}
 	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);
 
 	size = strlen(cmd);
@@ -415,6 +568,7 @@
 {
 	struct salinfo_data *data = context;
 	sal_log_record_header_t *rh;
+
 	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
 	rh = (sal_log_record_header_t *)(data->log_buffer);
 	/* Clear corrected errors as they are read from SAL */
@@ -431,6 +585,18 @@
 	int saved_size = ARRAY_SIZE(data->data_saved);
 
 	data->saved_num = 0;
+	switch (data->type){
+	case SAL_INFO_TYPE_MCA:
+//		printk("%s(): data->state: %d\n", __FUNCTION__, data->state);
+		if (any_log_available(&ia64_MCA_logs, data, JUST_TEST_LOGS))
+			data->state = STATE_LOG_RECORD;
+		return;
+	case SAL_INFO_TYPE_INIT:
+//		printk("%s(): data->state: %d\n", __FUNCTION__, data->state);
+		if (any_log_available(&ia64_INIT_logs, data, JUST_TEST_LOGS))
+			data->state = STATE_LOG_RECORD;
+		return;
+	}
 	spin_lock_irqsave(&data_saved_lock, flags);
 retry:
 	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
@@ -469,7 +635,20 @@
 	u8 *buf;
 	u64 bufsize;
 
+//	printk("%s(): data->state: %d\n", __FUNCTION__, data->state);
 	if (data->state == STATE_LOG_RECORD) {
+		switch (data->type){
+		case SAL_INFO_TYPE_MCA:
+			data->log_size = 0;
+			(void) any_log_available(&ia64_MCA_logs, data, DO_FETCH_LOG);
+			data->state = STATE_NO_DATA;
+			break;
+		case SAL_INFO_TYPE_INIT:
+			data->log_size = 0;
+			(void) any_log_available(&ia64_INIT_logs, data, DO_FETCH_LOG);
+			data->state = STATE_NO_DATA;
+			break;
+		}
 		buf = data->log_buffer;
 		bufsize = data->log_size;
 	} else if (data->state == STATE_OEMDATA) {
@@ -479,6 +658,8 @@
 		buf = NULL;
 		bufsize = 0;
 	}
+//	printk("%s(): buf: %p, count: %ld, pos: %lld, bufsize: %ld\n",
+//				__FUNCTION__, buf, count, *ppos, bufsize);
 	return simple_read_from_buffer(buffer, count, ppos, buf, bufsize);
 }
 
diff -Nru linux-2.6.24-tmp/include/asm-ia64/bitops.h linux-2.6.24-new-tmp/include/asm-ia64/bitops.h
--- linux-2.6.24-tmp/include/asm-ia64/bitops.h	2008-03-04 15:58:19.000000000 +0100
+++ linux-2.6.24-new-tmp/include/asm-ia64/bitops.h	2008-03-04 15:59:27.000000000 +0100
@@ -51,6 +51,39 @@
 }
 
 /**
+ * set_bit_rel - Atomically set a bit in memory with ".rel" semantics
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * This function is atomic and may not be reordered.  See __set_bit()
+ * if you do not require the atomic guarantees.
+ * Note that @nr may be almost arbitrarily large; this function is not
+ * restricted to acting on a single-word quantity.
+ *
+ * The address must be (at least) "long" aligned.
+ * Note that there are driver (e.g., eepro100) which use these operations to
+ * operate on hw-defined data-structures, so we can't easily change these
+ * operations to force a bigger alignment.
+ *
+ * bit 0 is the LSB of addr; bit 32 is the LSB of (addr+1).
+ */
+static __inline__ void
+set_bit_rel (int nr, volatile void *addr)
+{
+	__u32 bit, old, new;
+	volatile __u32 *m;
+	CMPXCHG_BUGCHECK_DECL
+
+	m = (volatile __u32 *) addr + (nr >> 5);
+	bit = 1 << (nr & 31);
+	do {
+		CMPXCHG_BUGCHECK(m);
+		old = *m;
+		new = old | bit;
+	} while (cmpxchg_rel(m, old, new) != old);
+}
+
+/**
  * __set_bit - Set a bit in memory
  * @nr: the bit to set
  * @addr: the address to start counting from

--------------040901070805040308050508--
