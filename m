From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 01 Jun 2000 08:54:13 +0000
Subject: [Linux-ia64] kernel update (relative to v2.4.0-test1)
Message-Id: <marc-linux-ia64-105590678205111@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is a quick kernel update.  I'm not sure this is distribution
material, but it should work better than last weeks patch.  Some
of the improvements:

	- "branch long" emulation by Stephan Zeisset is finally in
	  (sorry about the delay...).

	- added Stephane Eranian's /proc/palinfo "driver"; very nice
	  to find out details on your CPU...

	- SMP should work again

	- ptrace interface should work again (at least strace works...)

	- the unwind support now has a real cache and should be
          SMP-safe

	- SMP-related CPU initialization clean up; the bootstrap
	  processor now does an identify_cpu() early in the
	  bootprocess (same as in the UP case); this is necessary
	  because we now rely on PAL info stored in cpu_data[] to
	  bootstrap the system

	- some more ia-32 signal fixes from Don

	- unaligned accesses in big-endian mode now result in SIGBUS (instead
	  of sliently bogus data) (Stephane Eranian)

	- updated for 2.4.0-test1

	- remove Itanium dependencies from pgtable.h again (there is no desire
	  or need to make the kernel implementation specific)

	- speculative accesses that result in an alternate d-tlb fault are now
	  always NaTed

	- make simscsi driver SMP-safe

The full diff is available at

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/linux-2.4.0-test1-ia64-00=
0531.diff*

as usual.

	--david

diff -urN linux-davidm/arch/ia64/config.in linux-2.4.0-test1-lia/arch/ia64/=
config.in
--- linux-davidm/arch/ia64/config.in	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/config.in	Thu Jun  1 00:59:33 2000
@@ -4,7 +4,6 @@
 comment 'General setup'
=20
 define_bool CONFIG_IA64 y
-define_bool CONFIG_ITANIUM y	# easy choice for now... ;-)
=20
 define_bool CONFIG_ISA n
 define_bool CONFIG_SBUS n
@@ -22,6 +21,8 @@
 	 64KB			CONFIG_IA64_PAGE_SIZE_64KB" 16KB
=20
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
+	define_bool CONFIG_ITANIUM y
+	define_bool CONFIG_IA64_BRL_EMU y
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIFIC
 	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
@@ -44,6 +45,7 @@
=20
 bool 'SMP support' CONFIG_SMP
 bool 'Performance monitor support' CONFIG_PERFMON
+bool '/proc/palinfo support' CONFIG_IA64_PALINFO
=20
 bool 'Networking support' CONFIG_NET
 bool 'System V IPC' CONFIG_SYSVIPC
diff -urN linux-davidm/arch/ia64/hp/hpsim_irq.c linux-2.4.0-test1-lia/arch/=
ia64/hp/hpsim_irq.c
--- linux-davidm/arch/ia64/hp/hpsim_irq.c	Fri Mar 10 15:24:02 2000
+++ linux-2.4.0-test1-lia/arch/ia64/hp/hpsim_irq.c	Thu Jun  1 01:00:14 2000
@@ -5,7 +5,8 @@
  * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
-#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/sched.h>
 #include <linux/irq.h>
=20
 static unsigned int
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c linux-2.4.0-test1-lia/a=
rch/ia64/ia32/ia32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/ia32_signal.c	Thu Jun  1 01:00:27 =
2000
@@ -55,7 +55,7 @@
 };
=20
 static int
-copy_siginfo_to_user32(siginfo_t32 *to, siginfo_t *from)
+copy_siginfo_to_user32 (siginfo_t32 *to, siginfo_t *from)
 {
 	int err;
=20
@@ -326,8 +326,8 @@
                           ? current->exec_domain->signal_invmap[sig]
                           : sig),
                          &frame->sig);
-       err |=3D __put_user(&frame->info, &frame->pinfo);
-       err |=3D __put_user(&frame->uc, &frame->puc);
+       err |=3D __put_user((long)&frame->info, &frame->pinfo);
+       err |=3D __put_user((long)&frame->uc, &frame->puc);
        err |=3D copy_siginfo_to_user32(&frame->info, info);
=20
        /* Create the ucontext.  */
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.4.0-test1-lia/arch=
/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/Makefile	Thu Jun  1 01:00:52 2000
@@ -1,11 +1,6 @@
 #
 # Makefile for the linux kernel.
 #
-# Note! Dependencies are done automagically by 'make dep', which also
-# removes any old dependencies. DON'T put your own dependencies here
-# unless it's something special (ie not a .c file).
-#
-# Note 2! The CFLAGS definitions are now in the main makefile...
=20
 .S.s:
 	$(CPP) $(AFLAGS) -o $*.s $<
@@ -24,6 +19,10 @@
 O_OBJS	+=3D machvec.o
 endif
=20
+ifdef CONFIG_IA64_PALINFO
+O_OBJS	+=3D palinfo.o
+endif
+
 ifdef CONFIG_PCI
 O_OBJS	+=3D pci.o
 endif
@@ -34,6 +33,10 @@
=20
 ifdef CONFIG_IA64_MCA
 O_OBJS	+=3D mca.o mca_asm.o
+endif
+
+ifdef CONFIG_IA64_BRL_EMU
+O_OBJS  +=3D brl_emu.o
 endif
=20
 clean::
diff -urN linux-davidm/arch/ia64/kernel/brl_emu.c linux-2.4.0-test1-lia/arc=
h/ia64/kernel/brl_emu.c
--- linux-davidm/arch/ia64/kernel/brl_emu.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/brl_emu.c	Thu Jun  1 01:01:03 20=
00
@@ -0,0 +1,220 @@
+/*
+ *  Emulation of the "brl" instruction for IA64 processors that
+ *  don't support it in hardware.=20
+ *  Author: Stephan Zeisset, Intel Corp. <Stephan.Zeisset@intel.com>
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <asm/uaccess.h>
+#include <asm/processor.h>
+
+extern char ia64_set_b1, ia64_set_b2, ia64_set_b3, ia64_set_b4, ia64_set_b=
5;
+
+struct illegal_op_return {
+	unsigned long fkt, arg1, arg2, arg3;
+};
+
+/*
+ *  The unimplemented bits of a virtual address must be set
+ *  to the value of the most significant implemented bit.
+ *  unimpl_va_mask includes all unimplemented bits and
+ *  the most significant implemented bit, so the result
+ *  of an and operation with the mask must be all 0's
+ *  or all 1's for the address to be valid.
+ */
+#define unimplemented_virtual_address(va) (					\
+	((va) & my_cpu_data.unimpl_va_mask) !=3D 0 &&				\
+	((va) & my_cpu_data.unimpl_va_mask) !=3D my_cpu_data.unimpl_va_mask	\
+)
+
+/*
+ *  The unimplemented bits of a physical address must be 0.
+ *  unimpl_pa_mask includes all unimplemented bits, so the result
+ *  of an and operation with the mask must be all 0's for the
+ *  address to be valid.
+ */
+#define unimplemented_physical_address(pa) (		\
+	((pa) & my_cpu_data.unimpl_pa_mask) !=3D 0	\
+)
+
+/*
+ *  Handle an illegal operation fault that was caused by an=20
+ *  unimplemented "brl" instruction.
+ *  If we are not successful (e.g because the illegal operation=20
+ *  wasn't caused by a "brl" after all), we return -1.
+ *  If we are successful, we return either 0 or the address
+ *  of a "fixup" function for manipulating preserved register
+ *  state.
+ */
+
+struct illegal_op_return
+ia64_emulate_brl (struct pt_regs *regs, unsigned long ar_ec)
+{
+	unsigned long bundle[2];
+	unsigned long opcode, btype, qp, offset;
+	unsigned long next_ip;
+	struct siginfo siginfo;
+	struct illegal_op_return rv;
+	int tmp_taken, unimplemented_address;
+
+	rv.fkt =3D (unsigned long) -1;
+
+	/*
+	 *  Decode the instruction bundle.
+	 */
+
+        if (copy_from_user(bundle, (void *) (regs->cr_iip), sizeof(bundle)=
))
+                return rv;=20
+
+	next_ip =3D (unsigned long) regs->cr_iip + 16;
+
+	/* "brl" must be in slot 2. */
+	if (ia64_psr(regs)->ri !=3D 1) return rv;
+
+	/* Must be "mlx" template */
+	if ((bundle[0] & 0x1e) !=3D 0x4) return rv;
+
+	opcode =3D (bundle[1] >> 60);
+	btype =3D ((bundle[1] >> 29) & 0x7);
+	qp =3D ((bundle[1] >> 23) & 0x3f);
+	offset =3D ((bundle[1] & 0x0800000000000000L) << 4)
+		| ((bundle[1] & 0x00fffff000000000L) >> 32)=20
+		| ((bundle[1] & 0x00000000007fffffL) << 40)
+		| ((bundle[0] & 0xffff000000000000L) >> 24);
+
+	tmp_taken =3D regs->pr & (1L << qp);
+
+	switch(opcode) {
+	=09
+		case 0xC:
+			/*
+			 *  Long Branch.
+			 */
+			if (btype !=3D 0) return rv;
+			rv.fkt =3D 0;
+			if (!(tmp_taken)) {
+				/*
+				 *  Qualifying predicate is 0.
+				 *  Skip instruction.
+				 */
+				regs->cr_iip =3D next_ip;
+				ia64_psr(regs)->ri =3D 0;
+				return rv;
+			}
+			break;
+
+		case 0xD:
+			/*
+			 *  Long Call.
+			 */
+			rv.fkt =3D 0;
+			if (!(tmp_taken)) {
+				/*
+				 *  Qualifying predicate is 0.
+				 *  Skip instruction.
+				 */
+				regs->cr_iip =3D next_ip;
+				ia64_psr(regs)->ri =3D 0;
+				return rv;
+			}
+
+			/*
+			 *  BR[btype] =3D IP+16
+			 */
+			switch(btype) {
+				case 0:
+					regs->b0 =3D next_ip;
+					break;
+				case 1:
+					rv.fkt =3D (unsigned long) &ia64_set_b1;
+					break;
+				case 2:
+					rv.fkt =3D (unsigned long) &ia64_set_b2;
+					break;
+				case 3:
+					rv.fkt =3D (unsigned long) &ia64_set_b3;
+					break;
+				case 4:
+					rv.fkt =3D (unsigned long) &ia64_set_b4;
+					break;
+				case 5:
+					rv.fkt =3D (unsigned long) &ia64_set_b5;
+					break;
+				case 6:
+					regs->b6 =3D next_ip;
+					break;
+				case 7:
+					regs->b7 =3D next_ip;
+					break;
+			}
+			rv.arg1 =3D next_ip;
+
+			/*
+			 *  AR[PFS].pfm =3D CFM
+			 *  AR[PFS].pec =3D AR[EC]
+			 *  AR[PFS].ppl =3D PSR.cpl
+			 */
+			regs->ar_pfs =3D ((regs->cr_ifs & 0x3fffffffff)
+					| (ar_ec << 52)
+					| ((unsigned long) ia64_psr(regs)->cpl << 62));
+
+			/*
+			 *  CFM.sof -=3D CFM.sol
+			 *  CFM.sol =3D 0
+			 *  CFM.sor =3D 0
+			 *  CFM.rrb.gr =3D 0
+			 *  CFM.rrb.fr =3D 0
+			 *  CFM.rrb.pr =3D 0
+			 */
+			regs->cr_ifs =3D ((regs->cr_ifs & 0xffffffc00000007f)
+					- ((regs->cr_ifs >> 7) & 0x7f));
+			=09
+			break;
+
+		default:
+			/*
+			 *  Unknown opcode.
+			 */
+			return rv;
+
+	}
+
+	regs->cr_iip +=3D offset;=20
+	ia64_psr(regs)->ri =3D 0;
+
+	if (ia64_psr(regs)->it =3D 0)
+		unimplemented_address =3D unimplemented_physical_address(regs->cr_iip);
+	else
+		unimplemented_address =3D unimplemented_virtual_address(regs->cr_iip);
+
+	if (unimplemented_address) {=20
+		/*
+		 *  The target address contains unimplemented bits.
+		 */
+		printk("Woah! Unimplemented Instruction Address Trap!\n");
+		siginfo.si_signo =3D SIGILL;
+		siginfo.si_errno =3D 0;
+		siginfo.si_code =3D ILL_BADIADDR;
+		force_sig_info(SIGILL, &siginfo, current);
+	} else if (ia64_psr(regs)->tb) {
+		/*
+		 *  Branch Tracing is enabled.
+		 *  Force a taken branch signal.
+		 */
+		siginfo.si_signo =3D SIGTRAP;
+		siginfo.si_errno =3D 0;
+		siginfo.si_code =3D TRAP_BRANCH;
+		force_sig_info(SIGTRAP, &siginfo, current);
+	} else if (ia64_psr(regs)->ss) {
+		/*
+		 *  Single Step is enabled.
+		 *  Force a trace signal.
+		 */
+		siginfo.si_signo =3D SIGTRAP;
+		siginfo.si_errno =3D 0;
+		siginfo.si_code =3D TRAP_TRACE;
+		force_sig_info(SIGTRAP, &siginfo, current);
+	}
+	return rv;
+}
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/efi.c	Thu Jun  1 01:01:16 2000
@@ -5,9 +5,9 @@
  *
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
- * Copyright (C) 1999 Hewlett-Packard Co.
+ * Copyright (C) 1999-2000 Hewlett-Packard Co.
  * Copyright (C) 1999 David Mosberger-Tang <davidm@hpl.hp.com>
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>
  *
  * All EFI Runtime Services are not implemented yet as EFI only
  * supports physical mode addressing on SoftSDV. This is to be fixed
@@ -22,6 +22,7 @@
=20
 #include <asm/efi.h>
 #include <asm/io.h>
+#include <asm/pgtable.h>
 #include <asm/processor.h>
=20
 #define EFI_DEBUG	0
@@ -207,6 +208,61 @@
 	}
 }
=20
+/*
+ * Look for the PAL_CODE region reported by EFI and maps it using an
+ * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
+ * Abstraction Layer chapter 11 in ADAG
+ */
+static void
+map_pal_code (void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+	int pal_code_count=3D0;
+	u64 mask, flags;
+	u64 vaddr;
+
+	efi_map_start =3D __va(ia64_boot_param.efi_memmap);
+	efi_map_end   =3D efi_map_start + ia64_boot_param.efi_memmap_size;
+	efi_desc_size =3D ia64_boot_param.efi_memdesc_size;
+
+	for (p =3D efi_map_start; p < efi_map_end; p +=3D efi_desc_size) {
+		md =3D p;
+		if (md->type !=3D EFI_PAL_CODE) continue;
+
+		if (++pal_code_count > 1) {
+			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
+			       md->phys_addr);
+			continue;
+		}=20
+		mask  =3D ~((1 << _PAGE_SIZE_4M)-1);	/* XXX should be dynamic? */
+		vaddr =3D PAGE_OFFSET + md->phys_addr;
+
+	  	printk(__FUNCTION__": mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx=
)\n",
+		       md->phys_addr, md->phys_addr + (md->num_pages << 12),
+		       vaddr & mask, (vaddr & mask) + 4*1024*1024);
+
+		/*
+		 * Cannot write to CRx with PSR.ic=3D1
+		 */
+		ia64_clear_ic(flags);
+
+		/*
+		 * ITR0/DTR0: used for kernel code/data
+		 * ITR1/DTR1: used by HP simulator
+		 * ITR2/DTR2: map PAL code
+		 * ITR3/DTR3: used to map PAL calls buffer
+		 */
+		ia64_itr(0x1, 2, vaddr & mask,
+			 pte_val(mk_pte_phys(md->phys_addr,
+					     __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX))),
+			 _PAGE_SIZE_4M);
+		local_irq_restore(flags);
+		ia64_srlz_i ();
+	}
+}
+
 void __init=20
 efi_init (void)
 {
@@ -291,6 +347,8 @@
 		}
 	}
 #endif
+
+	map_pal_code();
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/efi_stub.S linux-2.4.0-test1-lia/ar=
ch/ia64/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/efi_stub.S	Thu Jun  1 01:01:29 2=
000
@@ -41,52 +41,6 @@
 	.text
=20
 /*
- * Switch execution mode from virtual to physical or vice versa.
- *
- * Inputs:
- *	r16 =3D new psr to establish
- */
-ENTRY(switch_mode)
- {
-	alloc r2=3Dar.pfs,0,0,0,0
-	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
-	mov r15=3Dip
- }
-	;;
- {
-	flushrs				// must be first insn in group
-	srlz.i
-	shr.u r19=3Dr15,61		// r19 <- top 3 bits of current IP
- }
-	;;
-	mov cr.ipsr=3Dr16			// set new PSR
-	add r3=1F-switch_mode,r15
-	xor r15=3D0x7,r19			// flip the region bits
-
-	mov r17=3Dar.bsp
-	mov r14=3Drp			// get return address into a general register
-
-	// switch RSE backing store:
-	;;
-	dep r17=3Dr15,r17,61,3		// make ar.bsp physical or virtual
-	mov r18=3Dar.rnat			// save ar.rnat
-	;;
-	mov ar.bspstore=3Dr17		// this steps on ar.rnat
-	dep r3=3Dr15,r3,61,3		// make rfi return address physical or virtual
-	;;
-	mov cr.iip=3Dr3
-	mov cr.ifs=3Dr0
-	dep sp=3Dr15,sp,61,3		// make stack pointer physical or virtual
-	;;
-	mov ar.rnat=3Dr18			// restore ar.rnat
-	dep r14=3Dr15,r14,61,3		// make function return address physical or virtu=
al
-	rfi				// must be last insn in group
-	;;
-1:	mov rp=3Dr14
-	br.ret.sptk.few rp
-END(switch_mode)
-
-/*
  * Inputs:
  *	in0 =3D address of function descriptor of EFI routine to call
  *	in1..in7 =3D arguments to routine
@@ -121,7 +75,7 @@
 	;;
 	andcm r16=3Dloc3,r16		// get psr with IT, DT, and RT bits cleared
 	mov out3=3Din4
-	br.call.sptk.few rp=3Dswitch_mode
+	br.call.sptk.few rp=3Dia64_switch_mode
 .ret0:
 	mov out4=3Din5
 	mov out5=3Din6
@@ -130,7 +84,7 @@
 .ret1:
 	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
 	mov r16=3Dloc3
-	br.call.sptk.few rp=3Dswitch_mode	// return to virtual mode
+	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
 .ret2:
 	mov ar.rsc=3Dloc4			// restore RSE configuration
 	mov ar.pfs=3Dloc1
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test1-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/entry.S	Thu Jun  1 01:02:14 2000
@@ -375,8 +375,6 @@
 	alloc loc1=3Dar.pfs,8,3,0,0
 	;;			// WAW on CFM at the br.call
 	mov loc0=3Drp
-	.fframe IA64_SWITCH_STACK_SIZE
-	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
 	br.call.sptk.many rp=3Dsave_switch_stack_with_current_frame	// must prese=
rve b6!!
 .ret2:	mov loc2=B6
 	br.call.sptk.few rp=3Dsyscall_trace
@@ -532,7 +530,7 @@
 2:
 	// check & deliver pending signals:
 (p2)	br.call.spnt.few rp=3Dhandle_signal_delivery
-#if defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS)
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_IA64_SOFTSDV_=
HACKS)
 	// Check for lost ticks
 	rsm psr.i
 	mov r2 =3D ar.itc
@@ -747,7 +745,7 @@
=20
 #endif /* CONFIG_SMP */
=20
-#if defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS)
+#if defined(CONFIG_ITANIUM_ASTEP_SPECIFIC) || defined(CONFIG_IA64_SOFTSDV_=
HACKS)
=20
 ENTRY(invoke_ia64_reset_itm)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
@@ -762,7 +760,7 @@
 	br.ret.sptk.many rp
 END(invoke_ia64_reset_itm)
=20
-#endif /* defined(CONFIG_SMP) || defined(CONFIG_IA64_SOFTSDV_HACKS) */
+#endif /* CONFIG_ITANIUM_ASTEP_SPECIFIC || CONFIG_IA64_SOFTSDV_HACKS */
=20
 	/*
 	 * Invoke do_softirq() while preserving in0-in7, which may be needed
@@ -847,7 +845,7 @@
=20
 setup_switch_stack:
 	UNW(.prologue)
-	mov r16=3Dloc0
+	mov r16=3Dloc1
 	DO_SAVE_SWITCH_STACK
 	UNW(.body)
 	br.cond.sptk.many back_from_setup_switch_stack
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.0-test1-lia/arch/=
ia64/kernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/entry.h	Thu Jun  1 01:02:23 2000
@@ -11,8 +11,8 @@
=20
 #define PT_REGS_UNWIND_INFO			\
 	UNW(.prologue);				\
-	UNW(.unwabi @svr4, 105);		\
-	UNW(.fframe IA64_PT_REGS_SIZE);		\
+	UNW(.unwabi @svr4, 'i');		\
+	UNW(.fframe IA64_PT_REGS_SIZE+16);	\
 	UNW(.spillsp rp, PT(CR_IIP));		\
 	UNW(.spillsp ar.pfs, PT(CR_IFS));	\
 	UNW(.spillsp ar.unat, PT(AR_UNAT));	\
diff -urN linux-davidm/arch/ia64/kernel/fw-emu.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/fw-emu.c
--- linux-davidm/arch/ia64/kernel/fw-emu.c	Fri Mar 10 15:24:02 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/fw-emu.c	Thu Jun  1 01:02:33 2000
@@ -124,7 +124,18 @@
 	.proc pal_emulator_static
 pal_emulator_static:
 	mov r8=3D-1
-	cmp.eq p6,p7=3D6,r28		/* PAL_PTCE_INFO */
+
+	mov r9%6
+	;;
+	cmp.gtu p6,p7=3Dr9,r28		/* r28 <=3D 255? */
+(p6)	br.cond.sptk.few static
+	;;
+	mov r9Q2
+	;;
+	cmp.gtu p6,p7=3Dr9,r28
+(p6)	br.cond.sptk.few stacked
+	;;
+static:	cmp.eq p6,p7=3D6,r28		/* PAL_PTCE_INFO */
 (p7)	br.cond.sptk.few 1f
 	;;
 	mov r8=3D0			/* status =3D 0 */
@@ -157,7 +168,12 @@
 	;;
 	mov ar.lc=3Dr9
 	mov r8=3Dr0
-1:	br.cond.sptk.few rp
+1:
+	br.cond.sptk.few rp
+
+stacked:
+	br.ret.sptk.few rp
+
 	.endp pal_emulator_static\n");
=20
 /* Macro to emulate SAL call using legacy IN and OUT calls to CF8, CFC etc=
.. */
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.0-test1-lia/arch/i=
a64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/head.S	Thu Jun  1 01:02:47 2000
@@ -633,3 +633,73 @@
 	mov      f127=F0
 	br.ret.sptk.few rp
 END(__ia64_init_fpu)
