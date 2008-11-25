From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Tue, 25 Nov 2008 12:57:54 +0000
Subject: [PATCH 12/13] ia64/pv_ops: paravirtualize gate.S.
Message-Id: <1227618131-3755-13-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

paravirtualize gate.S.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/include/asm/native/inst.h       |    5 +++++
 arch/ia64/include/asm/native/pvchk_inst.h |    3 +++
 arch/ia64/kernel/gate.S                   |   17 +++++++++++++----
 3 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/native/inst.h
index ad59fc6..d2d46ef 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -166,6 +166,11 @@
 #define RSM_PSR_DT		\
 	rsm psr.dt
 
+#define RSM_PSR_BE_I(clob0, clob1)	\
+	rsm psr.be | psr.i		\
+	CLOBBER(clob0)			\
+	CLOBBER(clob1)
+
 #define SSM_PSR_DT_AND_SRLZ_I	\
 	ssm psr.dt		\
 	;;			\
diff --git a/arch/ia64/include/asm/native/pvchk_inst.h b/arch/ia64/include/asm/native/pvchk_inst.h
index 13b289e..8d72962 100644
--- a/arch/ia64/include/asm/native/pvchk_inst.h
+++ b/arch/ia64/include/asm/native/pvchk_inst.h
@@ -251,6 +251,9 @@
 	IS_RREG_CLOB(clob2)
 #define RSM_PSR_DT				\
 	nop 0
+#define RSM_PSR_BE_I(clob0, clob1)		\
+	IS_RREG_CLOB(clob0)			\
+	IS_RREG_CLOB(clob1)
 #define SSM_PSR_DT_AND_SRLZ_I			\
 	nop 0
 #define BSW_0(clob0, clob1, clob2)		\
diff --git a/arch/ia64/kernel/gate.S b/arch/ia64/kernel/gate.S
index c957228..cf5e0a1 100644
--- a/arch/ia64/kernel/gate.S
+++ b/arch/ia64/kernel/gate.S
@@ -13,6 +13,7 @@
 #include <asm/sigcontext.h>
 #include <asm/system.h>
 #include <asm/unistd.h>
+#include "paravirt_inst.h"
 
 /*
  * We can't easily refer to symbols inside the kernel.  To avoid full runtime relocation,
@@ -323,7 +324,7 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 	epc					// B	causes split-issue
 }
 	;;
-	rsm psr.be | psr.i			// M2 (5 cyc to srlz.d)
+	RSM_PSR_BE_I(r20, r22)			// M2 (5 cyc to srlz.d)
 	LOAD_FSYSCALL_TABLE(r14)		// X
 	;;
 	mov r16=IA64_KR(CURRENT)		// M2 (12 cyc)
@@ -331,7 +332,7 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 	mov r19=NR_syscalls-1			// A
 	;;
 	lfetch [r18]				// M0|1
-	mov r29=psr				// M2 (12 cyc)
+	MOV_FROM_PSR(p0, r29, r8)		// M2 (12 cyc)
 	// If r17 is a NaT, p6 will be zero
 	cmp.geu p6,p7=r19,r17			// A    (sysnr > 0 && sysnr < 1024+NR_syscalls)?
 	;;
@@ -347,7 +348,7 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 (p6)	tbit.z.unc p8,p0=r18,0			// I0 (dual-issues with "mov b7=r18"!)
 	nop.i 0
 	;;
-(p8)	ssm psr.i
+	SSM_PSR_I(p8, p14, r25)
 (p6)	mov b7=r18				// I0
 (p8)	br.dptk.many b7				// B
 
@@ -368,9 +369,17 @@ GLOBAL_ENTRY(__kernel_syscall_via_epc)
 #else
 	BRL_COND_FSYS_BUBBLE_DOWN(p6)
 #endif
-	ssm psr.i
+	SSM_PSR_I(p0, p14, r10)
 	mov r10=-1
 (p10)	mov r8=EINVAL
 (p9)	mov r8=ENOSYS
 	FSYS_RETURN
+
+#ifdef CONFIG_PARAVIRT
+	/*
+	 * padd to make the size of this symbol constant
+	 * independent of paravirtualization.
+	 */
+	.align PAGE_SIZE / 8
+#endif
 END(__kernel_syscall_via_epc)
-- 
1.6.0.2

