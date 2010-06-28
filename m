From: Christoph Egger <siccegge@cs.fau.de>
Date: Mon, 28 Jun 2010 13:41:13 +0000
Subject: [PATCH 1/2] Removing dead CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
Message-Id: <92987f5365300b0338e414c147e92b80e311d1ae.1277731915.git.siccegge@cs.fau.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1277731915.git.siccegge@cs.fau.de>
In-Reply-To: <cover.1277731915.git.siccegge@cs.fau.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: vamos@i4.informatik.uni-erlangen.de

CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK doesn't exist in Kconfig,
therefore removing all references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 arch/ia64/include/asm/native/inst.h |   96 ++++++++--------------------------
 1 files changed, 23 insertions(+), 73 deletions(-)

diff --git a/arch/ia64/include/asm/native/inst.h b/arch/ia64/include/asm/native/inst.h
index d2d46ef..4800a1e 100644
--- a/arch/ia64/include/asm/native/inst.h
+++ b/arch/ia64/include/asm/native/inst.h
@@ -33,21 +33,6 @@
 #define paravirt_fsyscall_table			ia64_native_fsyscall_table
 #define paravirt_fsys_bubble_down		ia64_native_fsys_bubble_down
 
-#ifdef CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
-# define PARAVIRT_POISON	0xdeadbeefbaadf00d
-# define CLOBBER(clob)				\
-	;;					\
-	movl clob = PARAVIRT_POISON;		\
-	;;
-# define CLOBBER_PRED(pred_clob)		\
-	;;					\
-	cmp.eq pred_clob, p0 = r0, r0		\
-	;;
-#else
-# define CLOBBER(clob)			/* nothing */
-# define CLOBBER_PRED(pred_clob)	/* nothing */
-#endif
-
 #define MOV_FROM_IFA(reg)	\
 	mov reg = cr.ifa
 
@@ -70,106 +55,76 @@
 	mov reg = cr.iip
 
 #define MOV_FROM_IVR(reg, clob)	\
-	mov reg = cr.ivr	\
-	CLOBBER(clob)
+	mov reg = cr.ivr
 
 #define MOV_FROM_PSR(pred, reg, clob)	\
-(pred)	mov reg = psr			\
-	CLOBBER(clob)
+(pred)	mov reg = psr
 
 #define MOV_FROM_ITC(pred, pred_clob, reg, clob)	\
-(pred)	mov reg = ar.itc				\
-	CLOBBER(clob)					\
-	CLOBBER_PRED(pred_clob)
+(pred)	mov reg = ar.itc
 
 #define MOV_TO_IFA(reg, clob)	\
-	mov cr.ifa = reg	\
-	CLOBBER(clob)
+	mov cr.ifa = reg
 
 #define MOV_TO_ITIR(pred, reg, clob)	\
-(pred)	mov cr.itir = reg		\
-	CLOBBER(clob)
+(pred)	mov cr.itir = reg
 
 #define MOV_TO_IHA(pred, reg, clob)	\
-(pred)	mov cr.iha = reg		\
-	CLOBBER(clob)
+(pred)	mov cr.iha = reg
 
 #define MOV_TO_IPSR(pred, reg, clob)		\
-(pred)	mov cr.ipsr = reg			\
-	CLOBBER(clob)
+(pred)	mov cr.ipsr = reg
 
 #define MOV_TO_IFS(pred, reg, clob)	\
-(pred)	mov cr.ifs = reg		\
-	CLOBBER(clob)
+(pred)	mov cr.ifs = reg
 
 #define MOV_TO_IIP(reg, clob)	\
-	mov cr.iip = reg	\
-	CLOBBER(clob)
+	mov cr.iip = reg
 
 #define MOV_TO_KR(kr, reg, clob0, clob1)	\
-	mov IA64_KR(kr) = reg			\
-	CLOBBER(clob0)				\
-	CLOBBER(clob1)
+	mov IA64_KR(kr) = reg
 
 #define ITC_I(pred, reg, clob)	\
-(pred)	itc.i reg		\
-	CLOBBER(clob)
+(pred)	itc.i reg
 
 #define ITC_D(pred, reg, clob)	\
-(pred)	itc.d reg		\
-	CLOBBER(clob)
+(pred)	itc.d reg
 
 #define ITC_I_AND_D(pred_i, pred_d, reg, clob)	\
 (pred_i) itc.i reg;				\
-(pred_d) itc.d reg				\
-	CLOBBER(clob)
+(pred_d) itc.d reg
 
 #define THASH(pred, reg0, reg1, clob)		\
-(pred)	thash reg0 = reg1			\
-	CLOBBER(clob)
+(pred)	thash reg0 = reg1
 
 #define SSM_PSR_IC_AND_DEFAULT_BITS_AND_SRLZ_I(clob0, clob1)		\
-	ssm psr.ic | PSR_DEFAULT_BITS					\
-	CLOBBER(clob0)							\
-	CLOBBER(clob1)							\
+	ssm psr.ic | PSR_DEFAULT_BITS \
 	;;								\
 	srlz.i /* guarantee that interruption collectin is on */	\
 	;;
 
 #define SSM_PSR_IC_AND_SRLZ_D(clob0, clob1)	\
-	ssm psr.ic				\
-	CLOBBER(clob0)				\
-	CLOBBER(clob1)				\
+	ssm psr.ic \
 	;;					\
 	srlz.d
 
 #define RSM_PSR_IC(clob)	\
-	rsm psr.ic		\
-	CLOBBER(clob)
+	rsm psr.ic
 
 #define SSM_PSR_I(pred, pred_clob, clob)	\
-(pred)	ssm psr.i				\
-	CLOBBER(clob)				\
-	CLOBBER_PRED(pred_clob)
+(pred)	ssm psr.i
 
 #define RSM_PSR_I(pred, clob0, clob1)	\
-(pred)	rsm psr.i			\
-	CLOBBER(clob0)			\
-	CLOBBER(clob1)
+(pred)	rsm psr.i
 
 #define RSM_PSR_I_IC(clob0, clob1, clob2)	\
-	rsm psr.i | psr.ic			\
-	CLOBBER(clob0)				\
-	CLOBBER(clob1)				\
-	CLOBBER(clob2)
+	rsm psr.i | psr.ic
 
 #define RSM_PSR_DT		\
 	rsm psr.dt
 
 #define RSM_PSR_BE_I(clob0, clob1)	\
-	rsm psr.be | psr.i		\
-	CLOBBER(clob0)			\
-	CLOBBER(clob1)
+	rsm psr.be | psr.i
 
 #define SSM_PSR_DT_AND_SRLZ_I	\
 	ssm psr.dt		\
@@ -177,15 +132,10 @@
 	srlz.i
 
 #define BSW_0(clob0, clob1, clob2)	\
-	bsw.0				\
-	CLOBBER(clob0)			\
-	CLOBBER(clob1)			\
-	CLOBBER(clob2)
+	bsw.0
 
 #define BSW_1(clob0, clob1)	\
-	bsw.1			\
-	CLOBBER(clob0)		\
-	CLOBBER(clob1)
+	bsw.1
 
 #define COVER	\
 	cover
-- 
1.7.0.4

