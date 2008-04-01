From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Date: Tue, 01 Apr 2008 15:18:51 +0000
Subject: [PATCH] New way of storing MCA/INIT logs - take 2
Message-Id: <47F2525B.10104@bull.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------090309010608030100070903"
List-Id: <linux-ia64.vger.kernel.org>
References: <47CD8142.7050207@bull.net>
In-Reply-To: <47CD8142.7050207@bull.net>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------090309010608030100070903
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds a lock free, yet safe way of storing MCA/INIT logs.
You will not end up with logs mixed up from different MCAs.

By default, there are N_MCA_INIT_LOGS log buffers for the MCA, and
another N_MCA_INIT_LOGS log buffers for the INIT handler.
Boot command-line options of "nMCAlogs=<NUM>" and "nINITlogs=<NUM>,
where <NUM> is an integer greater than N_MCA_INIT_LOGS, override
the default values.

The first ("N" - 1) logs and the very last one are stored only.
The last one gets overwritten if there are too many logs there.

The admin. info. is in a structure ia64_mca_init_buf_t, see in mca.h.

Handling the first ("N" - 1) log buffers is straight forward:
You increment an atomic variable (->_b_cnt) and you use it as
index to ->_buf[].
Having completed the log, you set the corresponding validity bit.

Otherwise you race (incl. with the nested handlers) for the last buffer:
- Increment the atomic generation counter (->_gen_cnt).
- You own the last log buffer while no one else has got a higher
  generation count.
- The log data is broken up into 4-byte chunks and they are stamped with
  the generation count. They are written together as an atomic64_t into
  the last buffer (*->_last_buf)[] by use of a compare-and-swap primitive
  to make sure that no one with higher generation count has passed by in
  the mean time.
- (*->_last_buf)[0] is a marker:
  * Before writing the log data into the rest of (*->_last_buf)[], you
    set the marker to say "not done" (MCA_INIT_LOG_VALID bit off).
  * Having finished, you set the marker to say "done"
    (MCA_INIT_LOG_VALID bit on).

This is how the code backs off if someone writes the same buffer with
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
If there is no log left to save, it clears ->_b_cnt.
There is no "shift" of the logs in the buffers at the salinfo side.

Well, the the old code is not cleaned up...

Changes since the previous patch:
- Boot command-line options of "nMCAlogs=<NUM>" and "nINITlogs=<NUM>
- Reusing the "struct salinfo_data" infrastructure (not the data buffers)

Notes:
- Writing "clear <cpunum>" does not actually clear the SAL's log record.
  The MCA handler clears the recovered events.
- When checking to see if there is an MCA log coming before the reboot,
  the CPU number should have been picked up from the Processor Device
  Error Info. Yet a CPU causing fatal errors can be excluded after the
  reboot, the CPUs can be renumbered, etc. This implementation lets
  any CPU pick up logs coming before the reboot.
- Apply the patch http://marc.info/?l=linux-ia64&m=120418991227044&w=3
  before this one.

Thanks,

Zoltan Menyhart



--------------090309010608030100070903
Content-Type: text/plain;
 name="new-mca-log-patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="new-mca-log-patch"

diff -Nru linux-2.6.24-tmp/arch/ia64/kernel/mca.c linux-2.6.24-new-tmp/arch/ia64/kernel/mca.c
--- linux-2.6.24-tmp/arch/ia64/kernel/mca.c	2008-04-01 13:07:33.000000000 +0200
+++ linux-2.6.24-new-tmp/arch/ia64/kernel/mca.c	2008-03-31 11:15:08.000000000 +0200
@@ -183,6 +183,131 @@
 #define	MCA_IRQ_SAFE	1	/* NOT called from the MCA/INIT handlers */
 
 
