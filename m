From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 20 Dec 2003 00:03:11 +0000
Subject: RE: [patch] 2.6.0 MCA TLB error recovery
Message-Id: <marc-linux-ia64-107187879424992@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107181047921141@msgid-missing>
In-Reply-To: <marc-linux-ia64-107181047921141@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


> I didn't keep the old patches around.  Could you and Keith send me a
> consistent set of patches?  That would help me.

Here's Keith's first patch, 2nd (much smaller) is in the next e-mail:

From: linux-ia64-owner@vger.kernel.org on behalf of Keith Owens
[kaos@sgi.com]
Sent: Tuesday, November 25, 2003 12:37 AM
To: linux-ia64@vger.kernel.org
Subject: [patch] 2.6.0-test9 pal/sal/salinfo/mca

Forward port the recent changes to pal.h, sal.h, mca.h, salinfo.c and
mca.c from 2.4.23-rc2 to 2.6.0-test9.

This converts 2.6 to use salinfo instead of printing CMC/CPE/MCA/INIT
records in the kernel.  It makes the two kernel versions as close
together as possible.


Index: 9.2/include/asm-ia64/sal.h
--- 9.2/include/asm-ia64/sal.h Sun, 24 Aug 2003 10:59:40 +1000 kaos (linux-2.6-test/u/c/36_sal.h 1.3 644)
+++ 9.4/include/asm-ia64/sal.h Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/u/c/36_sal.h 1.4 644)
@@ -725,14 +725,16 @@ ia64_sal_mc_rendez (void)
  * Allow the OS to specify the interrupt number to be used by SAL to interrupt OS during
  * the machine check rendezvous sequence as well as the mechanism to wake up the
  * non-monarch processor at the end of machine check processing.
+ * Returns the complete ia64_sal_retval because some calls return more than just a status
+ * value.
  */
-static inline s64
+static inline struct ia64_sal_retval
 ia64_sal_mc_set_params (u64 param_type, u64 i_or_m, u64 i_or_m_val, u64 timeout, u64 rz_always)
 {
 	struct ia64_sal_retval isrv;
 	SAL_CALL(isrv, SAL_MC_SET_PARAMS, param_type, i_or_m, i_or_m_val,
 		 timeout, rz_always, 0, 0);
-	return isrv.status;
+	return isrv;
 }
 
 /* Read from PCI configuration space */
