From: Grant Grundler <iod00d@hp.com>
Date: Thu, 05 Aug 2004 21:24:00 +0000
Subject: Re: [BROKEN PATCH] kexec for ia64
Message-Id: <20040805212400.GJ6526@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200407261524.40804.jbarnes@engr.sgi.com>
In-Reply-To: <200407261524.40804.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Aug 05, 2004 at 12:56:00PM -0600, Eric W. Biederman wrote:
> Interesting.. One of the things we identified is that the kernel
> that comes up in this scenario will need truly paranoid device
> initialization code, so it can get the devices it chooses to use
> functioning from any state.   For the IOMMU things don't look
> differently.  The code will need to be tweaked so that it is
> sufficiently paranoid. 

Ok - but killing DMA would make this a NOP and prevents the
offending IO card from spewing potentially corrupt data to 
remote targets.

> I'm not certain how receiving an unmapped DMA request should be
> handled but there should be methods that are less drastic than
> crashing the kernel.  Crashing the kernel only seems sane
> during driver debugging.

It's sane *any time*. Or would you rather have the IO device
scribbling garbage on your root disk?
I'd rather have the box go down with a higher chance that
no corrupt data made it to media.

> One suggestion and I believe that still applies is to have a delay
> to allow existing in-flight DMA transfers to flush themselves.

Maybe. But that's also non-deterministic depending on the type
of IO device and how independent it is. Eg. RX rings on a NIC
may only slowly fill - harmless if we don't ever handle the
interrupts, look at the incoming data, or touch the IOMMU.
TX Rings are more likely to be bounded to fairly short times
before they are drained.

...
> It may also make sense to reserve a small portion of the IOMMU
> for the recovery kernel and not use that chunk of the IOMMU
> for the normal kernel.  That would allow valid DMA transactions
> the recovery kernel initiated to be recognized.

That's an interesting idea. I'm skepitical it's feasible though.
I need to think about the trade offs here.

And I'm still really very nervous about not shooting down inflight DMA.
For clusters, this is especially important (prevent on-disk shared data
from getting clobbered).

> Ok. It looks like the IOMMU case needs some more looking into.  But
> I think we are on the right track.
> 
> Would a reserved chunk of the IOMMU address space work?  I know things
> are scarce but we could probably deal with as little as 1M.

Scarcity of IOMMU resource is the lesser of my worries. We no longer
depend as much on IOMMU for IA64. parisc still fully depends on it
as do some other less common arches.

thanks,
grant
