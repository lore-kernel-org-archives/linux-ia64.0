From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 30 Apr 2008 12:29:23 +0000
Subject: [PATCH 10/15] ia64/pv_ops: paravirtualize entry.S
Message-Id: <1209558568393-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1207716549278-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1207716549278-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

paravirtualize ia64_swtich_to, ia64_leave_syscall and ia64_leave_kernel.
They include sensitive or performance critical privileged instructions
so that they need paravirtualization.
To paravirtualize them by single source and multi compile
they are converted into indirect jump. And define each pv instances.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/kernel/Makefile          |    2 +-
 arch/ia64/kernel/entry.S           |  115 ++++++++++++++++++++++----------=
---
 arch/ia64/kernel/paravirt.c        |   19 ++++++
 arch/ia64/kernel/paravirtentry.S   |   60 +++++++++++++++++++
 include/asm-ia64/native/inst.h     |    8 +++
 include/asm-ia64/paravirt_privop.h |   23 +++++++
 6 files changed, 183 insertions(+), 44 deletions(-)
 create mode 100644 arch/ia64/kernel/paravirtentry.S

diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index 8b25242..cea91f1 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -36,7 +36,7 @@ obj-$(CONFIG_PCI_MSI)		+=3D msi_ia64.o
 mca_recovery-y			+=3D mca_drv.o mca_drv_asm.o
 obj-$(CONFIG_IA64_MC_ERR_INJECT)+=3D err_inject.o
=20
-obj-$(CONFIG_PARAVIRT)		+=3D paravirt.o
+obj-$(CONFIG_PARAVIRT)		+=3D paravirt.o paravirtentry.o
=20
 obj-$(CONFIG_IA64_ESI)		+=3D esi.o
 ifneq ($(CONFIG_IA64_ESI),)
diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index e49ad8c..68fb7ef 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -23,6 +23,11 @@
  * 11/07/2000
  */
 /*
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *                    pv_ops.
+ */
+/*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
  *	pKStk:		See entry.h.
@@ -45,6 +50,7 @@
=20
 #include "minstate.h"
=20
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 	/*
 	 * execve() is special because in case of success, we need to
 	 * setup a null register window frame.
@@ -173,6 +179,7 @@ GLOBAL_ENTRY(sys_clone)
 	mov rp=3Dloc0
 	br.ret.sptk.many rp
 END(sys_clone)
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
=20
 /*
  * prev_task <- ia64_switch_to(struct task_struct *next)
@@ -180,7 +187,7 @@ END(sys_clone)
  *	called.  The code starting at .map relies on this.  The rest of the code
  *	doesn't care about the interrupt masking status.
  */
-GLOBAL_ENTRY(ia64_switch_to)
+GLOBAL_ENTRY(__paravirt_switch_to)
 	.prologue
 	alloc r16=3Dar.pfs,1,0,0,0
 	DO_SAVE_SWITCH_STACK
@@ -204,7 +211,7 @@ GLOBAL_ENTRY(ia64_switch_to)
 	;;
 .done:
 	ld8 sp=3D[r21]			// load kernel stack pointer of new task
-	mov IA64_KR(CURRENT)=3Din0	// update "current" application register
+	MOV_TO_KR(CURRENT, in0, r8, r9)		// update "current" application register
 	mov r8=3Dr13			// return pointer to previously running task
 	mov r13=3Din0			// set "current" pointer
 	;;
@@ -216,26 +223,25 @@ GLOBAL_ENTRY(ia64_switch_to)
 	br.ret.sptk.many rp		// boogie on out in new context
=20
 .map:
-	rsm psr.ic			// interrupts (psr.i) are already disabled here
+	RSM_PSR_IC(r25)			// interrupts (psr.i) are already disabled here
 	movl r25=3DPAGE_KERNEL
 	;;
 	srlz.d
 	or r23=3Dr25,r20			// construct PA | page properties
 	mov r25=3DIA64_GRANULE_SHIFT<<2
 	;;
-	mov cr.itir=3Dr25
-	mov cr.ifa=3Din0			// VA of next task...
+	MOV_TO_ITIR(p0, r25, r8)
+	MOV_TO_IFA(in0, r8)		// VA of next task...
 	;;
 	mov r25=3DIA64_TR_CURRENT_STACK
