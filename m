From: Christoph Hellwig <hch@lst.de>
Date: Thu, 04 Jan 2018 09:02:51 +0000
Subject: Re: [PATCH 30/67] dma-direct: retry allocations using GFP_DMA for small masks
Message-Id: <20180104090251.GE3251@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
	<20171229081911.2802-31-hch@lst.de>
	<f6139b03-0a4a-a9fe-4818-9b0bccf419e4@arm.com>
In-Reply-To: <f6139b03-0a4a-a9fe-4818-9b0bccf419e4-5wv7dgnIgG8@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vladimir Murzin <vladimir.murzin-5wv7dgnIgG8@public.gmane.org>
Cc: linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>, linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-c6x-dev-jPsnJVOj+W6hPH1hqNUYSQ@public.gmane.org, linux-hexagon-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-snps-arc-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, adi-buildroot-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-m68k-cunTk1MwBs8S/qaLPR03pWD2FQJk+8+b@public.gmane.org, patches-q3qR2WxjNRFS9aJRtSZj7A@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org

On Tue, Jan 02, 2018 at 04:43:15PM +0000, Vladimir Murzin wrote:
> On 29/12/17 08:18, Christoph Hellwig wrote:
> > If we got back an allocation that wasn't inside the support coherent mask,
> > retry the allocation using GFP_DMA.
> > 
> > Based on the x86 code.
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > ---
> >  lib/dma-direct.c | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> > 
> > diff --git a/lib/dma-direct.c b/lib/dma-direct.c
> > index ab81de3ac1d3..f8467cb3d89a 100644
> > --- a/lib/dma-direct.c
> > +++ b/lib/dma-direct.c
> > @@ -28,6 +28,11 @@ check_addr(struct device *dev, dma_addr_t dma_addr, size_t size,
> >  	return true;
> >  }
> >  
> > +static bool dma_coherent_ok(struct device *dev, phys_addr_t phys, size_t size)
> > +{
> > +	return phys_to_dma(dev, phys) + size <= dev->coherent_dma_mask;
> 
> Shouldn't it be: phys_to_dma(dev, phys) + size - 1 <= dev->coherent_dma_mask ?

Yes, I think it should.  The existing code was blindly copy and pasted
from x86.

> > +	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
> > +		__free_pages(page, page_order);
> > +		page = NULL;
> > +
> > +		if (dev->coherent_dma_mask < DMA_BIT_MASK(32) &&
> > +		    !(gfp & GFP_DMA)) {
> > +			gfp = (gfp & ~GFP_DMA32) | GFP_DMA;
> > +			goto again;
> 
> Shouldn't we limit number of attempts?

We only retty once anyway, due to the !GFP_DMA check first and then
ORing in GFP_DMA.
