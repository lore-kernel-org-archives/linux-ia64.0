From: David Mosberger <davidm@hpl.hp.com>
Date: Fri, 16 Mar 2001 08:54:27 +0000
Subject: [Linux-ia64] setcontext/getcontext support
Message-Id: <marc-linux-ia64-105590693005277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below adds support for the following routines:

	setcontext()
	getcontext()
	makecontext()
	swapcontext()

These routines are intended to be used for *synchronous* context
switching only.  In particular, doing a setcontext() on the sigcontext
structure passed to a signal handler will NOT work: you can only
setcontext()/swapcontext() to a context that was created by
getcontext()/makecontext().

Another limitation is that at most eight integer arguments can be
passed with makecontext().  Actually, you can pass anything as long as
those things are passed in register in0-in7.

The routines haven't been tested exhaustively, but the simple test
program included below does work and I think they should be in
reasonably good shape for use.  Thanks to Uli for providing this test
program.

Uli, if the patch looks OK, I'd appreciate it if you could check it
in.

Enjoy,

	--david

2001-03-16  David Mosberger  <davidm@hpl.hp.com>

	* sysdeps/unix/sysv/linux/ia64/bits/sigcontext.h (struct
	sigcontext): Drop hack that was needed for 2.1.1 kernel headers.

	* sysdeps/unix/sysv/linux/ia64/ucontext_i.h: New file.

	* sysdeps/unix/sysv/linux/ia64/Versions: Mention __start_context.

	* sysdeps/unix/sysv/linux/ia64/sys/ucontext.h: Rewrite to make it
	overlay with kernel's "struct sigcontext".

	* sysdeps/unix/sysv/linux/ia64/Makefile (sysdep_headers): Mention
	ia64/rse.h for "misc" subdir.
	(sysdep_routines): Mention __start_context for "stdlib" subdir.

	* sysdeps/unix/sysv/linux/ia64/ia64/rse.h: New file (based on
	kernel file of the same name).

	* stdlib/Makefile (tests): Mention tst-setcontext.

	* stdlib/tst-setcontext.c: New file (based on a sample program by
	Uli Drepper).

	* sysdeps/unix/sysv/linux/ia64/setcontext.S: New file.
	* sysdeps/unix/sysv/linux/ia64/getcontext.S: Ditto.
	* sysdeps/unix/sysv/linux/ia64/__start_context.S: Ditto.
	* sysdeps/unix/sysv/linux/ia64/makecontext.c: Ditto.

	* sysdeps/unix/sysv/linux/ia64/__longjmp.S (__longjmp): Use extr.u
	instead of shift & and.

diff --exclude CVS -urN libc/stdlib/Makefile libc-lia/stdlib/Makefile
--- libc/stdlib/Makefile	Mon Feb 26 09:50:38 2001
+++ libc-lia/stdlib/Makefile	Thu Mar 15 13:03:35 2001
@@ -59,7 +59,7 @@
 tests		:= tst-strtol tst-strtod testmb testrand testsort testdiv \
 		   test-canon test-canon2 tst-strtoll tst-environ	  \
 		   tst-xpg-basename tst-random tst-bsearch tst-limits	  \
-		   tst-rand48 bug-strtod
+		   tst-rand48 bug-strtod tst-setcontext
 
 
 # Several mpn functions from GNU MP are used by the strtod function.
