From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 04 Dec 2001 19:53:47 +0000
Subject: Re: [Linux-ia64] Bug in signal handling
Message-Id: <marc-linux-ia64-105590698805597@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805573@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805573@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[I'm resending this and a couple of other mails because there were
 some problems with the linuxia64.org mailer.]

>>>>> On 02 Dec 2001 23:05:29 +0100, Andreas Schwab <schwab@suse.de> said:

  Andreas> The kernel does not correctly handle interrupted syscalls
  Andreas> that are supposed to be restarted when two nested signal
  Andreas> handlers are executed at the same time.  To reproduce run
  Andreas> this program in one terminal:

The attached patch should fix this problem.  It turned out that the
kernel exit path sometimes ended up checking for pending signals
multiple times, which is no longer valid.  The hardest part about this
bug was finding an automatic way of testing it.  I have that now so
hopefully the bug won't ever rear its ugly head again.

The patch also fixes a potential race condition which could have the
effect that a CPU does not always run the high-priority task in the
system.

Richard, I'm cc'ing you because it appears to me that Alpha Linux may
have the same problem.  I looked into how this bug came about: the x86
version was changed as part of the softirq rewrite that happened in
2.4.6, and I simply missed it.  Perhaps other platforms suffer from
this bug as well (MIPS appears to have been fixed in 2.4.10 though).

Please let me know how this works.

	--david

--- linux-2.4.16/arch/ia64/kernel/entry.S	Mon Nov 26 11:18:20 2001
+++ lia64-kdb/arch/ia64/kernel/entry.S	Mon Dec  3 16:58:41 2001
@@ -519,6 +519,8 @@
 	lfetch.fault [sp]
 	movl r14=.restart
 	;;
+	// need_resched and signals atomic test
+(pUser)	rsm psr.i
 	mov.ret.sptk rp=r14,.restart
 .restart:
 	adds r17=IA64_TASK_NEED_RESCHED_OFFSET,r13
@@ -539,8 +541,6 @@
 (pUser)	cmp.ne.unc p7,p0=r17,r0			// current->need_resched != 0?
 (pUser)	cmp.ne.unc p8,p0=r18,r0			// current->sigpending != 0?
 	;;
-	adds r2=PT(R8)+16,r12
-	adds r3=PT(R9)+16,r12
 #ifdef CONFIG_PERFMON
 (p9)	br.call.spnt.many b7=pfm_block_on_overflow
 #endif
@@ -549,7 +549,10 @@
 #else
 (p7)	br.call.spnt.many b7=schedule
 #endif
-(p8)	br.call.spnt.many b7=handle_signal_delivery	// check & deliver pending signals
+(p8)	br.call.spnt.many rp=handle_signal_delivery	// check & deliver pending signals (once)
+	;;
+.ret9:	adds r2=PT(R8)+16,r12
+	adds r3=PT(R9)+16,r12
 	;;
 	// start restoring the state saved on the kernel stack (struct pt_regs):
 	ld8.fill r8=[r2],16
@@ -582,7 +585,7 @@
 	ld8.fill r30=[r2],16
 	ld8.fill r31=[r3],16
 	;;
-	rsm psr.i | psr.ic	// initiate turning off of interrupts & interruption collection
+	rsm psr.i | psr.ic	// initiate turning off of interrupt and interruption collection
 	invala			// invalidate ALAT
 	;;
 	ld8 r1=[r2],16		// ar.ccv
@@ -601,7 +604,7 @@
 	mov ar.fpsr=r13
 	mov b0=r14
 	;;
-	srlz.i			// ensure interrupts & interruption collection are off
+	srlz.i			// ensure interruption collection is off
 	mov b7=r15
 	;;
 	bsw.0			// switch back to bank 0