-	mov IA64_KR(CURRENT_STACK)=3Dr26	// remember last page we mapped...
+	MOV_TO_KR(CURRENT_STACK, r26, r8, r9)	// remember last page we mapped...
 	;;
 	itr.d dtr[r25]=3Dr23		// wire in new mapping...
-	ssm psr.ic			// reenable the psr.ic bit
-	;;
-	srlz.d
+	SSM_PSR_IC_AND_SRLZ_D(r8, r9)	// reenable the psr.ic bit
 	br.cond.sptk .done
-END(ia64_switch_to)
+END(__paravirt_switch_to)
=20
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 /*
  * Note that interrupts are enabled during save_switch_stack and load_swit=
ch_stack.  This
  * means that we may get an interrupt with "sp" pointing to the new kernel=
 stack while
@@ -375,7 +381,7 @@ END(save_switch_stack)
  *	- b7 holds address to return to
  *	- must not touch r8-r11
  */
-ENTRY(load_switch_stack)
+GLOBAL_ENTRY(load_switch_stack)
 	.prologue
 	.altrp b7
=20
@@ -571,7 +577,7 @@ GLOBAL_ENTRY(ia64_trace_syscall)
 .ret3:
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0			// p6 <- pUStk
 (pUStk)	rsm psr.i				// disable interrupts
-	br.cond.sptk .work_pending_syscall_end
+	br.cond.sptk ia64_work_pending_syscall_end
=20
 strace_error:
 	ld8 r3=3D[r2]				// load pt_regs.r8
@@ -636,8 +642,17 @@ GLOBAL_ENTRY(ia64_ret_from_syscall)
 	adds r2=3DPT(R8)+16,sp			// r2 =3D &pt_regs.r8
 	mov r10=3Dr0				// clear error indication in r10
 (p7)	br.cond.spnt handle_syscall_error	// handle potential syscall failure
+#ifdef CONFIG_PARAVIRT
+	;;
+	br.cond.sptk.few ia64_leave_syscall
+	;;
+#endif /* CONFIG_PARAVIRT */
 END(ia64_ret_from_syscall)
+#ifndef CONFIG_PARAVIRT
 	// fall through
+#endif
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
+
 /*
  * ia64_leave_syscall(): Same as ia64_leave_kernel, except that it doesn't
  *	need to switch to bank 0 and doesn't restore the scratch registers.
@@ -682,7 +697,7 @@ END(ia64_ret_from_syscall)
  *	      ar.csd: cleared
  *	      ar.ssd: cleared
  */
-ENTRY(ia64_leave_syscall)
+GLOBAL_ENTRY(__paravirt_leave_syscall)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -692,11 +707,11 @@ ENTRY(ia64_leave_syscall)
 	 * extra work.  We always check for extra work when returning to user-lev=
el.
 	 * With CONFIG_PREEMPT, we also check for extra work when the preempt_cou=
nt
 	 * is 0.  After extra work processing has been completed, execution
-	 * resumes at .work_processed_syscall with p6 set to 1 if the extra-work-=
check
+	 * resumes at ia64_work_processed_syscall with p6 set to 1 if the extra-w=
ork-check
 	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
-	rsm psr.i				// disable interrupts
+	RSM_PSR_I(p0, r2, r18)			// disable interrupts
 	cmp.eq pLvSys,p0=3Dr0,r0			// pLvSys=3D1: leave from syscall
 (pKStk) adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
@@ -706,11 +721,12 @@ ENTRY(ia64_leave_syscall)
 	;;
 	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
 #else /* !CONFIG_PREEMPT */
-(pUStk)	rsm psr.i
+	RSM_PSR_I(pUStk, r2, r18)
 	cmp.eq pLvSys,p0=3Dr0,r0		// pLvSys=3D1: leave from syscall
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
-.work_processed_syscall:
+.global __paravirt_work_processed_syscall;
+__paravirt_work_processed_syscall:
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	adds r2=3DPT(LOADRS)+16,r12
 (pUStk)	mov.m r22=3Dar.itc			// fetch time at leave
@@ -744,7 +760,7 @@ ENTRY(ia64_leave_syscall)
 (pNonSys) break 0		//      bug check: we shouldn't be here if pNonSys is T=
RUE!
 	;;
 	invala			// M0|1 invalidate ALAT
