From: Nick Piggin <npiggin@suse.de>
Date: Thu, 23 Aug 2007 01:59:16 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070823015916.GA18788@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org

On Wed, Aug 22, 2007 at 11:07:32AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 22 Aug 2007, Nick Piggin wrote:
> > 
> > It took me more than a glance to see what the difference is supposed to be
> > between wmb() and mmiowb(). I think especially because mmiowb isn't really
> > like a write barrier.
> 
> Well, it is, but it isn't. Not on its own - but together with a "normal" 
> barrier it is.
 
But it is stronger (or different) to write barrier semantics, because it
enforces the order in which a 3rd party (the IO device) sees writes from
multiple CPUs. The rest of our barrier concept is based purely on the
POV of the single entity executing the barrier.

Now it's needed because the IO device is not participating in the same
synchronisation logic that the CPUs are, which is why I say it is more
like a synchronisation primitive than a barrier primitive.


> > wmb is supposed to order all writes coming out of a single CPU, so that's
> > pretty simple.
> 
> No. wmb orders all *normal* writes coming out of a single CPU.

I'm pretty sure wmb() should order *all* writes, and smp_wmb() is what
you're thinking of for ordering regular writes to cacheable memory.
 

> It may not do anything at all for "uncached" IO writes that aren't part of 
> the cache coherency, and that are handled using totally different queues 
> (both inside and outside of the CPU)!
> 
> Now, on x86, the CPU actually tends to order IO writes *more* than it 
> orders any other writes (they are mostly entirely synchronous, unless the 
> area has been marked as write merging), but at least on PPC, it's the 
> other way around: without the cache as a serialization entry, you end up 
> having a totally separate queueu to serialize, and a regular-memory write 
> barrier does nothing at all to the IO queue.

Well PPC AFAIKS doesn't need the special synchronisation semantics of
this mmiowb primitive -- the reason it is not a noop is because the API
seems to also imply a wmb() (which is fine, and you'd normally want that
eg.  uncacheable stores must be ordered with the spin_unlock store).

It is just implemented with the PPC sync instruction, which just orders
all stores coming out of _this_ CPU. Their IO fabric must prevent IOs
from being reordered between CPUs if they're executed in a known order
(which is what Altix does not prevent).

 
> So think of the IO write queue as something totally asynchronous that has 
> zero connection to the normal write ordering - and then think of mmiowb() 
> as a way to *insert* a synchronization point.

If wmb (the non _smp one) orders all stores including IO stores, then it
should be sufficient to prevent IO writes from leaking out of a critical
section. The problem is that the "reader" (the IO device) itself is not
coherent. So _synchronisation_ point is right; it is not really a barrier.
Basically it says all IO writes issued by this CPU at this point will be
seen before any other IO writes issued by any other CPUs subsequently.

make_mmio_coherent()? queue_mmio_writes()? (I'd still prefer some kind of
acquire/release API that shows why CPU/CPU order matters too, and how it
is taken care of).


> > It really seems like it is some completely different concept from a
> > barrier. And it shows, on the platform where it really matters (sn2), where
> > the thing actually spins.
> 
> I agree that it probably isn't a "write barrier" per se. Think of it as a 
> "tie two subsystems together" thing.

Yes, in a way it is more like that. Which does fit with my suggestions
for a name.


> (And it doesn't just matter on sn2. It also matters on powerpc64, although 
> I think they just set a flag and do the *real* sync in the spin_unlock() 
> path).
> 
> Side note: the thing that makes "mmiowb()" even more exciting is that it's 
> not just the CPU, it's the fabric outside the CPU that matters too. That's 
> why the sn2 needs this - but the powerpc example shows a case where the 
> ordering requirement actually comes from the CPU itself.

Well I think sn2 is the *only* reason it matters.  When the ordering
requirement is coming from the CPU itself, that *is* just a traditional
write barrier (one which orders normal and io writes).

The funny things powerpc are doing in spin_unlock/etc. are a different
issue. Basically they are just helping along device drivers who get this
wrong and assume spinlocks order IOs; our lack of an acquire/release API
for IOs... they're just trying to get through this sorry state of affairs
without going insane ;) Powerpc is special here because their ordering
instructions distinguish between normal and IO, wheras most others don't
(including ia64, alpha, etc), so _most_ others do get their IOs ordered by
critical sections. This is a different issue to the mmiowb one (but still
shows that our APIs could be improved).

Why don't we get a nice easy spin_lock_io/spin_unlock_io, which takes
care of all the mmiowb and iowrite vs spin unlock problems? (individual
IOs within the lock would still need to be ordered as approprite).

Then we could also have a serialize_io()/unserialize_io() that takes
care of the same things but can be used when we have something other
than a spinlock for ordering CPUs (serialize_io may be a noop, but it
is good to ensure people are thinking about how they're excluding
other CPUs here -- if other CPUs are not excluded, then any code calling
mmiowb is buggy, right?).