diff --exclude CVS -urN libc/stdlib/tst-setcontext.c libc-lia/stdlib/tst-setcontext.c
--- libc/stdlib/tst-setcontext.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/stdlib/tst-setcontext.c	Thu Mar 15 23:41:49 2001
@@ -0,0 +1,71 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If not,
+   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+   Boston, MA 02111-1307, USA.  */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <ucontext.h>
+
+static ucontext_t ctx[3];
+
+static void
+f1 (long a0, long a1, long a2, long a3)
+{
+  printf ("start f1(a0=%lx,a1=%lx,a2=%lx,a3=%lx)\n", a0, a1, a2, a3);
+
+  if (a0 != 1 || a1 != 2 || a2 != 3 || a3 != -4)
+    {
+      puts ("arg mismatch");
+      exit (-1);
+    }
+
+  swapcontext (&ctx[1], &ctx[2]);
+  puts ("finish f1");
+}
+
+static void
+f2 (void)
+{
+  puts ("start f2");
+  swapcontext (&ctx[2], &ctx[1]);
+  puts ("finish f2");
+}
+
+int
+main (void)
+{
+  char st1[8192];
+  char st2[8192];
+
+  puts ("making contexts");
+  getcontext (&ctx[1]);
+  ctx[1].uc_stack.ss_sp = st1;
+  ctx[1].uc_stack.ss_size = sizeof st1;
+  ctx[1].uc_link = &ctx[0];
+  makecontext (&ctx[1], (void (*) (void)) f1, 4, 1, 2, 3, -4);
+
+  getcontext (&ctx[2]);
+  ctx[2].uc_stack.ss_sp = st2;
+  ctx[2].uc_stack.ss_size = sizeof st2;
+  ctx[2].uc_link = &ctx[1];
+  makecontext (&ctx[2], f2, 0);
+
+  puts ("swapping contexts");
+  swapcontext (&ctx[0], &ctx[2]);
+  puts ("back at main program; test succeeded!");
+  return 0;
+}
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/Makefile libc-lia/sysdeps/unix/sysv/linux/ia64/Makefile
--- libc/sysdeps/unix/sysv/linux/ia64/Makefile	Thu Jan 11 09:47:16 2001
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/Makefile	Fri Mar 16 00:21:10 2001
@@ -1,3 +1,11 @@
+ifeq ($(subdir),misc)
+sysdep_headers += ia64/rse.h
+endif
+
+ifeq ($(subdir),stdlib)
+sysdep_routines += __start_context
+endif
+
 ifeq ($(subdir),csu)
 CFLAGS-initfini.s += -DWEAK_GMON_START
 endif
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/Versions libc-lia/sysdeps/unix/sysv/linux/ia64/Versions
--- libc/sysdeps/unix/sysv/linux/ia64/Versions	Thu Jan 25 18:16:47 2001
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/Versions	Thu Mar 15 21:18:20 2001
@@ -18,6 +18,8 @@
 
     # linuxthreads
     __clone2;
