From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 25 Feb 2004 22:27:57 +0000
Subject: Important NaT-bit bug fix
Message-Id: <16445.8557.274484.443935@napali.hpl.hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="E/TmLQbyno"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--E/TmLQbyno
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit

While doing some libunwind NaT-bit testing, I discovered two bugs in
the kernel.  The first bug has been there "forever", the second bug
was introduced by the streamlined syscall path patch.

The effect of the first bug is that the NaT bit of a scratch register
(r2-r3, r8-r11, r14-r31) may silently be cleared to zero when a signal
handler gets invoked.  This is bad because it could turn a speculation
failure into an apparent speculation success and that in turn could
cause silent data corruption.

The effect of the second bug is a bit harder to gauge.  I think it may
cause the NaT bit of scratch registers to be set "randomly" when a
signal handler gets invoked.  If so, this could cause random
NaT-consumption faults, which would either be harmless or cause a
crash.  Actually, given how long we've been running with this bug
without seeing any unexpected crashes, I'm a unsure whether this
failure really happens in practice.

In any case, potential for silent data corruption needs to be taken
seriously, so I'd strongly advise everybody to upgrade to a fixed
kernel as soon as possible.  I should say that the probability of
triggering this bug may be relatively small because it requires doing
a speculative load into one of the above mentioned registers _and_
receiving a signal that results in a signal-handler-invocation while
the loaded register contains a NaT.

The first patch below is for 2.6.3 and has been verified to pass the
attached test-program.  The second patch is for 2.4.  It should be fine,
but I haven't really tested it.

NOTE TO USERS/DISTRIBUTORS OF OLDER KERNELS: if you do NOT have the
streamlined syscall-path patch applied in your kernel, then the patch
needs to be modified such that in ia64_{get,put}_scratch_nat_bits()
only the GET_BITS/PUT_BITS macros are changed (the rest should remain
the same).  If in doubt, run the attached test program below.

To prevent this (or similar) bugs from reoccurring, I created the
attached test program.  It's also useful to run the program if you're
unsure whether a given machine is running a fixed kernel.  You can run
the test like so:

 $ gcc -g -O -Wall -D_GNU_SOURCE test-nat.c test-nat-asm.S -o test-nat
 $ ./test-nat 1000000 1

If the result is:

	SUCCESS: no errors found.  Your kernel appears to be OK.

you should be OK.

Thanks,

	--david


--E/TmLQbyno
Content-Type: text/plain
Content-Description: 2.6.3-sigcontext-nat-fix.diff
Content-Disposition: inline;
	filename="2.6.3-sigcontext-nat-fix.diff"
Content-Transfer-Encoding: 7bit

===== arch/ia64/kernel/ptrace.c 1.33 vs edited =====
--- 1.33/arch/ia64/kernel/ptrace.c	Wed Dec 31 23:40:32 2003
+++ edited/arch/ia64/kernel/ptrace.c	Wed Feb 25 13:25:13 2004
@@ -75,12 +75,25 @@
 	({										\
 		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
 		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
-		(ia64_rotl(unat, first) >> bit) & mask;					\
+		unsigned long dist;							\
+		if (bit < first)							\
+			dist = 64 + bit - first;					\
+		else									\
+			dist = bit - first;						\
+		ia64_rotr(unat, dist) & mask;						\
 	})
 	unsigned long val;
 
-	val  = GET_BITS( 1,  3, scratch_unat);
-	val |= GET_BITS(12, 15, scratch_unat);
+	/*
+	 * Registers that are stored consecutively in struct pt_regs can be handled in
+	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
+	 * updated.
+	 */
+	val  = GET_BITS( 1,  1, scratch_unat);
+	val |= GET_BITS( 2,  3, scratch_unat);
+	val |= GET_BITS(12, 13, scratch_unat);
+	val |= GET_BITS(14, 14, scratch_unat);
+	val |= GET_BITS(15, 15, scratch_unat);
 	val |= GET_BITS( 8, 11, scratch_unat);
 	val |= GET_BITS(16, 31, scratch_unat);
 	return val;
