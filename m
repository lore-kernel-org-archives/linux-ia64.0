From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 02 Jun 2006 20:46:02 +0000
Subject: [RFC 2/2][2/4] Xen/ia64 added files
Message-Id: <1149281162.5998.113.camel@lappy>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-p7tBmmnWfpnHwP6L2lWG"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--=-p7tBmmnWfpnHwP6L2lWG
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


   New headers...

 arch/ia64/xen/xenminstate.h     |  369 ++++++++++++++++++++++++++++
 include/asm-ia64/fixmap.h       |    2
 include/asm-ia64/hypercall.h    |  511 ++++++++++++++++++++++++++++++++++++++++ include/asm-ia64/hypervisor.h   |  180 ++++++++++++++
 include/asm-ia64/privop.h       |   60 ++++
 include/asm-ia64/synch_bitops.h |   61 ++++
 include/asm-ia64/xen/privop.h   |  280 +++++++++++++++++++++
 7 files changed, 1463 insertions(+)

-- 
Alex Williamson                             HP Open Source & Linux Org.

--=-p7tBmmnWfpnHwP6L2lWG
Content-Disposition: attachment; filename=xen_ia64_adds_2.diff
Content-Type: text/x-patch; name=xen_ia64_adds_2.diff; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff -r 016512c08f6b -r 4489a633a5de arch/ia64/xen/xenminstate.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/arch/ia64/xen/xenminstate.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,369 @@
+#include <linux/config.h>
+
+#include <asm/cache.h>
+
+#ifdef CONFIG_XEN
+#include "../kernel/entry.h"
+#else
+#include "entry.h"
+#endif
+
+/*
+ * For ivt.s we want to access the stack virtually so we don't have to disable translation
+ * on interrupts.
+ *
+ *  On entry:
+ *	r1:	pointer to current task (ar.k6)
+ */
+#define MINSTATE_START_SAVE_MIN_VIRT								\
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
+
+#define MINSTATE_END_SAVE_MIN_VIRT								\
+	bsw.1;			/* switch back to bank 1 (must be last in insn group) */	\
+	;;
+
+/*
+ * For mca_asm.S we want to access the stack physically since the state is saved before we
+ * go virtual and don't want to destroy the iip or ipsr.
+ */
+#define MINSTATE_START_SAVE_MIN_PHYS								\
+(pKStk) mov r3=IA64_KR(PER_CPU_DATA);;								\
+(pKStk) addl r3=THIS_CPU(ia64_mca_data),r3;;							\
+(pKStk) ld8 r3 = [r3];;										\
+(pKStk) addl r3=IA64_MCA_CPU_INIT_STACK_OFFSET,r3;;						\
+(pKStk) addl sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
+(pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
+(pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
+	;;											\
+(pUStk)	mov r24=ar.rnat;									\
+(pUStk)	addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of memory stack */	\
+(pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
+(pUStk)	dep r22=-1,r22,61,3;			/* compute kernel virtual addr of RBS */	\
+	;;											\
+(pKStk) addl r1=-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r12) */		\
+(pUStk)	mov ar.bspstore=r22;			/* switch to kernel RBS */			\
+	;;											\
+(pUStk)	mov r18=ar.bsp;										\
+(pUStk)	mov ar.rsc=0x3;		/* set eager mode, pl 0, little-endian, loadrs=0 */		\
+
+#define MINSTATE_END_SAVE_MIN_PHYS								\
+	dep r12=-1,r12,61,3;		/* make sp a kernel virtual address */			\
+	;;
+
+#ifdef MINSTATE_VIRT
+# define MINSTATE_GET_CURRENT(reg)	mov reg=IA64_KR(CURRENT)
+# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_VIRT
+# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_VIRT
+#endif
+
+#ifdef MINSTATE_PHYS
+# define MINSTATE_GET_CURRENT(reg)	mov reg=IA64_KR(CURRENT);; tpa reg=reg
+# define MINSTATE_START_SAVE_MIN	MINSTATE_START_SAVE_MIN_PHYS
+# define MINSTATE_END_SAVE_MIN		MINSTATE_END_SAVE_MIN_PHYS
+#endif
+
+/*
+ * DO_SAVE_MIN switches to the kernel stacks (if necessary) and saves
+ * the minimum state necessary that allows us to turn psr.ic back
+ * on.
+ *
+ * Assumed state upon entry:
+ *	psr.ic: off
+ *	r31:	contains saved predicates (pr)
+ *
+ * Upon exit, the state is as follows:
+ *	psr.ic: off
+ *	 r2 = points to &pt_regs.r16
+ *	 r8 = contents of ar.ccv
+ *	 r9 = contents of ar.csd
+ *	r10 = contents of ar.ssd
+ *	r11 = FPSR_DEFAULT
+ *	r12 = kernel sp (kernel virtual address)
+ *	r13 = points to current task_struct (kernel virtual address)
+ *	p15 = TRUE if psr.i is set in cr.ipsr
+ *	predicate registers (other than p2, p3, and p15), b6, r3, r14, r15:
+ *		preserved
+ * CONFIG_XEN note: p6/p7 are not preserved
+ *
+ * Note that psr.ic is NOT turned on by this macro.  This is so that
+ * we can pass interruption state as arguments to a handler.
+ */
+#ifdef CONFIG_XEN
+#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							\
+	MINSTATE_GET_CURRENT(r16);	/* M (or M;;I) */					\
+	mov r27=ar.rsc;			/* M */							\
+	mov r20=r1;			/* A */							\
+	mov r25=ar.unat;		/* M */							\
+	/* mov r29=cr.ipsr;		/* M */							\
+	movl r29=XSI_IPSR;;									\
+	ld8 r29=[r29];;										\
+	mov r26=ar.pfs;			/* I */							\
+	/* mov r28=cr.iip;		/* M */							\
+	movl r28=XSI_IIP;;									\
+	ld8 r28=[r28];;										\
+	mov r21=ar.fpsr;		/* M */							\
+	COVER;			/* B;; (or nothing) */					\
+	;;											\
+	adds r16=IA64_TASK_THREAD_ON_USTACK_OFFSET,r16;						\
+	;;											\
+	ld1 r17=[r16];				/* load current->thread.on_ustack flag */	\
+	st1 [r16]=r0;				/* clear current->thread.on_ustack flag */	\
+	adds r1=-IA64_TASK_THREAD_ON_USTACK_OFFSET,r16						\
+	/* switch from user to kernel RBS: */							\
+	;;											\
+	invala;				/* M */							\
+	/* SAVE_IFS; /* see xen special handling below */						\
+	cmp.eq pKStk,pUStk=r0,r17;		/* are we in kernel mode already? */		\
+	;;											\
+	MINSTATE_START_SAVE_MIN									\
+	adds r17=2*L1_CACHE_BYTES,r1;		/* really: biggest cache-line size */		\
+	adds r16=PT(CR_IPSR),r1;								\
+	;;											\
+	lfetch.fault.excl.nt1 [r17],L1_CACHE_BYTES;						\
+	st8 [r16]=r29;		/* save cr.ipsr */						\
+	;;											\
+	lfetch.fault.excl.nt1 [r17];								\
+	tbit.nz p15,p0=r29,IA64_PSR_I_BIT;							\
+	mov r29=b0										\
+	;;											\
+	adds r16=PT(R8),r1;	/* initialize first base pointer */				\
+	adds r17=PT(R9),r1;	/* initialize second base pointer */				\
+(pKStk)	mov r18=r0;		/* make sure r18 isn't NaT */					\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r8,16;								\
+.mem.offset 8,0; st8.spill [r17]=r9,16;								\
+        ;;											\
+.mem.offset 0,0; st8.spill [r16]=r10,24;							\
+.mem.offset 8,0; st8.spill [r17]=r11,24;							\
+        ;;											\
+	/* xen special handling for possibly lazy cover */					\
+	movl r8=XSI_INCOMPL_REGFR;								\
+	;;											\
+	ld4 r30=[r8];										\
+	;;											\
+	/* set XSI_INCOMPL_REGFR 0 */								\
+	st4 [r8]=r0;										\
+	cmp.eq	p6,p7=r30,r0;									\
+	;; /* not sure if this stop bit is necessary */						\
+(p6)	adds r8=XSI_PRECOVER_IFS-XSI_INCOMPL_REGFR,r8;						\
+(p7)	adds r8=XSI_IFS-XSI_INCOMPL_REGFR,r8;							\
+	;;											\
+	ld8 r30=[r8];										\
+	;;											\
+	st8 [r16]=r28,16;	/* save cr.iip */						\
+	st8 [r17]=r30,16;	/* save cr.ifs */						\
+(pUStk)	sub r18=r18,r22;	/* r18=RSE.ndirty*8 */						\
+	mov r8=ar.ccv;										\
+	mov r9=ar.csd;										\
+	mov r10=ar.ssd;										\
+	movl r11=FPSR_DEFAULT;   /* L-unit */							\
+	;;											\
+	st8 [r16]=r25,16;	/* save ar.unat */						\
+	st8 [r17]=r26,16;	/* save ar.pfs */						\
+	shl r18=r18,16;		/* compute ar.rsc to be used for "loadrs" */			\
+	;;											\
+	st8 [r16]=r27,16;	/* save ar.rsc */						\
+(pUStk)	st8 [r17]=r24,16;	/* save ar.rnat */						\
+(pKStk)	adds r17=16,r17;	/* skip over ar_rnat field */					\
+	;;			/* avoid RAW on r16 & r17 */					\
+(pUStk)	st8 [r16]=r23,16;	/* save ar.bspstore */						\
+	st8 [r17]=r31,16;	/* save predicates */						\
+(pKStk)	adds r16=16,r16;	/* skip over ar_bspstore field */				\
+	;;											\
+	st8 [r16]=r29,16;	/* save b0 */							\
+	st8 [r17]=r18,16;	/* save ar.rsc value for "loadrs" */				\
+	cmp.eq pNonSys,pSys=r0,r0	/* initialize pSys=0, pNonSys=1 */			\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r20,16;	/* save original r1 */				\
+.mem.offset 8,0; st8.spill [r17]=r12,16;							\
+	adds r12=-16,r1;	/* switch to kernel memory stack (with 16 bytes of scratch) */	\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r13,16;							\
+.mem.offset 8,0; st8.spill [r17]=r21,16;	/* save ar.fpsr */				\
+	mov r13=IA64_KR(CURRENT);	/* establish `current' */				\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r15,16;							\
+.mem.offset 8,0; st8.spill [r17]=r14,16;							\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r2,16;								\
+.mem.offset 8,0; st8.spill [r17]=r3,16;								\
+	;;											\
+	EXTRA;											\
+	mov r2=b0; br.call.sptk b0=xen_bsw1;; mov b0=r2;					\
+	adds r2=IA64_PT_REGS_R16_OFFSET,r1;							\
+	;;											\
+	movl r1=__gp;		/* establish kernel global pointer */				\
+	;;											\
+	/* MINSTATE_END_SAVE_MIN */
+#else
+#define DO_SAVE_MIN(COVER,SAVE_IFS,EXTRA)							\
+	MINSTATE_GET_CURRENT(r16);	/* M (or M;;I) */					\
+	mov r27=ar.rsc;			/* M */							\
+	mov r20=r1;			/* A */							\
+	mov r25=ar.unat;		/* M */							\
+	mov r29=cr.ipsr;		/* M */							\
+	mov r26=ar.pfs;			/* I */							\
+	mov r28=cr.iip;			/* M */							\
+	mov r21=ar.fpsr;		/* M */							\
+	COVER;				/* B;; (or nothing) */					\
+	;;											\
+	adds r16=IA64_TASK_THREAD_ON_USTACK_OFFSET,r16;						\
+	;;											\
+	ld1 r17=[r16];				/* load current->thread.on_ustack flag */	\
+	st1 [r16]=r0;				/* clear current->thread.on_ustack flag */	\
+	adds r1=-IA64_TASK_THREAD_ON_USTACK_OFFSET,r16						\
+	/* switch from user to kernel RBS: */							\
+	;;											\
+	invala;				/* M */							\
+	SAVE_IFS;										\
+	cmp.eq pKStk,pUStk=r0,r17;		/* are we in kernel mode already? */		\
+	;;											\
+	MINSTATE_START_SAVE_MIN									\
+	adds r17=2*L1_CACHE_BYTES,r1;		/* really: biggest cache-line size */		\
+	adds r16=PT(CR_IPSR),r1;								\
+	;;											\
+	lfetch.fault.excl.nt1 [r17],L1_CACHE_BYTES;						\
+	st8 [r16]=r29;		/* save cr.ipsr */						\
+	;;											\
+	lfetch.fault.excl.nt1 [r17];								\
+	tbit.nz p15,p0=r29,IA64_PSR_I_BIT;							\
+	mov r29=b0										\
+	;;											\
+	adds r16=PT(R8),r1;	/* initialize first base pointer */				\
+	adds r17=PT(R9),r1;	/* initialize second base pointer */				\
+(pKStk)	mov r18=r0;		/* make sure r18 isn't NaT */					\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r8,16;								\
+.mem.offset 8,0; st8.spill [r17]=r9,16;								\
+        ;;											\
+.mem.offset 0,0; st8.spill [r16]=r10,24;							\
+.mem.offset 8,0; st8.spill [r17]=r11,24;							\
+        ;;											\
+	st8 [r16]=r28,16;	/* save cr.iip */						\
+	st8 [r17]=r30,16;	/* save cr.ifs */						\
+(pUStk)	sub r18=r18,r22;	/* r18=RSE.ndirty*8 */						\
+	mov r8=ar.ccv;										\
+	mov r9=ar.csd;										\
+	mov r10=ar.ssd;										\
+	movl r11=FPSR_DEFAULT;   /* L-unit */							\
+	;;											\
+	st8 [r16]=r25,16;	/* save ar.unat */						\
+	st8 [r17]=r26,16;	/* save ar.pfs */						\
+	shl r18=r18,16;		/* compute ar.rsc to be used for "loadrs" */			\
+	;;											\
+	st8 [r16]=r27,16;	/* save ar.rsc */						\
+(pUStk)	st8 [r17]=r24,16;	/* save ar.rnat */						\
+(pKStk)	adds r17=16,r17;	/* skip over ar_rnat field */					\
+	;;			/* avoid RAW on r16 & r17 */					\
+(pUStk)	st8 [r16]=r23,16;	/* save ar.bspstore */						\
+	st8 [r17]=r31,16;	/* save predicates */						\
+(pKStk)	adds r16=16,r16;	/* skip over ar_bspstore field */				\
+	;;											\
+	st8 [r16]=r29,16;	/* save b0 */							\
+	st8 [r17]=r18,16;	/* save ar.rsc value for "loadrs" */				\
+	cmp.eq pNonSys,pSys=r0,r0	/* initialize pSys=0, pNonSys=1 */			\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r20,16;	/* save original r1 */				\
+.mem.offset 8,0; st8.spill [r17]=r12,16;							\
+	adds r12=-16,r1;	/* switch to kernel memory stack (with 16 bytes of scratch) */	\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r13,16;							\
+.mem.offset 8,0; st8.spill [r17]=r21,16;	/* save ar.fpsr */				\
+	mov r13=IA64_KR(CURRENT);	/* establish `current' */				\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r15,16;							\
+.mem.offset 8,0; st8.spill [r17]=r14,16;							\
+	;;											\
+.mem.offset 0,0; st8.spill [r16]=r2,16;								\
+.mem.offset 8,0; st8.spill [r17]=r3,16;								\
+	adds r2=IA64_PT_REGS_R16_OFFSET,r1;							\
+	;;											\
+	EXTRA;											\
+	movl r1=__gp;		/* establish kernel global pointer */				\
+	;;											\
+	MINSTATE_END_SAVE_MIN
+#endif
+
+/*
+ * SAVE_REST saves the remainder of pt_regs (with psr.ic on).
+ *
+ * Assumed state upon entry:
+ *	psr.ic: on
+ *	r2:	points to &pt_regs.r16
+ *	r3:	points to &pt_regs.r17
+ *	r8:	contents of ar.ccv
+ *	r9:	contents of ar.csd
+ *	r10:	contents of ar.ssd
+ *	r11:	FPSR_DEFAULT
+ *
+ * Registers r14 and r15 are guaranteed not to be touched by SAVE_REST.
+ */
+#define SAVE_REST				\
+.mem.offset 0,0; st8.spill [r2]=r16,16;		\
+.mem.offset 8,0; st8.spill [r3]=r17,16;		\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r18,16;		\
+.mem.offset 8,0; st8.spill [r3]=r19,16;		\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r20,16;		\
+.mem.offset 8,0; st8.spill [r3]=r21,16;		\
+	mov r18=b6;				\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r22,16;		\
+.mem.offset 8,0; st8.spill [r3]=r23,16;		\
+	mov r19=b7;				\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r24,16;		\
+.mem.offset 8,0; st8.spill [r3]=r25,16;		\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r26,16;		\
+.mem.offset 8,0; st8.spill [r3]=r27,16;		\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r28,16;		\
+.mem.offset 8,0; st8.spill [r3]=r29,16;		\
+	;;					\
+.mem.offset 0,0; st8.spill [r2]=r30,16;		\
+.mem.offset 8,0; st8.spill [r3]=r31,32;		\
+	;;					\
+	mov ar.fpsr=r11;	/* M-unit */	\
+	st8 [r2]=r8,8;		/* ar.ccv */	\
+	adds r24=PT(B6)-PT(F7),r3;		\
+	;;					\
+	stf.spill [r2]=f6,32;			\
+	stf.spill [r3]=f7,32;			\
+	;;					\
+	stf.spill [r2]=f8,32;			\
+	stf.spill [r3]=f9,32;			\
+	;;					\
+	stf.spill [r2]=f10;			\
+	stf.spill [r3]=f11;			\
+	adds r25=PT(B7)-PT(F11),r3;		\
+	;;					\
+	st8 [r24]=r18,16;       /* b6 */	\
+	st8 [r25]=r19,16;       /* b7 */	\
+	;;					\
+	st8 [r24]=r9;        	/* ar.csd */	\
+	st8 [r25]=r10;      	/* ar.ssd */	\
+	;;
+
+#define SAVE_MIN_WITH_COVER	DO_SAVE_MIN(cover, mov r30=cr.ifs,)
+#define SAVE_MIN_WITH_COVER_R19	DO_SAVE_MIN(cover, mov r30=cr.ifs, mov r15=r19)
+#ifdef CONFIG_XEN
+#define SAVE_MIN		break 0;; /* FIXME: non-cover version only for ia32 support? */
+#else
+#define SAVE_MIN		DO_SAVE_MIN(     , mov r30=r0, )
+#endif
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/fixmap.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/fixmap.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,2 @@
+#define clear_fixmap(x)	do {} while (0)
+#define	set_fixmap(x,y)	do {} while (0)
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/hypercall.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/hypercall.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,511 @@
+/******************************************************************************
+ * hypercall.h
+ * 
+ * Linux-specific hypervisor handling.
+ * 
+ * Copyright (c) 2002-2004, K A Fraser
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ * 
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ * 
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ * 
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __HYPERCALL_H__
+#define __HYPERCALL_H__
+
+#include <linux/err.h>
+#include <asm/xen/privop.h>
+
+#include <linux/string.h> /* memcpy() */
+
+#ifndef __HYPERVISOR_H__
+# error "please don't include this file directly"
+#endif
+
+/*
+ * Assembler stubs for hyper-calls.
+ */
+
+#define _hypercall0(type, name)					\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name)	\
+			      : "r2","r8",			\
+			        "memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall1(type, name, a1)				\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"r" ((unsigned long)(a1))	\
+			      : "r14","r2","r8",		\
+				"memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall2(type, name, a1, a2)				\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r15=%3\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2))	\
+			      : "r14","r15","r2","r8",		\
+				"memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall3(type, name, a1, a2, a3)			\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"                            \
+			      "mov r14=%2\n"                    \
+			      "mov r15=%3\n"                    \
+			      "mov r16=%4\n"                    \
+			      "mov r2=%1\n"                     \
+			      "break 0x1000 ;;\n"               \
+			      "mov %0=r8 ;;\n"                  \
+			      : "=r" (__res)                    \
+			      : "i" (__HYPERVISOR_##name),      \
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2)),	\
+				"r" ((unsigned long)(a3))	\
+			      : "r14","r15","r16","r2","r8",	\
+			        "memory" );                     \
+	(type)__res;                                            \
+})
+
+#define _hypercall4(type, name, a1, a2, a3, a4)			\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"                            \
+			      "mov r14=%2\n"                    \
+			      "mov r15=%3\n"                    \
+			      "mov r16=%4\n"                    \
+			      "mov r17=%5\n"                    \
+			      "mov r2=%1\n"                     \
+			      "break 0x1000 ;;\n"               \
+			      "mov %0=r8 ;;\n"                  \
+			      : "=r" (__res)                    \
+			      : "i" (__HYPERVISOR_##name),      \
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2)),	\
+				"r" ((unsigned long)(a3)),	\
+				"r" ((unsigned long)(a4))       \
+			      : "r14","r15","r16","r2","r8",	\
+			        "r17","memory" );               \
+	(type)__res;                                            \
+})
+
+#define _hypercall5(type, name, a1, a2, a3, a4, a5)		\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"                            \
+			      "mov r14=%2\n"                    \
+			      "mov r15=%3\n"                    \
+			      "mov r16=%4\n"                    \
+			      "mov r17=%5\n"                    \
+			      "mov r18=%6\n"                    \
+			      "mov r2=%1\n"                     \
+			      "break 0x1000 ;;\n"               \
+			      "mov %0=r8 ;;\n"                  \
+			      : "=r" (__res)                    \
+			      : "i" (__HYPERVISOR_##name),      \
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2)),	\
+				"r" ((unsigned long)(a3)),	\
+				"r" ((unsigned long)(a4)),	\
+				"r" ((unsigned long)(a5))       \
+			      : "r14","r15","r16","r2","r8",	\
+			        "r17","r18","memory" );         \
+	(type)__res;                                            \
+})
+
+static inline int
+HYPERVISOR_sched_op_compat(
+    int cmd, unsigned long arg)
+{
+	return _hypercall2(int, sched_op_compat, cmd, arg);
+}
+
+static inline int
+HYPERVISOR_sched_op(
+	int cmd, void *arg)
+{
+	return _hypercall2(int, sched_op, cmd, arg);
+}
+
+static inline long
+HYPERVISOR_set_timer_op(
+    u64 timeout)
+{
+    unsigned long timeout_hi = (unsigned long)(timeout>>32);
+    unsigned long timeout_lo = (unsigned long)timeout;
+    return _hypercall2(long, set_timer_op, timeout_lo, timeout_hi);
+}
+
+static inline int
+HYPERVISOR_dom0_op(
+    dom0_op_t *dom0_op)
+{
+    dom0_op->interface_version = DOM0_INTERFACE_VERSION;
+    return _hypercall1(int, dom0_op, dom0_op);
+}
+
+static inline int
+HYPERVISOR_multicall(
+    void *call_list, int nr_calls)
+{
+    return _hypercall2(int, multicall, call_list, nr_calls);
+}
+
+//XXX xen/ia64 copy_from_guest() is broken.
+//    This is a temporal work around until it is fixed.
+static inline int
+____HYPERVISOR_memory_op(
+    unsigned int cmd, void *arg)
+{
+    return _hypercall2(int, memory_op, cmd, arg);
+}
+
+#include <xen/interface/memory.h>
+int ia64_xenmem_reservation_op(unsigned long op,
+		   struct xen_memory_reservation* reservation__);
+static inline int
+HYPERVISOR_memory_op(
+    unsigned int cmd, void *arg)
+{
+    switch (cmd) {
+    case XENMEM_increase_reservation:
+    case XENMEM_decrease_reservation:
+    case XENMEM_populate_physmap:
+        return ia64_xenmem_reservation_op(cmd, 
+                                          (struct xen_memory_reservation*)arg);
+    default:
+        return ____HYPERVISOR_memory_op(cmd, arg);
+    }
+    /* NOTREACHED */
+}
+
+static inline int
+HYPERVISOR_event_channel_op(
+    int cmd, void *arg)
+{
+    int rc = _hypercall2(int, event_channel_op, cmd, arg);
+    if (unlikely(rc == -ENOSYS)) {
+        struct evtchn_op op;
+        op.cmd = cmd;
+        memcpy(&op.u, arg, sizeof(op.u));
+        rc = _hypercall1(int, event_channel_op_compat, &op);
+    }
+    return rc;
+}
+
+static inline int
+HYPERVISOR_acm_op(
+	unsigned int cmd, void *arg)
+{
+    return _hypercall2(int, acm_op, cmd, arg);
+}
+
+static inline int
+HYPERVISOR_xen_version(
+    int cmd, void *arg)
+{
+    return _hypercall2(int, xen_version, cmd, arg);
+}
+
+static inline int
+HYPERVISOR_console_io(
+    int cmd, int count, char *str)
+{
+    return _hypercall3(int, console_io, cmd, count, str);
+}
+
+static inline int
+HYPERVISOR_physdev_op(
+    int cmd, void *arg)
+{
+    int rc = _hypercall2(int, physdev_op, cmd, arg);
+    if (unlikely(rc == -ENOSYS)) {
+        struct physdev_op op;
+        op.cmd = cmd;
+        memcpy(&op.u, arg, sizeof(op.u));
+        rc = _hypercall1(int, physdev_op_compat, &op);
+    }
+    return rc;
+}
+
+//XXX __HYPERVISOR_grant_table_op is used for this hypercall constant.
+static inline int
+____HYPERVISOR_grant_table_op(
+    unsigned int cmd, void *uop, unsigned int count)
+{
+    return _hypercall3(int, grant_table_op, cmd, uop, count);
+}
+int HYPERVISOR_grant_table_op(unsigned int cmd, void *uop, unsigned int count);
+
+static inline int
+HYPERVISOR_vcpu_op(
+	int cmd, int vcpuid, void *extra_args)
+{
+    return _hypercall3(int, vcpu_op, cmd, vcpuid, extra_args);
+}
+
+static inline int
+HYPERVISOR_suspend(
+	unsigned long srec)
+{
+	struct sched_shutdown sched_shutdown = {
+		.reason = SHUTDOWN_suspend
+	};
+
+	int rc = _hypercall3(int, sched_op, SCHEDOP_shutdown,
+			     &sched_shutdown, srec);
+
+	if (rc == -ENOSYS)
+		rc = _hypercall3(int, sched_op_compat, SCHEDOP_shutdown,
+				 SHUTDOWN_suspend, srec);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_callback_op(
+	int cmd, void *arg)
+{
+	return _hypercall2(int, callback_op, cmd, arg);
+}
+
+extern fastcall unsigned int __do_IRQ(unsigned int irq, struct pt_regs *regs);
+static inline void exit_idle(void) {}
+#define do_IRQ(irq, regs) ({			\
+	irq_enter();				\
+	__do_IRQ((irq), (regs));		\
+	irq_exit();				\
+})
+
+#define _hypercall_imm1(type, name, imm, a1)			\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r15=%3\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"i" (imm),			\
+				"r" ((unsigned long)(a1))	\
+			      : "r14","r15","r2","r8",		\
+				"memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall_imm2(type, name, imm, a1, a2)		\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r15=%3\n"			\
+			      "mov r16=%4\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"i" (imm),			\
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2))	\
+			      : "r14","r15","r16","r2","r8",	\
+				"memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall_imm3(type, name, imm, a1, a2, a3)		\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r15=%3\n"			\
+			      "mov r16=%4\n"			\
+			      "mov r17=%5\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"i" (imm),			\
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2)),	\
+				"r" ((unsigned long)(a3))	\
+			      : "r14","r15","r16","r17",	\
+				"r2","r8",			\
+				"memory" );			\
+	(type)__res;						\
+})
+
+#define _hypercall_imm4(type, name, imm, a1, a2, a3, a4)	\
+({								\
+	long __res;						\
+	__asm__ __volatile__ (";;\n"				\
+			      "mov r14=%2\n"			\
+			      "mov r15=%3\n"			\
+			      "mov r16=%4\n"			\
+			      "mov r17=%5\n"			\
+			      "mov r18=%6\n"			\
+			      "mov r2=%1\n"			\
+			      "break 0x1000 ;;\n"		\
+			      "mov %0=r8 ;;\n"			\
+			      : "=r" (__res)			\
+			      : "i" (__HYPERVISOR_##name),	\
+				"i" (imm),			\
+				"r" ((unsigned long)(a1)),	\
+				"r" ((unsigned long)(a2)),	\
+				"r" ((unsigned long)(a3)),	\
+				"r" ((unsigned long)(a4))	\
+			      : "r14","r15","r16","r17","r18",	\
+				"r2","r8",			\
+				"memory" );			\
+	(type)__res;						\
+})
+
+static inline unsigned long
+__HYPERVISOR_ioremap(unsigned long ioaddr, unsigned long size)
+{
+	return _hypercall_imm2(unsigned long, ia64_dom0vp_op,
+			       IA64_DOM0VP_ioremap, ioaddr, size);
+}
+
+static inline unsigned long
+HYPERVISOR_ioremap(unsigned long ioaddr, unsigned long size)
+{
+	unsigned long ret = ioaddr;
+	if (is_running_on_xen()) {
+		ret = __HYPERVISOR_ioremap(ioaddr, size);
+		if (unlikely(ret == -ENOSYS))
+			panic("hypercall %s failed with %ld. "
+			      "Please check Xen and Linux config mismatch\n",
+			      __func__, -ret);
+		else if (unlikely(IS_ERR_VALUE(ret)))
+			ret = ioaddr;
+	}
+	return ret;
+}
+
+static inline unsigned long
+__HYPERVISOR_phystomach(unsigned long gpfn)
+{
+	return _hypercall_imm1(unsigned long, ia64_dom0vp_op,
+			       IA64_DOM0VP_phystomach, gpfn);
+}
+
+static inline unsigned long
+HYPERVISOR_phystomach(unsigned long gpfn)
+{
+	unsigned long ret = gpfn;
+	if (is_running_on_xen()) {
+		ret = __HYPERVISOR_phystomach(gpfn);
+	}
+	return ret;
+}
+
+static inline unsigned long
+__HYPERVISOR_machtophys(unsigned long mfn)
+{
+	return _hypercall_imm1(unsigned long, ia64_dom0vp_op,
+			       IA64_DOM0VP_machtophys, mfn);
+}
+
+static inline unsigned long
+HYPERVISOR_machtophys(unsigned long mfn)
+{
+	unsigned long ret = mfn;
+	if (is_running_on_xen()) {
+		ret = __HYPERVISOR_machtophys(mfn);
+	}
+	return ret;
+}
+
+static inline unsigned long
+__HYPERVISOR_zap_physmap(unsigned long gpfn, unsigned int extent_order)
+{
+	return _hypercall_imm2(unsigned long, ia64_dom0vp_op,
+			       IA64_DOM0VP_zap_physmap, gpfn, extent_order);
+}
+
+static inline unsigned long
+HYPERVISOR_zap_physmap(unsigned long gpfn, unsigned int extent_order)
+{
+	unsigned long ret = 0;
+	if (is_running_on_xen()) {
+		ret = __HYPERVISOR_zap_physmap(gpfn, extent_order);
+	}
+	return ret;
+}
+
+static inline unsigned long
+__HYPERVISOR_add_physmap(unsigned long gpfn, unsigned long mfn,
+			 unsigned long flags, domid_t domid)
+{
+	return _hypercall_imm4(unsigned long, ia64_dom0vp_op,
+			       IA64_DOM0VP_add_physmap, gpfn, mfn, flags,
+			       domid);
+}
+
+static inline unsigned long
+HYPERVISOR_add_physmap(unsigned long gpfn, unsigned long mfn,
+		       unsigned long flags, domid_t domid)
+{
+	unsigned long ret = 0;
+	BUG_ON(!is_running_on_xen());//XXX
+	if (is_running_on_xen()) {
+		ret = __HYPERVISOR_add_physmap(gpfn, mfn, flags, domid);
+	}
+	return ret;
+}
+
+// for balloon driver
+#define HYPERVISOR_update_va_mapping(va, new_val, flags) (0)
+
+#endif /* __HYPERCALL_H__ */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/hypervisor.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/hypervisor.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,180 @@
+/******************************************************************************
+ * hypervisor.h
+ * 
+ * Linux-specific hypervisor handling.
+ * 
+ * Copyright (c) 2002-2004, K A Fraser
+ * 
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation; or, when distributed
+ * separately from the Linux kernel or incorporated into other
+ * software packages, subject to the following license:
+ * 
+ * Permission is hereby granted, free of charge, to any person obtaining a copy
+ * of this source file (the "Software"), to deal in the Software without
+ * restriction, including without limitation the rights to use, copy, modify,
+ * merge, publish, distribute, sublicense, and/or sell copies of the Software,
+ * and to permit persons to whom the Software is furnished to do so, subject to
+ * the following conditions:
+ * 
+ * The above copyright notice and this permission notice shall be included in
+ * all copies or substantial portions of the Software.
+ * 
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
+ * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
+ * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
+ * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
+ * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
+ * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
+ * IN THE SOFTWARE.
+ */
+
+#ifndef __HYPERVISOR_H__
+#define __HYPERVISOR_H__
+
+#include <linux/config.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/version.h>
+#include <linux/errno.h>
+#include <xen/interface/xen.h>
+#include <xen/interface/dom0_ops.h>
+#include <xen/interface/event_channel.h>
+#include <xen/interface/physdev.h>
+#include <xen/interface/sched.h>
+#include <asm/hypercall.h>
+#include <asm/ptrace.h>
+#include <asm/page.h>
+#include <asm/xen/privop.h> // for is_running_on_xen()
+
+extern shared_info_t *HYPERVISOR_shared_info;
+extern start_info_t *xen_start_info;
+
+void force_evtchn_callback(void);
+
+/* Turn jiffies into Xen system time. XXX Implement me. */
+#define jiffies_to_st(j)	0
+
+static inline int
+HYPERVISOR_yield(
+	void)
+{
+	int rc = HYPERVISOR_sched_op(SCHEDOP_yield, NULL);
+
+	if (rc == -ENOSYS)
+		rc = HYPERVISOR_sched_op_compat(SCHEDOP_yield, 0);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_block(
+	void)
+{
+	int rc = HYPERVISOR_sched_op(SCHEDOP_block, NULL);
+
+	if (rc == -ENOSYS)
+		rc = HYPERVISOR_sched_op_compat(SCHEDOP_block, 0);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_shutdown(
+	unsigned int reason)
+{
+	struct sched_shutdown sched_shutdown = {
+		.reason = reason
+	};
+
+	int rc = HYPERVISOR_sched_op(SCHEDOP_shutdown, &sched_shutdown);
+
+	if (rc == -ENOSYS)
+		rc = HYPERVISOR_sched_op_compat(SCHEDOP_shutdown, reason);
+
+	return rc;
+}
+
+static inline int
+HYPERVISOR_poll(
+	evtchn_port_t *ports, unsigned int nr_ports, u64 timeout)
+{
+	struct sched_poll sched_poll = {
+		.nr_ports = nr_ports,
+		.timeout = jiffies_to_st(timeout)
+	};
+
+	int rc;
+
+	set_xen_guest_handle(sched_poll.ports, ports);
+	rc = HYPERVISOR_sched_op(SCHEDOP_poll, &sched_poll);
+	if (rc == -ENOSYS)
+		rc = HYPERVISOR_sched_op_compat(SCHEDOP_yield, 0);
+
+	return rc;
+}
+
+// for drivers/xen/privcmd/privcmd.c
+#define machine_to_phys_mapping 0
+struct vm_area_struct;
+int direct_remap_pfn_range(struct vm_area_struct *vma,
+			   unsigned long address,
+			   unsigned long mfn,
+			   unsigned long size,
+			   pgprot_t prot,
+			   domid_t  domid);
+struct file;
+int privcmd_mmap(struct file * file, struct vm_area_struct * vma);
+#define HAVE_ARCH_PRIVCMD_MMAP
+
+// for drivers/xen/balloon/balloon.c
+#ifdef CONFIG_XEN_SCRUB_PAGES
+#define scrub_pages(_p,_n) memset((void *)(_p), 0, (_n) << PAGE_SHIFT)
+#else
+#define scrub_pages(_p,_n) ((void)0)
+#endif
+#define	pte_mfn(_x)	pte_pfn(_x)
+#define __pte_ma(_x)	((pte_t) {(_x)})
+#define phys_to_machine_mapping_valid(_x)	(1)
+#define pfn_pte_ma(_x,_y)	__pte_ma(0)
+
+int __xen_create_contiguous_region(unsigned long vstart, unsigned int order, unsigned int address_bits);
+static inline int
+xen_create_contiguous_region(unsigned long vstart,
+                             unsigned int order, unsigned int address_bits)
+{
+	int ret = 0;
+	if (is_running_on_xen()) {
+		ret = __xen_create_contiguous_region(vstart, order,
+		                                     address_bits);
+	}
+	return ret;
+}
+
+void __xen_destroy_contiguous_region(unsigned long vstart, unsigned int order);
+static inline void
+xen_destroy_contiguous_region(unsigned long vstart, unsigned int order)
+{
+	if (is_running_on_xen())
+		__xen_destroy_contiguous_region(vstart, order);
+}
+
+// for netfront.c, netback.c
+#define MULTI_UVMFLAGS_INDEX 0 //XXX any value
+
+static inline void
+MULTI_update_va_mapping(
+	multicall_entry_t *mcl, unsigned long va,
+	pte_t new_val, unsigned long flags)
+{
+	mcl->op = __HYPERVISOR_update_va_mapping;
+	mcl->result = 0;
+}
+
+// for debug
+asmlinkage int xprintk(const char *fmt, ...);
+#define xprintd(fmt, ...)	xprintk("%s:%d " fmt, __func__, __LINE__, \
+					##__VA_ARGS__)
+
+#endif /* __HYPERVISOR_H__ */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/privop.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/privop.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,60 @@
+#ifndef _ASM_IA64_PRIVOP_H
+#define _ASM_IA64_PRIVOP_H
+
+/*
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *
+ */
+
+#include <linux/config.h>
+#ifdef CONFIG_XEN
+#include <asm/xen/privop.h>
+#endif
+
+#ifndef __ASSEMBLY
+
+#ifndef IA64_PARAVIRTUALIZED
+
+#define ia64_getreg			__ia64_getreg
+#define ia64_setreg			__ia64_setreg
+#define ia64_hint			__ia64_hint
+#define ia64_thash			__ia64_thash
+#define ia64_itci			__ia64_itci
+#define ia64_itcd			__ia64_itcd
+#define ia64_itri			__ia64_itri
+#define ia64_itrd			__ia64_itrd
+#define ia64_tpa			__ia64_tpa
+#define ia64_set_ibr			__ia64_set_ibr
+#define ia64_set_pkr			__ia64_set_pkr
+#define ia64_set_pmc			__ia64_set_pmc
+#define ia64_set_pmd			__ia64_set_pmd
+#define ia64_set_rr			__ia64_set_rr
+#define ia64_get_cpuid			__ia64_get_cpuid
+#define ia64_get_ibr			__ia64_get_ibr
+#define ia64_get_pkr			__ia64_get_pkr
+#define ia64_get_pmc			__ia64_get_pmc
+#define ia64_get_pmd			__ia64_get_pmd
+#define ia64_get_rr			__ia64_get_rr
+#define ia64_fc				__ia64_fc
+#define ia64_ssm			__ia64_ssm
+#define ia64_rsm			__ia64_rsm
+#define ia64_ptce			__ia64_ptce
+#define ia64_ptcga			__ia64_ptcga
+#define ia64_ptcl			__ia64_ptcl
+#define ia64_ptri			__ia64_ptri
+#define ia64_ptrd			__ia64_ptrd
+#define ia64_get_psr_i			__ia64_get_psr_i
+#define ia64_intrin_local_irq_restore	__ia64_intrin_local_irq_restore
+#define ia64_pal_halt_light		__ia64_pal_halt_light
+#define ia64_leave_kernel		__ia64_leave_kernel
+#define ia64_leave_syscall		__ia64_leave_syscall
+#define ia64_trace_syscall		__ia64_trace_syscall
+#define ia64_switch_to			__ia64_switch_to
+#define ia64_pal_call_static		__ia64_pal_call_static
+
+#endif /* !IA64_PARAVIRTUALIZED */
+
+#endif /* !__ASSEMBLY */
+
+#endif /* _ASM_IA64_PRIVOP_H */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/synch_bitops.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/synch_bitops.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,61 @@
+#ifndef __XEN_SYNCH_BITOPS_H__
+#define __XEN_SYNCH_BITOPS_H__
+
+/*
+ * Copyright 1992, Linus Torvalds.
+ * Heavily modified to provide guaranteed strong synchronisation
+ * when communicating with Xen or other guest OSes running on other CPUs.
+ */
+
+#include <linux/config.h>
+
+#define ADDR (*(volatile long *) addr)
+
+static __inline__ void synch_set_bit(int nr, volatile void * addr)
+{
+	set_bit(nr, addr);
+}
+
+static __inline__ void synch_clear_bit(int nr, volatile void * addr)
+{
+	clear_bit(nr, addr);
+}
+
+static __inline__ void synch_change_bit(int nr, volatile void * addr)
+{
+	change_bit(nr, addr);
+}
+
+static __inline__ int synch_test_and_set_bit(int nr, volatile void * addr)
+{
+    return test_and_set_bit(nr, addr);
+}
+
+static __inline__ int synch_test_and_clear_bit(int nr, volatile void * addr)
+{
+    return test_and_clear_bit(nr, addr);
+}
+
+static __inline__ int synch_test_and_change_bit(int nr, volatile void * addr)
+{
+    return test_and_change_bit(nr, addr);
+}
+
+static __inline__ int synch_const_test_bit(int nr, const volatile void * addr)
+{
+    return test_bit(nr, addr);
+}
+
+static __inline__ int synch_var_test_bit(int nr, volatile void * addr)
+{
+    return test_bit(nr, addr);
+}
+
+#define synch_cmpxchg	ia64_cmpxchg4_acq
+
+#define synch_test_bit(nr,addr) \
+(__builtin_constant_p(nr) ? \
+ synch_const_test_bit((nr),(addr)) : \
+ synch_var_test_bit((nr),(addr)))
+
+#endif /* __XEN_SYNCH_BITOPS_H__ */
diff -r 016512c08f6b -r 4489a633a5de include/asm-ia64/xen/privop.h
--- /dev/null	Thu Jan 01 00:00:00 1970 +0000
+++ b/include/asm-ia64/xen/privop.h	Fri Jun 02 09:54:29 2006 -0600
@@ -0,0 +1,280 @@
+#ifndef _ASM_IA64_XEN_PRIVOP_H
+#define _ASM_IA64_XEN_PRIVOP_H
+
+/*
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@hp.com>
+ *
+ * Paravirtualizations of privileged operations for Xen/ia64
+ *
+ */
+
+
+#include <asm/xen/asm-xsi-offsets.h>
+#include <xen/interface/arch-ia64.h>
+
+#define IA64_PARAVIRTUALIZED
+
+#ifdef __ASSEMBLY__
+#define	XEN_HYPER_RFI			break HYPERPRIVOP_RFI
+#define	XEN_HYPER_RSM_PSR_DT		break HYPERPRIVOP_RSM_DT
+#define	XEN_HYPER_SSM_PSR_DT		break HYPERPRIVOP_SSM_DT
+#define	XEN_HYPER_COVER			break HYPERPRIVOP_COVER
+#define	XEN_HYPER_ITC_D			break HYPERPRIVOP_ITC_D
+#define	XEN_HYPER_ITC_I			break HYPERPRIVOP_ITC_I
+#define	XEN_HYPER_SSM_I			break HYPERPRIVOP_SSM_I
+#define	XEN_HYPER_GET_IVR		break HYPERPRIVOP_GET_IVR
+#define	XEN_HYPER_GET_TPR		break HYPERPRIVOP_GET_TPR
+#define	XEN_HYPER_SET_TPR		break HYPERPRIVOP_SET_TPR
+#define	XEN_HYPER_EOI			break HYPERPRIVOP_EOI
+#define	XEN_HYPER_SET_ITM		break HYPERPRIVOP_SET_ITM
+#define	XEN_HYPER_THASH			break HYPERPRIVOP_THASH
+#define	XEN_HYPER_PTC_GA		break HYPERPRIVOP_PTC_GA
+#define	XEN_HYPER_ITR_D			break HYPERPRIVOP_ITR_D
+#define	XEN_HYPER_GET_RR		break HYPERPRIVOP_GET_RR
+#define	XEN_HYPER_SET_RR		break HYPERPRIVOP_SET_RR
+#define	XEN_HYPER_SET_KR		break HYPERPRIVOP_SET_KR
+#define	XEN_HYPER_FC			break HYPERPRIVOP_FC
+#define	XEN_HYPER_GET_CPUID		break HYPERPRIVOP_GET_CPUID
+#define	XEN_HYPER_GET_PMD		break HYPERPRIVOP_GET_PMD
+#define	XEN_HYPER_GET_EFLAG		break HYPERPRIVOP_GET_EFLAG
+#define	XEN_HYPER_SET_EFLAG		break HYPERPRIVOP_SET_EFLAG
+#endif
+
+#ifndef __ASSEMBLY__
+extern int running_on_xen;
+#define is_running_on_xen() running_on_xen
+
+#define	XEN_HYPER_SSM_I		asm("break %0" : : "i" (HYPERPRIVOP_SSM_I))
+#define	XEN_HYPER_GET_IVR	asm("break %0" : : "i" (HYPERPRIVOP_GET_IVR))
+
+/************************************************/
+/* Instructions paravirtualized for correctness */
+/************************************************/
+
+/* "fc" and "thash" are privilege-sensitive instructions, meaning they
+ *  may have different semantics depending on whether they are executed
+ *  at PL0 vs PL!=0.  When paravirtualized, these instructions mustn't
+ *  be allowed to execute directly, lest incorrect semantics result. */
+extern unsigned long xen_fc(unsigned long addr);
+#define ia64_fc(addr)			xen_fc((unsigned long)(addr))
+extern unsigned long xen_thash(unsigned long addr);
+#define ia64_thash(addr)		xen_thash((unsigned long)(addr))
+/* Note that "ttag" and "cover" are also privilege-sensitive; "ttag"
+ * is not currently used (though it may be in a long-format VHPT system!)
+ * and the semantics of cover only change if psr.ic is off which is very
+ * rare (and currently non-existent outside of assembly code */
+
+/* There are also privilege-sensitive registers.  These registers are
+ * readable at any privilege level but only writable at PL0. */
+extern unsigned long xen_get_cpuid(int index);
+#define	ia64_get_cpuid(i)		xen_get_cpuid(i)
+extern unsigned long xen_get_pmd(int index);
+#define	ia64_get_pmd(i)			xen_get_pmd(i)
+extern unsigned long xen_get_eflag(void);	/* see xen_ia64_getreg */
+extern void xen_set_eflag(unsigned long);	/* see xen_ia64_setreg */
+
+/************************************************/
+/* Instructions paravirtualized for performance */
+/************************************************/
+
+/* Xen uses memory-mapped virtual privileged registers for access to many
+ * performance-sensitive privileged registers.  Some, like the processor
+ * status register (psr), are broken up into multiple memory locations.
+ * Others, like "pend", are abstractions based on privileged registers.
+ * "Pend" is guaranteed to be set if reading cr.ivr would return a
+ * (non-spurious) interrupt. */
+#define XSI_PSR_I			\
+	(*(uint64_t *)(XSI_PSR_I_ADDR))
+#define xen_get_virtual_psr_i()		\
+	(!(*(uint8_t *)(XSI_PSR_I)))
+#define xen_set_virtual_psr_i(_val)	\
+	({ *(uint8_t *)(XSI_PSR_I) = (uint8_t)(_val) ? 0:1; })
+#define xen_set_virtual_psr_ic(_val)	\
+	({ *(int *)(XSI_PSR_IC) = _val ? 1:0; })
+#define xen_get_virtual_pend()		(*(int *)(XSI_PEND))
+
+/* Hyperprivops are "break" instructions with a well-defined API.
+ * In particular, the virtual psr.ic bit must be off; in this way
+ * it is guaranteed to never conflict with a linux break instruction.
+ * Normally, this is done in a xen stub but this one is frequent enough
+ * that we inline it */
+#define xen_hyper_ssm_i()						\
+({									\
+	xen_set_virtual_psr_i(0);					\
+	xen_set_virtual_psr_ic(0);					\
+	XEN_HYPER_SSM_I;						\
+})
+
+/* turning off interrupts can be paravirtualized simply by writing
+ * to a memory-mapped virtual psr.i bit (implemented as a 16-bit bool) */
+#define xen_rsm_i()	xen_set_virtual_psr_i(0)
+
+/* turning on interrupts is a bit more complicated.. write to the
+ * memory-mapped virtual psr.i bit first (to avoid race condition),
+ * then if any interrupts were pending, we have to execute a hyperprivop
+ * to ensure the pending interrupt gets delivered; else we're done! */
+#define xen_ssm_i()							\
+({									\
+	int old = xen_get_virtual_psr_i();				\
+	xen_set_virtual_psr_i(1);					\
+	if (!old && xen_get_virtual_pend()) xen_hyper_ssm_i();		\
+})
+
+#define xen_ia64_intrin_local_irq_restore(x)				\
+{									\
+     if (is_running_on_xen()) {						\
+	if ((x) & IA64_PSR_I) { xen_ssm_i(); }				\
+	else { xen_rsm_i(); }						\
+    }									\
+    else __ia64_intrin_local_irq_restore((x));				\
+}
+
+#define	xen_get_psr_i()							\
+(									\
+	(is_running_on_xen()) ?						\
+		(xen_get_virtual_psr_i() ? IA64_PSR_I : 0)		\
+		: __ia64_get_psr_i()					\
+)
+
+#define xen_ia64_ssm(mask)						\
+{									\
+	if ((mask)==IA64_PSR_I) {					\
+		if (is_running_on_xen()) { xen_ssm_i(); }			\
+		else { __ia64_ssm(mask); }				\
+	}								\
+	else { __ia64_ssm(mask); }					\
+}
+
+#define xen_ia64_rsm(mask)						\
+{									\
+	if ((mask)==IA64_PSR_I) {					\
+		if (is_running_on_xen()) { xen_rsm_i(); }			\
+		else { __ia64_rsm(mask); }				\
+	}								\
+	else { __ia64_rsm(mask); }					\
+}
+
+
+/* Although all privileged operations can be left to trap and will
+ * be properly handled by Xen, some are frequent enough that we use
+ * hyperprivops for performance. */
+
+extern unsigned long xen_get_ivr(void);
+extern unsigned long xen_get_tpr(void);
+extern void xen_set_itm(unsigned long);
+extern void xen_set_tpr(unsigned long);
+extern void xen_eoi(void);
+extern void xen_set_rr(unsigned long index, unsigned long val);
+extern unsigned long xen_get_rr(unsigned long index);
+extern void xen_set_kr(unsigned long index, unsigned long val);
+extern void xen_ptcga(unsigned long addr, unsigned long size);
+
+/* Note: It may look wrong to test for is_running_on_xen() in each case.
+ * However regnum is always a constant so, as written, the compiler
+ * eliminates the switch statement, whereas is_running_on_xen() must be
+ * tested dynamically. */
+#define xen_ia64_getreg(regnum)						\
+({									\
+	__u64 ia64_intri_res;						\
+									\
+	switch(regnum) {						\
+	case _IA64_REG_CR_IVR:						\
+		ia64_intri_res = (is_running_on_xen()) ?			\
+			xen_get_ivr() :					\
+			__ia64_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		ia64_intri_res = (is_running_on_xen()) ?			\
+			xen_get_tpr() :					\
+			__ia64_getreg(regnum);				\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		ia64_intri_res = (is_running_on_xen()) ?			\
+			xen_get_eflag() :				\
+			__ia64_getreg(regnum);				\
+		break;							\
+	default:							\
+		ia64_intri_res = __ia64_getreg(regnum);			\
+		break;							\
+	}								\
+	ia64_intri_res;							\
+})
+
+#define xen_ia64_setreg(regnum,val)					\
+({									\
+	switch(regnum) {						\
+	case _IA64_REG_AR_KR0 ... _IA64_REG_AR_KR7:			\
+		(is_running_on_xen()) ?					\
+			xen_set_kr((regnum-_IA64_REG_AR_KR0), val) :	\
+			__ia64_setreg(regnum,val);			\
+		break;							\
+	case _IA64_REG_CR_ITM:						\
+		(is_running_on_xen()) ?					\
+			xen_set_itm(val) :				\
+			__ia64_setreg(regnum,val);			\
+		break;							\
+	case _IA64_REG_CR_TPR:						\
+		(is_running_on_xen()) ?					\
+			xen_set_tpr(val) :				\
+			__ia64_setreg(regnum,val);			\
+		break;							\
+	case _IA64_REG_CR_EOI:						\
+		(is_running_on_xen()) ?					\
+			xen_eoi() :					\
+			__ia64_setreg(regnum,val);			\
+		break;							\
+	case _IA64_REG_AR_EFLAG:					\
+		(is_running_on_xen()) ?					\
+			xen_set_eflag(val) :				\
+			__ia64_setreg(regnum,val);			\
+		break;							\
+	default:							\
+		__ia64_setreg(regnum,val);				\
+		break;							\
+	}								\
+})
+
+#define ia64_ssm			xen_ia64_ssm
+#define ia64_rsm			xen_ia64_rsm
+#define ia64_intrin_local_irq_restore	xen_ia64_intrin_local_irq_restore
+#define	ia64_ptcga			xen_ptcga
+#define	ia64_set_rr(index,val)		xen_set_rr(index,val)
+#define	ia64_get_rr(index)		xen_get_rr(index)
+#define ia64_getreg			xen_ia64_getreg
+#define ia64_setreg			xen_ia64_setreg
+#define	ia64_get_psr_i			xen_get_psr_i
+
+/* the remainder of these are not performance-sensitive so its
+ * OK to not paravirtualize and just take a privop trap and emulate */
+#define ia64_hint			__ia64_hint
+#define ia64_set_pmd			__ia64_set_pmd
+#define ia64_itci			__ia64_itci
+#define ia64_itcd			__ia64_itcd
+#define ia64_itri			__ia64_itri
+#define ia64_itrd			__ia64_itrd
+#define ia64_tpa			__ia64_tpa
+#define ia64_set_ibr			__ia64_set_ibr
+#define ia64_set_pkr			__ia64_set_pkr
+#define ia64_set_pmc			__ia64_set_pmc
+#define ia64_get_ibr			__ia64_get_ibr
+#define ia64_get_pkr			__ia64_get_pkr
+#define ia64_get_pmc			__ia64_get_pmc
+#define ia64_ptce			__ia64_ptce
+#define ia64_ptcl			__ia64_ptcl
+#define ia64_ptri			__ia64_ptri
+#define ia64_ptrd			__ia64_ptrd
+
+#endif /* !__ASSEMBLY__ */
+
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#define ia64_pal_halt_light		xen_pal_halt_light
+#define	ia64_leave_kernel		xen_leave_kernel
+#define	ia64_leave_syscall		xen_leave_syscall
+#define	ia64_trace_syscall		xen_trace_syscall
+#define	ia64_switch_to			xen_switch_to
+#define	ia64_pal_call_static		xen_pal_call_static
+
+#endif /* _ASM_IA64_XEN_PRIVOP_H */

--=-p7tBmmnWfpnHwP6L2lWG--

