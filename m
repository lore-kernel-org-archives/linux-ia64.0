From: David Mosberger <davidm@hpl.hp.com>
Date: Sat, 10 Jun 2000 01:07:23 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test1)
Message-Id: <marc-linux-ia64-105590678205127@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205111@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205111@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

An updated kernel diff is available in the usual place:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/linux-2.4.0-test1-ia64-00=
0609*

Summary of changes:

 - Stephen Zeisset's module related fixes to ia64_ksyms.c and pci.c.

 - Bill Nottingham's initrd additions.

 - Takayoshi Kouchi's pointer-lock related SMP fixes.

 - Jes Sorensen's mmap bug fix.

 - New unwind support now almost works.  Warning: don't enable
   CONFIG_IA64_NEW_UNWIND unless you have a bleeding edge toolchain
   with _all_ the unwind fixes.  Even then you may not want to turn
   it on as core-dump support hasn't been finished yet.

 - Without the new unwind support, the kernel now is conservative
   again and generates a switch_stack frame whenever there is a remote
   possibility that it might be needed.  This slows down several
   signal related operations, but it will be fast again once
   the new unwind support is complete.

I also added a printk whenever we get a timer tick before it was due.
Since that happens quite frequently, this quickly becomes annoying.
Look at it as an invitation to investigate the problem... ;-)

	--david

diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test1-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/entry.S	Fri Jun  9 17:09:56 2000
@@ -117,14 +117,11 @@
 	mov psr.l=3Dr17
 	;;
 	srlz.d
-
-	movl r28=1F
-	br.cond.sptk.many load_switch_stack
-1:	UNW(.restore sp)
-	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop switch_stack
+	DO_LOAD_SWITCH_STACK( )
 	br.ret.sptk.few rp
 END(ia64_switch_to)
=20
+#ifndef CONFIG_IA64_NEW_UNWIND
 	/*
 	 * Like save_switch_stack, but also save the stack frame that is active
 	 * at the time this function is called.
@@ -135,6 +132,8 @@
 	DO_SAVE_SWITCH_STACK
 	br.ret.sptk.few rp
 END(save_switch_stack_with_current_frame)
+#endif /* !CONFIG_IA64_NEW_UNWIND */
+
 /*
  * Note that interrupts are enabled during save_switch_stack and
  * load_switch_stack.  This means that we may get an interrupt with
@@ -343,7 +342,6 @@
 	;;
 	ld8.fill r4=3D[r2],16
 	ld8.fill r5=3D[r3],16
-	mov b7=3Dr28
 	;;
 	ld8.fill r6=3D[r2],16
 	ld8.fill r7=3D[r3],16
@@ -371,6 +369,19 @@
 	// also use it to preserve b6, which contains the syscall entry point.
 	//
 GLOBAL_ENTRY(invoke_syscall_trace)
+#ifdef CONFIG_IA64_NEW_UNWIND
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	alloc loc1=3Dar.pfs,8,3,0,0
+	mov loc0=3Drp
+	UNW(.body)
+	mov loc2=B6
+	;;
+	br.call.sptk.few rp=3Dsyscall_trace
+.ret3:	mov rp=3Dloc0
+	mov ar.pfs=3Dloc1
+	mov b6=3Dloc2
+	br.ret.sptk.few rp
+#else /* !CONFIG_IA64_NEW_SYSCALL */
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
 	alloc loc1=3Dar.pfs,8,3,0,0
 	;;			// WAW on CFM at the br.call
@@ -384,6 +395,7 @@
 	mov b6=3Dloc2
 	;;
 	br.ret.sptk.few rp
+#endif /* !CONFIG_IA64_NEW_SYSCALL */
 END(invoke_syscall_trace)
=20
 	//
@@ -802,112 +814,140 @@
 	// args get preserved, in case we need to restart a system call.
 	//
 ENTRY(handle_signal_delivery)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+#ifdef CONFIG_IA64_NEW_UNWIND
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
-
-	// If the process is being ptraced, the signal may not actually be delive=
red to
-	// the process.  Instead, SIGCHLD will be sent to the parent.  We need to
-	// setup a switch_stack so ptrace can inspect the processes state if nece=
ssary.
-	adds r2=3DIA64_TASK_FLAGS_OFFSET,r13
-	;;
-	ld8 r2=3D[r2]
+	mov loc0=3Drp				// save return address
+	.body
 	mov out0=3D0				// there is no "oldset"
-	adds out1=16,sp				// out1=3D&pt_regs
-	;;
+	adds out1=3D0,sp				// out1=3D&sigscratch
 (pSys)	mov out2=3D1				// out2=3D1 =3D> we're in a syscall
-	tbit.nz p16,p17=3Dr2,PF_PTRACED_BIT
-(p16)	br.cond.spnt.many setup_switch_stack
 	;;
-back_from_setup_switch_stack:
 (pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
-	adds r3=3D-IA64_SWITCH_STACK_SIZE+IA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16=
,sp
-(p17)	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp	// make space for (dummy) switc=
h_stack
-	;;
-(p17)	st8 [r3]=3Dr9				// save ar.unat in sw->caller_unat
-	mov loc0=3Drp				// save return address
-	UNW(.body)
+	.fframe 16
+	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
+	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
 	br.call.sptk.few rp=3Dia64_do_signal
 .ret11:
-	adds r3=3DIA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16,sp
+	.restore sp
+	adds sp=16,sp				// pop scratch stack space
 	;;
-	ld8 r9=3D[r3]				// load new unat from sw->caller_unat
+	ld8 r9=3D[sp]				// load new unat from sw->caller_unat
 	mov rp=3Dloc0
 	;;
-(p17)	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch_stack
-(p17)	mov ar.unat=3Dr9
-(p17)	mov ar.pfs=3Dloc1
-(p17)	br.ret.sptk.many rp
-
-	DO_LOAD_SWITCH_STACK( )		// restore the switch stack (ptrace may have mod=
ified it)
+	mov ar.unat=3Dr9
+	mov ar.pfs=3Dloc1
 	br.ret.sptk.many rp
-	// NOT REACHED
-
-setup_switch_stack:
-	UNW(.prologue)
-	mov r16=3Dloc1
+#else /* !CONFIG_IA64_NEW_UNWIND */
+	.prologue
+	alloc r16=3Dar.pfs,8,0,3,0 // preserve all eight input regs in case of sy=
scall restart!
 	DO_SAVE_SWITCH_STACK
 	UNW(.body)
-	br.cond.sptk.many back_from_setup_switch_stack
=20
+	mov out0=3D0				// there is no "oldset"
+	adds out1=16,sp				// out1=3D&sigscratch
+	.pred.rel.mutex pSys, pNonSys
+(pSys)	mov out2=3D1				// out2=3D1 =3D> we're in a syscall
+(pNonSys) mov out2=3D0				// out2=3D0 =3D> not a syscall
+	br.call.sptk.few rp=3Dia64_do_signal
+.ret11:
+	// restore the switch stack (ptrace may have modified it)
+	DO_LOAD_SWITCH_STACK( )
+	br.ret.sptk.many rp
+#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(handle_signal_delivery)
=20
 GLOBAL_ENTRY(sys_rt_sigsuspend)
-	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
-	alloc loc1=3Dar.pfs,2,2,3,0
-
-	// If the process is being ptraced, the signal may not actually be delive=
red to
-	// the process.  Instead, SIGCHLD will be sent to the parent.  We need to
-	// setup a switch_stack so ptrace can inspect the processes state if nece=
ssary.
-	// Also, the process might not ptraced until stopped in sigsuspend, so th=
is
-	// isn't something that we can do conditionally based upon the value of
-	// PF_PTRACED_BIT.
+#ifdef CONFIG_IA64_NEW_UNWIND
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8)
+	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
+	mov r9=3Dar.unat
+	mov loc0=3Drp				// save return address
 	mov out0=3Din0				// mask
 	mov out1=3Din1				// sigsetsize
+	adds out2=3D0,sp				// out2=3D&sigscratch
 	;;
-	adds out2=16,sp				// out1=3D&pt_regs
-	mov r16=3Dloc1
-	DO_SAVE_SWITCH_STACK
-	mov loc0=3Drp				// save return address
-	UNW(.body)
-	br.call.sptk.many rp=3Dia64_rt_sigsuspend
+	.fframe 16
+	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
+	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	.body
+	br.call.sptk.few rp=3Dia64_rt_sigsuspend
 .ret12:
-	adds r3=3DIA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16,sp
+	.restore sp
+	adds sp=16,sp				// pop scratch stack space
 	;;
-	ld8 r9=3D[r3]				// load new unat from sw->caller_unat
+	ld8 r9=3D[sp]				// load new unat from sw->caller_unat
 	mov rp=3Dloc0
 	;;
+	mov ar.unat=3Dr9
+	mov ar.pfs=3Dloc1
+	br.ret.sptk.many rp
+#else /* !CONFIG_IA64_NEW_UNWIND */
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
+	alloc r16=3Dar.pfs,2,0,3,0
+	DO_SAVE_SWITCH_STACK
+	UNW(.body)
+
+	mov out0=3Din0				// mask
+	mov out1=3Din1				// sigsetsize
+	adds out2=16,sp				// out1=3D&sigscratch
+	br.call.sptk.many rp=3Dia64_rt_sigsuspend
+.ret12:
 	// restore the switch stack (ptrace may have modified it)
-	DO_LOAD_SWITCH_STACK(PT_REGS_UNWIND_INFO)
+	DO_LOAD_SWITCH_STACK( )
 	br.ret.sptk.many rp
-	// NOT REACHED
+#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(sys_rt_sigsuspend)
=20
 ENTRY(sys_rt_sigreturn)
+#ifdef CONFIG_IA64_NEW_UNWIND
+	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
+	PT_REGS_UNWIND_INFO
+	.prologue
+	PT_REGS_SAVES(16)
+	adds sp=3D-16,sp
+	.body
+	cmp.eq pNonSys,p0=3Dr0,r0			// sigreturn isn't a normal syscall...
+	;;
+	adds out0=16,sp				// out0 =3D &sigscratch
+	br.call.sptk.few rp=3Dia64_rt_sigreturn
+.ret13:
+	adds sp=16,sp		// doesn't drop pt_regs, so don't mark it as restoring sp!
+	PT_REGS_UNWIND_INFO	// instead, create a new body section with the smalle=
r frame
+	;;
+	ld8 r9=3D[sp]				// load new ar.unat
+	mov b7=3Dr8
+	;;
+	mov ar.unat=3Dr9
+	br b7
+#else /* !CONFIG_IA64_NEW_UNWIND */
 	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
 	PT_REGS_UNWIND_INFO
-	adds out0=16,sp				// out0 =3D &pt_regs
 	UNW(.prologue)
 	UNW(.fframe IA64_PT_REGS_SIZE+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp rp, PT(CR_IIP)+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp ar.pfs, PT(CR_IFS)+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp ar.unat, PT(AR_UNAT)+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp pr, PT(PR)+IA64_SWITCH_STACK_SIZE)
-	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp	// make space for unat and padding
+	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
+	cmp.eq pNonSys,p0=3Dr0,r0			// sigreturn isn't a normal syscall...
 	;;
 	UNW(.body)
-	cmp.eq pNonSys,p0=3Dr0,r0			// sigreturn isn't a normal syscall...
+
+	adds out0=16,sp				// out0 =3D &sigscratch
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
 .ret13:
 	adds r3=3DIA64_SWITCH_STACK_CALLER_UNAT_OFFSET+16,sp
 	;;
 	ld8 r9=3D[r3]			// load new ar.unat
-	mov rp=3Dr8
+	mov b7=3Dr8
 	;;
 	PT_REGS_UNWIND_INFO
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch-stack frame
 	mov ar.unat=3Dr9
-	br rp
+	br b7
+#endif /* !CONFIG_IA64_NEW_UNWIND */
 END(sys_rt_sigreturn)
=20
 GLOBAL_ENTRY(ia64_prepare_handle_unaligned)