+#define	N_MCA_INIT_LOGS	3
+ia64_mca_init_buf_t ia64_MCA_logs;	/* Log buffers for the MCA handler */
+ia64_mca_init_buf_t ia64_INIT_logs;	/* Log buffers for the INIT handler */
+static unsigned int ia64_n_MCA_logs __initdata =	/* Incl. the "last log" */
+					N_MCA_INIT_LOGS;
+static unsigned int ia64_n_INIT_logs __initdata =	/* Incl. the "last log" */
+					N_MCA_INIT_LOGS;
+EXPORT_SYMBOL(ia64_MCA_logs);
+EXPORT_SYMBOL(ia64_INIT_logs);
+
+/*
+ * Command-line options of "nMCAlogs=<NUM>" and "nINITlogs=<NUM>,
+ * where <NUM> is an integer greater than N_MCA_INIT_LOGS, set the
+ * maximum number of the MCA / INIT log buffers, incl. the "last one".
+ */
+
+static int __init
+set_ia64_n_MCA_logs(char *str)
+{
+	unsigned int arg;
+
+	if (get_option(&str, &arg) != 1 /* int found, no subsequent comma */)
+		return 1;
+	if (ia64_n_MCA_logs >= arg)
+		return 1;
+	ia64_n_MCA_logs = arg;
+	return 0;
+}
+
+static int __init
+set_ia64_n_INIT_logs(char *str)
+{
+	unsigned int arg;
+
+	if (get_option(&str, &arg) != 1 /* int found, no subsequent comma */)
+		return 1;
+	if (ia64_n_INIT_logs >= arg)
+		return 1;
+	ia64_n_INIT_logs = arg;
+	return 0;
+}
+
+early_param("nMCAlogs", set_ia64_n_MCA_logs);
+early_param("nINITlogs", set_ia64_n_INIT_logs);
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
+					smp_processor_id() | MCA_INIT_LOG_VALID);
+}
+
+/*
+ * Try to pick up a buffer for MCA/INIT log coming from SAL_GET_STATE_INFO().
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns a pointer to the buffer, or NULL on failure.
+ */
+static log_buf_t *
+ia64_get_mca_init_log_buf(
+	ia64_mca_init_buf_t	* const bp)	/* Log buffer admin. info. */
+{
+	unsigned int		idx;		/* Index to ->_buf[] */
+
+	idx = ia64_fetchadd4_acq(&bp->_b_cnt, 1);	/* Returns the old value */
+	return idx < bp->_n_bufs ? MCA_BUFFER(bp, idx) : NULL;
+}
+
+/*
+ * Set up the log buffers for an MCA/INIT handler.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ */
+static inline int
+ia64_mca_init_bufs_set_up(
+	ia64_mca_init_buf_t	* const bp,	/* Log buffers for an MCA/INIT handler */
+	unsigned int		const n_buffs,	/* Incl. the "last log" */
+	unsigned int		sal_info_type)
+{ 
+	/* SAL will tell us the maximum size of any error record of this type. */
+	if ((bp->_b_size = ia64_sal_get_state_info_size(sal_info_type)) == 0)
+		return -1;
+	/* Add 4 bytes for the CPU number and 4 more for the actual log size. */
+	bp->_b_size = (bp->_b_size + 8 + sizeof(u64) - 1) & ~(sizeof(u64) - 1);
+	/*
+	 * Allocate the (n_buffs - 1) conventional buffers. The "last one" stores 4
+	 * bytes on each atomic64_t, therefore allocate twice of ->_b_size for it.
+	 */
+	bp->_buf = (log_buf_t (*)[]) alloc_bootmem((n_buffs - 1 + 2) * bp->_b_size);
+	if (bp->_buf == NULL)
+		return -1;
+	memset(bp->_buf, 0, (n_buffs - 1 + 2) * bp->_b_size);
+	/* The conventional log buffers w/o the "last log". */
+	bp->_n_bufs = n_buffs - 1;
+	/* The "last log buffer": */
+	bp->_last_buf = (atomic64_t (*)[]) ((u8 *) bp->_buf + bp->_b_size * (n_buffs - 1));
+	return 0;
+}
+
 /*
  * Push messages into buffer, print them later if not urgent.
  */
@@ -323,19 +448,6 @@
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
 
@@ -1194,6 +1306,41 @@
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
+	int				recover;
+
+	/* Get the MCA error record */
+	*size_p = ia64_sal_get_state_info(SAL_INFO_TYPE_MCA, (u64 *) log);
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
+static int
+ia64_mca_handler_last_log(struct ia64_sal_os_state * const sos);
+
+/*
  * ia64_mca_handler
  *
  *	This is uncorrectable machine check handler called from OS_MCA
@@ -1218,6 +1365,7 @@
 		 struct ia64_sal_os_state *sos)
 {
 	int recover, cpu = smp_processor_id();
+	log_buf_t *log_buf;
 	struct task_struct *previous_current;
 	struct ia64_mca_notify_die nd =
 		{ .sos = sos, .monarch_cpu = &monarch_cpu };
@@ -1259,34 +1407,29 @@
 		while (cpu_isset(cpu, mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
         }
+	/*
+	 * Try to pick up a buffer for the log coming from SAL_GET_STATE_INFO().
+	 */
+	if ((log_buf = ia64_get_mca_init_log_buf(&ia64_MCA_logs)) != NULL){
+		/* (->_cpu & MCA_INIT_LOG_VALID) was off, and remains off. */
+		log_buf->_cpu = smp_processor_id();
+		recover = ia64_mca_handler_helper(&log_buf->_log_size, log_buf->_data, sos);
+		/*
+		 * Tell salinfo that this log is valid.
+		 * Don't use set_bit(), ".rel" semantics is required.
+		 * Note that if !recover'ed => nobody will read this log.
+		 */
+		set_bit_rel(MCA_INIT_LOG_VALID_N, &log_buf->_cpu);
+	} else
+		recover = ia64_mca_handler_last_log(sos);
 