@@ -804,10 +806,12 @@ ia64_sal_update_pal (u64 param_buf, u64 
 
 extern unsigned long sal_platform_features;
 
+extern int (*salinfo_platform_oemdata)(const u8 *, u8 **, u64 *);
+
 struct sal_ret_values {
 	long r8; long r9; long r10; long r11;
 };
 
 #endif /* __ASSEMBLY__ */
 
-#endif /* _ASM_IA64_PAL_H */
+#endif /* _ASM_IA64_SAL_H */
Index: 9.2/include/asm-ia64/pal.h
--- 9.2/include/asm-ia64/pal.h Mon, 20 Oct 2003 11:16:44 +1000 kaos (linux-2.6-test/v/c/12_pal.h 1.3 644)
+++ 9.4/include/asm-ia64/pal.h Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/v/c/12_pal.h 1.4 644)
@@ -461,23 +461,13 @@ typedef struct pal_process_state_info_s 
 } pal_processor_state_info_t;
 
 typedef struct pal_cache_check_info_s {
-	u64		reserved1	: 16,
-			way		: 5,	/* Way in which the
-						 * error occurred
-						 */
-			reserved2	: 1,
-			mc		: 1,	/* Machine check corrected */
-			tv		: 1,	/* Target address
-						 * structure is valid
-						 */
-
-			wv		: 1,	/* Way field valid */
-			op		: 3,	/* Type of cache
+	u64		op		: 4,	/* Type of cache
 						 * operation that
 						 * caused the machine
 						 * check.
 						 */
-
+			level		: 2,	/* Cache level */
+			reserved1	: 2,
 			dl		: 1,	/* Failure in data part
 						 * of cache line
 						 */
@@ -486,11 +476,34 @@ typedef struct pal_cache_check_info_s {
 						 */
 			dc		: 1,	/* Failure in dcache */
 			ic		: 1,	/* Failure in icache */
-			index		: 24,	/* Cache line index */
-			mv		: 1,	/* mesi valid */
 			mesi		: 3,	/* Cache line state */
-			level		: 4;	/* Cache level */
+			mv		: 1,	/* mesi valid */
+			way		: 5,	/* Way in which the
+						 * error occurred
+						 */
+			wiv		: 1,	/* Way field valid */
+			reserved2	: 10,
+
+			index		: 20,	/* Cache line index */
+			reserved3	: 2,
 
+			is		: 1,	/* instruction set (1 = ia32) */
+			iv		: 1,	/* instruction set field valid */
+			pl		: 2,	/* privilege level */
+			pv		: 1,	/* privilege level field valid */
+			mcc		: 1,	/* Machine check corrected */
+			tv		: 1,	/* Target address
+						 * structure is valid
+						 */
+			rq		: 1,	/* Requester identifier
+						 * structure is valid
+						 */
+			rp		: 1,	/* Responder identifier
+						 * structure is valid
+						 */
+			pi		: 1;	/* Precise instruction pointer
+						 * structure is valid
+						 */
 } pal_cache_check_info_t;
 
 typedef struct pal_tlb_check_info_s {
@@ -498,18 +511,38 @@ typedef struct pal_tlb_check_info_s {
 	u64		tr_slot		: 8,	/* Slot# of TR where
 						 * error occurred
 						 */
-			reserved2	: 8,
+			trv		: 1,	/* tr_slot field is valid */
+			reserved1	: 1,
+			level		: 2,	/* TLB level where failure occurred */
+			reserved2	: 4,
 			dtr		: 1,	/* Fail in data TR */
 			itr		: 1,	/* Fail in inst TR */
 			dtc		: 1,	/* Fail in data TC */
 			itc		: 1,	/* Fail in inst. TC */
-			mc		: 1,	/* Machine check corrected */
-			reserved1	: 43;
+			op		: 4,	/* Cache operation */
+			reserved3	: 30,
 
+			is		: 1,	/* instruction set (1 = ia32) */
+			iv		: 1,	/* instruction set field valid */
+			pl		: 2,	/* privilege level */
+			pv		: 1,	/* privilege level field valid */
+			mcc		: 1,	/* Machine check corrected */
+			tv		: 1,	/* Target address
+						 * structure is valid
+						 */
+			rq		: 1,	/* Requester identifier
+						 * structure is valid
+						 */
+			rp		: 1,	/* Responder identifier
+						 * structure is valid
+						 */
+			pi		: 1;	/* Precise instruction pointer
+						 * structure is valid
+						 */
 } pal_tlb_check_info_t;
 
 typedef struct pal_bus_check_info_s {
-	u64		size		: 5,	/* Xaction size*/
+	u64		size		: 5,	/* Xaction size */
 			ib		: 1,	/* Internal bus error */
 			eb		: 1,	/* External bus error */
 			cc		: 1,	/* Error occurred
@@ -518,22 +551,99 @@ typedef struct pal_bus_check_info_s {
 						 */
 			type		: 8,	/* Bus xaction type*/
 			sev		: 5,	/* Bus error severity*/
-			tv		: 1,	/* Targ addr valid */
-			rp		: 1,	/* Resp addr valid */
-			rq		: 1,	/* Req addr valid */
+			hier		: 2,	/* Bus hierarchy level */
+			reserved1	: 1,
 			bsi		: 8,	/* Bus error status
 						 * info
 						 */
-			mc		: 1,	/* Machine check corrected */
-			reserved1	: 31;
+			reserved2	: 22,
+
+			is		: 1,	/* instruction set (1 = ia32) */
+			iv		: 1,	/* instruction set field valid */
+			pl		: 2,	/* privilege level */
+			pv		: 1,	/* privilege level field valid */
+			mcc		: 1,	/* Machine check corrected */
+			tv		: 1,	/* Target address
+						 * structure is valid
+						 */
+			rq		: 1,	/* Requester identifier
+						 * structure is valid
+						 */
+			rp		: 1,	/* Responder identifier
+						 * structure is valid
+						 */
+			pi		: 1;	/* Precise instruction pointer
+						 * structure is valid
+						 */
 } pal_bus_check_info_t;
 
+typedef struct pal_reg_file_check_info_s {
+	u64		id		: 4,	/* Register file identifier */
+			op		: 4,	/* Type of register
+						 * operation that
+						 * caused the machine
+						 * check.
+						 */
+			reg_num		: 7,	/* Register number */
+			rnv		: 1,	/* reg_num valid */
+			reserved2	: 38,
+
+			is		: 1,	/* instruction set (1 = ia32) */
+			iv		: 1,	/* instruction set field valid */
+			pl		: 2,	/* privilege level */
+			pv		: 1,	/* privilege level field valid */
+			mcc		: 1,	/* Machine check corrected */
+			reserved3	: 3,
+			pi		: 1;	/* Precise instruction pointer
+						 * structure is valid
+						 */
+} pal_reg_file_check_info_t;
+
+typedef struct pal_uarch_check_info_s {
+	u64		sid		: 5,	/* Structure identification */
+			level		: 3,	/* Level of failure */
+			array_id	: 4,	/* Array identification */
+			op		: 4,	/* Type of
+						 * operation that
+						 * caused the machine
+						 * check.
+						 */
+			way		: 6,	/* Way of structure */
+			wv		: 1,	/* way valid */
+			xv		: 1,	/* index valid */
+			reserved1	: 8,
+			index		: 8,	/* Index or set of the uarch
+						 * structure that failed.
+						 */
+			reserved2	: 24,
+
+			is		: 1,	/* instruction set (1 = ia32) */
+			iv		: 1,	/* instruction set field valid */
+			pl		: 2,	/* privilege level */
+			pv		: 1,	/* privilege level field valid */
+			mcc		: 1,	/* Machine check corrected */
+			tv		: 1,	/* Target address
+						 * structure is valid
+						 */
+			rq		: 1,	/* Requester identifier
+						 * structure is valid
+						 */
+			rp		: 1,	/* Responder identifier
+						 * structure is valid
+						 */
+			pi		: 1;	/* Precise instruction pointer
+						 * structure is valid
+						 */
+} pal_uarch_check_info_t;
+
 typedef union pal_mc_error_info_u {
 	u64				pmei_data;
 	pal_processor_state_info_t	pme_processor;
 	pal_cache_check_info_t		pme_cache;
 	pal_tlb_check_info_t		pme_tlb;
 	pal_bus_check_info_t		pme_bus;
+	pal_reg_file_check_info_t	pme_reg_file;
+	pal_uarch_check_info_t		pme_uarch;
 } pal_mc_error_info_t;
 
 #define pmci_proc_unknown_check			pme_processor.uc
Index: 9.2/include/asm-ia64/mca.h
--- 9.2/include/asm-ia64/mca.h Mon, 20 Oct 2003 11:16:44 +1000 kaos (linux-2.6-test/w/c/12_mca.h 1.3 644)
+++ 9.4/include/asm-ia64/mca.h Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/w/c/12_mca.h 1.4 644)
@@ -141,7 +141,6 @@ extern irqreturn_t ia64_mca_cpe_int_call
 extern int  ia64_log_print(int,prfunc_t);
 extern void ia64_mca_cmc_vector_setup(void);
 extern int  ia64_mca_check_errors(void);
-extern u64  ia64_log_get(int, prfunc_t);
 
 #define PLATFORM_CALL(fn, args)	printk("Platform call TBD\n")
 
Index: 9.2/arch/ia64/Kconfig
--- 9.2/arch/ia64/Kconfig Tue, 21 Oct 2003 18:45:55 +1000 kaos (linux-2.6-test/F/e/0_Kconfig 1.6 644)
+++ 9.4/arch/ia64/Kconfig Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/F/e/0_Kconfig 1.7 644)
@@ -394,16 +394,6 @@ config IA64_PALINFO
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
-config IA64_SALINFO
-	tristate "/proc/sal support"
-	help
-	  The /proc/sal directory exports the SAL (system abstraction layer)
-	  feature bits, like whether the platform is subject to ITC drift.  It
-	  is intended to be used by user programs that care about such things.
-
-	  To use this option, you have to ensure that the "/proc file system
-	  support" (CONFIG_PROC_FS) is enabled, too.
-
 config EFI_VARS
 	tristate "/proc/efi/vars support"
 	help