diff -urN linux-davidm/arch/ia64/kernel/ia64_ksyms.c linux-2.4.0-test1-lia/=
arch/ia64/kernel/ia64_ksyms.c
--- linux-davidm/arch/ia64/kernel/ia64_ksyms.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/ia64_ksyms.c	Fri Jun  9 17:10:26=
 2000
@@ -5,20 +5,15 @@
 #include <linux/config.h>
 #include <linux/module.h>
=20
-#include <asm/processor.h>
-EXPORT_SYMBOL(cpu_data);
-EXPORT_SYMBOL(kernel_thread);
-
-#include <asm/uaccess.h>
-EXPORT_SYMBOL(__copy_user);
-
 #include <linux/string.h>
-EXPORT_SYMBOL(memset);
+EXPORT_SYMBOL_NOVERS(memset);
 EXPORT_SYMBOL(memcmp);
-EXPORT_SYMBOL(memcpy);
+EXPORT_SYMBOL_NOVERS(memcpy);
+EXPORT_SYMBOL(memmove);
 EXPORT_SYMBOL(strcat);
 EXPORT_SYMBOL(strchr);
 EXPORT_SYMBOL(strcmp);
+EXPORT_SYMBOL(strcpy);
 EXPORT_SYMBOL(strlen);
 EXPORT_SYMBOL(strncat);
 EXPORT_SYMBOL(strncmp);
@@ -29,9 +24,41 @@
 EXPORT_SYMBOL(pci_alloc_consistent);
 EXPORT_SYMBOL(pci_free_consistent);
=20
+#include <linux/in6.h>
+#include <asm/checksum.h>
+EXPORT_SYMBOL(csum_partial_copy_nocheck);
+
 #include <asm/irq.h>
 EXPORT_SYMBOL(enable_irq);
 EXPORT_SYMBOL(disable_irq);
+
+#include <asm/current.h>
+#include <asm/hardirq.h>
+EXPORT_SYMBOL(irq_stat);
+
+#include <asm/processor.h>
+EXPORT_SYMBOL(cpu_data);
+EXPORT_SYMBOL(kernel_thread);
+
+#ifdef CONFIG_SMP
+EXPORT_SYMBOL(synchronize_irq);
+
+#include <asm/smplock.h>
+EXPORT_SYMBOL(kernel_flag);
+
+#include <asm/system.h>
+EXPORT_SYMBOL(__global_sti);
+EXPORT_SYMBOL(__global_cli);
+EXPORT_SYMBOL(__global_save_flags);
+EXPORT_SYMBOL(__global_restore_flags);
+
+#endif
+
+#include <asm/uaccess.h>
+EXPORT_SYMBOL(__copy_user);
+
+#include <asm/unistd.h>
+EXPORT_SYMBOL(__ia64_syscall);
=20
 /* from arch/ia64/lib */
 extern void __divdi3(void);
diff -urN linux-davidm/arch/ia64/kernel/mca_asm.S linux-2.4.0-test1-lia/arc=
h/ia64/kernel/mca_asm.S
--- linux-davidm/arch/ia64/kernel/mca_asm.S	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/mca_asm.S	Fri Jun  9 17:23:02 20=
00
@@ -6,7 +6,6 @@
 // 00/03/29 cfleck Added code to save INIT handoff state in pt_regs format=
, switch to temp kstack,
 //		   switch modes, jump to C INIT handler
 //
-#include <asm/offsets.h>
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 #include <asm/mca_asm.h>
diff -urN linux-davidm/arch/ia64/kernel/pci.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/pci.c	Fri Jun  9 17:23:13 2000
@@ -197,7 +197,7 @@
 	ranges->mem_end -=3D bus->resource[1]->start;
 }
