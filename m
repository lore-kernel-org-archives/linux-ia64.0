From: davidm@mostang.com (David Mosberger-Tang)
Date: Thu, 03 Nov 2005 06:40:19 +0000
Subject: [patch] align signal-frame even when not using alternate signal-stack
Message-Id: <20051103064019.5B552B3421@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[IA64] align signal-frame even when not using alternate signal-stack

At the moment, attempting to invoke a signal-handler on the normal
stack is guaranteed to fail if the stack-pointer happens not to be
16-byte aligned.  This is because the signal-trampoline will attempt
to store fp-regs with stf.spill instructions, which will trap for
misaligned addresses.  This isn't terribly useful behavior.  It's
better to just always align the signal frame to the next lower 16-byte
boundary.  (Lightly) tested patch attached below.

Signed-off-by: David Mosberger-Tang <David.Mosberger@acm.org>

diff --git a/arch/ia64/kernel/signal.c b/arch/ia64/kernel/signal.c
--- a/arch/ia64/kernel/signal.c
+++ b/arch/ia64/kernel/signal.c
@@ -387,15 +387,14 @@ setup_frame (int sig, struct k_sigaction
 	     struct sigscratch *scr)
 {
 	extern char __kernel_sigtramp[];
-	unsigned long tramp_addr, new_rbs = 0;
+	unsigned long tramp_addr, new_rbs = 0, new_sp;
 	struct sigframe __user *frame;
 	long err;
 
-	frame = (void __user *) scr->pt.r12;
+	new_sp = scr->pt.r12;
 	tramp_addr = (unsigned long) __kernel_sigtramp;
-	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags((unsigned long) frame) = 0) {
-		frame = (void __user *) ((current->sas_ss_sp + current->sas_ss_size)
-					 & ~(STACK_ALIGN - 1));
+	if ((ka->sa.sa_flags & SA_ONSTACK) && sas_ss_flags(new_sp) = 0) {
+		new_sp = current->sas_ss_sp + current->sas_ss_size;
 		/*
 		 * We need to check for the register stack being on the signal stack
 		 * separately, because it's switched separately (memory stack is switched
@@ -404,7 +403,7 @@ setup_frame (int sig, struct k_sigaction
 		if (!rbs_on_sig_stack(scr->pt.ar_bspstore))
 			new_rbs = (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - 1);
 	}
-	frame = (void __user *) frame - ((sizeof(*frame) + STACK_ALIGN - 1) & ~(STACK_ALIGN - 1));
+	frame = (void __user *) ((new_sp - sizeof(*frame)) & -STACK_ALIGN);
 
 	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
 		return force_sigsegv_info(sig, frame);
