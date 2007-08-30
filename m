From: Brent Casavant <bcasavan@sgi.com>
Date: Thu, 30 Aug 2007 19:42:41 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070830134057.L22183@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
	<1187886462.5972.17.camel@localhost.localdomain>
	<20070824030904.GC6989@wotan.suse.de>
	<20070828151737.P5403@pkunk.americas.sgi.com>
	<20070829005904.GB25335@wotan.suse.de>
	<20070829125651.L13320@pkunk.americas.sgi.com>
	<20070830033643.GB26257@wotan.suse.de>
In-Reply-To: <20070830033643.GB26257@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linuxppc-dev@ozlabs.org, linux-ia64@vger.kernel.org

On Thu, 30 Aug 2007, Nick Piggin wrote:

> OK, thanks for that. I think I have a rough idea of how they both
> work... I was just thinking (hoping) that, although the writel may
> not reach the device before the store reaches memory, it would
> _appear_ that way from the POV of the device (ie. if the device
> were to DMA from mem). But that's probably wishful thinking because
> the memory might be on some completely different part of the system.

Exactly.  Since uncacheable writes cannot by definition take
part in a cache-coherency mechanism, they really become their
own seperate hierarchy of transactions.

> I don't know whether this is exactly a correct implementation of
> Linux's barrier semantics. On one hand, wmb _is_ ordering the stores
> as they come out of the CPU; on the other, it isn't ordering normal
> stores with respect to writel from the POV of the device (which is
> seems to be what is expected by the docs and device driver writers).

Or, as I think of it, it's not ordering cacheable stores with respect
to uncacheable stores from the perspective of other CPUs in the system.
That's what's really at the heart of the concern for SN2.

> And on the other side, it just doesn't seem so useful just to know
> that stores coming out of the CPU are ordered if they can be reordered
> by an intermediate.

Well, it helps when certain classes of stores need to be ordered with
respect to eachother.  On SN2, wmb() still ensures that cacheable stores
are issued in a particular order, and thus seen by other CPUs in a
particular order.  That is still important, even when IO devices are not
in the mix.

> Why even have wmb() at all, if it doesn't actually
> order stores to IO and RAM?

It orders the class of stores which target RAM.  It doesn't order the
two seperate classes of stores (RAM and IO) with respect to eachother.

mmiowb() when used in conjunction with a lock which serializes access
to an IO device ensures that the order of stores to the IO device from
different CPUs is well-defined.  That's what we're really after here.

> powerpc's wmb() could just as well be an
> 'eieio' if it were to follow your model; that instruction orders IO,
> but not WRT cacheable stores.

That would seem to follow the intent of mmiowb() on SN2.  I know
next to nothing about PowerPC, so I'm not qualified to comment on that.

> So you could argue that the chipset is an extention of the CPU's IO/memory
> subsystem and should follow the ordering specified by the CPU. I like this
> idea because it could make things simpler and more regular for the Linux
> barrier model.

Sorry, I didn't design the hardware. ;)

I believe the problem, for a NUMA system, is that in order to implement
what you describe, you would need the chipset to cause all effectively
dirty cachelines in the CPU (including those that will become dirty
due to previous stores which the CPU hasn't committed from its pipeline
yet) to be written back to RAM before the the uncacheable store was allowed
to issue from the chipset to the IO fabric.  This would occur for every
IO store, not just the final store in a related sequence.  That would
obviously have a significant negative impact on performance.

> I guess it is too expensive for you to have mmiowb() in every wmb(),
> because _most_ of the time, all that's needed is ordering between IOs.

I think it's the other way around.  Most of the time all you need is
ordering between RAM stores, so mmiowb() would kill performance if it
was called every time wmb() was invoked.

> So why not have io_mb(), io_rmb(), io_wmb(), which order IOs but ignore
> system memory. Then the non-prefixed primitives order everything (to the
> point that wmb() is like mmiowb on sn2).

I'm not sure I follow.  Here's the bad sequence we're working with:

	CPU A		CPU B		Lock owner	IO device sees 
	-----		-----		----------	--------------
	...		...		unowned
	lock()		...		CPU A
	writel(val_a)	lock()		...
	unlock()			CPU B
	...		write(val_b)	...
	...		unlock()	unowned
	...		...		...		val_b
	...		...		...		val_a


The cacheable store to RAM from CPU A to perform the unlock was
not ordered with respect to the uncacheable writel() to the IO device.
CPU B, which has a different uncacheable store path to the IO device
in the NUMA system, saw the effect of the RAM store before CPU A's
uncacheable store arrived at the IO device.  CPU B then owned the
lock, performed its own uncacheable store to the IO device, and
released the lock.  The two uncacheable stores are taking different
routes to the device, and end up arriving in the wrong order.

mmiowb() solves this by causing the following:

	CPU A		CPU B		Lock owner	IO device sees 
	-----		-----		----------	--------------
	...		...		Unowned
	lock()		...		CPU A
	writel(val_a)	lock()		...
	mmiowb()			...		val_a
	unlock()			CPU B
	...		write(val_b)	...
	...		mmiowb()	...		val_b
	...		unlock()	unowned

The mmiowb() caused the IO device to see the uncacheable store from
CPU A before CPU B saw the cacheable store from CPU A.  Now all is
well with the world.

I might be exhausting your patience, but this is the key.  mmiowb()
causes the IO fabric to see the effects of an uncacheable store
before other CPUs see the effects of a subsequent cacheable store.
That's what's really at the heart of the matter.

> Now I guess it's strictly also needed if you want to ensure cacheable
> stores and IO stores are visible to the device in the correct order
> too. I think we'd normally hope wmb() does that for us too (hence all
> my rambling above).

There's really three perspectives to consider, not just the CPU and IO
device:

	1. CPU A performing locking and issuing IO stores.
	2. The IO device receiving stores.
	3. CPU B performing locking and issuing IO stores.

The lock ensures that the IO device sees stores from a single CPU
at a time.  wmb() ensures that CPU A and CPU B see the effect
of cacheable stores in the same order as eachother.  mmiowb()
ensures that the IO device has seen all the uncacheable stores from
CPU A before CPU B sees the cacheable stores from CPU A.

Wow.  I like that last paragraph.  I think I'll send now...

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
