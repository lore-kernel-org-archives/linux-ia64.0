From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 26 Oct 2004 08:36:40 +0000
Subject: Re: What does unwcheck.pl do?
Message-Id: <16766.3224.601095.511856@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <523c02d87l.fsf@topspin.com>
In-Reply-To: <523c02d87l.fsf@topspin.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 25 Oct 2004 10:21:50 -0700, Roland Dreier <roland@topspin.com> said:

  Roland> I can see the ERROR: comes from unwcheck.pl but I have no
  Roland> idea what it is checking (something to do with unwind info?)
  Roland> let alone how to fix the problem.

  Roland> Is this benign or is there something to be fixed?

Both: it needs to be fixed, but it's (mostly) benign since the only
time we're executing that code is when the unwinder can't run anyhow,
since we're in the middle of delivering an MCA.  That may (and
probably will) change in the future, so it's something that should be
fixed.

I was hoping someone who knows and could test the MCA code better
would fix it but that hasn't happened yet, so it's time for plan B.

Tony, below is a patch that fixes the unwind info enough that the
warning/error goes away.  The unwind-info may not be 100% correct
though.  Someone who can test/exercise this code may want to check on
that.

	--david

=== arch/ia64/kernel/mca_asm.S 1.14 vs edited ==--- 1.14/arch/ia64/kernel/mca_asm.S	2003-12-23 08:52:44 -08:00
+++ edited/arch/ia64/kernel/mca_asm.S	2004-10-26 01:29:47 -07:00
@@ -868,7 +868,7 @@
 
 
 GLOBAL_ENTRY(ia64_monarch_init_handler)
-
+	.prologue
 	// stash the information the SAL passed to os
 	SAL_TO_OS_MCA_HANDOFF_STATE_SAVE(r2)
 	;;
@@ -907,6 +907,7 @@
 	adds out0,sp				// out0 = pointer to pt_regs
 	;;
 	DO_SAVE_SWITCH_STACK
+	.body
 	adds out1,sp				// out0 = pointer to switch_stack
 
 	br.call.sptk.many rp=ia64_init_handler
