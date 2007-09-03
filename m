From: Nick Piggin <npiggin@suse.de>
Date: Mon, 03 Sep 2007 20:48:01 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070903204801.GB11502@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
	<1187886462.5972.17.camel@localhost.localdomain>
	<20070824030904.GC6989@wotan.suse.de>
	<20070828151737.P5403@pkunk.americas.sgi.com>
	<20070829005904.GB25335@wotan.suse.de>
	<20070829125651.L13320@pkunk.americas.sgi.com>
	<20070830033643.GB26257@wotan.suse.de>
	<20070830134057.L22183@pkunk.americas.sgi.com>
In-Reply-To: <20070830134057.L22183@pkunk.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Brent Casavant <bcasavan@sgi.com>
Cc: linuxppc-dev@ozlabs.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-ia64@vger.kernel.org, Anton Blanchard <anton@samba.org>

On Thu, Aug 30, 2007 at 02:42:41PM -0500, Brent Casavant wrote:
> On Thu, 30 Aug 2007, Nick Piggin wrote:
> 
> > I don't know whether this is exactly a correct implementation of
> > Linux's barrier semantics. On one hand, wmb _is_ ordering the stores
> > as they come out of the CPU; on the other, it isn't ordering normal
> > stores with respect to writel from the POV of the device (which is
> > seems to be what is expected by the docs and device driver writers).
> 
> Or, as I think of it, it's not ordering cacheable stores with respect
> to uncacheable stores from the perspective of other CPUs in the system.
> That's what's really at the heart of the concern for SN2.

AFAIKS, the issue is simply that it is not ordering cacheable stores
with respect to uncacheable stores from a _single_ CPU. I'll elaborate
further down.


> > And on the other side, it just doesn't seem so useful just to know
> > that stores coming out of the CPU are ordered if they can be reordered
> > by an intermediate.
> 
> Well, it helps when certain classes of stores need to be ordered with
> respect to eachother.  On SN2, wmb() still ensures that cacheable stores
> are issued in a particular order, and thus seen by other CPUs in a
> particular order.  That is still important, even when IO devices are not
> in the mix.

Well, we have smp_wmb() for that.


> > Why even have wmb() at all, if it doesn't actually
> > order stores to IO and RAM?
> 
> It orders the class of stores which target RAM.  It doesn't order the
> two seperate classes of stores (RAM and IO) with respect to eachother.

wmb() *really* is supposed to order all stores. As far as I gather,
devices often need it for something like this:

*dma_buffer = blah;
wmb();
writel(START_DMA, iomem);

One problem for sn2 seems to be that wmb is called like 500 times in
drivers/ and would be really heavy to turn it into mmiowb. On the
other hand, I really don't like how it's just gone and said "oh the
normal Linux semantics are too hard, so make wmb() mean something
slightly different, and add a totally new mmiowb() concept". Device
driver writers already get barriers totally wrong. mmiowb is being
completely misused already (and probably wmb too).


> mmiowb() when used in conjunction with a lock which serializes access
> to an IO device ensures that the order of stores to the IO device from
> different CPUs is well-defined.  That's what we're really after here.

But if we're pragmatic, we could say that stores which are sitting in
the CPU's chipset where they can potentially be reordered, can still
_conceptually_ be considered to be in some kind of store queue of the
CPU. This would mean that wmb() does have to order these WRT cacheable
stores coming from a single CPU.

And once you do that, sn2 will _also_ do the right thing with multiple
CPUs.


> > I guess it is too expensive for you to have mmiowb() in every wmb(),
> > because _most_ of the time, all that's needed is ordering between IOs.
> 
> I think it's the other way around.  Most of the time all you need is
> ordering between RAM stores, so mmiowb() would kill performance if it
> was called every time wmb() was invoked.

No, we have smp_wmb() for that.

 
> > So why not have io_mb(), io_rmb(), io_wmb(), which order IOs but ignore
> > system memory. Then the non-prefixed primitives order everything (to the
> > point that wmb() is like mmiowb on sn2).
> 
> I'm not sure I follow.  Here's the bad sequence we're working with:
> 
> 	CPU A		CPU B		Lock owner	IO device sees 
> 	-----		-----		----------	--------------
> 	...		...		unowned
> 	lock()		...		CPU A
> 	writel(val_a)	lock()		...
> 	unlock()			CPU B
> 	...		write(val_b)	...
> 	...		unlock()	unowned
> 	...		...		...		val_b
> 	...		...		...		val_a
> 
> 
> The cacheable store to RAM from CPU A to perform the unlock was
> not ordered with respect to the uncacheable writel() to the IO device.
> CPU B, which has a different uncacheable store path to the IO device
> in the NUMA system, saw the effect of the RAM store before CPU A's
> uncacheable store arrived at the IO device.  CPU B then owned the
> lock, performed its own uncacheable store to the IO device, and
> released the lock.  The two uncacheable stores are taking different
> routes to the device, and end up arriving in the wrong order.
> 
> mmiowb() solves this by causing the following:
> 
> 	CPU A		CPU B		Lock owner	IO device sees 
> 	-----		-----		----------	--------------
> 	...		...		Unowned
> 	lock()		...		CPU A
> 	writel(val_a)	lock()		...
> 	mmiowb()			...		val_a
> 	unlock()			CPU B
> 	...		write(val_b)	...
> 	...		mmiowb()	...		val_b
> 	...		unlock()	unowned
> 
> The mmiowb() caused the IO device to see the uncacheable store from
> CPU A before CPU B saw the cacheable store from CPU A.  Now all is
> well with the world.
> 
> I might be exhausting your patience, but this is the key.  mmiowb()
> causes the IO fabric to see the effects of an uncacheable store
> before other CPUs see the effects of a subsequent cacheable store.
> That's what's really at the heart of the matter.

Yes, I like this, and this is what wmb() should do :) That's what
Linux expects it to do.

 
> > Now I guess it's strictly also needed if you want to ensure cacheable
> > stores and IO stores are visible to the device in the correct order
> > too. I think we'd normally hope wmb() does that for us too (hence all
> > my rambling above).
> 
> There's really three perspectives to consider, not just the CPU and IO
> device:
> 
> 	1. CPU A performing locking and issuing IO stores.
> 	2. The IO device receiving stores.
> 	3. CPU B performing locking and issuing IO stores.
> 
> The lock ensures that the IO device sees stores from a single CPU
> at a time.  wmb() ensures that CPU A and CPU B see the effect
> of cacheable stores in the same order as eachother.  mmiowb()
> ensures that the IO device has seen all the uncacheable stores from
> CPU A before CPU B sees the cacheable stores from CPU A.
> 
> Wow.  I like that last paragraph.  I think I'll send now...

OK, now we _could_ consider the path to the IO device to be a 3rd
party that can reorder the IOs, but I'm coming to think that such
a concept need not be added if we instead consider that the reordering
portion is still part of the originating CPU and thus subject to a
wmb().

I was talking with Linus about this today, and he might have had an
opinion. He didn't like my io_wmb() idea, but instead thinks that
_every_ IO operation should be ordered WRT one another (eg. get rid
of the fancy __relaxed ones). That's fine, and once you do that,
you can get rid of lots of wmb(), and wmb() remains just for the
places where you want to order cacheable and uncacheable stores.
And now that wmb() is called much less often, you can define it
to actually match the expected Linux model.

I'm really not just trying to cause trouble here ;) The ordering details
of IO and IO/memory seems to be a mess -- it is defined differently for
different architectures, barriers are doing different things, *writel*
etc. functions have different ordering rules depending on the arch, etc.


