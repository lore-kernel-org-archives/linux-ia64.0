From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Thu, 13 May 2010 03:27:55 +0000
Subject: Re: [PATCH -mm] remove deprecated dma_sync_single and dma_sync_sg
Message-Id: <20100513122812S.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100511101308R.fujita.tomonori@lab.ntt.co.jp>
	<20100512162803.ccb05cb8.akpm@linux-foundation.org>
In-Reply-To: <20100512162803.ccb05cb8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@linux-foundation.org
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org, pete@sensoray.com, rcohen@snurgle.org, greg@kroah.com, linux-ia64@vger.kernel.org

On Wed, 12 May 2010 16:28:03 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 11 May 2010 10:13:23 +0900
> FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:
> 
> > Since 2.6.5, it had been commented, 'for backwards compatibility,
> > removed in 2.7.x'. Since 2.6.31, it have been marked as __deprecated.
> > 
> > I think that we can remove the API safely now.
> > 
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> > ---
> >  include/linux/dma-mapping.h |   15 ---------------
> >  1 files changed, 0 insertions(+), 15 deletions(-)
> > 
> > diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
> > index 2ea1494..89b7e1a 100644
> > --- a/include/linux/dma-mapping.h
> > +++ b/include/linux/dma-mapping.h
> > @@ -95,21 +95,6 @@ static inline int is_device_dma_capable(struct device *dev)
> >  #include <asm-generic/dma-mapping-broken.h>
> >  #endif
> >  
> > -/* for backwards compatibility, removed soon */
> > -static inline void __deprecated dma_sync_single(struct device *dev,
> > -						dma_addr_t addr, size_t size,
> > -						enum dma_data_direction dir)
> > -{
> > -	dma_sync_single_for_cpu(dev, addr, size, dir);
> > -}
> > -
> > -static inline void __deprecated dma_sync_sg(struct device *dev,
> > -					    struct scatterlist *sg, int nelems,
> > -					    enum dma_data_direction dir)
> > -{
> > -	dma_sync_sg_for_cpu(dev, sg, nelems, dir);
> > -}
> > -
> >  static inline u64 dma_get_mask(struct device *dev)
> >  {
> >  	if (dev && dev->dma_mask && *dev->dma_mask)
> 
> drivers/staging/go7007/saa7134-go7007.c uses dma_sync_single().

I know but drivers/staging/go7007/Makefile says:

# Uncomment when the saa7134 patches get into upstream
#ifneq ($(CONFIG_VIDEO_SAA7134),)
#obj-$(CONFIG_VIDEO_SAA7134) += saa7134-go7007.o
#EXTRA_CFLAGS += -Idrivers/media/video/saa7134 -DSAA7134_MPEG_GO7007=3
#endif

So this patch doesn't break it. But it might be better to replace the
api in it now. I'll send a patch soon.


> arch/ia64/kernel/machvec.c has functions machvec_dma_sync_single() and
> machvec_dma_sync_sg() which might be dead code.

No, they are used. The function name is deceptive though.

IA64 uses machvec_dma_sync_single() to implement
machvec_dma_sync_single_for_device() and
machvec_dma_sync_single_for_cpu()

IA64 also uses machvec_dma_sync_sg() to implement
machvec_dma_sync_sg_for_device() and machvec_dma_sync_sg_for_cpu().

IA64's dma_sync_ API works in the same way in both DMA directions.