Index: 9.2/arch/ia64/kernel/Makefile
--- 9.2/arch/ia64/kernel/Makefile Mon, 29 Sep 2003 13:13:55 +1000 kaos (linux-2.6-test/I/e/3_Makefile 1.3 644)
+++ 9.4/arch/ia64/kernel/Makefile Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/I/e/3_Makefile 1.4 644)
@@ -6,7 +6,7 @@ extra-y	:= head.o init_task.o vmlinux.ld
 
 obj-y := acpi.o entry.o efi.o efi_stub.o gate-data.o fsys.o ia64_ksyms.o irq.o irq_ia64.o	\
 	 irq_lsapic.o ivt.o machvec.o pal.o patch.o process.o perfmon.o ptrace.o sal.o		\
-	 semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o
+	 salinfo.o semaphore.o setup.o signal.o sys_ia64.o time.o traps.o unaligned.o unwind.o
 
 obj-$(CONFIG_EFI_VARS)		+= efivars.o
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
@@ -14,7 +14,6 @@ obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
 obj-$(CONFIG_IA64_MCA)		+= mca.o mca_asm.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
-obj-$(CONFIG_IA64_SALINFO)	+= salinfo.o
 obj-$(CONFIG_IOSAPIC)		+= iosapic.o
 obj-$(CONFIG_MODULES)		+= module.o
 obj-$(CONFIG_SMP)		+= smp.o smpboot.o
Index: 9.2/arch/ia64/kernel/salinfo.c
--- 9.2/arch/ia64/kernel/salinfo.c Mon, 29 Sep 2003 13:13:55 +1000 kaos (linux-2.6-test/I/e/22_salinfo.c 1.2 644)
+++ 9.4/arch/ia64/kernel/salinfo.c Tue, 25 Nov 2003 19:23:21 +1100 kaos (linux-2.6-test/I/e/22_salinfo.c 1.3 644)
@@ -3,18 +3,31 @@
  *
  * Creates entries in /proc/sal for various system features.
  *
- * Copyright (c) 2001 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2003 Hewlett-Packard Co
+ *	Bjorn Helgaas <bjorn.helgaas@hp.com>
  *
- * 09/11/2003	jbarnes@sgi.com		updated for 2.6
  * 10/30/2001	jbarnes@sgi.com		copied much of Stephane's palinfo
  *					code to create this file
+ * Oct 23 2003	kaos@sgi.com
+ *   Replace IPI with set_cpus_allowed() to read a record from the required cpu.
+ *   Redesign salinfo log processing to separate interrupt and user space
+ *   contexts.
+ *   Cache the record across multi-block reads from user space.
+ *   Support > 64 cpus.
+ *   Delete module_exit and MOD_INC/DEC_COUNT, salinfo cannot be a module.
  */
 
 #include <linux/types.h>
 #include <linux/proc_fs.h>
 #include <linux/module.h>
+#include <linux/smp.h>
+#include <linux/smp_lock.h>
+#include <linux/vmalloc.h>
 
+#include <asm/semaphore.h>
 #include <asm/sal.h>
+#include <asm/uaccess.h>
 
 MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
 MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");
@@ -41,42 +54,511 @@ static salinfo_entry_t salinfo_entries[]
 
 #define NR_SALINFO_ENTRIES ARRAY_SIZE(salinfo_entries)
 
