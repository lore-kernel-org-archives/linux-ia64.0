From: Takao Indoh <indou.takao@jp.fujitsu.com>
Date: Tue, 05 Sep 2006 12:18:39 +0000
Subject: [PATCH]IA64 kexec/kdump patch for INIT
Message-Id: <75C6D0E56B35AEindou.takao@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

Here is the IA64 kdump patch for INIT against 2.6.18-rc5
with a kexec/kdump 2.6.18-rc5 patch which was posted by Zou Nan hai on 29th Aug.

This patch includes the following two functions.

1) Stop each cpu using INIT interruption

Current kdump uses simple IPI to stop cpus, so cpu does not stop
if the cpu disables interruption. INIT interruption is non-maskable and
it can stop cpus surely.

2) Start kexec/kdump by INIT button

Some machines have a button to generate INIT. When a kernel hangs up,
we can start kexec/kdump using INIT button. This function is
enabled/disabled by /proc/sys/kernel/kdump_on_init.


TODO:
o Add delay code not to start kexec before each cpu's register is saved


Any comments are welcome!


Signed-off-by: Takao Indoh <indou.takao@jp.fujitsu.com>

diff -Nurp linux-2.6.18-rc5.org/arch/ia64/kernel/mca.c linux-2.6.18-rc5/arch/ia64/kernel/mca.c
--- linux-2.6.18-rc5.org/arch/ia64/kernel/mca.c	2006-08-31 14:27:10.000000000 +0900
+++ linux-2.6.18-rc5/arch/ia64/kernel/mca.c	2006-09-05 20:17:06.000000000 +0900
@@ -69,6 +69,7 @@
 #include <linux/smp.h>
 #include <linux/workqueue.h>
 #include <linux/cpumask.h>
+#include <linux/kexec.h>
 
 #include <asm/delay.h>
 #include <asm/kdebug.h>
@@ -136,6 +137,9 @@ extern void salinfo_log_wakeup(int type,
 
 static int mca_init __initdata;
 
+#ifdef CONFIG_CRASH_DUMP
+int kdump_on_init = 0;
+#endif
 
 static void inline
 ia64_mca_spin(const char *func)
@@ -1393,6 +1397,23 @@ ia64_init_handler(struct pt_regs *regs, 
 		sos->monarch = 0;
 	}
 
+#ifdef CONFIG_CRASH_DUMP
+	/* if reason code is not 1(reason code 1 means machine check
+	 * rendezvous), INIT was issued by kdump or INIT button.
+	 */
+	if (sos->rv_rc != 1 && (kdump_send_ipi || kdump_on_init)) {
+		local_irq_disable();
+		set_curr_task(cpu, previous_current);
+
+		/* change region of gp to region5 */
+		asm volatile ("movl gp=__gp"::: "memory");
+		crash_kexec(regs);
+
+		crash_save_this_cpu();
+		for (;;)
+			ia64_hint(ia64_hint_pause);
+	}
+#endif
 	if (!sos->monarch) {
 		ia64_mc_info.imi_rendez_checkin[cpu] = IA64_MCA_RENDEZ_CHECKIN_INIT;
 		while (monarch_cpu = -1)
diff -Nurp linux-2.6.18-rc5.org/arch/ia64/kernel/smp.c linux-2.6.18-rc5/arch/ia64/kernel/smp.c
--- linux-2.6.18-rc5.org/arch/ia64/kernel/smp.c	2006-08-31 14:27:10.000000000 +0900
+++ linux-2.6.18-rc5/arch/ia64/kernel/smp.c	2006-09-05 11:39:33.000000000 +0900
@@ -261,10 +261,17 @@ send_IPI_self (int op)
 }
 
 #ifdef CONFIG_CRASH_DUMP
+int kdump_send_ipi = 0;
 void
 kdump_smp_send_stop()
 {
- 	send_IPI_allbutself(IPI_KDUMP_CPU_STOP);
+	unsigned int i;
+
+	kdump_send_ipi = 1;
+	for_each_online_cpu (i) {
+		if (i != smp_processor_id())
+			platform_send_ipi(i, IA64_IPI_VECTOR, IA64_IPI_DM_INIT, 0);
+	}
 }
 #endif
 /*
diff -Nurp linux-2.6.18-rc5.org/include/asm-ia64/kexec.h linux-2.6.18-rc5/include/asm-ia64/kexec.h
--- linux-2.6.18-rc5.org/include/asm-ia64/kexec.h	2006-08-31 14:26:49.000000000 +0900
+++ linux-2.6.18-rc5/include/asm-ia64/kexec.h	2006-09-05 20:16:32.000000000 +0900
@@ -41,5 +41,7 @@ extern struct resource boot_param_res;
 extern void kdump_smp_send_stop(void);
 extern void kdump_disable_iosapic(void);
 extern void crash_save_this_cpu(void);
+extern int kdump_send_ipi;
+extern int kdump_on_init;
 
 #endif /* _ASM_IA64_KEXEC_H */
diff -Nurp linux-2.6.18-rc5.org/include/linux/sysctl.h linux-2.6.18-rc5/include/linux/sysctl.h
--- linux-2.6.18-rc5.org/include/linux/sysctl.h	2006-08-31 14:26:55.000000000 +0900
+++ linux-2.6.18-rc5/include/linux/sysctl.h	2006-09-05 20:50:57.000000000 +0900
@@ -150,6 +150,7 @@ enum
 	KERN_IA64_UNALIGNEDr, /* int: ia64 unaligned userland trap enable */
 	KERN_COMPAT_LOGs,	/* int: print compat layer  messages */
 	KERN_MAX_LOCK_DEPTHt,
+	KERN_KDUMP_ON_INITu, /* int: kdump by INIT button */
 };
 
 
diff -Nurp linux-2.6.18-rc5.org/kernel/sysctl.c linux-2.6.18-rc5/kernel/sysctl.c
--- linux-2.6.18-rc5.org/kernel/sysctl.c	2006-08-31 14:27:40.000000000 +0900
+++ linux-2.6.18-rc5/kernel/sysctl.c	2006-09-05 20:51:37.000000000 +0900
@@ -45,6 +45,7 @@
 #include <linux/syscalls.h>
 #include <linux/nfs_fs.h>
 #include <linux/acpi.h>
+#include <linux/kexec.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -701,6 +702,16 @@ static ctl_table kern_table[] = {
 		.proc_handler	= &proc_dointvec,
 	},
 #endif
+#if defined(CONFIG_IA64) && defined(CONFIG_CRASH_DUMP)
+	{
+		.ctl_name	= KERN_KDUMP_ON_INIT,
+		.procname	= "kdump_on_init",
+		.data		= &kdump_on_init,
+		.maxlen		= sizeof (int),
+	 	.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
+#endif
 
 	{ .ctl_name = 0 }
 };


