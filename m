From: John Keller <jpk@sgi.com>
Date: Thu, 20 Nov 2008 22:57:41 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <200811202257.mAKMvgGO061606@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20081120135023M.fujita.tomonori@lab.ntt.co.jp> from "FUJITA Tomonori" at Nov 20, 2008 01:49:27 PM
References: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20081117162454.169426.74531.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

> 
> On Wed, 19 Nov 2008 10:12:23 -0600 (CST)
> John Keller <jpk@sgi.com> wrote:
> 
> > On Tue, 18 Nov 2008
> > Fujita Tomonori wrote:
> > 
> > > On Mon, 17 Nov 2008 10:24:54 -0600
> > > John Keller <jpk@sgi.com> wrote:
> > 
> > > > Create a platform specific version of dma_get_required_mask()
> > > > for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
> > > > addressing regardless of the size of system memory.
> > > > Create a ia64 machvec for dma_get_required_mask, with the
> > > > SN version unconditionally returning DMA_64BIT_MASK.
> > > > 
> > > > 
> > > > Signed-off-by: John Keller <jpk@sgi.com>
> > > > ---
> > > > 
> > > >  Documentation/DMA-API.txt            |    9 ++++-----
> > > >  arch/ia64/include/asm/dma-mapping.h  |    3 +++
> > > >  arch/ia64/include/asm/machvec.h      |    7 +++++++
> > > >  arch/ia64/include/asm/machvec_init.h |    1 +
> > > >  arch/ia64/include/asm/machvec_sn2.h  |    2 ++
> > > >  arch/ia64/pci/pci.c                  |   21 +++++++++++++++++++++
> > > >  arch/ia64/sn/pci/pci_dma.c           |    6 ++++++
> > > >  include/linux/dma-mapping.h          |    2 ++
> > > >  8 files changed, 46 insertions(+), 5 deletions(-)
> > > 
> > > (snip)
> > > 
> > > >  static int __init pcibios_init(void)
> > > >  {
> > > >  	set_pci_cacheline_size();
> > > > Index: linux-2.6/include/linux/dma-mapping.h
> > > > =================================> > > > --- linux-2.6.orig/include/linux/dma-mapping.h	2008-11-17 08:38:07.740451313 -0600
> > > > +++ linux-2.6/include/linux/dma-mapping.h	2008-11-17 08:39:50.573284674 -0600
> > > > @@ -70,7 +70,9 @@ static inline u64 dma_get_mask(struct de
> > > >  	return DMA_32BIT_MASK;
> > > >  }
> > > >  
> > > > +#ifndef CONFIG_IA64
> > > >  extern u64 dma_get_required_mask(struct device *dev);
> > > > +#endif
> > > 
> > > I think that adding CONFIG_IA64 to include/linux/dma-mapping.h is
> > > wrong. I also think that you don't need to ifndef this extern.
> > 
> > Without this change ia64 would not build for me.
> 
> Odd. It works for me. Can you send your .config?

It built with CONFIG_IA64_SGI_SN2, but not CONFIG_IA64_GENERIC.
The error was related to the machvec magic, where the extern was
transformed into:

extern u64 ia64_mv.dma_get_required_mask(struct device *dev);

and the error was:

include/linux/dma-mapping.h:73: error: expected '=', ',' ';', 'asm' or '__attribute__' before '.' token

I'll be resubmitting the patch with this fixed and the #ifndef removed.



> 
> 
> > > If you need this trick with only CONFIG_IA64_SGI_SN2, how about
> > > something like this? It's simple and we can avoid duplicate the
> > > generic dma_get_required_mask in arch/ia64/pci/pci.c
> > 
> > Actually I need it for CONFIG_IA64_GENERIC and CONFIG_IA64_SGI_SN2.
> 
> Hmm, but your patch puts sn_dma_get_required_mask in
> arch/ia64/sn/pci/pci_dma.c. arch/ia64/sn/pci/pci_dma.c is compiled
> only with CONFIG_IA64_SGI_SN2?

No, arch/ia64/sn/pci/pci_dma.c is complied with CONFIG_IA64_GENERIC
as well, and if the kernel is booted on a SN2 platform, the
sn_machvec becomes the default.


> 
> 
> > But, even so, unfortunately your suggestion doesn't build.
> > 
> > I see numerous errors such as these:
> > 
> > kernel/fork.o: In function `__crc_dma_get_required_mask':
> > fork.c:(*ABS*+0xb0339303): multiple definition of `__crc_dma_get_required_mask'
> > kernel/exit.o: In function `__crc_dma_get_required_mask':
> > exit.c:(*ABS*+0x4a7c4115): multiple definiti  CC      fs/sysfs/group.o
> > on of `__crc_dma_get_required_mask'
> 
> Odd, it works for me. Looks that #define
> ARCH_HAS_DMA_GET_REQUIRED_MASK doesn't work. I'll try this with your
> .config.

Your suggested fix would work for CONFIG_IA64_SGI_SN2, but
we need it to work for CONFIG_IA64_GENERIC kernels as well, which
is what I was building when seeing these errors.



> 
> Thanks,
> 
> 
> > > 
> > > 
> > > diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
> > > index bbab7e2..4ffbd18 100644
> > > --- a/arch/ia64/include/asm/dma-mapping.h
> > > +++ b/arch/ia64/include/asm/dma-mapping.h
> > > @@ -144,6 +144,13 @@ static inline struct dma_mapping_ops *get_dma_ops(struct device *dev)
> > > 	return dma_ops;
> > > }
> > > 
> > > -
> > > +#ifdef CONFIG_IA64_SGI_SN2
> > > +#define ARCH_HAS_DMA_GET_REQUIRED_MASK
> > > +static inline u64 dma_get_required_mask(struct device *dev)
> > > +{
> > > +	return DMA_64BIT_MASK;
> > > +}
> > > +EXPORT_SYMBOL_GPL(dma_get_required_mask);
> > > +#endif
> > >  
> > > #endif /* _ASM_IA64_DMA_MAPPING_H */
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 