-	/* Get the MCA error record and log it */
-	ia64_mca_log_sal_error_record(SAL_INFO_TYPE_MCA, MCA_IRQ_NOTSAFE);
+	if (!recover)
+		monarch_cpu = -1;	/* Do we really care??? */
 
-	/* MCA error recovery */
-	recover = (ia64_mca_ucmc_extension
-		&& ia64_mca_ucmc_extension(
-			IA64_LOG_CURR_BUFFER(SAL_INFO_TYPE_MCA),
-			sos));
-
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
 
@@ -1311,6 +1454,27 @@
 	monarch_cpu = -1;	/* This frees the slaves and previous monarchs */
 }
 
+/*
+ * Helper routine for ia64_mca_handler() when only the last log buffer is
+ * available.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ * Should not be inlined.
+ * Don't want buff[max_SAL_log_size] always be on the stack...
+ */
+static noinline int
+ia64_mca_handler_last_log(
+	struct ia64_sal_os_state	* const sos)
+{
+	unsigned char	buff[ia64_MCA_logs._b_size];
+	int		recover;
+	unsigned int	size;
+
+	if ((recover = ia64_mca_handler_helper(&size, buff, sos)))
+		(void) ia64_last_log_write(&ia64_MCA_logs, buff,
+					(size + sizeof(u32) - 1) / sizeof(u32));
+	return recover;
+}
+
 static DECLARE_WORK(cmc_disable_work, ia64_mca_cmc_vector_disable_keventd);
 static DECLARE_WORK(cmc_enable_work, ia64_mca_cmc_vector_enable_keventd);
 
@@ -2015,10 +2179,15 @@
 	 * platform/processor error states for MCA/INIT/CMC
 	 * handling.
 	 */
-	ia64_log_init(SAL_INFO_TYPE_MCA);
+//	ia64_log_init(SAL_INFO_TYPE_MCA);
 	ia64_log_init(SAL_INFO_TYPE_INIT);
 	ia64_log_init(SAL_INFO_TYPE_CMC);
 	ia64_log_init(SAL_INFO_TYPE_CPE);
+	if (ia64_mca_init_bufs_set_up(&ia64_MCA_logs, ia64_n_MCA_logs,
+							SAL_INFO_TYPE_MCA) != 0 ||
+			ia64_mca_init_bufs_set_up(&ia64_INIT_logs, ia64_n_INIT_logs,
+							SAL_INFO_TYPE_INIT) != 0)
+		printk(KERN_WARNING "WARNING: MCA/INIT log buffer set up failed\n");
 
 	mca_init = 1;
 	printk(KERN_INFO "MCA related initialization done\n");
diff -Nru linux-2.6.24-tmp/arch/ia64/kernel/salinfo.c linux-2.6.24-new-tmp/arch/ia64/kernel/salinfo.c
--- linux-2.6.24-tmp/arch/ia64/kernel/salinfo.c	2008-04-01 13:07:33.000000000 +0200
+++ linux-2.6.24-new-tmp/arch/ia64/kernel/salinfo.c	2008-04-01 13:05:24.000000000 +0200
@@ -36,6 +36,12 @@
  *   Modify the locking to make the test for "work to do" an atomic operation.
  */
 
+#if 0
+#define	D_printk(...)            printk(__VA_ARGS__)
+#else
+#define	D_printk(...)            do { } while (0)
+#endif
+
 #include <linux/capability.h>
 #include <linux/cpu.h>
 #include <linux/types.h>
@@ -49,10 +55,16 @@
 #include <asm/sal.h>
 #include <asm/uaccess.h>
 
+#include <asm/mca.h>
+
 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
 MODULE_LICENSE("GPL");
 
+extern ia64_mca_init_buf_t ia64_MCA_logs;	/* Log buffers for the MCA handler */
+extern ia64_mca_init_buf_t ia64_INIT_logs;	/* Log buffers for the INIT handler */
+static int ia64_old_mca_log_checked;		/* Coming before the reboot */
+
 static int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);
 
 typedef struct {
@@ -262,6 +274,58 @@
 	}
 }
 
