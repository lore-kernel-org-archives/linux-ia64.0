From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 23 Aug 2007 02:57:56 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
In-Reply-To: <20070823022043.GB18788@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org



On Thu, 23 Aug 2007, Nick Piggin wrote:
>
> > Irix actually had an io_unlock() routine that did this 
> > implicitly, but iirc that was shot down for Linux...
> 
> Why was it shot down? Seems like a pretty good idea to me ;)

It's horrible. We'd need it for *every* single spinlock type. We have lots 
of them. 

So the choice is between:

 - sane:

	mmiowb()

   followed by any of the existing "spin_unlock()" variants (plain, 
   _irq(), _bh(), _irqrestore())

 - insane: multiply our current set of unlock primitives by two, by making 
   "io" versions for them all:

	spin_unlock_io[_irq|_irqrestore|_bh]()

but there's actually an EVEN WORSE problem with the stupid Irix approach, 
namely that it requires that the unlocker be aware of the exact details of 
what happens inside the lock. If the locking is done at an outer layer, 
that's not at all obvious!

In other words, Irix (once again) made a horrible and idiotic choice. 

Big surprise. Irix was probably the flakiest and worst of all the 
commercial proprietary unixes. No taste.

		Linus
