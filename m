From: Keith Owens <kaos@sgi.com>
Date: Tue, 11 Apr 2006 04:59:41 +0000
Subject: [patch 2.6.17-rc1] ia64_wait_for_slaves() incorrectly reports MCA
Message-Id: <26547.1144731581@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64_wait_for_slaves() was changed in 2.6.17-rc1 to report the slave
state.  It incorrectly assumes that all slaves are for MCA, but
ia64_wait_for_slaves() is also called from the INIT monarch handler.
The existing message is very misleading, so correct it.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 arch/ia64/kernel/mca.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2006-04-11 14:51:33.000000000 +1000
+++ linux/arch/ia64/kernel/mca.c	2006-04-11 14:57:28.132676363 +1000
@@ -961,7 +961,7 @@ no_mod:
  */
 
 static void
-ia64_wait_for_slaves(int monarch)
+ia64_wait_for_slaves(int monarch, const char *type)
 {
 	int c, wait = 0, missing = 0;
 	for_each_online_cpu(c) {
@@ -987,7 +987,7 @@ ia64_wait_for_slaves(int monarch)
 	}
 	if (!missing)
 		goto all_in;
-	printk(KERN_INFO "OS MCA slave did not rendezvous on cpu");
+	printk(KERN_INFO "OS %s slave did not rendezvous on cpu", type);
 	for_each_online_cpu(c) {
 		if (c = monarch)
 			continue;
@@ -998,7 +998,7 @@ ia64_wait_for_slaves(int monarch)
 	return;
 
 all_in:
-	printk(KERN_INFO "All OS MCA slaves have reached rendezvous\n");
+	printk(KERN_INFO "All OS %s slaves have reached rendezvous\n", type);
 	return;
 }
 
@@ -1034,7 +1034,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, 0, 0, 0)
 			= NOTIFY_STOP)
 		ia64_mca_spin(__FUNCTION__);
-	ia64_wait_for_slaves(cpu);
+	ia64_wait_for_slaves(cpu, "MCA");
 
 	/* Wakeup all the processors which are spinning in the rendezvous loop.
 	 * They will leave SAL, then spin in the OS with interrupts disabled
@@ -1421,7 +1421,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	 */
 	printk("Delaying for 5 seconds...\n");
 	udelay(5*1000000);
-	ia64_wait_for_slaves(cpu);
+	ia64_wait_for_slaves(cpu, "INIT");
 	/* If nobody intercepts DIE_INIT_MONARCH_PROCESS then we drop through
 	 * to default_monarch_init_process() above and just print all the
 	 * tasks.


