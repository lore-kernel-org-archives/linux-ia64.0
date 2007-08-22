From: Jesse Barnes <jesse.barnes@intel.com>
Date: Wed, 22 Aug 2007 19:02:11 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <200708221202.12403.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, linux-ia64@vger.kernel.org, linuxppc-dev@ozlabs.org

On Wednesday, August 22, 2007 11:07 am Linus Torvalds wrote:
> > It really seems like it is some completely different concept from a
> > barrier. And it shows, on the platform where it really matters
> > (sn2), where the thing actually spins.
>
> I agree that it probably isn't a "write barrier" per se. Think of it
> as a "tie two subsystems together" thing.

Right, maybe it's not the best name, but as long as you separate your 
memory access types, you can think of it as a real write barrier, just 
for mmio accesses (well uncached access really).

> (And it doesn't just matter on sn2. It also matters on powerpc64,
> although I think they just set a flag and do the *real* sync in the
> spin_unlock() path).

Yeah, they keep threatening to use this instead, but I'm not sure how 
easy it would be.  Also they may have more devices/drivers to worry 
about than sn2, so maybe changing over would mean too much driver 
debugging (well auditing really since it's not that hard to know where 
to put them).  Irix actually had an io_unlock() routine that did this 
implicitly, but iirc that was shot down for Linux...

Jesse
