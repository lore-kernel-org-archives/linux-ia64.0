From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 04:56:40 +0000
Subject: [patch] ia64: Don't forget to initialize PKStk for kernel-threads
Message-Id: <200501190456.j0J4ueug002411@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Kernel-threads had both pUStk and pKStk set to FALSE, which was
unintentional.  I don't think the bug has shown any ill effects, but
it's clearly wrong and could come around to bite us later, so let's
fix it now.  Depends on the previous patch to clean up C usage of the
global/root-function predicates.

	--david

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 20:51:20-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Don't forget to initialize pKStk on kernel-threads to TRUE.
# 
# arch/ia64/kernel/process.c
#   2005/01/18 20:51:03-08:00 davidm@tiger.hpl.hp.com +3 -1
#   Include "entry.h".
#   (convert_to_non_syscall): Initialize pKStk to TRUE.
# 
diff -Nru a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
--- a/arch/ia64/kernel/process.c	2005-01-18 20:54:31 -08:00
+++ b/arch/ia64/kernel/process.c	2005-01-18 20:54:31 -08:00
@@ -40,6 +40,8 @@
 #include <asm/unwind.h>
 #include <asm/user.h>
 
+#include "entry.h"
+
 #ifdef CONFIG_PERFMON
 # include <asm/perfmon.h>
 #endif
@@ -667,7 +669,7 @@
 	regs.pt.cr_ifs = 1UL << 63;		/* mark as valid, empty frame */
 	regs.sw.ar_fpsr = regs.pt.ar_fpsr = ia64_getreg(_IA64_REG_AR_FPSR);
 	regs.sw.ar_bspstore = (unsigned long) current + IA64_RBS_OFFSET;
-
+	regs.sw.pr = (1 << PRED_KERNEL_STACK);
 	return do_fork(flags | CLONE_VM | CLONE_UNTRACED, 0, &regs.pt, 0, NULL, NULL);
 }
 EXPORT_SYMBOL(kernel_thread);
