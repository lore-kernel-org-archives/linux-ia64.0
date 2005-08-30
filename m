From: Keith Owens <kaos@sgi.com>
Date: Tue, 30 Aug 2005 05:04:41 +0000
Subject: [PATCH 2.6.13 5/7] MCA/INIT: remove the physical mode path from minstate.h
Message-Id: <20050830050441.7997.17985.sendpatchset@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove the physical mode path from minstate.h.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 minstate.h |   88 ++++++++++++-------------------------------------------------
 1 files changed, 18 insertions(+), 70 deletions(-)

Index: linux/arch/ia64/kernel/minstate.h
=================================--- linux.orig/arch/ia64/kernel/minstate.h	2005-08-17 14:34:38.404220401 +1000
+++ linux/arch/ia64/kernel/minstate.h	2005-08-17 14:36:24.052711993 +1000
@@ -5,73 +5,6 @@
 #include "entry.h"
 
 /*
- * For ivt.s we want to access the stack virtually so we don't have to disable translation
- * on interrupts.
- *
- *  On entry:
- *	r1:	pointer to current task (ar.k6)
- */
-#define MINSTATE_START_SAVE_MIN_VIRT								\
-(pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
-	;;											\
-(pUStk)	mov.m r24=ar.rnat;									\
-(pUStk)	addl r22=IA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
-(pKStk) mov r1=sp;					/* get sp  */				\
-	;;											\
-(pUStk) lfetch.fault.excl.nt1 [r22];								\
-(pUStk)	addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of memory stack */	\
-(pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
-	;;											\
-(pUStk)	mov ar.bspstore=r22;				/* switch to kernel RBS */		\
-(pKStk) addl r1=-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r12) */	\
-	;;											\
-(pUStk)	mov r18=ar.bsp;										\
-(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */
-
-#define MINSTATE_END_SAVE_MIN_VIRT								\
-	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
-	;;
-
-/*
- * For mca_asm.S we want to access the stack physically since the state is saved before we
- * go virtual and don't want to destroy the iip or ipsr.
- */
-#define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKStk) mov r3=IA64_KR(PER_CPU_DATA);;								\
-(pKStk) addl r3=THIS_CPU(ia64_mca_data),r3;;							\
-(pKStk) ld8 r3 = [r3];;										\
-(pKStk) addl r3=IA64_MCA_CPU_INIT_STACK_OFFSET,r3;;						\
-(pKStk) addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
-(pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
-(pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
-	;;											\
-(pUStk)	mov r24=ar.rnat;									\
-(pUStk)	addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of memory stack */	\
-(pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
-(pUStk)	dep r22=-1,r22,61,3;			/* compute kernel virtual addr of RBS */	\
-	;;											\
-(pUStk)	mov ar.bspstore=r22;			/* switch to kernel RBS */			\
-	;;											\
-(pUStk)	mov r18=ar.bsp;										\
-(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */		\
-
-#define MINSTATE_END_SAVE_MIN_PHYS								\
-	dep r12=-1,r12,61,3;		/* make sp a kernel virtual address */			\
-	;;
-
-#ifdef MINSTATE_VIRT
-# define MINSTATE_GET_CURRENT(reg)	mov reg=IA64_KR(CURRENT)
-# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_VIRT
-# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_VIRT
-#endif
-
-#ifdef MINSTATE_PHYS
-# define MINSTATE_GET_CURRENT(reg)	mov reg=IA64_KR(CURRENT);; tpa reg=reg
-# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_PHYS
-# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_PHYS
-#endif
-
-/*
  * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
  * the minimum state necessary that allows us to turn psr.ic back
  * on.
@@ -97,7 +30,7 @@
  * we can pass interruption state as arguments to a handler.
  */
 #define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							\
-	MINSTATE_GET_CURRENT(r16);	/* M (or M;;I) */					\
+	mov r16=IA64_KR(CURRENT);	/* M */							\
 	mov r27=ar.rsc;			/* M */							\
 	mov r20=r1;			/* A */							\
 	mov r25=ar.unat;		/* M */							\
@@ -118,7 +51,21 @@
 	SAVE_IFS;										\
 	cmp.eq pKStk,pUStk=r0,r17;		/* are we in kernel mode already? */		\
 	;;											\
-	MINSTATE_START_SAVE_MIN									\
+(pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
+	;;											\
+(pUStk)	mov.m r24=ar.rnat;									\
+(pUStk)	addl r22=IA64_RBS_OFFSET,r1;			/* compute base of RBS */		\
+(pKStk) mov r1=sp;					/* get sp  */				\
+	;;											\
+(pUStk) lfetch.fault.excl.nt1 [r22];								\
+(pUStk)	addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of memory stack */	\
+(pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
+	;;											\
+(pUStk)	mov ar.bspstore=r22;				/* switch to kernel RBS */		\
+(pKStk) addl r1=-IA64_PT_REGS_SIZE,r1;			/* if in kernel mode, use sp (r12) */	\
+	;;											\
+(pUStk)	mov r18=ar.bsp;										\
+(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */		\
 	adds r17=2*L1_CACHE_BYTES,r1;		/* really: biggest cache-line size */		\
 	adds r16=PT(CR_IPSR),r1;								\
 	;;											\
@@ -181,7 +128,8 @@
 	EXTRA;											\
 	movl r1=__gp;		/* establish kernel global pointer */				\
 	;;											\
-	MINSTATE_END_SAVE_MIN
+	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
+	;;
 
 /*
  * SAVE_REST saves the remainder of pt_regs (with psr.ic on).
