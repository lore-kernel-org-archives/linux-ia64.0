From: Shi Weihua <shiwh@cn.fujitsu.com>
Date: Mon, 18 Feb 2008 10:27:08 +0000
Subject: [PATCH 5/5] signal(ia64_ia32): add a signal stack overflow check
Message-Id: <47B95D7C.1080005@cn.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

The similar check has been added to x86_32(i386) in commit
id 83bd01024b1fdfc41d9b758e5669e80fca72df66.
So we add this check to ia64_ia32 and improve it a liitle bit in that
we need to check for stack overflow only when the signal is on stack.

Signed-off-by: Shi Weihua <shiwh@cn.fujitsu.com> 

---
--- linux-2.6.25-rc2.orig/arch/ia64/ia32/ia32_signal.c	2008-02-16 04:57:20.000000000 +0800
+++ linux-2.6.25-rc2/arch/ia64/ia32/ia32_signal.c	2008-02-18 18:12:49.000000000 +0800
@@ -766,8 +766,19 @@ get_sigframe (struct k_sigaction *ka, st
 
 	/* This is the X/Open sanctioned signal stack switching.  */
 	if (ka->sa.sa_flags & SA_ONSTACK) {
-		if (!on_sig_stack(esp))
+		int onstack = sas_ss_flags(esp);
+
+		if (onstack = 0)
 			esp = current->sas_ss_sp + current->sas_ss_size;
+		else if (onstack = SS_ONSTACK) {
+			/*
+			 * If we are on the alternate signal stack and would
+			 * overflow it, don't return an always-bogus address
+			 * instead so we will die with SIGSEGV.
+			 */
+			if (!likely(on_sig_stack(esp - frame_size)))
+				return (void __user *) -1L;
+		}
 	}
 	/* Legacy stack switching not supported */
 


