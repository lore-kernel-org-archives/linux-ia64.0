From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 15 Jan 2005 07:25:29 +0000
Subject: [patch] fix sparse warning due to missing __user cast
Message-Id: <200501150725.j0F7PTXM022462@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial fix for a missing "__user" attribute.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/ia32/sys_ia32.c 1.111 vs edited ==--- 1.111/arch/ia64/ia32/sys_ia32.c	2005-01-11 15:58:41 -08:00
+++ edited/arch/ia64/ia32/sys_ia32.c	2005-01-14 23:01:12 -08:00
@@ -2656,7 +2647,7 @@
 	info.si_signo = 0;
 	set_fs (KERNEL_DS);
 	ret = sys_waitid(which, pid, (siginfo_t __user *) &info, options,
-			 uru ? &ru : NULL);
+			 uru ? (struct rusage __user *) &ru : NULL);
 	set_fs (old_fs);
 
 	if (ret < 0 || info.si_signo = 0)