+#define	MIN(a, b)	(a < b ? a : b)
+
+/*
+ * Check to see if we have got any not yet seen log in *bp (incl. the "last one").
+ * Set the bits in event mask indicating which CPUs are involved.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns:	FALSE if there is no fresh log.
+ *
+ * Note: If "cpu_event_p" points at "cpu_event" of "salinfo_data" than apply the
+ * necessary locking.
+ */
+static int
+new_log_available_set_events(
+	cpumask_t		* const cpu_event_p,
+	ia64_mca_init_buf_t	* const bp)	/* Where to look for the logs */
+{
+	int			found = 0;
+	unsigned int		const limit = MIN(atomic_read(&bp->_b_cnt),
+						bp->_n_bufs /* Excl. the "last log" */);
+	unsigned int		i;
+	unsigned long		tmp;
+
+	for (i = 0; i < limit; i++){
+		tmp = MCA_BUFFER(bp, i)->_cpu;
+		if (MCA_INIT_LOG_VALID & tmp){
+			D_printk("%s(): cpu %ld got event\n", __FUNCTION__,
+								tmp & MCA_INIT_CPU_MASK);
+			cpu_set(tmp & MCA_INIT_CPU_MASK, *cpu_event_p);
+			found = 1;
+		}
+	}
+	if (bp->_last_buf == NULL)
+		return found;
+	for (;; cpu_relax()){
+		i = atomic_read(&bp->_gen_cnt);		/* Gen. counter for _last_buf[] */
+		tmp = atomic64_read(&(*bp->_last_buf)[0]);	/* The marker */
+		if (GET_GEN_CNT(tmp) != i)
+			continue;
+		i = GET_LOG_DATA(tmp);
+		if (i & MCA_INIT_LOG_VALID){
+			D_printk("%s(): cpu %d got \"last\" event\n", __FUNCTION__,
+								i & MCA_INIT_CPU_MASK);
+			cpu_set(i & MCA_INIT_CPU_MASK, *cpu_event_p);
+			return 1;
+		} else
+			return found;
+	}
+	/*NOTREACHED*/
+}
+
+
 /* Check for outstanding MCA/INIT records every minute (arbitrary) */
 #define SALINFO_TIMER_DELAY (60*HZ)
 static struct timer_list salinfo_timer;
@@ -273,6 +337,9 @@
 	unsigned long flags;
 	if (!data->open)
 		return;
+	if (data->type == SAL_INFO_TYPE_MCA)
+		D_printk("%s(): events: 0x%016lx\n", __FUNCTION__,
+			* (u64 *) & (salinfo_data + SAL_INFO_TYPE_MCA)->cpu_event);
 	if (!cpus_empty(data->cpu_event)) {
 		spin_lock_irqsave(&data_saved_lock, flags);
 		salinfo_work_to_do(data);
@@ -280,11 +347,59 @@
 	}
 }
 
+/*
+ * Check to see if there is an MCA log coming before the reboot.
+ * (Should not be inlined: don't want this buffer on the stack all the time.)
+ *
+ * Returns:	The number of the CPU involved, or -1.
+ */
+static noinline int
+check_old_mca(unsigned int b_size)
+{
+	u8 l_buff[b_size];
+
+	if (ia64_sal_get_state_info(SAL_INFO_TYPE_MCA, (u64 *) l_buff) == 0)
+		return -1;
+	/*
+	 * Well, the CPU number should have been picked up from the
+	 * Processor Device Error Info.
+	 */
+	return smp_processor_id();
+}
+
 static void
 salinfo_timeout (unsigned long arg)
 {
+	struct salinfo_data *data;
+	cpumask_t cpu_event;
+	unsigned int cpu;
+	unsigned long flags;
+
 	ia64_mlogbuf_dump();
-	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_MCA);
+	data = salinfo_data + SAL_INFO_TYPE_MCA;
+	if (!ia64_old_mca_log_checked){			/* Coming before the reboot? */
+		if (ia64_MCA_logs._b_size == 0)
+			ia64_old_mca_log_checked = 1;	/* MCA init. went wrong */
+		else
+			if ((cpu = check_old_mca(ia64_MCA_logs._b_size)) == -1)
+				ia64_old_mca_log_checked = 1;
+			else {
+				spin_lock_irqsave(&data_saved_lock, flags);
+				cpu_set(cpu, data->cpu_event);
+				salinfo_work_to_do(data);
+				spin_unlock_irqrestore(&data_saved_lock, flags);
+				D_printk("events: 0x%016lx\n", * (u64 *) & data->cpu_event);
+			}
+	}
+	cpus_clear(cpu_event);
+	if (new_log_available_set_events(&cpu_event, &ia64_MCA_logs)){
+		D_printk("new events: 0x%016lx\n", * (u64 *) & cpu_event);
+		spin_lock_irqsave(&data_saved_lock, flags);
+		cpus_or(data->cpu_event, data->cpu_event, cpu_event);
+		salinfo_work_to_do(data);
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+	}
+// The new logging mechanism has not been integrated into the INIT handler yet
 	salinfo_timeout_check(salinfo_data + SAL_INFO_TYPE_INIT);
 	salinfo_timer.expires = jiffies + SALINFO_TIMER_DELAY;
 	add_timer(&salinfo_timer);
