From: Keith Owens <kaos@sgi.com>
Date: Thu, 22 Sep 2005 08:39:29 +0000
Subject: [patch 2.6.14-rc2] Wire in the MCA/INIT handler stacks
Message-Id: <11557.1127378369@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Wire the MCA/INIT handler stacks into DTR[2] and track them in
IA64_KR(CURRENT_STACK).  This gives the MCA/INIT handler stacks the
same TLB status as normal kernel stacks.  Reload the old CURRENT_STACK
data on return from OS to SAL.

Signed-off-by: Keith Owens <kaos@sgi.com>

---

 include/asm-ia64/mca.h     |    5 ++
 arch/ia64/kernel/mca_asm.S |   96 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 90 insertions(+), 11 deletions(-)

Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2005-09-21 16:41:46.520554241 +1000
+++ linux/include/asm-ia64/mca.h	2005-09-22 16:11:25.000000000 +1000
@@ -80,7 +80,12 @@ struct ia64_sal_os_state {
 	u64			sal_ra;			/* Return address in SAL, physical */
 	u64			sal_gp;			/* GP of the SAL - physical */
 	pal_min_state_area_t	*pal_min_state;		/* from R17.  physical in asm, virtual in C */
+	/* Previous values of IA64_KR(CURRENT) and IA64_KR(CURRENT_STACK).
+	 * Note: if the MCA/INIT recovery code wants to resume to a new context
+	 * then it must change these values to reflect the new kernel stack.
+	 */
 	u64			prev_IA64_KR_CURRENT;	/* previous value of IA64_KR(CURRENT) */
+	u64			prev_IA64_KR_CURRENT_STACK;
 	struct task_struct	*prev_task;		/* previous task, NULL if it is not useful */
 	/* Some interrupt registers are not saved in minstate, pt_regs or
 	 * switch_stack.  Because MCA/INIT can occur when interrupts are

Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-09-21 16:41:42.653900949 +1000
+++ linux/arch/ia64/kernel/mca_asm.S	2005-09-22 18:17:17.663495626 +1000
@@ -489,24 +489,27 @@ ia64_state_save:
 	;;
 	st8 [temp1]=r17,16	// pal_min_state
 	st8 [temp2]=r6,16	// prev_IA64_KR_CURRENT
+	mov r6=IA64_KR(CURRENT_STACK)
+	;;
+	st8 [temp1]=r6,16	// prev_IA64_KR_CURRENT_STACK
+	st8 [temp2]=r0,16	// prev_task, starts off as NULL
 	mov r6=cr.ifa
 	;;
-	st8 [temp1]=r0,16	// prev_task, starts off as NULL
-	st8 [temp2]=r12,16	// cr.isr
+	st8 [temp1]=r12,16	// cr.isr
+	st8 [temp2]=r6,16	// cr.ifa
 	mov r12=cr.itir
 	;;
-	st8 [temp1]=r6,16	// cr.ifa
-	st8 [temp2]=r12,16	// cr.itir
+	st8 [temp1]=r12,16	// cr.itir
+	st8 [temp2]=r11,16	// cr.iipa
 	mov r12=cr.iim
 	;;
-	st8 [temp1]=r11,16	// cr.iipa
-	st8 [temp2]=r12,16	// cr.iim
-	mov r6=cr.iha
+	st8 [temp1]=r12,16	// cr.iim
 (p1)	mov r12=IA64_MCA_COLD_BOOT
 (p2)	mov r12=IA64_INIT_WARM_BOOT
+	mov r6=cr.iha
 	;;
-	st8 [temp1]=r6,16	// cr.iha
-	st8 [temp2]=r12		// os_status, default is cold boot
+	st8 [temp2]=r6,16	// cr.iha
+	st8 [temp1]=r12		// os_status, default is cold boot
 	mov r6=IA64_MCA_SAME_CONTEXT
 	;;
 	st8 [temp1]=r6		// context, default is same context
@@ -823,9 +826,12 @@ ia64_state_restore:
 	ld8 r12=[temp1],16	// sal_ra
 	ld8 r9=[temp2],16	// sal_gp
 	;;
-	ld8 r22=[temp1],24	// pal_min_state, virtual.  skip prev_task
+	ld8 r22=[temp1],16	// pal_min_state, virtual
 	ld8 r21=[temp2],16	// prev_IA64_KR_CURRENT
 	;;
+	ld8 r16=[temp1],16	// prev_IA64_KR_CURRENT_STACK
+	ld8 r20=[temp2],16	// prev_task
+	;;
 	ld8 temp3=[temp1],16	// cr.isr
 	ld8 temp4=[temp2],16	// cr.ifa
 	;;
@@ -846,6 +852,45 @@ ia64_state_restore:
 	ld8 r8=[temp1]		// os_status
 	ld8 r10=[temp2]		// context
 
+	/* Wire IA64_TR_CURRENT_STACK to the stack that we are resuming to.  To
+	 * avoid any dependencies on the algorithm in ia64_switch_to(), just
+	 * purge any existing CURRENT_STACK mapping and insert the new one.
+	 *
+	 * r16 contains prev_IA64_KR_CURRENT_STACK, r21 contains
+	 * prev_IA64_KR_CURRENT, these values may have been changed by the C
+	 * code.  Do not use r8, r9, r10, r22, they contain values ready for
+	 * the return to SAL.
+	 */
+
+	mov r15=IA64_KR(CURRENT_STACK)		// physical granule mapped by IA64_TR_CURRENT_STACK
+	;;
+	shl r15=r15,IA64_GRANULE_SHIFT
+	;;
+	dep r15=-1,r15,61,3			// virtual granule
+	mov r18=IA64_GRANULE_SHIFT<<2		// for cr.itir.ps
+	;;
+	ptr.d r15,r18
+	;;
+	srlz.d
+
+	extr.u r19=r21,61,3			// r21 = prev_IA64_KR_CURRENT
+	shl r20=r16,IA64_GRANULE_SHIFT		// r16 = prev_IA64_KR_CURRENT_STACK
+	movl r21=PAGE_KERNEL			// page properties
+	;;
+	mov IA64_KR(CURRENT_STACK)=r16
+	cmp.eq p6,p0=RGN_KERNEL,r19		// new stack is in the kernel region?
+	or r21=r20,r21				// construct PA | page properties
+(p6)	br.spnt 1f				// the dreaded cpu 0 idle task in region 5:(
+	;;
+	mov cr.itir=r18
+	mov cr.ifa=r21
+	mov r20=IA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r20]=r21
+	;;
+	srlz.d
+1:
+
 	br.sptk b0
 
 //EndStub//////////////////////////////////////////////////////////////////////
