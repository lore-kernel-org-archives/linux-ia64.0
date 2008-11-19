From: John Keller <jpk@sgi.com>
Date: Wed, 19 Nov 2008 16:12:23 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <200811191612.mAJGCNCJ040231@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: fujita.tomonori@lab.ntt.co.jp
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 18 Nov 2008
Fujita Tomonori wrote:

> On Mon, 17 Nov 2008 10:24:54 -0600
> John Keller <jpk@sgi.com> wrote:

> > Create a platform specific version of dma_get_required_mask()
> > for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
> > addressing regardless of the size of system memory.
> > Create a ia64 machvec for dma_get_required_mask, with the
> > SN version unconditionally returning DMA_64BIT_MASK.
> > 
> > 
> > Signed-off-by: John Keller <jpk@sgi.com>
> > ---
> > 
> >  Documentation/DMA-API.txt            |    9 ++++-----
> >  arch/ia64/include/asm/dma-mapping.h  |    3 +++
> >  arch/ia64/include/asm/machvec.h      |    7 +++++++
> >  arch/ia64/include/asm/machvec_init.h |    1 +
> >  arch/ia64/include/asm/machvec_sn2.h  |    2 ++
> >  arch/ia64/pci/pci.c                  |   21 +++++++++++++++++++++
> >  arch/ia64/sn/pci/pci_dma.c           |    6 ++++++
> >  include/linux/dma-mapping.h          |    2 ++
> >  8 files changed, 46 insertions(+), 5 deletions(-)
> 
> (snip)
> 
> >  static int __init pcibios_init(void)
> >  {
> >  	set_pci_cacheline_size();
> > Index: linux-2.6/include/linux/dma-mapping.h
> > =================================> > --- linux-2.6.orig/include/linux/dma-mapping.h	2008-11-17 08:38:07.740451313 -0600
> > +++ linux-2.6/include/linux/dma-mapping.h	2008-11-17 08:39:50.573284674 -0600
> > @@ -70,7 +70,9 @@ static inline u64 dma_get_mask(struct de
> >  	return DMA_32BIT_MASK;
> >  }
> >  
> > +#ifndef CONFIG_IA64
> >  extern u64 dma_get_required_mask(struct device *dev);
> > +#endif
> 
> I think that adding CONFIG_IA64 to include/linux/dma-mapping.h is
> wrong. I also think that you don't need to ifndef this extern.

Without this change ia64 would not build for me.


> 
> If you need this trick with only CONFIG_IA64_SGI_SN2, how about
> something like this? It's simple and we can avoid duplicate the
> generic dma_get_required_mask in arch/ia64/pci/pci.c

Actually I need it for CONFIG_IA64_GENERIC and CONFIG_IA64_SGI_SN2.
But, even so, unfortunately your suggestion doesn't build.

I see numerous errors such as these:

kernel/fork.o: In function `__crc_dma_get_required_mask':
fork.c:(*ABS*+0xb0339303): multiple definition of `__crc_dma_get_required_mask'
kernel/exit.o: In function `__crc_dma_get_required_mask':
exit.c:(*ABS*+0x4a7c4115): multiple definiti  CC      fs/sysfs/group.o
on of `__crc_dma_get_required_mask'



> 
> 
> diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
> index bbab7e2..4ffbd18 100644
> --- a/arch/ia64/include/asm/dma-mapping.h
> +++ b/arch/ia64/include/asm/dma-mapping.h
> @@ -144,6 +144,13 @@ static inline struct dma_mapping_ops *get_dma_ops(struct device *dev)
> 	return dma_ops;
> }
> 
> -
> +#ifdef CONFIG_IA64_SGI_SN2
> +#define ARCH_HAS_DMA_GET_REQUIRED_MASK
> +static inline u64 dma_get_required_mask(struct device *dev)
> +{
> +	return DMA_64BIT_MASK;
> +}
> +EXPORT_SYMBOL_GPL(dma_get_required_mask);
> +#endif
>  
> #endif /* _ASM_IA64_DMA_MAPPING_H */
