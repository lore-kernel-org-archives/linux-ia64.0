From: David Mosberger <davidm@hpl.hp.com>
Date: Thu, 22 Jun 2000 06:51:45 +0000
Subject: [Linux-ia64] updatd kernel diff (relative to 2.4.0-test1)
Message-Id: <marc-linux-ia64-105590678205170@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Here is an updated kernel diff.

 IMPORTANT NOTICE

	- Per request from Jes, the "stat" structure was changed to
	  make it match with glibc-2.2.  This provides for a more
	  efficient implementation of stat and friends.  However, the
	  new format makes the stat, lstat, and fstat system calls
	  incompatible with current binaries.  Thus, rather than
	  replacing the existing syscalls, we added new versions of
	  them.  The old versions continue to be available (for the
	  time being) as old_stat, old_fstat, and old_lstat.

	  WARNING: If you plan on re-compiling glibc-2.1 with this
	  kernel you MUST update syscalls.list first by applying this
	  patch (WARNING^2: I didn't test this glibc patch, but you
	  get the idea...).

--- sysdeps/unix/sysv/linux/ia64/syscalls.list~	Tue May  9 17:59:12 2000
+++ sysdeps/unix/sysv/linux/ia64/syscalls.list	Mon Jun 19 20:55:36 2000
@@ -72,11 +72,11 @@
 s_getdents	getdents getdents	3	__syscall_getdents	getdents
=20
 # System calls with wrappers.
-sys_fstat	fxstat	fstat		2	__syscall_fstat
-sys_lstat	lxstat	lstat		2	__syscall_lstat
+sys_fstat	fxstat	old_fstat	2	__syscall_fstat
+sys_lstat	lxstat	old_lstat	2	__syscall_lstat
 sys_mknod	xmknod	mknod		3	__syscall_mknod
 sys_readv	readv	readv		3	__syscall_readv
-sys_stat	xstat	stat		2	__syscall_stat
+sys_stat	xstat	old_stat	2	__syscall_stat
 sys_writev	writev	writev		3	__syscall_writev
 s_getpagesize	getpagesize getpagesize	0	__syscall_getpagesize
 s_poll		poll	poll		3	__syscall_poll

OK, having said that, what else's new since last patch:

 - Completed unwind functionality.  I don't think things are final
   yet, but the last missing piece, core-dump support, hs been added
   now, so the new unwind support should now be functionally complete.
   On a kernel panic, you should now get a call trace in addition to
   the register dump.  That's the theory at least, as I haven't been
   able to test it out yet.  There are still some unwind related bugs
   in the toolchain, so I'd recommend not to turn on
   CONFIG_IA64_NEW_UNWIND unless you're willing to live dangerously...

 - Make the Alt DTLB handler work again for speculative faults (they
   always get NaT'ted now).

 - Most of Asit's patch: updates for IA-32 emulation, send_sig_info ->
   force_sig_info fixes, and the SMP ptc.g workaround fix.

 - Goutham's PCI DMA fix.

 - Fix Rules.make so the integer division routines don't get
   recompile all the time.

 - Add missing #include <linux/init.h> to hpsim_irq.c.  This
   should make things build for the HP simulator again.

 - mmap() is now supposed to return EINVAL when attempting to map into
   or across the address space hole in the middle of the region (also
   untested so far).

I tested this patch (with kdb patch applied) on a 4-way Lion, 1-way
Big Sur and the HP simulator.  Some known problems:

 - "make -j" seems to reliably lock up the kernel (the system doesn't
   freeze, you can still get into kdb, but the processes don't seem
   to be making forward progress anymore)

 - there are still occasionaly random user-level deaths (usually in
   the compiler); anyone who finds a half-way reproducible test case:
   please let me know (I'm currently working with the gcc test case
   that Richard found, but a simpler test-case would be very helpful)

As usual, the patch can be found at:

 ftp://ftp.kernel.org/pub/linux/kernel/ports/ia64

Look for file linux-2.4.0-test1-ia64-000621.diff*

Enjoy,

	--david

diff -urN linux-davidm/Rules.make linux-2.4.0-test1-lia/Rules.make
--- linux-davidm/Rules.make	Thu Mar 30 16:56:04 2000
+++ linux-2.4.0-test1-lia/Rules.make	Wed Jun 21 16:23:36 2000
@@ -291,9 +291,12 @@
 	))
=20
 # A kludge: .S files don't get flag dependencies (yet),
-#   because that will involve changing a lot of Makefiles.
+#   because that will involve changing a lot of Makefiles.  Also
+#   suppress object files explicitly listed in $(IGNORE_FLAGS_OBJS).
+#   This allows handling of assembly files that get translated into
+#   multiple object files (see arch/ia64/lib/idiv.S, for example).
 FILES_FLAGS_CHANGED :=3D $(strip \
-    $(filter-out $(patsubst %.S, %.o, $(wildcard *.S)), \
+    $(filter-out $(patsubst %.S, %.o, $(wildcard *.S) $(IGNORE_FLAGS_OBJS)=
), \
     $(FILES_FLAGS_CHANGED)))
=20
 ifneq ($(FILES_FLAGS_CHANGED),)
diff -urN linux-davidm/arch/ia64/hp/hpsim_irq.c linux-2.4.0-test1-lia/arch/=
ia64/hp/hpsim_irq.c
--- linux-davidm/arch/ia64/hp/hpsim_irq.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/hp/hpsim_irq.c	Wed Jun 21 16:23:54 2000
@@ -5,6 +5,7 @@
  * Copyright (C) 1998-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
=20
+#include <linux/init.h>
 #include <linux/kernel.h>
 #include <linux/sched.h>
 #include <linux/irq.h>
diff -urN linux-davidm/arch/ia64/ia32/binfmt_elf32.c linux-2.4.0-test1-lia/=
arch/ia64/ia32/binfmt_elf32.c
--- linux-davidm/arch/ia64/ia32/binfmt_elf32.c	Fri Apr 21 15:21:23 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/binfmt_elf32.c	Wed Jun 21 16:24:10=
 2000
@@ -2,6 +2,8 @@
  * IA-32 ELF support.
  *
  * Copyright (C) 1999 Arun Sharma <arun.sharma@intel.com>
+ *
+ * 06/16/00	A. Mallick	initialize csd/ssd/tssd/cflg for ia32_load_state
  */
 #include <linux/config.h>
 #include <linux/posix_types.h>
@@ -84,6 +86,15 @@
=20
 	current->thread.map_base =3D 0x40000000;
=20
+=20
+	/* setup ia32 state for ia32_load_state */
+
+	current->thread.eflag =3D IA32_EFLAG;
+	current->thread.csd =3D IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0xBL, 1L, 3L, 1=
L, 1L, 1L);
+	current->thread.ssd =3D IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0x3L, 1L, 3L, 1=
L, 1L, 1L);
+	current->thread.tssd =3D IA64_SEG_DESCRIPTOR(IA32_PAGE_OFFSET + PAGE_SIZE=
, 0x1FFFL, 0xBL,
+						   1L, 3L, 1L, 1L, 1L);
+
 	/* CS descriptor */
 	__asm__("mov ar.csd =3D %0" : /* no outputs */
 		: "r" IA64_SEG_DESCRIPTOR(0L, 0xFFFFFL, 0xBL, 1L,
@@ -96,9 +107,6 @@
 	__asm__("mov ar.eflag =3D %0" : /* no outputs */ : "r" (IA32_EFLAG));
=20
 	/* Control registers */
-	__asm__("mov ar.cflg =3D %0"
-		: /* no outputs */
-		: "r" (((ulong) IA32_CR4 << 32) | IA32_CR0));
 	__asm__("mov ar.fsr =3D %0"
 		: /* no outputs */
 		: "r" ((ulong)IA32_FSR_DEFAULT));
diff -urN linux-davidm/arch/ia64/ia32/ia32_entry.S linux-2.4.0-test1-lia/ar=
ch/ia64/ia32/ia32_entry.S
--- linux-davidm/arch/ia64/ia32/ia32_entry.S	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/ia32_entry.S	Wed Jun 21 16:24:27 2=
000
@@ -41,7 +41,7 @@
 	.previous
=20
 GLOBAL_ENTRY(ia32_ret_from_syscall)
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
=20
 	cmp.ge p6,p7=3Dr8,r0                      // syscall executed successfull=
y?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp    // r2 =3D &pt_regs.r8
@@ -61,7 +61,7 @@
 	//	b6  =3D syscall entry point
 	//
 GLOBAL_ENTRY(ia32_trace_syscall)
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
 .Lret4:	br.call.sptk.few rp=B6			// do the syscall
 .Lret5:	cmp.lt p6,p0=3Dr8,r0			// syscall failed?
diff -urN linux-davidm/arch/ia64/ia32/ia32_signal.c linux-2.4.0-test1-lia/a=
rch/ia64/ia32/ia32_signal.c
--- linux-davidm/arch/ia64/ia32/ia32_signal.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/ia32_signal.c	Wed Jun 21 16:24:46 =
2000
@@ -104,6 +104,7 @@
                 struct pt_regs *regs, unsigned long mask)
 {
        int  err =3D 0;
+       unsigned long flag;
=20
        err |=3D __put_user((regs->r16 >> 32) & 0xffff , (unsigned int *)&s=
c->fs);
        err |=3D __put_user((regs->r16 >> 48) & 0xffff , (unsigned int *)&s=
c->gs);
@@ -124,9 +125,11 @@
 #endif
        err |=3D __put_user(regs->cr_iip, &sc->eip);
        err |=3D __put_user(regs->r17 & 0xffff, (unsigned int *)&sc->cs);
-#if 0
-       err |=3D __put_user(regs->eflags, &sc->eflags);
-#endif
+       /*
+	*  `eflags' is in an ar register for this context
+	*/
+       asm volatile ("mov %0=3Dar.eflag ;;" : "=3Dr"(flag));
+       err |=3D __put_user((unsigned int)flag, &sc->eflags);
       =20
        err |=3D __put_user(regs->r12, &sc->esp_at_signal);
        err |=3D __put_user((regs->r17 >> 16) & 0xffff, (unsigned int *)&sc=
->ss);
@@ -190,15 +193,26 @@
        COPY(cr_iip, eip);
        COPY_SEG_STRICT(cs);
        COPY_SEG_STRICT(ss);
-#if 0
        {
-               unsigned int tmpflags;
-               err |=3D __get_user(tmpflags, &sc->eflags);
-               /* XXX: Change this to ar.eflags */
-               regs->eflags =3D (regs->eflags & ~0x40DD5) | (tmpflags & 0x=
40DD5);
-               regs->orig_eax =3D -1;            /* disable syscall checks=
 */
+		unsigned int tmpflags;
+		unsigned long flag;
+
+		/*
+		 *  IA32 `eflags' is not part of `pt_regs', it's
+		 *  in an ar register which is part of the thread
+		 *  context.  Fortunately, we are executing in the
+		 *  IA32 process's context.
+		 */
+		err |=3D __get_user(tmpflags, &sc->eflags);
+		asm volatile ("mov %0=3Dar.eflag ;;" : "=3Dr"(flag));
+		flag &=3D ~0x40DD5;
+		flag |=3D (tmpflags & 0x40DD5);
+		asm volatile ("mov ar.eflag=3D%0 ;;" :: "r"(flag));
+
+		regs->r1 =3D -1;	/* disable syscall checks, r1 is orig_eax */
        }
=20
+#if 0
        {
                struct _fpstate * buf;
                err |=3D __get_user(buf, &sc->fpstate);
diff -urN linux-davidm/arch/ia64/ia32/ia32_support.c linux-2.4.0-test1-lia/=
arch/ia64/ia32/ia32_support.c
--- linux-davidm/arch/ia64/ia32/ia32_support.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/ia32_support.c	Wed Jun 21 16:25:02=
 2000
@@ -1,6 +1,9 @@
 /*
  * IA32 helper functions
+ *
+ * 06/16/00	A. Mallick	added csd/ssd/tssd for ia32 thread context
  */
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/mm.h>
@@ -19,38 +22,52 @@
 void
 ia32_save_state (struct thread_struct *thread)
 {
-	unsigned long eflag, fsr, fcr, fir, fdr;
+	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
=20
 	asm ("mov %0=3Dar.eflag;"
 	     "mov %1=3Dar.fsr;"
 	     "mov %2=3Dar.fcr;"
 	     "mov %3=3Dar.fir;"
-	     "mov %4=3Dar.fdr"
-	     : "=3Dr"(eflag), "=3Dr"(fsr), "=3Dr"(fcr), "=3Dr"(fir), "=3Dr"(fdr));
+	     "mov %4=3Dar.fdr;"
+	     "mov %5=3Dar.csd;"
+	     "mov %6=3Dar.ssd;"
+	     "mov %7=3Dar.k1"
+	     : "=3Dr"(eflag), "=3Dr"(fsr), "=3Dr"(fcr), "=3Dr"(fir), "=3Dr"(fdr),
+	       "=3Dr"(csd), "=3Dr"(ssd), "=3Dr"(tssd));
 	thread->eflag =3D eflag;
 	thread->fsr =3D fsr;
 	thread->fcr =3D fcr;
 	thread->fir =3D fir;
 	thread->fdr =3D fdr;
+	thread->csd =3D csd;
+	thread->ssd =3D ssd;
+	thread->tssd =3D tssd;
 }
=20
 void
 ia32_load_state (struct thread_struct *thread)
 {
-	unsigned long eflag, fsr, fcr, fir, fdr;
+	unsigned long eflag, fsr, fcr, fir, fdr, csd, ssd, tssd;
=20
 	eflag =3D thread->eflag;
 	fsr =3D thread->fsr;
 	fcr =3D thread->fcr;
 	fir =3D thread->fir;
 	fdr =3D thread->fdr;
+	csd =3D thread->csd;
+	ssd =3D thread->ssd;
+	tssd =3D thread->tssd;
=20
 	asm volatile ("mov ar.eflag=3D%0;"
 		      "mov ar.fsr=3D%1;"
 		      "mov ar.fcr=3D%2;"
 		      "mov ar.fir=3D%3;"
-		      "mov ar.fdr=3D%4"
-		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr));
+		      "mov ar.fdr=3D%4;"
+		      "mov ar.csd=3D%5;"
+		      "mov ar.ssd=3D%6;"
+		      "mov ar.k1=3D%7"
+		      :: "r"(eflag), "r"(fsr), "r"(fcr), "r"(fir), "r"(fdr),
+		         "r"(csd), "r"(ssd), "r"(tssd));
 }
