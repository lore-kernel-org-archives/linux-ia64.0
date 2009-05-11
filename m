From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 11 May 2009 22:59:02 +0000
Subject: Re: [PATCH -tip 1/5] add asm-generic/dma-mappig.h
Message-Id: <20090512080018N.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1241670948-5818-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<1241670948-5818-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
	<200905071238.05110.arnd@arndb.de>
In-Reply-To: <200905071238.05110.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: arnd@arndb.de
Cc: fujita.tomonori@lab.ntt.co.jp, linux-kernel@vger.kernel.org, mingo@elte.hu, tony.luck@intel.com, linux-ia64@vger.kernel.org

On Thu, 7 May 2009 12:38:04 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Thursday 07 May 2009, FUJITA Tomonori wrote:
> > This header file provides some generic dma mapping function
> > definitions for the users of struct dma_map_ops.
> > 
> > Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> 
> I'm currently trying to add asm-generic variants for all of
> the common headers. One of my goals there is to make them
> as complete as possible, i.e. if a header file in asm-generic
> has the same name as one in any of the architectures, it should
> IMHO provide the same (full) API.

I see.


> I would therefore suggest that you either rename the file to
> something like dma-mapping-common.h or add some template
> functions that can be overriden per architecture, like
> 
> #ifndef dma_get_ops
> static inline struct dma_map_ops *get_dma_ops(struct device *dev)
> {
> 	return dma_ops;
> }
> #endif
> #ifndef dma_alloc_coherent
> /*
>  * to be defined out of line
>  */
> extern void *dma_alloc_coherent(struct device *dev, size_t size,
> 		dma_addr_t *dma_handle, gfp_t gfp);
> #endif
> 
> Then an architecture can opt-in to do things like:
> 
> #define dma_get_ops dma_get_ops
> static inline struct dma_map_ops *get_dma_ops(struct device *dev)
> {
> 	return dev->archdata.dma_ops;
> }
> 
> before the #include <asm-generic/dma-mapping.h>

It doesn't fit for what we want with dma-mapping.h and looks really
ugly.

ok, I'll go with something like include/linux/dma-mapping-common.h.


> > +static inline dma_addr_t dma_map_single_attrs(struct device *dev, void *ptr,
> > +					      size_t size,
> > +					      enum dma_data_direction dir,
> > +					      struct dma_attrs *attrs)
> > +{
> > +	struct dma_map_ops *ops = get_dma_ops(dev);
> > +	dma_addr_t addr;
> > +
> > +	kmemcheck_mark_initialized(ptr, size);
> > +	BUG_ON(!valid_dma_direction(dir));
> > +	addr = ops->map_page(dev, virt_to_page(ptr),
> > +			     (unsigned long)ptr & ~PAGE_MASK, size,
> > +			     dir, NULL);
> > +	debug_dma_map_page(dev, virt_to_page(ptr),
> > +			   (unsigned long)ptr & ~PAGE_MASK, size,
> > +			   dir, addr, true);
> > +	return addr;
> > +}
> 
> You are not passing the dma_attrs down here, which I think you need to,
> if any of the architectures using this file want to support DMA attributes.

Yeah, thanks. It's my silly mistake. IA64 needs dma_attrs so of course
we heed to pass it down here.
