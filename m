From: "David S. Miller" <davem@redhat.com>
Date: Wed, 05 Dec 2001 11:23:04 +0000
Subject: [Linux-ia64] Re: alpha bug in signal handling
Message-Id: <marc-linux-ia64-105590698805617@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

   From: Richard Henderson <rth@redhat.com>
   Date: Tue, 4 Dec 2001 19:00:48 -0800

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
   
I don't understand why this is even necessary.

What if the interrupt comes in on another processor.  How does this
return from trap behavior avoid that interrupt modifying the signal
and/or scheduling state wrt. the current cpu's task?

I think the change is bogus, we don't do this on sparc64 and things
have been perfectly fine.

And if the change isn't necessary, it's bad to disable interrupts for
a longer period of time than necessary.