+
+    __start_context;
   }
   GLIBC_2.2.2 {
     # w*
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/__longjmp.S libc-lia/sysdeps/unix/sysv/linux/ia64/__longjmp.S
--- libc/sysdeps/unix/sysv/linux/ia64/__longjmp.S	Fri Feb 16 10:11:04 2001
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/__longjmp.S	Thu Mar 15 17:25:07 2001
@@ -62,9 +62,7 @@
 	sub r8=r8,in0		// r8 <- &orig_jmpbuf - &jmpbuf
 	;;
 	ld8 r25=[r2]		// r25 <- jmpbuf.ar_unat
-	shr r8=r8,3		// r8 <- (&orig_jmpbuf - &jmpbuf)/8
-	;;
-	and r8=0x3f,r8
+	extr.u r8=r8,3,6	// r8 <- (&orig_jmpbuf - &jmpbuf)/8 & 0x3f
 	;;
 	cmp.lt pNeg,pPos=r8,r0
 	mov r2=in0
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/__start_context.S libc-lia/sysdeps/unix/sysv/linux/ia64/__start_context.S
--- libc/sysdeps/unix/sysv/linux/ia64/__start_context.S	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/__start_context.S	Fri Mar 16 00:10:09 2001
@@ -0,0 +1,51 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If
+   not, write to the Free Software Foundation, Inc.,
+   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
+
+#include <sysdep.h>
+#include <features.h>
+
+/* When a context set up by __makecontext() is activated, control
+   transfers to __start_context.  When we get here:
+
+	b1 = entry point of function to call
+	in0 = address of UCP to resume after function returns
+	in1 = global pointer for __start_context
+	out0 .. outN = arguments for function  */
+
+ENTRY(__start_context)
+	.prologue
+	alloc r2 = ar.pfs, 2, 0, 8, 0
+
+	.save rp, r4		// terminate call chain with a NULL rp
+	mov r4 = r0
+	;;
+
+	.body
+	br.call.sptk rp = b1
+1:
+	mov gp = in1			// restore gp
+	cmp.ne p6,p0 = in0, r0		// uc_link != 0 ?
+	;;
+(p6)	mov out0 = in0
+(p6)	br.call.sptk rp = __setcontext
+.Lexit:
+	mov out0 = 0
+	br.call.sptk rp = exit
+
+1:	br.cond.sptk .Lexit
+END(__start_context)
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/bits/sigcontext.h libc-lia/sysdeps/unix/sysv/linux/ia64/bits/sigcontext.h
--- libc/sysdeps/unix/sysv/linux/ia64/bits/sigcontext.h	Sat Jul 15 09:58:22 2000
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/bits/sigcontext.h	Thu Mar 15 14:03:59 2001
@@ -21,12 +21,6 @@
 # error "Never use <bits/sigcontext.h> directly; include <signal.h> instead."
 #endif
 
-#ifndef sigcontext_struct
-/* Kernel headers before 2.1.1 define a struct sigcontext_struct, but
-   we need sigcontext.  */
-# define sigcontext_struct sigcontext
-#endif
-
 #include <asm/fpu.h>
 #include <bits/sigstack.h>
 
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/getcontext.S libc-lia/sysdeps/unix/sysv/linux/ia64/getcontext.S
--- libc/sysdeps/unix/sysv/linux/ia64/getcontext.S	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/getcontext.S	Fri Mar 16 00:09:02 2001
@@ -0,0 +1,153 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If
+   not, write to the Free Software Foundation, Inc.,
+   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
+
+#include <sysdep.h>
+#include <features.h>
+
+#include "ucontext_i.h"
+
+/*  __getcontext (const ucontext_t *ucp)
+
+  Saves the machine context in UCP such that when it is activated,
+  it appears as if __getcontext() returned again.  The only difference
+  is that on a first return, r9 contains 1 and on a subsequent
+  return, it contains 0.
+
+  This implementation in intended to be used for *synchronous* context
+  switches only.  Therefore, it does not have to save anything
+  other than the PRESERVED state.  */
+
+ENTRY(__getcontext)
+	alloc r16 = ar.pfs, 1, 0, 3, 0
+
+	// sigprocmask (SIG_BLOCK, NULL, &sc->sc_mask):
+
+	mov r2 = SC_MASK
+	mov r15 = __NR_rt_sigprocmask
+	;;
+	mov out0 = SIG_BLOCK
+	mov out1 = 0
+	add out2 = r2, in0
+
+	break __BREAK_SYSCALL
+	flushrs					// save dirty partition on rbs
+
+	mov.m rFPSR = ar.fpsr
+	mov.m rRSC = ar.rsc
+	add r2 = SC_GR+1*8, r32
+	;;
+	mov.m rBSP = ar.bsp
+	mov.m rUNAT = ar.unat
+	add r3 = SC_GR+4*8, r32
+	;;
+
+.mem.offset 0,0; st8.spill [r2] = r1, (5*8 - 1*8)
+.mem.offset 8,0; st8.spill [r3] = r4, 16
+	mov.i rPFS = ar.pfs
+	;;
+.mem.offset 0,0; st8.spill [r2] = r5, 16
+.mem.offset 8,0; st8.spill [r3] = r6
+	add r3 = (SC_FR+3*16-(SC_GR+6*8)), r3
+	;;
+	st8.spill [r2] = r7, (SC_FR+2*16-(SC_GR+7*8))
+	nop 0
+	and rTMP = ~0x3, rRSC
+	;;
+	mov.m ar.rsc = rTMP 		// put RSE into enforced lazy mode
+	mov.m rNAT = ar.unat
+	mov.i rLC = ar.lc
+	;;
+	mov.m rRNAT = ar.rnat
+	mov.m ar.rsc = rRSC 		// restore RSE mode
+	mov rPR = pr
+
+ 	/*
+	 * Rotate NaT bits by rPOS positions to the right:
+	 */
+	stf.spill [r2] = f2, 32
+	stf.spill [r3] = f3, 32
+	add rPOS = SC_GR, r32			// rPOS <- &sc_gr[0]
+	;;
+	stf.spill [r2] = f4, (16*16-4*16)
+	stf.spill [r3] = f5, (17*16-5*16)
+	extr.u rPOS = rPOS, 3, 6		// get NaT bit number for r0
+	;;
+	stf.spill [r2] = f16, 32
+	stf.spill [r3] = f17, 32
+	sub rCPOS = 64, rPOS
+	;;
+	stf.spill [r2] = f18, 32
+	stf.spill [r3] = f19, 32
+	shr.u rTMP = rNAT, rPOS
+	;;
+	stf.spill [r2] = f20, 32
+	stf.spill [r3] = f21, 32
+	shl rNAT = rNAT, rCPOS
+	;;
+	stf.spill [r2] = f22, 32
+	stf.spill [r3] = f23, 32
+	or rNAT = rNAT, rTMP
+	;;
+	stf.spill [r2] = f24, 32
+	stf.spill [r3] = f25, 32
+	mov r8 = 0
+	;;
+	stf.spill [r2] = f26, 32
+	stf.spill [r3] = f27, 32
+	mov r9 = 1
+	;;
+	stf.spill [r2] = f28, 32
+	stf.spill [r3] = f29, 32
+	mov rB0 = b0
+	;;
+	stf.spill [r2] = f30, 32
+	stf.spill [r3] = f31, 32
+	mov rB1 = b1
+	;;
+	add r2 = SC_NAT, r32
+	nop 0
+	add r3 = SC_BSP, r32
+	;;
+	st8 [r2] = rNAT, (SC_RNAT-SC_NAT)
+	st8 [r3] = rBSP, (SC_UNAT-SC_BSP)
+	mov rB2 = b2
+	;;
+	st8 [r2] = rRNAT, (SC_FPSR-SC_RNAT)
+	st8 [r3] = rUNAT, (SC_PFS-SC_UNAT)
+	mov rB3 = b3
+	;;
+	st8 [r2] = rFPSR, (SC_LC-SC_FPSR)
+	st8 [r3] = rPFS, (SC_PR-SC_PFS)
+	mov rB4 = b4
+	;;
+	st8 [r2] = rLC, (SC_BR+0*8-SC_LC)
+	st8 [r3] = rPR, (SC_BR+1*8-SC_PR)
+	mov rB5 = b5
+
+	st8 [r2] = rB0, 16
+	st8 [r3] = rB1, 16
+	;;
+	st8 [r3] = rB2, 16
+	st8 [r3] = rB3, 16
+	;;
+	st8 [r2] = rB4
+	st8 [r3] = rB5
+	ret
+END(__getcontext)
+
+weak_alias(__getcontext, getcontext)
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/ia64/rse.h libc-lia/sysdeps/unix/sysv/linux/ia64/ia64/rse.h
--- libc/sysdeps/unix/sysv/linux/ia64/ia64/rse.h	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/ia64/rse.h	Thu Mar 15 16:32:13 2001
@@ -0,0 +1,78 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If not,
+   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+   Boston, MA 02111-1307, USA.  */
+
+#ifndef _ia64_rse_h
+#define _ia64_rse_h
+
+#include <features.h>
+
+/* Register stack engine related helper functions.  This file may be
+   used in applications, so be careful about the name-space and give
+   some consideration to non-GNU C compilers (though __inline is
+   fine). */
+
+static __inline unsigned long
+ia64_rse_slot_num (unsigned long *addr)
+{
+	return (((unsigned long) addr) >> 3) & 0x3f;
+}
+
+/* Return TRUE if ADDR is the address of an RNAT slot.  */
+
+static __inline unsigned long
+ia64_rse_is_rnat_slot (unsigned long *addr)
+{
+	return ia64_rse_slot_num (addr) = 0x3f;
+}
+
+/* Returns the address of the RNAT slot that covers the slot at
+   address SLOT_ADDR.  */
+
+static __inline unsigned long *
+ia64_rse_rnat_addr (unsigned long *slot_addr)
+{
+	return (unsigned long *) ((unsigned long) slot_addr | (0x3f << 3));
+}
+
+/* Calcuate the number of registers in the dirty partition starting at
+   BSPSTORE with a size of DIRTY bytes.  This isn't simply DIRTY
+   divided by eight because the 64th slot is used to store ar.rnat.  */
+
+static __inline unsigned long
+ia64_rse_num_regs (unsigned long *bspstore, unsigned long *bsp)
+{
+	unsigned long slots = (bsp - bspstore);
+
+	return slots - (ia64_rse_slot_num(bspstore) + slots)/0x40;
+}
+
+/* The inverse of the above: given bspstore and the number of
+   registers, calculate ar.bsp.  */
+
+static __inline unsigned long *
+ia64_rse_skip_regs (unsigned long *addr, long num_regs)
+{
+	long delta = ia64_rse_slot_num(addr) + num_regs;
+
+	if (num_regs < 0)
+		delta -= 0x3e;
+	return addr + num_regs + delta/0x3f;
+}
+
+#endif /* _ia64_rse_h */
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/makecontext.c libc-lia/sysdeps/unix/sysv/linux/ia64/makecontext.c
--- libc/sysdeps/unix/sysv/linux/ia64/makecontext.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/makecontext.c	Thu Mar 15 23:59:44 2001
@@ -0,0 +1,92 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If not,
+   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+   Boston, MA 02111-1307, USA.  */
+
+#include <stdarg.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <ucontext.h>
+
+#include <ia64/rse.h>
+
+struct fdesc
+  {
+    unsigned long ip;
+    unsigned long gp;
+  };
+
+#define PUSH(val)				\
+do {						\
+  if (ia64_rse_is_rnat_slot (rbs))		\
+    *rbs++ = 0;					\
+  *rbs++ = (val);				\
+} while (0)
+
+
+/* This implementation can handle an ARGC value of at most 8 and
+   values can be passed only in integer registers (r32-r39).  */
+
+void
+__makecontext (ucontext_t *ucp, void (*func) (void), int argc, ...)
+{
+  struct sigcontext *sc = &ucp->uc_mcontext;
+  extern void __start_context (ucontext_t *link, long gp, ...);
+  unsigned long stack_start, stack_end;
+  va_list ap;
+  long *rbs;
+  int i;
+
+  stack_start = (long) sc->sc_stack.ss_sp;
+  stack_end = (long) sc->sc_stack.ss_sp + sc->sc_stack.ss_size;
+
+  stack_start = (stack_start + 7) & -8;
+  stack_end = (stack_start + 15) & -16;
+
+  if (argc > 8)
+    {
+      fprintf (stderr, "__makecontext: does not know how to handle more "
+	       "than 8 arguments\n");
+      exit (-1);
+    }
+
+  /* set the entry point and global pointer: */
+  sc->sc_br[0] = ((struct fdesc *) &__start_context)->ip;
+  sc->sc_br[1] = ((struct fdesc *) func)->ip;
+  sc->sc_gr[1] = ((struct fdesc *) func)->gp;
+
+  /* set up the call frame: */
+  sc->sc_ar_pfs = ((sc->sc_ar_pfs & ~0x3fffffffffUL)
+		   | (argc + 2) | ((argc + 2) << 7));
+  rbs = (long *) stack_start;
+  PUSH((long) ucp->uc_link);
+  PUSH(((struct fdesc *) &__start_context)->gp);
+  va_start (ap, argc);
+  for (i = 0; i < argc; ++i)
+    PUSH(va_arg (ap, long));
+  va_end (ap);
+
+  /* set the memory and register stack pointers: */
+  sc->sc_ar_bsp = (long) rbs;
+  sc->sc_gr[12] = stack_end - 16;
+
+  /* clear the NaT bits for r1 and r12: */
+  sc->sc_nat &= ~((1 << 1) | (1 << 12));
+  sc->sc_ar_rnat = 0;
+}
+
+weak_alias (__makecontext, makecontext)
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/setcontext.S libc-lia/sysdeps/unix/sysv/linux/ia64/setcontext.S
--- libc/sysdeps/unix/sysv/linux/ia64/setcontext.S	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/setcontext.S	Thu Mar 15 23:12:22 2001
@@ -0,0 +1,149 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If
+   not, write to the Free Software Foundation, Inc.,
+   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
+
+#include <sysdep.h>
+#include <features.h>
+
+#include "ucontext_i.h"
+
+/*  __setcontext (const ucontext_t *ucp)
+
+  Restores the machine context in UCP and thereby resumes execution
+  in that context.
+
+  This implementation in intended to be used for *synchronous* context
+  switches only.  Therefore, it does not have to restore anything
+  other than the PRESERVED state.  */
+
+ENTRY(__setcontext)
+	alloc r16 = ar.pfs, 1, 0, 3, 0
+
+	// sigprocmask (SIG_SETMASK, &sc->sc_mask, NULL):
+
+	mov r2 = SC_MASK
+	mov r15 = __NR_rt_sigprocmask
+	;;
+	mov out0 = SIG_SETMASK
+	add out1 = r2, in0
+	mov out2 = 0
+
+	invala
+	break __BREAK_SYSCALL
+	add r2 = SC_NAT, r32
+
+	add r3 = SC_RNAT, r32			// r3 <- &sc_ar_rnat
+	add rPOS = SC_GR, r32			// rPOS <- &sc_gr[0]
+	;;
+	ld8 rNAT = [r2], (SC_BSP-SC_NAT)
+	extr.u rPOS = rPOS, 3, 6		// get NaT bit number for r0
+	;;
+	ld8 rBSP = [r2], (SC_UNAT-SC_BSP)
+	ld8 rRNAT = [r3], (SC_FPSR-SC_RNAT)
+	/*
+	 * Rotate NaT bits by rPOS positions to the left:
+	 */
+	sub rCPOS = 64, rPOS
+	;;
+	ld8 rUNAT = [r2], (SC_PFS-SC_UNAT)
+	ld8 rFPSR = [r3], (SC_LC-SC_FPSR)
+	shl rTMP = rNAT, rPOS
+	;;
+	ld8 rPFS = [r2], (SC_PR-SC_PFS)
+	ld8 rLC = [r3], (SC_BR+0*8-SC_LC)
+	shr.u rNAT = rNAT, rCPOS
+	;;
+	ld8 rPR = [r2], (SC_BR+1*8-SC_PR)
+	ld8 rB0 = [r3], 16
+	or rNAT = rNAT, rTMP
+	;;
+	ld8 rB1 = [r2], 16
+	ld8 rB2 = [r3], 16
+	;;
+	mov.m ar.unat = rNAT
+	mov.m rRSC = ar.rsc
+	;;
+	ld8 rB3 = [r2], 16
+	ld8 rB4 = [r3], (SC_GR+1*8-(SC_BR+4*8))
+	;;
+	ld8 rB5 = [r2], (SC_GR+4*8-(SC_BR+5*8))
+	ld8.fill r1 = [r3], (5*8 - 1*8)
+	;;
+	ld8.fill r4 = [r2], 16
+	ld8.fill r5 = [r3], 16
+	mov b0 = rB0
+	;;
+	ld8.fill r6 = [r2]
+	ld8.fill r7 = [r3], (SC_FR+2*16-(SC_GR+7*8))
+	adds r2 = (SC_FR+3*16-(SC_GR+6*8)), r2
+	;;
+	ldf.fill f3 = [r2], 16
+	ldf.fill f2 = [r3], 48
+	mov b1 = rB1
+	;;
+	ldf.fill f4 = [r2], (16*16-4*16)
+	ldf.fill f5 = [r3], (17*16-5*16)
+	mov b2 = rB2
+	;;
+	ldf.fill f16 = [r2], 32
+	ldf.fill f17 = [r3], 32
+	mov b3 = rB3
+	;;
+	ldf.fill f18 = [r2], 32
+	ldf.fill f19 = [r3], 32
+	mov b4 = rB4
+	;;
+	ldf.fill f20 = [r2], 32
+	ldf.fill f21 = [r3], 32
+	mov b5 = rB5
+	;;
+	ldf.fill f22 = [r2], 32
+	ldf.fill f23 = [r3], 32
+	mov r8 = 0
+	;;
+	ldf.fill f24 = [r2], 32
+	ldf.fill f25 = [r3], 32
+	mov r9 = 0
+	;;
+	ldf.fill f26 = [r2], 32
+	ldf.fill f27 = [r3], 32
+	dep rTMP = 0, rRSC, 16, 14	// clear ar.rsc.loadrs
+	;;
+	ldf.fill f28 = [r2], 32
+	ldf.fill f29 = [r3], 32
+	and rTMP = ~0x3, rTMP		// clear ar.rsc.mode
+	;;
+	ldf.fill f30 = [r2], 32
+	ldf.fill f31 = [r3], 32
+	mov pr = rPR, -1
+	;;
+	mov.m ar.rsc = rTMP		// put RSE into enforced lazy mode
+	mov.m ar.fpsr = rFPSR
+	mov.i ar.pfs = rPFS
+	;;
+	loadrs				// drop dirty partition is empty
+	;;
+	mov.m ar.bspstore = rBSP
+	mov.m ar.unat = rUNAT
+	mov.i ar.lc = rLC
+	;;
+	mov.m ar.rnat = rRNAT
+	mov.m ar.rsc = rRSC
+	ret
+END(__setcontext)
+
+weak_alias(__setcontext, setcontext)
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/setjmp.S libc-lia/sysdeps/unix/sysv/linux/ia64/setjmp.S
--- libc/sysdeps/unix/sysv/linux/ia64/setjmp.S	Tue Nov 21 12:55:37 2000
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/setjmp.S	Thu Mar 15 23:02:12 2001
@@ -19,7 +19,7 @@
    The layout of the jmp_buf is as follows.  This is subject to change
    and user-code should never depend on the particular layout of
    jmp_buf!
-  
+
 
   	offset:	description:
 	-------	------------
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/swapcontext.c libc-lia/sysdeps/unix/sysv/linux/ia64/swapcontext.c
--- libc/sysdeps/unix/sysv/linux/ia64/swapcontext.c	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/swapcontext.c	Thu Mar 15 19:31:41 2001
@@ -0,0 +1,40 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+   This file is part of the GNU C Library.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If not,
+   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
+   Boston, MA 02111-1307, USA.  */
+
+#include <ucontext.h>
+
+struct rv
+  {
+    long retval;
+    long first_return;
+  };
+
+extern struct rv __getcontext (ucontext_t *__ucp) __THROW;
+extern int __setcontext (__const ucontext_t *__ucp) __THROW;
+
+int
+__swapcontext (ucontext_t *oucp, const ucontext_t *ucp)
+{
+  struct rv rv = __getcontext (oucp);
+  if (rv.first_return)
+    __setcontext (ucp);
+  return 0;
+}
+
+weak_alias (__swapcontext, swapcontext)
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/sys/ucontext.h libc-lia/sysdeps/unix/sysv/linux/ia64/sys/ucontext.h
--- libc/sysdeps/unix/sysv/linux/ia64/sys/ucontext.h	Sat Jul 15 09:59:23 2000
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/sys/ucontext.h	Thu Mar 15 16:39:08 2001
@@ -1,4 +1,4 @@
-/* Copyright (C) 1998, 2000 Free Software Foundation, Inc.
+/* Copyright (C) 1998, 2000, 2001 Free Software Foundation, Inc.
    This file is part of the GNU C Library.
 
    The GNU C Library is free software; you can redistribute it and/or
@@ -24,48 +24,40 @@
 
 #include <bits/sigstack.h>
 
-typedef struct
-{
-  /* Place-holder for interrupt collection state.  */
-  long int ics_placeholder[15];
-  unsigned long	int ar_fpsr;		/* Floating point status.  */
-  unsigned long	int gp;			/* Global data pointer (gr1).  */
-  /* scratch registers: */
-  unsigned long	int gr8,   gr9, gr10, gr11,       gr13, gr14, gr15;
-  unsigned long	int gr16, gr17, gr18, gr19, gr20, gr21, gr22, gr23;
-  unsigned long	int gr24, gr25, gr26, gr27, gr28, gr29, gr30, gr31;
-  unsigned long	int ar_unat;
-  unsigned long	int ar_ec;
-  unsigned long	int ar_ccv;
-  /* RSE state: */
-  unsigned long	int ar_bsp_base;	/* Location of RSE spill area.  */
-  unsigned long	int ar_pfs;
-  unsigned long	int ar_rsc;
-  unsigned long int ar_bspstore;
-  unsigned long	int ar_rnat;
-  /* Misc. state: */
-  unsigned long	int dirty;		/* BSP - BSPSTORE */
-  unsigned long int cr_tpr;		/* Hw interrupt mask register.  */
-  unsigned long	int tpdp;		/* thread private data pointer.  */
-  unsigned long	int br_6, br_7;
-  /* Argument regs (gr32-gr39):  */
-  unsigned long	int arg0, arg1, arg2, arg3;
-  unsigned long	int arg4, arg5, arg6, arg7;
-  unsigned long	int ss_flags;		/* Save state flags.  */
-  unsigned long int br_1, br_2, br_3, br_4, br_5; /* Branch registers.  */
-  unsigned long int p_regs;		/* Predicates.  */
-} mcontext_t;
-
+/*
+ * These are here mostly for backwards compatibility with older Unices.
+ * IA-64 Linux does not distinguish between "struct sigcontext" and
+ * "ucontext_t" as all the necessary info is inside the former.
+ */
+
+typedef struct sigcontext mcontext_t;
+
+#ifdef __GNUC__
+# define _SC_GR0_OFFSET	\
+	(((char *) &((struct sigcontext *) 0)->sc_gr[0]) - (char *) 0)
+#else
+# define _SC_GR0_OFFSET	0xc8	/* pray that this is correct... */
+#endif
 
 typedef struct ucontext