@@ -298,6 +413,136 @@
 	return 0;
 }
 
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
+ */
+static inline void
+fetch_last_log(
+	ia64_mca_init_buf_t	* const bp,	/* Where to look for the logs */
+	struct salinfo_data	* const data)
+{
+	unsigned int		gen;
+	const atomic64_t	*p;
+	u64			tmp;
+
+//	D_printk("%s(%p,...): type: %d, CPU: %d\n", __FUNCTION__, bp, data->type,
+//								smp_processor_id());
+	for (;; cpu_relax()) {
+		gen = atomic_read(&bp->_gen_cnt);	/* Gen. counter for _last_buf[] */
+		p = &(*bp->_last_buf)[0];
+		tmp = atomic64_read(p++);		/* The marker */
+		if (GET_GEN_CNT(tmp) != gen)
+			continue;
+		tmp = GET_LOG_DATA(tmp);
+		/*
+		 * Before we got here, we have already seen MCA_INIT_LOG_VALID on.
+		 * If it is off, then the log is being updated in this very moment.
+		 */
+		if (!(tmp & MCA_INIT_LOG_VALID))
+			continue;
+		tmp = atomic64_read(p++);		/* SAL log size in u32 units */
+		if (GET_GEN_CNT(tmp) != gen)
+			continue;
+		if (copy_last_log(p, (void *) data->log_buffer, gen, GET_LOG_DATA(tmp)))
+			break;
+	}
+	data->log_size = GET_LOG_DATA(tmp) * sizeof(u32);
+	bp->_gen_seen = gen;
+}
+
+#define	JUST_TEST_LOGS		0
+#define	DO_FETCH_LOG		1
+
+/*
+ * Check to see if we have already seen all the logs for a CPU in *bp.
+ * See the comment above the definition of "ia64_mca_init_buf_t" in mca.h.
+ *
+ * Returns TRUE if some logs are available.
+ */
+static int
+is_log_available(
+	ia64_mca_init_buf_t	* const bp,	/* Where to look for the logs */
+	unsigned int		const cpu,
+	struct salinfo_data	* const data,
+	unsigned int		const mode)	/* JUST_TEST_LOGS, DO_FETCH_LOG */
+{
+	log_buf_t		*p;
+	unsigned int		const b_cnt = atomic_read(&bp->_b_cnt);
+	unsigned int		const limit = MIN( atomic_read(&bp->_b_cnt),
+						bp->_n_bufs /* Excl. the "last log" */);
+	unsigned int		i;
+
+	D_printk("%s(0x%p,... %d): mode: %d\n", __FUNCTION__, bp, data->type, mode);
+	for (i = 0; i < limit; i++){
+		p =  MCA_BUFFER(bp, i);
+		if (MCA_INIT_LOG_VALID & p->_cpu){
+			D_printk("buffer #%d @ %p valid\n", i, p);
+			if (mode == JUST_TEST_LOGS)
+				return 1;
+			data->log_size = p->_log_size;
+			memcpy(data->log_buffer, p->_data, p->_log_size);
+			p->_cpu &= ~MCA_INIT_LOG_VALID;
+			/*
+			 * Check to see if all the buffers have been consumed.
+			 */
+			for (i = 0; i < limit; i++)
+				if (MCA_INIT_LOG_VALID & MCA_BUFFER(bp, i)->_cpu)
+					return 1;
+			if (b_cnt <= bp->_n_bufs ||
+					bp->_gen_seen == atomic_read(&bp->_gen_cnt)){
+				/*
+				 * Clear ->_b_cnt. It can fail.
+				 * ... will be done next time...
+				 */
+				(void) cmpxchg(&bp->_b_cnt, b_cnt, 0);
+			}
+			return 1;
+		}
+	}
+	if (atomic_read(&bp->_gen_cnt) == bp->_gen_seen)
+		return 0;
+	if (mode == JUST_TEST_LOGS)
+		return 1;
+	fetch_last_log(bp, data);
+	/*
+	 * Check to see if all the buffers have been consumed.
+	 */
+	for (i = 0; i < limit; i++)
+		if (MCA_INIT_LOG_VALID & MCA_BUFFER(bp, i)->_cpu)
+			return 1;
+	/*
+	 * Clear ->_b_cnt. It can fail. ... will be done next time...
+	 */
+	(void) cmpxchg(&bp->_b_cnt, b_cnt, 0);
+	return 1;
+}
+
 static ssize_t
 salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t *ppos)
 {
@@ -308,6 +553,8 @@
 	size_t size;
 	int i, n, cpu = -1;
 
+	D_printk("%s(): type: %d events: 0x%016lx\n", __FUNCTION__,
+					data->type, * (u64 *) & data->cpu_event);
 retry:
 	if (cpus_empty(data->cpu_event) && down_trylock(&data->mutex)) {
 		if (file->f_flags & O_NONBLOCK)
@@ -415,9 +662,13 @@
 {
 	struct salinfo_data *data = context;
 	sal_log_record_header_t *rh;
+
 	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
 	rh = (sal_log_record_header_t *)(data->log_buffer);
-	/* Clear corrected errors as they are read from SAL */
+	/*
+	 * Clear corrected errors as they are read from SAL.
+	 * The MCA handler has already cleared the recovered events.
+	 */
 	if (rh->severity == sal_log_severity_corrected)
 		ia64_sal_clear_state_info(data->type);
 }
@@ -425,15 +676,52 @@
 static void
 salinfo_log_new_read(int cpu, struct salinfo_data *data)
 {
-	struct salinfo_data_saved *data_saved;
+	struct salinfo_data_saved *data_saved = data->data_saved;
 	unsigned long flags;
 	int i;
 	int saved_size = ARRAY_SIZE(data->data_saved);
 
 	data->saved_num = 0;
+	switch (data->type){
+	case SAL_INFO_TYPE_MCA:
+		D_printk("%s(): data->state: %d cpu: %d\n", __FUNCTION__,
+							data->state, cpu);
+		if (is_log_available(&ia64_MCA_logs, cpu, data, JUST_TEST_LOGS)){
+			data->state = STATE_LOG_RECORD;
+			/* Have to save CPU somewhere... */
+			data_saved->cpu = cpu;
+			D_printk("data_saved->cpu: %d\n", data_saved->cpu);
+		} else if (!ia64_old_mca_log_checked){	/* Coming before the reboot */
+			if ((i /* cpu */ = check_old_mca(ia64_MCA_logs._b_size)) == -1)
+				ia64_old_mca_log_checked = 1;
+			else {
+			// Should check if the old MCA is for this CPU
+//			else if (i == cpu){
+				data->state = STATE_LOG_RECORD;
+				/* Have to save CPU somewhere... */
+				data_saved->cpu = cpu;
+				D_printk("data_saved->cpu: %d\n", data_saved->cpu);
+			}
+		}
+		return;
+	case SAL_INFO_TYPE_INIT:
+		D_printk("%s(): data->state: %d cpu: %d\n", __FUNCTION__,
+							data->state, cpu);
+		data_saved->cpu = cpu;
+		if (is_log_available(&ia64_INIT_logs, cpu, data, JUST_TEST_LOGS)){
+			data->state = STATE_LOG_RECORD;
+			/* Have to save CPU somewhere... */
+			data_saved->cpu = cpu;
+		}
+		return;
+	}
 	spin_lock_irqsave(&data_saved_lock, flags);
 retry:
-	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
+	for (i = 0; i < saved_size; ++i, ++data_saved) {
+		/*
+		 * "salinfo_log_wakeup()" never called for the new buffering
+		 * mechanism used for MCSa / INITs therefore "->buffer" remains NULL.
+		 */
 		if (data_saved->buffer && data_saved->cpu == cpu) {
 			sal_log_record_header_t *rh = (sal_log_record_header_t *)(data_saved->buffer);
 			data->log_size = data_saved->size;
@@ -469,7 +757,45 @@
 	u8 *buf;
 	u64 bufsize;
 
+	D_printk("%s(): data->state: %d\n", __FUNCTION__, data->state);
 	if (data->state == STATE_LOG_RECORD) {
+		switch (data->type){
+		case SAL_INFO_TYPE_MCA:
+			D_printk("data->data_saved->cpu: %d\n", data->data_saved->cpu);
+			/*
+			 * Should find the same log that has been found in
+			 * salinfo_log_new_read(), unless it is the "last log",
+			 * and it has been overwritten by another CPU in the
+			 * mean time. - Will be seen later.
+			 */
+			data->log_size = 0;
+			if (!is_log_available(&ia64_MCA_logs,
+					data->data_saved->cpu, data, DO_FETCH_LOG) &&
+							!ia64_old_mca_log_checked){
+				/* Coming before the reboot */
+				data->log_size = ia64_sal_get_state_info(
+							SAL_INFO_TYPE_MCA,
+							(u64 *) data->log_buffer);
+				if (data->log_size > 0){
+					/*
+					 * Well, the CPU number should be checked
+					 * against Processor Device Error Info.
+					 */
+//					if (data->data_saved->cpu ! = ...CPU...)
+//						data->log_size = 0;
+//					else
+						ia64_old_mca_log_checked = 1;
+				}
+			}
+			data->state = STATE_NO_DATA;
+			break;
+		case SAL_INFO_TYPE_INIT:
+			data->log_size = 0;
+			(void) is_log_available(&ia64_INIT_logs,
+					data->data_saved->cpu, data, DO_FETCH_LOG);
+			data->state = STATE_NO_DATA;
+			break;
+		}
 		buf = data->log_buffer;
 		bufsize = data->log_size;
 	} else if (data->state == STATE_OEMDATA) {
@@ -479,6 +805,8 @@
 		buf = NULL;
 		bufsize = 0;
 	}
+	D_printk("buf: %p, count: %ld, pos: %lld, bufsize: %ld\n",
+					buf, count, *ppos, bufsize);
 	return simple_read_from_buffer(buffer, count, ppos, buf, bufsize);
 }
 
@@ -486,6 +814,9 @@
 salinfo_log_clear_cpu(void *context)
 {
 	struct salinfo_data *data = context;
+	/*
+	 * The MCA handler has already cleared the recovered events.
+	 */
 	ia64_sal_clear_state_info(data->type);
 }
 
@@ -538,10 +869,16 @@
 	if (copy_from_user(cmd, buffer, size))
 		return -EFAULT;
 
+	D_printk("%s(): \"%s\" type: %d state: %d\n", __FUNCTION__, cmd,
+						data->type, data->state);
 	if (sscanf(cmd, "read %d", &cpu) == 1) {
 		salinfo_log_new_read(cpu, data);
 	} else if (sscanf(cmd, "clear %d", &cpu) == 1) {
 		int ret;
+
+		/*
+		 * The MCA handler has already cleared the recovered events.
+		 */
 		if ((ret = salinfo_log_clear(data, cpu)))
 			count = ret;
 	} else if (sscanf(cmd, "oemdata %d %d", &cpu, &offset) == 2) {
@@ -662,10 +999,20 @@
 		entry->proc_fops = &salinfo_data_fops;
 		*sdir++ = entry;
 
-		/* we missed any events before now */
-		for_each_online_cpu(j)
-			cpu_set(j, data->cpu_event);
-
+		switch (data->type){
+		case SAL_INFO_TYPE_MCA:
+//		case SAL_INFO_TYPE_INIT:	// ...coming soon...
+			/*
+			 * There is no way to miss en event if there is a log
+			 * buffer available. An MCA coming before reboot is
+			 * treated separately.
+			 */
+			break;
+		default:
+			/* we missed any events before now */
+			for_each_online_cpu(j)
+				cpu_set(j, data->cpu_event);
+		}
 		*sdir++ = dir;
 	}
 
diff -Nru linux-2.6.24-tmp/include/asm-ia64/bitops.h linux-2.6.24-new-tmp/include/asm-ia64/bitops.h
--- linux-2.6.24-tmp/include/asm-ia64/bitops.h	2008-04-01 13:07:46.000000000 +0200
+++ linux-2.6.24-new-tmp/include/asm-ia64/bitops.h	2008-03-31 09:33:07.000000000 +0200
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
diff -Nru linux-2.6.24-tmp/include/asm-ia64/mca.h linux-2.6.24-new-tmp/include/asm-ia64/mca.h
--- linux-2.6.24-tmp/include/asm-ia64/mca.h	2008-04-01 13:07:46.000000000 +0200
+++ linux-2.6.24-new-tmp/include/asm-ia64/mca.h	2008-03-31 09:33:07.000000000 +0200
@@ -161,6 +161,143 @@
 
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
+
+#define	IA64_MAX_MCA_BUFS	2	/* excl. the "last" buffer */
+#if	IA64_MAX_MCA_BUFS < 1
+#error	Min. 1 buffers required
+#endif
+
+#define	IA64_MAX_INIT_BUFS	2	/* excl. the "last" buffer */
+#if	IA64_MAX_INIT_BUFS < 1
+#error	Min. 1 buffers required
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
+ * - The first ->_n_bufs logs (called as conventional ones) and the very last
+ *   one are stored only.
+ * - The last log gets overwritten if there are too many logs there.
+ * - if (->_b_cnt <= ->_n_bufs + 1), then ->_b_cnt counts the in-use buffers,
+ *   incl. the last one. There is no lost log if (->_b_cnt <= ->_n_bufs + 1).
+ * - if (->_b_cnt >= ->_n_bufs), then ->_gen_cnt is incremented.
+ * - if (->_b_cnt > ->_n_bufs), then the last buffer gets over-written by the
+ *   additional logs.
+ *
+ * The MCA/INIT handler plays as follows:
+ * - It fetches and increments ->_b_cnt in an atomic way (acquisition semantics).
+ * - If (previous value < ->_n_bufs), then it can simply store its log into
+ *   ->_buf[ previous value ]. Having done that, it sets the MCA_INIT_LOG_VALID
+ *   bit in ->_buf[ previous value ]._cpu (release semantics).
+ * - Otherwise it races (incl. with the nesting handlers) for the last buffer:
+ *   + It increments ->_gen_cnt in an atomic way to obtain its generation count
+ *     (acquisition semantics).
+ *   + It owns the last log buffer while no one else has got a higher generation
+ *     count.
+ *   + The log data is broken up into 4-byte chunks and they are stamped with
+ *     the generation count. They are written together as an atomic64_t into
+ *     (*->_last_buf)[] by use of a compare-and-swap primitive to make sure
+ *     that no one with higher generation count has passed by in the mean time.
+ *   + Similarly to the conventional buffers, (*->_last_buf)[0] is a marker:
+ *     it includes the CPU number and the MCA_INIT_LOG_VALID bit:
+ *     * Before writing the log data into the rest of (*->_last_buf)[], the
+ *       MCA/INIT handler sets the marker to say "not done"
+ *       (MCA_INIT_LOG_VALID bit off) + write-memory-barrier.
+ *     * Having finished, it sets the MCA_INIT_LOG_VALID bit.
+ *       (MCA_INIT_LOG_VALID bit on) using release semantics.
+ *
+ * The salinfo side polls ->_b_cnt:
+ * - Once a MCA_INIT_LOG_VALID bit is set in ->_buf[]._cpu, it is safe to read,
+ *   at any time, without any further precaution, the first
+ *   MIN(->_n_bufs, ->_b_cnt) buffer entries.
+ *   While ->_b_cnt is not reset to 0, the log buffers are not reused.
+ * - The salinfo side can clear the MCA_INIT_LOG_VALID bit in ->_buf[]._cpu at
+ *   any time (no need for an atomic operation because the MCA/INIT handler does
+ *   not even consider re-using this item before ->_b_cnt drops back to 0).
+ * - If (->_b_cnt > ->_n_buf), then the last buffer is read as follows:
+ *   + Pick up ->_gen_cnt.
+ *   + Verify the marker (*->_last_buf)[0], it should have the bit
+ *     MCA_INIT_LOG_VALID on. (Otherwise come back later...)
+ *   + While reading (*->_last_buf)[], verify if the generation count in each
+ *     item is the same. (Otherwise restart...)
+ * - The salinfo side can reset ->_b_cnt to 0 with an atomic operation, provided
+ *   it has not changed. (Otherwise restart...)
+ */
+
+#define	MCA_INIT_LOG_VALID_N	31
+#define	MCA_INIT_LOG_VALID	(1U << MCA_INIT_LOG_VALID_N)
+#define	MCA_INIT_CPU_MASK	(MCA_INIT_LOG_VALID - 1)
+
+typedef struct log_buf_s {		/* Conventional log buffer */
+	u32		_cpu;		/* Incl. MCA_INIT_LOG_VALID bit */
+	u32		_log_size;
+	u8		_data[];
+} log_buf_t;
+
+typedef struct ia64_mca_init_buf_s {
+	log_buf_t	(*_buf)[0];	/* Conventional buffers */
+	u32		_b_size;	/* Actual sizeof(log_buf_t) */
+	atomic_t	_b_cnt;		/* Counts the in-use _buf[]'s */
+	u32		_n_bufs;	/* Excl. the "last log" */
+	atomic64_t	(*_last_buf)[0];
+	atomic_t	_gen_cnt;	/* Generation counter for _last_buf[] */
+	u32		_gen_seen;	/* Generation seen by salinfo */
+} ia64_mca_init_buf_t;
+
+/* i-th conventional buffer: */
+#define	MCA_BUFFER(bp, i)		((log_buf_t *) ((u8 *) (bp)->_buf + (bp)->_b_size * (i)))
+
+/* Macros for (*->_last_buf)[]: */
+#define	GET_GEN_CNT(x)		((u32) x)		/* Generation counter */
+#define	GET_LOG_DATA(x)		((u32) (x >> 32))	/* Log data */
+#define	COMPOSE_AT_VAL(gc, dt)	((u32) (gc) | ((u64) (dt) << 32))
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

--------------090309010608030100070903--
