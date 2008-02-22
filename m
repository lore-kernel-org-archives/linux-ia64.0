From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:26 +0000
Subject: [PATCH 09/28] ia64/xen: paravirtualize pal_call_static().
Message-Id: <12036570473740-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/pal.S        |    5 ++-
 arch/ia64/xen/xenpal.S        |   76 +++++++++++++++++++++++++++++++++++++++++
 include/asm-ia64/privop.h     |    1 +
 include/asm-ia64/xen/privop.h |    1 +
 4 files changed, 81 insertions(+), 2 deletions(-)
 create mode 100644 arch/ia64/xen/xenpal.S

diff --git a/arch/ia64/kernel/pal.S b/arch/ia64/kernel/pal.S
index 0b53344..de7252d 100644
--- a/arch/ia64/kernel/pal.S
+++ b/arch/ia64/kernel/pal.S
@@ -16,6 +16,7 @@
 #include <asm/processor.h>
 
 	.data
+	.globl pal_entry_point
 pal_entry_point:
 	data8 ia64_pal_default_handler
 	.text
@@ -52,7 +53,7 @@ END(ia64_pal_default_handler)
  * in0         Index of PAL service
  * in1 - in3   Remaining PAL arguments
  */
-GLOBAL_ENTRY(ia64_pal_call_static)
+GLOBAL_ENTRY(__ia64_pal_call_static)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(4)
 	alloc loc1 = ar.pfs,4,5,0,0
 	movl loc2 = pal_entry_point
@@ -86,7 +87,7 @@ GLOBAL_ENTRY(ia64_pal_call_static)
 	;;
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.many b0
-END(ia64_pal_call_static)
+END(__ia64_pal_call_static)
 
 /*
  * Make a PAL call using the stacked registers calling convention.
diff --git a/arch/ia64/xen/xenpal.S b/arch/ia64/xen/xenpal.S
new file mode 100644
index 0000000..cf8dff9
--- /dev/null
+++ b/arch/ia64/xen/xenpal.S
@@ -0,0 +1,76 @@
+/*
+ * ia64/xen/xenpal.S
+ *
+ * Alternate PAL  routines for Xen.  Heavily leveraged from
+ *   ia64/kernel/pal.S
+ *
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@.hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/processor.h>
+#include <asm/paravirt_nop.h>
+
+GLOBAL_ENTRY(xen_pal_call_static)
+#ifdef CONFIG_XEN
+	BR_IF_NATIVE(__ia64_pal_call_static, r22, p7)
+#endif
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5)
+	alloc loc1 = ar.pfs,4,5,0,0
+	movl loc2 = pal_entry_point
+1:	{
+	  mov r28 = in0
+	  mov r29 = in1
+	  mov r8 = ip
+	}
+	;;
+	ld8 loc2 = [loc2]		// loc2 <- entry point
+	adds r8 = 1f-1b,r8
+	mov loc4=ar.rsc			// save RSE configuration
+	;;
+	mov ar.rsc=0			// put RSE in enforced lazy, LE mode
+#ifdef CONFIG_XEN
+	mov r9 = r8
+	XEN_HYPER_GET_PSR
+	;;
+	mov loc3 = r8
+	mov r8 = r9
+	;;
+#else
+	mov loc3 = psr
+#endif
+	mov loc0 = rp
+	.body
+	mov r30 = in2
+
+#ifdef CONFIG_XEN
+	// this is low priority for paravirtualization, but is called
+	// from the idle loop so confuses privop counting
+	movl r31=XSI_PSR_I_ADDR
+	;;
+	ld8 r31=[r31]
+	mov r22=1
+	;;
+	st1 [r31]=r22
+	;;
+	mov r31 = in3
+	mov b7 = loc2
+	;;
+#else
+	mov r31 = in3
+	mov b7 = loc2
+
+(p7)	rsm psr.i
+	;;
+#endif
+	mov rp = r8
+	br.cond.sptk.many b7
+1:	mov psr.l = loc3
+	mov ar.rsc = loc4		// restore RSE configuration
+	mov ar.pfs = loc1
+	mov rp = loc0
+	;;
+	srlz.d				// seralize restoration of psr.l
+	br.ret.sptk.many b0
+END(xen_pal_call_static)
diff --git a/include/asm-ia64/privop.h b/include/asm-ia64/privop.h
index b8dce79..09c14ae 100644
--- a/include/asm-ia64/privop.h
+++ b/include/asm-ia64/privop.h
@@ -21,6 +21,7 @@
 #define ia64_leave_syscall		__ia64_leave_syscall
 #define ia64_work_processed_syscall	__ia64_work_processed_syscall
 #define ia64_leave_kernel		__ia64_leave_kernel
+#define ia64_pal_call_static		__ia64_pal_call_static
 #endif /* !IA64_PARAVIRTUALIZED_ENTRY */
 
 #endif /* _ASM_IA64_PRIVOP_H */
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
index c8a5a0d..0fa8aa6 100644
--- a/include/asm-ia64/xen/privop.h
+++ b/include/asm-ia64/xen/privop.h
@@ -79,6 +79,7 @@
 #define ia64_leave_syscall		xen_leave_syscall
 #define ia64_work_processed_syscall	xen_work_processed_syscall_with_check
 #define ia64_leave_kernel		xen_leave_kernel
+#define ia64_pal_call_static		xen_pal_call_static
 #endif /* !CONFIG_PARAVIRT_ENTRY */
 
 #ifdef CONFIG_XEN
-- 
1.5.3

