From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 26 May 2000 07:49:50 +0000
Subject: [Linux-ia64] [PATCH] kernel updated (relative to 2.3.99pre6)
Message-Id: <marc-linux-ia64-105590678205108@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Attached below is the long overdue kernel update.  The diff below is
relative to the previous IA-64 kernel.  A full diff relative to
Linus's 2.3.99pre6 is at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64/

in file "linux-2.3.99-pre6-ia64-000525.diff.gz".  Note: this kernel
hasn't been tested in a lot of configurations so I'd not recommend to
use it in a distribution (not without further testing at least).  In
particular, I haven't had time to test SMP.  UP works fine on Big Sur
and the HP simulator.  The reason I'm making the patch available now
is that we need to sync up with Linus's tree so if this patch happens
not to work on some systems, not much is lost as I plan to put out a
patch soon that brings us to 2.4-test1.

An updated kdb patch is available at:

 ftp://ftp.hpl.hp.com/pub/linux-ia64/kdb-2.3.99-pre6-000525.diff.gz

The kdb patch is known not to work with SMP (it crashes in the boot
with a "CPU already initialized" error; looks like it's a stupid
problem, but I haven't had time to fix it; if someone could make this
work again, it would be great).

Summary of changes:

 o The big change this time is lots of new code to support full stack
   unwinding.  This is fairly intricate stuff and the code is not 100%
   complete yet.  For example, more debugging needs to be done, the
   memory/cache management is stupid, and SMP locking is
   missing. Having said that, I'm quite happy with how things are
   shaping up so far.  It looks like we should be able to unwind both
   reliably and efficiently.  the "backtrace" command in kdb works
   better than it ever did and there is complete support for all
   unwind directives (modulo bugs that is... ;-).  The new unwind
   support is enabled only if CONFIG_IA64_NEW_UNWIND is turned on.  Do
   NOT turn this on right now unless you have a toolchain that has all
   the unwind fixes applied (goes for gcc and gas).  Without those
   fixes, the unwind info will be incorrect and things won't work
   properly.

   As a consequence of this, I added unwind directives for all
   assembly files (I think I missed mca_asm.S though).  Please be sure
   to keep this info in sync with the assembly code.  For a
   description of the unwind directives, see the Assembly Reference
   Guide (available at http://developer.intel.com/design/ia64)

 o Workaround for the global tlb flush hw erratum  (Asit).

 o Kernel module support (Stephen Zeisset).

 o SIGFPE now passes ISR in the si_isr field of siginfo to permit
   user-level fp emulation/testing etc. (Goutham).

 o Fixes to the emu10k1 sound driver (Bill, I think).

 o New kernel option: if you have a CPU that has an A2 or later
   stepping, you can turn off CONFIG_ITANIUM_A1_SPECIFIC and enjoy
   reduced interrupt latency etc.

 o Increased number of PCI busses to scan to 255 (the fix necessary to
   make this work come from Asit).

 o Changes required for the AzusA platform (kouchi).  Please note that
   I did not include the azusa_vectors table nor did I change the
   isa_irq_to_vector_map.  For the former, please hack (or better
   still: fix) the bootloader.  For the latter, I think we need a
   better solution.  Either we can find an ISA vector map that will
   work on all platforms or, if that's not possible, we'll need to
   assign the ISA vectors dynamically.  Anyone want to take a stab at
   a clean solution for this?

 o Timer-management related updated by Walt.  I chose to use a different
   approach to handling "race conditions" with the itm.  Basically, the
   new code turns off interrupts while checking if the itc is past
   the itm and additionally allows for a slack of 1000 cycles.  Haven't
   done much experimenting with it, but I do think this should be the
   good way to reduce the number of spurious lost tick messages.

 o IA-32 updates by Don and myself.  Don, note that the IA-32
   state-switching is now in ia32_support.c.  I rearranged that code a
   little.  I think it should be much faster now, but I haven't
   measured it.

 o New header file <asm/asmmacro.h> defines a couple of convenience
   macros to assist in assembly programming.

 o Remove support for old compilers that didn't know how to return
   things in r9, r10, and r11.

 o ptrace updates in preparation for the new unwind code.  Kevin, note
   that PT_PRI_UNAT now exists but it does NOT yet return the correct
   NaT bits.  This will be one of the next things I'll work on.

 o Fix execve() code so that running gdb on vmlinux and typing "run"
   no longer freezes the system.  ;-)

That should be it.  Please give it a spin and let me know how it
works.

If someone is looking for a small but potentially interesting project:
in the SMP case, we currently do not implement a fine-grained
gettimeofday().  This is easy to do if you're willing to do an IPI to
the bootstrap processor on every gettimeofday(), but it seems to me we
should be able to do better than that (a lot better, actually).  Would
be great if someone could come up with a great way of solving this
issue (to get started, take a look at
arch/ia64/kernel/time.c:gettimeoffset()).

Enjoy,

	--david

diff -urN linux-davidm/arch/ia64/Makefile linux-2.3.99-pre6-lia/arch/ia64/M=
akefile
--- linux-davidm/arch/ia64/Makefile	Thu May 25 23:22:10 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/Makefile	Thu May 25 22:52:30 2000
@@ -12,16 +12,11 @@
 AWK :=3D awk
=20
 LINKFLAGS =3D -static -T arch/$(ARCH)/vmlinux.lds
-# next line is for HP compiler backend:
-#AFLAGS +=3D -DGCC_RETVAL_POINTER_IN_R8
-# The next line is needed when compiling with the July snapshot of the Cyg=
nus compiler:
-#EXTRA	=3D -D__GCC_DOESNT_KNOW_IN_REGS__
-# next two lines are for the September snapshot of the Cygnus compiler:
-AFLAGS +=3D -D__GCC_MULTIREG_RETVALS__ -Wa,-x
-EXTRA	=3D -D__GCC_MULTIREG_RETVALS__
+AFLAGS +=3D -Wa,-x
+EXTRA	=20
-#CFLAGS :=3D $(CFLAGS) -pipe -mconstant-gp $(EXTRA) -Wa,-x -ffixed-r13 -mf=
ixed-range=F10-f15,f32-f127
-CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127
+CFLAGS :=3D $(CFLAGS) -pipe $(EXTRA) -Wa,-x -ffixed-r13 -mfixed-range=F10-=
f15,f32-f127 \
+	  -mconstant-gp -funwind-tables
=20
 ifdef CONFIG_IA64_GENERIC
 	CORE_FILES      :=3D      arch/$(ARCH)/hp/hp.a	\
diff -urN linux-davidm/arch/ia64/boot/Makefile linux-2.3.99-pre6-lia/arch/i=
a64/boot/Makefile
--- linux-davidm/arch/ia64/boot/Makefile	Thu Mar 30 16:56:04 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/boot/Makefile	Thu May 25 22:53:10 2000
@@ -25,7 +25,8 @@
 all:	$(TARGETS)
=20
 bootloader: $(OBJECTS)
-	$(LD) $(LINKFLAGS) $(OBJECTS) $(LIBS) -o bootloader
+	$(LD) $(LINKFLAGS) $(OBJECTS) $(TOPDIR)/lib/lib.a $(TOPDIR)/arch/$(ARCH)/=
lib/lib.a \
+	-o bootloader
=20
 clean:
 	rm -f $(TARGETS)
diff -urN linux-davidm/arch/ia64/config.in linux-2.3.99-pre6-lia/arch/ia64/=
config.in
--- linux-davidm/arch/ia64/config.in	Thu May 25 23:22:10 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/config.in	Thu May 25 22:54:04 2000
@@ -24,9 +24,9 @@
 if [ "$CONFIG_IA64_DIG" =3D "y" ]; then
 	bool '  Enable Itanium A-step specific code' CONFIG_ITANIUM_ASTEP_SPECIFIC
 	bool '  Enable Itanium A1-step specific code' CONFIG_ITANIUM_A1_SPECIFIC
+	bool '  Enable use of global TLB purge instruction (ptc.g)' CONFIG_ITANIU=
M_PTCG
 	bool '  Enable SoftSDV hacks' CONFIG_IA64_SOFTSDV_HACKS
-	bool '  Enable BigSur hacks' CONFIG_IA64_BIGSUR_HACKS
-	bool '  Enable Lion hacks' CONFIG_IA64_LION_HACKS
+	bool '  Enable AzusA hacks' CONFIG_IA64_AZUSA_HACKS
 	bool '  Emulate PAL/SAL/EFI firmware' CONFIG_IA64_FW_EMU
 	bool '  Enable IA64 Machine Check Abort' CONFIG_IA64_MCA
 fi
@@ -188,5 +188,6 @@
 bool 'Turn on compare-and-exchange bug checking (slow!)' CONFIG_IA64_DEBUG=
_CMPXCHG
 bool 'Turn on irq debug checks (slow!)' CONFIG_IA64_DEBUG_IRQ
 bool 'Print possible IA64 hazards to console' CONFIG_IA64_PRINT_HAZARDS
+bool 'Enable new unwind support' CONFIG_IA64_NEW_UNWIND
=20
 endmenu
diff -urN linux-davidm/arch/ia64/dig/iosapic.c linux-2.3.99-pre6-lia/arch/i=
a64/dig/iosapic.c
--- linux-davidm/arch/ia64/dig/iosapic.c	Thu May 25 23:22:10 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/dig/iosapic.c	Thu May 25 22:54:40 2000
@@ -67,6 +67,12 @@
 		 (delivery << IO_SAPIC_DELIVERY_SHIFT) |
 		 vector);
=20
+#ifdef CONFIG_IA64_AZUSA_HACKS
+	/* set Flush Disable bit */
+	if (iosapic_addr !=3D 0xc0000000fec00000)
+		low32 |=3D (1 << 17);
+#endif
+
 	/* dest contains both id and eid */
 	high32 =3D (dest << IO_SAPIC_DEST_SHIFT);=09
=20
@@ -216,29 +222,31 @@
 }
=20
 void
