From: Richard Henderson <rth@redhat.com>
Date: Wed, 05 Dec 2001 03:00:48 +0000
Subject: [Linux-ia64] alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805615@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 04, 2001 at 06:15:50PM -0800, David Mosberger wrote:
> Oh, sorry, I was referring to teh *other* problem... ;-)
> 
> What I meant is that the check for re-scheduling
> (current->need_resched) and signal deliverify (current->sigpending)
> needs to be done with interrupts turned off, and the interrupts need
> to be left off until user space is reached.  Otherwise, you could get
> an interrupt which would wake up a higher priority task or post a
> signal between the check and the return to user space.
> 
> I didn't see this interrupt disabling in the Alpha version of entry.S,
> but I have to admit my Alpha assembly is getting quite rusty.

Oh, yes, I see.  This should fix it.


r~



--- arch/alpha/kernel/entry.S.orig	Tue Dec  4 18:40:53 2001
+++ arch/alpha/kernel/entry.S	Tue Dec  4 18:46:33 2001
@@ -580,6 +580,10 @@
 	and	$0,8,$0
 	beq	$0,restore_all
 ret_from_reschedule:
+	/* Turn off interrupts so that resched and signal delivery
+	   checks are done atomically.  */
+	addq	$31,7,$16
+	call_pal PAL_swpipl
 	ldq	$2,TASK_NEED_RESCHED($8)
 	lda	$4,init_task_union
 	bne	$2,reschedule