-/*
- * One for each feature and one more for the directory entry...
+static char *salinfo_log_name[] = {
+	"mca",
+	"init",
+	"cmc",
+	"cpe",
+};
+
+static struct proc_dir_entry *salinfo_proc_entries[
+	ARRAY_SIZE(salinfo_entries) +			/* /proc/sal/bus_lock */
+	ARRAY_SIZE(salinfo_log_name) +			/* /proc/sal/{mca,...} */
+	(2 * ARRAY_SIZE(salinfo_log_name)) +		/* /proc/sal/mca/{event,data} */
+	1];						/* /proc/sal */
+
+/* Some records we get ourselves, some are accessed as saved data in buffers
+ * that are owned by mca.c.
+ */
+struct salinfo_data_saved {
+	u8*			buffer;
+	u64			size;
+	u64			id;
+	int			cpu;
+};
+
+/* State transitions.  Actions are :-
+ *   Write "read <cpunum>" to the data file.
+ *   Write "clear <cpunum>" to the data file.
+ *   Write "oemdata <cpunum> <offset> to the data file.
+ *   Read from the data file.
+ *   Close the data file.
+ *
+ * Start state is NO_DATA.
+ *
+ * NO_DATA
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> return -EINVAL.
+ *    read data -> return EOF.
+ *    close -> unchanged.  Free record areas.
+ *
+ * LOG_RECORD
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> format the oem data, goto OEMDATA.
+ *    read data -> return the INIT/MCA/CMC/CPE record.
+ *    close -> unchanged.  Keep record areas.
+ *
+ * OEMDATA
+ *    write "read <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "clear <cpunum>" -> NO_DATA or LOG_RECORD.
+ *    write "oemdata <cpunum> <offset> -> format the oem data, goto OEMDATA.
+ *    read data -> return the formatted oemdata.
+ *    close -> unchanged.  Keep record areas.
+ *
+ * Closing the data file does not change the state.  This allows shell scripts
+ * to manipulate salinfo data, each shell redirection opens the file, does one
+ * action then closes it again.  The record areas are only freed at close when
+ * the state is NO_DATA.
+ */
+enum salinfo_state {
+	STATE_NO_DATA,
+	STATE_LOG_RECORD,
+	STATE_OEMDATA,
+};
+
+struct salinfo_data {
+	volatile cpumask_t	cpu_event;	/* which cpus have outstanding events */
+	struct semaphore	sem;		/* count of cpus with outstanding events (bits set in cpu_event) */
+	u8			*log_buffer;
+	u64			log_size;
+	u8			*oemdata;	/* decoded oem data */
+	u64			oemdata_size;
+	int			open;		/* single-open to prevent races */
+	u8			type;
+	u8			saved_num;	/* using a saved record? */
+	enum salinfo_state	state :8;	/* processing state */
+	u8			padding;
+	int			cpu_check;	/* next CPU to check */
+	struct salinfo_data_saved data_saved[5];/* save last 5 records from mca.c, must be < 255 */
+};
+
+static struct salinfo_data salinfo_data[ARRAY_SIZE(salinfo_log_name)];
+
+static spinlock_t data_lock, data_saved_lock;
+
+/** salinfo_platform_oemdata - optional callback to decode oemdata from an error
+ * record.
+ * @sect_header: pointer to the start of the section to decode.
+ * @oemdata: returns vmalloc area containing the decded output.
+ * @oemdata_size: returns length of decoded output (strlen).
+ *
+ * Description: If user space asks for oem data to be decoded by the kernel
+ * and/or prom and the platform has set salinfo_platform_oemdata to the address
+ * of a platform specific routine then call that routine.  salinfo_platform_oemdata
+ * vmalloc's and formats its output area, returning the address of the text
+ * and its strlen.  Returns 0 for success, -ve for error.  The callback is
+ * invoked on the cpu that generated the error record.
  */