-iosapic_init (unsigned long address)
+iosapic_init (unsigned long address, int irqbase)
 {
 	struct hw_interrupt_type *irq_type;
 	struct pci_vector_struct *vectors;
 	int i, irq;
=20
-	/*=20
-	 * Map the legacy ISA devices into the IOSAPIC data.  Some of
-	 * these may get reprogrammed later on with data from the ACPI
-	 * Interrupt Source Override table.
-	 */
-	for (i =3D 0; i < 16; i++) {
-		irq =3D isa_irq_to_vector(i);
-		iosapic_pin(irq) =3D i;=20
-		iosapic_bus(irq) =3D BUS_ISA;
-		iosapic_busdata(irq) =3D 0;
-		iosapic_dmode(irq) =3D IO_SAPIC_LOWEST_PRIORITY;
-		iosapic_trigger(irq)  =3D IO_SAPIC_EDGE;
-		iosapic_polarity(irq) =3D IO_SAPIC_POL_HIGH;
+	if (irqbase =3D 0)
+		/*=20
+		 * Map the legacy ISA devices into the IOSAPIC data.
+		 * Some of these may get reprogrammed later on with
+		 * data from the ACPI Interrupt Source Override table.
+		 */
+		for (i =3D 0; i < 16; i++) {
+			irq =3D isa_irq_to_vector(i);
+			iosapic_pin(irq) =3D i;=20
+			iosapic_bus(irq) =3D BUS_ISA;
+			iosapic_busdata(irq) =3D 0;
+			iosapic_dmode(irq) =3D IO_SAPIC_LOWEST_PRIORITY;
+			iosapic_trigger(irq)  =3D IO_SAPIC_EDGE;
+			iosapic_polarity(irq) =3D IO_SAPIC_POL_HIGH;
 #ifdef DEBUG_IRQ_ROUTING
-		printk("ISA: IRQ %02x -> Vector %02x IOSAPIC Pin %d\n", i, irq, iosapic_=
pin(irq));
+			printk("ISA: IRQ %02x -> Vector %02x IOSAPIC Pin %d\n",
+			       i, irq, iosapic_pin(irq));
 #endif
-	}
+		}
=20
 #ifndef CONFIG_IA64_SOFTSDV_HACKS
 	/*=20
@@ -251,6 +259,8 @@
 		irq =3D vectors[i].irq;
 		if (irq < 16)
 			irq =3D isa_irq_to_vector(irq);
+		if (iosapic_baseirq(irq) !=3D irqbase)
+			continue;
=20
 		iosapic_bustype(irq) =3D BUS_PCI;
 		iosapic_pin(irq) =3D irq - iosapic_baseirq(irq);
@@ -274,6 +284,9 @@
 #endif /* CONFIG_IA64_SOFTSDV_HACKS */
=20
 	for (i =3D 0; i < NR_IRQS; ++i) {
+		if (iosapic_baseirq(i) !=3D irqbase)
+			continue;
+
 		if (iosapic_pin(i) !=3D -1) {
 			if (iosapic_trigger(i) =3D IO_SAPIC_LEVEL)
 			  irq_type =3D &irq_type_iosapic_level;
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.3.99-pre6-lia/ar=
ch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Fri Apr 21 15:21:23 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/ia32/ia32_entry.S	Thu May 25 22:55:27 2=
000
@@ -1,14 +1,15 @@
+#include <asm/asmmacro.h>
 #include <asm/offsets.h>
 #include <asm/signal.h>
=20
+#include "../kernel/entry.h"
+
 	//
 	// Get possibly unaligned sigmask argument into an aligned
 	//   kernel buffer
 	.text
-	.proc ia32_rt_sigsuspend
-	.global ia32_rt_sigsuspend
-ia32_rt_sigsuspend:
=20
+GLOBAL_ENTRY(ia32_rt_sigsuspend)
 	// We'll cheat and not do an alloc here since we are ultimately
 	// going to do a simple branch to the IA64 sys_rt_sigsuspend.
 	// r32 is still the first argument which is the signal mask.
@@ -32,24 +33,22 @@
 	st4 [r32]=3Dr2
 	st4 [r10]=3Dr3
 	br.cond.sptk.many sys_rt_sigsuspend
+END(ia32_rt_sigsuspend)
=20
 	.section __ex_table,"a"
 	data4 @gprel(1b)
 	data4 (2b-1b)|1
 	.previous
=20
+GLOBAL_ENTRY(ia32_ret_from_syscall)
+	PT_REGS_UNWIND_INFO
=20
-	.endp ia32_rt_sigsuspend
-
-	.global ia32_ret_from_syscall
-	.proc ia32_ret_from_syscall
-ia32_ret_from_syscall:
 	cmp.ge p6,p7=3Dr8,r0                      // syscall executed successfull=
y?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp    // r2 =3D &pt_regs.r8
 	;;=20
 	st8 [r2]=3Dr8                             // store return value in slot f=
or r8
 	br.cond.sptk.few ia64_leave_kernel
-	.endp ia32_ret_from_syscall
+END(ia32_ret_from_syscall)
=20
 	//
 	// Invoke a system call, but do some tracing before and after the call.
@@ -61,9 +60,8 @@
 	//	r15 =3D syscall number
 	//	b6  =3D syscall entry point
 	//
-	.global ia32_trace_syscall
-	.proc ia32_trace_syscall
-ia32_trace_syscall:
+GLOBAL_ENTRY(ia32_trace_syscall)
+	PT_REGS_UNWIND_INFO
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
 .Lret4:	br.call.sptk.few rp=B6			// do the syscall
 .Lret5:	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
@@ -72,42 +70,38 @@
 	st8.spill [r2]=3Dr8			// store return value in slot for r8
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch return value
 .Lret6:	br.cond.sptk.many ia64_leave_kernel	// rp MUST be !=3D ia64_leave_=
kernel!
+END(ia32_trace_syscall)
=20
-	.endp ia32_trace_syscall
-
-	.align 16
-	.global sys32_vfork
-	.proc sys32_vfork
-sys32_vfork:
+GLOBAL_ENTRY(sys32_vfork)
 	alloc r16=3Dar.pfs,2,2,3,0;;
 	mov out0=3DIA64_CLONE_VFORK|IA64_CLONE_VM|SIGCHLD	// out0 =3D clone_flags
 	br.cond.sptk.few .fork1			// do the work
-	.endp sys32_vfork
+END(sys32_vfork)
=20
-	.align 16
-	.global sys32_fork
-	.proc sys32_fork
-sys32_fork:
-	alloc r16=3Dar.pfs,2,2,3,0;;
+GLOBAL_ENTRY(sys32_fork)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
+	alloc r16=3Dar.pfs,2,2,3,0
 	mov out0=3DSIGCHLD			// out0 =3D clone_flags
+	;;
 .fork1:
-	movl r28=1F
-	mov loc1=3Drp
-	br.cond.sptk.many save_switch_stack
-1:
-	mov loc0=3Dr16				// save ar.pfs across do_fork
+	mov loc0=3Drp
+	mov loc1=3Dr16				// save ar.pfs across do_fork
+	DO_SAVE_SWITCH_STACK
+
+	UNW(.body)
+
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp
 	adds r2=3DIA64_SWITCH_STACK_SIZE+IA64_PT_REGS_R12_OFFSET+16,sp
 	;;
 	ld8 out1=3D[r2]				// fetch usp from pt_regs.r12
 	br.call.sptk.few rp=3Ddo_fork
 .ret1:
-	mov ar.pfs=3Dloc0
+	mov ar.pfs=3Dloc1
+	UNW(.restore sp)
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
-	mov rp=3Dloc1
-	;;
+	mov rp=3Dloc0
 	br.ret.sptk.many rp
-	.endp sys32_fork
+END(sys32_fork)
=20
 	.rodata
 	.align 8
@@ -304,3 +298,8 @@
 	data8 sys_ni_syscall		  /* streams1 */
 	data8 sys_ni_syscall		  /* streams2 */
 	data8 sys32_vfork	  /* 190 */
+	/*
+	 *  CAUTION: If any system calls are added beyond this point
+	 *	then the check in `arch/ia64/kernel/ivt.S' will have
+	 *	to be modified also.  You've been warned.
+	 */
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c linux-2.3.99-pre6-lia/a=
rch/ia64/ia32/ia32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Fri Apr 21 15:21:23 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/ia32/ia32_signal.c	Wed May 10 13:50:50 =
2000
@@ -226,7 +226,7 @@
=20
        /* Set up to return from userspace.  If provided, use a stub
           already in userspace.  */
-       err |=3D __put_user(frame->retcode, &frame->pretcode);
+       err |=3D __put_user((long)frame->retcode, &frame->pretcode);
        /* This is popl %eax ; movl $,%eax ; int $0x80 */
        err |=3D __put_user(0xb858, (short *)(frame->retcode+0));
 #define __IA32_NR_sigreturn            119
@@ -281,8 +281,8 @@
                           ? current->exec_domain->signal_invmap[sig]
                           : sig),
                          &frame->sig);
-       err |=3D __put_user(&frame->info, &frame->pinfo);
-       err |=3D __put_user(&frame->uc, &frame->puc);
+       err |=3D __put_user((long)&frame->info, &frame->pinfo);
+       err |=3D __put_user((long)&frame->uc, &frame->puc);
        err |=3D __copy_to_user(&frame->info, info, sizeof(*info));
=20
        /* Create the ucontext.  */
@@ -296,7 +296,7 @@
                                regs, set->sig[0]);
        err |=3D __copy_to_user(&frame->uc.uc_sigmask, set, sizeof(*set));
       =20
-       err |=3D __put_user(frame->retcode, &frame->pretcode);
+       err |=3D __put_user((long)frame->retcode, &frame->pretcode);
        /* This is movl $,%eax ; int $0x80 */
        err |=3D __put_user(0xb8, (char *)(frame->retcode+0));
 #define __IA32_NR_rt_sigreturn         173
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c linux-2.3.99-pre6-lia/=
arch/ia64/ia32/ia32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Tue Feb  8 12:01:59 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/ia32/ia32_support.c	Mon May 22 18:03:20=
 2000
@@ -16,6 +16,43 @@
=20
 extern void die_if_kernel (char *str, struct pt_regs *regs, long err);
=20
+void
+ia32_save_state (struct thread_struct *thread)
+{
+	unsigned long eflag, fsr, fcr, fir, fdr;
+
+	asm ("mov %0=3Dar.eflag;"
+	     "mov %1=3Dar.fsr;"
+	     "mov %2=3Dar.fcr;"
+	     "mov %3=3Dar.fir;"
+	     "mov %4=3Dar.fdr"
+	     : "=3Dr"(eflag), "=3Dr"(fsr), "=3Dr"(fcr), "=3Dr"(fir), "=3Dr"(fdr));
+	thread->eflag =3D eflag;
+	thread->fsr =3D fsr;
+	thread->fcr =3D fcr;
+	thread->fir =3D fir;
+	thread->fdr =3D fdr;
+}
+
+void
+ia32_load_state (struct thread_struct *thread)
+{
+	unsigned long eflag, fsr, fcr, fir, fdr;
+
+	eflag =3D thread->eflag;
+	fsr =3D thread->fsr;
+	fcr =3D thread->fcr;
+	fir =3D thread->fir;
+	fdr =3D thread->fdr;
+
+	asm volatile ("mov ar.eflag=3D%0;"
+		      "mov ar.fsr=3D%1;"
+		      "mov ar.fcr=3D%2;"
+		      "mov ar.fir=3D%3;"
+		      "mov ar.fdr=3D%4"
+		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr));
+}
+
 /*
  * Setup IA32 GDT and TSS=20
  */
diff -urN linux-davidm/arch/ia64/ia32/sys_ia32.c linux-2.3.99-pre6-lia/arch=
/ia64/ia32/sys_ia32.c
--- linux-davidm/arch/ia64/ia32/sys_ia32.c	Thu May 25 23:22:10 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/ia32/sys_ia32.c	Thu May 25 22:55:38 2000
@@ -7,6 +7,8 @@
  * Copyright (C) 1999 		Arun Sharma <arun.sharma@intel.com>
  * Copyright (C) 1997,1998 	Jakub Jelinek (jj@sunsite.mff.cuni.cz)
  * Copyright (C) 1997 		David S. Miller (davem@caip.rutgers.edu)