+
+/*
+ * Switch execution mode from virtual to physical or vice versa.
+ *
+ * Inputs:
+ *	r16 =3D new psr to establish
+ *
+ * Note: RSE must already be in enforced lazy mode
+ */
+GLOBAL_ENTRY(ia64_switch_mode)
+ {
+	alloc r2=3Dar.pfs,0,0,0,0
+	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
+	mov r15=3Dip
+ }
+	;;
+ {
+	flushrs				// must be first insn in group
+	srlz.i
+	shr.u r19=3Dr15,61		// r19 <- top 3 bits of current IP
+ }
+	;;
+	mov cr.ipsr=3Dr16			// set new PSR
+	add r3=1F-ia64_switch_mode,r15
+	xor r15=3D0x7,r19			// flip the region bits
+
+	mov r17=3Dar.bsp
+	mov r14=3Drp			// get return address into a general register
+
+	// switch RSE backing store:
+	;;
+	dep r17=3Dr15,r17,61,3		// make ar.bsp physical or virtual
+	mov r18=3Dar.rnat			// save ar.rnat
+	;;
+	mov ar.bspstore=3Dr17		// this steps on ar.rnat
+	dep r3=3Dr15,r3,61,3		// make rfi return address physical or virtual
+	;;
+	mov cr.iip=3Dr3
+	mov cr.ifs=3Dr0
+	dep sp=3Dr15,sp,61,3		// make stack pointer physical or virtual
+	;;
+	mov ar.rnat=3Dr18			// restore ar.rnat
+	dep r14=3Dr15,r14,61,3		// make function return address physical or virtu=
al
+	rfi				// must be last insn in group
+	;;
+1:	mov rp=3Dr14
+	br.ret.sptk.few rp
+END(ia64_switch_mode)
+
+#ifdef CONFIG_IA64_BRL_EMU
+
+/*
+ *  Assembly routines used by brl_emu.c to set preserved register state.
+ */
+
+#define SET_REG(reg)				\
+ GLOBAL_ENTRY(ia64_set_##reg);			\
+	alloc r16=3Dar.pfs,1,0,0,0;		\
+	mov reg=3Dr32;				\
+	;;					\
+	br.ret.sptk rp;				\
+ END(ia64_set_##reg)
+
+SET_REG(b1);
+SET_REG(b2);
+SET_REG(b3);
+SET_REG(b4);
+SET_REG(b5);
+
+#endif /* CONFIG_IA64_BRL_EMU */
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test1-lia/arch/ia=
64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/ivt.S	Thu Jun  1 01:03:38 2000
@@ -316,7 +316,7 @@
 	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RX
 	;;
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,IA64_PHYS_BITS,(64-IA64_PHYS_BITS) // clear ed, resvd, an=
d unimpl. phys bits
+	dep r16=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS)	// clear ed & =
reserved bits
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
@@ -331,18 +331,26 @@
 // 0x1000 Entry 4 (size 64 bundles) Alt DTLB (7,46)
 	mov r16=3Dcr.ifa		// get address that caused the TLB miss
 	movl r17=3D__DIRTY_BITS|_PAGE_PL_0|_PAGE_AR_RW
+	mov r20=3Dcr.isr
+	mov r21=3Dcr.ipsr
+	mov r19=3Dpr
 	;;
+	tbit.nz p6,p7=3Dr20,IA64_ISR_SP_BIT	// is speculation bit on?
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
-	dep r16=3D0,r16,IA64_PHYS_BITS,(64-IA64_PHYS_BITS) // clear ed, resvd, an=
d unimpl. phys bits
+	dep r16=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS) // clear ed & =
reserved bits
 	;;
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
 	;;
 	or r16=3Dr16,r18		// set bit 4 (uncached) if the access was to region 6
+(p6)	mov cr.ipsr=3Dr21
 	;;
-	itc.d r16		// insert the TLB entry
+(p7)	itc.d r16		// insert the TLB entry
+	mov pr=3Dr19,-1
 	rfi
=20
+	;;
+
 	//-----------------------------------------------------------------------=
------------
 	// call do_page_fault (predicates are in r31, psr.dt is off, r16 is fault=
ing address)
 page_fault:
@@ -647,6 +655,50 @@
 // 0x3c00 Entry 15 (size 64 bundles) Reserved
 	FAULT(15)
=20
+//
+//  Squatting in this space ...
+//
+//  This special case dispatcher for illegal operation faults
+//  allows preserved registers to be modified through a=20
+//  callback function (asm only) that is handed back from
+//  the fault handler in r8. Up to three arguments can be
+//  passed to the callback function by returning an aggregate
+//  with the callback as its first element, followed by the
+//  arguments.
+//
+dispatch_illegal_op_fault:
+	SAVE_MIN_WITH_COVER
+	//
+	// The "alloc" can cause a mandatory store which could lead to
+	// an "Alt DTLB" fault which we can handle only if psr.ic is on.
+	//
+	ssm psr.ic | psr.dt
+	;;
+	srlz.i		// guarantee that interrupt collection is enabled
+	;;
+(p15)	ssm psr.i	// restore psr.i
+	adds r3=3D8,r2	// set up second base pointer for SAVE_REST
+	;;
+	alloc r14=3Dar.pfs,0,0,1,0	// must be first in insn group
+	mov out0=3Dar.ec
+	;;
+	SAVE_REST
+	;;
+	br.call.sptk.few rp=3Dia64_illegal_op_fault
+	;;
+	alloc r14=3Dar.pfs,0,0,3,0	// must be first in insn group
+	mov out0=3Dr9
+	mov out1=3Dr10
+	mov out2=3Dr11
+	movl r15=3Dia64_leave_kernel
+	;;
+	mov rp=3Dr15
+	mov b6=3Dr8
+	;;
+	cmp.ne p6,p0=3D0,r8
+(p6)	br.call.dpnt b6=B6		// call returns to ia64_leave_kernel
+	br.sptk ia64_leave_kernel
+
 	.align 1024
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x4000 Entry 16 (size 64 bundles) Reserved
@@ -909,7 +961,16 @@
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
 // 0x5400 Entry 24 (size 16 bundles) General Exception (5,32,34,36,38,39)
-	FAULT(24)
+	mov r16=3Dcr.isr
+	mov r31=3Dpr
+	rsm psr.dt		// avoid nested faults due to TLB misses...
+	;;
+	srlz.d			// ensure everyone knows psr.dt is off...
+	cmp4.eq p6,p0=3D0,r16
+(p6)	br.sptk dispatch_illegal_op_fault
+	;;
+	mov r19$		// fault number
+	br.cond.sptk.many dispatch_to_fault_handler
=20
 	.align 256
 //////////////////////////////////////////////////////////////////////////=
///////////////
diff -urN linux-davidm/arch/ia64/kernel/minstate.h linux-2.4.0-test1-lia/ar=
ch/ia64/kernel/minstate.h
--- linux-davidm/arch/ia64/kernel/minstate.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/minstate.h	Thu Jun  1 01:03:59 2=
000
@@ -69,7 +69,7 @@
 (p7)	mov rARBSPSTORE=3Dar.bspstore;			/* save ar.bspstore */			  \
 (p7)	dep rKRBS=3D-1,rKRBS,61,3;			/* compute kernel virtual addr of RBS */=
  \
 	;;											  \
-(pKern)	addl r1=16-IA64_PT_REGS_SIZE,r1;	/* if in kernel mode, use sp (r12=
) */		  \
+(pKern)	addl r1=3D-IA64_PT_REGS_SIZE,r1;		/* if in kernel mode, use sp (r1=
2) */		  \
 (p7)	mov ar.bspstore=3DrKRBS;			/* switch to kernel RBS */			  \
 	;;											  \
 (p7)	mov r18=3Dar.bsp;										  \
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.0-test1-lia/arch/ia=
64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/pal.S	Thu Jun  1 01:04:13 2000
@@ -5,9 +5,14 @@
  * Copyright (C) 1999 Don Dugger <don.dugger@intel.com>
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999-2000 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ *
+ * 05/22/2000 eranian Added support for stacked register calls
+ * 05/24/2000 eranian Added support for physical mode static calls
  */
=20
 #include <asm/asmmacro.h>
+#include <asm/processor.h>
=20
 	.text
 	.psr abi64
@@ -83,3 +88,108 @@
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.few	b0
 END(ia64_pal_call_static)
