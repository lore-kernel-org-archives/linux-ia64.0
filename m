From: Paul Mackerras <paulus@samba.org>
Date: Wed, 05 Dec 2001 20:55:26 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805625@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805617@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805617@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David S. Miller writes:

>    From: Richard Henderson <rth@redhat.com>
>    Date: Tue, 4 Dec 2001 19:00:48 -0800
> 
>    On Tue, Dec 04, 2001 at 06:15:50PM -0800, David Mosberger wrote:
>    > Oh, sorry, I was referring to teh *other* problem... ;-)
>    > 
>    > What I meant is that the check for re-scheduling
>    > (current->need_resched) and signal deliverify (current->sigpending)
>    > needs to be done with interrupts turned off, and the interrupts need
>    > to be left off until user space is reached.  Otherwise, you could get
>    > an interrupt which would wake up a higher priority task or post a
>    > signal between the check and the return to user space.
>    > 
>    > I didn't see this interrupt disabling in the Alpha version of entry.S,
>    > but I have to admit my Alpha assembly is getting quite rusty.
>    
>    Oh, yes, I see.  This should fix it.
>    
> I don't understand why this is even necessary.

I think David (Mosberger, not Miller :) is right here, and in fact
this is also wrong on PPC at the moment.  However, the worst case is
that the reschedule or signal delivery will get delayed until the next
interrupt on that cpu (max 1/HZ seconds).  Since it is a pretty narrow
window for the race I think it would be hard to observe the effect of
the bug.

> What if the interrupt comes in on another processor.  How does this
> return from trap behavior avoid that interrupt modifying the signal
> and/or scheduling state wrt. the current cpu's task?

If the interrupt comes in on another processor, then we call schedule()
on that processor and it does an IPI if it thinks that this processor
should reschedule.

The logic requires that we do the signal/schedule checks on exit to
userland.  The scenario where they can get missed is where we are
returning to userland, and we get an interrupt just after we have done
the checks.  Suppose the interrupt routine raises a signal or wakes up
a task.  On the return from the interrupt routine it won't do the
signal/schedule checks because we are returning to the kernel
mainline.  When we get back there it just completes the return to
userspace without doing the checks (since we have already done them).

Paul.

