From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 26 Jan 2005 02:48:42 +0000
Subject: [patch] small comment fix
Message-Id: <16887.1290.837088.513031@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Seems like I can't spll...

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

=== arch/ia64/kernel/ptrace.c 1.44 vs edited ==--- 1.44/arch/ia64/kernel/ptrace.c	2005-01-25 17:58:06 -08:00
+++ edited/arch/ia64/kernel/ptrace.c	2005-01-25 18:02:28 -08:00
@@ -1374,7 +1374,7 @@
 {
 	struct ia64_psr *child_psr = ia64_psr(ia64_task_regs(child));
 
-	/* make sure the single step/take-branch tra bits are not set: */
+	/* make sure the single step/taken-branch trap bits are not set: */
 	child_psr->ss = 0;
 	child_psr->tb = 0;
 }
