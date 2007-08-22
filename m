From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2007 18:07:32 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
In-Reply-To: <20070822045714.GD26374@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org



On Wed, 22 Aug 2007, Nick Piggin wrote:
> 
> It took me more than a glance to see what the difference is supposed to be
> between wmb() and mmiowb(). I think especially because mmiowb isn't really
> like a write barrier.

Well, it is, but it isn't. Not on its own - but together with a "normal" 
barrier it is.

> wmb is supposed to order all writes coming out of a single CPU, so that's
> pretty simple.

No. wmb orders all *normal* writes coming out of a single CPU.

It may not do anything at all for "uncached" IO writes that aren't part of 
the cache coherency, and that are handled using totally different queues 
(both inside and outside of the CPU)!

Now, on x86, the CPU actually tends to order IO writes *more* than it 
orders any other writes (they are mostly entirely synchronous, unless the 
area has been marked as write merging), but at least on PPC, it's the 
other way around: without the cache as a serialization entry, you end up 
having a totally separate queueu to serialize, and a regular-memory write 
barrier does nothing at all to the IO queue.

So think of the IO write queue as something totally asynchronous that has 
zero connection to the normal write ordering - and then think of mmiowb() 
as a way to *insert* a synchronization point.

In particular, the normal synchronization primitives (spinlocks, mutexes 
etc) are guaranteed to synchronize only normal memory accesses. So if you 
do MMIO inside a spinlock, since the MMIO writes are totally asyncronous 
wrt the normal memory accesses, the MMIO write can escape outside the 
spinlock unless you have somethign that serializes the MMIO accesses with 
the normal memory accesses.

So normally you'd see "mmiowb()" always *paired* with a normal memory 
barrier! The "mmiowb()" ends up synchronizing the MMIO writes with the 
normal memory accesses, and then the normal memory barrier acts as a 
barrier for subsequent writes.

Of course, the normal memory barrier would usually be a "spin_unlock()" or 
something like that, not a "wmb()". In fact, I don't think the powerpc 
implementation (as an example of this) will actually synchronize with 
anything *but* a spin_unlock().

> It really seems like it is some completely different concept from a
> barrier. And it shows, on the platform where it really matters (sn2), where
> the thing actually spins.

I agree that it probably isn't a "write barrier" per se. Think of it as a 
"tie two subsystems together" thing.

(And it doesn't just matter on sn2. It also matters on powerpc64, although 
I think they just set a flag and do the *real* sync in the spin_unlock() 
path).

Side note: the thing that makes "mmiowb()" even more exciting is that it's 
not just the CPU, it's the fabric outside the CPU that matters too. That's 
why the sn2 needs this - but the powerpc example shows a case where the 
ordering requirement actually comes from the CPU itself.

			Linus