=20
 /*
diff -urN linux-davidm/arch/ia64/ia32/ia32_traps.c linux-2.4.0-test1-lia/ar=
ch/ia64/ia32/ia32_traps.c
--- linux-davidm/arch/ia64/ia32/ia32_traps.c	Fri Apr 21 15:21:23 2000
+++ linux-2.4.0-test1-lia/arch/ia64/ia32/ia32_traps.c	Wed Jun 21 16:25:14 2=
000
@@ -1,3 +1,9 @@
+/*
+ * IA32 exceptions handler
+ *
+ * 06/16/00	A. Mallick	added siginfo for most cases (close to IA32)
+ */
+
 #include <linux/kernel.h>
 #include <linux/sched.h>
=20
@@ -9,9 +15,11 @@
 {
 	struct siginfo siginfo;
=20
+	siginfo.si_errno =3D 0;
 	switch ((isr >> 16) & 0xff) {
 	      case 1:
 	      case 2:
+		siginfo.si_signo =3D SIGTRAP;
 		if (isr =3D 0)
 			siginfo.si_code =3D TRAP_TRACE;
 		else if (isr & 0x4)
@@ -21,27 +29,96 @@
 		break;
=20
 	      case 3:
+		siginfo.si_signo =3D SIGTRAP;
 		siginfo.si_code =3D TRAP_BRKPT;
 		break;
=20
 	      case 0:	/* Divide fault */
+		siginfo.si_signo =3D SIGFPE;
+		siginfo.si_code =3D FPE_INTDIV;
+		break;
+
 	      case 4:	/* Overflow */
 	      case 5:	/* Bounds fault */
+		siginfo.si_signo =3D SIGFPE;
+		siginfo.si_code =3D 0;
+		break;
+
 	      case 6:	/* Invalid Op-code */
+		siginfo.si_signo =3D SIGILL;
+		siginfo.si_code =3D ILL_ILLOPN;
+		break;
+
 	      case 7:	/* FP DNA */
 	      case 8:	/* Double Fault */
 	      case 9:	/* Invalid TSS */
 	      case 11:	/* Segment not present */
 	      case 12:	/* Stack fault */
 	      case 13:	/* General Protection Fault */
+		siginfo.si_signo =3D SIGSEGV;
+		siginfo.si_code =3D 0;
+		break;
+
 	      case 16:	/* Pending FP error */
+		{
+			unsigned long fsr, fcr;
+
+			asm ("mov %0=3Dar.fsr;"
+			     "mov %1=3Dar.fcr;"
+			     : "=3Dr"(fsr), "=3Dr"(fcr));
+
+			siginfo.si_signo =3D SIGFPE;
+			/*
+			 * (~cwd & swd) will mask out exceptions that are not set to unmasked
+			 * status.  0x3f is the exception bits in these regs, 0x200 is the
+			 * C1 reg you need in case of a stack fault, 0x040 is the stack
+			 * fault bit.  We should only be taking one exception at a time,
+			 * so if this combination doesn't produce any single exception,
+			 * then we have a bad program that isn't syncronizing its FPU usage
+			 * and it will suffer the consequences since we won't be able to
+			 * fully reproduce the context of the exception
+			 */
+			switch(((~fcr) & (fsr & 0x3f)) | (fsr & 0x240)) {
+				case 0x000:
+				default:
+					siginfo.si_code =3D 0;
+					break;
+				case 0x001: /* Invalid Op */
+				case 0x040: /* Stack Fault */
+				case 0x240: /* Stack Fault | Direction */
+					siginfo.si_code =3D FPE_FLTINV;
+					break;
+				case 0x002: /* Denormalize */
+				case 0x010: /* Underflow */
+					siginfo.si_code =3D FPE_FLTUND;
+					break;
+				case 0x004: /* Zero Divide */
+					siginfo.si_code =3D FPE_FLTDIV;
+					break;
+				case 0x008: /* Overflow */
+					siginfo.si_code =3D FPE_FLTOVF;
+					break;
+				case 0x020: /* Precision */
+					siginfo.si_code =3D FPE_FLTRES;
+					break;
+			}
+
+			break;
+		}
+
 	      case 17:	/* Alignment check */
+		siginfo.si_signo =3D SIGSEGV;
+		siginfo.si_code =3D BUS_ADRALN;
+		break;
+
 	      case 19:	/* SSE Numeric error */
+		siginfo.si_signo =3D SIGFPE;
+		siginfo.si_code =3D 0;
+		break;
+
 	      default:
 		return -1;
 	}
-	siginfo.si_signo =3D SIGTRAP;
-	siginfo.si_errno =3D 0;
-	send_sig_info(SIGTRAP, &siginfo, current);
+	force_sig_info(SIGTRAP, &siginfo, current);
 	return 0;
 }
diff -urN linux-davidm/arch/ia64/kernel/efi.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/efi.c
--- linux-davidm/arch/ia64/kernel/efi.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/efi.c	Wed Jun 21 16:27:14 2000
@@ -14,6 +14,9 @@
  * in a future version.  --drummond 1999-07-20
  *
  * Implemented EFI runtime services and virtual mode calls.  --davidm
+ *
+ * Goutham Rao: <goutham.rao@intel.com>
+ * 	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/kernel.h>
 #include <linux/init.h>
@@ -170,6 +173,14 @@
 				printk("Warning: ignoring %luMB of memory above 1GB!\n",
 				       md->num_pages >> 8);
 				md->type =3D EFI_UNUSABLE_MEMORY;
+				continue;
+			}
+
+			if (!(md->attribute & EFI_MEMORY_WB))
+				continue;
+			if (md->num_pages =3D 0) {
+				printk("efi_memmap_walk: ignoring empty region at 0x%lx",
+				       md->phys_addr);
 				continue;
 			}
=20
diff -urN linux-davidm/arch/ia64/kernel/entry.S linux-2.4.0-test1-lia/arch/=
ia64/kernel/entry.S
--- linux-davidm/arch/ia64/kernel/entry.S	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/entry.S	Wed Jun 21 21:41:21 2000
@@ -413,7 +413,7 @@
=20
 GLOBAL_ENTRY(ia64_strace_clear_r8)
 	// this is where we return after cloning when PF_TRACESYS is on
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 # ifdef CONFIG_SMP
 	br.call.sptk.few rp=3Dinvoke_schedule_tail
 # endif
@@ -422,7 +422,7 @@
 END(ia64_strace_clear_r8)
=20
 ENTRY(ia64_trace_syscall)
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	br.call.sptk.few rp=3Dinvoke_syscall_trace // give parent a chance to cat=
ch syscall args
 .ret4:	br.call.sptk.few rp=B6			// do the syscall
 strace_check_retval:
@@ -469,7 +469,7 @@
 #define rB6		r21
=20
 GLOBAL_ENTRY(ia64_ret_from_syscall_clear_r8)
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 #ifdef CONFIG_SMP
 	// In SMP mode, we need to call schedule_tail to complete the scheduling =
process.
 	// Called by ia64_switch_to after do_fork()->copy_thread().  r8 contains =
the
@@ -482,7 +482,7 @@
 END(ia64_ret_from_syscall_clear_r8)
 	// fall through
 GLOBAL_ENTRY(ia64_ret_from_syscall)
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	cmp.ge p6,p7=3Dr8,r0			// syscall executed successfully?
 	adds r2=3DIA64_PT_REGS_R8_OFFSET+16,sp	// r2 =3D &pt_regs.r8
 	adds r3=3DIA64_PT_REGS_R8_OFFSET+32,sp	// r3 =3D &pt_regs.r10
@@ -497,7 +497,7 @@
 GLOBAL_ENTRY(ia64_leave_kernel)
 	// check & deliver software interrupts:
=20
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 #ifdef CONFIG_SMP
 	adds r2=3DIA64_TASK_PROCESSOR_OFFSET,r13
 	movl r3=3Dsoftirq_state
@@ -721,7 +721,7 @@
 	 * If pt_regs.r8 is zero, we assume that the call completed
 	 * successfully.
 	 */
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	ld8 r3=3D[r2]		// load pt_regs.r8
 	sub r9=3D0,r8		// negate return value to get errno
 	;;
@@ -819,7 +819,6 @@
 	alloc loc1=3Dar.pfs,8,2,3,0 // preserve all eight input regs in case of s=
yscall restart!
 	mov r9=3Dar.unat
 	mov loc0=3Drp				// save return address
-	.body
 	mov out0=3D0				// there is no "oldset"
 	adds out1=3D0,sp				// out1=3D&sigscratch
 (pSys)	mov out2=3D1				// out2=3D1 =3D> we're in a syscall
@@ -828,6 +827,7 @@
 	.fframe 16
 	.spillpsp ar.unat, 16			// (note that offset is relative to psp+0x10!)
 	st8 [sp]=3Dr9,-16				// allocate space for ar.unat and save it
+	.body
 	br.call.sptk.few rp=3Dia64_do_signal
 .ret11:
 	.restore sp
@@ -903,7 +903,7 @@
 ENTRY(sys_rt_sigreturn)
 #ifdef CONFIG_IA64_NEW_UNWIND
 	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	.prologue
 	PT_REGS_SAVES(16)
 	adds sp=3D-16,sp
@@ -914,7 +914,7 @@
 	br.call.sptk.few rp=3Dia64_rt_sigreturn
 .ret13:
 	adds sp=16,sp		// doesn't drop pt_regs, so don't mark it as restoring sp!
-	PT_REGS_UNWIND_INFO	// instead, create a new body section with the smalle=
r frame
+	PT_REGS_UNWIND_INFO(0)	// instead, create a new body section with the sma=
ller frame
 	;;
 	ld8 r9=3D[sp]				// load new ar.unat
 	mov b7=3Dr8
@@ -923,7 +923,7 @@
 	br b7
 #else /* !CONFIG_IA64_NEW_UNWIND */
 	.regstk 0,0,3,0	// inherited from gate.s:invoke_sighandler()
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	UNW(.prologue)
 	UNW(.fframe IA64_PT_REGS_SIZE+IA64_SWITCH_STACK_SIZE)
 	UNW(.spillsp rp, PT(CR_IIP)+IA64_SWITCH_STACK_SIZE)
@@ -943,7 +943,7 @@
 	ld8 r9=3D[r3]			// load new ar.unat
 	mov b7=3Dr8
 	;;
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	adds sp=3DIA64_SWITCH_STACK_SIZE,sp	// drop (dummy) switch-stack frame
 	mov ar.unat=3Dr9
 	br b7
@@ -955,15 +955,64 @@
 	// r16 =3D fake ar.pfs, we simply need to make sure=20
 	// privilege is still 0
 	//
-	PT_REGS_UNWIND_INFO
+	PT_REGS_UNWIND_INFO(0)
 	mov r16=3Dr0 			=09
 	DO_SAVE_SWITCH_STACK
 	br.call.sptk.few rp=3Dia64_handle_unaligned // stack frame setup in ivt
 .ret14:
-	DO_LOAD_SWITCH_STACK(PT_REGS_UNWIND_INFO)
+	DO_LOAD_SWITCH_STACK(PT_REGS_UNWIND_INFO(0))
 	br.cond.sptk.many rp			  // goes to ia64_leave_kernel
 END(ia64_prepare_handle_unaligned)
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+
+	//
+	// unw_init_running(void (*callback)(info, arg), void *arg)
+	//
+#	define EXTRA_FRAME_SIZE	((UNW_FRAME_INFO_SIZE+15)&~15)
+
+GLOBAL_ENTRY(unw_init_running)
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	alloc loc1=3Dar.pfs,2,3,3,0
+	;;
+	ld8 loc2=3D[in0],8
+	mov loc0=3Drp
+	mov r16=3Dloc1
+	DO_SAVE_SWITCH_STACK
+	.body
+
+	.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(2)
+	.fframe IA64_SWITCH_STACK_SIZE+EXTRA_FRAME_SIZE
+	SWITCH_STACK_SAVES(EXTRA_FRAME_SIZE)
+	adds sp=3D-EXTRA_FRAME_SIZE,sp
+	.body
+	;;
+	adds out0=16,sp				// &info
+	mov out1=3Dr13				// current
+	adds out2=16+EXTRA_FRAME_SIZE,sp	// &switch_stack
+	br.call.sptk.few rp=3Dunw_init_frame_info
+1:	adds out0=16,sp				// &info
+	mov b6=3Dloc2
+	mov loc2=3Dgp				// save gp across indirect function call
+	;;
+	ld8 gp=3D[in0]
+	mov out1=3Din1				// arg
+	br.call.sptk.few rp=B6			// invoke the callback function
+1:	mov gp=3Dloc2				// restore gp
+
+	// For now, we don't allow changing registers from within
+	// unw_init_running; if we ever want to allow that, we'd
+	// have to do a load_switch_stack here:
+	.restore sp
+	adds sp=3DIA64_SWITCH_STACK_SIZE+EXTRA_FRAME_SIZE,sp
+
+	mov ar.pfs=3Dloc1
+	mov rp=3Dloc0
+	br.ret.sptk.many rp
+END(unw_init_running)
+
+#endif
+
 	.rodata
 	.align 8
 	.globl sys_call_table
@@ -1064,9 +1113,9 @@
 	data8 sys_syslog
 	data8 sys_setitimer
 	data8 sys_getitimer
-	data8 sys_newstat			// 1120
-	data8 sys_newlstat
-	data8 sys_newfstat
+	data8 ia64_oldstat			// 1120
+	data8 ia64_oldlstat
+	data8 ia64_oldfstat
 	data8 sys_vhangup
 	data8 sys_lchown
 	data8 sys_vm86				// 1125
@@ -1154,9 +1203,9 @@
 	data8 sys_pivot_root
 	data8 sys_mincore
 	data8 sys_madvise
-	data8 ia64_ni_syscall			// 1210
-	data8 ia64_ni_syscall
-	data8 ia64_ni_syscall
+	data8 sys_newstat			// 1210
+	data8 sys_newlstat
+	data8 sys_newfstat
 	data8 ia64_ni_syscall
 	data8 ia64_ni_syscall
 	data8 ia64_ni_syscall			// 1215
diff -urN linux-davidm/arch/ia64/kernel/entry.h linux-2.4.0-test1-lia/arch/=
ia64/kernel/entry.h
--- linux-davidm/arch/ia64/kernel/entry.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/entry.h	Wed Jun 21 21:41:45 2000
@@ -9,37 +9,41 @@
 #define PT(f)		(IA64_PT_REGS_##f##_OFFSET + 16)
 #define SW(f)		(IA64_SWITCH_STACK_##f##_OFFSET + 16)
=20
-#define PT_REGS_UNWIND_INFO			\
+#define PT_REGS_SAVES(off)				\
+	UNW(.unwabi @svr4, 'i');			\
+	UNW(.fframe IA64_PT_REGS_SIZE+16+(off));	\
+	UNW(.spillsp rp, PT(CR_IIP)+(off));		\
+	UNW(.spillsp ar.pfs, PT(CR_IFS)+(off));		\
+	UNW(.spillsp ar.unat, PT(AR_UNAT)+(off));	\
+	UNW(.spillsp ar.fpsr, PT(AR_FPSR)+(off));	\
+	UNW(.spillsp pr, PT(PR)+(off));
+
+#define PT_REGS_UNWIND_INFO(off)		\
 	UNW(.prologue);				\
-	UNW(.unwabi @svr4, 'i');		\
-	UNW(.fframe IA64_PT_REGS_SIZE+16);	\
-	UNW(.spillsp rp, PT(CR_IIP));		\
-	UNW(.spillsp ar.pfs, PT(CR_IFS));	\
-	UNW(.spillsp ar.unat, PT(AR_UNAT));	\
-	UNW(.spillsp pr, PT(PR));		\
+	PT_REGS_SAVES(off);			\
 	UNW(.body)
=20
-#define SAVE_SWITCH_STACK_UNWIND_INFO							\
-	.savesp ar.unat,SW(CALLER_UNAT); .savesp ar.fpsr,SW(AR_FPSR));			\
-	UNW(.spillsp f2,SW(F2)); UNW(.spillsp f3,SW(F3));				\
-	UNW(.spillsp f4,SW(F4)); UNW(.spillsp f5,SW(F5));				\
-	UNW(.spillsp f16,SW(F16)); UNW(.spillsp f17,SW(F17));				\
-	UNW(.spillsp f18,SW(F18)); UNW(.spillsp f19,SW(F19));				\
-	UNW(.spillsp f20,SW(F20)); UNW(.spillsp f21,SW(F21));				\
-	UNW(.spillsp f22,SW(F22)); UNW(.spillsp f23,SW(F23));				\
-	UNW(.spillsp f24,SW(F24)); UNW(.spillsp f25,SW(F25));				\
-	UNW(.spillsp f26,SW(F26)); UNW(.spillsp f27,SW(F27));				\
-	UNW(.spillsp f28,SW(F28)); UNW(.spillsp f29,SW(F29));				\
-	UNW(.spillsp f30,SW(F30)); UNW(.spillsp f31,SW(F31));				\
-	UNW(.spillsp r4,SW(R4)); UNW(.spillsp r5,SW(R5));				\
-	UNW(.spillsp r6,SW(R6)); UNW(.spillsp r7,SW(R7));				\
-	UNW(.spillsp b1,SW(B1)); UNW(.spillsp b2,SW(B2));				\
-	UNW(.spillsp b3,SW(B3)); UNW(.spillsp b4,SW(B4));				\
-	UNW(.spillsp b5,SW(B5));							\
-	UNW(.spillsp ar.pfs,SW(AR_PFS)); UNW(.spillsp ar.lc,SW(AR_LC));			\
-	UNW(.spillsp @priunat,SW(AR_UNAT));						\
-	UNW(.spillsp ar.rnat,SW(AR_RNAT)); UNW(.spillsp ar.bspstore,SW(AR_BSPSTOR=
E));	\
-	UNW(.spillsp pr,SW(PR))
+#define SWITCH_STACK_SAVES(off)									  \
+	UNW(.savesp ar.unat,SW(CALLER_UNAT)+(off)); UNW(.savesp ar.fpsr,SW(AR_FPS=
R)+(off));	  \
+	UNW(.spillsp f2,SW(F2)+(off)); UNW(.spillsp f3,SW(F3)+(off));				  \
+	UNW(.spillsp f4,SW(F4)+(off)); UNW(.spillsp f5,SW(F5)+(off));				  \
+	UNW(.spillsp f16,SW(F16)+(off)); UNW(.spillsp f17,SW(F17)+(off));			  \
+	UNW(.spillsp f18,SW(F18)+(off)); UNW(.spillsp f19,SW(F19)+(off));			  \
+	UNW(.spillsp f20,SW(F20)+(off)); UNW(.spillsp f21,SW(F21)+(off));			  \
+	UNW(.spillsp f22,SW(F22)+(off)); UNW(.spillsp f23,SW(F23)+(off));			  \
+	UNW(.spillsp f24,SW(F24)+(off)); UNW(.spillsp f25,SW(F25)+(off));			  \
+	UNW(.spillsp f26,SW(F26)+(off)); UNW(.spillsp f27,SW(F27)+(off));			  \
+	UNW(.spillsp f28,SW(F28)+(off)); UNW(.spillsp f29,SW(F29)+(off));			  \
+	UNW(.spillsp f30,SW(F30)+(off)); UNW(.spillsp f31,SW(F31)+(off));			  \
+	UNW(.spillsp r4,SW(R4)+(off)); UNW(.spillsp r5,SW(R5)+(off));				  \
+	UNW(.spillsp r6,SW(R6)+(off)); UNW(.spillsp r7,SW(R7)+(off));				  \
+	UNW(.spillsp b0,SW(B0)+(off)); UNW(.spillsp b1,SW(B1)+(off));				  \
+	UNW(.spillsp b2,SW(B2)+(off)); UNW(.spillsp b3,SW(B3)+(off));				  \
+	UNW(.spillsp b4,SW(B4)+(off)); UNW(.spillsp b5,SW(B5)+(off));				  \
+	UNW(.spillsp ar.pfs,SW(AR_PFS)+(off)); UNW(.spillsp ar.lc,SW(AR_LC)+(off)=
);		  \
+	UNW(.spillsp @priunat,SW(AR_UNAT)+(off));						  \
+	UNW(.spillsp ar.rnat,SW(AR_RNAT)+(off)); UNW(.spillsp ar.bspstore,SW(AR_B=
SPSTORE)+(off)); \
+	UNW(.spillsp pr,SW(PR)+(off))
=20
 #define DO_SAVE_SWITCH_STACK			\
 	movl r28=1F;				\
@@ -47,7 +51,7 @@
 	.fframe IA64_SWITCH_STACK_SIZE;		\
 	adds sp=3D-IA64_SWITCH_STACK_SIZE,sp;	\
 	mov b7=3Dr28;				\
-	SAVE_SWITCH_STACK_UNWIND_INFO;		\
+	SWITCH_STACK_SAVES(0);			\
 	br.cond.sptk.many save_switch_stack;	\
 1:
=20
diff -urN linux-davidm/arch/ia64/kernel/head.S linux-2.4.0-test1-lia/arch/i=
a64/kernel/head.S
--- linux-davidm/arch/ia64/kernel/head.S	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/head.S	Wed Jun 21 21:41:55 2000
@@ -60,7 +60,7 @@
 	UNW(.prologue)
 	UNW(.save rp, r4)		// terminate unwind chain with a NULL rp
 	UNW(mov r4=3Dr0)
-	.body
+	UNW(.body)
 	// set IVT entry point---can't access I/O ports without it
 	movl r3=3Dia64_ivt
 	;;
diff -urN linux-davidm/arch/ia64/kernel/irq.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/irq.c
--- linux-davidm/arch/ia64/kernel/irq.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/irq.c	Wed Jun 21 21:42:11 2000
@@ -201,10 +201,14 @@
 		printk(" %d",local_bh_count(i));
=20
 	printk(" ]\nStack dumps:");
-#ifdef __ia64__
-	printk(" ]\nStack dumps: <unimplemented on IA-64---please fix me>");
-	/* for now we don't have stack dumping support... */
-#elif __i386__
+#if defined(__ia64__)
+	/*
+	 * We can't unwind the stack of another CPU without access to
+	 * the registers of that CPU.  And sending an IPI when we're
+	 * in a potentially wedged state doesn't sound like a smart
+	 * idea.
+	 */
+#elif defined(__i386__)
 	for(i=3D0;i< smp_num_cpus;i++) {
 		unsigned long esp;
 		if(i=3Dcpu)
@@ -227,9 +231,7 @@
 	You lose...
 #endif
 	printk("\nCPU %d:",cpu);
-#ifdef __i386__
 	show_stack(NULL);
-#endif
 	printk("\n");
 }
 =09
diff -urN linux-davidm/arch/ia64/kernel/ivt.S linux-2.4.0-test1-lia/arch/ia=
64/kernel/ivt.S
--- linux-davidm/arch/ia64/kernel/ivt.S	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/ivt.S	Wed Jun 21 21:55:57 2000
@@ -339,6 +339,7 @@
 	shr.u r18=3Dr16,57	// move address bit 61 to bit 4
 	dep r16=3D0,r16,IA64_MAX_PHYS_BITS,(64-IA64_MAX_PHYS_BITS) // clear ed & =
reserved bits
 	;;
+	dep r21=3D-1,r21,IA64_PSR_ED_BIT,1
 	andcm r18=3D0x10,r18	// bit 4=3D~address-bit(61)
 	dep r16=3Dr17,r16,0,12	// insert PTE control bits into r16
 	;;
