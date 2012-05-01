From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Tue, 01 May 2012 23:37:43 +0000
Subject: why is sigreturn() skipping some code on the way out of kernel?
Message-Id: <20120501233743.GI6871@ZenIV.linux.org.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

AFAICS, pNonSys had been used for several purposes from the very
beginning; one of them is suppression of syscall restarts and
since 2.3.99pre6-4 rt_sigreturn(2) is relying on that to prevent
a really unpleasant pile of problems.  So far, so good, but that's
not the only thing conditional on pNonSys - there's also
(pNonSys) br.cond.dpnt dont_preserve_current_frame
        COVER                           // add current frame into dirty partition and set cr.ifs
        ;;
        mov r19=ar.bsp                  // get new backing store pointer
rbs_switch:
        sub r16=r16,r18                 // krbs = old bsp - size of dirty partition
        cmp.ne p9,p0=r0,r0              // clear p9 to skip restore of cr.ifs
        ;;
        sub r19=r19,r16                 // calculate total byte size of dirty partition
        add r18d,r18                  // don't force in0-in7 into memory...
        ;;
        shl r19=r19,16                  // shift size of dirty partition into loadrs position
        ;;
dont_preserve_current_frame:

in .work_processed_kernel and I'd really like to know if skipping it on
sigreturn() is an intended effect.  I don't know ia64 well enough to even
tell what that code is doing, let alone whether it should be done on
sigreturn() or not...

The reason I'm asking is that we really need to loop after hitting
notify_resume_user() when we are returning to userland; not to mention
anything else, NEED_RESCHED might've been set while we had been building
sigframes.  Moreover, handling all pending signals is the normal behaviour
on most of the architectures; some of the reasons for it are covered by
kinda-sorta looping inside do_signal() (to catch self-inflicted SIGSEGV),
but the full-blown variant is saner anyway and it's better to have that
logics consistent between the architectures.

Of course, taking that loop into entry.S needs a different mechanism
for preventing double restarts; I wonder if using the same method that
is used by sigreturn() would be safe.  FWIW, entry.S bits are very
small; the question is whether they are correct...

Comments?

diff --git a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
index 1ccbe12..27322e6 100644
--- a/arch/ia64/kernel/entry.S
+++ b/arch/ia64/kernel/entry.S
@@ -1184,7 +1184,8 @@ skip_rbs_switch:
 
 .notify:
 (pUStk)	br.call.spnt.many rp=notify_resume_user
-.ret10:	cmp.ne p6,p0=r0,r0	// p6 <- 0 (don't re-check)
+.ret10:
+(pUStk)	cmp.eq.unc p6,p0=r0,r0		// p6 <- pUStk
 (pLvSys)br.cond.sptk.few  __paravirt_pending_syscall_end
 	br.cond.sptk.many .work_processed_kernel
 
@@ -1250,6 +1251,7 @@ GLOBAL_ENTRY(notify_resume_user)
 (pSys)	mov out2=1				// out2=1 => we're in a syscall
 	;;
 (pNonSys) mov out2=0				// out2=0 => not a syscall
+	cmp.eq pNonSys,pSys=r0,r0		// don't do restarts twice
 	.fframe 16
 	.spillsp ar.unat, 16
 	st8 [sp]=r9,-16				// allocate space for ar.unat and save it