+ * Copyright (C) 2000		Hewlett-Packard Co.
+ * Copyright (C) 2000		David Mosberger-Tang <davidm@hpl.hp.com>
  *
  * These routines maintain argument size conversion between 32bit and 64bit
  * environment.
@@ -55,24 +57,29 @@
 #include <net/sock.h>
 #include <asm/ia32.h>
=20
-#define A(__x) ((unsigned long)(__x))
-#define AA(__x) ((unsigned long)(__x))
+#define A(__x)		((unsigned long)(__x))
+#define AA(__x)		((unsigned long)(__x))
+#define ROUND_UP(x,a)	((__typeof__(x))(((unsigned long)(x) + ((a) - 1)) & =
~((a) - 1)))
+#define NAME_OFFSET(de) ((int) ((de)->d_name - (char *) (de)))
+
+extern asmlinkage long sys_execve (char *, char **, char **, struct pt_reg=
s *);
+extern asmlinkage long sys_munmap (unsigned long, size_t len);
+extern asmlinkage long sys_mprotect (unsigned long, size_t, unsigned long);
=20
 static int
 nargs(unsigned int arg, char **ap)
 {
-	char *ptr;
-	int n, err;
+	int n, err, addr;
=20
 	n =3D 0;
 	do {
-		if (err =3D get_user(ptr, (int *)arg))
+		if ((err =3D get_user(addr, (int *)A(arg))) !=3D 0)
 			return(err);
 		if (ap)
-			*ap++ =3D ptr;
+			*ap++ =3D (char *)A(addr);
 		arg +=3D sizeof(unsigned int);
 		n++;
-	} while (ptr);
+	} while (addr);
 	return(n - 1);
 }
=20
@@ -106,14 +113,14 @@
 	down(&current->mm->mmap_sem);
 	lock_kernel();
=20
-	av =3D do_mmap_pgoff(0, NULL, len,
-		PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0);
+	av =3D (char **) do_mmap_pgoff(0, 0UL, len, PROT_READ | PROT_WRITE,
+				     MAP_PRIVATE | MAP_ANONYMOUS, 0);
=20
 	unlock_kernel();
 	up(&current->mm->mmap_sem);
=20
 	if (IS_ERR(av))
-		return(av);
+		return (long)av;
 	ae =3D av + na + 1;
 	av[na] =3D (char *)0;
 	ae[ne] =3D (char *)0;
@@ -121,7 +128,7 @@
 	(void)nargs(envp, ae);
 	r =3D sys_execve(filename, av, ae, regs);
 	if (IS_ERR(r))
-		sys_munmap(av, len);
+		sys_munmap((unsigned long) av, len);
 	return(r);
 }
=20
@@ -146,9 +153,9 @@
 	return err;
 }