+
+/*
+ * Make a PAL call using the stacked registers calling convention.
+ *
+ * Inputs:
+ * 	in0         Index of PAL service
+ * 	in2 - in3   Remaning PAL arguments
+ */
+GLOBAL_ENTRY(ia64_pal_call_stacked)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5))
+	alloc	loc1 =3D ar.pfs,5,4,87,0
+	movl	loc2 =3D pal_entry_point
+
+	mov	r28  =3D in0		// Index MUST be copied to r28
+	mov	out0 =3D in0		// AND in0 of PAL function
+	mov	loc0 =3D rp
+	.body
+	;;
+	ld8	loc2 =3D [loc2]		// loc2 <- entry point
+	mov	out1 =3D in1
+	mov	out2 =3D in2
+	mov	out3 =3D in3
+	mov	loc3 =3D psr
+	;;
+	rsm	psr.i
+	mov	b7 =3D loc2
+	;;=20
+	br.call.sptk.many rp=B7		// now make the call
+.ret2:
+	mov	psr.l  =3D loc3
+	mov	ar.pfs =3D loc1
+	mov	rp =3D loc0
+	;;
+	srlz.d				// serialize restoration of psr.l
+	br.ret.sptk.few	b0
+END(ia64_pal_call_stacked)
+
+/*
+ * Make a physical mode PAL call using the static registers calling conven=
tion.
+ *
+ * Inputs:
+ * 	in0         Index of PAL service
+ * 	in2 - in3   Remaning PAL arguments
+ *
+ * PSR_DB, PSR_LP, PSR_TB, PSR_ID, PSR_DA are never set by the kernel.
+ * So we don't need to clear them.
+ */
+#define PAL_PSR_BITS_TO_CLEAR						\
+	(IA64_PSR_I | IA64_PSR_IT | IA64_PSR_DT | IA64_PSR_RT |		\
+	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
+	 IA64_PSR_DFL | IA64_PSR_DFH)
+
+#define PAL_PSR_BITS_TO_SET							\
+	(IA64_PSR_BN)
+
+
+GLOBAL_ENTRY(ia64_pal_call_phys_static)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6))
+	alloc	loc1 =3D ar.pfs,6,90,0,0
+	movl	loc2 =3D pal_entry_point
+1:	{
+	  mov	r28  =3D in0		// copy procedure index
+	  mov	r8   =3D ip		// save ip to compute branch
+	  mov	loc0 =3D rp		// save rp
+	}
+	.body
+	;;
+	ld8	loc2 =3D [loc2]		// loc2 <- entry point
+	mov	r29  =3D in1		// first argument
+	mov	r30  =3D in2		// copy arg2
+	mov	r31  =3D in3		// copy arg3
+	;;
+	mov	loc3 =3D psr		// save psr
+	adds	r8   =3D .ret4-1b,r8	// calculate return address for call
+	;;=20
+	mov loc4=3Dar.rsc			// save RSE configuration
+	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
+	dep.z r8=3Dr8,0,61		// convert rp to physical
+	;;
+	mov b7 =3D loc2			// install target to branch reg
+	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	movl r16=3DPAL_PSR_BITS_TO_CLEAR
+	movl r17=3DPAL_PSR_BITS_TO_SET
+	;;
+	or loc3=3Dloc3,r17		// add in psr the bits to set
+	;;
+	andcm r16=3Dloc3,r16		// removes bits to clear from psr
+	br.call.sptk.few rp=3Dia64_switch_mode
+.ret3:
+	mov rp =3D r8			// install return address (physical)
+	br.cond.sptk.few b7
+.ret4:
+	mov ar.rsc=3Dr0			// put RSE in enforced lazy, LE mode
+	mov r16=3Dloc3			// r16=3D original psr
+	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
+
+.ret5:	mov	psr.l =3D loc3		// restore init PSR
+
+	mov	ar.pfs =3D loc1
+	mov	rp =3D loc0
+	;;
+	mov ar.rsc=3Dloc4			// restore RSE configuration
+	srlz.d				// seralize restoration of psr.l
+	br.ret.sptk.few	b0
+END(ia64_pal_call_phys_static)
diff -urN linux-davidm/arch/ia64/kernel/palinfo.c linux-2.4.0-test1-lia/arc=
h/ia64/kernel/palinfo.c
--- linux-davidm/arch/ia64/kernel/palinfo.c	Wed Dec 31 16:00:00 1969
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/palinfo.c	Thu Jun  1 01:04:23 20=
00
@@ -0,0 +1,780 @@
+/*
+ * palinfo.c
+ *
+ * Prints processor specific information reported by PAL.
+ * This code is based on specification of PAL as of the
+ * Intel IA-64 Architecture Software Developer's Manual v1.0.
+ *
+ *=20
+ * Copyright (C) 2000 Hewlett-Packard Co
+ * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
+ *=20
+ * 05/26/2000	S.Eranian	initial release
+ *
+ * ISSUES:
+ *	- because of some PAL bugs, some calls return invalid results or
+ *	  are empty for now.
+ *	- remove hack to avoid problem with <=3D 256M RAM for itr.
+ */
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/proc_fs.h>
+#include <linux/mm.h>
+
+#include <asm/pal.h>
+#include <asm/sal.h>
+#include <asm/efi.h>
+#include <asm/page.h>
+#include <asm/processor.h>
+
+/*
+ * Hope to get rid of these in a near future
+*/
+#define IA64_PAL_VERSION_BUG		1
+
+#define PALINFO_VERSION "0.1"
+
+typedef int (*palinfo_func_t)(char*);
+
+typedef struct {
+	const char		*name;		/* name of the proc entry */
+	palinfo_func_t		proc_read;	/* function to call for reading */
+	struct proc_dir_entry	*entry;		/* registered entry (removal) */
+} palinfo_entry_t;
+
+static struct proc_dir_entry *palinfo_dir;
+
+/*
+ *  A bunch of string array to get pretty printing
+ */
+
+static char *cache_types[] =3D {
+	"",			/* not used */
+	"Instruction",
+	"Data",
+	"Data/Instruction"	/* unified */
+};
+
+static const char *cache_mattrib[]=3D{
+	"WriteThrough",
+	"WriteBack",
+	"",		/* reserved */
+	""		/* reserved */
+};
+
+static const char *cache_st_hints[]=3D{
+	"Temporal, level 1",
+	"Reserved",
+	"Reserved",
+	"Non-temporal, all levels",
+	"Reserved",
+	"Reserved",
+	"Reserved",=09
+	"Reserved"
+};
+
+static const char *cache_ld_hints[]=3D{
+	"Temporal, level 1",
+	"Non-temporal, level 1",
+	"Reserved",
+	"Non-temporal, all levels",
+	"Reserved",
+	"Reserved",
+	"Reserved",=09
+	"Reserved"
+};
+
+static const char *rse_hints[]=3D{
+	"enforced lazy",
+	"eager stores",
+	"eager loads",
+	"eager loads and stores"
+};
+
+#define RSE_HINTS_COUNT (sizeof(rse_hints)/sizeof(const char *))
+
+/*
+ * The current resvision of the Volume 2 of=20
+ * IA-64 Architecture Software Developer's Manual is wrong.
+ * Table 4-10 has invalid information concerning the ma field:
+ * Correct table is:
+ *      bit 0 - 001 - UC
+ *      bit 4 - 100 - UC
+ *      bit 5 - 101 - UCE
+ *      bit 6 - 110 - WC
+ *      bit 7 - 111 - NatPage=20
+ */
+static const char *mem_attrib[]=3D{
+	"Write Back (WB)",		/* 000 */
+	"Uncacheable (UC)",		/* 001 */
+	"Reserved",			/* 010 */
+	"Reserved",			/* 011 */
+	"Uncacheable (UC)",		/* 100 */
+	"Uncacheable Exported (UCE)",	/* 101 */
+	"Write Coalescing (WC)",	/* 110 */
+	"NaTPage"			/* 111 */
+};
+
+
+
+/*
+ * Allocate a buffer suitable for calling PAL code in Virtual mode
+ *
+ * The documentation (PAL2.6) requires thius buffer to have a pinned
+ * translation to avoid any DTLB faults. For this reason we allocate
+ * a page (large enough to hold any possible reply) and use a DTC
+ * to hold the translation during the call. A call the free_palbuffer()
+ * is required to release ALL resources (page + translation).
+ *
+ * The size of the page allocated is based on the PAGE_SIZE defined
+ * at compile time for the kernel, i.e.  >=3D 4Kb.
+ *
+ * Return: a pointer to the newly allocated page (virtual address)
+ */
+static void *
+get_palcall_buffer(void)
+{
+	void *tmp;
+
+	tmp =3D (void *)__get_free_page(GFP_KERNEL);
+	if (tmp =3D 0) {
+		printk(KERN_ERR "%s: can't get a buffer page\n", __FUNCTION__);
+	} else if ( ((u64)tmp - PAGE_OFFSET) > (1<<_PAGE_SIZE_256M) )  { /* XXX: =
temporary hack */
+		unsigned long flags;
+
+		/* PSR.ic must be zero to insert new DTR */
+		ia64_clear_ic(flags);
+
+		/*
+		 * we  only insert of DTR
+		 *
+		 * XXX: we need to figure out a way to "allocate" TR(s) to avoid
+		 * conflicts. Maybe something in an include file like pgtable.h
+		 * page.h or processor.h
+		 *
+		 * ITR0/DTR0: used for kernel code/data
+		 * ITR1/DTR1: used by HP simulator
+		 * ITR2/DTR2: used to map PAL code
+		 */
+		ia64_itr(0x2, 3, (u64)tmp,
+			 pte_val(mk_pte_phys(__pa(tmp), __pgprot(__DIRTY_BITS|_PAGE_PL_0|_PAGE_=
AR_RW))), PAGE_SHIFT);
+
+		ia64_srlz_d ();
+
+		__restore_flags(flags);=09
+	}
+
+	return tmp;
+}
+
+/*
+ * Free a palcall buffer allocated with the previous call
+ *
+ * The translation is also purged.
+ */
+static void
+free_palcall_buffer(void *addr)
+{
+	__free_page(addr);
+	ia64_ptr(0x2, (u64)addr, PAGE_SHIFT);
+	ia64_srlz_d ();
+}
+
+/*
+ * Take a 64bit vector and produces a string such that
+ * if bit n is set then 2^n in clear text is generated. The adjustment
+ * to the right unit is also done.
+ *
+ * Input:
+ *	- a pointer to a buffer to hold the string
+ * 	- a 64-bit vector
+ * Ouput:
+ *	- a pointer to the end of the buffer
+ *
+ */
+static char *
+bitvector_process(char *p, u64 vector)
+{
+	int i,j;
+	const char *units[]=3D{ "", "K", "M", "G", "T" };
+
+	for (i=3D0, j=3D0; i < 64; i++ , j=3Di/10) {
+		if (vector & 0x1) {
+			p +=3D sprintf(p, "%d%s ", 1 << (i-j*10), units[j]);
+		}
+		vector >>=3D 1;
+	}
+	return p;
+}
+
+/*
+ * Take a 64bit vector and produces a string such that
+ * if bit n is set then register n is present. The function
+ * takes into account consecutive registers and prints out ranges.
+ *
+ * Input:
+ *	- a pointer to a buffer to hold the string
+ * 	- a 64-bit vector
+ * Ouput:
+ *	- a pointer to the end of the buffer
+ *
+ */
+static char *
+bitregister_process(char *p, u64 *reg_info, int max)
+{
+	int i, begin, skip =3D 0;
+	u64 value =3D reg_info[0];
+
+	value >>=3D i =3D begin =3D ffs(value) - 1;
+
+	for(; i < max; i++ ) {
+
+		if (i !=3D 0 && (i%64) =3D 0) value =3D *++reg_info;
+
+		if ((value & 0x1) =3D 0 && skip =3D 0) {
+			if (begin  <=3D i - 2)=20
+				p +=3D sprintf(p, "%d-%d ", begin, i-1);
+			else
+				p +=3D sprintf(p, "%d ", i-1);
+			skip  =3D 1;
+			begin =3D -1;
+		} else if ((value & 0x1) && skip =3D 1) {
+			skip =3D 0;
+			begin =3D i;
+		}
+		value >>=3D1;
+	}
+	if (begin > -1) {
+		if (begin < 127)=20
+			p +=3D sprintf(p, "%d-127", begin);
+		else
+			p +=3D sprintf(p, "127");
+	}
+
+	return p;
+}
+
+static int
+power_info(char *page)
+{
+	s64 status;
+	char *p =3D page;
+	pal_power_mgmt_info_u_t *halt_info;
+	int i;
+
+	halt_info =3D get_palcall_buffer();
+	if (halt_info =3D 0) return 0;
+
+	status =3D ia64_pal_halt_info(halt_info);
+	if (status !=3D 0) {
+		free_palcall_buffer(halt_info);
+		return 0;
+	}
+
+	for (i=3D0; i < 8 ; i++ ) {
+		if (halt_info[i].pal_power_mgmt_info_s.im =3D 1) {
+			p +=3D sprintf(p,	"Power level %d:\n" \
+					"\tentry_latency       : %d cycles\n" \
+				 	"\texit_latency        : %d cycles\n" \
+					"\tpower consumption   : %d mW\n" \
+					"\tCache+TLB coherency : %s\n", i,
+				halt_info[i].pal_power_mgmt_info_s.entry_latency,
+				halt_info[i].pal_power_mgmt_info_s.exit_latency,
+				halt_info[i].pal_power_mgmt_info_s.power_consumption,
+				halt_info[i].pal_power_mgmt_info_s.co ? "Yes" : "No");
+		} else {
+			p +=3D sprintf(p,"Power level %d: not implemented\n",i);
+		}
+	}
+
+	free_palcall_buffer(halt_info);
+
+	return p - page;
+}
+
+static int=20
+cache_info(char *page)
+{
+	char *p =3D page;
+	u64 levels, unique_caches;
+	pal_cache_config_info_t cci;
+	int i,j, k;
+	s64 status;
+
+	if ((status=3Dia64_pal_cache_summary(&levels, &unique_caches)) !=3D 0) {
+			printk("ia64_pal_cache_summary=3D%ld\n", status);
+			return 0;
+	}
+
+	p +=3D sprintf(p, "Cache levels  : %ld\n" \
+			"Unique caches : %ld\n\n",
+			levels,
+			unique_caches);
+
+	for (i=3D0; i < levels; i++) {
+
+		for (j=3D2; j >0 ; j--) {
+
+			/* even without unification some level may not be present */
+			if ((status=3Dia64_pal_cache_config_info(i,j, &cci)) !=3D 0) {
+				continue;
+			}
+			p +=3D sprintf(p, "%s Cache level %d:\n" \
+					"\tSize           : %ld bytes\n" \
+					"\tAttributes     : ",
+					cache_types[j+cci.pcci_unified], i+1,
+					cci.pcci_cache_size);
+
+			if (cci.pcci_unified) p +=3D sprintf(p, "Unified ");
+
+			p +=3D sprintf(p, "%s\n", cache_mattrib[cci.pcci_cache_attr]);
+
+			p +=3D sprintf(p, "\tAssociativity  : %d\n" \
+					"\tLine size      : %d bytes\n" \
+					"\tStride         : %d bytes\n",
+					cci.pcci_assoc,
+					1<<cci.pcci_line_size,
+					1<<cci.pcci_stride);
+			if (j =3D 1)
+				p +=3D sprintf(p, "\tStore latency  : N/A\n");
+			else
+				p +=3D sprintf(p, "\tStore latency  : %d cycle(s)\n",
+						cci.pcci_st_latency);
+
+			p +=3D sprintf(p, "\tLoad latency   : %d cycle(s)\n" \
+					"\tStore hints    : ",
+					cci.pcci_ld_latency);
+
+			for(k=3D0; k < 8; k++ ) {
+				if ( cci.pcci_st_hints & 0x1) p +=3D sprintf(p, "[%s]", cache_st_hints=
[k]);
+				cci.pcci_st_hints >>=3D1;=20
+			}
+			p +=3D sprintf(p, "\n\tLoad hints     : ");
+
+			for(k=3D0; k < 8; k++ ) {
+				if ( cci.pcci_ld_hints & 0x1) p +=3D sprintf(p, "[%s]", cache_ld_hints=
[k]);
+				cci.pcci_ld_hints >>=3D1;=20
+			}
+			p +=3D sprintf(p, "\n\tAlias boundary : %d byte(s)\n" \
+					"\tTag LSB        : %d\n" \
+					"\tTag MSB        : %d\n",
+					1<<cci.pcci_alias_boundary,
+					cci.pcci_tag_lsb,
+					cci.pcci_tag_msb);
+
+			/* when unified, data(j=3D2) is enough */
+			if (cci.pcci_unified) break;
+		}
+	}
+	return p - page;
+}
+
+
+static int
+vm_info(char *page)
+{
+	char *p =3D page;
+	u64 tr_pages =3D0, vw_pages=3D0, tc_pages;
+	u64 attrib;
+	pal_vm_info_1_u_t vm_info_1;
+	pal_vm_info_2_u_t vm_info_2;
+	pal_tc_info_u_t	tc_info;
+	ia64_ptce_info_t ptce;
+	int i, j;
+	s64 status;
+
+	if ((status=3Dia64_pal_vm_summary(&vm_info_1, &vm_info_2)) !=3D0) {
+		printk("ia64_pal_vm_summary=3D%ld\n", status);
+		return 0;
+	}
+
+
+	p +=3D sprintf(p, "Physical Address Space         : %d bits\n" \
+			"Virtual Address Space          : %d bits\n" \
+			"Protection Key Registers(PKR)  : %d\n" \
+			"Implemented bits in PKR.key    : %d\n" \
+			"Hash Tag ID                    : 0x%x\n" \
+			"Size of RR.rid                 : %d\n",
+			vm_info_1.pal_vm_info_1_s.phys_add_size,
+			vm_info_2.pal_vm_info_2_s.impl_va_msb+1,
+			vm_info_1.pal_vm_info_1_s.max_pkr+1,
+			vm_info_1.pal_vm_info_1_s.key_size,
+			vm_info_1.pal_vm_info_1_s.hash_tag_id,
+			vm_info_2.pal_vm_info_2_s.rid_size);
+
+	if (ia64_pal_mem_attrib(&attrib) !=3D 0) return 0;
+
+	p +=3D sprintf(p, "Supported memory attributes    : %s\n", mem_attrib[att=
rib&0x7]);
+
+	if ((status=3Dia64_pal_vm_page_size(&tr_pages, &vw_pages)) !=3D0) {
+		printk("ia64_pal_vm_page_size=3D%ld\n", status);
+		return 0;
+	}
+
+	p +=3D sprintf(p, "\nTLB walker                     : %s implemented\n" \
+			"Number of DTR                  : %d\n" \
+			"Number of ITR                  : %d\n" \
+			"TLB insertable page sizes      : ",
+			vm_info_1.pal_vm_info_1_s.vw ? "\b":"not",
+			vm_info_1.pal_vm_info_1_s.max_dtr_entry+1,
+			vm_info_1.pal_vm_info_1_s.max_itr_entry+1);
+
+
+	p =3D bitvector_process(p, tr_pages);
+
+	p +=3D sprintf(p, "\nTLB purgeable page sizes       : ");
+
+	p =3D bitvector_process(p, vw_pages);
+
+	if ((status=3Dia64_get_ptce(&ptce)) !=3D 0) {
+		printk("ia64_get_ptce=3D%ld\n",status);
+		return 0;
+	}
+
+	p +=3D sprintf(p, "\nPurge base address             : 0x%016lx\n" \
+			"Purge outer loop count         : %d\n" \
+			"Purge inner loop count         : %d\n" \
+			"Purge outer loop stride        : %d\n" \
+			"Purge inner loop stride        : %d\n",
+			ptce.base,
+			ptce.count[0],
+			ptce.count[1],
+			ptce.stride[0],
+			ptce.stride[1]);
+
+	p +=3D sprintf(p, "TC Levels                      : %d\n" \
+			"Unique TC(s)                   : %d\n",=20
+			vm_info_1.pal_vm_info_1_s.num_tc_levels,
+			vm_info_1.pal_vm_info_1_s.max_unique_tcs);
+
+	for(i=3D0; i < vm_info_1.pal_vm_info_1_s.num_tc_levels; i++) {
+		for (j=3D2; j>0 ; j--) {
+			tc_pages =3D 0; /* just in case */
+
+	=09
+			/* even without unification, some levels may not be present */
+			if ((status=3Dia64_pal_vm_info(i,j, &tc_info, &tc_pages)) !=3D 0) {
+				continue;
+			}
+
+			p +=3D sprintf(p, "\n%s Translation Cache Level %d:\n" \
+					"\tHash sets           : %d\n" \
+					"\tAssociativity       : %d\n" \
+					"\tNumber of entries   : %d\n" \
+					"\tFlags               : ",
+					cache_types[j+tc_info.tc_unified], i+1,
+					tc_info.tc_num_sets,
+					tc_info.tc_associativity,
+					tc_info.tc_num_entries);
+
+			if (tc_info.tc_pf) p +=3D sprintf(p, "PreferredPageSizeOptimized ");
+			if (tc_info.tc_unified) p +=3D sprintf(p, "Unified ");
+			if (tc_info.tc_reduce_tr) p +=3D sprintf(p, "TCReduction");
+
+			p +=3D sprintf(p, "\n\tSupported page sizes: ");
+
+			p =3D bitvector_process(p, tc_pages);
+
+			/* when unified date (j=3D2) is enough */
+			if (tc_info.tc_unified) break;
+		}
+	}
+	p +=3D sprintf(p, "\n");
+
+	return p - page;=09
+}
+
+
+static int
+register_info(char *page)
+{
+	char *p =3D page;
+	u64 reg_info[2];
+	u64 info;
+	u64 phys_stacked;
+	pal_hints_u_t hints;
+	u64 iregs, dregs;
+	char *info_type[]=3D{
+		"Implemented AR(s)",
+		"AR(s) with read side-effects",
+		"Implemented CR(s)",
+		"CR(s) with read side-effects",
+	};
+
+	for(info=3D0; info < 4; info++) {
+
+		if (ia64_pal_register_info(info, &reg_info[0], &reg_info[1]) !=3D 0) ret=
urn 0;
+
+	 	p +=3D sprintf(p, "%-32s : ", info_type[info]);
+
+		p =3D bitregister_process(p, reg_info, 128);
+
+		p +=3D sprintf(p, "\n");
+	}
+
+	if (ia64_pal_rse_info(&phys_stacked, &hints) !=3D 0) return 0;
+
+	p +=3D sprintf(p, "RSE stacked physical registers   : %ld\n" \
+			"RSE load/store hints             : %ld (%s)\n",
+			phys_stacked,
+			hints.ph_data,=20
+		     	hints.ph_data < RSE_HINTS_COUNT ? rse_hints[hints.ph_data]: "(??)"=
);
+
+	if (ia64_pal_debug_info(&iregs, &dregs)) return 0;
+
+	p +=3D sprintf(p, "Instruction debug register pairs : %ld\n" \
+			"Data debug register pairs        : %ld\n",
+			iregs, dregs);
+
+	return p - page;
+}
+
+static const char *proc_features[]=3D{
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL, NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL, NULL,NULL,NULL,NULL,
+	NULL,NULL,NULL,NULL,NULL,
+	"XIP,XPSR,XFS implemented",
+	"XR1-XR3 implemented",
+	"Disable dynamic predicate prediction",
+	"Disable processor physical number",
+	"Disable dynamic data cache prefetch",
+	"Disable dynamic inst cache prefetch",
+	"Disable dynamic branch prediction",
+	NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
+	"Disable BINIT on processor time-out",
+	"Disable dynamic power management (DPM)",
+	"Disable coherency",=20
+	"Disable cache",=20
+	"Enable CMCI promotion",
+	"Enable MCA to BINIT promotion",
+	"Enable MCA promotion",
+	"Enable BEER promotion"
+};
+
+=09
+static int
+processor_info(char *page)
+{
+	char *p =3D page;
+	const char **v =3D proc_features;
+	u64 avail=3D1, status=3D1, control=3D1;
+	int i;
+	s64 ret;
+
+	/* must be in physical mode */
+	if ((ret=3Dia64_pal_proc_get_features(&avail, &status, &control)) !=3D 0)=
 return 0;
+
+	for(i=3D0; i < 64; i++, v++,avail >>=3D1, status >>=3D1, control >>=3D1) {
+		if ( ! *v ) continue;
+		p +=3D sprintf(p, "%-40s : %s%s %s\n", *v,=20
+				avail & 0x1 ? "" : "NotImpl",
+				avail & 0x1 ? (status & 0x1 ? "On" : "Off"): "",
+				avail & 0x1 ? (control & 0x1 ? "Ctrl" : "NoCtrl"): "");
+	}
+	return p - page;
+}
+
+/*
+ * physical mode call for PAL_VERSION is working fine.
+ * This function is meant to go away once PAL get fixed.
+ */
+static inline s64=20
+ia64_pal_version_phys(pal_version_u_t *pal_min_version, pal_version_u_t *p=
al_cur_version)=20
+{=09
+	struct ia64_pal_retval iprv;
+	PAL_CALL_PHYS(iprv, PAL_VERSION, 0, 0, 0);
+	if (pal_min_version)
+		pal_min_version->pal_version_val =3D iprv.v0;
+	if (pal_cur_version)
+		pal_cur_version->pal_version_val =3D iprv.v1;
+	return iprv.status;=20
+}
+
+static int
+version_info(char *page)
+{
+	s64 status;
+	pal_version_u_t min_ver, cur_ver;
+	char *p =3D page;
+
+#ifdef IA64_PAL_VERSION_BUG
+	/* The virtual mode call is buggy. But the physical mode call seems
+	 * to be ok. Until they fix virtual mode, we do physical.
+	 */
+	status =3D ia64_pal_version_phys(&min_ver, &cur_ver);
+#else
+	/* The system crashes if you enable this code with the wrong PAL=20
+	 * code
+	 */
+	status =3D ia64_pal_version(&min_ver, &cur_ver);
+#endif
+	if (status !=3D 0) return 0;
+
+	p +=3D sprintf(p, "PAL_vendor     : 0x%x (min=3D0x%x)\n" \
+			"PAL_A revision : 0x%x (min=3D0x%x)\n" \
+			"PAL_A model    : 0x%x (min=3D0x%x)\n" \
+			"PAL_B mode     : 0x%x (min=3D0x%x)\n" \
+			"PAL_B revision : 0x%x (min=3D0x%x)\n",
+	     		cur_ver.pal_version_s.pv_pal_vendor,
+	     		min_ver.pal_version_s.pv_pal_vendor,
+	     		cur_ver.pal_version_s.pv_pal_a_rev,
+	     		cur_ver.pal_version_s.pv_pal_a_rev,
+	     		cur_ver.pal_version_s.pv_pal_a_model,
+	     		min_ver.pal_version_s.pv_pal_a_model,
+	     		cur_ver.pal_version_s.pv_pal_b_rev,
+	     		min_ver.pal_version_s.pv_pal_b_rev,
+	     		cur_ver.pal_version_s.pv_pal_b_model,
+	     		min_ver.pal_version_s.pv_pal_b_model);
+
+	return p - page;
+}
+
+static int
+perfmon_info(char *page)
+{
+	char *p =3D page;
+	u64 *pm_buffer;
+	pal_perf_mon_info_u_t pm_info;
+
+	pm_buffer =3D (u64 *)get_palcall_buffer();
+	if (pm_buffer =3D 0) return 0;
+
+	if (ia64_pal_perf_mon_info(pm_buffer, &pm_info) !=3D 0) {
+		free_palcall_buffer(pm_buffer);
+		return 0;
+	}
+
+#ifdef IA64_PAL_PERF_MON_INFO_BUG
+	pm_buffer[5]=3D0x3;
+	pm_info.pal_perf_mon_info_s.cycles  =3D 0x12;
+	pm_info.pal_perf_mon_info_s.retired =3D 0x08;
+#endif
+
+	p +=3D sprintf(p, "PMC/PMD pairs                 : %d\n" \
+			"Counter width                 : %d bits\n" \
+			"Cycle event number            : %d\n" \
+			"Retired event number          : %d\n" \
+			"Implemented PMC               : ",=20
+			pm_info.pal_perf_mon_info_s.generic,
+			pm_info.pal_perf_mon_info_s.width,
+			pm_info.pal_perf_mon_info_s.cycles,
+			pm_info.pal_perf_mon_info_s.retired);
+
+	p =3D bitregister_process(p, pm_buffer, 256);
+
+	p +=3D sprintf(p, "\nImplemented PMD               : ");
+=09
+	p =3D bitregister_process(p, pm_buffer+4, 256);
+
+	p +=3D sprintf(p, "\nCycles count capable          : ");
+=09
+	p =3D bitregister_process(p, pm_buffer+8, 256);
+
+	p +=3D sprintf(p, "\nRetired bundles count capable : ");
+=09
+	p =3D bitregister_process(p, pm_buffer+12, 256);
+
+	p +=3D sprintf(p, "\n");
+
+	free_palcall_buffer(pm_buffer);
+
+	return p - page;
+}
+
+static int
+frequency_info(char *page)
+{
+	char *p =3D page;
+	struct pal_freq_ratio proc, itc, bus;
+	u64 base;
+
+	if (ia64_pal_freq_base(&base) =3D -1)
+		p +=3D sprintf(p, "Output clock            : not implemented\n");=20
+	else
+		p +=3D sprintf(p, "Output clock            : %ld ticks/s\n", base);
+
+	if (ia64_pal_freq_ratios(&proc, &bus, &itc) !=3D 0) return 0;
+
+	p +=3D sprintf(p, "Processor/Clock ratio   : %ld/%ld\n" \
+			"Bus/Clock ratio         : %ld/%ld\n" \
+			"ITC/Clock ratio         : %ld/%ld\n",
+			proc.num, proc.den,
+			bus.num, bus.den,
+			itc.num, itc.den);
+
+	return p - page;
+}
+
+
+/*
+ * Entry point routine: all calls go trhough this function
+ */
+static int
+palinfo_read_entry(char *page, char **start, off_t off, int count, int *eo=
f, void *data)
+{
+	palinfo_func_t info =3D (palinfo_func_t)data;
+        int len =3D info(page);
+
+        if (len <=3D off+count) *eof =3D 1;
+
+        *start =3D page + off;
+        len   -=3D off;
+
+        if (len>count) len =3D count;
+        if (len<0) len =3D 0;
+
+        return len;
+}
+
+/*
+ * List names,function pairs for every entry in /proc/palinfo
+ * Must be terminated with the NULL,NULL entry.
+ */
+static palinfo_entry_t palinfo_entries[]=3D{
+	{ "version_info",	version_info, },
+	{ "vm_info", 		vm_info, },
+	{ "cache_info",		cache_info, },
+	{ "power_info",		power_info, },
+	{ "register_info",	register_info, },
+	{ "processor_info",	processor_info, },
+	{ "perfmon_info",	perfmon_info, },
+	{ "frequency_info",	frequency_info, },
+	{ NULL,			NULL,}
+};
+
+
+static int __init=20
+palinfo_init(void)
+{
+	palinfo_entry_t *p;
+
+	printk(KERN_INFO "PAL Information Facility v%s\n", PALINFO_VERSION);
+
+	palinfo_dir =3D create_proc_entry("palinfo",  S_IFDIR | S_IRUGO | S_IXUGO=
, NULL);
+
+	for (p =3D palinfo_entries; p->name ; p++){
+		p->entry =3D create_proc_read_entry (p->name, 0, palinfo_dir,=20
+						   palinfo_read_entry, p->proc_read);
+	}
+
+	return 0;
+}
+
+static int __exit
+palinfo_exit(void)
+{
+	palinfo_entry_t *p;
+
+	for (p =3D palinfo_entries; p->name ; p++){
+		remove_proc_entry (p->name, palinfo_dir);
+	}
+	remove_proc_entry ("palinfo", 0);
+
+	return 0;
+}
+
+module_init(palinfo_init);
+module_exit(palinfo_exit);
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/setup.c	Thu Jun  1 01:04:49 2000
@@ -108,6 +108,8 @@
 {
 	unsigned long max_pfn, bootmap_start, bootmap_size;
=20
+	unw_init();
+
 	/*
 	 * The secondary bootstrap loader passes us the boot
 	 * parameters at the beginning of the ZERO_PAGE, so let's
@@ -155,10 +157,8 @@
 #ifdef CONFIG_SMP
 	bootstrap_processor =3D hard_smp_processor_id();
 	current->processor =3D bootstrap_processor;
-#else
-	cpu_init();
-	identify_cpu(&cpu_data[0]);
 #endif
+	cpu_init();	/* initialize the bootstrap CPU */
=20
 	if (efi.acpi) {
 		/* Parse the ACPI tables */
@@ -270,11 +270,14 @@
 			u64 features;
 		} field;
 	} cpuid;
+	pal_vm_info_1_u_t vm1;
+	pal_vm_info_2_u_t vm2;
+	pal_status_t status;
+	unsigned long impl_va_msb =3D 50, phys_addr_size =3D 44;	/* Itanium defau=
lts */
 	int i;
=20
-	for (i =3D 0; i < 5; ++i) {
+	for (i =3D 0; i < 5; ++i)
 		cpuid.bits[i] =3D ia64_get_cpuid(i);
-	}
=20
 	memset(c, 0, sizeof(struct cpuinfo_ia64));
=20
@@ -287,6 +290,24 @@
 	c->archrev =3D cpuid.field.archrev;
 	c->features =3D cpuid.field.features;
=20
+	status =3D ia64_pal_vm_summary(&vm1, &vm2);
+	if (status =3D PAL_STATUS_SUCCESS) {
+#if 1
+		/*
+		 * XXX the current PAL code returns IMPL_VA_MSB=3D60, which is dead-wron=
g.
+		 * --davidm 00/05/26
+		 s*/
+		impl_va_msb =3D 50;
+#else
+		impl_va_msb =3D vm2.pal_vm_info_2_s.impl_va_msb;
+#endif
+		phys_addr_size =3D vm1.pal_vm_info_1_s.phys_add_size;
+	}
+	printk("processor implements %lu virtual and %lu physical address bits\n",
+	       impl_va_msb + 1, phys_addr_size);
+	c->unimpl_va_mask =3D ~((7L<<61) | ((1L << (impl_va_msb + 1)) - 1));
+	c->unimpl_pa_mask =3D ~((1L<<63) | ((1L << phys_addr_size) - 1));
+
 #ifdef CONFIG_IA64_SOFTSDV_HACKS
 	/* BUG: SoftSDV doesn't support the cpuid registers. */
 	if (c->vendor[0] =3D '\0')=20
@@ -301,6 +322,11 @@
 void
 cpu_init (void)
 {
+	extern void __init ia64_rid_init (void);
+	extern void __init ia64_tlb_init (void);
+
+	identify_cpu(&my_cpu_data);
+
 	/* Clear the stack memory reserved for pt_regs: */
 	memset(ia64_task_regs(current), 0, sizeof(struct pt_regs));
=20
@@ -314,6 +340,14 @@
 	 */
 	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_PP);
 	ia64_set_fpu_owner(0);		/* initialize ar.k5 */
+
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm =3D &init_mm;
+
+	ia64_rid_init();
+	ia64_tlb_init();
+
+#ifdef CONFIG_SMP
+	normal_xtp();
+#endif
 }
diff -urN linux-davidm/arch/ia64/kernel/signal.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/signal.c
--- linux-davidm/arch/ia64/kernel/signal.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/signal.c	Thu Jun  1 01:05:04 2000
@@ -71,8 +71,15 @@
 	 * pre-set the correct error code here to ensure that the right values
 	 * get saved in sigcontext by ia64_do_signal.
 	 */
-	pt->r8 =3D EINTR;
-	pt->r10 =3D -1;
+#ifdef CONFIG_IA32_SUPPORT
+        if (IS_IA32_PROCESS(pt)) {
+                pt->r8 =3D -EINTR;
+        } else
+#endif
+	{
+		pt->r8 =3D EINTR;
+		pt->r10 =3D -1;
+	}
 	while (1) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		schedule();
@@ -138,7 +145,8 @@
 	return err;
 }
