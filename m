From: Jesse Barnes <jesse.barnes@intel.com>
Date: Thu, 23 Aug 2007 17:02:38 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <200708231002.39429.jesse.barnes@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
In-Reply-To: <20070823022043.GB18788@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>
Cc: linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linuxppc-dev@ozlabs.org

> > Yeah, they keep threatening to use this instead, but I'm not sure
> > how easy it would be.  Also they may have more devices/drivers to
> > worry about than sn2, so maybe changing over would mean too much
> > driver debugging (well auditing really since it's not that hard to
> > know where to put them).  Irix actually had an io_unlock() routine
> > that did this implicitly, but iirc that was shot down for Linux...
>
> Why was it shot down? Seems like a pretty good idea to me ;)

Well, like Linus said, it had some significant downsides (though I think 
Irix had fewer lock types, so the multiplicative effect wasn't so bad 
there).

> I'm clueless when it comes to drivers, but I see a lot of mmiowb()
> that are not paired with spin_unlock. How are these obvious? (ie.
> what is the pattern?) It looks like some might be lockless FIFOs (or
> maybe I'm just not aware of where the locks are). Can you just
> quickly illustrate the problem being solved?

Wow, it certainly has proliferated since it was added to the tree. :)

I didn't audit all the uses, but it seems like many of them get it 
right, i.e. mmiowb() before spin_unlock() where PIO has been done.  I'd 
have to look carefully to see whether lockless usages are correct, it's 
likely they're not.

Jesse