=20
-extern asmlinkage int sys_newstat(char * filename, struct stat * statbuf);
+extern asmlinkage long sys_newstat(char * filename, struct stat * statbuf);
=20
-asmlinkage int
+asmlinkage long
 sys32_newstat(char * filename, struct stat32 *statbuf)
 {
 	int ret;
@@ -163,9 +170,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_newlstat(char * filename, struct stat * statbuf);
+extern asmlinkage long sys_newlstat(char * filename, struct stat * statbuf=
);
=20
-asmlinkage int
+asmlinkage long
 sys32_newlstat(char * filename, struct stat32 *statbuf)
 {
 	int ret;
@@ -180,9 +187,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_newfstat(unsigned int fd, struct stat * statbuf);
+extern asmlinkage long sys_newfstat(unsigned int fd, struct stat * statbuf=
);
=20
-asmlinkage int
+asmlinkage long
 sys32_newfstat(unsigned int fd, struct stat32 *statbuf)
 {
 	int ret;
@@ -223,14 +230,14 @@
 	}
 	if (addr && ((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + le=
n)) =3D 0) {
 		back =3D kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
-		memcpy(back, addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
+		memcpy(back, (char *)addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_MASK)=
);
 	}
 	if ((r =3D do_mmap(0, baddr, len + (addr - baddr), prot, flags | MAP_ANON=
YMOUS, 0)) < 0)
 		return(r);
 	if (addr =3D 0)
 		addr =3D r;
 	if (back) {
-		memcpy(addr + len, back, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
+		memcpy((char *)addr + len, back, PAGE_SIZE - ((addr + len) & ~PAGE_MASK)=
);
 		kfree(back);
 	}
 	if (front) {
@@ -238,7 +245,7 @@
 		kfree(front);
 	}
 	if (flags & MAP_ANONYMOUS) {
-		memset(addr, 0, len);
+		memset((char *)addr, 0, len);
 		return(addr);
 	}
 	if (!file)
@@ -272,7 +279,7 @@
 	unsigned int offset;
 };
=20
-asmlinkage int
+asmlinkage long
 sys32_mmap(struct mmap_arg_struct *arg)
 {
 	int error =3D -EFAULT;
@@ -337,7 +344,7 @@
 	return(sys_mprotect(start & PAGE_MASK, len & PAGE_MASK, prot));
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_rt_sigaction(int sig, struct sigaction32 *act,
 		   struct sigaction32 *oact,  unsigned int sigsetsize)
 {
@@ -396,10 +403,10 @@
 }
=20
=20
-extern asmlinkage int sys_rt_sigprocmask(int how, sigset_t *set, sigset_t =
*oset,
-					 size_t sigsetsize);
+extern asmlinkage long sys_rt_sigprocmask(int how, sigset_t *set, sigset_t=
 *oset,
+					  size_t sigsetsize);
=20
-asmlinkage int
+asmlinkage long
 sys32_rt_sigprocmask(int how, sigset32_t *set, sigset32_t *oset,
 		     unsigned int sigsetsize)
 {
@@ -454,9 +461,9 @@
 	return err;
 }
=20
-extern asmlinkage int sys_statfs(const char * path, struct statfs * buf);
+extern asmlinkage long sys_statfs(const char * path, struct statfs * buf);
=20
-asmlinkage int
+asmlinkage long
 sys32_statfs(const char * path, struct statfs32 *buf)
 {
 	int ret;
@@ -471,9 +478,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_fstatfs(unsigned int fd, struct statfs * buf);
+extern asmlinkage long sys_fstatfs(unsigned int fd, struct statfs * buf);
=20
-asmlinkage int
+asmlinkage long
 sys32_fstatfs(unsigned int fd, struct statfs32 *buf)
 {
 	int ret;
@@ -540,7 +547,7 @@
=20
 extern int do_getitimer(int which, struct itimerval *value);
=20
-asmlinkage int
+asmlinkage long
 sys32_getitimer(int which, struct itimerval32 *it)
 {
 	struct itimerval kit;
@@ -555,7 +562,7 @@
=20
 extern int do_setitimer(int which, struct itimerval *, struct itimerval *);
=20
-asmlinkage int
+asmlinkage long
 sys32_setitimer(int which, struct itimerval32 *in, struct itimerval32 *out)
 {
 	struct itimerval kin, kout;
@@ -600,7 +607,7 @@
 extern struct timezone sys_tz;
 extern int do_sys_settimeofday(struct timeval *tv, struct timezone *tz);
=20
-asmlinkage int
+asmlinkage long
 sys32_gettimeofday(struct timeval32 *tv, struct timezone *tz)
 {
 	if (tv) {
@@ -616,7 +623,7 @@
 	return 0;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_settimeofday(struct timeval32 *tv, struct timezone *tz)
 {
 	struct timeval ktv;
@@ -634,56 +641,135 @@
 	return do_sys_settimeofday(tv ? &ktv : NULL, tz ? &ktz : NULL);
 }
=20
-struct dirent32 {
-	unsigned int	d_ino;
-	unsigned int	d_off;
-	unsigned short	d_reclen;
-	char		d_name[NAME_MAX + 1];
+struct linux32_dirent {
+	u32	d_ino;
+	u32	d_off;
+	u16	d_reclen;
+	char	d_name[1];
 };
=20
-static void
-xlate_dirent(void *dirent64, void *dirent32, long n)
+struct old_linux32_dirent {
+	u32	d_ino;
+	u32	d_offset;
+	u16	d_namlen;
+	char	d_name[1];
+};
+
+struct getdents32_callback {
+	struct linux32_dirent * current_dir;
+	struct linux32_dirent * previous;
+	int count;
+	int error;
+};
+
+struct readdir32_callback {
+	struct old_linux32_dirent * dirent;
+	int count;
+};
+
+static int
+filldir32 (void *__buf, const char *name, int namlen, off_t offset, ino_t =
ino)
 {
-	long off;
-	struct dirent *dirp;
-	struct dirent32 *dirp32;
-
-	off =3D 0;
-	while (off < n) {
-		dirp =3D (struct dirent *)(dirent64 + off);
-		dirp32 =3D (struct dirent32 *)(dirent32 + off);
-		off +=3D dirp->d_reclen;
-		dirp32->d_ino =3D dirp->d_ino;
-		dirp32->d_off =3D (unsigned int)dirp->d_off;
-		dirp32->d_reclen =3D dirp->d_reclen;
-		strncpy(dirp32->d_name, dirp->d_name, dirp->d_reclen - ((3 * 4) + 2));
-	}
-	return;
+	struct linux32_dirent * dirent;
+	struct getdents32_callback * buf =3D (struct getdents32_callback *) __buf;
+	int reclen =3D ROUND_UP(NAME_OFFSET(dirent) + namlen + 1, 4);
+
+	buf->error =3D -EINVAL;	/* only used if we fail.. */
+	if (reclen > buf->count)
+		return -EINVAL;
+	dirent =3D buf->previous;
+	if (dirent)
+		put_user(offset, &dirent->d_off);
+	dirent =3D buf->current_dir;
+	buf->previous =3D dirent;
+	put_user(ino, &dirent->d_ino);
+	put_user(reclen, &dirent->d_reclen);
+	copy_to_user(dirent->d_name, name, namlen);
+	put_user(0, dirent->d_name + namlen);
+	((char *) dirent) +=3D reclen;
+	buf->current_dir =3D dirent;
+	buf->count -=3D reclen;
+	return 0;
 }
=20
 asmlinkage long
-sys32_getdents(unsigned int fd, void * dirent32, unsigned int count)
+sys32_getdents (unsigned int fd, void * dirent, unsigned int count)
 {
-	long n;
-	void *dirent64;
+	struct file * file;
+	struct linux32_dirent * lastdirent;
+	struct getdents32_callback buf;
+	int error;
=20
-	dirent64 =3D (unsigned long)(dirent32 + (sizeof(long) - 1)) & ~(sizeof(lo=
ng) - 1);
-	if ((n =3D sys_getdents(fd, dirent64, count - (dirent64 - dirent32))) < 0)
-		return(n);
-	xlate_dirent(dirent64, dirent32, n);
-	return(n);
+	error =3D -EBADF;
+	file =3D fget(fd);
+	if (!file)
+		goto out;
+
+	buf.current_dir =3D (struct linux32_dirent *) dirent;
+	buf.previous =3D NULL;
+	buf.count =3D count;
+	buf.error =3D 0;
+
+	lock_kernel();
+	error =3D vfs_readdir(file, filldir32, &buf);
+	if (error < 0)
+		goto out_putf;
+	error =3D buf.error;
+	lastdirent =3D buf.previous;
+	if (lastdirent) {
+		put_user(file->f_pos, &lastdirent->d_off);
+		error =3D count - buf.count;
+	}
+
+out_putf:
+	unlock_kernel();
+	fput(file);
+out:
+	return error;
 }
=20
-asmlinkage int
-sys32_readdir(unsigned int fd, void * dirent32, unsigned int count)
+static int
+fillonedir32 (void * __buf, const char * name, int namlen, off_t offset, i=
no_t ino)
 {
-	int n;
-	struct dirent dirent64;
+	struct readdir32_callback * buf =3D (struct readdir32_callback *) __buf;
+	struct old_linux32_dirent * dirent;
=20
-	if ((n =3D old_readdir(fd, &dirent64, count)) < 0)
-		return(n);
-	xlate_dirent(&dirent64, dirent32, dirent64.d_reclen);
-	return(n);
+	if (buf->count)
+		return -EINVAL;
+	buf->count++;
+	dirent =3D buf->dirent;
+	put_user(ino, &dirent->d_ino);
+	put_user(offset, &dirent->d_offset);
+	put_user(namlen, &dirent->d_namlen);
+	copy_to_user(dirent->d_name, name, namlen);
+	put_user(0, dirent->d_name + namlen);
+	return 0;
+}
+
+asmlinkage long
+sys32_readdir (unsigned int fd, void * dirent, unsigned int count)
+{
+	int error;
+	struct file * file;
+	struct readdir32_callback buf;
+
+	error =3D -EBADF;
+	file =3D fget(fd);
+	if (!file)
+		goto out;
+
+	buf.count =3D 0;
+	buf.dirent =3D dirent;
+
+	lock_kernel();
+	error =3D vfs_readdir(file, fillonedir32, &buf);
+	if (error >=3D 0)
+		error =3D buf.count;
+	unlock_kernel();
+
+	fput(file);
+out:
+	return error;
 }
=20
 /*
@@ -696,9 +782,9 @@
  */
 #define MAX_SELECT_SECONDS \
 	((unsigned long) (MAX_SCHEDULE_TIMEOUT / HZ)-1)
-#define ROUND_UP(x,y) (((x)+(y)-1)/(y))
+#define ROUND_UP_TIME(x,y) (((x)+(y)-1)/(y))
=20
-asmlinkage int
+asmlinkage long
 sys32_select(int n, fd_set *inp, fd_set *outp, fd_set *exp, struct timeval=
32 *tvp32)
 {
 	fd_set_bits fds;
@@ -718,7 +804,7 @@
 			goto out_nofds;
=20
 		if ((unsigned long) sec < MAX_SELECT_SECONDS) {
-			timeout =3D ROUND_UP(usec, 1000000/HZ);
+			timeout =3D ROUND_UP_TIME(usec, 1000000/HZ);
 			timeout +=3D sec * (unsigned long) HZ;
 		}
 	}
@@ -795,13 +881,15 @@
 	unsigned int tvp;
 };
=20
-asmlinkage int old_select(struct sel_arg_struct *arg)
+asmlinkage long
+old_select(struct sel_arg_struct *arg)
 {
 	struct sel_arg_struct a;
=20
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
-	return sys32_select(a.n, a.inp, a.outp, a.exp, a.tvp);
+	return sys32_select(a.n, (fd_set *)A(a.inp), (fd_set *)A(a.outp), (fd_set=
 *)A(a.exp),
+			    (struct timeval32 *)A(a.tvp));
 }
=20
 struct timespec32 {
@@ -809,10 +897,9 @@
 	int	tv_nsec;
 };
=20
-extern asmlinkage int sys_nanosleep(struct timespec *rqtp,
-				    struct timespec *rmtp);=20
+extern asmlinkage long sys_nanosleep(struct timespec *rqtp, struct timespe=
c *rmtp);=20
=20
-asmlinkage int
+asmlinkage long
 sys32_nanosleep(struct timespec32 *rqtp, struct timespec32 *rmtp)
 {
 	struct timespec t;
@@ -993,9 +1080,9 @@
 	int	rlim_max;
 };
=20
-extern asmlinkage int sys_getrlimit(unsigned int resource, struct rlimit *=
rlim);
+extern asmlinkage long sys_getrlimit(unsigned int resource, struct rlimit =
*rlim);
=20
-asmlinkage int
+asmlinkage long
 sys32_getrlimit(unsigned int resource, struct rlimit32 *rlim)
 {
 	struct rlimit r;
@@ -1012,9 +1099,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_setrlimit(unsigned int resource, struct rlimit *=
rlim);
+extern asmlinkage long sys_setrlimit(unsigned int resource, struct rlimit =
*rlim);
=20
-asmlinkage int
+asmlinkage long
 sys32_setrlimit(unsigned int resource, struct rlimit32 *rlim)
 {
 	struct rlimit r;
@@ -1035,118 +1122,6 @@
 	return ret;
 }
=20
-/* Argument list sizes for sys_socketcall */
-#define AL(x) ((x) * sizeof(u32))
-static unsigned char nas[18]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
-                                AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
-                                AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
-#undef AL
-
-extern asmlinkage int sys_bind(int fd, struct sockaddr *umyaddr, int addrl=
en);
-extern asmlinkage int sys_connect(int fd, struct sockaddr *uservaddr,
-				  int addrlen);
-extern asmlinkage int sys_accept(int fd, struct sockaddr *upeer_sockaddr,
-				 int *upeer_addrlen);=20
-extern asmlinkage int sys_getsockname(int fd, struct sockaddr *usockaddr,
-				      int *usockaddr_len);
-extern asmlinkage int sys_getpeername(int fd, struct sockaddr *usockaddr,
-				      int *usockaddr_len);
-extern asmlinkage int sys_send(int fd, void *buff, size_t len, unsigned fl=
ags);
-extern asmlinkage int sys_sendto(int fd, u32 buff, __kernel_size_t32 len,
-				   unsigned flags, u32 addr, int addr_len);
-extern asmlinkage int sys_recv(int fd, void *ubuf, size_t size, unsigned f=
lags);
-extern asmlinkage int sys_recvfrom(int fd, u32 ubuf, __kernel_size_t32 siz=
e,
-				     unsigned flags, u32 addr, u32 addr_len);
-extern asmlinkage int sys_setsockopt(int fd, int level, int optname,
-				     char *optval, int optlen);
-extern asmlinkage int sys_getsockopt(int fd, int level, int optname,
-				       u32 optval, u32 optlen);
-
-extern asmlinkage int sys_socket(int family, int type, int protocol);
-extern asmlinkage int sys_socketpair(int family, int type, int protocol,
-				     int usockvec[2]);
-extern asmlinkage int sys_shutdown(int fd, int how);
-extern asmlinkage int sys_listen(int fd, int backlog);
-
-asmlinkage int sys32_socketcall(int call, u32 *args)
-{
-	int i, ret;
-	u32 a[6];
-	u32 a0,a1;
-				=20
-	if (call<SYS_SOCKET||call>SYS_RECVMSG)
-		return -EINVAL;
-	if (copy_from_user(a, args, nas[call]))
-		return -EFAULT;
-	a0=3Da[0];
-	a1=3Da[1];
-=09
-	switch(call)=20
-	{
-		case SYS_SOCKET:
-			ret =3D sys_socket(a0, a1, a[2]);
-			break;
-		case SYS_BIND:
-			ret =3D sys_bind(a0, (struct sockaddr *)A(a1), a[2]);
-			break;
-		case SYS_CONNECT:
-			ret =3D sys_connect(a0, (struct sockaddr *)A(a1), a[2]);
-			break;
-		case SYS_LISTEN:
-			ret =3D sys_listen(a0, a1);
-			break;
-		case SYS_ACCEPT:
-			ret =3D sys_accept(a0, (struct sockaddr *)A(a1),
-					  (int *)A(a[2]));
-			break;
-		case SYS_GETSOCKNAME:
-			ret =3D sys_getsockname(a0, (struct sockaddr *)A(a1),
-					       (int *)A(a[2]));
-			break;
-		case SYS_GETPEERNAME:
-			ret =3D sys_getpeername(a0, (struct sockaddr *)A(a1),
-					       (int *)A(a[2]));
-			break;
-		case SYS_SOCKETPAIR:
-			ret =3D sys_socketpair(a0, a1, a[2], (int *)A(a[3]));
-			break;
-		case SYS_SEND:
-			ret =3D sys_send(a0, (void *)A(a1), a[2], a[3]);
-			break;
-		case SYS_SENDTO:
-			ret =3D sys_sendto(a0, a1, a[2], a[3], a[4], a[5]);
-			break;
-		case SYS_RECV:
-			ret =3D sys_recv(a0, (void *)A(a1), a[2], a[3]);
-			break;
-		case SYS_RECVFROM:
-			ret =3D sys_recvfrom(a0, a1, a[2], a[3], a[4], a[5]);
-			break;
-		case SYS_SHUTDOWN:
-			ret =3D sys_shutdown(a0,a1);
-			break;
-		case SYS_SETSOCKOPT:
-			ret =3D sys_setsockopt(a0, a1, a[2], (char *)A(a[3]),
-					      a[4]);
-			break;
-		case SYS_GETSOCKOPT:
-			ret =3D sys_getsockopt(a0, a1, a[2], a[3], a[4]);
-			break;
-		case SYS_SENDMSG:
-			ret =3D sys32_sendmsg(a0, (struct msghdr32 *)A(a1),
-					     a[2]);
-			break;
-		case SYS_RECVMSG:
-			ret =3D sys32_recvmsg(a0, (struct msghdr32 *)A(a1),
-					     a[2]);
-			break;
-		default:
-			ret =3D EINVAL;
-			break;
-	}
-	return ret;
-}
-
 /*
  *  Declare the IA32 version of the msghdr
  */
@@ -1169,13 +1144,13 @@
 	if (!access_ok(VERIFY_READ, mp32, sizeof(*mp32)))
 		return(-EFAULT);
 	__get_user(i, &mp32->msg_name);
-	mp->msg_name =3D (void *)i;
+	mp->msg_name =3D (void *)A(i);
 	__get_user(mp->msg_namelen, &mp32->msg_namelen);
 	__get_user(i, &mp32->msg_iov);
-	mp->msg_iov =3D (struct iov *)i;
+	mp->msg_iov =3D (struct iovec *)A(i);
 	__get_user(mp->msg_iovlen, &mp32->msg_iovlen);
 	__get_user(i, &mp32->msg_control);
-	mp->msg_control =3D (void *)i;
+	mp->msg_control =3D (void *)A(i);
 	__get_user(mp->msg_controllen, &mp32->msg_controllen);
 	__get_user(mp->msg_flags, &mp32->msg_flags);
 	return(0);
@@ -1221,7 +1196,7 @@
 	iov32 =3D (struct iovec32 *)iov;
 	for (ct =3D m->msg_iovlen; ct-- > 0; ) {
 		iov[ct].iov_len =3D (__kernel_size_t)iov32[ct].iov_len;
-		iov[ct].iov_base =3D (void *)iov32[ct].iov_base;
+		iov[ct].iov_base =3D (void *) A(iov32[ct].iov_base);
 		err +=3D iov[ct].iov_len;
 	}
 out:
@@ -1246,7 +1221,7 @@
  *	BSD sendmsg interface
  */
=20
-asmlinkage int sys32_sendmsg(int fd, struct msghdr32 *msg, unsigned flags)
+int sys32_sendmsg(int fd, struct msghdr32 *msg, unsigned flags)
 {
 	struct socket *sock;
 	char address[MAX_SOCK_ADDR];
@@ -1325,7 +1300,8 @@
  *	BSD recvmsg interface
  */
=20
-asmlinkage int sys32_recvmsg(int fd, struct msghdr32 *msg, unsigned int fl=
ags)
+int
+sys32_recvmsg (int fd, struct msghdr32 *msg, unsigned int flags)
 {
 	struct socket *sock;
 	struct iovec iovstack[UIO_FASTIOV];
@@ -1407,6 +1383,118 @@
 	return err;
 }
=20
+/* Argument list sizes for sys_socketcall */
+#define AL(x) ((x) * sizeof(u32))
+static unsigned char nas[18]=3D{AL(0),AL(3),AL(3),AL(3),AL(2),AL(3),
+                                AL(3),AL(3),AL(4),AL(4),AL(4),AL(6),
+                                AL(6),AL(2),AL(5),AL(5),AL(3),AL(3)};
+#undef AL
+
+extern asmlinkage long sys_bind(int fd, struct sockaddr *umyaddr, int addr=
len);
+extern asmlinkage long sys_connect(int fd, struct sockaddr *uservaddr,
+				  int addrlen);
+extern asmlinkage long sys_accept(int fd, struct sockaddr *upeer_sockaddr,
+				 int *upeer_addrlen);=20
+extern asmlinkage long sys_getsockname(int fd, struct sockaddr *usockaddr,
+				      int *usockaddr_len);
+extern asmlinkage long sys_getpeername(int fd, struct sockaddr *usockaddr,
+				      int *usockaddr_len);
+extern asmlinkage long sys_send(int fd, void *buff, size_t len, unsigned f=
lags);
+extern asmlinkage long sys_sendto(int fd, u32 buff, __kernel_size_t32 len,
+				   unsigned flags, u32 addr, int addr_len);
+extern asmlinkage long sys_recv(int fd, void *ubuf, size_t size, unsigned =
flags);
+extern asmlinkage long sys_recvfrom(int fd, u32 ubuf, __kernel_size_t32 si=
ze,
+				     unsigned flags, u32 addr, u32 addr_len);
+extern asmlinkage long sys_setsockopt(int fd, int level, int optname,
+				     char *optval, int optlen);
+extern asmlinkage long sys_getsockopt(int fd, int level, int optname,
+				       u32 optval, u32 optlen);
+
+extern asmlinkage long sys_socket(int family, int type, int protocol);
+extern asmlinkage long sys_socketpair(int family, int type, int protocol,
+				     int usockvec[2]);
+extern asmlinkage long sys_shutdown(int fd, int how);
+extern asmlinkage long sys_listen(int fd, int backlog);
+
+asmlinkage long sys32_socketcall(int call, u32 *args)
+{
+	int ret;
+	u32 a[6];
+	u32 a0,a1;
+				=20
+	if (call<SYS_SOCKET||call>SYS_RECVMSG)
+		return -EINVAL;
+	if (copy_from_user(a, args, nas[call]))
+		return -EFAULT;
+	a0=3Da[0];
+	a1=3Da[1];
+=09
+	switch(call)=20
+	{
+		case SYS_SOCKET:
+			ret =3D sys_socket(a0, a1, a[2]);
+			break;
+		case SYS_BIND:
+			ret =3D sys_bind(a0, (struct sockaddr *)A(a1), a[2]);
+			break;
+		case SYS_CONNECT:
+			ret =3D sys_connect(a0, (struct sockaddr *)A(a1), a[2]);
+			break;
+		case SYS_LISTEN:
+			ret =3D sys_listen(a0, a1);
+			break;
+		case SYS_ACCEPT:
+			ret =3D sys_accept(a0, (struct sockaddr *)A(a1),
+					  (int *)A(a[2]));
+			break;
+		case SYS_GETSOCKNAME:
+			ret =3D sys_getsockname(a0, (struct sockaddr *)A(a1),
+					       (int *)A(a[2]));
+			break;
+		case SYS_GETPEERNAME:
+			ret =3D sys_getpeername(a0, (struct sockaddr *)A(a1),
+					       (int *)A(a[2]));
+			break;
+		case SYS_SOCKETPAIR:
+			ret =3D sys_socketpair(a0, a1, a[2], (int *)A(a[3]));
+			break;
+		case SYS_SEND:
+			ret =3D sys_send(a0, (void *)A(a1), a[2], a[3]);
+			break;
+		case SYS_SENDTO:
+			ret =3D sys_sendto(a0, a1, a[2], a[3], a[4], a[5]);
+			break;
+		case SYS_RECV:
+			ret =3D sys_recv(a0, (void *)A(a1), a[2], a[3]);
+			break;
+		case SYS_RECVFROM:
+			ret =3D sys_recvfrom(a0, a1, a[2], a[3], a[4], a[5]);
+			break;
+		case SYS_SHUTDOWN:
+			ret =3D sys_shutdown(a0,a1);
+			break;
+		case SYS_SETSOCKOPT:
+			ret =3D sys_setsockopt(a0, a1, a[2], (char *)A(a[3]),
+					      a[4]);
+			break;
+		case SYS_GETSOCKOPT:
+			ret =3D sys_getsockopt(a0, a1, a[2], a[3], a[4]);
+			break;
+		case SYS_SENDMSG:
+			ret =3D sys32_sendmsg(a0, (struct msghdr32 *)A(a1),
+					     a[2]);
+			break;
+		case SYS_RECVMSG:
+			ret =3D sys32_recvmsg(a0, (struct msghdr32 *)A(a1),
+					     a[2]);
+			break;
+		default:
+			ret =3D EINVAL;
+			break;
+	}
+	return ret;
+}
+
 /*
  * sys32_ipc() is the de-multiplexer for the SysV IPC calls in 32bit emula=
tion..
  *
@@ -1601,7 +1689,7 @@
 static int
 do_sys32_msgctl (int first, int second, void *uptr)
 {
-	int err, err2;
+	int err =3D -EINVAL, err2;
 	struct msqid_ds m;
 	struct msqid64_ds m64;
 	struct msqid_ds32 *up =3D (struct msqid_ds32 *)uptr;
@@ -1632,7 +1720,7 @@
 	case MSG_STAT:
 		old_fs =3D get_fs ();
 		set_fs (KERNEL_DS);
-		err =3D sys_msgctl (first, second, &m64);
+		err =3D sys_msgctl (first, second, (void *) &m64);
 		set_fs (old_fs);
 		err2 =3D put_user (m64.msg_perm.key, &up->msg_perm.key);
 		err2 |=3D __put_user(m64.msg_perm.uid, &up->msg_perm.uid);
@@ -1713,7 +1801,7 @@
 	case SHM_STAT:
 		old_fs =3D get_fs ();
 		set_fs (KERNEL_DS);
-		err =3D sys_shmctl (first, second, &s64);
+		err =3D sys_shmctl (first, second, (void *) &s64);
 		set_fs (old_fs);
 		if (err < 0)
 			break;
@@ -1741,7 +1829,7 @@
 	case SHM_INFO:
 		old_fs =3D get_fs ();
 		set_fs (KERNEL_DS);
-		err =3D sys_shmctl (first, second, &si);
+		err =3D sys_shmctl (first, second, (void *)&si);
 		set_fs (old_fs);
 		if (err < 0)
 			break;
@@ -1761,7 +1849,7 @@
 	return err;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_ipc (u32 call, int first, int second, int third, u32 ptr, u32 fifth)
 {
 	int version, err;
@@ -1886,10 +1974,10 @@
 	return err;
 }
=20
-extern asmlinkage int sys_wait4(pid_t pid,unsigned int * stat_addr,
+extern asmlinkage long sys_wait4(pid_t pid,unsigned int * stat_addr,
 				int options, struct rusage * ru);
=20
-asmlinkage int
+asmlinkage long
 sys32_wait4(__kernel_pid_t32 pid, unsigned int *stat_addr, int options,
 	    struct rusage32 *ru)
 {
@@ -1911,17 +1999,17 @@
 	}
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_waitpid(__kernel_pid_t32 pid, unsigned int *stat_addr, int options)
 {
 	return sys32_wait4(pid, stat_addr, options, NULL);
 }
=20
=20
-extern asmlinkage int
+extern asmlinkage long
 sys_getrusage(int who, struct rusage *ru);
=20
-asmlinkage int
+asmlinkage long
 sys32_getrusage(int who, struct rusage32 *ru)
 {
 	struct rusage r;
@@ -2417,9 +2505,9 @@
=20
 /* 32-bit timeval and related flotsam.  */
=20
-extern asmlinkage int sys_ioperm(unsigned long from, unsigned long num, in=
t on);
+extern asmlinkage long sys_ioperm(unsigned long from, unsigned long num, i=
nt on);
=20
-asmlinkage int
+asmlinkage long
 sys32_ioperm(u32 from, u32 num, int on)
 {
 	return sys_ioperm((unsigned long)from, (unsigned long)num, on);
@@ -2491,10 +2579,10 @@
     __kernel_time_t32 dqb_itime;
 };
                                =20
-extern asmlinkage int sys_quotactl(int cmd, const char *special, int id,
+extern asmlinkage long sys_quotactl(int cmd, const char *special, int id,
 				   caddr_t addr);
=20
-asmlinkage int
+asmlinkage long
 sys32_quotactl(int cmd, const char *special, int id, unsigned long addr)
 {
 	int cmds =3D cmd >> SUBCMDSHIFT;
@@ -2538,13 +2626,13 @@
 	return err;
 }
=20
-extern asmlinkage int sys_utime(char * filename, struct utimbuf * times);
+extern asmlinkage long sys_utime(char * filename, struct utimbuf * times);
=20
 struct utimbuf32 {
 	__kernel_time_t32 actime, modtime;
 };
=20
-asmlinkage int
+asmlinkage long
 sys32_utime(char * filename, struct utimbuf32 *times)
 {
 	struct utimbuf t;
@@ -2628,10 +2716,10 @@
 		__put_user(*fdset, ufdset);
 }
=20
-extern asmlinkage int sys_sysfs(int option, unsigned long arg1,
+extern asmlinkage long sys_sysfs(int option, unsigned long arg1,
 				unsigned long arg2);
=20
-asmlinkage int
+asmlinkage long
 sys32_sysfs(int option, u32 arg1, u32 arg2)
 {
 	return sys_sysfs(option, arg1, arg2);
@@ -2729,7 +2817,7 @@
 #define SMBFS_NAME	"smbfs"
 #define NCPFS_NAME	"ncpfs"
=20
-asmlinkage int
+asmlinkage long
 sys32_mount(char *dev_name, char *dir_name, char *type,
 	    unsigned long new_flags, u32 data)
 {
@@ -2803,9 +2891,9 @@
         char _f[22];
 };
=20
-extern asmlinkage int sys_sysinfo(struct sysinfo *info);
+extern asmlinkage long sys_sysinfo(struct sysinfo *info);
=20
-asmlinkage int
+asmlinkage long
 sys32_sysinfo(struct sysinfo32 *info)
 {
 	struct sysinfo s;
@@ -2831,10 +2919,10 @@
 	return ret;
 }
                =20
-extern asmlinkage int sys_sched_rr_get_interval(pid_t pid,
+extern asmlinkage long sys_sched_rr_get_interval(pid_t pid,
 						struct timespec *interval);
=20
-asmlinkage int
+asmlinkage long
 sys32_sched_rr_get_interval(__kernel_pid_t32 pid, struct timespec32 *inter=
val)
 {
 	struct timespec t;
@@ -2850,10 +2938,10 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_sigprocmask(int how, old_sigset_t *set,
+extern asmlinkage long sys_sigprocmask(int how, old_sigset_t *set,
 				      old_sigset_t *oset);
=20
-asmlinkage int
+asmlinkage long
 sys32_sigprocmask(int how, old_sigset_t32 *set, old_sigset_t32 *oset)
 {
 	old_sigset_t s;
@@ -2869,9 +2957,9 @@
 	return 0;
 }
=20
-extern asmlinkage int sys_sigpending(old_sigset_t *set);
+extern asmlinkage long sys_sigpending(old_sigset_t *set);
=20
-asmlinkage int
+asmlinkage long
 sys32_sigpending(old_sigset_t32 *set)
 {
 	old_sigset_t s;
@@ -2885,9 +2973,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_rt_sigpending(sigset_t *set, size_t sigsetsize);
+extern asmlinkage long sys_rt_sigpending(sigset_t *set, size_t sigsetsize);
=20
-asmlinkage int
+asmlinkage long
 sys32_rt_sigpending(sigset_t32 *set, __kernel_size_t32 sigsetsize)
 {
 	sigset_t s;
@@ -2990,11 +3078,11 @@
 	return d;
 }
=20
-extern asmlinkage int
+extern asmlinkage long
 sys_rt_sigtimedwait(const sigset_t *uthese, siginfo_t *uinfo,
 		    const struct timespec *uts, size_t sigsetsize);
=20
-asmlinkage int
+asmlinkage long
 sys32_rt_sigtimedwait(sigset_t32 *uthese, siginfo_t32 *uinfo,
 		      struct timespec32 *uts, __kernel_size_t32 sigsetsize)
 {
@@ -3031,10 +3119,10 @@
 	return ret;
 }
=20
-extern asmlinkage int
+extern asmlinkage long
 sys_rt_sigqueueinfo(int pid, int sig, siginfo_t *uinfo);
=20
-asmlinkage int
+asmlinkage long
 sys32_rt_sigqueueinfo(int pid, int sig, siginfo_t32 *uinfo)
 {
 	siginfo_t info;
@@ -3052,9 +3140,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_setreuid(uid_t ruid, uid_t euid);
+extern asmlinkage long sys_setreuid(uid_t ruid, uid_t euid);
=20
-asmlinkage int sys32_setreuid(__kernel_uid_t32 ruid, __kernel_uid_t32 euid)
+asmlinkage long sys32_setreuid(__kernel_uid_t32 ruid, __kernel_uid_t32 eui=
d)
 {
 	uid_t sruid, seuid;
=20
@@ -3063,9 +3151,9 @@
 	return sys_setreuid(sruid, seuid);
 }
=20
-extern asmlinkage int sys_setresuid(uid_t ruid, uid_t euid, uid_t suid);
+extern asmlinkage long sys_setresuid(uid_t ruid, uid_t euid, uid_t suid);
=20
-asmlinkage int
+asmlinkage long
 sys32_setresuid(__kernel_uid_t32 ruid, __kernel_uid_t32 euid,
 		__kernel_uid_t32 suid)
 {
@@ -3077,9 +3165,9 @@
 	return sys_setresuid(sruid, seuid, ssuid);
 }
=20
-extern asmlinkage int sys_getresuid(uid_t *ruid, uid_t *euid, uid_t *suid);
+extern asmlinkage long sys_getresuid(uid_t *ruid, uid_t *euid, uid_t *suid=
);
=20
-asmlinkage int
+asmlinkage long
 sys32_getresuid(__kernel_uid_t32 *ruid, __kernel_uid_t32 *euid,
 		__kernel_uid_t32 *suid)
 {
@@ -3095,9 +3183,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_setregid(gid_t rgid, gid_t egid);
+extern asmlinkage long sys_setregid(gid_t rgid, gid_t egid);
=20
-asmlinkage int
+asmlinkage long
 sys32_setregid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid)
 {
 	gid_t srgid, segid;
@@ -3107,9 +3195,9 @@
 	return sys_setregid(srgid, segid);
 }
=20
-extern asmlinkage int sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid);
+extern asmlinkage long sys_setresgid(gid_t rgid, gid_t egid, gid_t sgid);
=20
-asmlinkage int
+asmlinkage long
 sys32_setresgid(__kernel_gid_t32 rgid, __kernel_gid_t32 egid,
 		__kernel_gid_t32 sgid)
 {
@@ -3121,9 +3209,9 @@
 	return sys_setresgid(srgid, segid, ssgid);
 }
=20
-extern asmlinkage int sys_getresgid(gid_t *rgid, gid_t *egid, gid_t *sgid);
+extern asmlinkage long sys_getresgid(gid_t *rgid, gid_t *egid, gid_t *sgid=
);
=20
-asmlinkage int
+asmlinkage long
 sys32_getresgid(__kernel_gid_t32 *rgid, __kernel_gid_t32 *egid,
 		__kernel_gid_t32 *sgid)=20
 {
@@ -3142,9 +3230,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_getgroups(int gidsetsize, gid_t *grouplist);
+extern asmlinkage long sys_getgroups(int gidsetsize, gid_t *grouplist);
=20
-asmlinkage int
+asmlinkage long
 sys32_getgroups(int gidsetsize, __kernel_gid_t32 *grouplist)
 {
 	gid_t gl[NGROUPS];
@@ -3161,9 +3249,9 @@
 	return ret;
 }
=20
-extern asmlinkage int sys_setgroups(int gidsetsize, gid_t *grouplist);
+extern asmlinkage long sys_setgroups(int gidsetsize, gid_t *grouplist);
=20
-asmlinkage int
+asmlinkage long
 sys32_setgroups(int gidsetsize, __kernel_gid_t32 *grouplist)
 {
 	gid_t gl[NGROUPS];
@@ -3607,7 +3695,7 @@
 	kmsg->msg_control =3D (void *) orig_cmsg_uptr;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_sendmsg(int fd, struct msghdr32 *user_msg, unsigned user_flags)
 {
 	struct socket *sock;
@@ -3655,7 +3743,7 @@
 	return err;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_recvmsg(int fd, struct msghdr32 *user_msg, unsigned int user_flags)
 {
 	struct iovec iovstack[UIO_FASTIOV];
@@ -3746,7 +3834,7 @@
=20
 extern void check_pending(int signum);
=20
-asmlinkage int
+asmlinkage long
 sys32_sigaction (int sig, struct old_sigaction32 *act,
 		 struct old_sigaction32 *oact)
 {
@@ -3791,21 +3879,21 @@
 	return sys_create_module(name_user, (size_t)size);
 }
=20
-extern asmlinkage int sys_init_module(const char *name_user,
+extern asmlinkage long sys_init_module(const char *name_user,
 				      struct module *mod_user);=20
=20
 /* Hey, when you're trying to init module, take time and prepare us a nice=
 64bit
  * module structure, even if from 32bit modutils... Why to pollute kernel.=
.. :))
  */
-asmlinkage int
+asmlinkage long
 sys32_init_module(const char *name_user, struct module *mod_user)
 {
 	return sys_init_module(name_user, mod_user);
 }
=20
-extern asmlinkage int sys_delete_module(const char *name_user);
+extern asmlinkage long sys_delete_module(const char *name_user);
=20
-asmlinkage int
+asmlinkage long
 sys32_delete_module(const char *name_user)
 {
 	return sys_delete_module(name_user);
@@ -4080,7 +4168,7 @@
 	return error;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_query_module(char *name_user, int which, char *buf,
 		   __kernel_size_t32 bufsize, u32 ret)=20
 {
@@ -4148,9 +4236,9 @@
 	char name[60];
 };
 		=20
-extern asmlinkage int sys_get_kernel_syms(struct kernel_sym *table);
+extern asmlinkage long sys_get_kernel_syms(struct kernel_sym *table);
=20
-asmlinkage int
+asmlinkage long
 sys32_get_kernel_syms(struct kernel_sym32 *table)
 {
 	int len, i;
@@ -4182,19 +4270,19 @@
 	return -ENOSYS;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_init_module(const char *name_user, struct module *mod_user)
 {
 	return -ENOSYS;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_delete_module(const char *name_user)
 {
 	return -ENOSYS;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_query_module(const char *name_user, int which, char *buf, size_t buf=
size,
 		 size_t *ret)
 {
@@ -4206,7 +4294,7 @@
 	return -ENOSYS;
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_get_kernel_syms(struct kernel_sym *table)
 {
 	return -ENOSYS;
@@ -4422,7 +4510,7 @@
 	return err;
 }
=20
-extern asmlinkage int sys_nfsservctl(int cmd, void *arg, void *resp);
+extern asmlinkage long sys_nfsservctl(int cmd, void *arg, void *resp);
=20
 int asmlinkage
 sys32_nfsservctl(int cmd, struct nfsctl_arg32 *arg32, union nfsctl_res32 *=
res32)
@@ -4493,9 +4581,9 @@
 	return err;
 }
=20
-asmlinkage int sys_utimes(char *, struct timeval *);
+asmlinkage long sys_utimes(char *, struct timeval *);
=20
-asmlinkage int
+asmlinkage long
 sys32_utimes(char *filename, struct timeval32 *tvs)
 {
 	char *kfilename;
@@ -4523,7 +4611,7 @@
 }
=20
 /* These are here just in case some old ia32 binary calls it. */
-asmlinkage int
+asmlinkage long
 sys32_pause(void)
 {
 	current->state =3D TASK_INTERRUPTIBLE;
@@ -4532,19 +4620,19 @@
 }
=20
 /* PCI config space poking. */
-extern asmlinkage int sys_pciconfig_read(unsigned long bus,
+extern asmlinkage long sys_pciconfig_read(unsigned long bus,
 					 unsigned long dfn,
 					 unsigned long off,
 					 unsigned long len,
 					 unsigned char *buf);
=20
-extern asmlinkage int sys_pciconfig_write(unsigned long bus,
+extern asmlinkage long sys_pciconfig_write(unsigned long bus,
 					  unsigned long dfn,
 					  unsigned long off,
 					  unsigned long len,
 					  unsigned char *buf);
=20
-asmlinkage int
+asmlinkage long
 sys32_pciconfig_read(u32 bus, u32 dfn, u32 off, u32 len, u32 ubuf)
 {
 	return sys_pciconfig_read((unsigned long) bus,
@@ -4554,7 +4642,7 @@
 				  (unsigned char *)AA(ubuf));
 }
=20
-asmlinkage int
+asmlinkage long
 sys32_pciconfig_write(u32 bus, u32 dfn, u32 off, u32 len, u32 ubuf)
 {
 	return sys_pciconfig_write((unsigned long) bus,
@@ -4564,11 +4652,11 @@
 				   (unsigned char *)AA(ubuf));
 }
=20
-extern asmlinkage int sys_prctl(int option, unsigned long arg2,
+extern asmlinkage long sys_prctl(int option, unsigned long arg2,
 				unsigned long arg3, unsigned long arg4,
 				unsigned long arg5);
=20
-asmlinkage int
+asmlinkage long
 sys32_prctl(int option, u32 arg2, u32 arg3, u32 arg4, u32 arg5)
 {
 	return sys_prctl(option,
@@ -4579,9 +4667,9 @@
 }
=20
=20
-extern asmlinkage int sys_newuname(struct new_utsname * name);
+extern asmlinkage long sys_newuname(struct new_utsname * name);
=20
-asmlinkage int
+asmlinkage long
 sys32_newuname(struct new_utsname * name)
 {
 	int ret =3D sys_newuname(name);
@@ -4617,9 +4705,9 @@
 }
=20
=20
-extern asmlinkage int sys_personality(unsigned long);
+extern asmlinkage long sys_personality(unsigned long);
=20
-asmlinkage int
+asmlinkage long
 sys32_personality(unsigned long personality)
 {
 	int ret;
@@ -4636,7 +4724,7 @@
 extern asmlinkage ssize_t sys_sendfile(int out_fd, int in_fd, off_t *offse=
t,
 				       size_t count);=20
=20
-asmlinkage int
+asmlinkage long
 sys32_sendfile(int out_fd, int in_fd, __kernel_off_t32 *offset, s32 count)
 {
 	mm_segment_t old_fs =3D get_fs();
@@ -4673,7 +4761,7 @@
=20
 extern int do_adjtimex(struct timex *);
=20
-asmlinkage int
+asmlinkage long
 sys32_adjtimex(struct timex32 *utp)
 {
 	struct timex txc;
diff -urN linux-davidm/arch/ia64/kernel/Makefile linux-2.3.99-pre6-lia/arch=
/ia64/kernel/Makefile
--- linux-davidm/arch/ia64/kernel/Makefile	Fri Apr 21 15:21:24 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/Makefile	Thu May 25 19:44:00 2000
@@ -15,11 +15,10 @@
 all: kernel.o head.o init_task.o
=20
 O_TARGET :=3D kernel.o
-O_OBJS	 :=3D acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_s=
apic.o ivt.o \
-	    pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o sal_stub.o semapho=
re.o setup.o \
+O_OBJS	 :=3D acpi.o entry.o gate.o efi.o efi_stub.o irq.o irq_ia64.o irq_s=
apic.o ivt.o	\
+	    pal.o pci-dma.o process.o perfmon.o ptrace.o sal.o semaphore.o setup.=
o	\
 	    signal.o sys_ia64.o traps.o time.o unaligned.o unwind.o
-#O_OBJS   :=3D fpreg.o
-#OX_OBJS  :=3D ia64_ksyms.o
+OX_OBJS  :=3D ia64_ksyms.o
=20
 ifdef CONFIG_IA64_GENERIC
 O_OBJS	+=3D machvec.o
diff -urN linux-davidm/arch/ia64/kernel/acpi.c linux-2.3.99-pre6-lia/arch/i=
a64/kernel/acpi.c
--- linux-davidm/arch/ia64/kernel/acpi.c	Fri Apr 21 15:21:24 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/acpi.c	Thu May 25 22:56:31 2000
@@ -89,16 +89,16 @@
 #ifdef CONFIG_IA64_DIG
 	acpi_entry_iosapic_t *iosapic =3D (acpi_entry_iosapic_t *) p;
 	unsigned int ver, v;
-	int l, pins;
+	int l, max_pin;
=20
 	ver =3D iosapic_version(iosapic->address);
-	pins =3D (ver >> 16) & 0xff;
+	max_pin =3D (ver >> 16) & 0xff;
 =09
 	printk("IOSAPIC Version %x.%x: address 0x%lx IRQs 0x%x - 0x%x\n",=20
 	       (ver & 0xf0) >> 4, (ver & 0x0f), iosapic->address,=20
-	       iosapic->irq_base, iosapic->irq_base + pins);
+	       iosapic->irq_base, iosapic->irq_base + max_pin);
 =09
-	for (l =3D 0; l < pins; l++) {
+	for (l =3D 0; l <=3D max_pin; l++) {
 		v =3D iosapic->irq_base + l;
 		if (v < 16)
 			v =3D isa_irq_to_vector(v);
@@ -110,7 +110,7 @@
 		iosapic_addr(v) =3D (unsigned long) ioremap(iosapic->address, 0);
 		iosapic_baseirq(v) =3D iosapic->irq_base;
 	}
-	iosapic_init(iosapic->address);
+	iosapic_init(iosapic->address, iosapic->irq_base);
 #endif
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/efi_stub.S linux-2.3.99-pre6-lia/ar=
ch/ia64/kernel/efi_stub.S
--- linux-davidm/arch/ia64/kernel/efi_stub.S	Sun Feb  6 18:42:40 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/efi_stub.S	Thu May 25 22:56:41 2=
000
@@ -1,7 +1,8 @@
 /*
  * EFI call stub.
  *
- * Copyright (C) 1999 David Mosberger <davidm@hpl.hp.com>
+ * Copyright (C) 1999-2000 Hewlett-Packard Co
+ * Copyright (C) 1999-2000 David Mosberger <davidm@hpl.hp.com>
  *
  * This stub allows us to make EFI calls in physical mode with interrupts
  * turned off.  We need this because we can't call SetVirtualMap() until
@@ -30,6 +31,7 @@
 	(IA64_PSR_BN)
=20
 #include <asm/processor.h>
+#include <asm/asmmacro.h>
=20
 	.text
 	.psr abi64
@@ -44,8 +46,7 @@
  * Inputs:
  *	r16 =3D new psr to establish
  */
-	.proc switch_mode
-switch_mode:
+ENTRY(switch_mode)
  {
 	alloc r2=3Dar.pfs,0,0,0,0
 	rsm psr.i | psr.ic		// disable interrupts and interrupt collection
@@ -83,7 +84,7 @@
 	;;
 1:	mov rp=3Dr14
 	br.ret.sptk.few rp
-	.endp switch_mode
+END(switch_mode)
=20
 /*
  * Inputs:
@@ -94,13 +95,12 @@
  *	r8 =3D EFI_STATUS returned by called function
  */
=20
-	.global efi_call_phys
-	.proc efi_call_phys
-efi_call_phys:
-
-	alloc loc0=3Dar.pfs,8,5,7,0
+GLOBAL_ENTRY(efi_call_phys)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	alloc loc1=3Dar.pfs,8,5,7,0
 	ld8 r2=3D[in0],8			// load EFI function's entry point
-	mov loc1=3Drp
+	mov loc0=3Drp
+	UNW(.body)
 	;;
 	mov loc2=3Dgp			// save global pointer
 	mov loc4=3Dar.rsc			// save RSE configuration
@@ -133,9 +133,8 @@
 	br.call.sptk.few rp=3Dswitch_mode	// return to virtual mode
 .ret2:
 	mov ar.rsc=3Dloc4			// restore RSE configuration
-	mov ar.pfs=3Dloc0
-	mov rp=3Dloc1
+	mov ar.pfs=3Dloc1
+	mov rp=3Dloc0
 	mov gp=3Dloc2
 	br.ret.sptk.few rp
-=09
-	.endp efi_call_phys
+END(efi_call_phys)
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.3.99-pre6-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Thu May 25 23:22:10 2000
+++ linux-2.3.99-pre6-lia/arch/ia64/kernel/entry.S	Thu May 25 22:57:38 2000
@@ -13,8 +13,6 @@
 /*
  * Global (preserved) predicate usage on syscall entry/exit path:
  *
- *=20
- *	pEOI:		See entry.h.
  *	pKern:		See entry.h.
  *	pSys:		See entry.h.
  *	pNonSys:	!pSys
@@ -30,6 +28,7 @@
 #include <asm/offsets.h>
 #include <asm/processor.h>
 #include <asm/unistd.h>
+#include <asm/asmmacro.h>
=20
 #include "entry.h"
=20
@@ -42,11 +41,11 @@
 	 * execve() is special because in case of success, we need to
 	 * setup a null register window frame.
 	 */
-	.align 16
-	.proc ia64_execve
-ia64_execve:
-	alloc loc0=3Dar.pfs,3,2,4,0
-	mov loc1=3Drp
+ENTRY(ia64_execve)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(3))
+	alloc loc1=3Dar.pfs,3,2,4,0
+	mov loc0=3Drp
+	UNW(.body)
 	mov out0=3Din0			// filename
 	;;				// stop bit between alloc and call
 	mov out1=3Din1			// argv
@@ -54,25 +53,22 @@
 	add out3=16,sp			// regs
 	br.call.sptk.few rp=3Dsys_execve
 .ret0:	cmp4.ge p6,p0=3Dr8,r0
-	mov ar.pfs=3Dloc0			// restore ar.pfs
+	mov ar.pfs=3Dloc1			// restore ar.pfs
 	;;
 (p6)	mov ar.pfs=3Dr0			// clear ar.pfs in case of success
 	sxt4 r8=3Dr8			// return 64-bit result
-	mov rp=3Dloc1
+	mov rp=3Dloc0
=20
 	br.ret.sptk.few rp
-	.endp ia64_execve
+END(ia64_execve)
=20
-	.align 16
-	.global sys_clone
-	.proc sys_clone
-sys_clone:
+GLOBAL_ENTRY(sys_clone)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2))
 	alloc r16=3Dar.pfs,2,2,3,0;;
-	movl r28=1F
-	mov loc1=3Drp
-	br.cond.sptk.many save_switch_stack
-1:
-	mov loc0=3Dr16				// save ar.pfs across do_fork
+	mov loc0=3Drp
+	DO_SAVE_SWITCH_STACK
+	mov loc1=3Dr16				// save ar.pfs across do_fork
+	UNW(.body)
 	adds out2=3DIA64_SWITCH_STACK_SIZE+16,sp
 	adds r2=3DIA64_SWITCH_STACK_SIZE+IA64_PT_REGS_R12_OFFSET+16,sp
 	cmp.eq p8,p9=3Din1,r0			// usp =3D 0?
@@ -82,24 +78,22 @@
 (p9)	mov out1=3Din1
 	br.call.sptk.few rp=3Ddo_fork
 .ret1:
-	mov ar.pfs=3Dloc0
+	mov ar.pfs=3Dloc1
+	UNW(.restore sp)
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop the switch stack
-	mov rp=3Dloc1
+	mov rp=3Dloc0
 	;;
 	br.ret.sptk.many rp
-	.endp sys_clone
+END(sys_clone)
=20
 /*
- * prev_task <- switch_to(struct task_struct *next)
+ * prev_task <- ia64_switch_to(struct task_struct *next)
  */
-	.align 16
-	.global ia64_switch_to
-	.proc ia64_switch_to
-ia64_switch_to:
+GLOBAL_ENTRY(ia64_switch_to)
+	UNW(.prologue)
 	alloc r16=3Dar.pfs,1,0,0,0
-	movl r28=1F
-	br.cond.sptk.many save_switch_stack
-1:
+	DO_SAVE_SWITCH_STACK
+	UNW(.body)
 	// disable interrupts to ensure atomicity for next few instructions:
 	mov r17=3Dpsr		// M-unit
 	;;
@@ -126,63 +120,58 @@
=20
 	movl r28=1F
 	br.cond.sptk.many load_switch_stack
-1:
+1:	UNW(.restore sp)
+	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop switch_stack
 	br.ret.sptk.few rp
-	.endp ia64_switch_to
+END(ia64_switch_to)
=20
 	/*
 	 * Like save_switch_stack, but also save the stack frame that is active
 	 * at the time this function is called.
 	 */
-	.align 16
-	.proc save_switch_stack_with_current_frame
-save_switch_stack_with_current_frame:
-1:	{
-	  alloc r16=3Dar.pfs,0,0,0,0		// pass ar.pfs to save_switch_stack
-	  mov r28=3Dip
-	}
-	;;
-	adds r28=1F-1b,r28
-	br.cond.sptk.many save_switch_stack
-1:	br.ret.sptk.few rp
-	.endp save_switch_stack_with_current_frame
+ENTRY(save_switch_stack_with_current_frame)
+	UNW(.prologue)
+	alloc r16=3Dar.pfs,0,0,0,0		// pass ar.pfs to save_switch_stack
+	DO_SAVE_SWITCH_STACK
+	br.ret.sptk.few rp
+END(save_switch_stack_with_current_frame)
 /*
  * Note that interrupts are enabled during save_switch_stack and
  * load_switch_stack.  This means that we may get an interrupt with
  * "sp" pointing to the new kernel stack while ar.bspstore is still
  * pointing to the old kernel backing store area.  Since ar.rsc,
  * ar.rnat, ar.bsp, and ar.bspstore are all preserved by interrupts,
- * this is not a problem.
+ * this is not a problem.  Also, we don't need to specify unwind
+ * information for preserved registers that are not modified in
+ * save_switch_stack as the right unwind information is already
+ * specified at the call-site of save_switch_stack.
  */
=20
 /*
  * save_switch_stack:
  *	- r16 holds ar.pfs
- *	- r28 holds address to return to
+ *	- b7 holds address to return to
  *	- rp (b0) holds return address to save
  */
-	.align 16
-	.global save_switch_stack
-	.proc save_switch_stack
-save_switch_stack:
+GLOBAL_ENTRY(save_switch_stack)
+	UNW(.prologue)
+	UNW(.altrp b7)
 	flushrs			// flush dirty regs to backing store (must be first in insn gro=
up)
 	mov r17=3Dar.unat		// preserve caller's
-	adds r2=3D-IA64_SWITCH_STACK_SIZE+16,sp	// r2 =3D &sw->caller_unat
+	adds r2=16,sp		// r2 =3D &sw->caller_unat
 	;;
 	mov r18=3Dar.fpsr		// preserve fpsr
 	mov ar.rsc=3Dr0		// put RSE in mode: enforced lazy, little endian, pl 0
 	;;
 	mov r19=3Dar.rnat
-	adds r3=3D-IA64_SWITCH_STACK_SIZE+24,sp	// r3 =3D &sw->ar_fpsr
-
-	// Note: the instruction ordering is important here: we can't
-	// store anything to the switch stack before sp is updated
-	// as otherwise an interrupt might overwrite the memory!
-	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
+	adds r3$,sp		// r3 =3D &sw->ar_fpsr
 	;;
+	.savesp ar.unat,SW(CALLER_UNAT)
 	st8 [r2]=3Dr17,16
+	.savesp ar.fpsr,SW(AR_FPSR)
 	st8 [r3]=3Dr18,24
 	;;
+	UNW(.body)
 	stf.spill [r2]=F2,32
 	stf.spill [r3]=F3,32
 	mov r21=B0
@@ -259,16 +248,17 @@
 	st8 [r3]=3Dr21		// save predicate registers
 	mov ar.rsc=3D3		// put RSE back into eager mode, pl 0
 	br.cond.sptk.few b7
-	.endp save_switch_stack
+END(save_switch_stack)
=20
 /*
  * load_switch_stack:
- *	- r28 holds address to return to
+ *	- b7 holds address to return to
  */
-	.align 16
-	.proc load_switch_stack
-load_switch_stack:
+ENTRY(load_switch_stack)
+	UNW(.prologue)
+	UNW(.altrp b7)
 	invala			// invalidate ALAT
+	UNW(.body)
 	adds r2=3DIA64_SWITCH_STACK_B0_OFFSET+16,sp	// get pointer to switch_stac=
k.b0
 	mov ar.rsc=3Dr0		// put RSE into enforced lazy mode
 	adds r3=3DIA64_SWITCH_STACK_B0_OFFSET+24,sp	// get pointer to switch_stac=
k.b1
@@ -360,14 +350,10 @@
 	mov ar.unat=3Dr18				// restore caller's unat
 	mov ar.fpsr=3Dr19				// restore fpsr
 	mov ar.rsc=3D3				// put RSE back into eager mode, pl 0
-	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// pop switch_stack
 	br.cond.sptk.few b7
-	.endp load_switch_stack
+END(load_switch_stack)
=20
-	.align 16
-	.global __ia64_syscall
-	.proc __ia64_syscall
-__ia64_syscall:
+GLOBAL_ENTRY(__ia64_syscall)
 	.regstk 6,0,0,0
 	mov r15=3Din5				// put syscall number in place
 	break __BREAK_SYSCALL
@@ -377,30 +363,30 @@
 (p6)	st4 [r2]=3Dr8
 (p6)	mov r8=3D-1
 	br.ret.sptk.few rp
-	.endp __ia64_syscall
+END(__ia64_syscall)
=20
 	//
 	// We invoke syscall_trace through this intermediate function to
 	// ensure that the syscall input arguments are not clobbered.  We
 	// also use it to preserve b6, which contains the syscall entry point.
 	//
-	.align 16
-	.global invoke_syscall_trace
-	.proc invoke_syscall_trace
-invoke_syscall_trace:
-	alloc loc0=3Dar.pfs,8,3,0,0
+GLOBAL_ENTRY(invoke_syscall_trace)
+	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(8))
+	alloc loc1=3Dar.pfs,8,3,0,0
 	;;			// WAW on CFM at the br.call
-	mov loc1=3Drp
+	mov loc0=3Drp
+	.fframe IA64_SWITCH_STACK_SIZE
+	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp
 	br.call.sptk.many rp=3Dsave_switch_stack_with_current_frame	// must prese=
rve b6!!
 .ret2:	mov loc2=B6
 	br.call.sptk.few rp=3Dsyscall_trace
 .ret3:	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop switch_stack frame
-	mov rp=3Dloc1
-	mov ar.pfs=3Dloc0
+	mov rp=3Dloc0
+	mov ar.pfs=3Dloc1
 	mov b6=3Dloc2
 	;;
 	br.ret.sptk.few rp
-	.endp invoke_syscall_trace
+END(invoke_syscall_trace)
=20
 	//
 	// Invoke a system call, but do some tracing before and after the call.
@@ -414,19 +400,19 @@
 	//
 	.global ia64_trace_syscall
 	.global ia64_strace_leave_kernel
-	.global ia64_strace_clear_r8
=20
-	.proc ia64_strace_clear_r8
-ia64_strace_clear_r8:		// this is where we return after cloning when PF_TR=
ACESYS is on
+GLOBAL_ENTRY(ia64_strace_clear_r8)
+	// this is where we return after cloning when PF_TRACESYS is on
+	PT_REGS_UNWIND_INFO
 # ifdef CONFIG_SMP
 	br.call.sptk.few rp=3Dinvoke_schedule_tail
 # endif
 	mov r8=3D0
 	br strace_check_retval
-	.endp ia64_strace_clear_r8
+END(ia64_strace_clear_r8)
=20
-	.proc ia64_trace_syscall
-ia64_trace_syscall:
+ENTRY(ia64_trace_syscall)
+	PT_REGS_UNWIND_INFO
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
 .ret4:	br.call.sptk.few rp=B6			// do the syscall
 strace_check_retval:
@@ -454,7 +440,7 @@
 (p6)	mov r10=3D-1
 (p6)	mov r8=3Dr9
 	br.cond.sptk.few strace_save_retval
-	.endp ia64_trace_syscall
+END(ia64_trace_syscall)
=20
 /*
  * A couple of convenience macros to help implement/understand the state
@@ -472,12 +458,8 @@
 #define rKRBS		r22
 #define rB6		r21
=20
-	.align 16
-	.global ia64_ret_from_syscall
-	.global ia64_ret_from_syscall_clear_r8
-	.global ia64_leave_kernel
-	.proc ia64_ret_from_syscall
-ia64_ret_from_syscall_clear_r8:
+GLOBAL_ENTRY(ia64_ret_from_syscall_clear_r8)
+	PT_REGS_UNWIND_INFO
 #ifdef CONFIG_SMP
 	// In SMP mode, we need to call schedule_tail to complete the scheduling =
process.
 	// Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
@@ -487,7 +469,10 @@
 #endif                 =20
 	mov r8=3D0
 	;;					// added stop bits to prevent r8 dependency
-ia64_ret_from_syscall:
+END(ia64_ret_from_syscall_clear_r8)
+	// fall through
+GLOBAL_ENTRY(ia64_ret_from_syscall)
+	PT_REGS_UNWIND_INFO
 	cmp.ge p6,p7=3Dr8,r0			// syscall executed successfully?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
 	adds r3=3DIA64_PT_REGS_R8_OFFSET+32,sp	// r3 =3D &pt_regs.r10
@@ -497,19 +482,21 @@
 	.mem.offset 8,0
 (p6)	st8.spill [r3]=3Dr0	// clear error indication in slot for r10 and
