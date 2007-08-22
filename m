From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Wed, 22 Aug 2007 16:51:04 +0000
Subject: Re: [PATCH 2/3] dma: override "dma_flags_set_dmaflush" for sn-ia64
Message-Id: <200708220951.05101.jbarnes@virtuousgeek.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070818002746.GU1813@sgi.com> <200708220903.23702.jbarnes@virtuousgeek.org> <1187801095.3410.49.camel@localhost.localdomain>
In-Reply-To: <1187801095.3410.49.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jes Sorensen <jes@sgi.com>, akepner@sgi.com, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, rdreier@cisco.com, linux-ia64 <linux-ia64@vger.kernel.org>

On Wednesday, August 22, 2007 9:44:55 am James Bottomley wrote:
> > The problem is a DMA write (say to a completion queue) from a device may
> > imply something about another DMA write from the same device (say the
> > actual data). If the completion queue write arrives first (which can
> > happen on sn2), the driver must ensure that the rest of the outstanding
> > DMA is complete prior to looking at the completion queue status.  It can
> > either use a regular PIO read to do this (i.e. a non-relaxed one) or set
> > a flag on the completion queue DMA address that makes it act as a barrier
> > wrt other DMA, which is what akepner's patch does (which should be much
> > more efficient that using a PIO read to guarantee DMA writes have
> > completed).
>
> This is a violation of the PCI spec, isn't it, like Matthew pointed out?
> The only time a device->host DMA transaction shouldn't follow strict
> ordering is when the device sets the relaxed hint in its PCI registers.

Yeah, it is.  Whether its allowed in PCIe depends on how you read the spec 
(but either way it would need to be explicitly enabled).

For better or for worse, Altix hardware always behaves this way (well mostly 
for the better, since most device protocols don't care as they involve PIO, 
and out of order completion is *much* faster on Altix than strict ordering).

Arthur's patch is pretty straightfoward though, so unless someone can think of 
a better way of hiding this architectural detail in lower level code it's 
probably a good thing to add (especially given that future revs of PCIe will 
probably allow this behavior, and hopefully less ambiguously than the current 
spec).

Jesse