diff -urN linux-davidm/arch/ia64/kernel/pal.S linux-2.4.0-test1-lia/arch/ia=
64/kernel/pal.S
--- linux-davidm/arch/ia64/kernel/pal.S	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/pal.S	Wed Jun 21 21:42:38 2000
@@ -59,31 +59,31 @@
  */
 GLOBAL_ENTRY(ia64_pal_call_static)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6))
-	alloc	loc1 =3D ar.pfs,6,90,0,0
-	movl	loc2 =3D pal_entry_point
+	alloc loc1 =3D ar.pfs,6,90,0,0
+	movl loc2 =3D pal_entry_point
 1:	{
-	  mov	r28 =3D in0
-	  mov	r29 =3D in1
-	  mov	r8 =3D ip
+	  mov r28 =3D in0
+	  mov r29 =3D in1
+	  mov r8 =3D ip
 	}
 	;;
-	ld8	loc2 =3D [loc2]		// loc2 <- entry point
-	mov	r30 =3D in2
-	mov	r31 =3D in3
-	;;
-	mov	loc3 =3D psr
-	mov	loc0 =3D rp
-	.body
-	adds	r8 =3D .ret0-1b,r8
+	ld8 loc2 =3D [loc2]		// loc2 <- entry point
+	mov r30 =3D in2
+	mov r31 =3D in3
+	;;
+	mov loc3 =3D psr
+	mov loc0 =3D rp
+	UNW(.body)
+	adds r8 =3D .ret0-1b,r8
 	;;=20
-	rsm	psr.i
-	mov	b7 =3D loc2
-	mov	rp =3D r8
+	rsm psr.i
+	mov b7 =3D loc2
+	mov rp =3D r8
 	;;=20
 	br.cond.sptk.few b7
-.ret0:	mov	psr.l =3D loc3
-	mov	ar.pfs =3D loc1
-	mov	rp =3D loc0
+.ret0:	mov psr.l =3D loc3
+	mov ar.pfs =3D loc1
+	mov rp =3D loc0
 	;;
 	srlz.d				// seralize restoration of psr.l
 	br.ret.sptk.few	b0
@@ -98,28 +98,28 @@
  */
 GLOBAL_ENTRY(ia64_pal_call_stacked)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(5))
-	alloc	loc1 =3D ar.pfs,5,4,87,0
-	movl	loc2 =3D pal_entry_point
+	alloc loc1 =3D ar.pfs,5,4,87,0
+	movl loc2 =3D pal_entry_point
=20
-	mov	r28  =3D in0		// Index MUST be copied to r28
-	mov	out0 =3D in0		// AND in0 of PAL function
-	mov	loc0 =3D rp
-	.body
-	;;
-	ld8	loc2 =3D [loc2]		// loc2 <- entry point
-	mov	out1 =3D in1
-	mov	out2 =3D in2
-	mov	out3 =3D in3
-	mov	loc3 =3D psr
+	mov r28  =3D in0			// Index MUST be copied to r28
+	mov out0 =3D in0			// AND in0 of PAL function
+	mov loc0 =3D rp
+	UNW(.body)
+	;;
+	ld8 loc2 =3D [loc2]		// loc2 <- entry point
+	mov out1 =3D in1
+	mov out2 =3D in2
+	mov out3 =3D in3
+	mov loc3 =3D psr
 	;;
-	rsm	psr.i
-	mov	b7 =3D loc2
+	rsm psr.i
+	mov b7 =3D loc2
 	;;=20
 	br.call.sptk.many rp=B7		// now make the call
 .ret2:
-	mov	psr.l  =3D loc3
-	mov	ar.pfs =3D loc1
-	mov	rp =3D loc0
+	mov psr.l  =3D loc3
+	mov ar.pfs =3D loc1
+	mov rp =3D loc0
 	;;
 	srlz.d				// serialize restoration of psr.l
 	br.ret.sptk.few	b0
@@ -140,28 +140,28 @@
 	 IA64_PSR_DD | IA64_PSR_SS | IA64_PSR_RI | IA64_PSR_ED |	\
 	 IA64_PSR_DFL | IA64_PSR_DFH)
=20
-#define PAL_PSR_BITS_TO_SET							\
+#define PAL_PSR_BITS_TO_SET						\
 	(IA64_PSR_BN)
=20
=20
 GLOBAL_ENTRY(ia64_pal_call_phys_static)
 	UNW(.prologue ASM_UNW_PRLG_RP|ASM_UNW_PRLG_PFS, ASM_UNW_PRLG_GRSAVE(6))
-	alloc	loc1 =3D ar.pfs,6,90,0,0
-	movl	loc2 =3D pal_entry_point
+	alloc loc1 =3D ar.pfs,6,90,0,0
+	movl loc2 =3D pal_entry_point
 1:	{
-	  mov	r28  =3D in0		// copy procedure index
-	  mov	r8   =3D ip		// save ip to compute branch
-	  mov	loc0 =3D rp		// save rp
+	  mov r28  =3D in0		// copy procedure index
+	  mov r8   =3D ip			// save ip to compute branch
+	  mov loc0 =3D rp			// save rp
 	}
-	.body
+	UNW(.body)
 	;;
-	ld8	loc2 =3D [loc2]		// loc2 <- entry point
-	mov	r29  =3D in1		// first argument
-	mov	r30  =3D in2		// copy arg2
-	mov	r31  =3D in3		// copy arg3
+	ld8 loc2 =3D [loc2]		// loc2 <- entry point
+	mov r29  =3D in1			// first argument
+	mov r30  =3D in2			// copy arg2
+	mov r31  =3D in3			// copy arg3
 	;;
-	mov	loc3 =3D psr		// save psr
-	adds	r8   =3D .ret4-1b,r8	// calculate return address for call
+	mov loc3 =3D psr			// save psr
+	adds r8   =3D .ret4-1b,r8		// calculate return address for call
 	;;=20
 	mov loc4=3Dar.rsc			// save RSE configuration
 	dep.z loc2=3Dloc2,0,61		// convert pal entry point to physical
@@ -184,10 +184,10 @@
 	mov r16=3Dloc3			// r16=3D original psr
 	br.call.sptk.few rp=3Dia64_switch_mode // return to virtual mode
=20
-.ret5:	mov	psr.l =3D loc3		// restore init PSR
+.ret5:	mov psr.l =3D loc3		// restore init PSR
=20
-	mov	ar.pfs =3D loc1
-	mov	rp =3D loc0
+	mov ar.pfs =3D loc1
+	mov rp =3D loc0
 	;;
 	mov ar.rsc=3Dloc4			// restore RSE configuration
 	srlz.d				// seralize restoration of psr.l
diff -urN linux-davidm/arch/ia64/kernel/pci-dma.c linux-2.4.0-test1-lia/arc=
h/ia64/kernel/pci-dma.c
--- linux-davidm/arch/ia64/kernel/pci-dma.c	Mon Feb 14 15:34:21 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/pci-dma.c	Wed Jun 21 21:42:48 20=
00
@@ -23,8 +23,8 @@
 	void *ret;
 	int gfp =3D GFP_ATOMIC;
=20
-	if (!hwdev || hwdev->dma_mask !=3D 0xffffffff)
-		gfp |=3D GFP_DMA;
+	if (!hwdev || hwdev->dma_mask =3D 0xffffffff)
+		gfp |=3D GFP_DMA;	/* XXX fix me: should change this to GFP_32BIT or ZONE=
_32BIT */
 	ret =3D (void *)__get_free_pages(gfp, get_order(size));
=20
 	if (ret) {
diff -urN linux-davidm/arch/ia64/kernel/pci.c linux-2.4.0-test1-lia/arch/ia=
64/kernel/pci.c
--- linux-davidm/arch/ia64/kernel/pci.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/pci.c	Wed Jun 21 21:42:54 2000
@@ -133,7 +133,7 @@
  * Initialization. Uses the SAL interface
  */
=20
-#define PCI_BUSSES_TO_SCAN 255
+#define PCI_BUSES_TO_SCAN 255
=20
 void __init=20
 pcibios_init(void)
@@ -147,7 +147,7 @@
 	}
=20
 	printk("PCI: Probing PCI hardware\n");
-	for (i =3D 0; i < PCI_BUSSES_TO_SCAN; i++)=20
+	for (i =3D 0; i < PCI_BUSES_TO_SCAN; i++)=20
 		pci_scan_bus(i, ops, NULL);
 	platform_pci_fixup();
 	return;
diff -urN linux-davidm/arch/ia64/kernel/process.c linux-2.4.0-test1-lia/arc=
h/ia64/kernel/process.c
--- linux-davidm/arch/ia64/kernel/process.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/process.c	Wed Jun 21 21:56:11 20=
00
@@ -23,8 +23,40 @@
 #include <asm/processor.h>
 #include <asm/sal.h>
 #include <asm/uaccess.h>
+#include <asm/unwind.h>
 #include <asm/user.h>
=20
+static void
+do_show_stack (struct unw_frame_info *info, void *arg)
+{
+	unsigned long ip, sp, bsp;
+
+	printk("\nCall Trace: ");
+	do {
+		unw_get_ip(info, &ip);
+		if (ip =3D 0)
+			break;
+
+		unw_get_sp(info, &sp);
+		unw_get_bsp(info, &bsp);
+		printk("[<%016lx>] sp=3D0x%016lx bsp=3D0x%016lx\n", ip, sp, bsp);
+	} while (unw_unwind(info) >=3D 0);
+}
+
+void
+show_stack (struct task_struct *task)
+{
+#ifdef CONFIG_IA64_NEW_UNWIND
+	if (!task)
+		unw_init_running(do_show_stack, 0);
+	else {
+		struct unw_frame_info info;
+
+		unw_init_from_blocked_task(&info, task);
+		do_show_stack(&info, 0);
+	}
+#endif
+}
=20
 void
 show_regs (struct pt_regs *regs)
@@ -71,6 +103,10 @@
 			       ((i =3D sof - 1) || (i % 3) =3D 2) ? "\n" : " ");
 		}
 	}
+#ifdef CONFIG_IA64_NEW_UNWIND
+	if (!user_mode(regs))
+		show_stack(0);
+#endif
 }
=20
 void __attribute__((noreturn))
@@ -104,7 +140,7 @@
=20
 			itc =3D ia64_get_itc();
 			itm =3D ia64_get_itm();
