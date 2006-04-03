From: Keith Owens <kaos@sgi.com>
Date: Mon, 03 Apr 2006 05:26:12 +0000
Subject: [patch 2.6.16-git] Pass more data to the MCA/INIT notify_die hooks
Message-Id: <22273.1144041972@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The MCA/INIT handlers maintain important state in the SAL to OS (sos)
area and in the monarch_cpu flag.  Kernel debuggers (such as KDB) need
this data, and may need to adjust the monarch_cpu field so make the
data available to the notify_die hooks.  Define two more events for
calling the functions on the notify_die chain.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

Patch is against aegl git test tree, as of April 2.

This patch is part of a long term project to provide a standard set of
kernel hooks which can be used by any debugger, not just by KDB.

 arch/ia64/kernel/mca.c    |   33 +++++++++++++++++++++------------
 include/asm-ia64/kdebug.h |    2 ++
 include/asm-ia64/mca.h    |    5 +++++
 3 files changed, 28 insertions(+), 12 deletions(-)


Index: linux-2.6-ia64/arch/ia64/kernel/mca.c
=================================--- linux-2.6-ia64.orig/arch/ia64/kernel/mca.c	2006-04-03 11:38:01.000000000 +1000
+++ linux-2.6-ia64/arch/ia64/kernel/mca.c	2006-04-03 12:16:42.011119879 +1000
@@ -581,10 +581,12 @@ ia64_mca_rendez_int_handler(int rendez_i
 {
 	unsigned long flags;
 	int cpu = smp_processor_id();
+	struct ia64_mca_notify_die nd +		{ .sos = NULL, .monarch_cpu = &monarch_cpu };
 
 	/* Mask all interrupts */
 	local_irq_save(flags);
-	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -594,7 +596,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 	 */
 	ia64_sal_mc_rendez();
 
-	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_PROCESS, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -602,7 +604,7 @@ ia64_mca_rendez_int_handler(int rendez_i
 	while (monarch_cpu != -1)
 	       cpu_relax();	/* spin until monarch leaves */
 
-	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_RENDZVOUS_LEAVE, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1023,6 +1025,8 @@ ia64_mca_handler(struct pt_regs *regs, s
 		&sos->proc_state_param;
 	int recover, cpu = smp_processor_id();
 	task_t *previous_current;
+	struct ia64_mca_notify_die nd +		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
@@ -1031,7 +1035,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
 	monarch_cpu = cpu;
-	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 	ia64_wait_for_slaves(cpu);
@@ -1043,7 +1047,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	 * spinning in SAL does not work.
 	 */
 	ia64_mca_wakeup_all();
-	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, 0, 0, 0)
+	if (notify_die(DIE_MCA_MONARCH_PROCESS, "MCA", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1064,7 +1068,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
 	}
-	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, 0, 0, recover)
+	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1351,10 +1355,14 @@ ia64_init_handler(struct pt_regs *regs, 
 	static atomic_t monarchs;
 	task_t *previous_current;
 	int cpu = smp_processor_id();
+	struct ia64_mca_notify_die nd +		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
+	(void) notify_die(DIE_INIT_ENTER, "INIT", regs, (long)&nd, 0, 0);
+
 	printk(KERN_INFO "Entered OS INIT handler. PSP=%lx cpu=%d monarch=%ld\n",
 		sos->proc_state_param, cpu, sos->monarch);
 	salinfo_log_wakeup(SAL_INFO_TYPE_INIT, NULL, 0, 0);
@@ -1390,15 +1398,15 @@ ia64_init_handler(struct pt_regs *regs, 
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
 		       cpu_relax();	/* spin until monarch enters */
-		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_ENTER, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
-		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
 		while (monarch_cpu != -1)
 		       cpu_relax();	/* spin until monarch leaves */
-		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, 0, 0, 0)
+		if (notify_die(DIE_INIT_SLAVE_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 				= NOTIFY_STOP)
 			ia64_mca_spin(__FUNCTION__);
 		printk("Slave on cpu %d returning to normal service.\n", cpu);
@@ -1409,7 +1417,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	}
 
 	monarch_cpu = cpu;
-	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_ENTER, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 
@@ -1426,10 +1434,10 @@ ia64_init_handler(struct pt_regs *regs, 
 	 * to default_monarch_init_process() above and just print all the
 	 * tasks.
 	 */
-	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_PROCESS, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
-	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, 0, 0, 0)
+	if (notify_die(DIE_INIT_MONARCH_LEAVE, "INIT", regs, (long)&nd, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
@@ -1631,6 +1639,7 @@ ia64_mca_init(void)
 			printk(KERN_INFO "Increasing MCA rendezvous timeout from "
 				"%ld to %ld milliseconds\n", timeout, isrv.v0);
 			timeout = isrv.v0;
+			(void) notify_die(DIE_MCA_NEW_TIMEOUT, "MCA", NULL, timeout, 0, 0);
 			continue;
 		}
 		printk(KERN_ERR "Failed to register rendezvous interrupt "
Index: linux-2.6-ia64/include/asm-ia64/mca.h
=================================--- linux-2.6-ia64.orig/include/asm-ia64/mca.h	2006-04-03 11:38:19.000000000 +1000
+++ linux-2.6-ia64/include/asm-ia64/mca.h	2006-04-03 11:44:32.603770231 +1000
@@ -148,6 +148,11 @@ extern int  ia64_reg_MCA_extension(int (
 extern void ia64_unreg_MCA_extension(void);
 extern u64 ia64_get_rnat(u64 *);
 
+struct ia64_mca_notify_die {
+	struct ia64_sal_os_state *sos;
+	int *monarch_cpu;
+};
+
 #else	/* __ASSEMBLY__ */
 
 #define IA64_MCA_CORRECTED	0x0	/* Error has been corrected by OS_MCA */
Index: linux-2.6-ia64/include/asm-ia64/kdebug.h
=================================--- linux-2.6-ia64.orig/include/asm-ia64/kdebug.h	2006-04-03 12:13:59.000000000 +1000
+++ linux-2.6-ia64/include/asm-ia64/kdebug.h	2006-04-03 12:14:12.014069993 +1000
@@ -58,6 +58,8 @@ enum die_val {
 	DIE_MCA_RENDZVOUS_ENTER,
 	DIE_MCA_RENDZVOUS_PROCESS,
 	DIE_MCA_RENDZVOUS_LEAVE,
+	DIE_MCA_NEW_TIMEOUT,
+	DIE_INIT_ENTER,
 	DIE_INIT_MONARCH_ENTER,
 	DIE_INIT_MONARCH_PROCESS,
 	DIE_INIT_MONARCH_LEAVE,