=20
-int __init
+int
 pcibios_enable_device (struct pci_dev *dev)
 {
 	/* Not needed, since we enable all devices at startup.  */
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-test1-lia/arc=
h/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/process.c	Fri Jun  9 17:23:40 20=
00
@@ -311,7 +311,12 @@
 	dst[12] =3D pt->r12; dst[13] =3D pt->r13; dst[14] =3D pt->r14; dst[15] =
=3D pt->r15;
 	memcpy(dst + 16, &pt->r16, 16*8);	/* r16-r31 are contiguous */
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+	printk("ia64_elf_core_copy_regs: fix me, please?");
+	dst[32] =3D 0;
+#else
 	dst[32] =3D ia64_get_nat_bits(pt, sw);
+#endif
 	dst[33] =3D pt->pr;
=20
 	/* branch regs: */
@@ -332,6 +337,10 @@
 	struct switch_stack *sw =3D ((struct switch_stack *) pt) - 1;
 	struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+	printk("dump_fpu: fix me, please?");
+#endif
+
 	memset(dst, 0, sizeof (dst));	/* don't leak any "random" bits */
=20
 	/* f0 is 0.0 */  /* f1 is 1.0 */  dst[2] =3D sw->f2; dst[3] =3D sw->f3;
@@ -440,7 +449,7 @@
 	do {
 		if (unw_unwind(&info) < 0)
 			return 0;
-		ip =3D unw_get_ip(&info);
+		unw_get_ip(&info, &ip);
 		if (ip < first_sched || ip >=3D last_sched)
 			return ip;
 	} while (count++ < 16);
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/ptrace.c	Fri Jun  9 17:15:55 2000
@@ -33,6 +33,89 @@
 #define IPSR_WRITE_MASK	0x000006a00100003eUL
 #define IPSR_READ_MASK	IPSR_WRITE_MASK
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+
+#define PTRACE_DEBUG	1
+
+#if PTRACE_DEBUG
+# define dprintk(format...)	printk(format)
+# define inline
+#else
+# define dprintk(format...)
+#endif
+
+static int
+unwind_to_user (struct unw_frame_info *info, struct task_struct *child)
+{
+	unsigned long ip;
+
+	unw_init_from_blocked_task(info, child);
+	while (unw_unwind(info) >=3D 0) {
+		if (unw_get_rp(info, &ip) < 0) {
+			unw_get_ip(info, &ip);
+			dprintk("ptrace: failed to read return pointer (ip=3D0x%lx)\n", ip);
+			return -1;
+		}
+		if (ip < TASK_SIZE)
+			return 0;
+	}
+	unw_get_ip(info, &ip);
+	dprintk("ptrace: failed to unwind to user-level (ip=3D0x%lx)\n", ip);
+	return -1;
+}
+
+/*
+ * Collect the NaT bits for r1-r31 from scratch_unat and return a NaT
+ * bitset where bit i is set iff the NaT bit of register i is set.
+ */
+unsigned long
+ia64_get_scratch_nat_bits (struct pt_regs *pt, unsigned long scratch_unat)
+{
+#	define GET_BITS(first, last, unat)						\
+	({										\
+		unsigned long bit =3D ia64_unat_pos(&pt->r##first);			\
+		unsigned long mask =3D ((1UL << (last - first + 1)) - 1) << first;	\
+		(ia64_rotl(unat, first) >> bit) & mask;					\
+	})
+	unsigned long val;
+
+	val  =3D GET_BITS( 1,  3, scratch_unat);
+	val |=3D GET_BITS(12, 15, scratch_unat);
+	val |=3D GET_BITS( 8, 11, scratch_unat);
+	val |=3D GET_BITS(16, 31, scratch_unat);
+	return val;
+
+#	undef GET_BITS
+}
+
+/*
+ * Set the NaT bits for the scratch registers according to NAT and
+ * return the resulting unat (assuming the scratch registers are
+ * stored in PT).
+ */
+unsigned long
+ia64_put_scratch_nat_bits (struct pt_regs *pt, unsigned long nat)
+{
+	unsigned long scratch_unat;
+
+#	define PUT_BITS(first, last, nat)					\
+	({									\
+		unsigned long bit =3D ia64_unat_pos(&pt->r##first);		\
+		unsigned long mask =3D ((1UL << (last - first + 1)) - 1) << bit;	\
+		(ia64_rotr(nat, first) << bit) & mask;				\
+	})
+	scratch_unat  =3D PUT_BITS( 1,  3, nat);
+	scratch_unat |=3D PUT_BITS(12, 15, nat);
+	scratch_unat |=3D PUT_BITS( 8, 11, nat);
+	scratch_unat |=3D PUT_BITS(16, 31, nat);
+
+	return scratch_unat;
+
+#	undef PUT_BITS
+}
+
+#else /* !CONFIG_IA64_NEW_UNWIND */
+
 /*
  * Collect the NaT bits for r1-r31 from sw->caller_unat and
  * sw->ar_unat and return a NaT bitset where bit i is set iff the NaT
@@ -80,28 +163,26 @@
 #	undef PUT_BITS
 }
=20
-#define IA64_MLI_TEMPLATE	0x2
+#endif /* !CONFIG_IA64_NEW_UNWIND */
+
+#define IA64_MLX_TEMPLATE	0x2
 #define IA64_MOVL_OPCODE	6
=20
 void
 ia64_increment_ip (struct pt_regs *regs)
 {
-	unsigned long w0, w1, ri =3D ia64_psr(regs)->ri + 1;
+	unsigned long w0, ri =3D ia64_psr(regs)->ri + 1;
=20
 	if (ri > 2) {
 		ri =3D 0;
 		regs->cr_iip +=3D 16;
 	} else if (ri =3D 2) {
 		get_user(w0, (char *) regs->cr_iip + 0);
-		get_user(w1, (char *) regs->cr_iip + 8);
-		if (((w0 >> 1) & 0xf) =3D IA64_MLI_TEMPLATE && (w1 >> 60) =3D IA64_MOVL_=
OPCODE) {
+		if (((w0 >> 1) & 0xf) =3D IA64_MLX_TEMPLATE) {
 			/*
-			 * rfi'ing to slot 2 of an MLI bundle causes
+			 * rfi'ing to slot 2 of an MLX bundle causes
 			 * an illegal operation fault.  We don't want
-			 * that to happen...  Note that we check the
-			 * opcode only.  "movl" has a vc bit of 0, but
-			 * since a vc bit of 1 is currently reserved,
-			 * we might just as well treat it like a movl.
+			 * that to happen...
 			 */
 			ri =3D 0;
 			regs->cr_iip +=3D 16;
@@ -113,21 +194,17 @@
 void
 ia64_decrement_ip (struct pt_regs *regs)
 {
-	unsigned long w0, w1, ri =3D ia64_psr(regs)->ri - 1;
+	unsigned long w0, ri =3D ia64_psr(regs)->ri - 1;
=20
 	if (ia64_psr(regs)->ri =3D 0) {
 		regs->cr_iip -=3D 16;
 		ri =3D 2;
 		get_user(w0, (char *) regs->cr_iip + 0);
-		get_user(w1, (char *) regs->cr_iip + 8);
-		if (((w0 >> 1) & 0xf) =3D IA64_MLI_TEMPLATE && (w1 >> 60) =3D IA64_MOVL_=
OPCODE) {
+		if (((w0 >> 1) & 0xf) =3D IA64_MLX_TEMPLATE) {
 			/*
-			 * rfi'ing to slot 2 of an MLI bundle causes
+			 * rfi'ing to slot 2 of an MLX bundle causes
 			 * an illegal operation fault.  We don't want
-			 * that to happen...  Note that we check the
-			 * opcode only.  "movl" has a vc bit of 0, but
-			 * since a vc bit of 1 is currently reserved,
-			 * we might just as well treat it like a movl.
+			 * that to happen...
 			 */
 			ri =3D 1;
 		}
@@ -292,7 +369,11 @@
=20
 	laddr =3D (unsigned long *) addr;
 	child_regs =3D ia64_task_regs(child);
+#ifdef CONFIG_IA64_NEW_UNWIND
+	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
+#else
 	child_stack =3D (struct switch_stack *) child_regs - 1;
+#endif
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
@@ -336,7 +417,11 @@
=20
 	laddr =3D (unsigned long *) addr;
 	child_regs =3D ia64_task_regs(child);
+#ifdef CONFIG_IA64_NEW_UNWIND
+	child_stack =3D (struct switch_stack *) (child->thread.ksp + 16);
+#else
 	child_stack =3D (struct switch_stack *) child_regs - 1;
+#endif
 	bspstore =3D (unsigned long *) child_regs->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
@@ -395,21 +480,42 @@
                                     long new_bsp,
                                     int force_loadrs_to_zero)
 {
-	unsigned long *krbs, bspstore, bsp, krbs_num_regs, rbs_end, addr, val;
-	long ndirty, ret;
-	struct pt_regs *child_regs;
+	unsigned long *krbs, bspstore, *kbspstore, bsp, rbs_end, addr, val;
+	long ndirty, ret =3D 0;
+	struct pt_regs *child_regs =3D ia64_task_regs(child);
+
+#ifdef CONFIG_IA64_NEW_UNWIND
+	struct unw_frame_info info;
+	unsigned long cfm, sof;
+
+	if (unwind_to_user(&info, child) < 0)
+		return -1;
+
+	unw_get_bsp(&info, (unsigned long *) &kbspstore);
+
+	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
+	ndirty =3D ia64_rse_num_regs(krbs, krbs + (child_regs->loadrs >> 19));
+	bspstore =3D child_regs->ar_bspstore;
+	bsp =3D (long) ia64_rse_skip_regs((long *)bspstore, ndirty);
+
+	cfm =3D child_regs->cr_ifs;
+	if (!(cfm & (1UL << 63)))
+		unw_get_cfm(&info, &cfm);
+	sof =3D (cfm & 0x7f);
+	rbs_end =3D (long) ia64_rse_skip_regs((long *)bspstore, sof);
+#else
 	struct switch_stack *child_stack;
+	unsigned long krbs_num_regs;
=20
-	ret =3D 0;
-	child_regs =3D ia64_task_regs(child);
 	child_stack =3D (struct switch_stack *) child_regs - 1;
-
+	kbspstore =3D (unsigned long *) child_stack->ar_bspstore;
 	krbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
 	ndirty =3D ia64_rse_num_regs(krbs, krbs + (child_regs->loadrs >> 19));
 	bspstore =3D child_regs->ar_bspstore;
 	bsp =3D (long) ia64_rse_skip_regs((long *)bspstore, ndirty);
-	krbs_num_regs =3D ia64_rse_num_regs(krbs, (unsigned long *) child_stack->=
ar_bspstore);
+	krbs_num_regs =3D ia64_rse_num_regs(krbs, kbspstore);
 	rbs_end =3D (long) ia64_rse_skip_regs((long *)bspstore, krbs_num_regs);
+#endif
=20
 	/* Return early if nothing to do */
 	if (bsp =3D new_bsp)
@@ -438,13 +544,15 @@
 }
=20
 static void
-sync_thread_rbs (struct task_struct *child, int make_writable)
+sync_thread_rbs (struct task_struct *child, struct mm_struct *mm, int make=
_writable)
 {
 	struct task_struct *p;
 	read_lock(&tasklist_lock);
-	for_each_task(p) {
-		if (p->mm =3D child->mm && p->state !=3D TASK_RUNNING)
-			sync_kernel_register_backing_store(p, 0, make_writable);
+	{
+		for_each_task(p) {
+			if (p->mm =3D mm && p->state !=3D TASK_RUNNING)
+				sync_kernel_register_backing_store(p, 0, make_writable);
+		}
 	}
 	read_unlock(&tasklist_lock);
 	child->thread.flags |=3D IA64_THREAD_KRBS_SYNCED;
@@ -466,6 +574,234 @@
 	}
 }
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+
+#include <asm/unwind.h>
+
+static int
+access_fr (struct unw_frame_info *info, int regnum, int hi, unsigned long =
*data, int write_access)
+{
+	struct ia64_fpreg fpval;
+	int ret;
+
+	ret =3D unw_get_fr(info, regnum, &fpval);
+	if (ret < 0)
+		return ret;
+
+	if (write_access) {
+		fpval.u.bits[hi] =3D *data;
+		ret =3D unw_set_fr(info, regnum, fpval);
+	} else
+		*data =3D fpval.u.bits[hi];
+	return ret;
+}
+
+static int
+access_uarea (struct task_struct *child, unsigned long addr, unsigned long=
 *data, int write_access)
+{
+	unsigned long *ptr, *rbs, *bspstore, ndirty, regnum;
+	struct switch_stack *sw;
+	struct unw_frame_info info;
+	struct pt_regs *pt;
+
+	pt =3D ia64_task_regs(child);
+	sw =3D (struct switch_stack *) (child->thread.ksp + 16);
+
+	if ((addr & 0x7) !=3D 0) {
+		dprintk("ptrace: unaligned register address 0x%lx\n", addr);
+		return -1;
+	}
+
+	if (addr < PT_F127 + 16) {
+		/* accessing fph */
+		sync_fph(child);
+		ptr =3D (unsigned long *) ((unsigned long) &child->thread.fph + addr);
+	} else if (addr >=3D PT_F10 && addr < PT_F15 + 16) {
+		/* scratch registers untouched by kernel (saved in switch_stack) */
+		ptr =3D (unsigned long *) ((long) sw + addr - PT_NAT_BITS);
+	} else if (addr < PT_AR_LC + 8) {
+		/* preserved state: */
+		unsigned long nat_bits, scratch_unat, dummy =3D 0;
+		struct unw_frame_info info;
+		char nat =3D 0;
+		int ret;
+
+		if (unwind_to_user(&info, child) < 0)
+			return -1;
+
+		switch (addr) {
+		      case PT_NAT_BITS:
+			if (write_access) {
+				nat_bits =3D *data;
+				scratch_unat =3D ia64_put_scratch_nat_bits(pt, nat_bits);
+				if (unw_set_ar(&info, UNW_AR_UNAT, scratch_unat) < 0) {
+					dprintk("ptrace: failed to set ar.unat\n");
+					return -1;
+				}
+				for (regnum =3D 4; regnum <=3D 7; ++regnum) {
+					unw_get_gr(&info, regnum, &dummy, &nat);
+					unw_set_gr(&info, regnum, dummy, (nat_bits >> regnum) & 1);
+				}
+			} else {
+				if (unw_get_ar(&info, UNW_AR_UNAT, &scratch_unat) < 0) {
+					dprintk("ptrace: failed to read ar.unat\n");
+					return -1;
+				}
+				nat_bits =3D ia64_get_scratch_nat_bits(pt, scratch_unat);
+				for (regnum =3D 4; regnum <=3D 7; ++regnum) {
+					unw_get_gr(&info, regnum, &dummy, &nat);
+					nat_bits |=3D (nat !=3D 0) << regnum;
+				}
+				*data =3D nat_bits;
+			}
+			return 0;
+
+		      case PT_R4: case PT_R5: case PT_R6: case PT_R7:
+			if (write_access) {
+				/* read NaT bit first: */
+				ret =3D unw_get_gr(&info, (addr - PT_R4)/8 + 4, data, &nat);
+				if (ret < 0)
+					return ret;
+			}
+			return unw_access_gr(&info, (addr - PT_R4)/8 + 4, data, &nat,
+					     write_access);
+
+		      case PT_B1: case PT_B2: case PT_B3: case PT_B4: case PT_B5:
+			return unw_access_br(&info, (addr - PT_B1)/8 + 1, data, write_access);
+
+		      case PT_AR_LC:
+			return unw_access_ar(&info, UNW_AR_LC, data, write_access);
+
+		      default:
+			if (addr >=3D PT_F2 && addr < PT_F5 + 16)
+				return access_fr(&info, (addr - PT_F2)/16 + 2, (addr & 8) !=3D 0,
+						 data, write_access);
+			else if (addr >=3D PT_F16 && addr < PT_F31 + 16)
+				return access_fr(&info, (addr - PT_F16)/16 + 16, (addr & 8) !=3D 0,
+						 data, write_access);
+			else {
+				dprintk("ptrace: rejecting access to register address 0x%lx\n",
+					addr);
+				return -1;
+			}
+		}
+	} else if (addr < PT_F9+16) {
+		/* scratch state */
+		switch (addr) {
+		      case PT_AR_BSP:
+			if (write_access)
+				/* FIXME? Account for lack of ``cover'' in the syscall case */
+				return sync_kernel_register_backing_store(child, *data, 1);
+			else {
+				rbs =3D (unsigned long *) child + IA64_RBS_OFFSET/8;
+				bspstore =3D (unsigned long *) pt->ar_bspstore;
+				ndirty =3D ia64_rse_num_regs(rbs, rbs + (pt->loadrs >> 19));
+
+				/*
+				 * If we're in a system call, no ``cover'' was done.  So to
+				 * make things uniform, we'll add the appropriate displacement
+				 * onto bsp if we're in a system call.
+				 */
+				if (!(pt->cr_ifs & (1UL << 63))) {
+					struct unw_frame_info info;
+					unsigned long cfm;
+
+					if (unwind_to_user(&info, child) < 0)
+						return -1;
+
+					unw_get_cfm(&info, &cfm);
+					ndirty +=3D cfm & 0x7f;
+				}
+				*data =3D (unsigned long) ia64_rse_skip_regs(bspstore, ndirty);
+				return 0;
+			}
+
+		      case PT_CFM:
+			if (pt->cr_ifs & (1UL << 63)) {
+				if (write_access)
+					pt->cr_ifs =3D ((pt->cr_ifs & ~0x3fffffffffUL)
+						      | (*data & 0x3fffffffffUL));
+				else
+					*data =3D pt->cr_ifs & 0x3fffffffffUL;
+			} else {
+				/* kernel was entered through a system call */
+				unsigned long cfm;
+
+				if (unwind_to_user(&info, child) < 0)
+					return -1;
+
+				unw_get_cfm(&info, &cfm);
+				if (write_access)
+					unw_set_cfm(&info, ((cfm & ~0x3fffffffffU)
+							    | (*data & 0x3fffffffffUL)));
+				else
+					*data =3D cfm;
+			}
+			return 0;
+
+		      case PT_CR_IPSR:
+			if (write_access)
+				pt->cr_ipsr =3D ((*data & IPSR_WRITE_MASK)
+					       | (pt->cr_ipsr & ~IPSR_WRITE_MASK));
+			else
+				*data =3D (pt->cr_ipsr & IPSR_READ_MASK);
+			return 0;
+
+		      		   case PT_R1:  case PT_R2:  case PT_R3:
+		      case PT_R8:  case PT_R9:  case PT_R10: case PT_R11:
+		      case PT_R12: case PT_R13: case PT_R14: case PT_R15:
+		      case PT_R16: case PT_R17: case PT_R18: case PT_R19:
+		      case PT_R20: case PT_R21: case PT_R22: case PT_R23:
+		      case PT_R24: case PT_R25: case PT_R26: case PT_R27:
+		      case PT_R28: case PT_R29: case PT_R30: case PT_R31:
+		      case PT_B0:  case PT_B6:  case PT_B7:
+		      case PT_F6:  case PT_F6+8: case PT_F7: case PT_F7+8:
+		      case PT_F8:  case PT_F8+8: case PT_F9: case PT_F9+8:
+		      case PT_AR_BSPSTORE:
+		      case PT_AR_RSC: case PT_AR_UNAT: case PT_AR_PFS: case PT_AR_RNAT:
+		      case PT_AR_CCV: case PT_AR_FPSR: case PT_CR_IIP: case PT_PR:
+			/* scratch register */
+			ptr =3D (unsigned long *) ((long) pt + addr - PT_CR_IPSR);
+			break;
+
+		      default:
+			/* disallow accessing anything else... */
+			dprintk("ptrace: rejecting access to register address 0x%lx\n",
+				addr);
+			return -1;
+		}
+	} else {
+		/* access debug registers */
+
+		if (!(child->thread.flags & IA64_THREAD_DBG_VALID)) {
+			child->thread.flags |=3D IA64_THREAD_DBG_VALID;
+			memset(child->thread.dbr, 0, sizeof(child->thread.dbr));
+			memset(child->thread.ibr, 0, sizeof( child->thread.ibr));
+		}
+		if (addr >=3D PT_IBR) {
+			regnum =3D (addr - PT_IBR) >> 3;
+			ptr =3D &child->thread.ibr[0];
+		} else {
+			regnum =3D (addr - PT_DBR) >> 3;
+			ptr =3D &child->thread.dbr[0];
+		}
+
+		if (regnum >=3D 8) {
+			dprintk("ptrace: rejecting access to register address 0x%lx\n", addr);
+			return -1;
+		}
+
+		ptr +=3D regnum;
+	}
+	if (write_access)
+		*ptr =3D *data;
+	else
+		*data =3D *ptr;
+	return 0;
+}
+
+#else /* !CONFIG_IA64_NEW_UNWIND */
+
 static int
 access_uarea (struct task_struct *child, unsigned long addr, unsigned long=
 *data, int write_access)
 {
@@ -486,6 +822,13 @@
 		sw =3D (struct switch_stack *) pt - 1;
=20
 		switch (addr) {
+		      case PT_NAT_BITS:
+			if (write_access)
+				ia64_put_nat_bits(pt, sw, *data);
+			else
+				*data =3D ia64_get_nat_bits(pt, sw);
+			return 0;
+
 		      case PT_AR_BSP:
 			if (write_access)
 				/* FIXME? Account for lack of ``cover'' in the syscall case */
@@ -508,9 +851,6 @@
=20
 		      case PT_CFM:
 			if (write_access) {
-				pt =3D ia64_task_regs(child);
-				sw =3D (struct switch_stack *) pt - 1;
-
 				if (pt->cr_ifs & (1UL << 63))
 					pt->cr_ifs =3D ((pt->cr_ifs & ~0x3fffffffffUL)
 						      | (*data & 0x3fffffffffUL));
@@ -545,18 +885,26 @@
 		      case PT_R28: case PT_R29: case PT_R30: case PT_R31:
 		      case PT_B0: case PT_B1: case PT_B2: case PT_B3:
 		      case PT_B4: case PT_B5: case PT_B6: case PT_B7:
-		      case PT_F2: case PT_F3:
-		      case PT_F4:  case PT_F5:  case PT_F6:  case PT_F7:
-		      case PT_F8:  case PT_F9:  case PT_F10: case PT_F11:
-		      case PT_F12: case PT_F13: case PT_F14: case PT_F15:
-		      case PT_F16: case PT_F17: case PT_F18: case PT_F19:
-		      case PT_F20: case PT_F21: case PT_F22: case PT_F23:
-		      case PT_F24: case PT_F25: case PT_F26: case PT_F27:
-		      case PT_F28: case PT_F29: case PT_F30: case PT_F31:
-		      case PT_AR_LC: case PT_AR_UNAT: case PT_AR_PFS: case PT_AR_RNAT:
-		      case PT_AR_CCV: case PT_AR_FPSR:
-		      case PT_CR_IIP: case PT_PR:
-			ptr =3D (unsigned long *) ((long) sw + addr - PT_PRI_UNAT);
+		      case PT_F2: case PT_F2+8: case PT_F3: case PT_F3+8:
+		      case PT_F4: case PT_F4+8: case PT_F5: case PT_F5+8:
+		      case PT_F6: case PT_F6+8: case PT_F7: case PT_F7+8:
+  		      case PT_F8: case PT_F8+8: case PT_F9: case PT_F9+8:
+		      case PT_F10: case PT_F10+8: case PT_F11: case PT_F11+8:
+		      case PT_F12: case PT_F12+8: case PT_F13: case PT_F13+8:
+		      case PT_F14: case PT_F14+8: case PT_F15: case PT_F15+8:
+		      case PT_F16: case PT_F16+8: case PT_F17: case PT_F17+8:
+		      case PT_F18: case PT_F18+8: case PT_F19: case PT_F19+8:
+  		      case PT_F20: case PT_F20+8: case PT_F21: case PT_F21+8:
+		      case PT_F22: case PT_F22+8: case PT_F23: case PT_F23+8:=20
+		      case PT_F24: case PT_F24+8: case PT_F25: case PT_F25+8:
+		      case PT_F26: case PT_F26+8: case PT_F27: case PT_F27+8:
+ 		      case PT_F28: case PT_F28+8: case PT_F29: case PT_F29+8:
+		      case PT_F30: case PT_F30+8: case PT_F31: case PT_F31+8:
+		      case PT_AR_BSPSTORE:
+		      case PT_AR_RSC: case PT_AR_UNAT: case PT_AR_PFS: case PT_AR_RNAT:
+		      case PT_AR_CCV: case PT_AR_FPSR: case PT_CR_IIP: case PT_PR:
+		      case PT_AR_LC:
+			ptr =3D (unsigned long *) ((long) sw + addr - PT_NAT_BITS);
 			break;
=20
 		      default:
@@ -591,6 +939,8 @@
 	return 0;
 }
=20
+#endif /* !CONFIG_IA64_NEW_UNWIND */
+
 asmlinkage long
 sys_ptrace (long request, pid_t pid, unsigned long addr, unsigned long dat=
a,
 	    long arg4, long arg5, long arg6, long arg7, long stack)
@@ -613,17 +963,21 @@
=20
 	ret =3D -ESRCH;
 	read_lock(&tasklist_lock);
-	child =3D find_task_by_pid(pid);
+	{
+		child =3D find_task_by_pid(pid);
+		if (child)
+			get_task_struct(child);
+	}
 	read_unlock(&tasklist_lock);
 	if (!child)
 		goto out;
 	ret =3D -EPERM;
 	if (pid =3D 1)		/* no messing around with init! */
-		goto out;
+		goto out_tsk;
=20
 	if (request =3D PTRACE_ATTACH) {
 		if (child =3D current)
-			goto out;
+			goto out_tsk;
 		if ((!child->dumpable ||
 		    (current->uid !=3D child->euid) ||
 		    (current->uid !=3D child->suid) ||
@@ -632,10 +986,10 @@
 	 	    (current->gid !=3D child->sgid) ||
 	 	    (!cap_issubset(child->cap_permitted, current->cap_permitted)) ||
 	 	    (current->gid !=3D child->gid)) && !capable(CAP_SYS_PTRACE))
-			goto out;
+			goto out_tsk;
 		/* the same process cannot be attached many times */
 		if (child->flags & PF_PTRACED)
-			goto out;
+			goto out_tsk;
 		child->flags |=3D PF_PTRACED;
 		if (child->p_pptr !=3D current) {
 			unsigned long flags;
@@ -648,78 +1002,98 @@
 		}
 		send_sig(SIGSTOP, child, 1);
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
 	}
 	ret =3D -ESRCH;
 	if (!(child->flags & PF_PTRACED))
-		goto out;
+		goto out_tsk;
 	if (child->state !=3D TASK_STOPPED) {
 		if (request !=3D PTRACE_KILL)
-			goto out;
+			goto out_tsk;
 	}
 	if (child->p_pptr !=3D current)
-		goto out;
+		goto out_tsk;
=20
 	switch (request) {
 	      case PTRACE_PEEKTEXT:
 	      case PTRACE_PEEKDATA:		/* read word at location addr */
-	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)
-		    && atomic_read(&child->mm->mm_users) > 1)
-			sync_thread_rbs(child, 0);
+	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)) {
+			struct mm_struct *mm;
+			long do_sync;
+
+			task_lock(child);
+			{
+				mm =3D child->mm;
+				do_sync =3D mm && (atomic_read(&mm->mm_users) > 1);
+			}
+			task_unlock(child);
+			if (do_sync)
+				sync_thread_rbs(child, mm, 0);
+		}
 		ret =3D ia64_peek(regs, child, addr, &data);
 		if (ret =3D 0) {
 			ret =3D data;
 			regs->r8 =3D 0;	/* ensure "ret" is not mistaken as an error code */
 		}
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_POKETEXT:
 	      case PTRACE_POKEDATA:		/* write the word at location addr */
-	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)
-		    && atomic_read(&child->mm->mm_users) > 1)
-			sync_thread_rbs(child, 1);
+	        if (!(child->thread.flags & IA64_THREAD_KRBS_SYNCED)) {
+			struct mm_struct *mm;
+			long do_sync;
+
+			task_lock(child);
+			{
+				mm =3D child->mm;
+				do_sync =3D mm && (atomic_read(&child->mm->mm_users) > 1);
+			}
+			task_unlock(child);
+			if (do_sync)
+				sync_thread_rbs(child, mm, 1);
+		}
 		ret =3D ia64_poke(regs, child, addr, data);
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_PEEKUSR:		/* read the word at addr in the USER area */
 		if (access_uarea(child, addr, &data, 0) < 0) {
 			ret =3D -EIO;
-			goto out;
+			goto out_tsk;
 		}
 		ret =3D data;
 		regs->r8 =3D 0;	/* ensure "ret" is not mistaken as an error code */
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_POKEUSR:	      /* write the word at addr in the USER ar=
ea */
 		if (access_uarea(child, addr, &data, 1) < 0) {
 			ret =3D -EIO;
-			goto out;
+			goto out_tsk;
 		}
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_GETSIGINFO:
 		ret =3D -EIO;
 		if (!access_ok(VERIFY_WRITE, data, sizeof (siginfo_t))
 		    || child->thread.siginfo =3D 0)
-			goto out;
+			goto out_tsk;
 		copy_to_user((siginfo_t *) data, child->thread.siginfo, sizeof (siginfo_=
t));
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
 		break;
 	      case PTRACE_SETSIGINFO:
 		ret =3D -EIO;
 		if (!access_ok(VERIFY_READ, data, sizeof (siginfo_t))
 		    || child->thread.siginfo =3D 0)
-			goto out;
+			goto out_tsk;
 		copy_from_user(child->thread.siginfo, (siginfo_t *) data, sizeof (siginf=
o_t));
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
 	      case PTRACE_SYSCALL:	/* continue and stop at next (return from) sys=
call */
 	      case PTRACE_CONT:		/* restart after signal. */
 		ret =3D -EIO;
 		if (data > _NSIG)
-			goto out;
+			goto out_tsk;
 		if (request =3D PTRACE_SYSCALL)
 			child->flags |=3D PF_TRACESYS;
 		else
@@ -735,7 +1109,7 @@
=20
 		wake_up_process(child);
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_KILL:
 		/*
@@ -744,7 +1118,7 @@
 		 * that it wants to exit.
 		 */
 		if (child->state =3D TASK_ZOMBIE)		/* already dead */
-			goto out;
+			goto out_tsk;
 		child->exit_code =3D SIGKILL;
=20
 		/* make sure the single step/take-branch tra bits are not set: */
@@ -756,13 +1130,13 @@
=20
 		wake_up_process(child);
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_SINGLESTEP:		/* let child execute for one instruction */
 	      case PTRACE_SINGLEBLOCK:
 		ret =3D -EIO;
 		if (data > _NSIG)
-			goto out;
+			goto out_tsk;
=20
 		child->flags &=3D ~PF_TRACESYS;
 		if (request =3D PTRACE_SINGLESTEP) {
@@ -778,12 +1152,12 @@
 		/* give it a chance to run. */
 		wake_up_process(child);
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
=20
 	      case PTRACE_DETACH:		/* detach a process that was attached. */
 		ret =3D -EIO;
 		if (data > _NSIG)
-			goto out;
+			goto out_tsk;
=20
 		child->flags &=3D ~(PF_PTRACED|PF_TRACESYS);
 		child->exit_code =3D data;
@@ -802,12 +1176,14 @@
=20
 		wake_up_process(child);
 		ret =3D 0;
-		goto out;
+		goto out_tsk;
=20
 	      default:
 		ret =3D -EIO;
-		goto out;
+		goto out_tsk;
 	}
+  out_tsk:
+	free_task_struct(child);
   out:
 	unlock_kernel();
 	return ret;
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/setup.c	Fri Jun  9 17:16:12 2000
@@ -36,6 +36,10 @@
 #include <asm/efi.h>
 #include <asm/mca.h>
=20
+#ifdef CONFIG_BLK_DEV_RAM
+# include <linux/blk.h>
+#endif
+
 extern char _end;
=20
 /* cpu_data[bootstrap_processor] is data for the bootstrap processor: */
@@ -127,11 +131,22 @@
 	 * change APIs, they'd do things for the better.  Grumble...
 	 */
 	bootmap_start =3D PAGE_ALIGN(__pa(&_end));
+	if (ia64_boot_param.initrd_size)
+		bootmap_start =3D PAGE_ALIGN(bootmap_start + ia64_boot_param.initrd_size=
);
 	bootmap_size =3D init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
=20
 	efi_memmap_walk(free_available_memory, 0);
=20
 	reserve_bootmem(bootmap_start, bootmap_size);
+#ifdef CONFIG_BLK_DEV_INITRD
+	initrd_start =3D ia64_boot_param.initrd_start;
+	if (initrd_start) {
+		initrd_end =3D initrd_start+ia64_boot_param.initrd_size;
+		printk("Initial ramdisk at: 0x%p (%lu bytes)\n",
+		       (void *) initrd_start, ia64_boot_param.initrd_size);
+		reserve_bootmem(virt_to_phys(initrd_start), ia64_boot_param.initrd_size);
+	}
+#endif
 #if 0
 	/* XXX fix me */
 	init_mm.start_code =3D (unsigned long) &_stext;
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/signal.c	Fri Jun  9 17:16:43 2000
@@ -37,16 +37,26 @@
 # define GET_SIGSET(k,u)	__get_user((k)->sig[0], &(u)->sig[0])
 #endif
=20
+struct sigscratch {
+#ifdef CONFIG_IA64_NEW_UNWIND
+	unsigned long scratch_unat;	/* ar.unat for the general registers saved in=
 pt */
+	unsigned long pad;
+#else
+	struct switch_stack sw;
+#endif
+	struct pt_regs pt;
+};
+
 struct sigframe {
 	struct siginfo info;
 	struct sigcontext sc;
 };
=20
 extern long sys_wait4 (int, int *, int, struct rusage *);
-extern long ia64_do_signal (sigset_t *, struct pt_regs *, long);	/* forwar=
d decl */
+extern long ia64_do_signal (sigset_t *, struct sigscratch *, long);	/* for=
ward decl */
=20
 long
-ia64_rt_sigsuspend (sigset_t *uset, size_t sigsetsize, struct pt_regs *pt)
+ia64_rt_sigsuspend (sigset_t *uset, size_t sigsetsize, struct sigscratch *=
scr)
 {
 	sigset_t oldset, set;
=20
@@ -72,18 +82,18 @@
 	 * get saved in sigcontext by ia64_do_signal.
 	 */
 #ifdef CONFIG_IA32_SUPPORT
-        if (IS_IA32_PROCESS(pt)) {
-                pt->r8 =3D -EINTR;
+        if (IS_IA32_PROCESS(&scr->pt)) {
+                scr->pt.r8 =3D -EINTR;
         } else
 #endif
 	{
-		pt->r8 =3D EINTR;
-		pt->r10 =3D -1;
+		scr->pt.r8 =3D EINTR;
+		scr->pt.r10 =3D -1;
 	}
 	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule();
-		if (ia64_do_signal(&oldset, pt, 1))
+		if (ia64_do_signal(&oldset, scr, 1))
 			return -EINTR;
 	}
 }
@@ -98,9 +108,8 @@
 }
=20
 static long
-restore_sigcontext (struct sigcontext *sc, struct pt_regs *pt)
+restore_sigcontext (struct sigcontext *sc, struct sigscratch *scr)
 {
-	struct switch_stack *sw =3D (struct switch_stack *) pt - 1;
 	unsigned long ip, flags, nat, um, cfm;
 	long err;
=20
@@ -111,28 +120,32 @@
 	err |=3D __get_user(ip, &sc->sc_ip);			/* instruction pointer */
 	err |=3D __get_user(cfm, &sc->sc_cfm);
 	err |=3D __get_user(um, &sc->sc_um);			/* user mask */
-	err |=3D __get_user(pt->ar_rsc, &sc->sc_ar_rsc);
-	err |=3D __get_user(pt->ar_ccv, &sc->sc_ar_ccv);
-	err |=3D __get_user(pt->ar_unat, &sc->sc_ar_unat);
-	err |=3D __get_user(pt->ar_fpsr, &sc->sc_ar_fpsr);
-	err |=3D __get_user(pt->ar_pfs, &sc->sc_ar_pfs);
-	err |=3D __get_user(pt->pr, &sc->sc_pr);			/* predicates */
-	err |=3D __get_user(pt->b0, &sc->sc_br[0]);		/* b0 (rp) */
-	err |=3D __get_user(pt->b6, &sc->sc_br[6]);		/* b6 */
-	err |=3D __get_user(pt->b7, &sc->sc_br[7]);		/* b7 */
-	err |=3D __copy_from_user(&pt->r1, &sc->sc_gr[1], 3*8);	/* r1-r3 */
-	err |=3D __copy_from_user(&pt->r8, &sc->sc_gr[8], 4*8);	/* r8-r11 */
-	err |=3D __copy_from_user(&pt->r12, &sc->sc_gr[12], 4*8);	/* r12-r15 */
-	err |=3D __copy_from_user(&pt->r16, &sc->sc_gr[16], 16*8);	/* r16-r31 */
+	err |=3D __get_user(scr->pt.ar_rsc, &sc->sc_ar_rsc);
+	err |=3D __get_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);
+	err |=3D __get_user(scr->pt.ar_unat, &sc->sc_ar_unat);
+	err |=3D __get_user(scr->pt.ar_fpsr, &sc->sc_ar_fpsr);
+	err |=3D __get_user(scr->pt.ar_pfs, &sc->sc_ar_pfs);
+	err |=3D __get_user(scr->pt.pr, &sc->sc_pr);		/* predicates */
+	err |=3D __get_user(scr->pt.b0, &sc->sc_br[0]);		/* b0 (rp) */
+	err |=3D __get_user(scr->pt.b6, &sc->sc_br[6]);		/* b6 */
+	err |=3D __get_user(scr->pt.b7, &sc->sc_br[7]);		/* b7 */
+	err |=3D __copy_from_user(&scr->pt.r1, &sc->sc_gr[1], 3*8);	/* r1-r3 */
+	err |=3D __copy_from_user(&scr->pt.r8, &sc->sc_gr[8], 4*8);	/* r8-r11 */
+	err |=3D __copy_from_user(&scr->pt.r12, &sc->sc_gr[12], 4*8);	/* r12-r15 =
*/
+	err |=3D __copy_from_user(&scr->pt.r16, &sc->sc_gr[16], 16*8);	/* r16-r31=
 */
=20
-	pt->cr_ifs =3D cfm | (1UL << 63);
+	scr->pt.cr_ifs =3D cfm | (1UL << 63);
=20
 	/* establish new instruction pointer: */
-	pt->cr_iip =3D ip & ~0x3UL;
-	ia64_psr(pt)->ri =3D ip & 0x3;
-	pt->cr_ipsr =3D (pt->cr_ipsr & ~IA64_PSR_UM) | (um & IA64_PSR_UM);
-
-	ia64_put_nat_bits (pt, sw, nat);	/* restore the original scratch NaT bits=
 */
+	scr->pt.cr_iip =3D ip & ~0x3UL;
+	ia64_psr(&scr->pt)->ri =3D ip & 0x3;
+	scr->pt.cr_ipsr =3D (scr->pt.cr_ipsr & ~IA64_PSR_UM) | (um & IA64_PSR_UM);
+
+#ifdef CONFIG_IA64_NEW_UNWIND
+	scr->scratch_unat =3D ia64_put_scratch_nat_bits(&scr->pt, nat);
+#else
+	ia64_put_nat_bits(&scr->pt, &scr->sw, nat);	/* restore the original scrat=
ch NaT bits */
+#endif
=20
 	if (flags & IA64_SC_FLAG_FPH_VALID) {
 		struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
@@ -186,15 +199,8 @@
 	}
 }
=20
-/*
- * When we get here, ((struct switch_stack *) pt - 1) is a
- * switch_stack frame that has no defined value.  Upon return, we
- * expect sw->caller_unat to contain the new unat value.  The reason
- * we use a full switch_stack frame is so everything is symmetric
- * with ia64_do_signal().
- */
 long
-ia64_rt_sigreturn (struct pt_regs *pt)
+ia64_rt_sigreturn (struct sigscratch *scr)
 {
 	extern char ia64_strace_leave_kernel, ia64_leave_kernel;
 	struct sigcontext *sc;
@@ -202,7 +208,7 @@
 	sigset_t set;
 	long retval;
=20
-	sc =3D &((struct sigframe *) (pt->r12 + 16))->sc;
+	sc =3D &((struct sigframe *) (scr->pt.r12 + 16))->sc;
=20
 	/*
 	 * When we return to the previously executing context, r8 and
@@ -234,18 +240,18 @@
 	recalc_sigpending(current);
 	spin_unlock_irq(&current->sigmask_lock);
=20
-	if (restore_sigcontext(sc, pt))
+	if (restore_sigcontext(sc, scr))
 		goto give_sigsegv;
=20
 #if DEBUG_SIG
 	printk("SIG return (%s:%d): sp=3D%lx ip=3D%lx\n",
-	       current->comm, current->pid, pt->r12, pt->cr_iip);
+	       current->comm, current->pid, scr->pt.r12, scr->pt.cr_iip);
 #endif
 	/*
 	 * It is more difficult to avoid calling this function than to
 	 * call it and ignore errors.
 	 */
-	do_sigaltstack(&sc->sc_stack, 0, pt->r12);
+	do_sigaltstack(&sc->sc_stack, 0, scr->pt.r12);
 	return retval;
=20
   give_sigsegv:
@@ -266,14 +272,13 @@
  * trampoline starts.  Everything else is done at the user-level.
  */
 static long
-setup_sigcontext (struct sigcontext *sc, sigset_t *mask, struct pt_regs *p=
t)
+setup_sigcontext (struct sigcontext *sc, sigset_t *mask, struct sigscratch=
 *scr)
 {
-	struct switch_stack *sw =3D (struct switch_stack *) pt - 1;
 	struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
 	unsigned long flags =3D 0, ifs, nat;
 	long err;
=20
-	ifs =3D pt->cr_ifs;
+	ifs =3D scr->pt.cr_ifs;
=20
 	if (on_sig_stack((unsigned long) sc))
 		flags |=3D IA64_SC_FLAG_ONSTACK;
@@ -293,46 +298,49 @@
 	 * Note: sw->ar_unat is UNDEFINED unless the process is being
 	 * PTRACED.  However, this is OK because the NaT bits of the
 	 * preserved registers (r4-r7) are never being looked at by
-	 * the signal handler (register r4-r7 are used instead).
+	 * the signal handler (registers r4-r7 are used instead).
 	 */
-	nat =3D ia64_get_nat_bits(pt, sw);
+#ifdef CONFIG_IA64_NEW_UNWIND
+	nat =3D ia64_get_scratch_nat_bits(&scr->pt, scr->scratch_unat);
+#else
+	nat =3D ia64_get_nat_bits(&scr->pt, &scr->sw);
+#endif
=20
 	err  =3D __put_user(flags, &sc->sc_flags);
=20
 	err |=3D __put_user(nat, &sc->sc_nat);
 	err |=3D PUT_SIGSET(mask, &sc->sc_mask);
-	err |=3D __put_user(pt->cr_ipsr & IA64_PSR_UM, &sc->sc_um);
-	err |=3D __put_user(pt->ar_rsc, &sc->sc_ar_rsc);
-	err |=3D __put_user(pt->ar_ccv, &sc->sc_ar_ccv);
-	err |=3D __put_user(pt->ar_unat, &sc->sc_ar_unat);		/* ar.unat */
-	err |=3D __put_user(pt->ar_fpsr, &sc->sc_ar_fpsr);		/* ar.fpsr */
-	err |=3D __put_user(pt->ar_pfs, &sc->sc_ar_pfs);
-	err |=3D __put_user(pt->pr, &sc->sc_pr);				/* predicates */
-	err |=3D __put_user(pt->b0, &sc->sc_br[0]);			/* b0 (rp) */
-	err |=3D __put_user(pt->b6, &sc->sc_br[6]);			/* b6 */
-	err |=3D __put_user(pt->b7, &sc->sc_br[7]);			/* b7 */
-
-	err |=3D __copy_to_user(&sc->sc_gr[1], &pt->r1, 3*8);		/* r1-r3 */
-	err |=3D __copy_to_user(&sc->sc_gr[8], &pt->r8, 4*8);		/* r8-r11 */
-	err |=3D __copy_to_user(&sc->sc_gr[12], &pt->r12, 4*8);		/* r12-r15 */
-	err |=3D __copy_to_user(&sc->sc_gr[16], &pt->r16, 16*8);		/* r16-r31 */
+	err |=3D __put_user(scr->pt.cr_ipsr & IA64_PSR_UM, &sc->sc_um);
+	err |=3D __put_user(scr->pt.ar_rsc, &sc->sc_ar_rsc);
+	err |=3D __put_user(scr->pt.ar_ccv, &sc->sc_ar_ccv);
+	err |=3D __put_user(scr->pt.ar_unat, &sc->sc_ar_unat);		/* ar.unat */
+	err |=3D __put_user(scr->pt.ar_fpsr, &sc->sc_ar_fpsr);		/* ar.fpsr */
+	err |=3D __put_user(scr->pt.ar_pfs, &sc->sc_ar_pfs);
+	err |=3D __put_user(scr->pt.pr, &sc->sc_pr);			/* predicates */
+	err |=3D __put_user(scr->pt.b0, &sc->sc_br[0]);			/* b0 (rp) */
+	err |=3D __put_user(scr->pt.b6, &sc->sc_br[6]);			/* b6 */
+	err |=3D __put_user(scr->pt.b7, &sc->sc_br[7]);			/* b7 */
+
+	err |=3D __copy_to_user(&sc->sc_gr[1], &scr->pt.r1, 3*8);		/* r1-r3 */
+	err |=3D __copy_to_user(&sc->sc_gr[8], &scr->pt.r8, 4*8);		/* r8-r11 */
+	err |=3D __copy_to_user(&sc->sc_gr[12], &scr->pt.r12, 4*8);	/* r12-r15 */
+	err |=3D __copy_to_user(&sc->sc_gr[16], &scr->pt.r16, 16*8);	/* r16-r31 */
=20
-	err |=3D __put_user(pt->cr_iip + ia64_psr(pt)->ri, &sc->sc_ip);
-	err |=3D __put_user(pt->r12, &sc->sc_gr[12]);			/* r12 */
+	err |=3D __put_user(scr->pt.cr_iip + ia64_psr(&scr->pt)->ri, &sc->sc_ip);
 	return err;
 }
=20
 static long
-setup_frame (int sig, struct k_sigaction *ka, siginfo_t *info, sigset_t *s=
et, struct pt_regs *pt)
+setup_frame (int sig, struct k_sigaction *ka, siginfo_t *info, sigset_t *s=
et,
+	     struct sigscratch *scr)
 {
-	struct switch_stack *sw =3D (struct switch_stack *) pt - 1;
 	extern char ia64_sigtramp[], __start_gate_section[];
 	unsigned long tramp_addr, new_rbs =3D 0;
 	struct sigframe *frame;
 	struct siginfo si;
 	long err;
=20
-	frame =3D (void *) pt->r12;
+	frame =3D (void *) scr->pt.r12;
 	tramp_addr =3D GATE_ADDR + (ia64_sigtramp - __start_gate_section);
 	if ((ka->sa.sa_flags & SA_ONSTACK) !=3D 0 && !on_sig_stack((unsigned long=
) frame)) {
 		new_rbs  =3D (current->sas_ss_sp + sizeof(long) - 1) & ~(sizeof(long) - =
1);
@@ -348,31 +356,39 @@
=20
 	err |=3D __put_user(current->sas_ss_sp, &frame->sc.sc_stack.ss_sp);
 	err |=3D __put_user(current->sas_ss_size, &frame->sc.sc_stack.ss_size);
-	err |=3D __put_user(sas_ss_flags(pt->r12), &frame->sc.sc_stack.ss_flags);
-	err |=3D setup_sigcontext(&frame->sc, set, pt);
+	err |=3D __put_user(sas_ss_flags(scr->pt.r12), &frame->sc.sc_stack.ss_fla=
gs);
+	err |=3D setup_sigcontext(&frame->sc, set, scr);
=20
 	if (err)
 		goto give_sigsegv;
=20
-	pt->r12 =3D (unsigned long) frame - 16;		/* new stack pointer */
-	pt->r2  =3D sig;					/* signal number */
-	pt->r3  =3D (unsigned long) ka->sa.sa_handler;	/* addr. of handler's proc=
. descriptor */
-	pt->r15 =3D new_rbs;
-	pt->ar_fpsr =3D FPSR_DEFAULT;			/* reset fpsr for signal handler */
-	pt->cr_iip =3D tramp_addr;
-	ia64_psr(pt)->ri =3D 0;				/* start executing in first slot */
+	scr->pt.r12 =3D (unsigned long) frame - 16;		/* new stack pointer */
+	scr->pt.r2  =3D sig;					/* signal number */
+	scr->pt.r3  =3D (unsigned long) ka->sa.sa_handler;	/* addr. of handler's =
proc desc */
+	scr->pt.r15 =3D new_rbs;
+	scr->pt.ar_fpsr =3D FPSR_DEFAULT;			/* reset fpsr for signal handler */
+	scr->pt.cr_iip =3D tramp_addr;
+	ia64_psr(&scr->pt)->ri =3D 0;			/* start executing in first slot */
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+	/*
+	 * Note: this affects only the NaT bits of the scratch regs
+	 * (the ones saved in pt_regs), which is exactly what we want.
+	 */
+	scr->scratch_unat =3D 0; /* ensure NaT bits of at least r2, r3, r12, and =
r15 are clear */
+#else
 	/*
 	 * Note: this affects only the NaT bits of the scratch regs
-	 * (the ones saved in pt_regs, which is exactly what we want.
+	 * (the ones saved in pt_regs), which is exactly what we want.
 	 * The NaT bits for the preserved regs (r4-r7) are in
 	 * sw->ar_unat iff this process is being PTRACED.
 	 */
-	sw->caller_unat =3D 0;	/* ensure NaT bits of at least r2, r3, r12, and r1=
5 are clear */
+	scr->sw.caller_unat =3D 0; /* ensure NaT bits of at least r2, r3, r12, an=
d r15 are clear */
+#endif
=20
 #if DEBUG_SIG
 	printk("SIG deliver (%s:%d): sig=3D%d sp=3D%lx ip=3D%lx handler=3D%lx\n",
-	       current->comm, current->pid, sig, pt->r12, pt->cr_iip, pt->r3);
+	       current->comm, current->pid, sig, scr->pt.r12, scr->pt.cr_iip, scr=
->pt.r3);
 #endif
 	return 1;
=20
@@ -391,17 +407,17 @@
=20
 static long
 handle_signal (unsigned long sig, struct k_sigaction *ka, siginfo_t *info,=
 sigset_t *oldset,
-	       struct pt_regs *pt)
+	       struct sigscratch *scr)
 {
 #ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(pt)) {
+	if (IS_IA32_PROCESS(&scr->pt)) {
 		/* send signal to IA-32 process */
-		if (!ia32_setup_frame1(sig, ka, info, oldset, pt))
+		if (!ia32_setup_frame1(sig, ka, info, oldset, &scr->pt))
 			return 0;
 	} else
 #endif
 	/* send signal to IA-64 process */
-	if (!setup_frame(sig, ka, info, oldset, pt))
+	if (!setup_frame(sig, ka, info, oldset, scr))
 		return 0;
=20
 	if (ka->sa.sa_flags & SA_ONESHOT)
@@ -418,12 +434,6 @@
 }
=20
 /*
- * When we get here, `pt' points to struct pt_regs and ((struct
- * switch_stack *) pt - 1) points to a switch stack structure.
- * HOWEVER, in the normal case, the ONLY value valid in the
- * switch_stack is the caller_unat field.  The entire switch_stack is
- * valid ONLY if current->flags has PF_PTRACED set.
- *
  * Note that `init' is a special process: it doesn't get signals it
  * doesn't want to handle.  Thus you cannot kill init even with a
  * SIGKILL even by mistake.
@@ -433,26 +443,26 @@
  * user-level signal handling stack-frames in one go after that.
  */
 long
-ia64_do_signal (sigset_t *oldset, struct pt_regs *pt, long in_syscall)
+ia64_do_signal (sigset_t *oldset, struct sigscratch *scr, long in_syscall)
 {
 	struct k_sigaction *ka;
 	siginfo_t info;
 	long restart =3D in_syscall;
-	long errno =3D pt->r8;
+	long errno =3D scr->pt.r8;
=20
 	/*
 	 * In the ia64_leave_kernel code path, we want the common case
 	 * to go fast, which is why we may in certain cases get here
 	 * from kernel mode. Just return without doing anything if so.
 	 */
-	if (!user_mode(pt))
+	if (!user_mode(&scr->pt))
 		return 0;
=20
 	if (!oldset)
 		oldset =3D &current->blocked;
=20
 #ifdef CONFIG_IA32_SUPPORT
-	if (IS_IA32_PROCESS(pt)) {
+	if (IS_IA32_PROCESS(&scr->pt)) {
 		if (in_syscall) {
 			if (errno >=3D 0)
 				restart =3D 0;
@@ -461,7 +471,7 @@
 		}
 	} else
 #endif
-	if (pt->r10 !=3D -1) {
+	if (scr->pt.r10 !=3D -1) {
 		/*
 		 * A system calls has to be restarted only if one of
 		 * the error codes ERESTARTNOHAND, ERESTARTSYS, or
@@ -555,7 +565,7 @@
 			      case SIGQUIT: case SIGILL: case SIGTRAP:
 			      case SIGABRT: case SIGFPE: case SIGSEGV:
 			      case SIGBUS: case SIGSYS: case SIGXCPU: case SIGXFSZ:
-				if (do_coredump(signr, pt))
+				if (do_coredump(signr, &scr->pt))
 					exit_code |=3D 0x80;
 				/* FALLTHRU */
=20
@@ -575,29 +585,29 @@
 				if ((ka->sa.sa_flags & SA_RESTART) =3D 0) {
 			      case ERESTARTNOHAND:
 #ifdef CONFIG_IA32_SUPPORT
-					if (IS_IA32_PROCESS(pt))
-						pt->r8 =3D -EINTR;
+					if (IS_IA32_PROCESS(&scr->pt))
+						scr->pt.r8 =3D -EINTR;
 					else
 #endif
-					pt->r8 =3D EINTR;
-					/* note: pt->r10 is already -1 */
+					scr->pt.r8 =3D EINTR;
+					/* note: scr->pt.r10 is already -1 */
 					break;
 				}
 			      case ERESTARTNOINTR:
-#ifdef CONFIG_IA32_SUPPOT
-				if (IS_IA32_PROCESS(pt)) {
-					pt->r8 =3D pt->r1;
-					pt->cr_iip -=3D 2;
+#ifdef CONFIG_IA32_SUPPORT
+				if (IS_IA32_PROCESS(&scr->pt)) {
+					scr->pt.r8 =3D scr->pt.r1;
+					scr->pt.cr_iip -=3D 2;
 				} else
 #endif
-				ia64_decrement_ip(pt);
+				ia64_decrement_ip(&scr->pt);
 			}
 		}
=20
 		/* Whee!  Actually deliver the signal.  If the
 		   delivery failed, we need to continue to iterate in
 		   this loop so we can deliver the SIGSEGV... */
-		if (handle_signal(signr, ka, &info, oldset, pt))
+		if (handle_signal(signr, ka, &info, oldset, scr))
 			return 1;
 	}
=20
@@ -606,9 +616,9 @@
 		/* Restart the system call - no handlers present */
 		if (errno =3D ERESTARTNOHAND || errno =3D ERESTARTSYS || errno =3D EREST=
ARTNOINTR) {
 #ifdef CONFIG_IA32_SUPPORT
-			if (IS_IA32_PROCESS(pt)) {
-				pt->r8 =3D pt->r1;
-				pt->cr_iip -=3D 2;
+			if (IS_IA32_PROCESS(&scr->pt)) {
+				scr->pt.r8 =3D scr->pt.r1;
+				scr->pt.cr_iip -=3D 2;
 			} else
 #endif
 			/*
@@ -617,7 +627,7 @@
 			 * is adjust ip so that the "break"
 			 * instruction gets re-executed.
 			 */
-			ia64_decrement_ip(pt);
+			ia64_decrement_ip(&scr->pt);
 		}
 	}
 	return 0;
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/smp.c	Fri Jun  9 17:49:36 2000
@@ -81,7 +81,6 @@
 #ifndef CONFIG_ITANIUM_PTCG
 # define IPI_FLUSH_TLB		3
 #endif	/*!CONFIG_ITANIUM_PTCG */
-#define IPI_KDB_INTERRUPT	4
=20
 /*
  *	Setup routine for controlling SMP activation
@@ -133,24 +132,17 @@
=20
 }
=20
-static inline void
-pointer_unlock(void **lock, void **data)
-{
-	*data =3D *lock;
-	*lock =3D NULL;
-}
-
 static inline int
 pointer_lock(void *lock, void *data, int retry)
 {
  again:
-	if (cmpxchg_acq(lock, 0, data) =3D 0)
+	if (cmpxchg_acq((void **) lock, 0, data) =3D 0)
 		return 0;
=20
 	if (!retry)
 		return -EBUSY;
=20
-	while (*(void**) lock)
+	while (*(void **) lock)
 		;
=20
 	goto again;
@@ -191,13 +183,13 @@
 				int wait;
=20
 				/* release the 'pointer lock' */
-				pointer_unlock((void **) &smp_call_function_data, (void **) &data);
+				data =3D smp_call_function_data;
 				func =3D data->func;
 				info =3D data->info;
 				wait =3D data->wait;
=20
 				mb();
-				atomic_dec (&data->unstarted_count);
+				atomic_dec(&data->unstarted_count);
=20
 				/* At this point the structure may be gone unless wait is true.  */
 				(*func)(info);
@@ -205,7 +197,7 @@
 				/* Notify the sending CPU that the task is done.  */
 				mb();
 				if (wait)=20
-					atomic_dec (&data->unfinished_count);
+					atomic_dec(&data->unfinished_count);
 			}
 			break;
=20
@@ -344,41 +336,35 @@
 {
 	struct smp_call_struct data;
 	long timeout;
-	static spinlock_t lock =3D SPIN_LOCK_UNLOCKED;
+	int cpus =3D smp_num_cpus - 1;
+
+	if (cpus =3D 0)
+		return 0;
 =09
 	data.func =3D func;
 	data.info =3D info;
 	data.wait =3D wait;
-	atomic_set(&data.unstarted_count, smp_num_cpus - 1);
-	atomic_set(&data.unfinished_count, smp_num_cpus - 1);
+	atomic_set(&data.unstarted_count, cpus);
+	atomic_set(&data.unfinished_count, cpus);
=20
 	if (pointer_lock(&smp_call_function_data, &data, retry))
 		return -EBUSY;
=20
-	smp_call_function_data =3D &data;
-	spin_unlock (&lock);
-	data.func =3D func;
-	data.info =3D info;
-	atomic_set (&data.unstarted_count, smp_num_cpus - 1);
-	data.wait =3D wait;
-	if (wait)=20
-		atomic_set (&data.unfinished_count, smp_num_cpus - 1);
-=09
 	/*  Send a message to all other CPUs and wait for them to respond  */
 	send_IPI_allbutself(IPI_CALL_FUNC);
=20
 	/*  Wait for response  */
 	timeout =3D jiffies + HZ;
-	while ( (atomic_read (&data.unstarted_count) > 0) &&
-		time_before (jiffies, timeout) )
-		barrier ();
-	if (atomic_read (&data.unstarted_count) > 0) {
+	while ((atomic_read(&data.unstarted_count) > 0) && time_before(jiffies, t=
imeout))
+		barrier();
+	if (atomic_read(&data.unstarted_count) > 0) {
 		smp_call_function_data =3D NULL;
 		return -ETIMEDOUT;
 	}
 	if (wait)
-		while (atomic_read (&data.unfinished_count) > 0)
-			barrier ();
+		while (atomic_read(&data.unfinished_count) > 0)
+			barrier();
+	/* unlock pointer */
 	smp_call_function_data =3D NULL;
 	return 0;
 }
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c linux-2.4.0-test1-lia/ar=
ch/ia64/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/sys_ia64.c	Fri Jun  9 17:18:00 2=
000
@@ -156,6 +156,9 @@
 {
 	struct pt_regs *regs =3D (struct pt_regs *) &stack;
=20
+	if ((off & ~PAGE_MASK) !=3D 0)
+		return -EINVAL;
+
 	addr =3D do_mmap2(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 	if (!IS_ERR(addr))
 		regs->r8 =3D 0;	/* ensure large addresses are not mistaken as failures..=
. */
diff -urN linux-davidm/arch/ia64/kernel/time.c linux-2.4.0-test1-lia/arch/i=
a64/kernel/time.c
--- linux-davidm/arch/ia64/kernel/time.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/time.c	Fri Jun  9 17:18:07 2000
@@ -162,6 +162,11 @@
 	 */
 	write_lock(&xtime_lock);
 	new_itm =3D itm.next[cpu].count;
+
+	if (!time_after(ia64_get_itc(), new_itm))
+		printk("Oops: timer tick before it's due (itc=3D%lx,itm=3D%lx)\n",
+		       ia64_get_itc(), new_itm);
+
 	while (1) {
 		/*
 		 * Do kernel PC profiling here.  We multiply the
@@ -220,7 +225,7 @@
 	ia64_set_itm(new_itm);
 }
=20
-#ifdef CONFIG_ITANIUM_ASTEP_SPECIFIC
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_IA64_SOFTSDV_=
HACKS)
=20
 /*
  * Interrupts must be disabled before calling this routine.
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Fri Jun  9 17:38:58 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/traps.c	Fri Jun  9 17:49:52 2000
@@ -36,10 +36,6 @@
 #include <linux/init.h>
 #include <linux/sched.h>
=20
-#ifdef CONFIG_KDB
-#include <linux/kdb.h>
-#endif
-
 #include <asm/ia32.h>
 #include <asm/processor.h>
 #include <asm/uaccess.h>
@@ -92,13 +88,6 @@
 	}
=20
 	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
-
-#ifdef CONFIG_KDB
-	while (1) {
-                kdb(KDB_REASON_PANIC, 0, regs);
-                printk("Cant go anywhere from Panic!\n");
-	}
-#endif
=20
 	show_regs(regs);
=20
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Fri Jun  9 17:38:59 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unwind.c	Fri Jun  9 17:18:53 2000
@@ -49,7 +49,7 @@
 #define UNW_LOG_HASH_SIZE	(UNW_LOG_CACHE_SIZE + 1)
 #define UNW_HASH_SIZE		(1 << UNW_LOG_HASH_SIZE)
=20
-#define UNW_DEBUG	0
+#define UNW_DEBUG	1
 #define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spa=
ns!! */
=20
 #if UNW_DEBUG
@@ -191,8 +191,10 @@
 	struct unw_ireg *ireg;
 	struct pt_regs *pt;
=20
-	if ((unsigned) regnum - 1 >=3D 127)
+	if ((unsigned) regnum - 1 >=3D 127) {
+		dprintk("unwind: trying to access non-existent r%u\n", regnum);
 		return -1;
+	}
=20
 	if (regnum < 32) {
 		if (regnum >=3D 4 && regnum <=3D 7) {
@@ -238,7 +240,12 @@
 					nat_addr =3D ia64_rse_rnat_addr(addr);
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >=3D info->regstk.top)
+					{
+						dprintk("unwind: %lx outside of regstk "
+							"[0x%lx-0x%lx)\n", addr,
+							info->regstk.limit, info->regstk.top);
 						return -1;
+					}
 					if ((unsigned long) nat_addr >=3D info->regstk.top)
 						nat_addr =3D &info->sw->ar_rnat;
 					nat_mask =3D (1UL << ia64_rse_slot_num(addr));
@@ -307,9 +314,12 @@
 		/* preserved: */
 	      case 1: case 2: case 3: case 4: case 5:
 		addr =3D *(&info->b1 + (regnum - 1));
+		if (!addr)
+			addr =3D &info->sw->b1 + (regnum - 1);
 		break;
=20
 	      default:
+		dprintk("unwind: trying to access non-existent b%u\n", regnum);
 		return -1;
 	}
 	if (write)
@@ -325,8 +335,10 @@
 	struct ia64_fpreg *addr =3D 0;
 	struct pt_regs *pt;
=20
-	if ((unsigned) (regnum - 2) >=3D 30)
+	if ((unsigned) (regnum - 2) >=3D 30) {
+		dprintk("unwind: trying to access non-existent f%u\n", regnum);
 		return -1;
+	}
=20
 	pt =3D (struct pt_regs *) info->sp - 1;
=20
@@ -412,6 +424,7 @@
 		break;
=20
 	      default:
+		dprintk("unwind: trying to access non-existent ar%u\n", regnum);
 		return -1;
 	}
=20
@@ -1327,7 +1340,8 @@
 	}
 	if (!e) {
 		/* no info, return default unwinder (leaf proc, no mem stack, no saved r=
egs)  */
-		dprintk("unwind: no unwind info for ip=3D0x%lx\n", ip);
+		dprintk("unwind: no unwind info for ip=3D0x%lx (prev ip=3D0x%lx)\n", ip,
+			unw.cache[info->prev_script].ip);
 		sr.curr.reg[UNW_REG_RP].where =3D UNW_WHERE_BR;
 		sr.curr.reg[UNW_REG_RP].when =3D -1;
 		sr.curr.reg[UNW_REG_RP].val =3D 0;
@@ -1338,7 +1352,7 @@
 		return script;
 	}
=20
-	sr.when_target =3D (3*((ip & ~0xfUL) - (table->segment_base + e->start_of=
fset))
+	sr.when_target =3D (3*((ip & ~0xfUL) - (table->segment_base + e->start_of=
fset))/16
 			  + (ip & 0xfUL));
 	hdr =3D *(u64 *) (table->segment_base + e->info_offset);
 	dp =3D   (u8 *)  (table->segment_base + e->info_offset + 8);
@@ -1383,7 +1397,7 @@
 			      case UNW_WHERE_FR:     printk("f%lu", r->val); break;
 			      case UNW_WHERE_BR:     printk("b%lu", r->val); break;
 			      case UNW_WHERE_SPREL:  printk("[sp+0x%lx]", r->val); break;
-			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", 0x10 - r->val); brea=
k;
+			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", r->val); break;
 			      case UNW_WHERE_NONE:
 				printk("%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
 				break;=20
@@ -1531,6 +1545,7 @@
=20
 	if (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)) {
 		/* don't let obviously bad addresses pollute the cache */
+		dprintk("unwind: rejecting bad ip=3D0x%lx\n", info->ip);
 		info->rp =3D 0;
 		return -1;
 	}
@@ -1590,18 +1605,18 @@
 		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
-	info->cfm =3D *info->pfs;
+	info->cfm =3D info->pfs;
=20
 	/* restore the bsp: */
 	pr =3D info->pr_val;
 	num_regs =3D 0;
 	if ((info->flags & UNW_FLAG_INTERRUPT_FRAME)) {
 		if ((pr & (1UL << pNonSys)) !=3D 0)
-			num_regs =3D info->cfm & 0x7f;		/* size of frame */
+			num_regs =3D *info->cfm & 0x7f;		/* size of frame */
 		info->pfs  			(unsigned long *) (info->sp + 16 + struct_offset(struct pt=
_regs, ar_pfs));
 	} else
-		num_regs =3D (info->cfm >> 7) & 0x7f;	/* size of locals */
+		num_regs =3D (*info->cfm >> 7) & 0x7f;	/* size of locals */
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
bsp, -num_regs);
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
 		dprintk("unwind: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
@@ -1669,8 +1684,8 @@
 	info->memstk.top   =3D stktop;
 	info->sw  =3D sw;
 	info->sp =3D info->psp =3D (unsigned long) (sw + 1) - 16;
-	info->cfm =3D sw->ar_pfs;
-	sol =3D (info->cfm >> 7) & 0x7f;
+	info->cfm =3D &sw->ar_pfs;
+	sol =3D (*info->cfm >> 7) & 0x7f;
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
regstk.top, -sol);
 	info->ip =3D sw->b0;
 	info->pr_val =3D sw->pr;
@@ -1704,7 +1719,7 @@
 	info->regstk.top   =3D top;
 	info->sw  =3D sw;
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
regstk.top, -sol);
-	info->cfm =3D sw->ar_pfs;
+	info->cfm =3D &sw->ar_pfs;
 	info->ip  =3D sw->b0;
 #endif
 }
@@ -1741,7 +1756,7 @@
 	info->regstk.top   =3D top;
 	info->sw =3D sw;
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs(bsp, -sof);
-	info->cfm =3D regs->cr_ifs;
+	info->cfm =3D &regs->cr_ifs;
 	info->ip  =3D regs->cr_iip;
 #endif
 }
@@ -1777,7 +1792,7 @@
 int
 unw_unwind (struct unw_frame_info *info)
 {
-	unsigned long sol, cfm =3D info->cfm;
+	unsigned long sol, cfm =3D *info->cfm;
 	int is_nat;
=20
 	sol =3D (cfm >> 7) & 0x7f;	/* size of locals */
@@ -1796,16 +1811,16 @@
=20
 	info->ip =3D read_reg(info, sol - 2, &is_nat);
 	if (is_nat || (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)))
-		/* don't let obviously bad addresses pollute the cache */
+		/* reject let obviously bad addresses */
 		return -1;
=20
+	info->cfm =3D ia64_rse_skip_regs((unsigned long *) info->bsp, sol - 1);
 	cfm =3D read_reg(info, sol - 1, &is_nat);
 	if (is_nat)
 		return -1;
=20
 	sol =3D (cfm >> 7) & 0x7f;
=20
-	info->cfm =3D cfm;
 	info->bsp =3D (unsigned long) ia64_rse_skip_regs((unsigned long *) info->=
bsp, -sol);
 	return 0;
 }
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test1-lia/arch/ia64/=
mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Fri Jun  9 17:38:59 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/init.c	Fri Jun  9 17:19:34 2000
@@ -183,6 +183,19 @@
 }
=20
 void
+free_initrd_mem(unsigned long start, unsigned long end)
+{
+	if (start < end)
+		printk ("Freeing initrd memory: %ldkB freed\n", (end - start) >> 10);
+	for (; start < end; start +=3D PAGE_SIZE) {
+		clear_bit(PG_reserved, &mem_map[MAP_NR(start)].flags);
+		set_page_count(&mem_map[MAP_NR(start)], 1);
+		free_page(start);
+		++totalram_pages;
+	}
+}
+
+void
 si_meminfo (struct sysinfo *val)
 {
 	val->totalram =3D totalram_pages;
diff -urN linux-davidm/arch/ia64/vmlinux.lds.S linux-2.4.0-test1-lia/arch/i=
a64/vmlinux.lds.S
--- linux-davidm/arch/ia64/vmlinux.lds.S	Fri Jun  9 17:38:59 2000
+++ linux-2.4.0-test1-lia/arch/ia64/vmlinux.lds.S	Fri Jun  9 17:20:07 2000
@@ -46,6 +46,11 @@
 	{ *(__ex_table) }
   __stop___ex_table =3D .;
=20
+  __start___ksymtab =3D .;	/* Kernel symbol table */
+  __ksymtab : AT(ADDR(__ksymtab) - PAGE_OFFSET)
+	{ *(__ksymtab) }
+  __stop___ksymtab =3D .;
+
   /* Unwind table */
   ia64_unw_start =3D .;
   .IA_64.unwind : AT(ADDR(.IA_64.unwind) - PAGE_OFFSET)
@@ -56,6 +61,8 @@
=20
   .rodata : AT(ADDR(.rodata) - PAGE_OFFSET)
 	{ *(.rodata) }
+  .kstrtab : AT(ADDR(.kstrtab) - PAGE_OFFSET)
+	{ *(.kstrtab) }
   .opd : AT(ADDR(.opd) - PAGE_OFFSET)
 	{ *(.opd) }
=20
diff -urN linux-davidm/fs/proc/generic.c linux-2.4.0-test1-lia/fs/proc/gene=
ric.c
--- linux-davidm/fs/proc/generic.c	Sun May 21 20:34:37 2000
+++ linux-2.4.0-test1-lia/fs/proc/generic.c	Fri Jun  9 17:24:08 2000
@@ -42,7 +42,7 @@
 #endif
=20
 /* 4K page size but our output routines use some slack for overruns */
-#define PROC_BLOCK_SIZE	(3*1024)
+#define PROC_BLOCK_SIZE	(PAGE_SIZE - 1024)
=20
 static ssize_t
 proc_file_read(struct file * file, char * buf, size_t nbytes, loff_t *ppos)
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test1-lia/i=
nclude/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Fri Jun  9 17:39:00 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/processor.h	Fri Jun  9 17:24:33 =
2000
@@ -658,13 +658,16 @@
 thread_saved_pc (struct thread_struct *t)
 {
 	struct unw_frame_info info;
+	unsigned long ip;
+
 	/* XXX ouch: Linus, please pass the task pointer to thread_saved_pc() ins=
tead! */
 	struct task_struct *p =3D (void *) ((unsigned long) t - IA64_TASK_THREAD_=
OFFSET);
=20
 	unw_init_from_blocked_task(&info, p);
 	if (unw_unwind(&info) < 0)
 		return 0;
-	return unw_get_ip(&info);
+	unw_get_ip(&info, &ip);
+	return ip;
 }
=20
 /*
diff -urN linux-davidm/include/asm-ia64/ptrace.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/ptrace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/ptrace.h	Fri Jun  9 17:24:41 2000
@@ -220,10 +220,17 @@
   extern long ia64_peek (struct pt_regs *, struct task_struct *, unsigned =
long addr, long *val);
   extern long ia64_poke (struct pt_regs *, struct task_struct *, unsigned =
long addr, long val);
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+  /* get nat bits for scratch registers such that bit N=3D1 iff scratch re=
gister rN is a NaT */
+  extern unsigned long ia64_get_scratch_nat_bits (struct pt_regs *pt, unsi=
gned long scratch_unat);
+  /* put nat bits for scratch registers such that scratch register rN is a=
 NaT iff bit N=3D1 */
+  extern unsigned long ia64_put_scratch_nat_bits (struct pt_regs *pt, unsi=
gned long nat);
+#else
   /* get nat bits for r1-r31 such that bit N=3D1 iff rN is a NaT */
   extern long ia64_get_nat_bits (struct pt_regs *pt, struct switch_stack *=
sw);
   /* put nat bits for r1-r31 such that rN is a NaT iff bit N=3D1 */
   extern void ia64_put_nat_bits (struct pt_regs *pt, struct switch_stack *=
sw, unsigned long nat);
+#endif
=20
   extern void ia64_increment_ip (struct pt_regs *pt);
   extern void ia64_decrement_ip (struct pt_regs *pt);
diff -urN linux-davidm/include/asm-ia64/ptrace_offsets.h linux-2.4.0-test1-=
lia/include/asm-ia64/ptrace_offsets.h
--- linux-davidm/include/asm-ia64/ptrace_offsets.h	Fri Jun  9 17:39:00 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/ptrace_offsets.h	Fri Jun  9 17:2=
5:05 2000
@@ -118,7 +118,7 @@
 #define PT_F126			0x05e0
 #define PT_F127			0x05f0
 /* switch stack: */
-#define PT_PRI_UNAT		0x0600
+#define PT_NAT_BITS		0x0600
=20
 #define PT_F2			0x0610
 #define PT_F3			0x0620
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Fri Jun  9 17:39:00 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/system.h	Fri Jun  9 17:25:19 2000
@@ -54,6 +54,8 @@
 	__u16 num_pci_vectors;	/* number of ACPI derived PCI IRQ's*/
 	__u64 pci_vectors;	/* physical address of PCI data (pci_vector_struct)*/
 	__u64 fpswa;		/* physical address of the the fpswa interface */
+	__u64 initrd_start;
+	__u64 initrd_size;
 } ia64_boot_param;
=20
 extern inline void
diff -urN linux-davidm/include/asm-ia64/unwind.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Fri Jun  9 17:39:00 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/unwind.h	Fri Jun  9 17:25:28 2000
@@ -54,9 +54,9 @@
 	unsigned long bsp;
 	unsigned long sp;		/* stack pointer */
 	unsigned long psp;		/* previous sp */
-	unsigned long cfm;
 	unsigned long ip;		/* instruction pointer */
 	unsigned long pr_val;		/* current predicates */
+	unsigned long *cfm;
=20
 	struct switch_stack *sw;
=20
@@ -123,11 +123,21 @@
  */
 extern int unw_unwind (struct unw_frame_info *info);
=20
-#define unw_get_ip(info)	((info)->ip)
-#define unw_get_sp(info)	((unsigned long) (info)->sp)
-#define unw_get_psp(info)	((unsigned long) (info)->psp)
-#define unw_get_bsp(info)	((unsigned long) (info)->bsp)
-#define unw_get_cfm(info)	((info)->cfm)
+#define unw_get_ip(info,vp)	({*(vp) =3D (info)->ip; 0;})
+#define unw_get_sp(info,vp)	({*(vp) =3D (unsigned long) (info)->sp; 0;})
+#define unw_get_psp(info,vp)	({*(vp) =3D (unsigned long) (info)->psp; 0;})
+#define unw_get_bsp(info,vp)	({*(vp) =3D (unsigned long) (info)->bsp; 0;})
+#define unw_get_cfm(info,vp)	({*(vp) =3D *(info)->cfm; 0;})
+#define unw_set_cfm(info,val)	({*(info)->cfm =3D (val); 0;})
+
+static inline int
+unw_get_rp (struct unw_frame_info *info, unsigned long *val)
+{
+	if (!info->rp)
+		return -1;
+	*val =3D *info->rp;
+	return 0;
+}
=20
 extern int unw_access_gr (struct unw_frame_info *, int, unsigned long *, c=
har *, int);
 extern int unw_access_br (struct unw_frame_info *, int, unsigned long *, i=
nt);
@@ -135,11 +145,35 @@
 extern int unw_access_ar (struct unw_frame_info *, int, unsigned long *, i=
nt);
 extern int unw_access_pr (struct unw_frame_info *, unsigned long *, int);
=20
-#define unw_set_gr(i,n,v,nat)	unw_access_gr(i,n,v,nat,1)
-#define unw_set_br(i,n,v)	unw_access_br(i,n,v,1)
-#define unw_set_fr(i,n,v)	unw_access_fr(i,n,v,1)
-#define unw_set_ar(i,n,v)	unw_access_ar(i,n,v,1)
-#define unw_set_pr(i,v)		unw_access_ar(i,v,1)
+static inline int
+unw_set_gr (struct unw_frame_info *i, int n, unsigned long v, char nat)
+{
+	return unw_access_gr(i, n, &v, &nat, 1);
+}
+
+static inline int
+unw_set_br (struct unw_frame_info *i, int n, unsigned long v)
+{
+	return unw_access_br(i, n, &v, 1);
+}
+
+static inline int
+unw_set_fr (struct unw_frame_info *i, int n, struct ia64_fpreg v)
+{
+	return unw_access_fr(i, n, &v, 1);
+}
+
+static inline int
+unw_set_ar (struct unw_frame_info *i, int n, unsigned long v)
+{
+	return unw_access_ar(i, n, &v, 1);
+}
+
+static inline int
+unw_set_pr (struct unw_frame_info *i, unsigned long v)
+{
+	return unw_access_pr(i, &v, 1);
+}
=20
 #define unw_get_gr(i,n,v,nat)	unw_access_gr(i,n,v,nat,0)
 #define unw_get_br(i,n,v)	unw_access_br(i,n,v,0)