-			if (time_after(itc, itm)) {
+			if (time_after(itc, itm + 1000)) {
 				extern void ia64_reset_itm (void);
=20
 				printk("cpu_idle: ITM in past (itc=3D%lx,itm=3D%lx:%lums)\n",
@@ -267,9 +303,103 @@
 	return 0;
 }
=20
+#ifdef CONFIG_IA64_NEW_UNWIND
+
+void
+do_copy_regs (struct unw_frame_info *info, void *arg)
+{
+	unsigned long ar_bsp, ndirty, *krbs, addr, mask, sp, nat_bits =3D 0, ip;
+	elf_greg_t *dst =3D arg;
+	struct pt_regs *pt;
+	char nat;
+	long val;
+	int i;
+
+	memset(dst, 0, sizeof(elf_gregset_t));	/* don't leak any kernel bits to u=
ser-level */
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	unw_get_sp(info, &sp);
+	pt =3D (struct pt_regs *) (sp + 16);
+
+	krbs =3D (unsigned long *) current + IA64_RBS_OFFSET/8;
+	ndirty =3D ia64_rse_num_regs(krbs, krbs + (pt->loadrs >> 19));
+	ar_bsp =3D (unsigned long) ia64_rse_skip_regs((long *) pt->ar_bspstore, n=
dirty);
+
+	/*
+	 * Write portion of RSE backing store living on the kernel
+	 * stack to the VM of the process.
+	 */
+	for (addr =3D pt->ar_bspstore; addr < ar_bsp; addr +=3D 8)
+		if (ia64_peek(pt, current, addr, &val) =3D 0)
+			access_process_vm(current, addr, &val, sizeof(val), 1);
+
+	/* r0 is zero */
+	for (i =3D 1, mask =3D (1UL << i); i < 32; ++i) {
+		unw_get_gr(info, i, &dst[i], &nat);
+		if (nat)
+			nat_bits |=3D mask;
+		mask <<=3D 1;
+	}
+	dst[32] =3D nat_bits;
+	unw_get_pr(info, &dst[33]);
+
+	for (i =3D 0; i < 8; ++i)
+		unw_get_br(info, i, &dst[34 + i]);
+
+	unw_get_rp(info, &ip);
+	dst[42] =3D ip + ia64_psr(pt)->ri;
+	dst[43] =3D pt->cr_ifs & 0x3fffffffff;
+	dst[44] =3D pt->cr_ipsr & IA64_PSR_UM;
+
+	unw_get_ar(info, UNW_AR_RSC, &dst[45]);
+	/*
+	 * For bsp and bspstore, unw_get_ar() would return the kernel
+	 * addresses, but we need the user-level addresses instead:
+	 */
+	dst[46] =3D ar_bsp;
+	dst[47] =3D pt->ar_bspstore;
+	unw_get_ar(info, UNW_AR_RNAT, &dst[48]);
+	unw_get_ar(info, UNW_AR_CCV, &dst[49]);
+	unw_get_ar(info, UNW_AR_UNAT, &dst[50]);
+	unw_get_ar(info, UNW_AR_FPSR, &dst[51]);
+	dst[52] =3D pt->ar_pfs;	/* UNW_AR_PFS is =3D to pt->cr_ifs for interrupt =
frames */
+	unw_get_ar(info, UNW_AR_LC, &dst[53]);
+	unw_get_ar(info, UNW_AR_EC, &dst[54]);
+}
+
+void
+do_dump_fpu (struct unw_frame_info *info, void *arg)
+{
+	struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
+	elf_fpreg_t *dst =3D arg;
+	int i;
+
+	memset(dst, 0, sizeof(elf_fpregset_t));	/* don't leak any "random" bits */
+
+	if (unw_unwind_to_user(info) < 0)
+		return;
+
+	/* f0 is 0.0, f1 is 1.0 */
+
+	for (i =3D 2; i < 32; ++i)
+		unw_get_fr(info, i, dst + i);
+
+	if ((fpu_owner =3D current) || (current->thread.flags & IA64_THREAD_FPH_V=
ALID)) {
+		ia64_sync_fph(current);
+		memcpy(dst + 32, current->thread.fph, 96*16);
+	}
+}
+
+#endif /* CONFIG_IA64_NEW_UNWIND */
+
 void
 ia64_elf_core_copy_regs (struct pt_regs *pt, elf_gregset_t dst)
 {
+#ifdef CONFIG_IA64_NEW_UNWIND
+	unw_init_running(do_copy_regs, dst);
+#else
 	struct switch_stack *sw =3D ((struct switch_stack *) pt) - 1;
 	unsigned long ar_ec, cfm, ar_bsp, ndirty, *krbs, addr;
=20
@@ -303,7 +433,7 @@
 	 *	ar.rsc ar.bsp ar.bspstore ar.rnat
 	 *	ar.ccv ar.unat ar.fpsr ar.pfs ar.lc ar.ec
 	 */
-	memset(dst, 0, sizeof (dst));	/* don't leak any "random" bits */
+	memset(dst, 0, sizeof(dst));	/* don't leak any "random" bits */
=20
 	/* r0 is zero */   dst[ 1] =3D  pt->r1; dst[ 2] =3D  pt->r2; dst[ 3] =3D =
pt->r3;
 	dst[ 4] =3D  sw->r4; dst[ 5] =3D  sw->r5; dst[ 6] =3D  sw->r6; dst[ 7] =
=3D sw->r7;
@@ -311,36 +441,32 @@
 	dst[12] =3D pt->r12; dst[13] =3D pt->r13; dst[14] =3D pt->r14; dst[15] =
=3D pt->r15;
 	memcpy(dst + 16, &pt->r16, 16*8);	/* r16-r31 are contiguous */
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-	printk("ia64_elf_core_copy_regs: fix me, please?");
-	dst[32] =3D 0;
-#else
 	dst[32] =3D ia64_get_nat_bits(pt, sw);
-#endif
 	dst[33] =3D pt->pr;
=20
 	/* branch regs: */
 	dst[34] =3D pt->b0; dst[35] =3D sw->b1; dst[36] =3D sw->b2; dst[37] =3D s=
w->b3;
 	dst[38] =3D sw->b4; dst[39] =3D sw->b5; dst[40] =3D pt->b6; dst[41] =3D p=
t->b7;
=20
-	dst[42] =3D pt->cr_iip; dst[43] =3D pt->cr_ifs;
-	dst[44] =3D pt->cr_ipsr;	/* XXX perhaps we should filter out some bits he=
re? --davidm */
+	dst[42] =3D pt->cr_iip + ia64_psr(pt)->ri;
+	dst[43] =3D pt->cr_ifs;
+	dst[44] =3D pt->cr_ipsr & IA64_PSR_UM;
=20
 	dst[45] =3D pt->ar_rsc; dst[46] =3D ar_bsp; dst[47] =3D pt->ar_bspstore; =
 dst[48] =3D pt->ar_rnat;
 	dst[49] =3D pt->ar_ccv; dst[50] =3D pt->ar_unat; dst[51] =3D sw->ar_fpsr;=
 dst[52] =3D pt->ar_pfs;
 	dst[53] =3D sw->ar_lc; dst[54] =3D (sw->ar_pfs >> 52) & 0x3f;
+#endif /* !CONFIG_IA64_NEW_UNWIND */
 }
=20
 int
 dump_fpu (struct pt_regs *pt, elf_fpregset_t dst)
 {
+#ifdef CONFIG_IA64_NEW_UNWIND
+	unw_init_running(do_dump_fpu, dst);
+#else
 	struct switch_stack *sw =3D ((struct switch_stack *) pt) - 1;
 	struct task_struct *fpu_owner =3D ia64_get_fpu_owner();
=20
-#ifdef CONFIG_IA64_NEW_UNWIND
-	printk("dump_fpu: fix me, please?");
-#endif
-
 	memset(dst, 0, sizeof (dst));	/* don't leak any "random" bits */
=20
 	/* f0 is 0.0 */  /* f1 is 1.0 */  dst[2] =3D sw->f2; dst[3] =3D sw->f3;
@@ -354,6 +480,7 @@
 		}
 		memcpy(dst + 32, current->thread.fph, 96*16);
 	}
+#endif
 	return 1;	/* f0-f31 are always valid so we always return 1 */
 }
=20
diff -urN linux-davidm/arch/ia64/kernel/ptrace.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/ptrace.c
--- linux-davidm/arch/ia64/kernel/ptrace.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/ptrace.c	Wed Jun 21 21:43:40 2000
@@ -29,8 +29,10 @@
  *	id (instruction debug fault disable; one bit)
  *	dd (data debug fault disable; one bit)
  *	ri (restart instruction; two bits)
+ *	is (instruction set; one bit)
  */
-#define IPSR_WRITE_MASK	0x000006a00100003eUL
+#define IPSR_WRITE_MASK \
+	(IA64_PSR_UM | IA64_PSR_DB | IA64_PSR_IS | IA64_PSR_ID | IA64_PSR_DD | IA=
64_PSR_RI)
 #define IPSR_READ_MASK	IPSR_WRITE_MASK
=20
 #ifdef CONFIG_IA64_NEW_UNWIND
@@ -44,26 +46,6 @@
 # define dprintk(format...)
 #endif
=20
-static int
-unwind_to_user (struct unw_frame_info *info, struct task_struct *child)
-{
-	unsigned long ip;
-
-	unw_init_from_blocked_task(info, child);
-	while (unw_unwind(info) >=3D 0) {
-		if (unw_get_rp(info, &ip) < 0) {
-			unw_get_ip(info, &ip);
-			dprintk("ptrace: failed to read return pointer (ip=3D0x%lx)\n", ip);
-			return -1;
-		}
-		if (ip < TASK_SIZE)
-			return 0;
-	}
-	unw_get_ip(info, &ip);
-	dprintk("ptrace: failed to unwind to user-level (ip=3D0x%lx)\n", ip);
-	return -1;
-}
-
 /*
  * Collect the NaT bits for r1-r31 from scratch_unat and return a NaT
  * bitset where bit i is set iff the NaT bit of register i is set.
@@ -488,7 +470,8 @@
 	struct unw_frame_info info;
 	unsigned long cfm, sof;
=20
-	if (unwind_to_user(&info, child) < 0)
+	unw_init_from_blocked_task(&info, child);
+	if (unw_unwind_to_user(&info) < 0)
 		return -1;
=20
 	unw_get_bsp(&info, (unsigned long *) &kbspstore);
@@ -561,10 +544,11 @@
 /*
  * Ensure the state in child->thread.fph is up-to-date.
  */