@@ -982,6 +1027,7 @@ ia64_set_kernel_registers:
 	add temp4=temp4, temp1	// &struct ia64_sal_os_state.os_gp
 	add r12=temp1, temp3	// kernel stack pointer on MCA/INIT stack
 	add r13=temp1, r3	// set current to start of MCA/INIT stack
+	add r20=temp1, r3	// physical start of MCA/INIT stack
 	;;
 	ld8 r1=[temp4]		// OS GP from SAL OS state
 	;;
@@ -991,7 +1037,35 @@ ia64_set_kernel_registers:
 	;;
 	mov IA64_KR(CURRENT)=r13
 
-	// FIXME: do I need to wire IA64_KR_CURRENT_STACK and IA64_TR_CURRENT_STACK?
+	/* Wire IA64_TR_CURRENT_STACK to the MCA/INIT handler stack.  To avoid
+	 * any dependencies on the algorithm in ia64_switch_to(), just purge
+	 * any existing CURRENT_STACK mapping and insert the new one.
+	 */
+
+	mov r16=IA64_KR(CURRENT_STACK)		// physical granule mapped by IA64_TR_CURRENT_STACK
+	;;
+	shl r16=r16,IA64_GRANULE_SHIFT
+	;;
+	dep r16=-1,r16,61,3			// virtual granule
+	mov r18=IA64_GRANULE_SHIFT<<2		// for cr.itir.ps
+	;;
+	ptr.d r16,r18
+	;;
+	srlz.d
+
+	shr.u r16=r20,IA64_GRANULE_SHIFT	// r20 = physical start of MCA/INIT stack
+	movl r21=PAGE_KERNEL			// page properties
+	;;
+	mov IA64_KR(CURRENT_STACK)=r16
+	or r21=r20,r21				// construct PA | page properties
+	;;
+	mov cr.itir=r18
+	mov cr.ifa=r13
+	mov r20=IA64_TR_CURRENT_STACK
+	;;
+	itr.d dtr[r20]=r21
+	;;
+	srlz.d
 
 	br.sptk b0
 