-	rsm psr.i | psr.ic	// M2   turn off interrupts and interruption collection
+	RSM_PSR_I_IC(r28, r29, r30)	// M2   turn off interrupts and interruption =
collection
 	cmp.eq p9,p0=3Dr0,r0	// A    set p9 to indicate that we should restore cr=
.ifs
=20
 	ld8 r29=3D[r2],16		// M0|1 load cr.ipsr
@@ -765,7 +781,7 @@ ENTRY(ia64_leave_syscall)
 	;;
 #endif
 	ld8 r26=3D[r2],PT(B0)-PT(AR_PFS)	// M0|1 load ar.pfs
-(pKStk)	mov r22=3Dpsr			// M2   read PSR now that interrupts are disabled
+	MOV_FROM_PSR(pKStk, r22, r21)	// M2   read PSR now that interrupts are di=
sabled
 	nop 0
 	;;
 	ld8 r21=3D[r2],PT(AR_RNAT)-PT(B0) // M0|1 load b0
@@ -798,7 +814,7 @@ ENTRY(ia64_leave_syscall)
=20
 	srlz.d				// M0   ensure interruption collection is off (for cover)
 	shr.u r18=3Dr19,16		// I0|1 get byte size of existing "dirty" partition
-	cover				// B    add current frame into dirty partition & set cr.ifs
+	COVER				// B    add current frame into dirty partition & set cr.ifs
 	;;
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	mov r19=3Dar.bsp			// M2   get new backing store pointer
@@ -823,8 +839,9 @@ ENTRY(ia64_leave_syscall)
 	mov.m ar.ssd=3Dr0			// M2   clear ar.ssd
 	mov f11=F0			// F    clear f11
 	br.cond.sptk.many rbs_switch	// B
-END(ia64_leave_syscall)
+END(__paravirt_leave_syscall)
=20
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 #ifdef CONFIG_IA32_SUPPORT
 GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
 	PT_REGS_UNWIND_INFO(0)
@@ -835,10 +852,20 @@ GLOBAL_ENTRY(ia64_ret_from_ia32_execve)
 	st8.spill [r2]=3Dr8	// store return value in slot for r8 and set unat bit
 	.mem.offset 8,0
 	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and set una=
t bit
+#ifdef CONFIG_PARAVIRT
+	;;
+	// don't fall through, ia64_leave_kernel may be #define'd
+	br.cond.sptk.few ia64_leave_kernel
+	;;
+#endif /* CONFIG_PARAVIRT */
 END(ia64_ret_from_ia32_execve)
+#ifndef CONFIG_PARAVIRT
 	// fall through
+#endif
 #endif /* CONFIG_IA32_SUPPORT */
-GLOBAL_ENTRY(ia64_leave_kernel)
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
+
+GLOBAL_ENTRY(__paravirt_leave_kernel)
 	PT_REGS_UNWIND_INFO(0)
 	/*
 	 * work.need_resched etc. mustn't get changed by this CPU before it retur=
ns to
@@ -852,7 +879,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	 * needs to be redone.
 	 */
 #ifdef CONFIG_PREEMPT
-	rsm psr.i				// disable interrupts
+	RSM_PSR_I(p0, r17, r31)			// disable interrupts
 	cmp.eq p0,pLvSys=3Dr0,r0			// pLvSys=3D0: leave from kernel
 (pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
@@ -862,7 +889,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	;;
 	cmp.eq p6,p0=3Dr21,r0		// p6 <- pUStk || (preempt_count =3D 0)
 #else
-(pUStk)	rsm psr.i
+	RSM_PSR_I(pUStk, r17, r31)
 	cmp.eq p0,pLvSys=3Dr0,r0		// pLvSys=3D0: leave from kernel
 (pUStk)	cmp.eq.unc p6,p0=3Dr0,r0		// p6 <- pUStk
 #endif
@@ -910,7 +937,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	mov ar.csd=3Dr30
 	mov ar.ssd=3Dr31
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption =
collection
+	RSM_PSR_I_IC(r23, r22, r25)	// initiate turning off of interrupt and inte=
rruption collection
 	invala			// invalidate ALAT
 	;;
 	ld8.fill r22=3D[r2],24
@@ -942,7 +969,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	mov ar.ccv=3Dr15
 	;;
 	ldf.fill f11=3D[r2]
-	bsw.0			// switch back to bank 0 (no stop bit required beforehand...)
+	BSW_0(r2, r3, r15)	// switch back to bank 0 (no stop bit required beforeh=
and...)
 	;;
 (pUStk)	mov r18=3DIA64_KR(CURRENT)// M2 (12 cycle read latency)
 	adds r16=3DPT(CR_IPSR)+16,r12
