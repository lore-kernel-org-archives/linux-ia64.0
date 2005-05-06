From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 06 May 2005 12:25:07 +0000
Subject: Re: MINSTATE_START_SAVE_MIN_PHYS looking very confused
Message-Id: <17019.25123.473344.304659@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <17019.24133.738017.806202@napali.hpl.hp.com>
In-Reply-To: <17019.24133.738017.806202@napali.hpl.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Fri, 6 May 2005 05:08:37 -0700, David Mosberger <davidm@linux.hpl.hp.com> said:

  David> It's not possible to handle nested INITs anyhow, so why not
  David> just simplify that code to always switch to the INIT stack?

I suspect Keith will tell me "that's what I've been working on". ;-)

However, the existing code clearly is bogus, putting the kernel stack
at a (almost) random place when INIT hits while in kernel-mode.  Patch
below fixes this.

	--david

[IA64] Fix stack placement when INIT hits in kernel mode.

Without this patch, the stack is placed _below_ the current task
structure, which is risky at best.

Tony, I think this patch needs to go into 2.6.12, since it fixes a
real bug.  Without it, INIT may case secondary errors, which would be
most unpleasant.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/minstate.h
=================================--- b5f77812a2ece5addfd983e38eda85017039a29d/arch/ia64/kernel/minstate.h  (mode:100644 sha1:1dbc7b2497c90d4b3c0a8cef4c7afb94e7abc315)
+++ uncommitted/arch/ia64/kernel/minstate.h  (mode:100644)
@@ -41,7 +41,7 @@
 (pKStk) addl r3=THIS_CPU(ia64_mca_data),r3;;							\
 (pKStk) ld8 r3 = [r3];;										\
 (pKStk) addl r3=IA64_MCA_CPU_INIT_STACK_OFFSET,r3;;						\
-(pKStk) addl sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
+(pKStk) addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
 (pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
 (pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
 	;;											\
@@ -50,7 +50,6 @@
 (pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
 (pUStk)	dep r22=-1,r22,61,3;			/* compute kernel virtual addr of RBS */	\
 	;;											\
-(pKStk) addl r1=-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r12) */		\
 (pUStk)	mov ar.bspstore=r22;			/* switch to kernel RBS */			\
 	;;											\
 (pUStk)	mov r18=ar.bsp;										\
