From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 18 Sep 2001 05:53:46 +0000
Subject: Re: [Linux-ia64] sigaltstack not working
Message-Id: <marc-linux-ia64-105590698805197@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805189@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805189@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 17 Sep 2001 16:12:34 +0200, Andreas Schwab <schwab@suse.de> said:

  Andreas> The appended program isn't working as expected.  As soon as
  Andreas> the stack limit is reached it hangs without actually
  Andreas> executing the signal handler.

Below is a first draft to fix this problem.  With the patch applied,
the test program works fine.  I call it a "first draft" since it
hasn't received a whole lot of testing yet.  I'd appreciate it if
others could help with testing.  If you find any bugs, please let me
know (and if it works, I appreciate a note, too ;-).

For completeness, it is also necessary to update the MINSIGSTKSZ and
SIGSTKSZ macros in include/asm-ia64/signal.h.  I'm using the following
values now:

#define MINSIGSTKSZ     131027  /* min. stack size for sigaltstack() */
#define SIGSTKSZ        262144  /* default stack size for sigaltstack() */

The old values were far too small.  The new values are somewhat
largish but it's better to be safe here as the values really can't be
increased without breaking binary compatibility.  Thanks to Rafael
Hernandez for finding this!

Jes, will you make the corresponding changes to sigcontext.h and
signal.h in libc?

Thanks,

	--david

--- lia64-kdb/include/asm-ia64/sigcontext.h~	Thu Aug 16 11:04:37 2001
+++ lia64-kdb/include/asm-ia64/sigcontext.h	Mon Sep 17 18:16:08 2001
@@ -40,7 +40,8 @@
 	unsigned long		sc_gr[32];	/* general registers (static partition) */
 	struct ia64_fpreg	sc_fr[128];	/* floating-point registers */
 
-	unsigned long		sc_rsvd[16];	/* reserved for future use */
+	unsigned long		sc_loadrs;
+	unsigned long		sc_rsvd[15];	/* reserved for future use */
 
 	/*
 	 * The mask must come last so we can increase _NSIG_WORDS
--- lia64-kdb/arch/ia64/tools/print_offsets.c~	Mon Sep 10 10:27:11 2001
+++ lia64-kdb/arch/ia64/tools/print_offsets.c	Mon Sep 17 18:16:26 2001
@@ -165,6 +165,7 @@
     { "IA64_SIGCONTEXT_FR6_OFFSET",	offsetof (struct sigcontext, sc_fr[6]) },
     { "IA64_SIGCONTEXT_PR_OFFSET",	offsetof (struct sigcontext, sc_pr) },
     { "IA64_SIGCONTEXT_R12_OFFSET",	offsetof (struct sigcontext, sc_gr[12]) },
+    { "IA64_SIGCONTEXT_LOADRS_OFFSET",	offsetof (struct sigcontext, sc_loadrs) },
     { "IA64_SIGFRAME_ARG0_OFFSET",		offsetof (struct sigframe, arg0) },
     { "IA64_SIGFRAME_ARG1_OFFSET",		offsetof (struct sigframe, arg1) },
     { "IA64_SIGFRAME_ARG2_OFFSET",		offsetof (struct sigframe, arg2) },
--- lia64-kdb/arch/ia64/kernel/gate.S~	Mon Sep 17 18:54:41 2001
+++ lia64-kdb/arch/ia64/kernel/gate.S	Mon Sep 17 21:18:39 2001
@@ -74,7 +74,8 @@
 	.vframesp SP_OFF+SIGCONTEXT_OFF
 	.body
 
-	.prologue
+	.label_state 1
+
 	adds base0=SIGHANDLER_OFF,sp
 	adds base1=RBS_BASE_OFF,sp
 	br.call.sptk.many rp
@@ -156,6 +157,8 @@
 	mov r15=__NR_rt_sigreturn
 	break __BREAK_SYSCALL
 
+	.body
+	.copy_state 1
 setup_rbs:
 	mov ar.rsc=0				// put RSE into enforced lazy mode
 	;;
@@ -180,22 +183,25 @@
 	mov ar.rsc=0xf				// set RSE into eager mode, pl 3
 	br.cond.sptk back_from_setup_rbs
 
+	.prologue
+	.copy_state 1
+	.spillsp ar.rnat, RNAT_OFF+SIGCONTEXT_OFF
+	.body
 restore_rbs:
 	alloc r2=ar.pfs,0,0,0,0			// alloc null frame
 	adds r16=(LOADRS_OFF+SIGCONTEXT_OFF),sp
 	;;
 	ld8 r14=[r16]
+	adds r16=(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
 	mov ar.rsc=r14				// put RSE into enforced lazy mode
+	ld8 r14=[r16]				// get new rnat
 	;;
 	loadrs					// restore dirty partition
-
-	adds r16=(RNAT_OFF+SIGCONTEXT_OFF),sp
 	;;
-	ld8 r14=[r16]				// get new rnat
-	mov ar.bspstore=r15			// set old register backing store area
+	mov ar.bspstore=r15			// switch back to old register backing store area
 	;;
-	mov ar.rnat=r14				// establish new rnat
+	mov ar.rnat=r14				// restore RNaT
 	mov ar.rsc=0xf				// (will be restored later on from sc_ar_rsc)
 	// invala not necessary as that will happen when returning to user-mode
 	br.cond.sptk back_from_restore_rbs

