From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Mon, 18 Feb 2008 10:26:23 +0000
Subject: [PATCH 4/5] signal(ia64): add a signal stack overflow check
Message-Id: <47B95D4F.8030003@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The similar check has been added to x86_32(i386) in commit
id 83bd01024b1fdfc41d9b758e5669e80fca72df66.
So we add this check to ia64 and improve it a liitle bit in that
we need to check for stack overflow only when the signal is on stack.

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 

---
--- linux-2.6.25-rc2.orig/arch/ia64/kernel/signal.c	2008-02-16 04:57:20.000000000 +0800
+++ linux-2.6.25-rc2/arch/ia64/kernel/signal.c	2008-02-18 18:17:15.000000000 +0800
@@ -342,15 +342,29 @@ setup_frame (int sig, struct k_sigaction
 
 	new_sp = scr->pt.r12;
 	tramp_addr = (unsigned long) __kernel_sigtramp;
-	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags(new_sp) = 0) {
-		new_sp = current->sas_ss_sp + current->sas_ss_size;
-		/*
-		 * We need to check for the register stack being on the signal stack
-		 * separately, because it's switched separately (memory stack is switched
-		 * in the kernel, register stack is switched in the signal trampoline).
-		 */
-		if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
-			new_rbs = (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - 1);
+	if (ka->sa.sa_flags & SA_ONSTACK) {
+		int onstack = sas_ss_flags(new_sp);
+
+		if (onstack = 0) {
+			new_sp = current->sas_ss_sp + current->sas_ss_size;
+			/*
+			 * We need to check for the register stack being on the
+			 * signal stack separately, because it's switched
+			 * separately (memory stack is switched in the kernel,
+			 * register stack is switched in the signal trampoline).
+			 */
+			if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
+				new_rbs = (current->sas_ss_sp +
+					  sizeof(long) - 1) & ~(sizeof(long) - 1);
+		} else if (onstack = SS_ONSTACK) {
+			/*
+			 * If we are on the alternate signal stack and would
+			 * overflow it, don't return an always-bogus address
+			 * instead so we will die with SIGSEGV.
+			 */
+			if (!likely(on_sig_stack(new_sp - sizeof(*frame))))
+				return force_sigsegv_info(sig, frame);
+		}
 	}
 	frame = (void __user *) ((new_sp - sizeof(*frame)) & -STACK_ALIGN);
 


