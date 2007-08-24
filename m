From: Nick Piggin <npiggin@suse.de>
Date: Fri, 24 Aug 2007 02:59:16 +0000
Subject: Re: wmb vs mmiowb
Message-Id: <20070824025916.GB6989@wotan.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070822045714.GD26374@wotan.suse.de>
	<alpine.LFD.0.999.0708221049560.30176@woody.linux-foundation.org>
	<200708221202.12403.jesse.barnes@intel.com>
	<20070823022043.GB18788@wotan.suse.de>
	<alpine.LFD.0.999.0708221953360.30176@woody.linux-foundation.org>
	<20070823042038.GI18788@wotan.suse.de>
	<alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.0.999.0708230915000.30176@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-ia64@vger.kernel.org, Jesse Barnes <jesse.barnes@intel.com>, linuxppc-dev@ozlabs.org

On Thu, Aug 23, 2007 at 09:16:42AM -0700, Linus Torvalds wrote:
> 
> 
> On Thu, 23 Aug 2007, Nick Piggin wrote:
> > 
> > Also, FWIW, there are some advantages of deferring the mmiowb thingy
> > until the point of unlock.
> 
> And that is exactly what ppc64 does.
> 
> But you're missing a big point: for 99.9% of all hardware, mmiowb() is a 
> total no-op. So when you talk about "advantages", you're not talking about 
> any *real* advantage, are you?

You're in a feisty mood today ;)

I guess on the 0.1% of hradware where it is not a noop, there might be a
real advantage... but that was just handwaving anyway. My real point was
that I'd like things to be more easily understandable.

I think we are agreed at this point that mmiowb without some form of CPU
synchronisation is a bug, and it is also not of the same type of barrier
that we normally think about in the kernel (it could be like a MPI style
rendezvous barrier between the CPU and the IO fabric). Anyway, point is
that device drivers seem to have enough on their plate already.

Look at bcm43xx, for example. Most of this guy's mmiowb()s are completely
wrong and should be wmb(). mmiowb() is only a wmb() on ppc because as I
said, ppc's spin_unlock does not order IOs like most other architectures.
On alpha, for example, spin_unlock does order IOs, so mmiowb is a noop,
and this is broken (non-sn2 ia64 should also be a noop here, because
their unlock orders IOs, but it seems that mmiowb semantics are so non
obvious that they either got it wrong themselves, or assumed device
drivers surely would).


