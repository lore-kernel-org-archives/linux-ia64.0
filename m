From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 30 Sep 2009 01:24:29 +0000
Subject: Re: [git pull] ia64 changes
Message-Id: <alpine.LFD.2.01.0909291808410.6996@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



On Tue, 29 Sep 2009, Robin Holt wrote:
> 
> Any idea how difficult it will be to re-enable interrupts inside the
> contended lock case?  Without thinking about it, it feels like it
> will be impossible.

With a ticket lock, taking an interrupt while waiting ends up being 
exactly the same as taking an interrupt while holding it, so yeah, if you 
have an interrupt-safe lock, you can't re-enable interrupts while waiting 
for the lock. You're basically holding on to your place in the line even 
before you've actually gotten permission to proceed.

That's obviously where the fairness comes from, but it is also what makes 
it impossible to let interrupts come in - because even when you're just 
spinning on the previous user, you've already marked the spinlock as being 
busy for the next one.

Of course, even if you were able to re-enable interrupts while spinning, 
if an interrupt actually happens and then needs the lock, that interrupt 
will have high latency _anyway_. So re-enabling interrupts doesn't help in 
any fundamental way, although it can make it much less likely that you'll 
hit the bad case.

That may sound like ticket locks are nasty, but there are some upsides. In 
particular, the fairness of the ticket locks means that latencies are be 
bounded. And just for that simple reason there is often much less reason 
to worry about having to re-enable interrupts: the bounded upper case is 
not true of traditional locks.

Whether the bounds are sufficient for your situation is obviously an issue 
and depends on your load, but even in the presense of extreme contention 
it then boils down to: don't protect costly operations with interrupt-safe 
spinlocks, so that the bound (nr_cpus*cost) doesn't grow too large. And we 
generally don't.

Of course, in extreme situations you might want the RT kernel and then 
generally not ever actually disable the _real_ interrupts.

			Linus