=20
-int copy_siginfo_to_user(siginfo_t *to, siginfo_t *from)
+int
+copy_siginfo_to_user (siginfo_t *to, siginfo_t *from)
 {
 	if (!access_ok (VERIFY_WRITE, to, sizeof(siginfo_t)))
 		return -EFAULT;
@@ -147,29 +155,32 @@
 	else {
 		int err;
=20
-		/* If you change siginfo_t structure, please be sure
-		   this code is fixed accordingly.
-		   It should never copy any pad contained in the structure
-		   to avoid security leaks, but must copy the generic
-		   3 ints plus the relevant union member.  */
+		/*
+		 * If you change siginfo_t structure, please be sure
+		 * this code is fixed accordingly.  It should never
+		 * copy any pad contained in the structure to avoid
+		 * security leaks, but must copy the generic 3 ints
+		 * plus the relevant union member.
+		 */
 		err =3D __put_user(from->si_signo, &to->si_signo);
 		err |=3D __put_user(from->si_errno, &to->si_errno);
 		err |=3D __put_user((short)from->si_code, &to->si_code);
 		switch (from->si_code >> 16) {
-		case __SI_FAULT >> 16:
-		case __SI_POLL >> 16:
+		      case __SI_FAULT >> 16:
+			err |=3D __put_user(from->si_isr, &to->si_isr);
+		      case __SI_POLL >> 16:
 			err |=3D __put_user(from->si_addr, &to->si_addr);
 			err |=3D __put_user(from->si_imm, &to->si_imm);
 			break;
-		case __SI_CHLD >> 16:
+		      case __SI_CHLD >> 16:
 			err |=3D __put_user(from->si_utime, &to->si_utime);
 			err |=3D __put_user(from->si_stime, &to->si_stime);
 			err |=3D __put_user(from->si_status, &to->si_status);
-		default:
+		      default:
 			err |=3D __put_user(from->si_uid, &to->si_uid);
 			err |=3D __put_user(from->si_pid, &to->si_pid);
 			break;
-		/* case __SI_RT: This is not generated by the kernel as of now.  */
+		      /* case __SI_RT: This is not generated by the kernel as of now.  */
 		}
 		return err;
 	}
@@ -563,6 +574,11 @@
 			      case ERESTARTSYS:
 				if ((ka->sa.sa_flags & SA_RESTART) =3D 0) {
 			      case ERESTARTNOHAND:
+#ifdef CONFIG_IA32_SUPPORT
+					if (IS_IA32_PROCESS(pt))
+						pt->r8 =3D -EINTR;
+					else
+#endif
 					pt->r8 =3D EINTR;
 					/* note: pt->r10 is already -1 */
 					break;
diff -urN linux-davidm/arch/ia64/kernel/smp.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/smp.c
--- linux-davidm/arch/ia64/kernel/smp.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/smp.c	Thu Jun  1 01:06:05 2000
@@ -81,6 +81,7 @@
 #ifndef CONFIG_ITANIUM_PTCG
 # define IPI_FLUSH_TLB		3
 #endif	/*!CONFIG_ITANIUM_PTCG */
+#define IPI_KDB_INTERRUPT	4
=20
 /*
  *	Setup routine for controlling SMP activation
@@ -245,6 +246,9 @@
 				start +=3D (1UL << nbits);
 			} while (start < end);
=20
+			ia64_insn_group_barrier();
+			ia64_srlz_i();			/* srlz.i implies srlz.d */
+
 			if (saved_rid !=3D flush_rid) {
 				ia64_set_rr(flush_start, saved_rid);
 				ia64_srlz_d();
@@ -440,19 +444,6 @@
 	}
 }
=20
-
-/*
- * Called by both boot and secondaries to move global data into
- * per-processor storage.
- */
-static inline void __init
-smp_store_cpu_info(int cpuid)
-{
-	struct cpuinfo_ia64 *c =3D &cpu_data[cpuid];
-
-	identify_cpu(c);
-}
-
 static inline void __init
 smp_calibrate_delay(int cpuid)
 {
@@ -521,16 +512,8 @@
 	extern void ia64_init_itm(void);
 	extern void ia64_cpu_local_tick(void);
=20
-	ia64_set_dcr(IA64_DCR_DR | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_PP);
-	ia64_set_fpu_owner(0);	      =20
-	ia64_rid_init();		/* initialize region ids */
-
 	cpu_init();
-	__flush_tlb_all();
-
-	normal_xtp();
=20
-	smp_store_cpu_info(smp_processor_id());
 	smp_setup_percpu_timer(smp_processor_id());
=20
 	/* setup the CPU local timer tick */
@@ -658,16 +641,7 @@
 	/* Setup BSP mappings */
 	__cpu_number_map[bootstrap_processor] =3D 0;
 	__cpu_logical_map[0] =3D bootstrap_processor;
-	current->processor =3D bootstrap_processor;
=20
-	/* Mark BSP booted and get active_mm context */
-	cpu_init();
-
-	/* reset XTP for interrupt routing */
-	normal_xtp();
-
-	/* And generate an entry in cpu_data */
-	smp_store_cpu_info(bootstrap_processor);
 	smp_calibrate_delay(smp_processor_id());
 #if 0
 	smp_tune_scheduling();
@@ -785,4 +759,3 @@
 	}
=20
 }
-
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/traps.c	Thu Jun  1 01:07:02 2000
@@ -36,6 +36,10 @@
 #include <linux/init.h>
 #include <linux/sched.h>
=20
+#ifdef CONFIG_KDB
+#include <linux/kdb.h>
+#endif
+
 #include <asm/ia32.h>
 #include <asm/processor.h>
 #include <asm/uaccess.h>
@@ -89,6 +93,13 @@
=20
 	printk("%s[%d]: %s %ld\n", current->comm, current->pid, str, err);
=20
+#ifdef CONFIG_KDB
+	while (1) {
+                kdb(KDB_REASON_PANIC, 0, regs);
+                printk("Cant go anywhere from Panic!\n");
+	}
+#endif
+
 	show_regs(regs);
=20
 	if (current->thread.flags & IA64_KERNEL_DEATH) {
@@ -361,6 +372,42 @@
 		}
 	}
 	return 0;
+}
+
+struct illegal_op_return {
+	unsigned long fkt, arg1, arg2, arg3;
+};
+
+struct illegal_op_return
+ia64_illegal_op_fault (unsigned long ec, unsigned long arg1, unsigned long=
 arg2,
+		       unsigned long arg3, unsigned long arg4, unsigned long arg5,
+		       unsigned long arg6, unsigned long arg7, unsigned long stack)
+{
+	struct pt_regs *regs =3D (struct pt_regs *) &stack;
+	struct illegal_op_return rv;
+	struct siginfo si;
+	char buf[128];
+
+#ifdef CONFIG_IA64_BRL_EMU=09
+	{
+		extern struct illegal_op_return ia64_emulate_brl (struct pt_regs *, unsi=
gned long);
+
+		rv =3D ia64_emulate_brl(regs, ec);
+		if (rv.fkt !=3D (unsigned long) -1)
+			return rv;
+	}
+#endif
+
+	sprintf(buf, "IA-64 Illegal operation fault");
+	die_if_kernel(buf, regs, 0);
+
+	memset(&si, 0, sizeof(si));
+	si.si_signo =3D SIGILL;
+	si.si_code =3D ILL_ILLOPC;
+	si.si_addr =3D (void *) (regs->cr_iip + ia64_psr(regs)->ri);
+	force_sig_info(SIGILL, &si, current);
+	rv.fkt =3D 0;
+	return rv;
 }
=20
 void
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.0-test1-lia/a=
rch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Fri Apr 21 15:21:24 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unaligned.c	Thu Jun  1 01:07:40 =
2000
@@ -1,8 +1,8 @@
 /*
  * Architecture-specific unaligned trap handling.
  *
- * Copyright (C) 1999 Hewlett-Packard Co
- * Copyright (C) 1999 Stephane Eranian <eranian@hpl.hp.com>
+ * Copyright (C) 1999-2000 Hewlett-Packard Co
+ * Copyright (C) 1999-2000 Stephane Eranian <eranian@hpl.hp.com>
  */
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -1410,6 +1410,25 @@
 		die_if_kernel("Unaligned reference while in kernel\n", regs, 30);
 		/* NOT_REACHED */
 	}
+	/*
+	 * For now, we don't support user processes running big-endian
+	 * which do unaligned accesses
+	 */
+	if (ia64_psr(regs)->be) {
+		struct siginfo si;
+
+		printk(KERN_ERR "%s(%d): big-endian unaligned access %016lx (ip=3D%016lx=
) not "
+		       "yet supported\n",
+		       current->comm, current->pid, ifa, regs->cr_iip + ipsr->ri);
+
+		si.si_signo =3D SIGBUS;
+		si.si_errno =3D 0;
+		si.si_code =3D BUS_ADRALN;
+		si.si_addr =3D (void *) ifa;
+		send_sig_info(SIGBUS, &si, current);
+		return;
+	}
+
 	if (current->thread.flags & IA64_THREAD_UAC_SIGBUS) {
 		struct siginfo si;
=20
@@ -1417,7 +1436,7 @@
 		si.si_errno =3D 0;
 		si.si_code =3D BUS_ADRALN;
 		si.si_addr =3D (void *) ifa;
-		send_sig_info (SIGBUS, &si, current);
+		send_sig_info(SIGBUS, &si, current);
 		return;
 	}
=20
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unwind.c	Thu Jun  1 01:07:55 2000
@@ -2,6 +2,16 @@
  * Copyright (C) 1999-2000 Hewlett-Packard Co
  * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
+/*
+ * SMP conventions:
+ *	o updates to the global unwind data (in structure "unw") are serialized
+ *	  by the unw.lock spinlock
+ *	o each unwind script has its own read-write lock; a thread must acquire
+ *	  a read lock before executing a script and must acquire a write lock
+ *	  before modifying a script
+ *	o if both the unw.lock spinlock and a script's read-write lock must be
+ *	  acquired, then the read-write lock must be acquired first.
+ */
 #include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
@@ -11,6 +21,7 @@
=20
 #ifdef CONFIG_IA64_NEW_UNWIND
=20
+#include <asm/delay.h>
 #include <asm/ptrace.h>
 #include <asm/ptrace_offsets.h>
 #include <asm/rse.h>
@@ -32,202 +43,517 @@
  */
 #define UNWIND_TABLE_SORT_BUG
=20
-#define UNW_DEBUG	1
+#define UNW_LOG_CACHE_SIZE	7	/* each unw_script is ~256 bytes in size */
+#define UNW_CACHE_SIZE		(1 << UNW_LOG_CACHE_SIZE)
+
+#define UNW_LOG_HASH_SIZE	(UNW_LOG_CACHE_SIZE + 1)
+#define UNW_HASH_SIZE		(1 << UNW_LOG_HASH_SIZE)
+
+#define UNW_DEBUG	0
+#define UNW_STATS	0	/* WARNING: this disabled interrupts for long time-spa=
ns!! */
=20
 #if UNW_DEBUG
 # define dprintk(format...)	printk(format)
+# define inline
 #else
 # define dprintk(format...)
 #endif
=20
+#if UNW_STATS
+# define STAT(x...)	x
+#else
+# define STAT(x...)
+#endif
+
 #define alloc_reg_state()	kmalloc(sizeof(struct unw_state_record), GFP_ATO=
MIC)
 #define free_reg_state(usr)	kfree(usr)
=20
 typedef unsigned long unw_word;
-
-static const enum unw_register_index save_order[] =3D {
-	UNW_REG_RP, UNW_REG_PFS, UNW_REG_PSP, UNW_REG_PR,
-	UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
-};
+typedef unsigned char unw_hash_index_t;
=20
 #define struct_offset(str,fld)	((char *)&((str *)NULL)->fld - (char *) 0)
