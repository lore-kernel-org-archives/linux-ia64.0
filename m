From: Nick Piggin <npiggin@suse.de>
Date: Thu, 23 Aug 2007 02:20:43 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070823022043.GB18788@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
In-Reply-To: <200708221202.12403.jesse.barnes@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jesse.barnes@intel.com>
Cc: linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

On Wed, Aug 22, 2007 at 12:02:11PM -0700, Jesse Barnes wrote:
> On Wednesday, August 22, 2007 11:07 am Linus Torvalds wrote:
> > > It really seems like it is some completely different concept from a
> > > barrier. And it shows, on the platform where it really matters
> > > (sn2), where the thing actually spins.
> >
> > I agree that it probably isn't a "write barrier" per se. Think of it
> > as a "tie two subsystems together" thing.
> 
> Right, maybe it's not the best name, but as long as you separate your 
> memory access types, you can think of it as a real write barrier, just 
> for mmio accesses (well uncached access really).

If we have the following situation (all vars start at 0)
CPU0			CPU1			CPU2
spin_lock(&lock);				~
A = 1;						~
wmb();						~
B = 2;						~
spin_unlock(&lock);				X = B;
			spin_lock(&lock);	rmb();
			A = 10;			Y = A;
			wmb();			~
			B = 11;			~
			spin_unlock(&lock);	~

(I use the '~' just to show CPU2 is not specifically temporally
related to CPU0 or CPU1).

Then CPU2 could have X=11 and Y=1, according to the Linux abstract
memory consistency model, couldn't it? I think so, and I think this
is what your mmiowb is trying to protect. In the above situation,
CPU2 would just use the spinlock -- I don't think we have a simple
primitive that CPU0 and 1 can call to prevent this reordering at
CPU2. An IO device obviously can't use a spinlock :).


> > (And it doesn't just matter on sn2. It also matters on powerpc64,
> > although I think they just set a flag and do the *real* sync in the
> > spin_unlock() path).
> 
> Yeah, they keep threatening to use this instead, but I'm not sure how 
> easy it would be.  Also they may have more devices/drivers to worry 
> about than sn2, so maybe changing over would mean too much driver 
> debugging (well auditing really since it's not that hard to know where 
> to put them).  Irix actually had an io_unlock() routine that did this 
> implicitly, but iirc that was shot down for Linux...

Why was it shot down? Seems like a pretty good idea to me ;)

I'm clueless when it comes to drivers, but I see a lot of mmiowb()
that are not paired with spin_unlock. How are these obvious? (ie.
what is the pattern?) It looks like some might be lockless FIFOs (or
maybe I'm just not aware of where the locks are). Can you just quickly
illustrate the problem being solved?

Thanks,
Nick
