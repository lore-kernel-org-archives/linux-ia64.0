From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 08:58:41 +0000
Subject: [patch] fix proc-name typo in entry.S
Message-Id: <200504290858.j3T8wfQk001305@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[IA64] Trivial patch to fix a typo caught by new assembler

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/entry.S
=================================--- a63eb89df905efd86a58940286a63c5f670b1c05/arch/ia64/kernel/entry.S  (mode:100644 sha1:4517d4ab5ef1c2a7905edac6706763d5c6859c2d)
+++ uncommitted/arch/ia64/kernel/entry.S  (mode:100644)
@@ -777,7 +777,7 @@
 	st8.spill [r2]=r8	// store return value in slot for r8 and set unat bit
 	.mem.offset 8,0
 	st8.spill [r3]=r0	// clear error indication in slot for r10 and set unat bit
-END(ia64_ret_from_ia32_execve_syscall)
+END(ia64_ret_from_ia32_execve)
 	// fall through
 #endif /* CONFIG_IA32_SUPPORT */
 GLOBAL_ENTRY(ia64_leave_kernel)