-static struct proc_dir_entry *salinfo_proc_entries[NR_SALINFO_ENTRIES + 1];
+int (*salinfo_platform_oemdata)(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size);
+
+struct salinfo_platform_oemdata_parms {
+	const u8 *efi_guid;
+	u8 **oemdata;
+	u64 *oemdata_size;
+	int ret;
+};
+
+static void
+salinfo_platform_oemdata_cpu(void *context)
+{
+	struct salinfo_platform_oemdata_parms *parms = context;
+	parms->ret = salinfo_platform_oemdata(parms->efi_guid, parms->oemdata, parms->oemdata_size);
+}
+
+static void
+shift1_data_saved (struct salinfo_data *data, int shift)
+{
+	memcpy(data->data_saved+shift, data->data_saved+shift+1,
+	       (ARRAY_SIZE(data->data_saved) - (shift+1)) * sizeof(data->data_saved[0]));
+	memset(data->data_saved + ARRAY_SIZE(data->data_saved) - 1, 0,
+	       sizeof(data->data_saved[0]));
+}
+
+/* This routine is invoked in interrupt context.  Note: mca.c enables
+ * interrupts before calling this code for CMC/CPE.  MCA and INIT events are
+ * not irq safe, do not call any routines that use spinlocks, they may deadlock.
+ *
+ * The buffer passed from mca.c points to the output from ia64_log_get. This is
+ * a persistent buffer but its contents can change between the interrupt and
+ * when user space processes the record.  Save the record id to identify
+ * changes.
+ */
+void
+salinfo_log_wakeup(int type, u8 *buffer, u64 size)
+{
+	struct salinfo_data *data = salinfo_data + type;
+	struct salinfo_data_saved *data_saved;
+	unsigned long flags = 0;
+	int i, irqsafe = type != SAL_INFO_TYPE_MCA && type != SAL_INFO_TYPE_INIT;
+	int saved_size = ARRAY_SIZE(data->data_saved);
+
+	BUG_ON(type >= ARRAY_SIZE(salinfo_log_name));
+
+	if (irqsafe)
+		spin_lock_irqsave(&data_saved_lock, flags);
+	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
+		if (!data_saved->buffer)
+			break;
+	}
+	if (i = saved_size) {
+		if (!data->saved_num) {
+			shift1_data_saved(data, 0);
+			data_saved = data->data_saved + saved_size - 1;
+		} else
+			data_saved = NULL;
+	}
+	if (data_saved) {
+		data_saved->cpu = smp_processor_id();
+		data_saved->id = ((sal_log_record_header_t *)buffer)->id;
+		data_saved->size = size;
+		data_saved->buffer = buffer;
+	}
+	if (irqsafe)
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+
+	if (!test_and_set_bit(smp_processor_id(), &data->cpu_event)) {
+		if (irqsafe)
+			up(&data->sem);
+	}
+}
+
+static int
+salinfo_event_open(struct inode *inode, struct file *file)
+{
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+	return 0;
+}
+
+static ssize_t
+salinfo_event_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = PDE(inode);
+	struct salinfo_data *data = entry->data;
+	char cmd[32];
+	size_t size;
+	int i, n, cpu = -1;
+
+retry:
+	if (down_trylock(&data->sem)) {
+		if (file->f_flags & O_NONBLOCK)
+			return -EAGAIN;
+		if (down_interruptible(&data->sem))
+			return -ERESTARTSYS;
+	}
+
+	n = data->cpu_check;
+	for (i = 0; i < NR_CPUS; i++) {
+		if (test_bit(n, &data->cpu_event)) {
+			cpu = n;
+			break;
+		}
+		if (++n = NR_CPUS)
+			n = 0;
+	}
+
+	if (cpu = -1)
+		goto retry;
+
+	/* events are sticky until the user says "clear" */
+	up(&data->sem);
+
+	/* for next read, start checking at next CPU */
+	data->cpu_check = cpu;
+	if (++data->cpu_check = NR_CPUS)
+		data->cpu_check = 0;
+
+	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);
+
+	size = strlen(cmd);
+	if (size > count)
+		size = count;
+	if (copy_to_user(buffer, cmd, size))
+		return -EFAULT;
+
+	return size;
+}
+
+static struct file_operations salinfo_event_fops = {
+	.open  = salinfo_event_open,
+	.read  = salinfo_event_read,
+};
+
+static int
+salinfo_log_open(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *entry = PDE(inode);
+	struct salinfo_data *data = entry->data;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	spin_lock(&data_lock);
+	if (data->open) {
+		spin_unlock(&data_lock);
+		return -EBUSY;
+	}
+	data->open = 1;
+	spin_unlock(&data_lock);
+
+	if (data->state = STATE_NO_DATA &&
+	    !(data->log_buffer = vmalloc(ia64_sal_get_state_info_size(data->type)))) {
+		data->open = 0;
+		return -ENOMEM;
+	}
+
+	return 0;
+}
+
+static int
+salinfo_log_release(struct inode *inode, struct file *file)
+{
+	struct proc_dir_entry *entry = PDE(inode);
+	struct salinfo_data *data = entry->data;
+
+	if (data->state = STATE_NO_DATA) {
+		vfree(data->log_buffer);
+		vfree(data->oemdata);
+		data->log_buffer = NULL;
+		data->oemdata = NULL;
+	}
+	spin_lock(&data_lock);
+	data->open = 0;
+	spin_unlock(&data_lock);
+	return 0;
+}
+
+static void
+call_on_cpu(int cpu, void (*fn)(void *), void *arg)
+{
+	cpumask_t save_cpus_allowed, new_cpus_allowed;
+	memcpy(&save_cpus_allowed, &current->cpus_allowed, sizeof(save_cpus_allowed));
+	memset(&new_cpus_allowed, 0, sizeof(new_cpus_allowed));
+	set_bit(cpu, &new_cpus_allowed);
+	set_cpus_allowed(current, new_cpus_allowed);
+	(*fn)(arg);
+	set_cpus_allowed(current, save_cpus_allowed);
+}
+
+static void
+salinfo_log_read_cpu(void *context)
+{
+	struct salinfo_data *data = context;
+	data->log_size = ia64_sal_get_state_info(data->type, (u64 *) data->log_buffer);
+}
+
+static void
+salinfo_log_new_read(int cpu, struct salinfo_data *data)
+{
+	struct salinfo_data_saved *data_saved;
+	unsigned long flags;
+	int i;
+	int saved_size = ARRAY_SIZE(data->data_saved);
+
+	data->saved_num = 0;
+	spin_lock_irqsave(&data_saved_lock, flags);
+retry:
+	for (i = 0, data_saved = data->data_saved; i < saved_size; ++i, ++data_saved) {
+		if (data_saved->buffer && data_saved->cpu = cpu) {
+			sal_log_record_header_t *rh = (sal_log_record_header_t *)(data_saved->buffer);
+			data->log_size = data_saved->size;
+			memcpy(data->log_buffer, rh, data->log_size);
+			barrier();	/* id check must not be moved */
+			if (rh->id = data_saved->id) {
+				data->saved_num = i+1;
+				break;
+			}
+			/* saved record changed by mca.c since interrupt, discard it */
+			shift1_data_saved(data, i);
+			goto retry;
+		}
+	}
+	spin_unlock_irqrestore(&data_saved_lock, flags);
+
+	if (!data->saved_num)
+		call_on_cpu(cpu, salinfo_log_read_cpu, data);
+	data->state = data->log_size ? STATE_LOG_RECORD : STATE_NO_DATA;
+}
+
+static ssize_t
+salinfo_log_read(struct file *file, char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = PDE(inode);
+	struct salinfo_data *data = entry->data;
+	void *saldata;
+	size_t size;
+	u8 *buf;
+	u64 bufsize;
+
+	if (data->state = STATE_LOG_RECORD) {
+		buf = data->log_buffer;
+		bufsize = data->log_size;
+	} else if (data->state = STATE_OEMDATA) {
+		buf = data->oemdata;
+		bufsize = data->oemdata_size;
+	} else {
+		buf = NULL;
+		bufsize = 0;
+	}
+	if (*ppos >= bufsize)
+		return 0;
+
+	saldata = buf + file->f_pos;
+	size = bufsize - file->f_pos;
+	if (size > count)
+		size = count;
+	if (copy_to_user(buffer, saldata, size))
+		return -EFAULT;
+
+	*ppos += size;
+	return size;
+}
+
+static void
+salinfo_log_clear_cpu(void *context)
+{
+	struct salinfo_data *data = context;
+	ia64_sal_clear_state_info(data->type);
+}
+
+static int
+salinfo_log_clear(struct salinfo_data *data, int cpu)
+{
+	data->state = STATE_NO_DATA;
+	if (!test_bit(cpu, &data->cpu_event))
+		return 0;
+	down(&data->sem);
+	clear_bit(cpu, &data->cpu_event);
+	if (data->saved_num) {
+		unsigned long flags;
+		spin_lock_irqsave(&data_saved_lock, flags);
+		shift1_data_saved(data, data->saved_num - 1 );
+		data->saved_num = 0;
+		spin_unlock_irqrestore(&data_saved_lock, flags);
+	}
+	call_on_cpu(cpu, salinfo_log_clear_cpu, data);
+
+	/* clearing a record may make a new record visible */
+	salinfo_log_new_read(cpu, data);
+	if (data->state = STATE_LOG_RECORD &&
+	    !test_and_set_bit(cpu,  &data->cpu_event))
+		up(&data->sem);
+	return 0;
+}
+
+static ssize_t
+salinfo_log_write(struct file *file, const char *buffer, size_t count, loff_t *ppos)
+{
+	struct inode *inode = file->f_dentry->d_inode;
+	struct proc_dir_entry *entry = PDE(inode);
+	struct salinfo_data *data = entry->data;
+	char cmd[32];
+	size_t size;
+	u32 offset;
+	int cpu;
+
+	size = sizeof(cmd);
+	if (count < size)
+		size = count;
+	if (copy_from_user(cmd, buffer, size))
+		return -EFAULT;
+
+	if (sscanf(cmd, "read %d", &cpu) = 1) {
+		salinfo_log_new_read(cpu, data);
+	} else if (sscanf(cmd, "clear %d", &cpu) = 1) {
+		int ret;
+		if ((ret = salinfo_log_clear(data, cpu)))
+			count = ret;
+	} else if (sscanf(cmd, "oemdata %d %d", &cpu, &offset) = 2) {
+		if (data->state != STATE_LOG_RECORD && data->state != STATE_OEMDATA)
+			return -EINVAL;
+		if (offset > data->log_size - sizeof(efi_guid_t))
+			return -EINVAL;
+		data->state = STATE_OEMDATA;
+		if (salinfo_platform_oemdata) {
+			struct salinfo_platform_oemdata_parms parms = {
+				.efi_guid = data->log_buffer + offset,
+				.oemdata = &data->oemdata,
+				.oemdata_size = &data->oemdata_size
+			};
+			call_on_cpu(cpu, salinfo_platform_oemdata_cpu, &parms);
+			if (parms.ret)
+				count = parms.ret;
+		} else
+			data->oemdata_size = 0;
+	} else
+		return -EINVAL;
+
+	return count;
+}
+
+static struct file_operations salinfo_data_fops = {
+	.open    = salinfo_log_open,
+	.release = salinfo_log_release,
+	.read    = salinfo_log_read,
+	.write   = salinfo_log_write,
+};
 
 static int __init
 salinfo_init(void)
 {
 	struct proc_dir_entry *salinfo_dir; /* /proc/sal dir entry */
 	struct proc_dir_entry **sdir = salinfo_proc_entries; /* keeps track of every entry */
-	int i;
+	struct proc_dir_entry *dir, *entry;
+	struct salinfo_data *data;
+	int i, j, online;
 
 	salinfo_dir = proc_mkdir("sal", NULL);
+	if (!salinfo_dir)
+		return 0;
 
 	for (i=0; i < NR_SALINFO_ENTRIES; i++) {
 		/* pass the feature bit in question as misc data */
-		*sdir = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
+		*sdir++ = create_proc_read_entry (salinfo_entries[i].name, 0, salinfo_dir,
 						  salinfo_read, (void *)salinfo_entries[i].feature);
-		if (*sdir)
-			(*sdir)->owner = THIS_MODULE;
-		sdir++;
 	}
-	*sdir++ = salinfo_dir;
-
-	return 0;
-}
 
