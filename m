From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 05 Mar 2008 18:18:53 +0000
Subject: [PATCH 38/50] ia64/xen: paravirtualize pal_call_static().
Message-Id: <12047411461275-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xenpal.S |   76 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 76 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xenpal.S

diff --git a/arch/ia64/xen/xenpal.S b/arch/ia64/xen/xenpal.S
new file mode 100644
index 0000000..0e05210
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
+	BR_IF_NATIVE(native_pal_call_static, r22, p7)
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
-- 
1.5.3

