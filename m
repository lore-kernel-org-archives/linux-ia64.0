From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Mon, 25 Feb 2008 03:16:46 +0000
Subject: [PATCH 4/4] ia64/xen: paravirtualize ia64_switch_to, ia64_leave_syscall and ia64_leave_kernel in ent
Message-Id: <12039094064190-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/xen/xenentry.S      |  798 +++++++++++++++++++++++++++++++++++++=
++++
 include/asm-ia64/xen/privop.h |   22 ++
 2 files changed, 820 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/xenentry.S

diff --git a/arch/ia64/xen/xenentry.S b/arch/ia64/xen/xenentry.S
new file mode 100644
index 0000000..38a509d
--- /dev/null
+++ b/arch/ia64/xen/xenentry.S
@@ -0,0 +1,798 @@
+/*
+ * ia64/xen/entry.S
+ *
+ * Alternate kernel routines for Xen.  Heavily leveraged from
+ *   ia64/kernel/entry.S
+ *
+ * Copyright (C) 2005 Hewlett-Packard Co
+ *	Dan Magenheimer <dan.magenheimer@.hp.com>
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/cache.h>
+#include <asm/errno.h>
+#include <asm/kregs.h>
+#include <asm/asm-offsets.h>
+#include <asm/pgtable.h>
+#include <asm/percpu.h>
+#include <asm/processor.h>
+#include <asm/thread_info.h>
+#include <asm/unistd.h>
+
+#ifdef CONFIG_XEN
+#include "xenminstate.h"
+#include <asm/paravirt_nop.h>
+#else
+#include "minstate.h"
+#endif
+
+/*
+ * prev_task <- ia64_switch_to(struct task_struct *next)
+ *	With Ingo's new scheduler, interrupts are disabled when this routine ge=
ts
+ *	called.  The code starting at .map relies on this.  The rest of the code
+ *	doesn't care about the interrupt masking status.
+ */
+#ifdef CONFIG_XEN
+GLOBAL_ENTRY(xen_switch_to)
+	BR_IF_NATIVE(__ia64_switch_to, r22, p7)
+#else
+GLOBAL_ENTRY(ia64_switch_to)
+#endif
+	.prologue
+	alloc r16=3Dar.pfs,1,0,0,0
+	DO_SAVE_SWITCH_STACK
+	.body
+
+	adds r22=3DIA64_TASK_THREAD_KSP_OFFSET,r13
+	movl r25=3Dinit_task
+	mov r27=3DIA64_KR(CURRENT_STACK)
+	adds r21=3DIA64_TASK_THREAD_KSP_OFFSET,in0
+	dep r20=3D0,in0,61,3		// physical address of "next"
+	;;
+	st8 [r22]=3Dsp			// save kernel stack pointer of old task
+	shr.u r26=3Dr20,IA64_GRANULE_SHIFT
+	cmp.eq p7,p6=3Dr25,in0
+	;;
+	/*
+	 * If we've already mapped this task's page, we can skip doing it again.
+	 */
+(p6)	cmp.eq p7,p6=3Dr26,r27
+(p6)	br.cond.dpnt .map
+	;;
+.done:
+	ld8 sp=3D[r21]			// load kernel stack pointer of new task
+#ifdef CONFIG_XEN
+	// update "current" application register
+	mov r8=3DIA64_KR_CURRENT
+	mov r9=3Din0;;
+	XEN_HYPER_SET_KR
+#else
+	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
+#endif
+	mov r8=3Dr13			// return pointer to previously running task
+	mov r13=3Din0			// set "current" pointer
+	;;
+	DO_LOAD_SWITCH_STACK
+
+#ifdef CONFIG_SMP
+	sync.i				// ensure "fc"s done by this CPU are visible on other CPUs
+#endif
+	br.ret.sptk.many rp		// boogie on out in new context
+
+.map:
+#ifdef CONFIG_XEN
+	movl r25=3DXSI_PSR_IC			// clear psr.ic
+	;;
+	st4 [r25]=3Dr0
+	;;
+#else
+	rsm psr.ic			// interrupts (psr.i) are already disabled here
+#endif
+	movl r25=3DPAGE_KERNEL
+	;;
+	srlz.d
+	or r23=3Dr25,r20			// construct PA | page properties
+	mov r25=3DIA64_GRANULE_SHIFT<<2
+	;;
+#ifdef CONFIG_XEN
+	movl r8=3DXSI_ITIR
+	;;
+	st8 [r8]=3Dr25
+	;;
+	movl r8=3DXSI_IFA
+	;;
+	st8 [r8]=3Din0			 // VA of next task...
+	;;
+	mov r25=3DIA64_TR_CURRENT_STACK
+	// remember last page we mapped...
+	mov r8=3DIA64_KR_CURRENT_STACK
+	mov r9=3Dr26;;
+	XEN_HYPER_SET_KR;;
+#else
+	mov cr.itir=3Dr25
+	mov cr.ifa=3Din0			// VA of next task...
+	;;
+	mov r25=3DIA64_TR_CURRENT_STACK
+	mov IA64_KR(CURRENT_STACK)=3Dr26	// remember last page we mapped...
+#endif
+	;;
+	itr.d dtr[r25]=3Dr23		// wire in new mapping...
+#ifdef CONFIG_XEN
+	;;
+	srlz.d
+	mov r9=3D1
+	movl r8=3DXSI_PSR_IC
+	;;
+	st4 [r8]=3Dr9
+	;;
+#else
+	ssm psr.ic			// reenable the psr.ic bit
+	;;
+	srlz.d
+#endif
+	br.cond.sptk .done
+#ifdef CONFIG_XEN
+END(xen_switch_to)
+#else
+END(ia64_switch_to)
+#endif
+
+#ifdef CONFIG_XEN
+GLOBAL_ENTRY(xen_work_processed_syscall_with_check)
+	BR_IF_NATIVE(__ia64_work_processed_syscall, r2, p7)
+	br.cond.sptk xen_work_processed_syscall
+END(xen_work_processed_syscall_with_check)
+#endif
+
+/*
+ * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
+ *	need to switch to bank 0 and doesn't restore the scratch registers.
+ *	To avoid leaking kernel bits, the scratch registers are set to
+ *	the following known-to-be-safe values:
+ *
+ *		  r1: restored (global pointer)
+ *		  r2: cleared
+ *		  r3: 1 (when returning to user-level)
+ *	      r8-r11: restored (syscall return value(s))
+ *		 r12: restored (user-level stack pointer)
+ *		 r13: restored (user-level thread pointer)
+ *		 r14: set to __kernel_syscall_via_epc
+ *		 r15: restored (syscall #)
+ *	     r16-r17: cleared
+ *		 r18: user-level b6
+ *		 r19: cleared
+ *		 r20: user-level ar.fpsr
+ *		 r21: user-level b0
+ *		 r22: cleared
+ *		 r23: user-level ar.bspstore
+ *		 r24: user-level ar.rnat
+ *		 r25: user-level ar.unat
+ *		 r26: user-level ar.pfs
+ *		 r27: user-level ar.rsc
+ *		 r28: user-level ip
+ *		 r29: user-level psr
+ *		 r30: user-level cfm
+ *		 r31: user-level pr
+ *	      f6-f11: cleared
+ *		  pr: restored (user-level pr)
+ *		  b0: restored (user-level rp)
+ *	          b6: restored
+ *		  b7: set to __kernel_syscall_via_epc
+ *	     ar.unat: restored (user-level ar.unat)
+ *	      ar.pfs: restored (user-level ar.pfs)
+ *	      ar.rsc: restored (user-level ar.rsc)
+ *	     ar.rnat: restored (user-level ar.rnat)
+ *	 ar.bspstore: restored (user-level ar.bspstore)
+ *	     ar.fpsr: restored (user-level ar.fpsr)
+ *	      ar.ccv: cleared
+ *	      ar.csd: cleared
+ *	      ar.ssd: cleared
+ */
+#ifdef CONFIG_XEN
+GLOBAL_ENTRY(xen_leave_syscall)
+	BR_IF_NATIVE(__ia64_leave_syscall, r22, p7)
+#else
+ENTRY(ia64_leave_syscall)
+#endif
+	PT_REGS_UNWIND_INFO(0)
+	/*
+	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
+	 * user- or fsys-mode, hence we disable interrupts early on.
+	 *
+	 * p6 controls whether current_thread_info()->flags needs to be check for
+	 * extra work.  We always check for extra work when returning to user-lev=
el.
+	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
+	 * is 0.  After extra work processing has been completed, execution
+	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * needs to be redone.
+	 */
+#ifdef CONFIG_PREEMPT
+	rsm psr.i				// disable interrupts
+	cmp.eq pLvSys,p0=3Dr0,r0			// pLvSys=3D1: leave from syscall
+(pKStk) adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+	.pred.rel.mutex pUStk,pKStk
+(pKStk) ld4 r21=3D[r20]			// r21 <- preempt_count
+(pUStk)	mov r21=3D0			// r21 <- 0
+	;;
+	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
+#else /* !CONFIG_PREEMPT */
+#ifdef CONFIG_XEN
+	movl r2=3DXSI_PSR_I_ADDR
+	mov r18=3D1
+	;;
+	ld8 r2=3D[r2]
+	;;
+(pUStk)	st1 [r2]=3Dr18
+#else
+(pUStk)	rsm psr.i
+#endif
+	cmp.eq pLvSys,p0=3Dr0,r0		// pLvSys=3D1: leave from syscall
+(pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
+#endif
+#ifdef CONFIG_XEN
+.global xen_work_processed_syscall;
+xen_work_processed_syscall:
+#else
+.work_processed_syscall:
+#endif
+	adds r2=3DPT(LOADRS)+16,r12
+	adds r3=3DPT(AR_BSPSTORE)+16,r12
+	adds r18=3DTI_FLAGS+IA64_TASK_SIZE,r13
+	;;
+(p6)	ld4 r31=3D[r18]				// load current_thread_info()->flags
+	ld8 r19=3D[r2],PT(B6)-PT(LOADRS)		// load ar.rsc value for "loadrs"
+	nop.i 0
+	;;
+	mov r16=3Dar.bsp				// M2  get existing backing store pointer
+	ld8 r18=3D[r2],PT(R9)-PT(B6)		// load b6
+(p6)	and r15=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
+	;;
+	ld8 r23=3D[r3],PT(R11)-PT(AR_BSPSTORE)	// load ar.bspstore (may be garbag=
e)
+(p6)	cmp4.ne.unc p6,p0=3Dr15, r0		// any special work pending?
+(p6)	br.cond.spnt .work_pending_syscall
+	;;
+	// start restoring the state saved on the kernel stack (struct pt_regs):
+	ld8 r9=3D[r2],PT(CR_IPSR)-PT(R9)
+	ld8 r11=3D[r3],PT(CR_IIP)-PT(R11)
+(pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
+	;;
+	invala			// M0|1 invalidate ALAT
+#ifdef CONFIG_XEN
+	movl r28=3DXSI_PSR_I_ADDR
+	movl r29=3DXSI_PSR_IC
+	;;
+	ld8 r28=3D[r28]
+	mov r30=3D1
+	;;
+	st1	[r28]=3Dr30
+	st4	[r29]=3Dr0	// note: clears both vpsr.i and vpsr.ic!
+	;;
+#else
+	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
+#endif
+	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should restore cr=
.ifs
+
+	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
+	ld8 r28=3D[r3],16		// M0|1 load cr.iip
+	mov r22=3Dr0		// A    clear r22
+	;;
+	ld8 r30=3D[r2],16		// M0|1 load cr.ifs
+	ld8 r25=3D[r3],16		// M0|1 load ar.unat
+(pUStk) add r14=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r13
+	;;
+	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
+#ifdef CONFIG_XEN
+(pKStk)	mov r21=3Dr8
+(pKStk)	XEN_HYPER_GET_PSR
+	;;
+(pKStk)	mov r22=3Dr8
+(pKStk)	mov r8=3Dr21
+	;;
+#else
+(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
+#endif
+	nop 0
+	;;
+	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // M0|1 load b0
+	ld8 r27=3D[r3],PT(PR)-PT(AR_RSC)	// M0|1 load ar.rsc
+	mov f6=F0			// F    clear f6
+	;;
+	ld8 r24=3D[r2],PT(AR_FPSR)-PT(AR_RNAT)	// M0|1 load ar.rnat (may be garba=
ge)
+	ld8 r31=3D[r3],PT(R1)-PT(PR)		// M0|1 load predicates
+	mov f7=F0				// F    clear f7
+	;;
+	ld8 r20=3D[r2],PT(R12)-PT(AR_FPSR)	// M0|1 load ar.fpsr
+	ld8.fill r1=3D[r3],16			// M0|1 load r1
+(pUStk) mov r17=3D1				// A
+	;;
+(pUStk) st1 [r14]=3Dr17				// M2|3
+	ld8.fill r13=3D[r3],16			// M0|1
+	mov f8=F0				// F    clear f8
+	;;
+	ld8.fill r12=3D[r2]			// M0|1 restore r12 (sp)
+	ld8.fill r15=3D[r3]			// M0|1 restore r15
+	mov b6=3Dr18				// I0   restore b6
+
+	LOAD_PHYS_STACK_REG_SIZE(r17)
+	mov f9=F0					// F    clear f9
+(pKStk) br.cond.dpnt.many skip_rbs_switch		// B
+
+	srlz.d				// M0   ensure interruption collection is off (for cover)
+	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
+#ifdef CONFIG_XEN
+	XEN_HYPER_COVER;
+#else
+	cover				// B    add current frame into dirty partition & set cr.ifs
+#endif
+	;;
+	mov r19=3Dar.bsp			// M2   get new backing store pointer
+	mov f10=F0			// F    clear f10
+
+	nop.m 0
+	movl r14=3D__kernel_syscall_via_epc // X
+	;;
+	mov.m ar.csd=3Dr0			// M2   clear ar.csd
+	mov.m ar.ccv=3Dr0			// M2   clear ar.ccv
+	mov b7=3Dr14			// I0   clear b7 (hint with __kernel_syscall_via_epc)
+
+	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
+	mov f11=F0			// F    clear f11
+	br.cond.sptk.many rbs_switch	// B
+#ifdef CONFIG_XEN
+END(xen_leave_syscall)
+#else
+END(ia64_leave_syscall)
+#endif
+
+#ifdef CONFIG_XEN
+GLOBAL_ENTRY(xen_leave_kernel)
+	BR_IF_NATIVE(__ia64_leave_kernel, r22, p7)
+#else
+GLOBAL_ENTRY(ia64_leave_kernel)
+#endif
+	PT_REGS_UNWIND_INFO(0)
+	/*
+	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
+	 * user- or fsys-mode, hence we disable interrupts early on.
+	 *
+	 * p6 controls whether current_thread_info()->flags needs to be check for
+	 * extra work.  We always check for extra work when returning to user-lev=
el.
+	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
+	 * is 0.  After extra work processing has been completed, execution
+	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * needs to be redone.
+	 */
+#ifdef CONFIG_PREEMPT
+	rsm psr.i				// disable interrupts
+	cmp.eq p0,pLvSys=3Dr0,r0			// pLvSys=3D0: leave from kernel
+(pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+	.pred.rel.mutex pUStk,pKStk
+(pKStk)	ld4 r21=3D[r20]			// r21 <- preempt_count
+(pUStk)	mov r21=3D0			// r21 <- 0
+	;;
+	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
+#else
+#ifdef CONFIG_XEN
+(pUStk)	movl r17=3DXSI_PSR_I_ADDR
+(pUStk)	mov r31=3D1
+		;;
+(pUStk) 	ld8 r17=3D[r17]
+		;;
+(pUStk)	st1 [r17]=3Dr31
+	;;
+#else
+(pUStk)	rsm psr.i
+#endif
+	cmp.eq p0,pLvSys=3Dr0,r0		// pLvSys=3D0: leave from kernel
+(pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
+#endif
+.work_processed_kernel:
+	adds r17=3DTI_FLAGS+IA64_TASK_SIZE,r13
+	;;
+(p6)	ld4 r31=3D[r17]				// load current_thread_info()->flags
+	adds r21=3DPT(PR)+16,r12
+	;;
+
+	lfetch [r21],PT(CR_IPSR)-PT(PR)
+	adds r2=3DPT(B6)+16,r12
+	adds r3=3DPT(R16)+16,r12
+	;;
+	lfetch [r21]
+	ld8 r28=3D[r2],8		// load b6
+	adds r29=3DPT(R24)+16,r12
+
+	ld8.fill r16=3D[r3],PT(AR_CSD)-PT(R16)
+	adds r30=3DPT(AR_CCV)+16,r12
+(p6)	and r19=3DTIF_WORK_MASK,r31		// any work other than TIF_SYSCALL_TRACE?
+	;;
+	ld8.fill r24=3D[r29]
+	ld8 r15=3D[r30]		// load ar.ccv
+(p6)	cmp4.ne.unc p6,p0=3Dr19, r0		// any special work pending?
+	;;
+	ld8 r29=3D[r2],16		// load b7
+	ld8 r30=3D[r3],16		// load ar.csd
+(p6)	br.cond.spnt .work_pending
+	;;
+	ld8 r31=3D[r2],16		// load ar.ssd
+	ld8.fill r8=3D[r3],16
+	;;
+	ld8.fill r9=3D[r2],16
+	ld8.fill r10=3D[r3],PT(R17)-PT(R10)
+	;;
+	ld8.fill r11=3D[r2],PT(R18)-PT(R11)
+	ld8.fill r17=3D[r3],16
+	;;
+	ld8.fill r18=3D[r2],16
+	ld8.fill r19=3D[r3],16
+	;;
+	ld8.fill r20=3D[r2],16
+	ld8.fill r21=3D[r3],16
+	mov ar.csd=3Dr30
+	mov ar.ssd=3Dr31
+	;;
+#ifdef CONFIG_XEN
+	movl r23=3DXSI_PSR_I_ADDR
+	movl r22=3DXSI_PSR_IC
+	;;
+	ld8 r23=3D[r23]
+	mov r25=3D1
+	;;
+	st1 [r23]=3Dr25
+	st4 [r22]=3Dr0		// note: clears both vpsr.i and vpsr.ic!
+	;;
+#else
+	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption =
collection
+#endif
+	invala			// invalidate ALAT
+	;;
+	ld8.fill r22=3D[r2],24
+	ld8.fill r23=3D[r3],24
+	mov b6=3Dr28
+	;;
+	ld8.fill r25=3D[r2],16
+	ld8.fill r26=3D[r3],16
+	mov b7=3Dr29
+	;;
+	ld8.fill r27=3D[r2],16
+	ld8.fill r28=3D[r3],16
+	;;
+	ld8.fill r29=3D[r2],16
+	ld8.fill r30=3D[r3],24
+	;;
+	ld8.fill r31=3D[r2],PT(F9)-PT(R31)
+	adds r3=3DPT(F10)-PT(F6),r3
+	;;
+	ldf.fill f9=3D[r2],PT(F6)-PT(F9)
+	ldf.fill f10=3D[r3],PT(F8)-PT(F10)
+	;;
+	ldf.fill f6=3D[r2],PT(F7)-PT(F6)
+	;;
+	ldf.fill f7=3D[r2],PT(F11)-PT(F7)
+	ldf.fill f8=3D[r3],32
+	;;
+	srlz.d	// ensure that inter. collection is off (VHPT is don't care, since=
 text is pinned)
+	mov ar.ccv=3Dr15
+	;;
+	ldf.fill f11=3D[r2]
+#ifdef CONFIG_XEN
+	;;
+	// r16-r31 all now hold bank1 values
+	mov r15=3Dar.unat
+	movl r2=3DXSI_BANK1_R16
+	movl r3=3DXSI_BANK1_R16+8
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr16,16
+.mem.offset 8,0; st8.spill [r3]=3Dr17,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr18,16
+.mem.offset 8,0; st8.spill [r3]=3Dr19,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr20,16
+.mem.offset 8,0; st8.spill [r3]=3Dr21,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr22,16
+.mem.offset 8,0; st8.spill [r3]=3Dr23,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr24,16
+.mem.offset 8,0; st8.spill [r3]=3Dr25,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr26,16
+.mem.offset 8,0; st8.spill [r3]=3Dr27,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr28,16
+.mem.offset 8,0; st8.spill [r3]=3Dr29,16
+	;;
+.mem.offset 0,0; st8.spill [r2]=3Dr30,16
+.mem.offset 8,0; st8.spill [r3]=3Dr31,16
+	;;
+	mov r3=3Dar.unat
+	movl r2=3DXSI_B1NAT
+	;;
+	st8 [r2]=3Dr3
+	mov ar.unat=3Dr15
+	movl r2=3DXSI_BANKNUM;;
+	st4 [r2]=3Dr0;
+#else
+	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
+#endif
+	;;
+(pUStk)	mov r18=3DIA64_KR(CURRENT)// M2 (12 cycle read latency)
+	adds r16=3DPT(CR_IPSR)+16,r12
+	adds r17=3DPT(CR_IIP)+16,r12
+
+#ifdef CONFIG_XEN
+(pKStk)	mov r29=3Dr8
+(pKStk)	XEN_HYPER_GET_PSR
+	;;
+(pKStk)	mov r22=3Dr8
+(pKStk)	mov r8=3Dr29
+	;;
+#else
+(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+#endif
+	nop.i 0
+	nop.i 0
+	;;
+	ld8 r29=3D[r16],16	// load cr.ipsr
+	ld8 r28=3D[r17],16	// load cr.iip
+	;;
+	ld8 r30=3D[r16],16	// load cr.ifs
+	ld8 r25=3D[r17],16	// load ar.unat
+	;;
+	ld8 r26=3D[r16],16	// load ar.pfs
+	ld8 r27=3D[r17],16	// load ar.rsc
+	cmp.eq p9,p0=3Dr0,r0	// set p9 to indicate that we should restore cr.ifs
+	;;
+	ld8 r24=3D[r16],16	// load ar.rnat (may be garbage)
+	ld8 r23=3D[r17],16	// load ar.bspstore (may be garbage)
+	;;
+	ld8 r31=3D[r16],16	// load predicates
+	ld8 r21=3D[r17],16	// load b0
+	;;
+	ld8 r19=3D[r16],16	// load ar.rsc value for "loadrs"
+	ld8.fill r1=3D[r17],16	// load r1
+	;;
+	ld8.fill r12=3D[r16],16
+	ld8.fill r13=3D[r17],16
+(pUStk)	adds r18=3DIA64_TASK_THREAD_ON_USTACK_OFFSET,r18
+	;;
+	ld8 r20=3D[r16],16	// ar.fpsr
+	ld8.fill r15=3D[r17],16
+	;;
+	ld8.fill r14=3D[r16],16
+	ld8.fill r2=3D[r17]
+(pUStk)	mov r17=3D1
+	;;
+	ld8.fill r3=3D[r16]
+(pUStk)	st1 [r18]=3Dr17		// restore current->thread.on_ustack
+	shr.u r18=3Dr19,16	// get byte size of existing "dirty" partition
+	;;
+	mov r16=3Dar.bsp		// get existing backing store pointer
+	LOAD_PHYS_STACK_REG_SIZE(r17)
+(pKStk)	br.cond.dpnt skip_rbs_switch
+
+	/*
+	 * Restore user backing store.
+	 *
+	 * NOTE: alloc, loadrs, and cover can't be predicated.
+	 */
+(pNonSys) br.cond.dpnt dont_preserve_current_frame
+
+#ifdef CONFIG_XEN
+	XEN_HYPER_COVER;
+#else
+	cover				// add current frame into dirty partition and set cr.ifs
+#endif
+	;;
+	mov r19=3Dar.bsp			// get new backing store pointer
+rbs_switch:
+	sub r16=3Dr16,r18			// krbs =3D old bsp - size of dirty partition
+	cmp.ne p9,p0=3Dr0,r0		// clear p9 to skip restore of cr.ifs
+	;;
+	sub r19=3Dr19,r16			// calculate total byte size of dirty partition
+	add r18d,r18			// don't force in0-in7 into memory...
+	;;
+	shl r19=3Dr19,16			// shift size of dirty partition into loadrs position
+	;;
+dont_preserve_current_frame:
+	/*
+	 * To prevent leaking bits between the kernel and user-space,
+	 * we must clear the stacked registers in the "invalid" partition here.
+	 * Not pretty, but at least it's fast (3.34 registers/cycle on Itanium,
+	 * 5 registers/cycle on McKinley).
+	 */
+#	define pRecurse	p6
+#	define pReturn	p7
+#ifdef CONFIG_ITANIUM
+#	define Nregs	10
+#else
+#	define Nregs	14
+#endif
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	shr.u loc1=3Dr18,9		// RNaTslots <=3D floor(dirtySize / (64*8))
+	sub r17=3Dr17,r18			// r17 =3D (physStackedSize + 8) - dirtySize
+	;;
+	mov ar.rsc=3Dr19			// load ar.rsc to be used for "loadrs"
+	shladd in0=3Dloc1,3,r17
+	mov in1=3D0
+	;;
+	TEXT_ALIGN(32)
+rse_clear_invalid:
+#ifdef CONFIG_ITANIUM
+	// cycle 0
+ { .mii
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	add out0=3D-Nregs*8,in0
+}{ .mfb
+	add out1=3D1,in1			// increment recursion count
+	nop.f 0
+	nop.b 0				// can't do br.call here because of alloc (WAW on CFM)
+	;;
+}{ .mfi	// cycle 1
+	mov loc1=3D0
+	nop.f 0
+	mov loc2=3D0
+}{ .mib
+	mov loc3=3D0
+	mov loc4=3D0
+(pRecurse) br.call.sptk.many b0=3Drse_clear_invalid
+
+}{ .mfi	// cycle 2
+	mov loc5=3D0
+	nop.f 0
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+}{ .mib
+	mov loc6=3D0
+	mov loc7=3D0
+(pReturn) br.ret.sptk.many b0
+}
+#else /* !CONFIG_ITANIUM */
+	alloc loc0=3Dar.pfs,2,Nregs-2,2,0
+	cmp.lt pRecurse,p0=3DNregs*8,in0	// if more than Nregs regs left to clear=
, (re)curse
+	add out0=3D-Nregs*8,in0
+	add out1=3D1,in1			// increment recursion count
+	mov loc1=3D0
+	mov loc2=3D0
+	;;
+	mov loc3=3D0
+	mov loc4=3D0
+	mov loc5=3D0
+	mov loc6=3D0
+	mov loc7=3D0
+(pRecurse) br.call.dptk.few b0=3Drse_clear_invalid
+	;;
+	mov loc8=3D0
+	mov loc9=3D0
+	cmp.ne pReturn,p0=3Dr0,in1	// if recursion count !=3D 0, we need to do a =
br.ret
+	mov loc10=3D0
+	mov loc11=3D0
+(pReturn) br.ret.dptk.many b0
+#endif /* !CONFIG_ITANIUM */
+#	undef pRecurse
+#	undef pReturn
+	;;
+	alloc r17=3Dar.pfs,0,0,0,0	// drop current register frame
+	;;
+	loadrs
+	;;
+skip_rbs_switch:
+	mov ar.unat=3Dr25		// M2
+(pKStk)	extr.u r22=3Dr22,21,1	// I0 extract current value of psr.pp from r=
22
+(pLvSys)mov r19=3Dr0		// A  clear r19 for leave_syscall, no-op otherwise
+	;;
+(pUStk)	mov ar.bspstore=3Dr23	// M2
+(pKStk)	dep r29=3Dr22,r29,21,1	// I0 update ipsr.pp with psr.pp
+(pLvSys)mov r16=3Dr0		// A  clear r16 for leave_syscall, no-op otherwise
+	;;
+#ifdef CONFIG_XEN
+	movl r25=3DXSI_IPSR
+	;;
+	st8[r25]=3Dr29,XSI_IFS_OFS-XSI_IPSR_OFS
+	;;
+#else
+	mov cr.ipsr=3Dr29		// M2
+#endif
+	mov ar.pfs=3Dr26		// I0
+(pLvSys)mov r17=3Dr0		// A  clear r17 for leave_syscall, no-op otherwise
+
+#ifdef CONFIG_XEN
+(p9)	st8 [r25]=3Dr30
+	;;
+	adds r25=3DXSI_IIP_OFS-XSI_IFS_OFS,r25
+	;;
+#else
+(p9)	mov cr.ifs=3Dr30		// M2
+#endif
+	mov b0=3Dr21		// I0
+(pLvSys)mov r18=3Dr0		// A  clear r18 for leave_syscall, no-op otherwise
+
+	mov ar.fpsr=3Dr20		// M2
+#ifdef CONFIG_XEN
+	st8	[r25]=3Dr28
+#else
+	mov cr.iip=3Dr28		// M2
+#endif
+	nop 0
+	;;
+(pUStk)	mov ar.rnat=3Dr24		// M2 must happen with RSE in lazy mode
+	nop 0
+(pLvSys)mov r2=3Dr0
+
+	mov ar.rsc=3Dr27		// M2
+	mov pr=3Dr31,-1		// I0
+#ifdef CONFIG_XEN
+	;;
+	XEN_HYPER_RFI;
+#else
+	rfi			// B
+#endif
+
+	/*
+	 * On entry:
+	 *	r20 =3D &current->thread_info->pre_count (if CONFIG_PREEMPT)
+	 *	r31 =3D current->thread_info->flags
+	 * On exit:
+	 *	p6 =3D TRUE if work-pending-check needs to be redone
+	 */
+.work_pending_syscall:
+	add r2=3D-8,r2
+	add r3=3D-8,r3
+	;;
+	st8 [r2]=3Dr8
+	st8 [r3]=3Dr10
+.work_pending:
+	tbit.z p6,p0=3Dr31,TIF_NEED_RESCHED		// current_thread_info()->need_resch=
ed=3D0?
+(p6)	br.cond.sptk.few .notify
+#ifdef CONFIG_PREEMPT
+(pKStk) dep r21=3D-1,r0,PREEMPT_ACTIVE_BIT,1
+	;;
+(pKStk) st4 [r20]=3Dr21
+	ssm psr.i		// enable interrupts
+#endif
+	br.call.spnt.many rp=3Dschedule
+.ret9:	cmp.eq p6,p0=3Dr0,r0				// p6 <- 1
+#ifdef CONFIG_XEN
+	movl r2=3DXSI_PSR_I_ADDR
+	mov r20=3D1
+	;;
+	ld8 r2=3D[r2]
+	;;
+	st1 [r2]=3Dr20
+#else
+	rsm psr.i		// disable interrupts
+#endif
+	;;
+#ifdef CONFIG_PREEMPT
+(pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
+	;;
+(pKStk)	st4 [r20]=3Dr0		// preempt_count() <- 0
+#endif
+(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
+	br.cond.sptk.many .work_processed_kernel	// re-check
+
+.notify:
+(pUStk)	br.call.spnt.many rp=3Dnotify_resume_user
+.ret10:	cmp.ne p6,p0=3Dr0,r0				// p6 <- 0
+(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
+	br.cond.sptk.many .work_processed_kernel	// don't re-check
+
+.work_pending_syscall_end:
+	adds r2=3DPT(R8)+16,r12
+	adds r3=3DPT(R10)+16,r12
+	;;
+	ld8 r8=3D[r2]
+	ld8 r10=3D[r3]
+#ifdef CONFIG_XEN
+	br.cond.sptk.many xen_work_processed_syscall	// re-check
+#else
+	br.cond.sptk.many .work_processed_syscall	// re-check
+#endif
+
+#ifdef CONFIG_XEN
+END(xen_leave_kernel)
+#else
+END(ia64_leave_kernel)
+#endif
diff --git a/include/asm-ia64/xen/privop.h b/include/asm-ia64/xen/privop.h
index dd3e5ec..c8a5a0d 100644
--- a/include/asm-ia64/xen/privop.h
+++ b/include/asm-ia64/xen/privop.h
@@ -70,4 +70,26 @@
 #define XSI_IHA				(XSI_BASE + XSI_IHA_OFS)
 #endif
=20
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#ifndef CONFIG_PARAVIRT_ENTRY
+#define IA64_PARAVIRTUALIZED_ENTRY
+#define ia64_switch_to			xen_switch_to
+#define ia64_leave_syscall		xen_leave_syscall
+#define ia64_work_processed_syscall	xen_work_processed_syscall_with_check
+#define ia64_leave_kernel		xen_leave_kernel
+#endif /* !CONFIG_PARAVIRT_ENTRY */
+
+#ifdef CONFIG_XEN
+#ifdef __ASSEMBLY__
+#define BR_IF_NATIVE(target, reg, pred)		\
+	.body ;					\
+	movl reg=3Drunning_on_xen;; ;		\
+	ld4 reg=3D[reg];; ;			\
+	cmp.eq pred,p0=3Dreg,r0 ;			\
+	(pred)	br.cond.sptk.many target;;
+#endif /* __ASSEMBLY__ */
+#endif
+
 #endif /* _ASM_IA64_XEN_PRIVOP_H */
--=20
1.5.3