-static void __exit
-salinfo_exit(void)
-{
-	int i = 0;
+	for (i = 0; i < ARRAY_SIZE(salinfo_log_name); i++) {
+		data = salinfo_data + i;
+		data->type = i;
+		sema_init(&data->sem, 0);
+		dir = proc_mkdir(salinfo_log_name[i], salinfo_dir);
+		if (!dir)
+			continue;
+
+		entry = create_proc_entry("event", S_IRUSR, dir);
+		if (!entry)
+			continue;
+		entry->data = data;
+		entry->proc_fops = &salinfo_event_fops;
+		*sdir++ = entry;
+
+		entry = create_proc_entry("data", S_IRUSR | S_IWUSR, dir);
+		if (!entry)
+			continue;
+		entry->data = data;
+		entry->proc_fops = &salinfo_data_fops;
+		*sdir++ = entry;
+
+		/* we missed any events before now */
+		online = 0;
+		for (j = 0; j < NR_CPUS; j++)
+			if (cpu_online(j)) {
+				set_bit(j, &data->cpu_event);
+				++online;
+			}
+		sema_init(&data->sem, online);
 
-	for (i = 0; i < NR_SALINFO_ENTRIES ; i++) {
-		if (salinfo_proc_entries[i])
-			remove_proc_entry (salinfo_proc_entries[i]->name, NULL);
+		*sdir++ = dir;
 	}
+
+	*sdir++ = salinfo_dir;
+
+	return 0;
 }
 
 /*
@@ -102,4 +584,3 @@ salinfo_read(char *page, char **start, o
 }
 
 module_init(salinfo_init);
-module_exit(salinfo_exit);
Index: 9.2/arch/ia64/kernel/mca.c
--- 9.2/arch/ia64/kernel/mca.c Mon, 20 Oct 2003 11:16:44 +1000 kaos (linux-2.6-test/I/e/30_mca.c 1.2.1.4 644)
+++ 9.4/arch/ia64/kernel/mca.c Tue, 25 Nov 2003 19:30:04 +1100 kaos (linux-2.6-test/I/e/30_mca.c 1.2.1.6 644)
@@ -87,6 +87,7 @@ static void			ia64_mca_wakeup_all(void);
 static void			ia64_log_init(int);
 extern void			ia64_monarch_init_handler (void);
 extern void			ia64_slave_init_handler (void);
+static u64			ia64_log_get(int sal_info_type, u8 **buffer);
 extern struct hw_interrupt_type	irq_type_iosapic_level;
 
 static struct irqaction cmci_irqaction = {
@@ -149,12 +150,14 @@ static int cmc_polling_enabled = 1;
  */
 static int cpe_poll_enabled = 1;
 
+extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size);
+
 /*
  *  ia64_mca_log_sal_error_record
  *
- *  This function retrieves a specified error record type from SAL, sends it to
- *  the system log, and notifies SALs to clear the record from its non-volatile
- *  memory.
+ *  This function retrieves a specified error record type from SAL,
+ *  wakes up any processes waiting for error records, and sends it to
+ *  the system log.
  *
  *  Inputs  :   sal_info_type   (Type of error record MCA/CMC/CPE/INIT)
  *  Outputs :   platform error status
@@ -162,11 +165,13 @@ static int cpe_poll_enabled = 1;
 int
 ia64_mca_log_sal_error_record(int sal_info_type, int called_from_init)
 {
-	int platform_err = 0;
+	u8 *buffer;
+	u64 size;
+	int platform_err;
 
-	/* Get the MCA error record */
-	if (!ia64_log_get(sal_info_type, (prfunc_t)printk))
-		return platform_err;		/* no record retrieved */
+	size = ia64_log_get(sal_info_type, &buffer);
+	if (!size)
+		return 0;
 
 	/* TODO:
 	 * 1. analyze error logs to determine recoverability
@@ -174,10 +179,10 @@ ia64_mca_log_sal_error_record(int sal_in
 	 * 3. set ia64_os_mca_recovery_successful flag, if applicable
 	 */
 