=20
-static unsigned short preg_index[UNW_NUM_REGS] =3D {
-	struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_GR */
-	struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_MEM */
-	struct_offset(struct unw_frame_info, pbsp)/8,
-	struct_offset(struct unw_frame_info, bspstore)/8,
-	struct_offset(struct unw_frame_info, pfs)/8,
-	struct_offset(struct unw_frame_info, rnat)/8,
-	struct_offset(struct unw_frame_info, psp)/8,
-	struct_offset(struct unw_frame_info, rp)/8,
-	struct_offset(struct unw_frame_info, r4)/8,
-	struct_offset(struct unw_frame_info, r5)/8,
-	struct_offset(struct unw_frame_info, r6)/8,
-	struct_offset(struct unw_frame_info, r7)/8,
-	struct_offset(struct unw_frame_info, unat)/8,
-	struct_offset(struct unw_frame_info, pr)/8,
-	struct_offset(struct unw_frame_info, lc)/8,
-	struct_offset(struct unw_frame_info, fpsr)/8,
-	struct_offset(struct unw_frame_info, b1)/8,
-	struct_offset(struct unw_frame_info, b2)/8,
-	struct_offset(struct unw_frame_info, b3)/8,
-	struct_offset(struct unw_frame_info, b4)/8,
-	struct_offset(struct unw_frame_info, b5)/8,
-	struct_offset(struct unw_frame_info, f2)/8,
-	struct_offset(struct unw_frame_info, f3)/8,
-	struct_offset(struct unw_frame_info, f4)/8,
-	struct_offset(struct unw_frame_info, f5)/8,
-	struct_offset(struct unw_frame_info, fr[16])/8,
-	struct_offset(struct unw_frame_info, fr[17])/8,
-	struct_offset(struct unw_frame_info, fr[18])/8,
-	struct_offset(struct unw_frame_info, fr[19])/8,
-	struct_offset(struct unw_frame_info, fr[20])/8,
-	struct_offset(struct unw_frame_info, fr[21])/8,
-	struct_offset(struct unw_frame_info, fr[22])/8,
-	struct_offset(struct unw_frame_info, fr[23])/8,
-	struct_offset(struct unw_frame_info, fr[24])/8,
-	struct_offset(struct unw_frame_info, fr[25])/8,
-	struct_offset(struct unw_frame_info, fr[26])/8,
-	struct_offset(struct unw_frame_info, fr[27])/8,
-	struct_offset(struct unw_frame_info, fr[28])/8,
-	struct_offset(struct unw_frame_info, fr[29])/8,
-	struct_offset(struct unw_frame_info, fr[30])/8,
-	struct_offset(struct unw_frame_info, fr[31])/8,
-};
+static struct {
+	struct unw_table *tables;
=20
+	const unsigned char save_order[8];
+	/* Maps a preserved register index (preg_index) to corresponding switch_s=
tack offset: */
+	unsigned short sw_off[sizeof(struct unw_frame_info) / 8];
+
+	unsigned short lru_head;
+	unsigned short lru_tail;
+	unsigned short preg_index[UNW_NUM_REGS];
+	struct unw_table kernel_table;
+
+	spinlock_t lock;
+	unw_hash_index_t hash[UNW_HASH_SIZE];
+	struct unw_script cache[UNW_CACHE_SIZE];
+
+# if UNW_DEBUG
+	const char *preg_name[UNW_NUM_REGS];
+# endif
+# if UNW_STATS
+	struct {
+		struct {
+			int lookups;
+			int hinted_hits;
+			int normal_hits;
+			int collision_chain_traversals;
+		} cache;
+		struct {
+			unsigned long build_time;
+			unsigned long run_time;
+			unsigned long parse_time;
+			int builds;
+			int news;
+			int collisions;
+			int runs;
+		} script;
+		struct {
+			unsigned long init_time;
+			unsigned long unwind_time;
+			int inits;
+			int unwinds;
+		} api;
+	} stat;
+# endif
+} unw =3D {
+	tables: &unw.kernel_table,
+	lock: SPIN_LOCK_UNLOCKED,
+	save_order: {
+		UNW_REG_RP, UNW_REG_PFS, UNW_REG_PSP, UNW_REG_PR,
+		UNW_REG_UNAT, UNW_REG_LC, UNW_REG_FPSR, UNW_REG_PRI_UNAT_GR
+	},
+	preg_index: {
+		struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_GR */
+		struct_offset(struct unw_frame_info, pri_unat)/8,	/* PRI_UNAT_MEM */
+		struct_offset(struct unw_frame_info, pbsp)/8,
+		struct_offset(struct unw_frame_info, bspstore)/8,
+		struct_offset(struct unw_frame_info, pfs)/8,
+		struct_offset(struct unw_frame_info, rnat)/8,
+		struct_offset(struct unw_frame_info, psp)/8,
+		struct_offset(struct unw_frame_info, rp)/8,
+		struct_offset(struct unw_frame_info, r4)/8,
+		struct_offset(struct unw_frame_info, r5)/8,
+		struct_offset(struct unw_frame_info, r6)/8,
+		struct_offset(struct unw_frame_info, r7)/8,
+		struct_offset(struct unw_frame_info, unat)/8,
+		struct_offset(struct unw_frame_info, pr)/8,
+		struct_offset(struct unw_frame_info, lc)/8,
+		struct_offset(struct unw_frame_info, fpsr)/8,
+		struct_offset(struct unw_frame_info, b1)/8,
+		struct_offset(struct unw_frame_info, b2)/8,
+		struct_offset(struct unw_frame_info, b3)/8,
+		struct_offset(struct unw_frame_info, b4)/8,
+		struct_offset(struct unw_frame_info, b5)/8,
+		struct_offset(struct unw_frame_info, f2)/8,
+		struct_offset(struct unw_frame_info, f3)/8,
+		struct_offset(struct unw_frame_info, f4)/8,
+		struct_offset(struct unw_frame_info, f5)/8,
+		struct_offset(struct unw_frame_info, fr[16 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[17 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[18 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[19 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[20 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[21 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[22 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[23 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[24 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[25 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[26 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[27 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[28 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[29 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[30 - 16])/8,
+		struct_offset(struct unw_frame_info, fr[31 - 16])/8,
+	},
+	hash : { [0 ... UNW_HASH_SIZE - 1] =3D -1 },
 #if UNW_DEBUG
-
-static const char *preg_name[UNW_NUM_REGS] =3D {
-	"pri_unat_gr", "pri_unat_mem", "bsp", "bspstore", "ar.pfs", "ar.rnat", "p=
sp", "rp",
-	"r4", "r5", "r6", "r7",
-	"ar.unat", "pr", "ar.lc", "ar.fpsr",
-	"b1", "b2", "b3", "b4", "b5",
-	"f2", "f3", "f4", "f5",
-	"f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23",
-	"f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31"
+	preg_name: {
+		"pri_unat_gr", "pri_unat_mem", "bsp", "bspstore", "ar.pfs", "ar.rnat", "=
psp", "rp",
+		"r4", "r5", "r6", "r7",
+		"ar.unat", "pr", "ar.lc", "ar.fpsr",
+		"b1", "b2", "b3", "b4", "b5",
+		"f2", "f3", "f4", "f5",
+		"f16", "f17", "f18", "f19", "f20", "f21", "f22", "f23",
+		"f24", "f25", "f26", "f27", "f28", "f29", "f30", "f31"
+	}
+#endif
 };
=20
-#endif /* UNW_DEBUG */
-
-/* Maps a preserved register index (preg_index) into the corresponding swi=
tch_stack offset: */
-static unsigned short sw_offset[sizeof (struct unw_frame_info) / 8];
+=0C
+/* Unwind accessors.  */
=20
-static struct unw_table *unw_tables;
-
-static void
-push (struct unw_state_record *sr)
+int
+unw_access_gr (struct unw_frame_info *info, int regnum, unsigned long *val=
, char *nat, int write)
 {
-	struct unw_reg_state *rs;
+	unsigned long *addr, *nat_addr, nat_mask =3D 0, dummy_nat;
+	struct unw_ireg *ireg;
+	struct pt_regs *pt;
=20
-	rs =3D alloc_reg_state();
-	memcpy(rs, &sr->curr, sizeof(*rs));
-	rs->next =3D sr->stack;
-	sr->stack =3D rs;
-}
+	if ((unsigned) regnum - 1 >=3D 127)
+		return -1;
=20
-static void
-pop (struct unw_state_record *sr)
-{
-	struct unw_reg_state *rs;
+	if (regnum < 32) {
+		if (regnum >=3D 4 && regnum <=3D 7) {
+			/* access a preserved register */
+			ireg =3D &info->r4 + (regnum - 4);
+			addr =3D ireg->loc;
+			if (addr) {
+				nat_addr =3D addr + ireg->nat.off;
+				switch (ireg->nat.type) {
+				      case UNW_NAT_VAL:
+					/* simulate getf.sig/setf.sig */
+					if (write) {
+						if (*nat) {
+							/* write NaTVal and be done with it */
+							addr[0] =3D 0;
+							addr[1] =3D 0x1fffe;
+							return 0;
+						}
+						addr[1] =3D 0x1003e;
+					} else {
+						if (addr[0] =3D 0 && addr[1] =3D 0x1ffe) {
+							/* return NaT and be done with it */
+							*val =3D 0;
+							*nat =3D 1;
+							return 0;
+						}
+					}
+					/* fall through */
+				      case UNW_NAT_NONE:
+					nat_addr =3D &dummy_nat;
+					break;
=20
-	if (!sr->stack) {
-		printk ("unwind: stack underflow!\n");
-		return;
+				      case UNW_NAT_SCRATCH:
+					if (info->unat)
+						nat_addr =3D info->unat;
+					else
+						nat_addr =3D &info->sw->caller_unat;
+				      case UNW_NAT_PRI_UNAT:
+					nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
+					break;
+
+				      case UNW_NAT_STACKED:
+					nat_addr =3D ia64_rse_rnat_addr(addr);
+					if ((unsigned long) addr < info->regstk.limit
+					    || (unsigned long) addr >=3D info->regstk.top)
+						return -1;
+					if ((unsigned long) nat_addr >=3D info->regstk.top)
+						nat_addr =3D &info->sw->ar_rnat;
+					nat_mask =3D (1UL << ia64_rse_slot_num(addr));
+					break;
+				}
+			} else {
+				addr =3D &info->sw->r4 + (regnum - 4);
+				nat_addr =3D &info->sw->ar_unat;
+				nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
+			}
+		} else {
+			/* access a scratch register */
+			pt =3D (struct pt_regs *) info->sp - 1;
+			if (regnum <=3D 3)
+				addr =3D &pt->r1 + (regnum - 1);
+			else if (regnum <=3D 11)
+				addr =3D &pt->r8 + (regnum - 8);
+			else if (regnum <=3D 15)
+				addr =3D &pt->r12 + (regnum - 12);
+			else
+				addr =3D &pt->r16 + (regnum - 16);
+			if (info->unat)
+				nat_addr =3D info->unat;
+			else
+				nat_addr =3D &info->sw->caller_unat;
+			nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
+		}
+	} else {
+		/* access a stacked register */
+		addr =3D ia64_rse_skip_regs((unsigned long *) info->bsp, regnum);
+		nat_addr =3D ia64_rse_rnat_addr(addr);
+		if ((unsigned long) addr < info->regstk.limit
+		    || (unsigned long) addr >=3D info->regstk.top)
+		{
+			dprintk("unwind: ignoring attempt to access register outside of rbs\n");
+			return -1;
+		}
+		if ((unsigned long) nat_addr >=3D info->regstk.top)
+			nat_addr =3D &info->sw->ar_rnat;
+		nat_mask =3D (1UL << ia64_rse_slot_num(addr));
 	}
-	rs =3D sr->stack;
-	sr->stack =3D rs->next;
-	free_reg_state(rs);
-}
=20
-static enum unw_register_index __attribute__((const))
-decode_abreg (unsigned char abreg, int memory)
-{
-	switch (abreg) {
-	      case 0x04 ... 0x07: return UNW_REG_R4 + (abreg - 0x04);
-	      case 0x22 ... 0x25: return UNW_REG_F2 + (abreg - 0x22);
-	      case 0x30 ... 0x3f: return UNW_REG_F16 + (abreg - 0x30);
-	      case 0x41 ... 0x45: return UNW_REG_B1 + (abreg - 0x41);
-	      case 0x60: return UNW_REG_PR;
-	      case 0x61: return UNW_REG_PSP;
-	      case 0x62: return memory ? UNW_REG_PRI_UNAT_MEM : UNW_REG_PRI_UNAT_=
GR;
-	      case 0x63: return UNW_REG_RP;
-	      case 0x64: return UNW_REG_BSP;
-	      case 0x65: return UNW_REG_BSPSTORE;
-	      case 0x66: return UNW_REG_RNAT;
-	      case 0x67: return UNW_REG_UNAT;
-	      case 0x68: return UNW_REG_FPSR;
-	      case 0x69: return UNW_REG_PFS;
-	      case 0x6a: return UNW_REG_LC;
-	      default:
-		break;
+	if (write) {
+		*addr =3D *val;
+		*nat_addr =3D (*nat_addr & ~nat_mask) | nat_mask;
+	} else {
+		*val =3D *addr;
+		*nat =3D (*nat_addr & nat_mask) !=3D 0;
 	}
-	dprintk("unwind: bad abreg=3D0x%x\n", abreg);
-	return UNW_REG_LC;
+	return 0;
 }
=20
-static void
-set_reg (struct unw_reg_info *reg, enum unw_where where, int when, unsigne=
d long val)
+int
+unw_access_br (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
 {
-	reg->val =3D val;
-	reg->where =3D where;
-	if (reg->when =3D UNW_WHEN_NEVER)
-		reg->when =3D when;
-}
+	unsigned long *addr;
+	struct pt_regs *pt;
=20
-static void
-alloc_spill_area (unsigned long *offp, unsigned long regsize,
-		  struct unw_reg_info *lo, struct unw_reg_info *hi)
-{
-	struct unw_reg_info *reg;
+	pt =3D (struct pt_regs *) info->sp - 1;
+	switch (regnum) {
+		/* scratch: */
+	      case 0: addr =3D &pt->b0; break;
+	      case 6: addr =3D &pt->b6; break;
+	      case 7: addr =3D &pt->b7; break;
=20
-	for (reg =3D hi; reg >=3D lo; --reg) {
-		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
-			reg->where =3D UNW_WHERE_PSPREL;
-			reg->val =3D *offp;
-			*offp +=3D regsize;
-		}
+		/* preserved: */
+	      case 1: case 2: case 3: case 4: case 5:
+		addr =3D *(&info->b1 + (regnum - 1));
+		break;
+
+	      default:
+		return -1;
 	}
+	if (write)
+		*addr =3D *val;
+	else
+		*val =3D *addr;
+	return 0;
 }
=20
-static void
-spill_next_when (struct unw_reg_info **regp, struct unw_reg_info *lim, unw=
_word t)
+int
+unw_access_fr (struct unw_frame_info *info, int regnum, struct ia64_fpreg =
*val, int write)
 {
-	struct unw_reg_info *reg;
+	struct ia64_fpreg *addr =3D 0;
+	struct pt_regs *pt;
=20
-	for (reg =3D *regp; reg <=3D lim; ++reg) {
-		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
-			reg->when =3D t;
-			*regp =3D reg + 1;
-			return;
-		}
+	if ((unsigned) (regnum - 2) >=3D 30)
+		return -1;
+
+	pt =3D (struct pt_regs *) info->sp - 1;
+
+	if (regnum <=3D 5) {
+		addr =3D *(&info->f2 + (regnum - 2));
+		if (!addr)
+			addr =3D &info->sw->f2 + (regnum - 2);
+	} else if (regnum <=3D 15) {
+		if (regnum <=3D 9)
+			addr =3D &pt->f6  + (regnum - 6);
+		else
+			addr =3D &info->sw->f10 + (regnum - 10);
+	} else if (regnum <=3D 31) {
+		addr =3D *(&info->fr[regnum - 16]);
+		if (!addr)
+			addr =3D &info->sw->f16 + (regnum - 16);
 	}
-	dprintk("unwind: excess spill!\n");
+
+	if (write)
+		*addr =3D *val;
+	else
+		*val =3D *addr;
+	return 0;
 }
=20
-static void
-finish_prologue (struct unw_state_record *sr)
+int
+unw_access_ar (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
 {
-	struct unw_reg_info *reg;
-	unsigned long off;
-	int i;
+	unsigned long *addr;
+	struct pt_regs *pt;
=20
-	/*
-	 * First, resolve implicit register save locations
-	 * (see Section "11.4.2.3 Rules for Using Unwind
-	 * Descriptors", rule 3):
-	 */
-	for (i =3D 0; i < (int) sizeof(save_order)/sizeof(save_order[0]); ++i) {
-		reg =3D sr->curr.reg + save_order[i];
-		if (reg->where =3D UNW_WHERE_GR_SAVE) {
-			reg->where =3D UNW_WHERE_GR;
-			reg->val =3D sr->gr_save_loc++;
-		}
-	}
+	pt =3D (struct pt_regs *) info->sp - 1;
=20
-	/*
-	 * Next, compute when the fp, general, and branch registers get
-	 * saved.  This must come before alloc_spill_area() because
+	switch (regnum) {
+	      case UNW_AR_BSP:
+		addr =3D info->pbsp;
+		if (!addr)
+			addr =3D &info->sw->ar_bspstore;
+		break;
+
+	      case UNW_AR_BSPSTORE:
+		addr =3D info->bspstore;
+		if (!addr)
+			addr =3D &info->sw->ar_bspstore;
+		break;
+
+	      case UNW_AR_PFS:
+		addr =3D info->pfs;
+		if (!addr)
+			addr =3D &info->sw->ar_pfs;
+		break;
+
+	      case UNW_AR_RNAT:
+		addr =3D info->rnat;
+		if (!addr)
+			addr =3D &info->sw->ar_rnat;
+		break;
+
+	      case UNW_AR_UNAT:
+		addr =3D info->unat;
+		if (!addr)
+			addr =3D &info->sw->ar_unat;
+		break;
+
+	      case UNW_AR_LC:
+		addr =3D info->lc;
+		if (!addr)
+			addr =3D &info->sw->ar_lc;
+		break;
+
+	      case UNW_AR_FPSR:
+		addr =3D info->fpsr;
+		if (!addr)
+			addr =3D &info->sw->ar_fpsr;
+		break;
+
+	      case UNW_AR_RSC:
+		addr =3D &pt->ar_rsc;
+		break;
+
+	      case UNW_AR_CCV:
+		addr =3D &pt->ar_ccv;
+		break;
+
+	      default:
+		return -1;
+	}
+
+	if (write)
+		*addr =3D *val;
+	else
+		*val =3D *addr;
+	return 0;
+}
+
+inline int
+unw_access_pr (struct unw_frame_info *info, unsigned long *val, int write)
+{
+	unsigned long *addr;
+
+	addr =3D info->pr;
+	if (!addr)
+		addr =3D &info->sw->pr;
+
+	if (write)
+		*addr =3D *val;
+	else
+		*val =3D *addr;
+	return 0;
+}
+
+=0C
+/* Unwind decoder routines */
+
+static inline void
+push (struct unw_state_record *sr)
+{
+	struct unw_reg_state *rs;
+
+	rs =3D alloc_reg_state();
+	memcpy(rs, &sr->curr, sizeof(*rs));
+	rs->next =3D sr->stack;
+	sr->stack =3D rs;
+}
+
+static void
+pop (struct unw_state_record *sr)
+{
+	struct unw_reg_state *rs;
+
+	if (!sr->stack) {
+		printk ("unwind: stack underflow!\n");
+		return;
+	}
+	rs =3D sr->stack;
+	sr->stack =3D rs->next;
+	free_reg_state(rs);
+}
+
+static enum unw_register_index __attribute__((const))
+decode_abreg (unsigned char abreg, int memory)
+{
+	switch (abreg) {
+	      case 0x04 ... 0x07: return UNW_REG_R4 + (abreg - 0x04);
+	      case 0x22 ... 0x25: return UNW_REG_F2 + (abreg - 0x22);
+	      case 0x30 ... 0x3f: return UNW_REG_F16 + (abreg - 0x30);
+	      case 0x41 ... 0x45: return UNW_REG_B1 + (abreg - 0x41);
+	      case 0x60: return UNW_REG_PR;
+	      case 0x61: return UNW_REG_PSP;
+	      case 0x62: return memory ? UNW_REG_PRI_UNAT_MEM : UNW_REG_PRI_UNAT_=
GR;
+	      case 0x63: return UNW_REG_RP;
+	      case 0x64: return UNW_REG_BSP;
+	      case 0x65: return UNW_REG_BSPSTORE;
+	      case 0x66: return UNW_REG_RNAT;
+	      case 0x67: return UNW_REG_UNAT;
+	      case 0x68: return UNW_REG_FPSR;
+	      case 0x69: return UNW_REG_PFS;
+	      case 0x6a: return UNW_REG_LC;
+	      default:
+		break;
+	}
+	dprintk("unwind: bad abreg=3D0x%x\n", abreg);
+	return UNW_REG_LC;
+}
+
+static void
+set_reg (struct unw_reg_info *reg, enum unw_where where, int when, unsigne=
d long val)
+{
+	reg->val =3D val;
+	reg->where =3D where;
+	if (reg->when =3D UNW_WHEN_NEVER)
+		reg->when =3D when;
+}
+
+static void
+alloc_spill_area (unsigned long *offp, unsigned long regsize,
+		  struct unw_reg_info *lo, struct unw_reg_info *hi)
+{
+	struct unw_reg_info *reg;
+
+	for (reg =3D hi; reg >=3D lo; --reg) {
+		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
+			reg->where =3D UNW_WHERE_PSPREL;
+			reg->val =3D *offp;
+			*offp +=3D regsize;
+		}
+	}
+}
+
+static inline void
+spill_next_when (struct unw_reg_info **regp, struct unw_reg_info *lim, unw=
_word t)
+{
+	struct unw_reg_info *reg;
+
+	for (reg =3D *regp; reg <=3D lim; ++reg) {
+		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
+			reg->when =3D t;
+			*regp =3D reg + 1;
+			return;
+		}
+	}
+	dprintk("unwind: excess spill!\n");
+}
+
+static inline void
+finish_prologue (struct unw_state_record *sr)
+{
+	struct unw_reg_info *reg;
+	unsigned long off;
+	int i;
+
+	/*
+	 * First, resolve implicit register save locations
+	 * (see Section "11.4.2.3 Rules for Using Unwind
+	 * Descriptors", rule 3):
+	 */
+	for (i =3D 0; i < (int) sizeof(unw.save_order)/sizeof(unw.save_order[0]);=
 ++i) {
+		reg =3D sr->curr.reg + unw.save_order[i];
+		if (reg->where =3D UNW_WHERE_GR_SAVE) {
+			reg->where =3D UNW_WHERE_GR;
+			reg->val =3D sr->gr_save_loc++;
+		}
+	}
+
+	/*
+	 * Next, compute when the fp, general, and branch registers get
+	 * saved.  This must come before alloc_spill_area() because
 	 * we need to know which registers are spilled to their home
 	 * locations.
 	 */
@@ -267,7 +593,7 @@
  * Region header descriptors.
  */
=20
-static inline void
+static void
 desc_prologue (int body, unw_word rlen, unsigned char mask, unsigned char =
grsave,
 	       struct unw_state_record *sr)
 {
@@ -298,7 +624,7 @@
 	if (!body) {
 		for (i =3D 0; i < 4; ++i) {
 			if (mask & 0x8)
-				set_reg(sr->curr.reg + save_order[i], UNW_WHERE_GR,
+				set_reg(sr->curr.reg + unw.save_order[i], UNW_WHERE_GR,
 					sr->region_start + sr->region_len - 1, grsave++);
 			mask <<=3D 1;
 		}
@@ -316,8 +642,10 @@
 static inline void
 desc_abi (unsigned char abi, unsigned char context, struct unw_state_recor=
d *sr)
 {
-	dprintk("unwind: ignoring unwabi(abi=3D0x%x,context=3D0x%x)\n", abi, cont=
ext);
-	sr->flags |=3D UNW_FLAG_INTERRUPT_FRAME;
+	if (abi =3D 0 && context =3D 'i')
+		sr->flags |=3D UNW_FLAG_INTERRUPT_FRAME;
+	else
+		dprintk("unwind: ignoring unwabi(abi=3D0x%x,context=3D0x%x)\n", abi, con=
text);
 }
=20
 static inline void
@@ -645,44 +973,126 @@
=20
 #include "unwind_decoder.c"
=20
-static struct unw_table_entry *
-lookup (struct unw_table *table, unsigned long rel_ip)
+=0C
+/* Unwind scripts. */
+
+static inline unw_hash_index_t
+hash (unsigned long ip)
 {
-	struct unw_table_entry *e =3D 0;
-	unsigned long lo, hi, mid;
+#	define magic	0x9e3779b97f4a7c16	/* (sqrt(5)/2-1)*2^64 */
=20
-	/* do a binary search for right entry: */
-	for (lo =3D 0, hi =3D table->length; lo < hi; ) {
-		mid =3D (lo + hi) / 2;
-		e =3D &table->array[mid];
-		if (rel_ip < e->start_offset)
-			hi =3D mid;
-		else if (rel_ip >=3D e->end_offset)
-			lo =3D mid + 1;
-		else
-			break;
-	}
-	return e;
+	return (ip >> 4)*magic >> (64 - UNW_LOG_HASH_SIZE);
 }
=20
-static struct unw_script *
-script_new (void)
+static inline long
+cache_match (struct unw_script *script, unsigned long ip, unsigned long pr=
_val)
 {
-	struct unw_script *script;
+	read_lock(&script->lock);
+	if ((ip) =3D (script)->ip && (((pr_val) ^ (script)->pr_val) & (script)->p=
r_mask) =3D 0)
+		/* keep the read lock... */
+		return 1;
+	read_unlock(&script->lock);
+	return 0;
+}
=20
-	script =3D kmalloc(sizeof(*script), GFP_ATOMIC);	/* XXX fix me */
-	memset(script, 0, sizeof(*script));
-	return script;
+static inline struct unw_script *
+script_lookup (struct unw_frame_info *info)
+{
+	struct unw_script *script =3D unw.cache + info->hint;
+	unsigned long ip, pr_val;
+
+	STAT(++unw.stat.cache.lookups);
+
+	ip =3D info->ip;
+	pr_val =3D info->pr_val;
+
+	if (cache_match(script, ip, pr_val)) {
+		STAT(++unw.stat.cache.hinted_hits);
+		return script;
+	}
+
+	script =3D unw.cache + unw.hash[hash(ip)];
+	while (1) {
+		if (cache_match(script, ip, pr_val)) {
+			/* update hint; no locking required as single-word writes are atomic */
+			STAT(++unw.stat.cache.normal_hits);
+			unw.cache[info->prev_script].hint =3D script - unw.cache;
+			return script;
+		}
+		if (script->coll_chain >=3D UNW_HASH_SIZE)
+			return 0;
+		script =3D unw.cache + script->coll_chain;
+		STAT(++unw.stat.cache.collision_chain_traversals);
+	}
 }
=20
-static void
-script_emit (struct unw_script *script, struct unw_insn insn)
+/*
+ * On returning, a write lock for the SCRIPT is still being held.
+ */
+static inline struct unw_script *
+script_new (unsigned long ip)
 {
-	if (script->count >=3D UNW_MAX_SCRIPT_LEN) {
-		dprintk("unwind: script exceeds maximum size of %u instructions!\n",
-			UNW_MAX_SCRIPT_LEN);
+	struct unw_script *script, *prev, *tmp;
+	unsigned short head;
+	unsigned long flags;
+	unsigned char index;
+
+	STAT(++unw.stat.script.news);
+
+	/*
+	 * Atomically fetch the least recently used script.  We can't
+	 * do this via unw.lock because we also need to acquire the
+	 * script's lock and to avoid deadlock, we must acquire the
+	 * latter before the former.
+	 */
+	do {
+		head =3D unw.lru_head;
+	} while (cmpxchg(&unw.lru_head, head, unw.cache[head].lru_chain) !=3D hea=
d);
+
+	script =3D unw.cache + head;
+
+	write_lock(&script->lock);
+
+	spin_lock_irqsave(&unw.lock, flags);
+	{
+		/* re-insert script at the tail of the LRU chain: */
+		unw.cache[unw.lru_tail].lru_chain =3D head;
+		unw.lru_tail =3D head;
+
+		/* remove the old script from the hash table (if it's there): */
+		index =3D hash(script->ip);
+		tmp =3D unw.cache + unw.hash[index];
+		prev =3D 0;
+		while (1) {
+			if (tmp =3D script) {
+				if (prev)
+					prev->coll_chain =3D tmp->coll_chain;
+				else
+					unw.hash[index] =3D tmp->coll_chain;
+				break;
+			} else
+				prev =3D tmp;
+			if (tmp->coll_chain >=3D UNW_CACHE_SIZE)
+				/* old script wasn't in the hash-table */
+				break;
+			tmp =3D unw.cache + tmp->coll_chain;
+		}
+
+		/* enter new script in the hash table */
+		index =3D hash(ip);
+		script->coll_chain =3D unw.hash[index];
+		unw.hash[index] =3D script - unw.cache;
+
+		script->ip =3D ip;	/* set new IP while we're holding the locks */
+
+		STAT(if (script->coll_chain < UNW_CACHE_SIZE) ++unw.stat.script.collisio=
ns);
 	}
-	script->insn[script->count++] =3D insn;
+	spin_unlock_irqrestore(&unw.lock, flags);
+
+	script->flags =3D 0;
+	script->hint =3D 0;
+	script->count =3D 0;
+	return script;
 }
=20
 static void
@@ -690,17 +1100,34 @@
 {
 	script->pr_mask =3D sr->pr_mask;
 	script->pr_val =3D sr->pr_val;
+	/*
+	 * We could down-grade our write-lock on script->lock here but
+	 * the rwlock API doesn't offer atomic lock downgrading, so
+	 * we'll just keep the write-lock and release it later when
+	 * we're done using the script.
+	 */
 }
=20
 static inline void
-emit_nat_info (struct unw_state_record *sr, int i, struct unw_script *scri=
pt)
+script_emit (struct unw_script *script, struct unw_insn insn)
 {
-	struct unw_reg_info *r =3D sr->curr.reg + i;
-	enum unw_insn_opcode opc;
-	struct unw_insn insn;
-	unsigned long val;
-
-	switch (r->where) {
+	if (script->count >=3D UNW_MAX_SCRIPT_LEN) {
+		dprintk("unwind: script exceeds maximum size of %u instructions!\n",
+			UNW_MAX_SCRIPT_LEN);
+		return;
+	}
+	script->insn[script->count++] =3D insn;
+}
+
+static inline void
+emit_nat_info (struct unw_state_record *sr, int i, struct unw_script *scri=
pt)
+{
+	struct unw_reg_info *r =3D sr->curr.reg + i;
+	enum unw_insn_opcode opc;
+	struct unw_insn insn;
+	unsigned long val;
+
+	switch (r->where) {
 	      case UNW_WHERE_GR:
 		if (r->val >=3D 32) {
 			/* register got spilled to a stacked register */
@@ -734,7 +1161,7 @@
 		return;
 	}
 	insn.opc =3D opc;
-	insn.dst =3D preg_index[i];
+	insn.dst =3D unw.preg_index[i];
 	insn.val =3D val;
 	script_emit(script, insn);
 }
@@ -765,10 +1192,10 @@
 				opc =3D UNW_INSN_MOVE2;
 				need_nat_info =3D 0;
 			}
-			val =3D preg_index[UNW_REG_R4 + (rval - 4)];
+			val =3D unw.preg_index[UNW_REG_R4 + (rval - 4)];
 		} else {
 			opc =3D UNW_INSN_LOAD_SPREL;
-			val =3D 0x10 - sizeof(struct pt_regs);=20
+			val =3D -sizeof(struct pt_regs);=20
 			if (rval >=3D 1 && rval <=3D 3)
 				val +=3D struct_offset(struct pt_regs, r1) + 8*(rval - 1);
 			else if (rval <=3D 11)
@@ -784,12 +1211,12 @@
=20
 	      case UNW_WHERE_FR:
 		if (rval <=3D 5)
-			val =3D preg_index[UNW_REG_F2  + (rval -  1)];
+			val =3D unw.preg_index[UNW_REG_F2  + (rval -  1)];
 		else if (rval >=3D 16 && rval <=3D 31)
-			val =3D preg_index[UNW_REG_F16 + (rval - 16)];
+			val =3D unw.preg_index[UNW_REG_F16 + (rval - 16)];
 		else {
 			opc =3D UNW_INSN_LOAD_SPREL;
-			val =3D 0x10 - sizeof(struct pt_regs);
+			val =3D -sizeof(struct pt_regs);
 			if (rval <=3D 9)
 				val +=3D struct_offset(struct pt_regs, f6) + 16*(rval - 6);
 			else
@@ -799,10 +1226,10 @@
=20
 	      case UNW_WHERE_BR:
 		if (rval >=3D 1 && rval <=3D 5)
-			val =3D preg_index[UNW_REG_B1 + (rval - 1)];
+			val =3D unw.preg_index[UNW_REG_B1 + (rval - 1)];
 		else {
 			opc =3D UNW_INSN_LOAD_SPREL;
-			val =3D 0x10 - sizeof(struct pt_regs);
+			val =3D -sizeof(struct pt_regs);
 			if (rval =3D 0)
 				val +=3D struct_offset(struct pt_regs, b0);
 			else if (rval =3D 6)
@@ -825,412 +1252,191 @@
 		break;
 	}
 	insn.opc =3D opc;
-	insn.dst =3D preg_index[i];
+	insn.dst =3D unw.preg_index[i];
 	insn.val =3D val;
 	script_emit(script, insn);
 	if (need_nat_info)
 		emit_nat_info(sr, i, script);
 }
=20
+static inline struct unw_table_entry *
+lookup (struct unw_table *table, unsigned long rel_ip)
+{
+	struct unw_table_entry *e =3D 0;
+	unsigned long lo, hi, mid;
+
+	/* do a binary search for right entry: */
+	for (lo =3D 0, hi =3D table->length; lo < hi; ) {
+		mid =3D (lo + hi) / 2;
+		e =3D &table->array[mid];
+		if (rel_ip < e->start_offset)
+			hi =3D mid;
+		else if (rel_ip >=3D e->end_offset)
+			lo =3D mid + 1;
+		else
+			break;
+	}
+	return e;
+}
+
 /*
  * Build an unwind script that unwinds from state OLD_STATE to the
  * entrypoint of the function that called OLD_STATE.
  */
-static struct unw_script *
+static inline struct unw_script *
 build_script (struct unw_frame_info *info)
 {
 	struct unw_reg_state *rs, *next;
 	struct unw_table_entry *e =3D 0;
 	struct unw_script *script =3D 0;
+	unsigned long ip =3D info->ip;
 	struct unw_state_record sr;
 	struct unw_table *table;
 	struct unw_reg_info *r;
 	struct unw_insn insn;
 	u8 *dp, *desc_end;
-	unsigned long ip;
 	u64 hdr;
 	int i;
+	STAT(unsigned long start, parse_start;)
+
+	STAT(++unw.stat.script.builds; start =3D ia64_get_itc());
=20
 	/* build state record */
 	memset(&sr, 0, sizeof(sr));
 	for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r)
 		r->when =3D UNW_WHEN_NEVER;
-	sr.pr_val =3D info->pr_val;
-
-	script =3D script_new ();
-	if (!script) {
-		dprintk("unwind: failed to create unwind script\n");
-		return 0;
-	}
-	ip =3D script->ip =3D info->ip;
-
-	/* search the kernels and the modules' unwind tables for IP: */
-
-	for (table =3D unw_tables; table; table =3D table->next) {
-		if (ip >=3D table->start && ip < table->end) {
-			e =3D lookup(table, ip - table->segment_base);
-			break;
-		}
-	}
-	if (!e) {
-		/* no info, return default unwinder (leaf proc, no mem stack, no saved r=
egs)  */
-		dprintk("unwind: no unwind info for ip=3D%lx\n", ip);
-		sr.curr.reg[UNW_REG_RP].where =3D UNW_WHERE_BR;
-		sr.curr.reg[UNW_REG_RP].when =3D -1;
-		sr.curr.reg[UNW_REG_RP].val =3D 0;
-		compile_reg(&sr, UNW_REG_RP, script);
-		script_finalize(script, &sr);
-		return script;
-	}
-
-	sr.when_target =3D (3*((ip & ~0xfUL) - (table->segment_base + e->start_of=
fset))
-			  + (ip & 0xfUL));
-	hdr =3D *(u64 *) (table->segment_base + e->info_offset);
-	dp =3D   (u8 *)  (table->segment_base + e->info_offset + 8);
-	desc_end =3D dp + 8*UNW_LENGTH(hdr);
-
-	while (!sr.done && dp < desc_end)
-		dp =3D unw_decode(dp, sr.in_body, &sr);
-
-	if (sr.when_target > sr.epilogue_start) {
-		/*
-		 * sp has been restored and all values on the memory stack below
-		 * psp also have been restored.
-		 */
-		sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE;
-		sr.curr.reg[UNW_REG_PSP].val =3D 0;
-		for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r)
-			if ((r->where =3D UNW_WHERE_PSPREL && r->val <=3D 0x10)
-			    || r->where =3D UNW_WHERE_SPREL)
-				r->where =3D UNW_WHERE_NONE;
-	}
-
-	script->flags =3D sr.flags;
-
-	/*
-	 * If RP did't get saved, generate entry for the return link
-	 * register.
-	 */
-	if (sr.curr.reg[UNW_REG_RP].when >=3D sr.when_target) {
-		sr.curr.reg[UNW_REG_RP].where =3D UNW_WHERE_BR;
-		sr.curr.reg[UNW_REG_RP].when =3D -1;
-		sr.curr.reg[UNW_REG_RP].val =3D sr.return_link_reg;
-	}
-
-#if UNW_DEBUG
-	printk ("unwind: state record for func 0x%lx, t=3D%u:\n",
-		table->segment_base + e->start_offset, sr.when_target);
-	for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
-		if (r->where !=3D UNW_WHERE_NONE || r->when !=3D UNW_WHEN_NEVER) {
-			printk("  %s <- ", preg_name[r - sr.curr.reg]);
-			switch (r->where) {
-			      case UNW_WHERE_GR:     printk("r%lu", r->val); break;
-			      case UNW_WHERE_FR:     printk("f%lu", r->val); break;
-			      case UNW_WHERE_BR:     printk("b%lu", r->val); break;
-			      case UNW_WHERE_SPREL:  printk("[sp+0x%lx]", r->val); break;
-			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", 0x10 - r->val); brea=
k;
-			      case UNW_WHERE_NONE:
-				printk("%s+0x%lx", preg_name[r - sr.curr.reg], r->val);
-				break;=20
-			      default:		     printk("BADWHERE(%d)", r->where); break;
-			}
-			printk ("\t\t%d\n", r->when);
-		}
-	}
-#endif
-
-	/* translate state record into unwinder instructions: */
-
-	if (sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE
-	    && sr.when_target > sr.curr.reg[UNW_REG_PSP].when && sr.curr.reg[UNW_=
REG_PSP].val !=3D 0)
-	{
-		/* new psp is sp plus frame size */
-		insn.opc =3D UNW_INSN_ADD;
-		insn.dst =3D preg_index[UNW_REG_PSP];
-		insn.val =3D sr.curr.reg[UNW_REG_PSP].val;
-		script_emit(script, insn);
-	}
-
-	/* determine where the primary UNaT is: */
-	if (sr.when_target < sr.curr.reg[UNW_REG_PRI_UNAT_GR].when)
-		i =3D UNW_REG_PRI_UNAT_MEM;
-	else if (sr.when_target < sr.curr.reg[UNW_REG_PRI_UNAT_MEM].when)
-		i =3D UNW_REG_PRI_UNAT_GR;
-	else if (sr.curr.reg[UNW_REG_PRI_UNAT_MEM].when > sr.curr.reg[UNW_REG_PRI=
_UNAT_GR].when)
-		i =3D UNW_REG_PRI_UNAT_MEM;
-	else
-		i =3D UNW_REG_PRI_UNAT_GR;
-
-	compile_reg(&sr, i, script);
-
-	for (i =3D UNW_REG_BSP; i < UNW_NUM_REGS; ++i)
-		compile_reg(&sr, i, script);
-
-	/* free labelled register states & stack: */
-
-	for (rs =3D sr.reg_state_list; rs; rs =3D next) {
-		next =3D rs->next;
-		free_reg_state(rs);
-	}
-	while (sr.stack)
-		pop(&sr);
-
-	script_finalize(script, &sr);
-	return script;
-}
-
-int
-unw_access_gr (struct unw_frame_info *info, int regnum, unsigned long *val=
, char *nat, int write)
-{
-	unsigned long *addr, *nat_addr, nat_mask =3D 0, dummy_nat;
-	struct unw_ireg *ireg;
-	struct pt_regs *pt;
-
-	if ((unsigned) regnum - 1 >=3D 127)
-		return -1;
-
-	if (regnum < 32) {
-		if (regnum >=3D 4 && regnum <=3D 7) {
-			/* access a preserved register */
-			ireg =3D &info->r4 + (regnum - 4);
-			addr =3D ireg->loc;
-			if (addr) {
-				nat_addr =3D addr + ireg->nat.off;
-				switch (ireg->nat.type) {
-				      case UNW_NAT_VAL:
-					/* simulate getf.sig/setf.sig */
-					if (write) {
-						if (*nat) {
-							/* write NaTVal and be done with it */
-							addr[0] =3D 0;
-							addr[1] =3D 0x1fffe;
-							return 0;
-						}
-						addr[1] =3D 0x1003e;
-					} else {
-						if (addr[0] =3D 0 && addr[1] =3D 0x1ffe) {
-							/* return NaT and be done with it */
-							*val =3D 0;
-							*nat =3D 1;
-							return 0;
-						}
-					}
-					/* fall through */
-				      case UNW_NAT_NONE:
-					nat_addr =3D &dummy_nat;
-					break;
-
-				      case UNW_NAT_SCRATCH:
-					if (info->unat)
-						nat_addr =3D info->unat;
-					else
-						nat_addr =3D &info->sw->caller_unat;
-				      case UNW_NAT_PRI_UNAT:
-					nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
-					break;
-
-				      case UNW_NAT_STACKED:
-					nat_addr =3D ia64_rse_rnat_addr(addr);
-					if ((unsigned long) addr < info->regstk.limit
-					    || (unsigned long) addr >=3D info->regstk.top)
-						return -1;
-					if ((unsigned long) nat_addr >=3D info->regstk.top)
-						nat_addr =3D &info->sw->ar_rnat;
-					nat_mask =3D (1UL << ia64_rse_slot_num(addr));
-					break;
-				}
-			} else {
-				addr =3D &info->sw->r4 + (regnum - 4);
-				nat_addr =3D &info->sw->ar_unat;
-				nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
-			}
-		} else {
-			/* access a scratch register */
-			pt =3D (struct pt_regs *) info->sp - 1;
-			if (regnum <=3D 3)
-				addr =3D &pt->r1 + (regnum - 1);
-			else if (regnum <=3D 11)
-				addr =3D &pt->r8 + (regnum - 8);
-			else if (regnum <=3D 15)
-				addr =3D &pt->r12 + (regnum - 12);
-			else
-				addr =3D &pt->r16 + (regnum - 16);
-			if (info->unat)
-				nat_addr =3D info->unat;
-			else
-				nat_addr =3D &info->sw->caller_unat;
-			nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
-		}
-	} else {
-		/* access a stacked register */
-		addr =3D ia64_rse_skip_regs((unsigned long *) info->bsp, regnum);
-		nat_addr =3D ia64_rse_rnat_addr(addr);
-		if ((unsigned long) addr < info->regstk.limit
-		    || (unsigned long) addr >=3D info->regstk.top)
-		{
-			dprintk("unwind: ignoring attempt to access register outside of rbs\n");
-			return -1;
-		}
-		if ((unsigned long) nat_addr >=3D info->regstk.top)
-			nat_addr =3D &info->sw->ar_rnat;
-		nat_mask =3D (1UL << ia64_rse_slot_num(addr));
-	}
-
-	if (write) {
-		*addr =3D *val;
-		*nat_addr =3D (*nat_addr & ~nat_mask) | nat_mask;
-	} else {
-		*val =3D *addr;
-		*nat =3D (*nat_addr & nat_mask) !=3D 0;
-	}
-	return 0;
-}
-
-int
-unw_access_br (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
-{
-	unsigned long *addr;
-	struct pt_regs *pt;
-
-	pt =3D (struct pt_regs *) info->sp - 1;
-	switch (regnum) {
-		/* scratch: */
-	      case 0: addr =3D &pt->b0; break;
-	      case 6: addr =3D &pt->b6; break;
-	      case 7: addr =3D &pt->b7; break;
-
-		/* preserved: */
-	      case 1: case 2: case 3: case 4: case 5:
-		addr =3D *(&info->b1 + (regnum - 1));
-		break;
-
-	      default:
-		return -1;
-	}
-	if (write)
-		*addr =3D *val;
-	else
-		*val =3D *addr;
-	return 0;
-}
-
-int
-unw_access_fr (struct unw_frame_info *info, int regnum, struct ia64_fpreg =
*val, int write)
-{
-	struct ia64_fpreg *addr =3D 0;
-	struct pt_regs *pt;
-
-	if ((unsigned) (regnum - 2) >=3D 30)
-		return -1;
-
-	pt =3D (struct pt_regs *) info->sp - 1;
+	sr.pr_val =3D info->pr_val;
=20
-	if (regnum <=3D 5) {
-		addr =3D *(&info->f2 + (regnum - 2));
-		if (!addr)
-			addr =3D &info->sw->f2 + (regnum - 2);
-	} else if (regnum <=3D 15) {
-		if (regnum <=3D 9)
-			addr =3D &pt->f6  + (regnum - 6);
-		else
-			addr =3D &info->sw->f10 + (regnum - 10);
-	} else if (regnum <=3D 31) {
-		addr =3D *(&info->fr[regnum - 16]);
-		if (!addr)
-			addr =3D &info->sw->f16 + (regnum - 16);
+	script =3D script_new(ip);
+	if (!script) {
+		dprintk("unwind: failed to create unwind script\n");
+		STAT(unw.stat.script.build_time +=3D ia64_get_itc() - start);
+		return 0;
 	}
+	unw.cache[info->prev_script].hint =3D script - unw.cache;
=20
-	if (write)
-		*addr =3D *val;
-	else
-		*val =3D *addr;
-	return 0;
-}
-
-int
-unw_access_ar (struct unw_frame_info *info, int regnum, unsigned long *val=
, int write)
-{
-	unsigned long *addr;
-	struct pt_regs *pt;
+	/* search the kernels and the modules' unwind tables for IP: */
=20
-	pt =3D (struct pt_regs *) info->sp - 1;
+	STAT(parse_start =3D ia64_get_itc());
=20
-	switch (regnum) {
-	      case UNW_AR_BSP:
-		addr =3D info->pbsp;
-		if (!addr)
-			addr =3D &info->sw->ar_bspstore;
-		break;
+	for (table =3D unw.tables; table; table =3D table->next) {
+		if (ip >=3D table->start && ip < table->end) {
+			e =3D lookup(table, ip - table->segment_base);
+			break;
+		}
+	}
+	if (!e) {
+		/* no info, return default unwinder (leaf proc, no mem stack, no saved r=
egs)  */
+		dprintk("unwind: no unwind info for ip=3D0x%lx\n", ip);
+		sr.curr.reg[UNW_REG_RP].where =3D UNW_WHERE_BR;
+		sr.curr.reg[UNW_REG_RP].when =3D -1;
+		sr.curr.reg[UNW_REG_RP].val =3D 0;
+		compile_reg(&sr, UNW_REG_RP, script);
+		script_finalize(script, &sr);
+		STAT(unw.stat.script.parse_time +=3D ia64_get_itc() - parse_start);
+		STAT(unw.stat.script.build_time +=3D ia64_get_itc() - start);
+		return script;
+	}
=20
-	      case UNW_AR_BSPSTORE:
-		addr =3D info->bspstore;
-		if (!addr)
-			addr =3D &info->sw->ar_bspstore;
-		break;
+	sr.when_target =3D (3*((ip & ~0xfUL) - (table->segment_base + e->start_of=
fset))
+			  + (ip & 0xfUL));
+	hdr =3D *(u64 *) (table->segment_base + e->info_offset);
+	dp =3D   (u8 *)  (table->segment_base + e->info_offset + 8);
+	desc_end =3D dp + 8*UNW_LENGTH(hdr);
=20
-	      case UNW_AR_PFS:
-		addr =3D info->pfs;
-		if (!addr)
-			addr =3D &info->sw->ar_pfs;
-		break;
+	while (!sr.done && dp < desc_end)
+		dp =3D unw_decode(dp, sr.in_body, &sr);
=20
-	      case UNW_AR_RNAT:
-		addr =3D info->rnat;
-		if (!addr)
-			addr =3D &info->sw->ar_rnat;
-		break;
+	if (sr.when_target > sr.epilogue_start) {
+		/*
+		 * sp has been restored and all values on the memory stack below
+		 * psp also have been restored.
+		 */
+		sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE;
+		sr.curr.reg[UNW_REG_PSP].val =3D 0;
+		for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r)
+			if ((r->where =3D UNW_WHERE_PSPREL && r->val <=3D 0x10)
+			    || r->where =3D UNW_WHERE_SPREL)
+				r->where =3D UNW_WHERE_NONE;
+	}
=20
-	      case UNW_AR_UNAT:
-		addr =3D info->unat;
-		if (!addr)
-			addr =3D &info->sw->ar_unat;
-		break;
+	script->flags =3D sr.flags;
=20
-	      case UNW_AR_LC:
-		addr =3D info->lc;
-		if (!addr)
-			addr =3D &info->sw->ar_lc;
-		break;
+	/*
+	 * If RP did't get saved, generate entry for the return link
+	 * register.
+	 */
+	if (sr.curr.reg[UNW_REG_RP].when >=3D sr.when_target) {
+		sr.curr.reg[UNW_REG_RP].where =3D UNW_WHERE_BR;
+		sr.curr.reg[UNW_REG_RP].when =3D -1;
+		sr.curr.reg[UNW_REG_RP].val =3D sr.return_link_reg;
+	}
=20
-	      case UNW_AR_FPSR:
-		addr =3D info->fpsr;
-		if (!addr)
-			addr =3D &info->sw->ar_fpsr;
-		break;
+#if UNW_DEBUG
+	printk ("unwind: state record for func 0x%lx, t=3D%u:\n",
+		table->segment_base + e->start_offset, sr.when_target);
+	for (r =3D sr.curr.reg; r < sr.curr.reg + UNW_NUM_REGS; ++r) {
+		if (r->where !=3D UNW_WHERE_NONE || r->when !=3D UNW_WHEN_NEVER) {
+			printk("  %s <- ", unw.preg_name[r - sr.curr.reg]);
+			switch (r->where) {
+			      case UNW_WHERE_GR:     printk("r%lu", r->val); break;
+			      case UNW_WHERE_FR:     printk("f%lu", r->val); break;
+			      case UNW_WHERE_BR:     printk("b%lu", r->val); break;
+			      case UNW_WHERE_SPREL:  printk("[sp+0x%lx]", r->val); break;
+			      case UNW_WHERE_PSPREL: printk("[psp+0x%lx]", 0x10 - r->val); brea=
k;
+			      case UNW_WHERE_NONE:
+				printk("%s+0x%lx", unw.preg_name[r - sr.curr.reg], r->val);
+				break;=20
+			      default:		     printk("BADWHERE(%d)", r->where); break;
+			}
+			printk ("\t\t%d\n", r->when);
+		}
+	}
+#endif
=20
-	      case UNW_AR_RSC:
-		addr =3D &pt->ar_rsc;
-		break;
+	STAT(unw.stat.script.parse_time +=3D ia64_get_itc() - parse_start);
=20
-	      case UNW_AR_CCV:
-		addr =3D &pt->ar_ccv;
-		break;
+	/* translate state record into unwinder instructions: */
=20
-	      default:
-		return -1;
+	if (sr.curr.reg[UNW_REG_PSP].where =3D UNW_WHERE_NONE
+	    && sr.when_target > sr.curr.reg[UNW_REG_PSP].when && sr.curr.reg[UNW_=
REG_PSP].val !=3D 0)
+	{
+		/* new psp is sp plus frame size */
+		insn.opc =3D UNW_INSN_ADD;
+		insn.dst =3D unw.preg_index[UNW_REG_PSP];
+		insn.val =3D sr.curr.reg[UNW_REG_PSP].val;
+		script_emit(script, insn);
 	}
=20
-	if (write)
-		*addr =3D *val;
+	/* determine where the primary UNaT is: */
+	if (sr.when_target < sr.curr.reg[UNW_REG_PRI_UNAT_GR].when)
+		i =3D UNW_REG_PRI_UNAT_MEM;
+	else if (sr.when_target < sr.curr.reg[UNW_REG_PRI_UNAT_MEM].when)
+		i =3D UNW_REG_PRI_UNAT_GR;
+	else if (sr.curr.reg[UNW_REG_PRI_UNAT_MEM].when > sr.curr.reg[UNW_REG_PRI=
_UNAT_GR].when)
+		i =3D UNW_REG_PRI_UNAT_MEM;
 	else
-		*val =3D *addr;
-	return 0;
-}
+		i =3D UNW_REG_PRI_UNAT_GR;
=20
-inline int
-unw_access_pr (struct unw_frame_info *info, unsigned long *val, int write)
-{
-	unsigned long *addr;
+	compile_reg(&sr, i, script);
=20
-	addr =3D info->pr;
-	if (!addr)
-		addr =3D &info->sw->pr;
+	for (i =3D UNW_REG_BSP; i < UNW_NUM_REGS; ++i)
+		compile_reg(&sr, i, script);
=20
-	if (write)
-		*addr =3D *val;
-	else
-		*val =3D *addr;
-	return 0;
+	/* free labelled register states & stack: */
+
+	STAT(parse_start =3D ia64_get_itc());
+	for (rs =3D sr.reg_state_list; rs; rs =3D next) {
+		next =3D rs->next;
+		free_reg_state(rs);
+	}
+	while (sr.stack)
+		pop(&sr);
+	STAT(unw.stat.script.parse_time +=3D ia64_get_itc() - parse_start);
+
+	script_finalize(script, &sr);
+	STAT(unw.stat.script.build_time +=3D ia64_get_itc() - start);
+	return script;
 }
=20
 /*
@@ -1238,13 +1444,15 @@
  * reflect the state that existed upon entry to the function that this
  * unwinder represents.
  */
-static void
+static inline void
 run_script (struct unw_script *script, struct unw_frame_info *state)
 {
 	struct unw_insn *ip, *limit, next_insn;
 	unsigned long opc, dst, val, off;
 	unsigned long *s =3D (unsigned long *) state;
+	STAT(unsigned long start;)
=20
+	STAT(++unw.stat.script.runs; start =3D ia64_get_itc());
 	state->flags =3D script->flags;
 	ip =3D script->insn;
 	limit =3D script->insn + script->count;
@@ -1299,10 +1507,11 @@
 			break;
 		}
 	}
+	STAT(unw.stat.script.run_time +=3D ia64_get_itc() - start);
 	return;
=20
   lazy_init:
-	off =3D sw_offset[val];
+	off =3D unw.sw_off[val];
 	s[val] =3D (unsigned long) state->sw + off;
 	if (off >=3D struct_offset (struct unw_frame_info, r4)
 	    && off <=3D struct_offset (struct unw_frame_info, r7))
@@ -1314,61 +1523,71 @@
 	goto redo;
 }
=20
-static void
+static int
 find_save_locs (struct unw_frame_info *info)
 {
-	static struct unw_script *script_cache;
+	int have_write_lock =3D 0;
 	struct unw_script *scr;
=20
-	/* XXX BIG FIXME---need hash table here... */
-	scr =3D script_cache;
-	if (scr) {
-		while (scr->ip !=3D info->ip || ((info->pr_val ^ scr->pr_val) & scr->pr_=
mask) !=3D 0) {
-			if (scr->hint =3D -1) {
-				scr =3D 0;
-				break;
-			}
-			scr =3D (struct unw_script *) ((int *) scr + scr->hint);
-		}
+	if (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)) {
+		/* don't let obviously bad addresses pollute the cache */
+		info->rp =3D 0;
+		return -1;
 	}
=20
+	scr =3D script_lookup(info);
 	if (!scr) {
 		scr =3D build_script(info);
-		if (scr) {
-			if (script_cache)
-				scr->hint =3D (int *) script_cache - (int *) scr;
-			else
-				scr->hint =3D -1;
-			script_cache =3D scr;
+		if (!scr) {
+			dprintk("unwind: failed to locate/build unwind script for ip %lx\n",
+				info->ip);
+			return -1;
 		}
+		have_write_lock =3D 1;
 	}
+	info->hint =3D scr->hint;
+	info->prev_script =3D scr - unw.cache;
=20
-	if (!scr) {
-		dprintk("unwind: failed to locate/build unwind script for ip %lx\n", inf=
o->ip);
-		return;
-	}
 	run_script(scr, info);
+
+	if (have_write_lock)
+		write_unlock(&scr->lock);
+	else
+		read_unlock(&scr->lock);
+	return 0;
 }
=20
 int
 unw_unwind (struct unw_frame_info *info)
 {
+	unsigned long prev_ip, prev_sp, prev_bsp;
 	unsigned long ip, pr, num_regs;
+	STAT(unsigned long start, flags;)
+	int retval;
 =09
+	STAT(local_irq_save(flags); ++unw.stat.api.unwinds; start =3D ia64_get_it=
c());
+
+	prev_ip =3D info->ip;
+	prev_sp =3D info->sp;
+	prev_bsp =3D info->bsp;
+
 	/* restore the ip */
 	if (!info->rp) {
-		dprintk("unwind: failed to locate return link!\n");
+		dprintk("unwind: failed to locate return link (ip=3D0x%lx)!\n", info->ip=
);
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
 	ip =3D info->ip =3D *info->rp;
 	if (ip <=3D TASK_SIZE) {
-		dprintk("unwind: reached user-space (ip=3D%lx)\n", ip);
+		dprintk("unwind: reached user-space (ip=3D0x%lx)\n", ip);
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
=20
 	/* restore the cfm: */
 	if (!info->pfs) {
 		dprintk("unwind: failed to locate ar.pfs!\n");
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
 	info->cfm =3D *info->pfs;
@@ -1387,6 +1606,7 @@
 	if (info->bsp < info->regstk.limit || info->bsp > info->regstk.top) {
 		dprintk("unwind: bsp (0x%lx) out of range [0x%lx-0x%lx]\n",
 			info->bsp, info->regstk.limit, info->regstk.top);
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
=20
@@ -1395,20 +1615,31 @@
 	if (info->sp < info->memstk.top || info->sp > info->memstk.limit) {
 		dprintk("unwind: sp (0x%lx) out of range [0x%lx-0x%lx]\n",
 			info->sp, info->regstk.top, info->regstk.limit);
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
+		return -1;
+	}
+
+	if (info->ip =3D prev_ip && info->sp =3D prev_sp && info->bsp =3D prev_bs=
p) {
+		dprintk("unwind: ip, sp, bsp remain unchanged; stopping here (ip=3D0x%lx=
)\n", ip);
+		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
 	}
=20
 	/* finally, restore the predicates: */
 	unw_get_pr(info, &info->pr_val);
=20
-	find_save_locs(info);
-	return 0;
+	retval =3D find_save_locs(info);
+	STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_rest=
ore(flags));
+	return retval;
 }
=20
 static void
 unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t, s=
truct switch_stack *sw)
 {
 	unsigned long rbslimit, rbstop, stklimit, stktop, sol;
+	STAT(unsigned long start, flags;)
+
+	STAT(local_irq_save(flags); ++unw.stat.api.inits; start =3D ia64_get_itc(=
));
=20
 	/*
 	 * Subtle stuff here: we _could_ unwind through the
@@ -1445,6 +1676,7 @@
 	info->pr_val =3D sw->pr;
=20
 	find_save_locs(info);
+	STAT(unw.stat.api.init_time +=3D ia64_get_itc() - start; local_irq_restor=
e(flags));
 }
=20
 #endif /* CONFIG_IA64_NEW_UNWIND */
@@ -1563,7 +1795,8 @@
 		return -1;
=20
 	info->ip =3D read_reg(info, sol - 2, &is_nat);
-	if (is_nat)
+	if (is_nat || (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)))
+		/* don't let obviously bad addresses pollute the cache */
 		return -1;
=20
 	cfm =3D read_reg(info, sol - 1, &is_nat);
@@ -1580,18 +1813,12 @@
=20
 #ifdef CONFIG_IA64_NEW_UNWIND
=20
-void *
-unw_add_unwind_table (const char *name, unsigned long segment_base, unsign=
ed long gp,
-		      void *table_start, void *table_end)
+static void
+init_unwind_table (struct unw_table *table, const char *name, unsigned lon=
g segment_base,
+		   unsigned long gp, void *table_start, void *table_end)
 {
-	struct unw_table *table;
 	struct unw_table_entry *start =3D table_start, *end =3D table_end;
=20
-	if (end - start <=3D 0) {
-		dprintk("unwind: ignoring attempt to insert empty unwind table\n");
-		return 0;
-	}
-
 #ifdef UNWIND_TABLE_SORT_BUG
 	{
 		struct unw_table_entry *e1, *e2, tmp;
@@ -1609,8 +1836,6 @@
 		}
 	}
 #endif
-
-	table =3D kmalloc(sizeof(*table), GFP_USER);
 	table->name =3D name;
 	table->segment_base =3D segment_base;
 	table->gp =3D gp;
@@ -1618,9 +1843,34 @@
 	table->end =3D segment_base + end[-1].end_offset;
 	table->array =3D start;
 	table->length =3D end - start;
+}
+
+void *
+unw_add_unwind_table (const char *name, unsigned long segment_base, unsign=
ed long gp,
+		      void *table_start, void *table_end)
+{
+	struct unw_table_entry *start =3D table_start, *end =3D table_end;
+	struct unw_table *table;
+	unsigned long flags;
+
+	if (end - start <=3D 0) {
+		dprintk("unwind: ignoring attempt to insert empty unwind table\n");
+		return 0;
+	}
+=09
+	table =3D kmalloc(sizeof(*table), GFP_USER);
+	if (!table)
+		return 0;
=20
-	table->next =3D unw_tables;
-	unw_tables =3D table;
+	init_unwind_table(table, name, segment_base, gp, table_start, table_end);
+
+	spin_lock_irqsave(&unw.lock, flags);
+	{
+		/* keep kernel unwind table at the front (it's searched most commonly): =
*/
+		table->next =3D unw.tables->next;
+		unw.tables->next =3D table;
+	}
+	spin_unlock_irqrestore(&unw.lock, flags);
=20
 	return table;
 }
@@ -1628,7 +1878,10 @@
 void
 unw_remove_unwind_table (void *handle)
 {
-	struct unw_table *table, *prev;
+	struct unw_table *table, *prevt;
+	struct unw_script *tmp, *prev;
+	unsigned long flags;
+	long index;
=20
 	if (!handle) {
 		dprintk("unwind: ignoring attempt to remove non-existent unwind table\n"=
);
@@ -1636,18 +1889,52 @@
 	}
=20
 	table =3D handle;
-	for (prev =3D (struct unw_table *) &unw_tables; prev; prev =3D prev->next)
-		if (prev->next =3D table)
-			break;
-	if (!prev) {
-		dprintk("unwind: failed to find unwind table %p\n", table);
+	if (table =3D &unw.kernel_table) {
+		dprintk("unwind: sorry, freeing the kernel's unwind table is a no-can-do=
!\n");
 		return;
 	}
-	prev->next =3D table->next;
-	kfree(table);
=20
-	/* XXX need to implement this... */
-	dprintk("unwind: don't forget to clear cache entries for this module!\n");
+	spin_lock_irqsave(&unw.lock, flags);
+	{
+		/* first, delete the table: */
+
+		for (prevt =3D (struct unw_table *) &unw.tables; prevt; prevt =3D prevt-=
>next)
+			if (prevt->next =3D table)
+				break;
+		if (!prevt) {
+			dprintk("unwind: failed to find unwind table %p\n", table);
+			spin_unlock_irqrestore(&unw.lock, flags);
+			return;
+		}
+		prevt->next =3D table->next;
+
+		/* next, remove hash table entries for this table */
+
+		for (index =3D 0; index <=3D UNW_HASH_SIZE; ++index) {
+			if (unw.hash[index] >=3D UNW_CACHE_SIZE)
+				continue;
+
+			tmp =3D unw.cache + unw.hash[index];
+			prev =3D 0;
+			while (1) {
+				write_lock(&tmp->lock);
+				{
+					if (tmp->ip >=3D table->start && tmp->ip < table->end) {
+						if (prev)
+							prev->coll_chain =3D tmp->coll_chain;
+						else
+							unw.hash[index] =3D -1;
+						tmp->ip =3D 0;
+					} else
+						prev =3D tmp;
+				}
+				write_unlock(&tmp->lock);
+			}
+		}
+	}
+	spin_unlock_irqrestore(&unw.lock, flags);
+
+	kfree(table);
 }
 #endif /* CONFIG_IA64_NEW_UNWIND */
=20
@@ -1656,27 +1943,39 @@
 {
 #ifdef CONFIG_IA64_NEW_UNWIND
 	extern int ia64_unw_start, ia64_unw_end, __gp;
+	extern void unw_hash_index_t_is_too_narrow (void);
 	long i, off;
-#	define SW(f)	struct_offset(struct switch_stack, f)
=20
-	sw_offset[preg_index[UNW_REG_PRI_UNAT_GR]] =3D SW(ar_unat);
-	sw_offset[preg_index[UNW_REG_BSPSTORE]] =3D SW(ar_bspstore);
-	sw_offset[preg_index[UNW_REG_PFS]] =3D SW(ar_unat);
-	sw_offset[preg_index[UNW_REG_RP]] =3D SW(b0);
-	sw_offset[preg_index[UNW_REG_UNAT]] =3D SW(ar_unat);
-	sw_offset[preg_index[UNW_REG_PR]] =3D SW(pr);
-	sw_offset[preg_index[UNW_REG_LC]] =3D SW(ar_lc);
-	sw_offset[preg_index[UNW_REG_FPSR]] =3D SW(ar_fpsr);
-	for (i =3D UNW_REG_R4, off =3D SW(r4); i <=3D UNW_REG_R7; ++i, off +=3D 8)
-		sw_offset[preg_index[i]] =3D off;
-	for (i =3D UNW_REG_B1, off =3D SW(b1); i <=3D UNW_REG_B5; ++i, off +=3D 8)
-		sw_offset[preg_index[i]] =3D off;
-	for (i =3D UNW_REG_F2, off =3D SW(f2); i <=3D UNW_REG_F5; ++i, off +=3D 1=
6)
-		sw_offset[preg_index[i]] =3D off;
-	for (i =3D UNW_REG_F16, off =3D SW(f16); i <=3D UNW_REG_F31; ++i, off +=
=3D 16)
-		sw_offset[preg_index[i]] =3D off;
+	if (8*sizeof (unw_hash_index_t) < UNW_LOG_HASH_SIZE)
+		unw_hash_index_t_is_too_narrow();
+
+	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] =3D SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_BSPSTORE]] =3D SW(AR_BSPSTORE);
+	unw.sw_off[unw.preg_index[UNW_REG_PFS]] =3D SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_RP]] =3D SW(B0);
+	unw.sw_off[unw.preg_index[UNW_REG_UNAT]] =3D SW(AR_UNAT);
+	unw.sw_off[unw.preg_index[UNW_REG_PR]] =3D SW(PR);
+	unw.sw_off[unw.preg_index[UNW_REG_LC]] =3D SW(AR_LC);
+	unw.sw_off[unw.preg_index[UNW_REG_FPSR]] =3D SW(AR_FPSR);
+	for (i =3D UNW_REG_R4, off =3D SW(R4); i <=3D UNW_REG_R7; ++i, off +=3D 8)
+		unw.sw_off[unw.preg_index[i]] =3D off;
+	for (i =3D UNW_REG_B1, off =3D SW(B1); i <=3D UNW_REG_B5; ++i, off +=3D 8)
+		unw.sw_off[unw.preg_index[i]] =3D off;
+	for (i =3D UNW_REG_F2, off =3D SW(F2); i <=3D UNW_REG_F5; ++i, off +=3D 1=
6)
+		unw.sw_off[unw.preg_index[i]] =3D off;
+	for (i =3D UNW_REG_F16, off =3D SW(F16); i <=3D UNW_REG_F31; ++i, off +=
=3D 16)
+		unw.sw_off[unw.preg_index[i]] =3D off;
+
+	unw.cache[0].coll_chain =3D -1;
+	for (i =3D 1; i < UNW_CACHE_SIZE; ++i) {
+		unw.cache[i].lru_chain =3D (i - 1);
+		unw.cache[i].coll_chain =3D -1;
+		unw.cache[i].lock =3D RW_LOCK_UNLOCKED;
+	}
+	unw.lru_head =3D UNW_CACHE_SIZE - 1;
+	unw.lru_tail =3D 0;
=20
-	unw_add_unwind_table("kernel", KERNEL_START, (unsigned long) &__gp,
-			     &ia64_unw_start, &ia64_unw_end);
+	init_unwind_table(&unw.kernel_table, "kernel", KERNEL_START, (unsigned lo=
ng) &__gp,
+			  &ia64_unw_start, &ia64_unw_end);
 #endif /* CONFIG_IA64_NEW_UNWIND */
 }
diff -urN linux-davidm/arch/ia64/kernel/unwind_i.h linux-2.4.0-test1-lia/ar=
ch/ia64/kernel/unwind_i.h
--- linux-davidm/arch/ia64/kernel/unwind_i.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unwind_i.h	Thu Jun  1 01:08:05 2=
000
@@ -138,14 +138,23 @@
 	signed int val		: 19;
 };
=20
-#define UNW_MAX_SCRIPT_LEN	(2*UNW_NUM_REGS)
+/*
+ * Preserved general static registers (r2-r5) give rise to two script
+ * instructions; everything else yields at most one instruction; at
+ * the end of the script, the psp gets popped, accounting for one more
+ * instruction.
+ */
+#define UNW_MAX_SCRIPT_LEN	(UNW_NUM_REGS + 5)
=20
 struct unw_script {
 	unsigned long ip;		/* ip this script is for */
 	unsigned long pr_mask;		/* mask of predicates script depends on */
 	unsigned long pr_val;		/* predicate values this script is for */
-	unsigned long flags;		/* see UNW_FLAG_* in unwind.h */
-	unsigned int count;		/* number of instructions in script */
-	int hint;			/* hint for next script to try */
+	rwlock_t lock;
+	unsigned int flags;		/* see UNW_FLAG_* in unwind.h */
+	unsigned short lru_chain;	/* used for least-recently-used chain */
+	unsigned short coll_chain;	/* used for hash collisions */
+	unsigned short hint;		/* hint for next script to try (or -1) */
+	unsigned short count;		/* number of instructions in script */
 	struct unw_insn insn[UNW_MAX_SCRIPT_LEN];
 };
diff -urN linux-davidm/arch/ia64/mm/fault.c linux-2.4.0-test1-lia/arch/ia64=
/mm/fault.c
--- linux-davidm/arch/ia64/mm/fault.c	Mon Apr 24 15:52:23 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/fault.c	Thu Jun  1 01:09:50 2000
@@ -1,8 +1,8 @@
 /*
  * MMU fault handling support.
  *
- * Copyright (C) 1998, 1999 Hewlett-Packard Co
- * Copyright (C) 1998, 1999 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 1998-2000 Hewlett-Packard Co
+ * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 #include <linux/sched.h>
 #include <linux/kernel.h>
@@ -94,7 +94,14 @@
 	 * sure we exit gracefully rather than endlessly redo the
 	 * fault.
 	 */
-	if (!handle_mm_fault(mm, vma, address, (isr & IA64_ISR_W) !=3D 0)) {
+	switch (handle_mm_fault(mm, vma, address, (mask & VM_WRITE) !=3D 0)) {
+	      case 1:
+		++current->min_flt;
+		break;
+	      case 2:
+		++current->maj_flt;
+		break;
+	      case 0:
 		/*
 		 * We ran out of memory, or some other thing happened
 		 * to us that made us unable to handle the page fault
@@ -102,6 +109,8 @@
 		 */
 		signal =3D SIGBUS;
 		goto bad_area;
+	      default:
+		goto out_of_memory;
 	}
 	up(&mm->mmap_sem);
 	return;
@@ -128,15 +137,11 @@
 		return;
 	}
 	if (user_mode(regs)) {
-#if 0
-printk("%s(%d): segfault accessing %lx\n", current->comm, current->pid, ad=
dress);
-show_regs(regs);
-#endif
 		si.si_signo =3D signal;
 		si.si_errno =3D 0;
 		si.si_code =3D SI_KERNEL;
 		si.si_addr =3D (void *) address;
-		force_sig_info(SIGSEGV, &si, current);
+		force_sig_info(signal, &si, current);
 		return;
 	}
=20
@@ -161,4 +166,11 @@
 	die_if_kernel("Oops", regs, isr);
 	do_exit(SIGKILL);
 	return;
+
+  out_of_memory:
+	up(&mm->mmap_sem);
+	printk("VM: killing process %s\n", current->comm);
+	if (user_mode(regs))
+		do_exit(SIGKILL);
+	goto no_context;
 }
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test1-lia/arch/ia64/=
mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/init.c	Thu Jun  1 01:10:02 2000
@@ -14,6 +14,7 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
=20
+#include <asm/bitops.h>
 #include <asm/dma.h>
 #include <asm/efi.h>
 #include <asm/ia32.h>
@@ -265,7 +266,7 @@
 void __init
 ia64_rid_init (void)
 {
-	unsigned long flags, rid, pta;
+	unsigned long flags, rid, pta, impl_va_msb;
=20
 	/* Set up the kernel identity mappings (regions 6 & 7) and the vmalloc ar=
ea (region 5): */
 	ia64_clear_ic(flags);
@@ -300,11 +301,15 @@
 #	define ld_max_addr_space_size	(ld_max_addr_space_pages + PAGE_SHIFT)
 #	define ld_max_vpt_size		(ld_max_addr_space_pages + ld_pte_size)
 #	define POW2(n)			(1ULL << (n))
-#	define IMPL_VA_MSB		50
-	if (POW2(ld_max_addr_space_size - 1) + POW2(ld_max_vpt_size) > POW2(IMPL_=
VA_MSB))
+	impl_va_msb =3D ffz(~my_cpu_data.unimpl_va_mask) - 1;
+
+	if (impl_va_msb < 50 || impl_va_msb > 60)
+		panic("Bogus impl_va_msb value of %lu!\n", impl_va_msb);
+
+	if (POW2(ld_max_addr_space_size - 1) + POW2(ld_max_vpt_size) > POW2(impl_=
va_msb))
 		panic("mm/init: overlap between virtually mapped linear page table and "
 		      "mapped kernel space!");
-	pta =3D POW2(61) - POW2(IMPL_VA_MSB);
+	pta =3D POW2(61) - POW2(impl_va_msb);
 	/*
 	 * Set the (virtually mapped linear) page table address.  Bit
 	 * 8 selects between the short and long format, bits 2-7 the
@@ -324,9 +329,6 @@
=20
 	clear_page((void *) ZERO_PAGE_ADDR);
=20
-	ia64_rid_init();
-	__flush_tlb_all();
-
 	/* initialize mem_map[] */
=20
 	memset(zones_size, 0, sizeof(zones_size));
@@ -378,8 +380,6 @@
=20
 	max_mapnr =3D max_low_pfn;
 	high_memory =3D __va(max_low_pfn * PAGE_SIZE);
-
-	ia64_tlb_init();
=20
 	totalram_pages +=3D free_all_bootmem();
=20
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.0-test1-lia/arch/ia64/m=
m/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/tlb.c	Thu Jun  1 01:10:24 2000
@@ -53,10 +53,11 @@
  * flush_tlb_no_ptcg is called with ptcg_lock locked
  */
 static inline void
-flush_tlb_no_ptcg (__u64 start, __u64 end, __u64 nbits)
+flush_tlb_no_ptcg (unsigned long start, unsigned long end, unsigned long n=
bits)
 {
-	__u64 flags;
-	__u64 saved_tpr;
+	extern void smp_send_flush_tlb (void);
+	unsigned long saved_tpr =3D 0;
+	unsigned long flags;
=20
 	/*
 	 * Some times this is called with interrupts disabled and causes
@@ -83,10 +84,12 @@
 	 * Purge local TLB entries. ALAT invalidation is done in ia64_leave_kerne=
l.
 	 */
 	do {
-		__asm__ __volatile__ ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memo=
ry");
+		asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");
 		start +=3D (1UL << nbits);
 	} while (start < end);
=20
+	ia64_srlz_i();			/* srlz.i implies srlz.d */
+
 	/*
 	 * Wait for other CPUs to finish purging entries.
 	 */
@@ -157,7 +160,7 @@
 	stride0 =3D ia64_ptce_info.stride[0];
 	stride1 =3D ia64_ptce_info.stride[1];
=20
-	__save_and_cli(flags);
+	local_irq_save(flags);
 	for (i =3D 0; i < count0; ++i) {
 		for (j =3D 0; j < count1; ++j) {
 			asm volatile ("ptc.e %0" :: "r"(addr));
@@ -165,7 +168,7 @@
 		}
 		addr +=3D stride0;
 	}
-	__restore_flags(flags);
+	local_irq_restore(flags);
 	ia64_insn_group_barrier();
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 	ia64_insn_group_barrier();
@@ -211,21 +214,20 @@
 		/*
 		 * Flush ALAT entries also.
 		 */
-		__asm__ __volatile__ ("ptc.ga %0,%1;;srlz.i;;"
-				      :: "r"(start), "r"(nbits<<2) : "memory");
+		asm volatile ("ptc.ga %0,%1;;srlz.i;;" :: "r"(start), "r"(nbits<<2) : "m=
emory");
 # else
-		__asm__ __volatile__ ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memo=
ry");
+		asm volatile ("ptc.l %0,%1" :: "r"(start), "r"(nbits<<2) : "memory");
 # endif
 		start +=3D (1UL << nbits);
 	} while (start < end);
-#endif /* CONFIG_SMP && !defined(CONFIG_ITANIUM_PTCG)
+#endif /* CONFIG_SMP && !defined(CONFIG_ITANIUM_PTCG) */
 	spin_unlock(&ptcg_lock);
 	ia64_insn_group_barrier();
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 	ia64_insn_group_barrier();
 }
=20
-void
+void __init
 ia64_tlb_init (void)
 {
 	ia64_get_ptce(&ia64_ptce_info);
diff -urN linux-davidm/drivers/ide/piix.c linux-2.4.0-test1-lia/drivers/ide=
/piix.c
--- linux-davidm/drivers/ide/piix.c	Thu Jun  1 01:20:27 2000
+++ linux-2.4.0-test1-lia/drivers/ide/piix.c	Thu Jun  1 01:11:08 2000
@@ -423,7 +423,7 @@
=20
 void __init ide_init_piix (ide_hwif_t *hwif)
 {
-#if 0
+#ifndef CONFIG_IA64
 	/* autoprobe instead... --davidm 00/04/20 */
 	if (!hwif->irq)
 		hwif->irq =3D hwif->channel ? 15 : 14;
diff -urN linux-davidm/drivers/scsi/simscsi.c linux-2.4.0-test1-lia/drivers=
/scsi/simscsi.c
--- linux-davidm/drivers/scsi/simscsi.c	Thu May 25 23:22:10 2000
+++ linux-2.4.0-test1-lia/drivers/scsi/simscsi.c	Thu Jun  1 01:11:28 2000
@@ -85,17 +85,22 @@
 static void
 simscsi_interrupt (unsigned long val)
 {
+	unsigned long flags;
 	Scsi_Cmnd *sc;
=20
-	while ((sc =3D queue[rd].sc) !=3D 0) {
-		atomic_dec(&num_reqs);
-		queue[rd].sc =3D 0;
+	spin_lock_irqsave(&io_request_lock, flags);
+	{
+		while ((sc =3D queue[rd].sc) !=3D 0) {
+			atomic_dec(&num_reqs);
+			queue[rd].sc =3D 0;
 #if DEBUG_SIMSCSI
-		printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
+			printk("simscsi_interrupt: done with %ld\n", sc->serial_number);
 #endif
-		(*sc->scsi_done)(sc);
-		rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
+			(*sc->scsi_done)(sc);
+			rd =3D (rd + 1) % SIMSCSI_REQ_QUEUE_LEN;
+		}
 	}
+	spin_unlock_irqrestore(&io_request_lock, flags);
 }
=20
 int
diff -urN linux-davidm/drivers/sound/emu10k1/main.c linux-2.4.0-test1-lia/d=
rivers/sound/emu10k1/main.c
--- linux-davidm/drivers/sound/emu10k1/main.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/drivers/sound/emu10k1/main.c	Thu Jun  1 01:12:11 =
2000
@@ -532,7 +532,7 @@
 	return CTSTATUS_SUCCESS;
 }
=20
-static void audio_exit(struct emu10k1_card *card)
+static void __devexit audio_exit(struct emu10k1_card *card)
 {
 	kfree(card->waveout);
 	kfree(card->wavein);
@@ -550,7 +550,7 @@
 	return;
 }
=20
-static void emu10k1_exit(struct emu10k1_card *card)
+static void __devexit emu10k1_exit(struct emu10k1_card *card)
 {
 	int ch;
=20
diff -urN linux-davidm/fs/binfmt_elf.c linux-2.4.0-test1-lia/fs/binfmt_elf.c
--- linux-davidm/fs/binfmt_elf.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/fs/binfmt_elf.c	Thu Jun  1 01:12:21 2000
@@ -288,12 +288,14 @@
 	    } else
 		    map_addr =3D -EINVAL;
 #else /* !CONFIG_BINFMT_ELF32 */
+	    down(&current->mm->mmap_sem);
 	    map_addr =3D do_mmap(interpreter,
 			    load_addr + ELF_PAGESTART(vaddr),
 			    eppnt->p_filesz + ELF_PAGEOFFSET(eppnt->p_vaddr),
 			    elf_prot,
 			    elf_type,
 			    eppnt->p_offset - ELF_PAGEOFFSET(eppnt->p_vaddr));
+	    up(&current->mm->mmap_sem);
 #endif /* !CONFIG_BINFMT_ELF32 */
=20
 	    if (!load_addr_set && interp_elf_ex->e_type =3D ET_DYN) {
@@ -663,11 +665,13 @@
 		} else
 			error =3D EINVAL;
 #else /* CONFIG_BINFMT_ELF32 */
+		down(&current->mm->mmap_sem);
 		error =3D do_mmap(bprm->file, ELF_PAGESTART(load_bias + vaddr),
 		                (elf_ppnt->p_filesz +
 		                ELF_PAGEOFFSET(elf_ppnt->p_vaddr)),
 		                elf_prot, elf_flags, (elf_ppnt->p_offset -
 		                ELF_PAGEOFFSET(elf_ppnt->p_vaddr)));
+		up(&current->mm->mmap_sem);
 #endif /* CONFIG_BINFMT_ELF32 */
=20
 		if (!load_addr_set) {
diff -urN linux-davidm/fs/lockd/xdr.c linux-2.4.0-test1-lia/fs/lockd/xdr.c
--- linux-davidm/fs/lockd/xdr.c	Sun Apr  2 15:31:32 2000
+++ linux-2.4.0-test1-lia/fs/lockd/xdr.c	Thu Jun  1 01:12:30 2000
@@ -86,7 +86,7 @@
=20
 	if ((len =3D ntohl(*p++)) !=3D NFS2_FHSIZE) {
 		printk(KERN_NOTICE
-			"lockd: bad fhandle size %x (should be %Zu)\n",
+			"lockd: bad fhandle size %x (should be %u)\n",
 			len, NFS2_FHSIZE);
 		return NULL;
 	}
diff -urN linux-davidm/fs/nfsd/nfscache.c linux-2.4.0-test1-lia/fs/nfsd/nfs=
cache.c
--- linux-davidm/fs/nfsd/nfscache.c	Thu Jun  1 01:20:28 2000
+++ linux-2.4.0-test1-lia/fs/nfsd/nfscache.c	Thu Jun  1 01:12:41 2000
@@ -60,7 +60,7 @@
 	nfscache =3D (struct svc_cacherep *)
 		__get_free_pages(GFP_KERNEL, order);
 	if (!nfscache) {
-		printk (KERN_ERR "nfsd: cannot allocate %d bytes for reply cache\n", i);
+		printk (KERN_ERR "nfsd: cannot allocate %Zu bytes for reply cache\n", i);
 		return;
 	}
 	memset(nfscache, 0, i);
@@ -70,7 +70,7 @@
 	if (!hash_list) {
 		free_pages ((unsigned long)nfscache, order);
 		nfscache =3D NULL;
-		printk (KERN_ERR "nfsd: cannot allocate %d bytes for hash list\n", i);
+		printk (KERN_ERR "nfsd: cannot allocate %Zu bytes for hash list\n", i);
 		return;
 	}
=20
diff -urN linux-davidm/fs/readdir.c linux-2.4.0-test1-lia/fs/readdir.c
--- linux-davidm/fs/readdir.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/fs/readdir.c	Thu Jun  1 01:30:33 2000
@@ -79,10 +79,6 @@
 	return 0;
 }
=20
-#define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
-#define ROUND_UP(x) (((x)+sizeof(long)-1) & ~(sizeof(long)-1))
-
-#if !defined(__ia64__)
 /*
  * Traditional linux readdir() handling..
  *
@@ -91,6 +87,10 @@
  * anyway. Thus the special "fillonedir()" function for that
  * case (the low-level handlers don't need to care about this).
  */
+#define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
+#define ROUND_UP(x) (((x)+sizeof(long)-1) & ~(sizeof(long)-1))
+
+#ifndef __ia64__
=20
 struct old_linux_dirent {
 	unsigned long	d_ino;
@@ -146,7 +146,7 @@
 	return error;
 }
=20
-#endif /* !defined(__ia64__) */
+#endif /* !__ia64__ */
=20
 /*
  * New, all-improved, singing, dancing, iBCS2-compliant getdents()
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.0-test1-lia/include=
/asm-ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/pal.h	Thu Jun  1 01:13:03 2000
@@ -4,11 +4,12 @@
 /*
  * Processor Abstraction Layer definitions.
  *
- * This is based on version 2.4 of the manual "Enhanced Mode Processor
- * Abstraction Layer".
+ * This is based on Intel IA-64 Architecture Software Developer's Manual r=
ev 1.0
+ * chapter 11 IA-64 Processor Abstraction Layer
  *
  * Copyright (C) 1998-2000 Hewlett-Packard Co
  * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
+ * Copyright (C) 2000 Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 1999 VA Linux Systems
  * Copyright (C) 1999 Walt Drummond <drummond@valinux.com>
  * Copyright (C) 1999 Srinivasa Prasad Thirumalachar <sprasad@sprasad.engr=
.sgi.com>
@@ -16,6 +17,8 @@
  * 99/10/01	davidm	Make sure we pass zero for reserved parameters.
  * 00/03/07	davidm	Updated pal_cache_flush() to be in sync with PAL v2.6.
  * 00/03/23     cfleck  Modified processor min-state save area to match up=
dated PAL & SAL info
+ * 00/05/24     eranian Updated to latest PAL spec, fix structures bugs, a=
dded=20
+ * 00/05/25	eranian Support for stack calls, and statis physical calls
  */
=20
 /*
@@ -127,8 +130,8 @@
 typedef	union  pal_cache_config_info_1_s {
 	struct {
 		u64		u		: 1,	/* 0 Unified cache ? */
-				reserved	: 5,	/* 7-3 Reserved */
 				at		: 2,	/* 2-1 Cache mem attr*/
+				reserved	: 5,	/* 7-3 Reserved */
 				associativity	: 8,	/* 16-8 Associativity*/
 				line_size	: 8,	/* 23-17 Line size */
 				stride		: 8,	/* 31-24 Stride */
@@ -164,8 +167,8 @@
 	u64				pcci_reserved;
 } pal_cache_config_info_t;
=20
-#define pcci_ld_hint		pcci_info_1.pcci1.load_hints
-#define pcci_st_hint		pcci_info_1.pcci1_bits.store_hints
+#define pcci_ld_hints		pcci_info_1.pcci1_bits.load_hints
+#define pcci_st_hints		pcci_info_1.pcci1_bits.store_hints
 #define pcci_ld_latency		pcci_info_1.pcci1_bits.load_latency
 #define pcci_st_latency		pcci_info_1.pcci1_bits.store_latency
 #define pcci_stride		pcci_info_1.pcci1_bits.stride
@@ -641,8 +644,12 @@
  * parameters.
  */
 extern struct ia64_pal_retval ia64_pal_call_static (u64, u64, u64, u64);=20
+extern struct ia64_pal_retval ia64_pal_call_stacked (u64, u64, u64, u64); =

+extern struct ia64_pal_retval ia64_pal_call_phys_static (u64, u64, u64, u6=
4);=20
=20
-#define PAL_CALL(iprv,a0,a1,a2,a3)	iprv =3D ia64_pal_call_static(a0,a1, a2=
, a3)
+#define PAL_CALL(iprv,a0,a1,a2,a3)	iprv =3D ia64_pal_call_static(a0, a1, a=
2, a3)
+#define PAL_CALL_STK(iprv,a0,a1,a2,a3)	iprv =3D ia64_pal_call_stacked(a0, =
a1, a2, a3)
+#define PAL_CALL_PHYS(iprv,a0,a1,a2,a3) iprv =3D ia64_pal_call_phys_static=
(a0, a1, a2, a3)
=20
 typedef int (*ia64_pal_handler) (u64, ...);
 extern ia64_pal_handler ia64_pal;
@@ -702,7 +709,7 @@
 			   pal_bus_features_u_t *features_control)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_BUS_GET_FEATURES, 0, 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_BUS_GET_FEATURES, 0, 0, 0);
 	if (features_avail)
 		features_avail->pal_bus_features_val =3D iprv.v0;
 	if (features_status)
@@ -711,15 +718,54 @@
 		features_control->pal_bus_features_val =3D iprv.v2;
 	return iprv.status;=09
 }
+
 /* Enables/disables specific processor bus features */
 extern inline s64=20
 ia64_pal_bus_set_features (pal_bus_features_u_t feature_select)=20
 {=09
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_BUS_SET_FEATURES, feature_select.pal_bus_features_val,=
 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_BUS_SET_FEATURES, feature_select.pal_bus_features=
_val, 0, 0);
 	return iprv.status;
 }
=20
+/* Get detailed cache information */
+extern inline s64
+ia64_pal_cache_config_info (u64 cache_level, u64 cache_type, pal_cache_con=
fig_info_t *conf)
+{
+	struct ia64_pal_retval iprv;
+
+	PAL_CALL(iprv, PAL_CACHE_INFO, cache_level, cache_type, 0);=20
+
+	if (iprv.status =3D 0) {
+		conf->pcci_status                 =3D iprv.status;
+		conf->pcci_info_1.pcci1_data      =3D iprv.v0;
+		conf->pcci_info_2.pcci2_data      =3D iprv.v1;
+		conf->pcci_reserved               =3D iprv.v2;
+	}
+	return iprv.status;=20
+
+}
+
+/* Get detailed cche protection information */
+extern inline s64
+ia64_pal_cache_prot_info (u64 cache_level, u64 cache_type, pal_cache_prote=
ction_info_t *prot)
+{
+	struct ia64_pal_retval iprv;
+
+	PAL_CALL(iprv, PAL_CACHE_PROT_INFO, cache_level, cache_type, 0);=20
+
+	if (iprv.status =3D 0) {
+		prot->pcpi_status           =3D iprv.status;
+		prot->pcp_info[0].pcpi_data =3D iprv.v0 & 0xffffffff;
+		prot->pcp_info[1].pcpi_data =3D iprv.v0 >> 32;
+		prot->pcp_info[2].pcpi_data =3D iprv.v1 & 0xffffffff;
+		prot->pcp_info[3].pcpi_data =3D iprv.v1 >> 32;
+		prot->pcp_info[4].pcpi_data =3D iprv.v2 & 0xffffffff;
+		prot->pcp_info[5].pcpi_data =3D iprv.v2 >> 32;
+	}
+	return iprv.status;=20
+}
+=20
 /*
  * Flush the processor instruction or data caches.  *PROGRESS must be
  * initialized to zero before calling this for the first time..
@@ -895,7 +941,10 @@
 	struct {
 	       u64		exit_latency		: 16,
 				entry_latency		: 16,
-				power_consumption	: 32;
+				power_consumption	: 28,
+				im			: 1,
+				co			: 1,
+				reserved		: 2;
 	} pal_power_mgmt_info_s;
 } pal_power_mgmt_info_u_t;
=20
@@ -904,7 +953,7 @@
 ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf)=20
 {=09
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_HALT_INFO, (unsigned long) power_buf, 0, 0);
+	PAL_CALL_STK(iprv, PAL_HALT_INFO, (unsigned long) power_buf, 0, 0);
 	return iprv.status;=20
 }
=20
@@ -1013,7 +1062,7 @@
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_MEM_ATTRIB, 0, 0, 0);
 	if (mem_attrib)
-		*mem_attrib =3D iprv.v0;
+		*mem_attrib =3D iprv.v0 & 0xff;
 	return iprv.status;=20
 }
=20
@@ -1076,28 +1125,32 @@
 	return iprv.status;=20
 }
=20
-#ifdef TBD
 struct pal_features_s;
 /* Provide information about configurable processor features */
 extern inline s64=20
-ia64_pal_proc_get_features (struct pal_features_s *features_avail,=20
-			    struct pal_features_s *features_status,=20
-			    struct pal_features_s *features_control)
+ia64_pal_proc_get_features (u64 *features_avail,=20
+			    u64 *features_status,=20
+			    u64 *features_control)
 {=09
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_PROC_GET_FEATURES, 0, 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, 0, 0);
+	if (iprv.status =3D 0) {
+		*features_avail   =3D iprv.v0;
+		*features_status  =3D iprv.v1;
+		*features_control =3D iprv.v2;
+	}
 	return iprv.status;=20
 }
+
 /* Enable/disable processor dependent features */
 extern inline s64=20
-ia64_pal_proc_set_features (feature_select)=20
+ia64_pal_proc_set_features (u64 feature_select)=20
 {=09
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_PROC_SET_FEATURES, feature_select, 0, 0);
+	PAL_CALL_PHYS(iprv, PAL_PROC_SET_FEATURES, feature_select, 0, 0);
 	return iprv.status;=20
 }
=20
-#endif=20
 /*
  * Put everything in a struct so we avoid the global offset table whenever
  * possible.
@@ -1206,12 +1259,16 @@
=20
 /* Return PAL version information */
 extern inline s64=20
-ia64_pal_version (pal_version_u_t *pal_version)=20
+ia64_pal_version (pal_version_u_t *pal_min_version, pal_version_u_t *pal_c=
ur_version)=20
 {=09
 	struct ia64_pal_retval iprv;
 	PAL_CALL(iprv, PAL_VERSION, 0, 0, 0);
-	if (pal_version)
-		pal_version->pal_version_val =3D iprv.v0;
+	if (pal_min_version)
+		pal_min_version->pal_version_val =3D iprv.v0;
+
+	if (pal_cur_version)
+		pal_cur_version->pal_version_val =3D iprv.v1;
+
 	return iprv.status;=20
 }
=20
@@ -1228,7 +1285,14 @@
 	} pal_tc_info_s;
 } pal_tc_info_u_t;			=09
 			=09
-	      =20
+#define tc_reduce_tr		pal_tc_info_s.reduce_tr
+#define tc_unified		pal_tc_info_s.unified
+#define tc_pf			pal_tc_info_s.pf
+#define tc_num_entries		pal_tc_info_s.num_entries
+#define tc_associativity	pal_tc_info_s.associativity
+#define tc_num_sets		pal_tc_info_s.num_sets
+
+
 /* Return information about the virtual memory characteristics of the proc=
essor=20
  * implementation.
  */
@@ -1264,7 +1328,7 @@
 	struct {
 		u64		vw		: 1,
 				phys_add_size	: 7,
-				key_size	: 16,
+				key_size	: 8,
 				max_pkr		: 8,
 				hash_tag_id	: 8,
 				max_dtr_entry	: 8,
diff -urN linux-davidm/include/asm-ia64/pgtable.h linux-2.4.0-test1-lia/inc=
lude/asm-ia64/pgtable.h
--- linux-davidm/include/asm-ia64/pgtable.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/pgtable.h	Thu Jun  1 01:14:01 20=
00
@@ -16,23 +16,16 @@
=20
 #include <asm/mman.h>
 #include <asm/page.h>
+#include <asm/processor.h>
 #include <asm/types.h>
=20
-/* Size of virtuaql and physical address spaces: */
-#ifdef CONFIG_ITANIUM
-# define IA64_IMPL_VA_MSB	50
-# define IA64_PHYS_BITS		44		/* Itanium PRM defines 44 bits of ppn */
-#else
-# define IA64_IMPL_VA_MSB	60		/* maximum value (bits 61-63 are region bits=
) */
-# define IA64_PHYS_BITS		50		/* EAS2.6 allows up to 50 bits of ppn */
-#endif
-#define IA64_PHYS_SIZE		(__IA64_UL(1) << IA64_PHYS_BITS)
+#define IA64_MAX_PHYS_BITS	50	/* max. number of physical address bits (arc=
hitected) */
=20
 /* Is ADDR a valid kernel address? */
 #define kern_addr_valid(addr)	((addr) >=3D TASK_SIZE)
=20
 /* Is ADDR a valid physical address? */
-#define phys_addr_valid(addr)	((addr) < IA64_PHYS_SIZE)
+#define phys_addr_valid(addr)	(((addr) & my_cpu_data.unimpl_pa_mask) =3D 0)
=20
 /*
  * First, define the various bits in a PTE.  Note that the PTE format
@@ -63,7 +56,7 @@
 #define _PAGE_AR_SHIFT		9
 #define _PAGE_A			(1 <<  5)	/* page accessed bit */
 #define _PAGE_D			(1 <<  6)	/* page dirty bit */
-#define _PAGE_PPN_MASK		((IA64_PHYS_SIZE - 1) & ~0xfffUL)
+#define _PAGE_PPN_MASK		(((__IA64_UL(1) << IA64_MAX_PHYS_BITS) - 1) & ~0xf=
ffUL)
 #define _PAGE_ED		(__IA64_UL(1) << 52)	/* exception deferral */
 #define _PAGE_PROTNONE		(__IA64_UL(1) << 63)
=20
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test1-lia/i=
nclude/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/processor.h	Thu Jun  1 01:14:12 =
2000
@@ -237,6 +237,8 @@
 	__u64 proc_freq;	/* frequency of processor */
 	__u64 cyc_per_usec;	/* itc_freq/1000000 */
 	__u64 usec_per_cyc;	/* 2^IA64_USEC_PER_CYC_SHIFT*1000000/itc_freq */
+	__u64 unimpl_va_mask;	/* mask of unimplemented virtual address bits (from=
 PAL) */
+	__u64 unimpl_pa_mask;	/* mask of unimplemented physical address bits (fro=
m PAL) */
 #ifdef CONFIG_SMP
 	__u64 loops_per_sec;
 	__u64 ipi_count;
diff -urN linux-davidm/include/asm-ia64/string.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/string.h
--- linux-davidm/include/asm-ia64/string.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/string.h	Thu Jun  1 01:14:24 2000
@@ -12,4 +12,7 @@
 #define __HAVE_ARCH_STRLEN	1 /* see arch/ia64/lib/strlen.S */
 #define __HAVE_ARCH_MEMSET	1 /* see arch/ia64/lib/memset.S */
=20
+extern __kernel_size_t strlen (const char *);
+extern void *memset (void *,int,__kernel_size_t);
+
 #endif /* _ASM_IA64_STRING_H */
diff -urN linux-davidm/include/asm-ia64/system.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/system.h
--- linux-davidm/include/asm-ia64/system.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/system.h	Thu Jun  1 01:14:34 2000
@@ -135,7 +135,7 @@
 do {									 \
 	unsigned long ip, old_psr, psr =3D (x);				 \
 									 \
-	__asm__ __volatile__ ("mov %0=3Dpsr; mov psr.l=3D%1;; srlz.d"	 \
+	__asm__ __volatile__ (";;mov %0=3Dpsr; mov psr.l=3D%1;; srlz.d"	 \
 			      : "=3D&r" (old_psr) : "r" (psr) : "memory"); \
 	if ((old_psr & (1UL << 14)) && !(psr & (1UL << 14))) {		 \
 		__asm__ ("mov %0=3Dip" : "=3Dr"(ip));			 \
@@ -149,7 +149,7 @@
 						      : "=3Dr" (x) :: "memory")
 # define local_irq_disable()	__asm__ __volatile__ (";; rsm psr.i;;" ::: "m=
emory")
 /* (potentially) setting psr.i requires data serialization: */
-# define local_irq_restore(x)	__asm__ __volatile__ ("mov psr.l=3D%0;; srlz=
.d"		\
+# define local_irq_restore(x)	__asm__ __volatile__ (";; mov psr.l=3D%0;; s=
rlz.d"	\
 						      :: "r" (x) : "memory")
 #endif /* !CONFIG_IA64_DEBUG_IRQ */
=20
diff -urN linux-davidm/include/asm-ia64/unwind.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/unwind.h	Thu Jun  1 01:14:42 2000
@@ -48,7 +48,9 @@
 struct unw_frame_info {
 	struct unw_stack regstk;
 	struct unw_stack memstk;
-	unsigned long flags;
+	unsigned int flags;
+	short hint;
+	short prev_script;
 	unsigned long bsp;
 	unsigned long sp;		/* stack pointer */
 	unsigned long psp;		/* previous sp */
diff -urN linux-davidm/init/main.c linux-2.4.0-test1-lia/init/main.c
--- linux-davidm/init/main.c	Thu Jun  1 01:38:40 2000
+++ linux-2.4.0-test1-lia/init/main.c	Thu Jun  1 01:15:49 2000
@@ -572,7 +572,6 @@
 #endif
 	mem_init();
 	kmem_cache_sizes_init();
-	unw_init();		/* XXX remove reliance on kmalloc and move to setup_arch() */
 #ifdef CONFIG_PERFMON
 	perfmon_init();
 #endif


