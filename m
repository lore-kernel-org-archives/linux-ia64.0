From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 10 May 2005 18:34:45 +0000
Subject: [patch] fix ptrace "unwind-to-user" code
Message-Id: <17024.65221.741502.617353@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

Another patch that would be really good to get into 2.6.12...

	--david

[IA64] Correct convert_to_non_syscall()

convert_to_non_syscall() has the same problem that unwind_to_user()
used to have.  Fix it likewise.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/ptrace.c
=================================--- 4efbd8a990df4437fb178c8a705dadc36812f98a/arch/ia64/kernel/ptrace.c  (mode:100644)
+++ uncommitted/arch/ia64/kernel/ptrace.c  (mode:100644)
@@ -692,16 +692,30 @@
 			unsigned long cfm)
 {
 	struct unw_frame_info info, prev_info;
-	unsigned long ip, pr;
+	unsigned long ip, sp, pr;
 
 	unw_init_from_blocked_task(&info, child);
 	while (1) {
 		prev_info = info;
 		if (unw_unwind(&info) < 0)
 			return;
-		if (unw_get_rp(&info, &ip) < 0)
+
+		unw_get_sp(&info, &sp);
+		if ((long)((unsigned long)child + IA64_STK_OFFSET - sp)
+		    < IA64_PT_REGS_SIZE) {
+			dprintk("ptrace.%s: ran off the top of the kernel "
+				"stack\n", __FUNCTION__);
+			return;
+		}
+		if (unw_get_pr (&prev_info, &pr) < 0) {
+			unw_get_rp(&prev_info, &ip);
+			dprintk("ptrace.%s: failed to read "
+				"predicate register (ip=0x%lx)\n",
+				__FUNCTION__, ip);
 			return;
-		if (ip < FIXADDR_USER_END)
+		}
+		if (unw_is_intr_frame(&info)
+		    && (pr & (1UL << PRED_USER_STACK)))
 			break;
 	}
 