+	salinfo_log_wakeup(sal_info_type, buffer, size);
 	platform_err = ia64_log_print(sal_info_type, (prfunc_t)printk);
-	/* temporary: only clear SAL logs on hardware-corrected errors
-		or if we're logging an error after an MCA-initiated reboot */
-	if ((sal_info_type > 1) || (called_from_init))
+	/* Clear logs from corrected errors in case there's no user-level logger */
+	if (sal_info_type = SAL_INFO_TYPE_CPE || sal_info_type = SAL_INFO_TYPE_CMC)
 		ia64_sal_clear_state_info(sal_info_type);
 
 	return platform_err;
@@ -450,7 +455,10 @@ static void
 ia64_mca_register_cpev (int cpev)
 {
 	/* Register the CPE interrupt vector with SAL */
-	if (ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0)) {
+	struct ia64_sal_retval isrv;
+
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_CPE_INT, SAL_MC_PARAM_MECHANISM_INT, cpev, 0, 0);
+	if (isrv.status) {
 		printk(KERN_ERR "ia64_mca_platform_init: failed to register Corrected "
 		       "Platform Error interrupt vector with SAL.\n");
 		return;
@@ -629,6 +637,8 @@ ia64_mca_init(void)
 	ia64_fptr_t *mca_hldlr_ptr = (ia64_fptr_t *)ia64_os_mca_dispatch;
 	int i;
 	s64 rc;
+	struct ia64_sal_retval isrv;
+	u64 timeout = IA64_MCA_RENDEZ_TIMEOUT;	/* platform specific */
 
 	IA64_MCA_DEBUG("ia64_mca_init: begin\n");
 
@@ -644,23 +654,33 @@ ia64_mca_init(void)
 	 */
 
 	/* Register the rendezvous interrupt vector with SAL */
-	if ((rc = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
-					 SAL_MC_PARAM_MECHANISM_INT,
-					 IA64_MCA_RENDEZ_VECTOR,
-					 IA64_MCA_RENDEZ_TIMEOUT,
-					 SAL_MC_PARAM_RZ_ALWAYS)))
-	{
+	while (1) {
+		isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_INT,
+					      SAL_MC_PARAM_MECHANISM_INT,
+					      IA64_MCA_RENDEZ_VECTOR,
+					      timeout,
+					      SAL_MC_PARAM_RZ_ALWAYS);
+		rc = isrv.status;
+		if (rc = 0)
+			break;
+		if (rc = -2) {
+			printk(KERN_INFO "ia64_mca_init: increasing MCA rendezvous timeout from "
+				"%ld to %ld\n", timeout, isrv.v0);
+			timeout = isrv.v0;
+			continue;
+		}
 		printk(KERN_ERR "ia64_mca_init: Failed to register rendezvous interrupt "
 		       "with SAL.  rc = %ld\n", rc);
 		return;
 	}
 
 	/* Register the wakeup interrupt vector with SAL */