-{
-  mcontext_t uc_mcontext;		/* saved machine state */
-  int uc_spares[8];			/* room to grow... */
-  unsigned int uc_created_by_getcontext: 1;
-  unsigned int uc_reserved_flags: 31;
-  struct ucontext *uc_link;
-  __sigset_t uc_sigmask;
-  stack_t uc_stack;
-} ucontext_t;
+  {
+    union
+      {
+	mcontext_t _mc;
+	struct
+	  {
+	    unsigned long _pad[_SC_GR0_OFFSET/8];
+	    struct ucontext *_link;	/* this should overlay sc_gr[0] */
+	  }
+	_uc;
+      }
+    _u;
+  }
+ucontext_t;
+
+#define uc_mcontext	_u._mc
+#define uc_sigmask	_u._mc.sc_sigmask
+#define uc_stack	_u._mc.sc_stack
+#define uc_link		_u._uc._link
 
 #endif /* sys/ucontext.h */
diff --exclude CVS -urN libc/sysdeps/unix/sysv/linux/ia64/ucontext_i.h libc-lia/sysdeps/unix/sysv/linux/ia64/ucontext_i.h
--- libc/sysdeps/unix/sysv/linux/ia64/ucontext_i.h	Wed Dec 31 16:00:00 1969
+++ libc-lia/sysdeps/unix/sysv/linux/ia64/ucontext_i.h	Thu Mar 15 21:16:53 2001
@@ -0,0 +1,58 @@
+/* Copyright (C) 2001 Free Software Foundation, Inc.
+     Contributed by David Mosberger-Tang <davidm@hpl.hp.com>.
+
+   The GNU C Library is free software; you can redistribute it and/or
+   modify it under the terms of the GNU Library General Public License as
+   published by the Free Software Foundation; either version 2 of the
+   License, or (at your option) any later version.
+
+   The GNU C Library is distributed in the hope that it will be useful,
+   but WITHOUT ANY WARRANTY; without even the implied warranty of
+   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+   Library General Public License for more details.
+
+   You should have received a copy of the GNU Library General Public
+   License along with the GNU C Library; see the file COPYING.LIB.  If
+   not, write to the Free Software Foundation, Inc.,
+   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
+
+/* Constants shared between setcontext() and getcontext().  Don't
+   install this header file.  */
+
+#define SIG_BLOCK	0
+#define SIG_UNBLOCK	1
+#define SIG_SETMASK	2
+
+#define SC_NAT	0x008
+#define SC_BSP	0x048
+#define SC_RNAT	0x050
+#define SC_UNAT	0x060
+#define SC_FPSR	0x068
+#define SC_PFS	0x070
+#define SC_LC	0x078
+#define SC_PR	0x080
+#define SC_BR	0x088
+#define SC_GR	0x0c8
+#define SC_FR	0x1d0
+#define SC_MASK	0x9d0
+
+
+#define rTMP	r16
+#define rPOS	r16
+#define rCPOS	r17
+#define rNAT	r18
+
+#define rB5	r18
+#define rB4	r19
+#define rB3	r20
+#define rB2	r21
+#define rB1	r22
+#define rB0	r23
+#define rRSC	r24
+#define rBSP	r25
+#define rRNAT	r26
+#define rUNAT	r27
+#define rFPSR	r28
+#define rPFS	r29
+#define rLC	r30
+#define rPR	r31

