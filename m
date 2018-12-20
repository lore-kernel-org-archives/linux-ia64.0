From: Christoph Hellwig <hch@lst.de>
Date: Thu, 20 Dec 2018 16:46:08 +0000
Subject: Re: [PATCH 15/15] dma-mapping: bypass indirect calls for dma-direct
Message-Id: <20181220164608.GA20000@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de> <20181207190720.18517-16-hch@lst.de> <20181220164418.GA18777@ulmo>
In-Reply-To: <20181220164418.GA18777@ulmo>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thierry Reding <thierry.reding@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, Dec 20, 2018 at 05:44:18PM +0100, Thierry Reding wrote:
> On Fri, Dec 07, 2018 at 11:07:20AM -0800, Christoph Hellwig wrote:
> [...]
> > diff --git a/kernel/dma/mapping.c b/kernel/dma/mapping.c
> > index 0b18cfbdde95..fc84c81029d9 100644
> > --- a/kernel/dma/mapping.c
> > +++ b/kernel/dma/mapping.c
> [...]
> > @@ -397,9 +404,9 @@ int dma_supported(struct device *dev, u64 mask)
> >  {
> >  	const struct dma_map_ops *ops = get_dma_ops(dev);
> >  
> > -	if (!ops)
> > -		return 0;
> > -	if (!ops->dma_supported)
> > +	if (dma_is_direct(ops))
> > +		return dma_direct_supported(dev, mask);
> > +	if (ops->dma_supported)
> >  		return 1;
> >  	return ops->dma_supported(dev, mask);
> >  }
> 
> Hi Christoph,
> 
> This hunk causes a crash on boot for me. It looks like a ! got lost in
> the rework here. The following patch fixes the crash for me and restores
> the logic of the op->dma_supported check.
> 
> Feel free to squash this patch into the above if you prefer that.

I don't want to rebase, so I'll pick this up ASAP.
