From: Nick Piggin <npiggin@suse.de>
Date: Thu, 23 Aug 2007 04:20:38 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070823042038.GI18788@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org

On Wed, Aug 22, 2007 at 07:57:56PM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 23 Aug 2007, Nick Piggin wrote:
> >
> > > Irix actually had an io_unlock() routine that did this 
> > > implicitly, but iirc that was shot down for Linux...
> > 
> > Why was it shot down? Seems like a pretty good idea to me ;)
> 
> It's horrible. We'd need it for *every* single spinlock type. We have lots 
> of them. 
> 
> So the choice is between:
> 
>  - sane:
> 
> 	mmiowb()
> 
>    followed by any of the existing "spin_unlock()" variants (plain, 
>    _irq(), _bh(), _irqrestore())
> 
>  - insane: multiply our current set of unlock primitives by two, by making 
>    "io" versions for them all:
> 
> 	spin_unlock_io[_irq|_irqrestore|_bh]()
> 
> but there's actually an EVEN WORSE problem with the stupid Irix approach, 
> namely that it requires that the unlocker be aware of the exact details of 
> what happens inside the lock. If the locking is done at an outer layer, 
> that's not at all obvious!

Also, FWIW, there are some advantages of deferring the mmiowb thingy
until the point of unlock. The disadvantage is that the caller may not
know if the inner layer performed ios that require the mmiowb, but
the advantage of waiting until unlock is that the wait is deferred
for as long as possible, and will hopefully be a shorter one when
performed later.

