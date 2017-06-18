From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 18 Jun 2017 09:54:02 +0000
Subject: Re: [PATCH 42/44] powerpc/cell: use the dma_supported method for ops switching
Message-Id: <1497779642.31581.6.camel@kernel.crashing.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170616181059.19206-1-hch@lst.de>
 <20170616181059.19206-43-hch@lst.de>
 <1497732627.2897.128.camel@kernel.crashing.org>
 <20170618071344.GB18526@infradead.org>
In-Reply-To: <20170618071344.GB18526@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-mips@linux-mips.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-c6x-dev@linux-c6x.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-xtensa@linux-xtensa.org, x86@kernel.org, linux-tegra@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, dmaengine@vger.kernel.org, iommu@lists.linux-foundation.org, openrisc@lists.librecores.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, xen-devel@lists.xenproject.org, linuxppc-dev@lists.ozlabs.org, Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org

On Sun, 2017-06-18 at 00:13 -0700, Christoph Hellwig wrote:
> On Sun, Jun 18, 2017 at 06:50:27AM +1000, Benjamin Herrenschmidt wrote:
> > What is your rationale here ? (I have missed patch 0 it seems).
> 
> Less code duplication, more modular dma_map_ops insteance.
> 
> > dma_supported() was supposed to be pretty much a "const" function
> > simply informing whether a given setup is possible. Having it perform
> > an actual switch of ops seems to be pushing it...
> 
> dma_supported() is already gone from the public DMA API as it doesn't
> make sense to be called separately from set_dma_mask.  It will be
> entirely gone in the next series after this one.

Ah ok, in that case it makes much more sense, we can rename it then.

> > What if a driver wants to test various dma masks and then pick one ?
> > 
> > Where does the API documents that if a driver calls dma_supported() it
> > then *must* set the corresponding mask and use that ?
> 
> Where is the API document for _any_ of the dma routines? (A: work in
> progress by me, but I need to clean up the mess of arch hooks before
> it can make any sense)

Heh fair enough.

> > I don't like a function that is a "boolean query" like this one to have
> > such a major side effect.
> > 
> > > From an API standpoint, dma_set_mask() is when the mask is established,
> > 
> > and thus when the ops switch should happen.
> 
> And that's exactly what happens at the driver API level.  It just turns
> out the dma_capable method is they way better place to actually
> implement it, as the ->set_dma_mask method requires lots of code
> duplication while not offering any actual benefit over ->dma_capable.
> And because of that it's gone after this series.
> 
> In theory we could rename ->dma_capable now, but it would require a
> _lot_ of churn.  Give me another merge window or two and we should
> be down to be about 2 handful of dma_map_ops instance, at which point
> we could do all this gratious renaming a lot more easily :)

Sure, I get it now, as long as it's not publicly exposed to drivers
we are fine.

Cheers,
Ben.

