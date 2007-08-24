From: Nick Piggin <npiggin@suse.de>
Date: Fri, 24 Aug 2007 03:09:05 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070824030904.GC6989@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
	<1187886462.5972.17.camel@localhost.localdomain>
In-Reply-To: <1187886462.5972.17.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Jesse Barnes <jesse.barnes@intel.com>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

On Thu, Aug 23, 2007 at 06:27:42PM +0200, Benjamin Herrenschmidt wrote:
> On Thu, 2007-08-23 at 09:16 -0700, Linus Torvalds wrote:
> > 
> > On Thu, 23 Aug 2007, Nick Piggin wrote:
> > > 
> > > Also, FWIW, there are some advantages of deferring the mmiowb thingy
> > > until the point of unlock.
> > 
> > And that is exactly what ppc64 does.
> > 
> > But you're missing a big point: for 99.9% of all hardware, mmiowb() is a 
> > total no-op. So when you talk about "advantages", you're not talking about 
> > any *real* advantage, are you?
> 
> I wonder whether it might be worth removing mmiowb and having all archs
> that matter do like ppc64 though... It's just yet another confusing
> barrier that most driver writers get wrong..

Only sn2 and powerpc really matter, actually (for different reasons).

All smp architectures other than powerpc appear to have barrier
instructions that order all memory operations, so IOs never leak
out of locking primitives. This is why powerpc wants a wmb (not
mmiowb) before spin_unlock to order IOs (pity about other locking
primitives).

And all platforms other than sn2 don't appear to reorder IOs after
they leave the CPU, so only sn2 needs to do the mmiowb thing before
spin_unlock.