-static void
-sync_fph (struct task_struct *child)
+void
+ia64_sync_fph (struct task_struct *child)
 {
 	if (ia64_psr(ia64_task_regs(child))->mfh && ia64_get_fpu_owner() =3D chil=
d) {
+		ia64_set_fpu_owner(0);
 		ia64_save_fpu(&child->thread.fph[0]);
 		child->thread.flags |=3D IA64_THREAD_FPH_VALID;
 	}
@@ -614,7 +598,7 @@
=20
 	if (addr < PT_F127 + 16) {
 		/* accessing fph */
-		sync_fph(child);
+		ia64_sync_fph(child);
 		ptr =3D (unsigned long *) ((unsigned long) &child->thread.fph + addr);
 	} else if (addr >=3D PT_F10 && addr < PT_F15 + 16) {
 		/* scratch registers untouched by kernel (saved in switch_stack) */
@@ -626,7 +610,8 @@
 		char nat =3D 0;
 		int ret;
=20
-		if (unwind_to_user(&info, child) < 0)
+		unw_init_from_blocked_task(&info, child);
+		if (unw_unwind_to_user(&info) < 0)
 			return -1;
=20
 		switch (addr) {
@@ -706,7 +691,8 @@
 					struct unw_frame_info info;
 					unsigned long cfm;
=20
-					if (unwind_to_user(&info, child) < 0)
+					unw_init_from_blocked_task(&info, child);
+					if (unw_unwind_to_user(&info) < 0)
 						return -1;
=20
 					unw_get_cfm(&info, &cfm);
@@ -727,7 +713,8 @@
 				/* kernel was entered through a system call */
 				unsigned long cfm;
=20
-				if (unwind_to_user(&info, child) < 0)
+				unw_init_from_blocked_task(&info, child);
+				if (unw_unwind_to_user(&info) < 0)
 					return -1;
=20
 				unw_get_cfm(&info, &cfm);
@@ -814,7 +801,7 @@
=20
 	if (addr < PT_F127+16) {
 		/* accessing fph */
-		sync_fph(child);
+		ia64_sync_fph(child);
 		ptr =3D (unsigned long *) ((unsigned long) &child->thread.fph + addr);
 	} else if (addr < PT_F9+16) {
 		/* accessing switch_stack or pt_regs: */
diff -urN linux-davidm/arch/ia64/kernel/setup.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/setup.c
--- linux-davidm/arch/ia64/kernel/setup.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/setup.c	Wed Jun 21 21:44:17 2000
@@ -28,6 +28,7 @@
 #include <linux/console.h>
=20
 #include <asm/acpi-ext.h>
+#include <asm/ia32.h>
 #include <asm/page.h>
 #include <asm/machvec.h>
 #include <asm/processor.h>
@@ -361,6 +362,13 @@
=20
 	ia64_rid_init();
 	ia64_tlb_init();
+
+#ifdef	CONFIG_IA32_SUPPORT
+	/* initialize global ia32 state - CR0 and CR4 */
+	__asm__("mov ar.cflg =3D %0"
+		: /* no outputs */
+		: "r" (((ulong) IA32_CR4 << 32) | IA32_CR0));
+#endif
=20
 #ifdef CONFIG_SMP
 	normal_xtp();
diff -urN linux-davidm/arch/ia64/kernel/sys_ia64.c linux-2.4.0-test1-lia/ar=
ch/ia64/kernel/sys_ia64.c
--- linux-davidm/arch/ia64/kernel/sys_ia64.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/sys_ia64.c	Wed Jun 21 21:44:56 2=
000
@@ -14,6 +14,9 @@
 #include <linux/file.h>		/* doh, must come after sched.h... */
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
+#include <linux/highuid.h>
+
+#include <asm/uaccess.h>
=20
 asmlinkage long
 ia64_getpriority (int which, int who, long arg2, long arg3, long arg4, lon=
g arg5, long arg6,=20
@@ -94,7 +97,11 @@
 static inline unsigned long
 do_mmap2 (unsigned long addr, unsigned long len, int prot, int flags, int =
fd, unsigned long pgoff)
 {
+	long start_low, end_low, starting_region, ending_region;
+	unsigned long loff, hoff;
 	struct file *file =3D 0;
+	/* the virtual address space that is mappable in each region: */
+#	define OCTANT_SIZE	((PTRS_PER_PGD<<PGDIR_SHIFT)/8)
=20
 	/*
 	 * A zero mmap always succeeds in Linux, independent of
@@ -103,15 +110,19 @@
 	if (PAGE_ALIGN(len) =3D 0)
 		return addr;
=20
-#ifdef notyet
-	/* Don't permit mappings that would cross a region boundary: */
-	region_start =3D IA64_GET_REGION(addr);
-	region_end   =3D IA64_GET_REGION(addr + len);
-	if (region_start !=3D region_end)
+	/* Don't permit mappings into or across the address hole in a region: */
+	loff =3D REGION_OFFSET(addr);
+	hoff =3D loff - (REGION_SIZE - OCTANT_SIZE/2);
+	if ((len | loff | (loff + len)) >=3D OCTANT_SIZE/2
+	    && (len | hoff | (hoff + len)) >=3D OCTANT_SIZE/2)
 		return -EINVAL;
=20
-	<<x??x>>
-#endif
+	/* Don't permit mappings that would cross a region boundary: */
+
+	starting_region =3D REGION_NUMBER(addr);
+	ending_region   =3D REGION_NUMBER(addr + len);
+	if (starting_region !=3D ending_region)
+		return -EINVAL;
=20
 	flags &=3D ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	if (!(flags & MAP_ANONYMOUS)) {
@@ -212,6 +223,136 @@
 		regs->r8 =3D 0;	/* ensure large addresses are not mistaken as failures..=
. */
 	return addr;
 }
+
+#if 1
+/*
+ * This is here for a while to keep compatibillity with the old stat()
+ * call - it will be removed later once everybody migrates to the new
+ * kernel stat structure that matches the glibc one - Jes
+ */
+static __inline__ int
+do_revalidate (struct dentry *dentry)
+{
+	struct inode * inode =3D dentry->d_inode;
+	if (inode->i_op && inode->i_op->revalidate)
+		return inode->i_op->revalidate(dentry);
+	return 0;
+}
+
+static int
+cp_ia64_old_stat (struct inode *inode, struct ia64_oldstat *statbuf)
+{
+	struct ia64_oldstat tmp;
+	unsigned int blocks, indirect;
+
+	memset(&tmp, 0, sizeof(tmp));
+	tmp.st_dev =3D kdev_t_to_nr(inode->i_dev);
+	tmp.st_ino =3D inode->i_ino;
+	tmp.st_mode =3D inode->i_mode;
+	tmp.st_nlink =3D inode->i_nlink;
+	SET_STAT_UID(tmp, inode->i_uid);
+	SET_STAT_GID(tmp, inode->i_gid);
+	tmp.st_rdev =3D kdev_t_to_nr(inode->i_rdev);
+	tmp.st_size =3D inode->i_size;
+	tmp.st_atime =3D inode->i_atime;
+	tmp.st_mtime =3D inode->i_mtime;
+	tmp.st_ctime =3D inode->i_ctime;
+/*
+ * st_blocks and st_blksize are approximated with a simple algorithm if
+ * they aren't supported directly by the filesystem. The minix and msdos
+ * filesystems don't keep track of blocks, so they would either have to
+ * be counted explicitly (by delving into the file itself), or by using
+ * this simple algorithm to get a reasonable (although not 100% accurate)
+ * value.
+ */
+
+/*
+ * Use minix fs values for the number of direct and indirect blocks.  The
+ * count is now exact for the minix fs except that it counts zero blocks.
+ * Everything is in units of BLOCK_SIZE until the assignment to
+ * tmp.st_blksize.
+ */
+#define D_B   7
+#define I_B   (BLOCK_SIZE / sizeof(unsigned short))
+
+	if (!inode->i_blksize) {
+		blocks =3D (tmp.st_size + BLOCK_SIZE - 1) / BLOCK_SIZE;
+		if (blocks > D_B) {
+			indirect =3D (blocks - D_B + I_B - 1) / I_B;
+			blocks +=3D indirect;
+			if (indirect > 1) {
+				indirect =3D (indirect - 1 + I_B - 1) / I_B;
+				blocks +=3D indirect;
+				if (indirect > 1)
+					blocks++;
+			}
+		}
+		tmp.st_blocks =3D (BLOCK_SIZE / 512) * blocks;
+		tmp.st_blksize =3D BLOCK_SIZE;
+	} else {
+		tmp.st_blocks =3D inode->i_blocks;
+		tmp.st_blksize =3D inode->i_blksize;
+	}
+	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
+}
+
+asmlinkage long
+ia64_oldstat (char *filename, struct ia64_oldstat *statbuf)
+{
+	struct nameidata nd;
+	int error;
+
+	lock_kernel();
+	error =3D user_path_walk(filename, &nd);
+	if (!error) {
+		error =3D do_revalidate(nd.dentry);
+		if (!error)
+		error =3D cp_ia64_old_stat(nd.dentry->d_inode, statbuf);
+		path_release(&nd);
+	}
+	unlock_kernel();
+	return error;
+}
+
+
+asmlinkage long
+ia64_oldlstat (char *filename, struct ia64_oldstat *statbuf) {
+	struct nameidata nd;
+	int error;
+
+	lock_kernel();
+	error =3D user_path_walk_link(filename, &nd);
+	if (!error) {
+		error =3D do_revalidate(nd.dentry);
+		if (!error)
+			error =3D cp_ia64_old_stat(nd.dentry->d_inode, statbuf);
+		path_release(&nd);
+	}
+	unlock_kernel();
+	return error;
+}
+
+asmlinkage long
+ia64_oldfstat (unsigned int fd, struct ia64_oldstat *statbuf)
+{
+	struct file * f;
+	int err =3D -EBADF;
+
+	lock_kernel();
+	f =3D fget(fd);
+	if (f) {
+		struct dentry * dentry =3D f->f_dentry;
+
+		err =3D do_revalidate(dentry);
+		if (!err)
+			err =3D cp_ia64_old_stat(dentry->d_inode, statbuf);
+		fput(f);
+	}
+	unlock_kernel();
+	return err;
+}
+=20
+#endif
=20
 #ifndef CONFIG_PCI
=20
diff -urN linux-davidm/arch/ia64/kernel/traps.c linux-2.4.0-test1-lia/arch/=
ia64/kernel/traps.c
--- linux-davidm/arch/ia64/kernel/traps.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/traps.c	Wed Jun 21 21:45:23 2000
@@ -172,7 +172,7 @@
 	siginfo.si_signo =3D sig;
 	siginfo.si_errno =3D 0;
 	siginfo.si_code =3D code;
-	send_sig_info(sig, &siginfo, current);
+	force_sig_info(sig, &siginfo, current);
 }
=20
 /*
@@ -337,7 +337,7 @@
 				siginfo.si_code =3D FPE_FLTDIV;
 			}
 			siginfo.si_isr =3D isr;
-			send_sig_info(SIGFPE, &siginfo, current);
+			force_sig_info(SIGFPE, &siginfo, current);
 		}
 	} else {
 		if (exception =3D -1) {
@@ -357,7 +357,7 @@
 				siginfo.si_code =3D FPE_FLTRES;
 			}
 			siginfo.si_isr =3D isr;
-			send_sig_info(SIGFPE, &siginfo, current);
+			force_sig_info(SIGFPE, &siginfo, current);
 		}
 	}
 	return 0;
diff -urN linux-davidm/arch/ia64/kernel/unaligned.c linux-2.4.0-test1-lia/a=
rch/ia64/kernel/unaligned.c
--- linux-davidm/arch/ia64/kernel/unaligned.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unaligned.c	Wed Jun 21 21:45:50 =
2000
@@ -460,32 +460,15 @@
 	 * enabled.
 	 *
 	 * The registers [32-127] are ususally saved in the tss. When get here,
-	 * they are NECESSARY live because they are only saved explicitely.
+	 * they are NECESSARILY live because they are only saved explicitely.
 	 * We have 3 ways of updating the values: force a save of the range
 	 * in tss, use a gigantic switch/case statement or generate code on the
 	 * fly to store to the right register.
 	 * For now, we are using the (slow) save/restore way.
 	 */
  	if (regnum >=3D IA64_FIRST_ROTATING_FR) {
-		/*
-		 * force a save of [32-127] to tss
-		 * we use the __() form to avoid fiddling with the dfh bit
-		 */
-		__ia64_save_fpu(&current->thread.fph[0]);
-
+		ia64_sync_fph(current);
 		current->thread.fph[IA64_FPH_OFFS(regnum)] =3D *fpval;
-
-		__ia64_load_fpu(&current->thread.fph[0]);
-
-		/*
-	 	 * mark the high partition as being used now
-		 *
-		 * This is REQUIRED because the disabled_fph_fault() does
-		 * not set it, it's relying on the faulting instruction to
-		 * do it. In our case the faulty instruction never gets executed
-		 * completely, so we need to toggle the bit.
-	 	 */
-		regs->cr_ipsr |=3D IA64_PSR_MFH;
 	} else {
 		/*
 		 * pt_regs or switch_stack ?
@@ -544,15 +527,8 @@
 	 * See discussion in setfpreg() for reasons and other ways of doing this.
 	 */
  	if (regnum >=3D IA64_FIRST_ROTATING_FR) {
-=09
-		/*
-		 * force a save of [32-127] to tss
-		 * we use the__ia64_save_fpu() form to avoid fiddling with
-		 * the dfh bit.
-		 */
-		__ia64_save_fpu(&current->thread.fph[0]);
-
-		*fpval =3D  current->thread.fph[IA64_FPH_OFFS(regnum)];
+		ia64_sync_fph(current);
+		*fpval =3D current->thread.fph[IA64_FPH_OFFS(regnum)];
 	} else {
 		/*
 		 * f0 =3D 0.0, f1=3D 1.0. Those registers are constant and are thus
@@ -1425,7 +1401,7 @@
 		si.si_errno =3D 0;
 		si.si_code =3D BUS_ADRALN;
 		si.si_addr =3D (void *) ifa;
-		send_sig_info(SIGBUS, &si, current);
+		force_sig_info(SIGBUS, &si, current);
 		return;
 	}
=20
@@ -1436,7 +1412,7 @@
 		si.si_errno =3D 0;
 		si.si_code =3D BUS_ADRALN;
 		si.si_addr =3D (void *) ifa;
-		send_sig_info(SIGBUS, &si, current);
+		force_sig_info(SIGBUS, &si, current);
 		return;
 	}
=20
diff -urN linux-davidm/arch/ia64/kernel/unwind.c linux-2.4.0-test1-lia/arch=
/ia64/kernel/unwind.c
--- linux-davidm/arch/ia64/kernel/unwind.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/kernel/unwind.c	Wed Jun 21 21:43:19 2000
@@ -3,6 +3,18 @@
  * Copyright (C) 1999-2000 David Mosberger-Tang <davidm@hpl.hp.com>
  */
 /*
+ * This file implements call frame unwind support for the Linux
+ * kernel.  Parsing and processing the unwind information is
+ * time-consuming, so this implementation translates the the unwind
+ * descriptors into unwind scripts.  These scripts are very simple
+ * (basically a sequence of assignments) and efficient to execute.
+ * They are cached for later re-use.  Each script is specific for a
+ * given instruction pointer address and the set of predicate values
+ * that the script depends on (most unwind descriptors are
+ * unconditional and scripts often do not depend on predicates at
+ * all).  This code is based on the unwind conventions described in
+ * the "IA-64 Software Conventions and Runtime Architecture" manual.
+ *
  * SMP conventions:
  *	o updates to the global unwind data (in structure "unw") are serialized
  *	  by the unw.lock spinlock
@@ -22,6 +34,7 @@
 #ifdef CONFIG_IA64_NEW_UNWIND
=20
 #include <asm/delay.h>
+#include <asm/page.h>
 #include <asm/ptrace.h>
 #include <asm/ptrace_offsets.h>
 #include <asm/rse.h>
@@ -74,19 +87,30 @@
 #define struct_offset(str,fld)	((char *)&((str *)NULL)->fld - (char *) 0)
=20
 static struct {
+	spinlock_t lock;			/* spinlock for unwind data */
+
+	/* list of unwind tables (one per load-module) */
 	struct unw_table *tables;
=20
+	/* table of registers that prologues can save (and order in which they're=
 saved): */
 	const unsigned char save_order[8];
-	/* Maps a preserved register index (preg_index) to corresponding switch_s=
tack offset: */
+
+	/* maps a preserved register index (preg_index) to corresponding switch_s=
tack offset: */
 	unsigned short sw_off[sizeof(struct unw_frame_info) / 8];
=20
-	unsigned short lru_head;
-	unsigned short lru_tail;
+	unsigned short lru_head;		/* index of lead-recently used script */
+	unsigned short lru_tail;		/* index of most-recently used script */
+
+	/* index into unw_frame_info for preserved register i */
 	unsigned short preg_index[UNW_NUM_REGS];
+
+	/* unwind table for the kernel: */
 	struct unw_table kernel_table;
=20
-	spinlock_t lock;
+	/* hash table that maps instruction pointer to script index: */
 	unw_hash_index_t hash[UNW_HASH_SIZE];
+
+	/* script cache: */
 	struct unw_script cache[UNW_CACHE_SIZE];
=20
 # if UNW_DEBUG
@@ -228,8 +252,8 @@
 					break;
=20
 				      case UNW_NAT_SCRATCH:
-					if (info->unat)
-						nat_addr =3D info->unat;
+					if (info->pri_unat)
+						nat_addr =3D info->pri_unat;
 					else
 						nat_addr =3D &info->sw->caller_unat;
 				      case UNW_NAT_PRI_UNAT:
@@ -241,7 +265,7 @@
 					if ((unsigned long) addr < info->regstk.limit
 					    || (unsigned long) addr >=3D info->regstk.top)
 					{
-						dprintk("unwind: %lx outside of regstk "
+						dprintk("unwind: 0x%p outside of regstk "
 							"[0x%lx-0x%lx)\n", addr,
 							info->regstk.limit, info->regstk.top);
 						return -1;
@@ -258,7 +282,10 @@
 			}
 		} else {
 			/* access a scratch register */
-			pt =3D (struct pt_regs *) info->sp - 1;
+			if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
+				pt =3D (struct pt_regs *) info->psp - 1;
+			else
+				pt =3D (struct pt_regs *) info->sp - 1;
 			if (regnum <=3D 3)
 				addr =3D &pt->r1 + (regnum - 1);
 			else if (regnum <=3D 11)
@@ -267,8 +294,8 @@
 				addr =3D &pt->r12 + (regnum - 12);
 			else
 				addr =3D &pt->r16 + (regnum - 16);
-			if (info->unat)
-				nat_addr =3D info->unat;
+			if (info->pri_unat)
+				nat_addr =3D info->pri_unat;
 			else
 				nat_addr =3D &info->sw->caller_unat;
 			nat_mask =3D (1UL << ((long) addr & 0x1f8)/8);
@@ -304,7 +331,10 @@
 	unsigned long *addr;
 	struct pt_regs *pt;
=20
-	pt =3D (struct pt_regs *) info->sp - 1;
+	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
+		pt =3D (struct pt_regs *) info->psp - 1;
+	else
+		pt =3D (struct pt_regs *) info->sp - 1;
 	switch (regnum) {
 		/* scratch: */
 	      case 0: addr =3D &pt->b0; break;
@@ -335,12 +365,15 @@
 	struct ia64_fpreg *addr =3D 0;
 	struct pt_regs *pt;
=20
-	if ((unsigned) (regnum - 2) >=3D 30) {
+	if ((unsigned) (regnum - 2) >=3D 126) {
 		dprintk("unwind: trying to access non-existent f%u\n", regnum);
 		return -1;
 	}
=20
-	pt =3D (struct pt_regs *) info->sp - 1;
+	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
+		pt =3D (struct pt_regs *) info->psp - 1;
+	else
+		pt =3D (struct pt_regs *) info->sp - 1;
=20
 	if (regnum <=3D 5) {
 		addr =3D *(&info->f2 + (regnum - 2));
@@ -352,9 +385,14 @@
 		else
 			addr =3D &info->sw->f10 + (regnum - 10);
 	} else if (regnum <=3D 31) {
-		addr =3D *(&info->fr[regnum - 16]);
+		addr =3D info->fr[regnum - 16];
 		if (!addr)
 			addr =3D &info->sw->f16 + (regnum - 16);
+	} else {
+		struct task_struct *t =3D info->task;
+
+		ia64_sync_fph(t);
+		addr =3D t->thread.fph + (regnum - 32);
 	}
=20
 	if (write)
@@ -370,7 +408,10 @@
 	unsigned long *addr;
 	struct pt_regs *pt;
=20
-	pt =3D (struct pt_regs *) info->sp - 1;
+	if (info->flags & UNW_FLAG_INTERRUPT_FRAME)
+		pt =3D (struct pt_regs *) info->psp - 1;
+	else
+		pt =3D (struct pt_regs *) info->sp - 1;
=20
 	switch (regnum) {
 	      case UNW_AR_BSP:
@@ -409,6 +450,15 @@
 			addr =3D &info->sw->ar_lc;
 		break;
=20
+	      case UNW_AR_EC:
+		if (!info->cfm)
+			return -1;
+		if (write)
+			*info->cfm =3D (*info->cfm & ~(0x3fUL << 52)) | ((*val & 0x3f) << 52);
+		else
+			*val =3D (*info->cfm >> 52) & 0x3f;
+		return 0;
+
 	      case UNW_AR_FPSR:
 		addr =3D info->fpsr;
 		if (!addr)
@@ -523,7 +573,7 @@
 	for (reg =3D hi; reg >=3D lo; --reg) {
 		if (reg->where =3D UNW_WHERE_SPILL_HOME) {
 			reg->where =3D UNW_WHERE_PSPREL;
-			reg->val =3D *offp;
+			reg->val =3D 0x10 - *offp;
 			*offp +=3D regsize;
 		}
 	}
@@ -1046,27 +1096,34 @@
 script_new (unsigned long ip)
 {
 	struct unw_script *script, *prev, *tmp;
-	unsigned short head;
 	unsigned long flags;
 	unsigned char index;
+	unsigned short head;
=20
 	STAT(++unw.stat.script.news);
=20
 	/*
-	 * Atomically fetch the least recently used script.  We can't
-	 * do this via unw.lock because we also need to acquire the
-	 * script's lock and to avoid deadlock, we must acquire the
-	 * latter before the former.
+	 * Can't (easily) use cmpxchg() here because of ABA problem
+	 * that is intrinsic in cmpxchg()...
 	 */
-	do {
+	spin_lock_irqsave(&unw.lock, flags);
+	{
 		head =3D unw.lru_head;
-	} while (cmpxchg(&unw.lru_head, head, unw.cache[head].lru_chain) !=3D hea=
d);
-
-	script =3D unw.cache + head;
+		script =3D unw.cache + head;
+		unw.lru_head =3D script->lru_chain;
+	}
+	spin_unlock(&unw.lock);
=20
+	/*
+	 * XXX We'll deadlock here if we interrupt a thread that is
+	 * holding a read lock on script->lock.  A try_write_lock()
+	 * might be mighty handy here...  Alternatively, we could
+	 * disable interrupts whenever we hold a read-lock, but that
+	 * seems silly.
+	 */
 	write_lock(&script->lock);
=20
-	spin_lock_irqsave(&unw.lock, flags);
+	spin_lock(&unw.lock);
 	{
 		/* re-insert script at the tail of the LRU chain: */
 		unw.cache[unw.lru_tail].lru_chain =3D head;
@@ -1543,7 +1600,9 @@
 	int have_write_lock =3D 0;
 	struct unw_script *scr;
=20
-	if (info->ip & (my_cpu_data.unimpl_va_mask | 0xf)) {
+	if ((info->ip & (my_cpu_data.unimpl_va_mask | 0xf))
+	    || REGION_NUMBER(info->ip) !=3D REGION_KERNEL)
+	{
 		/* don't let obviously bad addresses pollute the cache */
 		dprintk("unwind: rejecting bad ip=3D0x%lx\n", info->ip);
 		info->rp =3D 0;
@@ -1593,7 +1652,11 @@
 		return -1;
 	}
 	ip =3D info->ip =3D *info->rp;
-	if (ip <=3D TASK_SIZE) {
+	if (ip < GATE_ADDR + PAGE_SIZE) {
+		/*
+		 * We don't have unwind info for the gate page, so we consider that part
+		 * of user-space for the purpose of unwinding.
+		 */
 		dprintk("unwind: reached user-space (ip=3D0x%lx)\n", ip);
 		STAT(unw.stat.api.unwind_time +=3D ia64_get_itc() - start; local_irq_res=
tore(flags));
 		return -1;
@@ -1648,7 +1711,30 @@
 	return retval;
 }
=20
-static void
+int
+unw_unwind_to_user (struct unw_frame_info *info)
+{
+	unsigned long ip;
+
+	while (unw_unwind(info) >=3D 0) {
+		if (unw_get_rp(info, &ip) < 0) {
+			unw_get_ip(info, &ip);
+			dprintk("unwind: failed to read return pointer (ip=3D0x%lx)\n", ip);
+			return -1;
+		}
+		/*
+		 * We don't have unwind info for the gate page, so we consider that part
+		 * of user-space for the purpose of unwinding.
+		 */
+		if (ip < GATE_ADDR + PAGE_SIZE)
+			return 0;
+	}
+	unw_get_ip(info, &ip);
+	dprintk("unwind: failed to unwind to user-level (ip=3D0x%lx)\n", ip);
+	return -1;
+}
+
+void
 unw_init_frame_info (struct unw_frame_info *info, struct task_struct *t, s=
truct switch_stack *sw)
 {
 	unsigned long rbslimit, rbstop, stklimit, stktop, sol;
@@ -1682,6 +1768,7 @@
 	info->regstk.top   =3D rbstop;
 	info->memstk.limit =3D stklimit;
 	info->memstk.top   =3D stktop;
+	info->task =3D t;
 	info->sw  =3D sw;
 	info->sp =3D info->psp =3D (unsigned long) (sw + 1) - 16;
 	info->cfm =3D &sw->ar_pfs;
@@ -1961,7 +2048,7 @@
 	extern void unw_hash_index_t_is_too_narrow (void);
 	long i, off;
=20
-	if (8*sizeof (unw_hash_index_t) < UNW_LOG_HASH_SIZE)
+	if (8*sizeof(unw_hash_index_t) < UNW_LOG_HASH_SIZE)
 		unw_hash_index_t_is_too_narrow();
=20
 	unw.sw_off[unw.preg_index[UNW_REG_PRI_UNAT_GR]] =3D SW(AR_UNAT);
diff -urN linux-davidm/arch/ia64/lib/Makefile linux-2.4.0-test1-lia/arch/ia=
64/lib/Makefile
--- linux-davidm/arch/ia64/lib/Makefile	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/lib/Makefile	Wed Jun 21 21:57:29 2000
@@ -16,6 +16,9 @@
=20
 LX_OBJS =3D io.o
=20
+IGNORE_FLAGS_OBJS =3D __divdi3.o __divsi3.o __udivdi3.o __udivsi3.o \
+		    __moddi3.o __modsi3.o __umoddi3.o __umodsi3.o
+
 include $(TOPDIR)/Rules.make
=20
 __divdi3.o: idiv.S
diff -urN linux-davidm/arch/ia64/mm/init.c linux-2.4.0-test1-lia/arch/ia64/=
mm/init.c
--- linux-davidm/arch/ia64/mm/init.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/init.c	Wed Jun 21 21:47:35 2000
@@ -346,7 +346,7 @@
=20
 	memset(zones_size, 0, sizeof(zones_size));
=20
-	max_dma =3D virt_to_phys((void *) MAX_DMA_ADDRESS);
+	max_dma =3D (PAGE_ALIGN(MAX_DMA_ADDRESS) >> PAGE_SHIFT);
 	if (max_low_pfn < max_dma)
 		zones_size[ZONE_DMA] =3D max_low_pfn;
 	else {
diff -urN linux-davidm/arch/ia64/mm/tlb.c linux-2.4.0-test1-lia/arch/ia64/m=
m/tlb.c
--- linux-davidm/arch/ia64/mm/tlb.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/mm/tlb.c	Wed Jun 21 21:48:13 2000
@@ -73,6 +73,7 @@
 		local_irq_enable();
 	}
=20
+	spin_lock(&ptcg_lock);
 	flush_rid =3D ia64_get_rr(start);
 	ia64_srlz_d();
 	flush_start =3D start;
@@ -205,10 +206,10 @@
 	}
 	start &=3D ~((1UL << nbits) - 1);
=20
-	spin_lock(&ptcg_lock);
 #if defined(CONFIG_SMP) && !defined(CONFIG_ITANIUM_PTCG)
 	flush_tlb_no_ptcg(start, end, nbits);
 #else
+	spin_lock(&ptcg_lock);
 	do {
 # ifdef CONFIG_SMP
 		/*
diff -urN linux-davidm/arch/ia64/tools/print_offsets.c linux-2.4.0-test1-li=
a/arch/ia64/tools/print_offsets.c
--- linux-davidm/arch/ia64/tools/print_offsets.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/arch/ia64/tools/print_offsets.c	Wed Jun 21 21:48:=
47 2000
@@ -45,6 +45,9 @@
     { "IA64_PT_REGS_SIZE",		sizeof (struct pt_regs) },
     { "IA64_SWITCH_STACK_SIZE",		sizeof (struct switch_stack) },
     { "IA64_SIGINFO_SIZE",		sizeof (struct siginfo) },
+#ifdef CONFIG_IA64_NEW_UNWIND
+    { "UNW_FRAME_INFO_SIZE",		sizeof (struct unw_frame_info) },
+#endif
     { "", 0 },			/* spacer */
     { "IA64_TASK_FLAGS_OFFSET",		offsetof (struct task_struct, flags) },
     { "IA64_TASK_SIGPENDING_OFFSET",	offsetof (struct task_struct, sigpend=
ing) },
diff -urN linux-davidm/drivers/char/simserial.c linux-2.4.0-test1-lia/drive=
rs/char/simserial.c
--- linux-davidm/drivers/char/simserial.c	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/drivers/char/simserial.c	Wed Jun 21 21:49:39 2000
@@ -30,10 +30,6 @@
 #include <linux/serial.h>
 #include <linux/serialP.h>
=20
-#ifdef CONFIG_KDB
-# include <linux/kdb.h>
-#endif
-
 #include <asm/irq.h>
 #include <asm/uaccess.h>
=20
@@ -158,9 +154,6 @@
 			} else if ( seen_esc =3D 2 ) {
 				if ( ch =3D 'P' ) show_state();		/* F1 key */
 				if ( ch =3D 'Q' ) show_buffers();	/* F2 key */
-#ifdef CONFIG_KDB
-				if ( ch =3D 'S' ) KDB_ENTER();		/* F4 key */
-#endif
 				seen_esc =3D 0;
 				continue;
 			}
diff -urN linux-davidm/include/asm-ia64/dma.h linux-2.4.0-test1-lia/include=
/asm-ia64/dma.h
--- linux-davidm/include/asm-ia64/dma.h	Sun Feb 13 10:30:44 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/dma.h	Wed Jun 21 21:57:58 2000
@@ -21,7 +21,7 @@
 #define dma_inb		inb
=20
 #define MAX_DMA_CHANNELS	8
-#define MAX_DMA_ADDRESS		(~0UL)		/* no limits on DMAing, for now */
+#define MAX_DMA_ADDRESS		0xffffffffUL
=20
 extern spinlock_t  dma_spin_lock;
=20
diff -urN linux-davidm/include/asm-ia64/ia32.h linux-2.4.0-test1-lia/includ=
e/asm-ia64/ia32.h
--- linux-davidm/include/asm-ia64/ia32.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/ia32.h	Wed Jun 21 21:50:32 2000
@@ -112,10 +112,16 @@
        sigset32_t sa_mask;     /* A 32 bit mask */
 };
=20
+typedef struct sigaltstack_ia32 {
+	unsigned int	ss_sp;
+	int		ss_flags;
+	unsigned int	ss_size;
+} stack_ia32_t;
+
 struct ucontext_ia32 {
-	unsigned long	  uc_flags;
-	struct ucontext_ia32  *uc_link;
-	stack_t		  uc_stack;
+	unsigned int	  uc_flags;
+	unsigned int 	  uc_link;
+	stack_ia32_t	  uc_stack;
 	struct sigcontext_ia32 uc_mcontext;
 	sigset_t	  uc_sigmask;	/* mask last for extensibility */
 };
@@ -343,8 +349,8 @@
  *  IA32 floating point control registers starting values
  */
=20
-#define IA32_FSR_DEFAULT	0x55550000	/* set all tag bits */
-#define IA32_FCR_DEFAULT	0x33f		/* single precision, all masks */
+#define IA32_FSR_DEFAULT	0x55550000		/* set all tag bits */
+#define IA32_FCR_DEFAULT	0x17800000037fULL	/* extended precision, all mask=
s */
=20
 #define IA32_PTRACE_GETREGS	12
 #define IA32_PTRACE_SETREGS	13
diff -urN linux-davidm/include/asm-ia64/page.h linux-2.4.0-test1-lia/includ=
e/asm-ia64/page.h
--- linux-davidm/include/asm-ia64/page.h	Wed Mar 15 09:59:06 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/page.h	Wed Jun 21 21:50:50 2000
@@ -127,6 +127,12 @@
 #define __pa(x)		({ia64_va _v; _v.l =3D (long) (x); _v.f.reg =3D 0; _v.l;})
 #define __va(x)		({ia64_va _v; _v.l =3D (long) (x); _v.f.reg =3D -1; _v.p;=
})
=20
+#define REGION_NUMBER(x)	({ia64_va _v; _v.l =3D (long) (x); _v.f.reg;})
+#define REGION_OFFSET(x)	({ia64_va _v; _v.l =3D (long) (x); _v.f.off;})
+
+#define REGION_SIZE		REGION_NUMBER(1)
+#define REGION_KERNEL	7
+
 #define BUG() do { printk("kernel BUG at %s:%d!\n", __FILE__, __LINE__); *=
(int *)0=3D0; } while (0)
 #define PAGE_BUG(page) do { BUG(); } while (0)
=20
diff -urN linux-davidm/include/asm-ia64/pal.h linux-2.4.0-test1-lia/include=
/asm-ia64/pal.h
--- linux-davidm/include/asm-ia64/pal.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/pal.h	Wed Jun 21 21:51:10 2000
@@ -951,7 +951,7 @@
 /* Return information about processor's optional power management capabili=
ties. */
 extern inline s64=20
 ia64_pal_halt_info (pal_power_mgmt_info_u_t *power_buf)=20
-{=09
+{
 	struct ia64_pal_retval iprv;
 	PAL_CALL_STK(iprv, PAL_HALT_INFO, (unsigned long) power_buf, 0, 0);
 	return iprv.status;=20
diff -urN linux-davidm/include/asm-ia64/processor.h linux-2.4.0-test1-lia/i=
nclude/asm-ia64/processor.h
--- linux-davidm/include/asm-ia64/processor.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/processor.h	Wed Jun 21 21:51:21 =
2000
@@ -10,6 +10,7 @@
  *
  * 11/24/98	S.Eranian	added ia64_set_iva()
  * 12/03/99	D. Mosberger	implement thread_saved_pc() via kernel unwind API
+ * 06/16/00	A. Mallick	added csd/ssd/tssd for ia32 support
  */
=20
 #include <linux/config.h>
@@ -291,10 +292,13 @@
 	__u64 fcr;			/* IA32 floating pt control reg */
 	__u64 fir;			/* IA32 fp except. instr. reg */
 	__u64 fdr;			/* IA32 fp except. data reg */
+	__u64 csd;			/* IA32 code selector descriptor */
+	__u64 ssd;			/* IA32 stack selector descriptor */
+	__u64 tssd;			/* IA32 TSS descriptor */
 	union {
 		__u64 sigmask;		/* aligned mask for sigsuspend scall */
 	} un;
-# define INIT_THREAD_IA32	, 0, 0, 0, 0, 0, {0}
+# define INIT_THREAD_IA32	, 0, 0, 0x17800000037fULL, 0, 0, 0, 0, 0, {0}
 #else
 # define INIT_THREAD_IA32
 #endif /* CONFIG_IA32_SUPPORT */
diff -urN linux-davidm/include/asm-ia64/ptrace.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/ptrace.h
--- linux-davidm/include/asm-ia64/ptrace.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/ptrace.h	Wed Jun 21 21:51:33 2000
@@ -136,8 +136,8 @@
 	unsigned long r30;		/* scratch */
 	unsigned long r31;		/* scratch */
=20
-	unsigned long ar_ccv;		/* compare/exchange value  */
-	unsigned long ar_fpsr;		/* floating point status*/
+	unsigned long ar_ccv;		/* compare/exchange value (scratch) */
+	unsigned long ar_fpsr;		/* floating point status (preserved) */
=20
 	unsigned long b0;		/* return pointer (bp) */
 	unsigned long b7;		/* scratch */
@@ -219,6 +219,7 @@
   extern void show_regs (struct pt_regs *);
   extern long ia64_peek (struct pt_regs *, struct task_struct *, unsigned =
long addr, long *val);
   extern long ia64_poke (struct pt_regs *, struct task_struct *, unsigned =
long addr, long val);
+  extern void ia64_sync_fph (struct task_struct *t);
=20
 #ifdef CONFIG_IA64_NEW_UNWIND
   /* get nat bits for scratch registers such that bit N=3D1 iff scratch re=
gister rN is a NaT */
diff -urN linux-davidm/include/asm-ia64/stat.h linux-2.4.0-test1-lia/includ=
e/asm-ia64/stat.h
--- linux-davidm/include/asm-ia64/stat.h	Sun Feb  6 18:42:40 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/stat.h	Wed Jun 21 21:51:44 2000
@@ -7,6 +7,27 @@
  */
=20
 struct stat {
+	unsigned long	st_dev;
+	unsigned long	st_ino;
+	unsigned long	st_nlink;
+	unsigned int	st_mode;
+	unsigned int	st_uid;
+	unsigned int	st_gid;
+	unsigned int	__pad0;
+	unsigned long	st_rdev;
+	unsigned long	st_size;
+	unsigned long	st_atime;
+	unsigned long	__reserved0;	/* reserved for atime.nanoseconds */
+	unsigned long	st_mtime;
+	unsigned long	__reserved1;	/* reserved for mtime.nanoseconds */
+	unsigned long	st_ctime;
+	unsigned long	__reserved2;	/* reserved for ctime.nanoseconds */
+	unsigned long	st_blksize;
+	long		st_blocks;
+	unsigned long	__unused[3];
+};
+
+struct ia64_oldstat {
 	unsigned int	st_dev;
 	unsigned int	st_ino;
 	unsigned int	st_mode;
diff -urN linux-davidm/include/asm-ia64/unistd.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/unistd.h
--- linux-davidm/include/asm-ia64/unistd.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/unistd.h	Wed Jun 21 21:51:52 2000
@@ -109,9 +109,9 @@
 #define __NR_syslog			1117
 #define __NR_setitimer			1118
 #define __NR_getitimer			1119
-#define __NR_stat			1120
-#define __NR_lstat			1121
-#define __NR_fstat			1122
+#define __NR_old_stat			1120
+#define __NR_old_lstat			1121
+#define __NR_old_fstat			1122
 #define __NR_vhangup			1123
 #define __NR_lchown			1124
 #define __NR_vm86			1125
@@ -199,6 +199,9 @@
 #define __NR_sys_pivot_root		1207
 #define __NR_mincore			1208
 #define __NR_madvise			1209
+#define __NR_stat			1210
+#define __NR_lstat			1211
+#define __NR_fstat			1212
=20
 #if !defined(__ASSEMBLY__) && !defined(ASSEMBLER)
=20
diff -urN linux-davidm/include/asm-ia64/unwind.h linux-2.4.0-test1-lia/incl=
ude/asm-ia64/unwind.h
--- linux-davidm/include/asm-ia64/unwind.h	Wed Jun 21 22:07:19 2000
+++ linux-2.4.0-test1-lia/include/asm-ia64/unwind.h	Wed Jun 21 21:52:01 2000
@@ -23,6 +23,7 @@
 	UNW_AR_RNAT,
 	UNW_AR_UNAT,
 	UNW_AR_LC,
+	UNW_AR_EC,
 	UNW_AR_FPSR,
 	UNW_AR_RSC,
 	UNW_AR_CCV
@@ -58,6 +59,7 @@
 	unsigned long pr_val;		/* current predicates */
 	unsigned long *cfm;
=20
+	struct task_struct *task;
 	struct switch_stack *sw;
=20
 	/* preserved state: */
@@ -101,6 +103,9 @@
  */
 extern void unw_init_from_blocked_task (struct unw_frame_info *info, struc=
t task_struct *t);
=20
+extern void unw_init_frame_info (struct unw_frame_info *info, struct task_=
struct *t,
+				 struct switch_stack *sw);
+
 /*
  * Prepare to unwind the current task.  For this to work, the kernel
  * stack identified by REGS must look like this:
@@ -118,10 +123,22 @@
 extern void unw_init_from_current (struct unw_frame_info *info, struct pt_=
regs *regs);
=20
 /*
+ * Prepare to unwind the currently running thread.
+ */
+extern void unw_init_running (void (*callback)(struct unw_frame_info *info=
, void *arg), void *arg);
+
+/*
  * Unwind to previous to frame.  Returns 0 if successful, negative
  * number in case of an error.
  */
 extern int unw_unwind (struct unw_frame_info *info);
+
+/*
+ * Unwind until the return pointer is in user-land (or until an error
+ * occurs).  Returns 0 if successful, negative number in case of
+ * error.
+ */
+extern int unw_unwind_to_user (struct unw_frame_info *info);
=20
 #define unw_get_ip(info,vp)	({*(vp) =3D (info)->ip; 0;})
 #define unw_get_sp(info,vp)	({*(vp) =3D (unsigned long) (info)->sp; 0;})