@@ -96,16 +109,29 @@
 unsigned long
 ia64_put_scratch_nat_bits (struct pt_regs *pt, unsigned long nat)
 {
+#	define PUT_BITS(first, last, nat)						\
+	({										\
+		unsigned long bit = ia64_unat_pos(&pt->r##first);			\
+		unsigned long mask = ((1UL << (last - first + 1)) - 1) << first;	\
+		long dist;								\
+		if (bit < first)							\
+			dist = 64 + bit - first;					\
+		else									\
+			dist = bit - first;						\
+		ia64_rotl(nat & mask, dist);						\
+	})
 	unsigned long scratch_unat;
 
-#	define PUT_BITS(first, last, nat)					\
-	({									\
-		unsigned long bit = ia64_unat_pos(&pt->r##first);		\
-		unsigned long mask = ((1UL << (last - first + 1)) - 1) << bit;	\
-		(ia64_rotr(nat, first) << bit) & mask;				\
-	})
-	scratch_unat  = PUT_BITS( 1,  3, nat);
-	scratch_unat |= PUT_BITS(12, 15, nat);
+	/*
+	 * Registers that are stored consecutively in struct pt_regs can be handled in
+	 * parallel.  If the register order in struct_pt_regs changes, this code MUST be
+	 * updated.
+	 */
+	scratch_unat  = PUT_BITS( 1,  1, nat);
+	scratch_unat |= PUT_BITS( 2,  3, nat);
+	scratch_unat |= PUT_BITS(12, 13, nat);
+	scratch_unat |= PUT_BITS(14, 14, nat);
+	scratch_unat |= PUT_BITS(15, 15, nat);
 	scratch_unat |= PUT_BITS( 8, 11, nat);
 	scratch_unat |= PUT_BITS(16, 31, nat);
 
===== include/asm-ia64/processor.h 1.55 vs edited =====
--- 1.55/include/asm-ia64/processor.h	Tue Feb 10 21:13:48 2004
+++ edited/include/asm-ia64/processor.h	Wed Feb 25 11:55:28 2004
@@ -655,24 +655,13 @@
 	return retval;
 }
 
-/* XXX remove the handcoded version once we have a sufficiently clever compiler... */
-#ifdef SMART_COMPILER
-# define ia64_rotr(w,n)						\
-  ({								\
-	__u64 __ia64_rotr_w = (w), _n = (n);			\
-								\
-	(__ia64_rotr_w >> _n) | (__ia64_rotr_w << (64 - _n));	\
-  })
-#else
-# define ia64_rotr(w,n)					\
-  ({							\
-	__u64 __ia64_rotr_w;				\
-	__ia64_rotr_w = ia64_shrp((w), (w), (n));	\
-	__ia64_rotr_w;					\
-  })
-#endif
+static inline __u64
+ia64_rotr (__u64 w, __u64 n)
+{
+	return (w >> n) | (w << (64 - n));
+}
 
-#define ia64_rotl(w,n)	ia64_rotr((w),(64)-(n))
+#define ia64_rotl(w,n)	ia64_rotr((w), (64) - (n))
 
 /*
  * Take a mapped kernel address and return the equivalent address

--E/TmLQbyno
Content-Type: text/plain
Content-Description: test-nat.c
Content-Disposition: inline;
	filename="test-nat.c"
Content-Transfer-Encoding: 7bit

/*
   Copyright (c) 2004 Hewlett-Packard Development Company, L.P.
     Written by David Mosberger-Tang <davidm@hpl.hp.com>

   This program verifies that the NaT bits of the static scratch
   registers are properly passed to a signal handler and that they are
   properly preserved across a signal handler invocation.  */

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

unsigned long num_errors;

#define ARRAY_SIZE(a)	((int) ((sizeof (a)) / sizeof ((a)[0])))

static int scratch_regs[] =
  {
    2, 3, 8, 9, 10, 11, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
    25, 26, 27, 28, 29, 30, 31
  };

static unsigned long regval[ARRAY_SIZE (scratch_regs)];
static int depth;

extern unsigned long load_scratch_regs_and_segfault (unsigned long *values);

static void
check_scratch_nat (void)
{
  unsigned long errors;
  int i;

  for (i = 0; i < ARRAY_SIZE (scratch_regs); ++i)
    regval[i] = random ();
  errors = load_scratch_regs_and_segfault (regval);
  if (errors)
    {
      printf ("FAILURE: Detected %lu scratch register corruptions\n", errors);
      num_errors += errors;
    }
}

void
sighandler (int signal, void *siginfo, void *context)
{
  ucontext_t *uc = context;
  unsigned long regmask;
  int i, regnum, is_nat;

  for (i = 0; i < ARRAY_SIZE (scratch_regs); ++i)
    {
      regnum = scratch_regs[i];
      regmask = 1UL << regnum;
      is_nat = (regval[i] & 1);

      if ((is_nat && !(uc->uc_mcontext.sc_nat & regmask))
	  || (!is_nat && (uc->uc_mcontext.sc_gr[regnum] != regval[i])))
	{
	  printf ("FAILURE: r%-2d=%c%016lx, expected %c%016lx\n",
		  scratch_regs[i],
		  (uc->uc_mcontext.sc_nat & regmask) ? '*' : ' ',
		  uc->uc_mcontext.sc_gr[regnum],
		  (regval[i] & 1) ? '*' : ' ', regval[i]);
	  ++num_errors;
	}
    }
  ++uc->uc_mcontext.sc_ip;	/* skip over faulting instruction */

  if (depth > 0)
    {
      --depth;
      check_scratch_nat ();
    }
}

static void
enable_sighandler (void)
{
  struct sigaction act;

  memset (&act, 0, sizeof (act));
  act.sa_handler = (void (*)(int)) sighandler;
  act.sa_flags = SA_SIGINFO | SA_NOMASK;
  if (sigaction (SIGILL, &act, NULL) < 0)
    {
      fprintf (stderr, "sigaction: %s\n", strerror (errno));
      exit (-1);
    }
}

int
main (int argc, char **argv)
{
  long i, count = 1000000;
  int max_depth = 1024;

  if (argc > 1)
    {
      count = atol (argv[1]);
      if (argc > 2)
	max_depth = atol (argv[2]);
    }

  enable_sighandler ();
  depth = max_depth - 1;

  for (i = 0; i < count; ++i)
    {
      check_scratch_nat ();
      depth = random () % max_depth;
    }

  if (num_errors > 0)
    {
      printf ("FAILURE: detected %lu errors\n", num_errors);
      exit (-1);
    }
  printf ("SUCCESS: no errors found.  Your kernel appears to be OK.\n");
  return 0;
}

--E/TmLQbyno
Content-Type: text/plain
Content-Description: test-nat-asm.S
Content-Disposition: inline;
	filename="test-nat-asm.S"
Content-Transfer-Encoding: 7bit

/*
   Copyright (c) 2004 Hewlett-Packard Development Company, L.P.
     Written by David Mosberger-Tang <davidm@hpl.hp.com>

   This program verifies that the NaT bits of the static scratch
   registers are properly passed to a signal handler and that they are
   properly preserved across a signal handler invocation.  */

#define	errcount	loc0
#define tmp		loc1
#define spill_addr	loc2

#define LOAD_VAL(reg)				\
	ld8 reg = [in0], 8;;			\
	st8 [spill_addr] = reg, 8;		\
	tbit.nz p6, p0 = reg, 0;;		\
(p6)	ld8.s reg = [r0]

#define CHECK_VAL(reg)				\
	ld8 loc1 = [spill_addr], 8;;		\
	tbit.nz p6, p7 = loc1, 0;;		\
(p6)	tnat.z p8, p0 = reg;			\
(p7)	cmp.ne p8, p0 = loc1, reg;;		\
(p8)	add errcount = 1, errcount;;

	.global load_scratch_regs_and_segfault
	.proc load_scratch_regs_and_segfault
load_scratch_regs_and_segfault:
	.prologue
	.regstk 1, 3, 0, 0
	alloc r2 = ar.pfs, 1, 3, 0, 0;;
	.fframe 24*8
	add sp = -24*8, sp;;
	.body

	add spill_addr = 16, sp
	LOAD_VAL(r2);	LOAD_VAL(r3);	LOAD_VAL(r8);	LOAD_VAL(r9)
	LOAD_VAL(r10);	LOAD_VAL(r11);	LOAD_VAL(r14);	LOAD_VAL(r15)
	LOAD_VAL(r16);	LOAD_VAL(r17);	LOAD_VAL(r18);	LOAD_VAL(r19)
	LOAD_VAL(r20);	LOAD_VAL(r21);	LOAD_VAL(r22);	LOAD_VAL(r23)
	LOAD_VAL(r24);	LOAD_VAL(r25);	LOAD_VAL(r26);	LOAD_VAL(r27)
	LOAD_VAL(r28);	LOAD_VAL(r29);	LOAD_VAL(r30);	LOAD_VAL(r31);;
	{
	  mov r0 = r0			// force SIGILL
	  mov errcount = 0			// clear error counter
	  add spill_addr = 16, sp;;
	}
	CHECK_VAL(r2);	CHECK_VAL(r3);	CHECK_VAL(r8);	CHECK_VAL(r9)
	CHECK_VAL(r10);	CHECK_VAL(r11);	CHECK_VAL(r14);	CHECK_VAL(r15)
	CHECK_VAL(r16);	CHECK_VAL(r17);	CHECK_VAL(r18);	CHECK_VAL(r19)
	CHECK_VAL(r20);	CHECK_VAL(r21);	CHECK_VAL(r22);	CHECK_VAL(r23)
	CHECK_VAL(r24);	CHECK_VAL(r25);	CHECK_VAL(r26);	CHECK_VAL(r27)
	CHECK_VAL(r28);	CHECK_VAL(r29);	CHECK_VAL(r30);	CHECK_VAL(r31)
	mov r8 = errcount
	.restore sp
	add sp = 24*8, sp
	br.ret.sptk.many rp

	.endp load_scratch_regs_and_segfault

--E/TmLQbyno--
