From: Zou Nan hai <nanhai.zou@intel.com>
Date: Fri, 29 Sep 2006 04:38:54 +0000
Subject: [Patch] Fix OS_INIT handle in IA64 Kexec/Kdump
Message-Id: <1159504734.5251.40.camel@linux-znh>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	Indoh found the bug of OS_INIT handler in my previous IA64 Kexec/Kdump
patch. 
	When Kdump found it can't stop other CPUs by IPI, it will send INIT to
them. One of the CPUs may be picked as monarch then execute
machine_kexec, thus 2 CPU will execute 
machine_kexec at the same time. Below patch will fix that.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

--- linux-2.6.18/arch/ia64/kernel/crash.c	2006-09-29 07:13:18.000000000 +0800
+++ linux-2.6.18-fix/arch/ia64/kernel/crash.c	2006-09-29 07:01:13.000000000 +0800
@@ -110,6 +110,8 @@ kdump_wait_cpu_freeze(void)
 	return 1;
 }
 
+static int kdump_sending_init;
+
 void
 machine_crash_shutdown(struct pt_regs *pt)
 {
@@ -125,8 +127,9 @@ machine_crash_shutdown(struct pt_regs *p
 #ifdef CONFIG_SMP
 	kdump_smp_send_stop();
 	if (kdump_wait_cpu_freeze() && kdump_on_init) 	{
-		kdump_sending_init = 1;
 		//not all cpu response to IPI, send INIT to freeze them
+		kdump_sending_init = 1;
+		mb();
 		kdump_smp_send_init();
 	}
 #endif
@@ -170,6 +173,9 @@ kdump_init_notifier(struct notifier_bloc
 	if (nd->sos->rv_rc = 1)
 		return NOTIFY_DONE;
 
+	if (kdump_sending_init)
+		unw_init_running(kdump_cpu_freeze, NULL);
+
 	switch (val) {
 		case DIE_INIT_MONARCH_ENTER:
 			machine_kdump_on_init();






	
