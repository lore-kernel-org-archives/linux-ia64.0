From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Thu, 20 Jan 2005 06:24:27 +0000
Subject: [patch] fix ptrace debug-register handling bug
Message-Id: <200501200624.j0K6ORhk007171@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I noticed that the PTRACE_POKEUSR code incorrectly clears bits 56-58
of _all_ debug registers.  The intention was to only clear it for
odd-numbered registers, to ensure that user-level can only set
user-level data/instruction-breakpoints.  Patch below fixes this problem.
The patch also replaces explicit clearing of the single-step and
taken-branch PSR bits with a call to ptrace_disable() for PTRACE_KILL.

Please apply.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/ptrace.c 1.42 vs edited ==--- 1.42/arch/ia64/kernel/ptrace.c	2005-01-18 20:41:57 -08:00
+++ edited/arch/ia64/kernel/ptrace.c	2005-01-19 13:22:56 -08:00
@@ -1052,12 +1052,11 @@
 
 		ptr += regnum;
 
-		if (write_access)
+		if ((regnum & 1) && write_access) {
 			/* don't let the user set kernel-level breakpoints: */
 			*ptr = *data & ~(7UL << 56);
-		else
-			*data = *ptr;
-		return 0;
+			return 0;
+		}
 	}
 	if (write_access)
 		*ptr = *data;
@@ -1522,13 +1520,7 @@
 			goto out_tsk;
 		child->exit_code = SIGKILL;
 
-		/*
-		 * Make sure the single step/take-branch trap bits are
-		 * not set:
-		 */
-		ia64_psr(pt)->ss = 0;
-		ia64_psr(pt)->tb = 0;
-
+		ptrace_disable(child);
 		wake_up_process(child);
 		ret = 0;
 		goto out_tsk;