-	if ((rc = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
-					 SAL_MC_PARAM_MECHANISM_INT,
-					 IA64_MCA_WAKEUP_VECTOR,
-					 0, 0)))
-	{
+	isrv = ia64_sal_mc_set_params(SAL_MC_PARAM_RENDEZ_WAKEUP,
+				      SAL_MC_PARAM_MECHANISM_INT,
+				      IA64_MCA_WAKEUP_VECTOR,
+				      0, 0);
+	rc = isrv.status;
+	if (rc) {
 		printk(KERN_ERR "ia64_mca_init: Failed to register wakeup interrupt with SAL.  "
 		       "rc = %ld\n", rc);
 		return;
@@ -1399,12 +1419,12 @@ ia64_log_init(int sal_info_type)
  *	Get the current MCA log from SAL and copy it into the OS log buffer.
  *
  *  Inputs  :   info_type   (SAL_INFO_TYPE_{MCA,INIT,CMC,CPE})
- *              prfunc      (fn ptr of log output function)
  *  Outputs :   size        (total record length)
+ *              *buffer     (ptr to error record)
  *
  */
-u64
-ia64_log_get(int sal_info_type, prfunc_t prfunc)
+static u64
+ia64_log_get(int sal_info_type, u8 **buffer)
 {
 	sal_log_record_header_t     *log_buffer;
 	u64                         total_len = 0;
@@ -1422,6 +1442,7 @@ ia64_log_get(int sal_info_type, prfunc_t
 		IA64_LOG_UNLOCK(sal_info_type);
 		IA64_MCA_DEBUG("ia64_log_get: SAL error record type %d retrieved. "
 			       "Record length = %ld\n", sal_info_type, total_len);
+		*buffer = (u8 *) log_buffer;
 		return total_len;
 	} else {
 		IA64_LOG_UNLOCK(sal_info_type);
@@ -1466,7 +1487,7 @@ ia64_log_prt_oem_data (int header_len, i
 void
 ia64_log_rec_header_print (sal_log_record_header_t *lh, prfunc_t prfunc)
 {
-	prfunc("+Err Record ID: %d    SAL Rev: %2x.%02x\n", lh->id,
+	prfunc("+Err Record ID: %ld    SAL Rev: %2x.%02x\n", lh->id,
 			lh->revision.major, lh->revision.minor);
 	prfunc("+Time: %02x/%02x/%02x%02x %02x:%02x:%02x    Severity %d\n",
 			lh->timestamp.slh_month, lh->timestamp.slh_day,
@@ -1589,13 +1610,13 @@ ia64_log_cache_check_info_print (int    
 	if (info->dl)
 		prfunc(" Line: Data,");
 	prfunc(" Operation: %s,", pal_cache_op[info->op]);
-	if (info->wv)
+	if (info->wiv)
 		prfunc(" Way: %d,", info->way);
 	if (cache_check_info->valid.target_identifier)
 		/* Hope target address is saved in target_identifier */
 		if (info->tv)
 			prfunc(" Target Addr: 0x%lx,", target_addr);
-	if (info->mc)
+	if (info->mcc)
 		prfunc(" MC: Corrected");
 	prfunc("\n");
 }
@@ -1631,13 +1652,13 @@ ia64_log_tlb_check_info_print (int      
 		prfunc("  Failure: Data Translation Cache");
 	if (info->itr) {
 		prfunc("  Failure: Instruction Translation Register");
-		prfunc(" ,Slot: %d", info->tr_slot);
+		prfunc(" ,Slot: %ld", info->tr_slot);
 	}
 	if (info->dtr) {
 		prfunc("  Failure: Data Translation Register");
-		prfunc(" ,Slot: %d", info->tr_slot);
+		prfunc(" ,Slot: %ld", info->tr_slot);
 	}
-	if (info->mc)
+	if (info->mcc)
 		prfunc(" ,MC: Corrected");
 	prfunc("\n");
 }
@@ -1683,7 +1704,7 @@ ia64_log_bus_check_info_print (int      
 		prfunc(" ,Error: Internal");
 	if (info->eb)
 		prfunc(" ,Error: External");
-	if (info->mc)
+	if (info->mcc)
 		prfunc(" ,MC: Corrected");
 	if (info->tv)
 		prfunc(" ,Target Address: 0x%lx", targ_addr);
@@ -1970,9 +1991,9 @@ ia64_log_plat_specific_err_info_print (s
 		ia64_log_prt_guid(&psei->guid, prfunc);
 	}
 	if (psei->valid.oem_data) {
-		platform_plat_specific_err_print((int)psei->header.len,
-				      (int)sizeof(sal_log_plat_specific_err_info_t) - 1,
-				      &(psei->oem_data[0]), prfunc);
+		platform_plat_specific_err_print((int) psei->header.len,
+				      (char *) psei->oem_data - (char *) psei,
+				      &psei->oem_data[0], prfunc);
 	}
 	prfunc("\n");
 }
@@ -2352,13 +2373,12 @@ ia64_log_print(int sal_info_type, prfunc
 
 	switch(sal_info_type) {
 	      case SAL_INFO_TYPE_MCA:
-		prfunc("+BEGIN HARDWARE ERROR STATE AT MCA\n");
-		platform_err = ia64_log_platform_info_print(IA64_LOG_CURR_BUFFER(sal_info_type),
-							    prfunc);
-		prfunc("+END HARDWARE ERROR STATE AT MCA\n");
+		prfunc("+CPU %d: SAL log contains MCA error record\n", smp_processor_id());
+		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_INIT:
-		prfunc("+MCA INIT ERROR LOG (UNIMPLEMENTED)\n");
+		prfunc("+CPU %d: SAL log contains INIT error record\n", smp_processor_id());
+		ia64_log_rec_header_print(IA64_LOG_CURR_BUFFER(sal_info_type), prfunc);
 		break;
 	      case SAL_INFO_TYPE_CMC:
 		prfunc("+BEGIN HARDWARE ERROR STATE AT CMC\n");

-
To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