@@ -950,12 +977,12 @@ GLOBAL_ENTRY(ia64_leave_kernel)
=20
 #ifdef CONFIG_VIRT_CPU_ACCOUNTING
 	.pred.rel.mutex pUStk,pKStk
-(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+	MOV_FROM_PSR(pKStk, r22, r29)	// M2 read PSR now that interrupts are disa=
bled=09
 (pUStk)	mov.m r22=3Dar.itc	// M  fetch time at leave
 	nop.i 0
 	;;
 #else
-(pKStk)	mov r22=3Dpsr		// M2 read PSR now that interrupts are disabled
+	MOV_FROM_PSR(pKStk, r22, r29)	// M2 read PSR now that interrupts are disa=
bled
 	nop.i 0
 	nop.i 0
 	;;
@@ -1027,7 +1054,7 @@ GLOBAL_ENTRY(ia64_leave_kernel)
 	 * NOTE: alloc, loadrs, and cover can't be predicated.
 	 */
 (pNonSys) br.cond.dpnt dont_preserve_current_frame
-	cover				// add current frame into dirty partition and set cr.ifs
+	COVER				// add current frame into dirty partition and set cr.ifs
 	;;
 	mov r19=3Dar.bsp			// get new backing store pointer
 rbs_switch:
@@ -1130,16 +1157,16 @@ skip_rbs_switch:
 (pKStk)	dep r29=3Dr22,r29,21,1	// I0 update ipsr.pp with psr.pp
 (pLvSys)mov r16=3Dr0		// A  clear r16 for leave_syscall, no-op otherwise
 	;;
-	mov cr.ipsr=3Dr29		// M2
+	MOV_TO_IPSR(r29, r25)	// M2
 	mov ar.pfs=3Dr26		// I0
 (pLvSys)mov r17=3Dr0		// A  clear r17 for leave_syscall, no-op otherwise
=20
-(p9)	mov cr.ifs=3Dr30		// M2
+	MOV_TO_IFS(p9, r30, r25)// M2
 	mov b0=3Dr21		// I0
 (pLvSys)mov r18=3Dr0		// A  clear r18 for leave_syscall, no-op otherwise
=20
 	mov ar.fpsr=3Dr20		// M2
-	mov cr.iip=3Dr28		// M2
+	MOV_TO_IIP(r28, r25)	// M2
 	nop 0
 	;;
 (pUStk)	mov ar.rnat=3Dr24		// M2 must happen with RSE in lazy mode
@@ -1148,7 +1175,7 @@ skip_rbs_switch:
=20
 	mov ar.rsc=3Dr27		// M2
 	mov pr=3Dr31,-1		// I0
-	rfi			// B
+	RFI			// B
=20
 	/*
 	 * On entry:
@@ -1170,36 +1197,37 @@ skip_rbs_switch:
 (pKStk) dep r21=3D-1,r0,PREEMPT_ACTIVE_BIT,1
 	;;
 (pKStk) st4 [r20]=3Dr21
-	ssm psr.i		// enable interrupts
+	SSM_PSR_I(p0, r2)	// enable interrupts
 #endif
 	br.call.spnt.many rp=3Dschedule
 .ret9:	cmp.eq p6,p0=3Dr0,r0				// p6 <- 1
-	rsm psr.i		// disable interrupts
+	RSM_PSR_I(p0, r2, r20)	// disable interrupts
 	;;
 #ifdef CONFIG_PREEMPT
 (pKStk)	adds r20=3DTI_PRE_COUNT+IA64_TASK_SIZE,r13
 	;;
 (pKStk)	st4 [r20]=3Dr0		// preempt_count() <- 0
 #endif
-(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
+(pLvSys)br.cond.sptk.few  __paravirt_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// re-check
=20
 .notify:
 (pUStk)	br.call.spnt.many rp=3Dnotify_resume_user
 .ret10:	cmp.ne p6,p0=3Dr0,r0				// p6 <- 0
-(pLvSys)br.cond.sptk.few  .work_pending_syscall_end
+(pLvSys)br.cond.sptk.few  __paravirt_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel	// don't re-check
=20
-.work_pending_syscall_end:
+.global __paravirt_pending_syscall_end;
+__paravirt_pending_syscall_end:
 	adds r2=3DPT(R8)+16,r12
 	adds r3=3DPT(R10)+16,r12
 	;;
 	ld8 r8=3D[r2]
 	ld8 r10=3D[r3]
-	br.cond.sptk.many .work_processed_syscall	// re-check
-
-END(ia64_leave_kernel)
+	br.cond.sptk.many __paravirt_work_processed_syscall_target	// re-check
+END(__paravirt_leave_kernel)
=20
+#ifdef __IA64_ASM_PARAVIRTUALIZED_NATIVE
 ENTRY(handle_syscall_error)
 	/*
 	 * Some system calls (e.g., ptrace, mmap) can return arbitrary values whi=
ch could
@@ -1238,7 +1266,7 @@ END(ia64_invoke_schedule_tail)
 	 * be set up by the caller.  We declare 8 input registers so the system c=
all
 	 * args get preserved, in case we need to restart a system call.
 	 */
-ENTRY(notify_resume_user)
+GLOBAL_ENTRY(notify_resume_user)
 	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
@@ -1300,7 +1328,7 @@ ENTRY(sys_rt_sigreturn)
 	adds sp=16,sp
 	;;
 	ld8 r9=3D[sp]				// load new ar.unat
-	mov.sptk b7=3Dr8,ia64_leave_kernel
+	mov.sptk b7=3Dr8,ia64_native_leave_kernel
 	;;
 	mov ar.unat=3Dr9
 	br.many b7
@@ -1659,3 +1687,4 @@ sys_call_table:
 	data8 sys_timerfd_gettime
=20
 	.org sys_call_table + 8*NR_syscalls	// guard against failures to increase=
 NR_syscalls
+#endif /* __IA64_ASM_PARAVIRTUALIZED_NATIVE */
diff --git a/arch/ia64/kernel/paravirt.c b/arch/ia64/kernel/paravirt.c
index e5482bb..7126ea8 100644
--- a/arch/ia64/kernel/paravirt.c
+++ b/arch/ia64/kernel/paravirt.c
@@ -286,3 +286,22 @@ struct pv_cpu_ops pv_cpu_ops =3D {
 			=3D ia64_native_intrin_local_irq_restore_func,
 };
 EXPORT_SYMBOL(pv_cpu_ops);
+
+/*************************************************************************=
*****
+ * replacement of hand written assembly codes.
+ */
+
+void
+paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch)
+{
+	extern unsigned long paravirt_switch_to_targ;
+	extern unsigned long paravirt_leave_syscall_targ;
+	extern unsigned long paravirt_work_processed_syscall_targ;
+	extern unsigned long paravirt_leave_kernel_targ;
+
+	paravirt_switch_to_targ =3D cpu_asm_switch->switch_to;
+	paravirt_leave_syscall_targ =3D cpu_asm_switch->leave_syscall;
+	paravirt_work_processed_syscall_targ +		cpu_asm_switch->work_processed_sy=
scall;
+	paravirt_leave_kernel_targ =3D cpu_asm_switch->leave_kernel;
+}
diff --git a/arch/ia64/kernel/paravirtentry.S b/arch/ia64/kernel/paravirten=
try.S
new file mode 100644
index 0000000..2f42fcb
--- /dev/null
+++ b/arch/ia64/kernel/paravirtentry.S
@@ -0,0 +1,60 @@
+/*************************************************************************=
*****
+ * linux/arch/ia64/xen/paravirtentry.S
+ *
+ * Copyright (c) 2008 Isaku Yamahata <yamahata at valinux co jp>
+ *                    VA Linux Systems Japan K.K.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  U=
SA
+ *
+ */
+
+#include <asm/asmmacro.h>
+#include <asm/asm-offsets.h>
+#include "entry.h"
+
+#define DATA8(sym, init_value)			\
+	.pushsection .data.read_mostly ;	\
+	.align 8 ;				\
+	.global sym ;				\
+	sym: ;					\
+	data8 init_value ;			\
+	.popsection
+
+#define BRANCH(targ, reg, breg)		\
+	movl reg=3Dtarg ;			\
+	;;				\
+	ld8 reg=3D[reg] ;			\
+	;;				\
+	mov breg=3Dreg ;			\
+	br.cond.sptk.many breg
+
+#define BRANCH_PROC(sym, reg, breg)				\
+	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ; \
+	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
+		BRANCH(paravirt_ ## sym ## _targ, reg, breg) ;	\
+	END(paravirt_ ## sym)
+
+#define BRANCH_PROC_UNWINFO(sym, reg, breg)			\
+	DATA8(paravirt_ ## sym ## _targ, ia64_native_ ## sym) ; \
+	GLOBAL_ENTRY(paravirt_ ## sym) ;			\
+		PT_REGS_UNWIND_INFO(0) ;			\
+		BRANCH(paravirt_ ## sym ## _targ, reg, breg) ;	\
+	END(paravirt_ ## sym)
+
+
+BRANCH_PROC(switch_to, r22, b7)
+BRANCH_PROC_UNWINFO(leave_syscall, r22, b7)
+BRANCH_PROC(work_processed_syscall, r2, b7)
+BRANCH_PROC_UNWINFO(leave_kernel, r22, b7)
diff --git a/include/asm-ia64/native/inst.h b/include/asm-ia64/native/inst.h
index c167b7d..1855dae 100644
--- a/include/asm-ia64/native/inst.h
+++ b/include/asm-ia64/native/inst.h
@@ -22,6 +22,14 @@
=20
 #define DO_SAVE_MIN		IA64_NATIVE_DO_SAVE_MIN
=20
+#define __paravirt_switch_to			ia64_native_switch_to
+#define __paravirt_leave_syscall		ia64_native_leave_syscall
+#define __paravirt_work_processed_syscall	ia64_native_work_processed_sysca=
ll
+#define __paravirt_leave_kernel			ia64_native_leave_kernel
+#define __paravirt_pending_syscall_end		ia64_work_pending_syscall_end
+#define __paravirt_work_processed_syscall_target \
+						ia64_work_processed_syscall
+
 #ifdef CONFIG_PARAVIRT_GUEST_ASM_CLOBBER_CHECK
 # define PARAVIRT_POISON	0xdeadbeefbaadf00d
 # define CLOBBER(clob)				\
diff --git a/include/asm-ia64/paravirt_privop.h b/include/asm-ia64/paravirt=
_privop.h
index 7b133ae..52482e6 100644
--- a/include/asm-ia64/paravirt_privop.h
+++ b/include/asm-ia64/paravirt_privop.h
@@ -80,12 +80,35 @@ extern unsigned long ia64_native_getreg_func(int regnum=
);
 			ia64_native_rsm(mask);	\
 	} while (0)
=20
+/*************************************************************************=
*****
+ * replacement of hand written assembly codes.
+ */
+struct pv_cpu_asm_switch {
+	unsigned long switch_to;
+	unsigned long leave_syscall;
+	unsigned long work_processed_syscall;
+	unsigned long leave_kernel;
+};
+void paravirt_cpu_asm_init(const struct pv_cpu_asm_switch *cpu_asm_switch);
+
 #endif /* __ASSEMBLY__ */
=20
+#define IA64_PARAVIRT_ASM_FUNC(name)	paravirt_ ## name
+
 #else
=20
 /* fallback for native case */
+#define IA64_PARAVIRT_ASM_FUNC(name)	ia64_native_ ## name
=20
 #endif /* CONFIG_PARAVIRT */
=20
+/* these routines utilize privilege-sensitive or performance-sensitive
+ * privileged instructions so the code must be replaced with
+ * paravirtualized versions */
+#define ia64_switch_to			IA64_PARAVIRT_ASM_FUNC(switch_to)
+#define ia64_leave_syscall		IA64_PARAVIRT_ASM_FUNC(leave_syscall)
+#define ia64_work_processed_syscall	\
+	IA64_PARAVIRT_ASM_FUNC(work_processed_syscall)
+#define ia64_leave_kernel		IA64_PARAVIRT_ASM_FUNC(leave_kernel)
+
 #endif /* _ASM_IA64_PARAVIRT_PRIVOP_H */
--=20
1.5.3

