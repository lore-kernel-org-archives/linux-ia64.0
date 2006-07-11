From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Tue, 11 Jul 2006 19:12:53 +0000
Subject: [PATCH] oops_in_progress on MCA/INIT
Message-Id: <200607111912.k6BJCrIP1986049@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keith Owens wrote:
> 
> The existing 'oops_in_progress' code is working pretty well.  It does
> leave nasty bits behind if the MCA is recoverable, but that problem is
> not bad enough to justify a completely separate print mechanism plus
> changes to external programs.  Instead we should fix the unwanted side
> effects of oops_in_progress.

One problem is that oops_in_progress gets set in MCA/INIT but
does not get cleared if the MCA is recovered (or after the INIT
stack trace prints).  The result is that subsequent messages do
not get to /var/log/messages, due to release_console_sem() not 
waking up klogd.  Thanks to Keith Owens for his analysis of 
this problem.

This patch does not address the larger issue of printing from
MCA/INIT context.

Signed-off-by: Russ Anderson (rja@sgi.com)

---------------------------------------------------------
---
 arch/ia64/kernel/mca.c |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

Index: test/arch/ia64/kernel/mca.c
=================================--- test.orig/arch/ia64/kernel/mca.c	2006-06-22 16:37:35.000000000 -0500
+++ test/arch/ia64/kernel/mca.c	2006-07-11 13:17:39.765023019 -0500
@@ -132,6 +132,17 @@ static int cmc_polling_enabled = 1;
  * necessary for debugging.
  */
 static int cpe_poll_enabled = 1;
+static int loglevel_save = -1;
+
+#define SAVE_LOGLEVEL(__console_loglevel)		\
+	if (loglevel_save < 0)				\
+		loglevel_save = __console_loglevel
+
+#define RESTORE_LOGLEVEL(__console_loglevel)		\
+	if (loglevel_save >= 0) {			\
+		__console_loglevel = loglevel_save;	\
+		loglevel_save = -1;			\
+	}
 
 extern void salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe);
 
@@ -1028,6 +1039,7 @@ ia64_mca_handler(struct pt_regs *regs, s
 	struct ia64_mca_notify_die nd  		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
+	SAVE_LOGLEVEL(console_loglevel);
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 	printk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d monarch=%ld\n",
@@ -1067,6 +1079,8 @@ ia64_mca_handler(struct pt_regs *regs, s
 		rh->severity = sal_log_severity_corrected;
 		ia64_sal_clear_state_info(SAL_INFO_TYPE_MCA);
 		sos->os_status = IA64_MCA_CORRECTED;
+		RESTORE_LOGLEVEL(console_loglevel);
+		oops_in_progress = 0;
 	}
 	if (notify_die(DIE_MCA_MONARCH_LEAVE, "MCA", regs, (long)&nd, 0, recover)
 			= NOTIFY_STOP)
@@ -1358,6 +1372,7 @@ ia64_init_handler(struct pt_regs *regs, 
 	struct ia64_mca_notify_die nd  		{ .sos = sos, .monarch_cpu = &monarch_cpu };
 
+	SAVE_LOGLEVEL(console_loglevel);
 	oops_in_progress = 1;	/* FIXME: make printk NMI/MCA/INIT safe */
 	console_loglevel = 15;	/* make sure printks make it to console */
 
@@ -1442,6 +1457,8 @@ ia64_init_handler(struct pt_regs *regs, 
 		ia64_mca_spin(__FUNCTION__);
 	printk("\nINIT dump complete.  Monarch on cpu %d returning to normal service.\n", cpu);
 	atomic_dec(&monarchs);
+	RESTORE_LOGLEVEL(console_loglevel);
+	oops_in_progress = 0;
 	set_curr_task(cpu, previous_current);
 	monarch_cpu = -1;
 	return;

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
