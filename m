From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Wed, 03 Oct 2007 08:06:26 +0000
Subject: [PATCH 2/3] signal(ia64): alternative signal stack wraparound occurs
Message-Id: <47034D82.1000208@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: tony.luck@intel.com, linux-ia64@vger.kernel.org

Fixing alternative signal stack wraparound.

If a process uses alternative signal stack by using sigaltstack()
and that stack overflow, stack wraparound occurs.
This patch checks whether the signal frame is on the alternative
stack. If the frame is not on there, kill a signal SIGSEGV to the process forcedly
then the process will be terminated.

This patch is for ia64,version is 2.6.23-rc8.

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com>

diff -pur linux-2.6.23-rc8.orig/arch/ia64/ia32/ia32_signal.c 
linux-2.6.23-rc8/arch/ia64/ia32/ia32_signal.c
--- linux-2.6.23-rc8.orig/arch/ia64/ia32/ia32_signal.c	2007-07-09 08:32:17.000000000 +0900
+++ linux-2.6.23-rc8/arch/ia64/ia32/ia32_signal.c	2007-09-26 12:16:09.000000000 +0900
@@ -766,7 +766,7 @@ get_sigframe (struct k_sigaction *ka, st

  	/* This is the X/Open sanctioned signal stack switching.  */
  	if (ka->sa.sa_flags & SA_ONSTACK) {
-		if (!on_sig_stack(esp))
+		if (sas_ss_flags(esp) = 0)
  			esp = current->sas_ss_sp + current->sas_ss_size;
  	}
  	/* Legacy stack switching not supported */
@@ -787,6 +787,10 @@ setup_frame_ia32 (int sig, struct k_siga

  	frame = get_sigframe(ka, regs, sizeof(*frame));

+	if ((ka->sa.sa_flags & SA_ONSTACK)
+		&& (sas_ss_flags((unsigned long) frame) = 0))
+		goto give_sigsegv;
+
  	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
  		goto give_sigsegv;

@@ -854,6 +858,10 @@ setup_rt_frame_ia32 (int sig, struct k_s

  	frame = get_sigframe(ka, regs, sizeof(*frame));

+	if ((ka->sa.sa_flags & SA_ONSTACK)
+		&& (sas_ss_flags((unsigned long) frame) = 0))
+		goto give_sigsegv;
+
  	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
  		goto give_sigsegv;

diff -pur linux-2.6.23-rc8.orig/arch/ia64/kernel/signal.c linux-2.6.23-rc8/arch/ia64/kernel/signal.c
--- linux-2.6.23-rc8.orig/arch/ia64/kernel/signal.c	2007-07-09 08:32:17.000000000 +0900
+++ linux-2.6.23-rc8/arch/ia64/kernel/signal.c	2007-09-26 09:54:10.000000000 +0900
@@ -362,6 +362,10 @@ setup_frame (int sig, struct k_sigaction
  	}
  	frame = (void __user *) ((new_sp - sizeof(*frame)) & -STACK_ALIGN);

+	if ((ka->sa.sa_flags & SA_ONSTACK)
+		&& (sas_ss_flags((unsigned long) frame) = 0))
+		return force_sigsegv_info(sig, frame);
+
  	if (!access_ok(VERIFY_WRITE, frame, sizeof(*frame)))
  		return force_sigsegv_info(sig, frame);


