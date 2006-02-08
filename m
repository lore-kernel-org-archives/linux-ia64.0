From: Keith Owens <kaos@sgi.com>
Date: Wed, 08 Feb 2006 02:40:59 +0000
Subject: [PATCH 2.6.16-rc2 1/3] MCA: print messages in MCA handler
Message-Id: <20060208024059.9264.4992.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Print a message identifying the monarch MCA handler.  Print a summary
of the status of the slave MCA cpus.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 mca.c |   25 +++++++++++++++++++++++--
 1 files changed, 23 insertions(+), 2 deletions(-)

Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2006-02-08 11:41:55.494263795 +1100
+++ linux/arch/ia64/kernel/mca.c	2006-02-08 12:10:03.619783349 +1100
@@ -908,7 +908,7 @@ no_mod:
 static void
 ia64_wait_for_slaves(int monarch)
 {
-	int c, wait = 0;
+	int c, wait = 0, missing = 0;
 	for_each_online_cpu(c) {
 		if (c = monarch)
 			continue;
@@ -919,15 +919,32 @@ ia64_wait_for_slaves(int monarch)
 		}
 	}
 	if (!wait)
-		return;
+		goto all_in;
 	for_each_online_cpu(c) {
 		if (c = monarch)
 			continue;
 		if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE) {
 			udelay(5*1000000);	/* wait 5 seconds for slaves (arbitrary) */
+			if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE)
+				missing = 1;
 			break;
 		}
 	}
+	if (!missing)
+		goto all_in;
+	printk(KERN_INFO "OS MCA slave did not rendezvous on cpu");
+	for_each_online_cpu(c) {
+		if (c = monarch)
+			continue;
+		if (ia64_mc_info.imi_rendez_checkin[c] = IA64_MCA_RENDEZ_CHECKIN_NOTDONE)
+			printk(" %d", c);
+	}
+	printk("\n");
+	return;
+
+all_in:
+	printk(KERN_INFO "All OS MCA slaves have reached rendezvous\n");
+	return;
 }
 
 /*
@@ -953,6 +970,10 @@ ia64_mca_handler(struct pt_regs *regs, s
 	task_t *previous_current;
 
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
+	console_loglevel = 15;	/* make sure printks make it to console */
+	printk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d monarch=%ld\n",
+		sos->proc_state_param, cpu, sos->monarch);
+
 	previous_current = ia64_mca_modify_original_stack(regs, sw, sos, "MCA");
 	monarch_cpu = cpu;
 	if (notify_die(DIE_MCA_MONARCH_ENTER, "MCA", regs, 0, 0, 0)
