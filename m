From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Fri, 21 Nov 2008 05:11:45 +0000
Subject: Re: [PATCH] ia64: SN specific version of dma_get_required_mask()
Message-Id: <20081121141134K.fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081120135023M.fujita.tomonori@lab.ntt.co.jp>
	<200811202257.mAKMvgGO061606@fcbayern.americas.sgi.com>
In-Reply-To: <200811202257.mAKMvgGO061606@fcbayern.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jpk@sgi.com
Cc: fujita.tomonori@lab.ntt.co.jp, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 20 Nov 2008 16:57:41 -0600 (CST)
John Keller <jpk@sgi.com> wrote:

> > 
> > On Wed, 19 Nov 2008 10:12:23 -0600 (CST)
> > John Keller <jpk@sgi.com> wrote:
> > 
> > > On Tue, 18 Nov 2008
> > > Fujita Tomonori wrote:
> > > 
> > > > On Mon, 17 Nov 2008 10:24:54 -0600
> > > > John Keller <jpk@sgi.com> wrote:
> > > 
> > > > > Create a platform specific version of dma_get_required_mask()
> > > > > for ia64 SN Altix. All SN Altix platforms support 64 bit DMA
> > > > > addressing regardless of the size of system memory.
> > > > > Create a ia64 machvec for dma_get_required_mask, with the
> > > > > SN version unconditionally returning DMA_64BIT_MASK.
> > > > > 
> > > > > 
> > > > > Signed-off-by: John Keller <jpk@sgi.com>
> > > > > ---
> > > > > 
> > > > >  Documentation/DMA-API.txt            |    9 ++++-----
> > > > >  arch/ia64/include/asm/dma-mapping.h  |    3 +++
> > > > >  arch/ia64/include/asm/machvec.h      |    7 +++++++
> > > > >  arch/ia64/include/asm/machvec_init.h |    1 +
> > > > >  arch/ia64/include/asm/machvec_sn2.h  |    2 ++
> > > > >  arch/ia64/pci/pci.c                  |   21 +++++++++++++++++++++
> > > > >  arch/ia64/sn/pci/pci_dma.c           |    6 ++++++
> > > > >  include/linux/dma-mapping.h          |    2 ++
> > > > >  8 files changed, 46 insertions(+), 5 deletions(-)
> > > > 
> > > > (snip)
> > > > 
> > > > >  static int __init pcibios_init(void)
> > > > >  {
> > > > >  	set_pci_cacheline_size();
> > > > > Index: linux-2.6/include/linux/dma-mapping.h
> > > > > =================================> > > > > --- linux-2.6.orig/include/linux/dma-mapping.h	2008-11-17 08:38:07.740451313 -0600
> > > > > +++ linux-2.6/include/linux/dma-mapping.h	2008-11-17 08:39:50.573284674 -0600
> > > > > @@ -70,7 +70,9 @@ static inline u64 dma_get_mask(struct de
> > > > >  	return DMA_32BIT_MASK;
> > > > >  }
> > > > >  
> > > > > +#ifndef CONFIG_IA64
> > > > >  extern u64 dma_get_required_mask(struct device *dev);
> > > > > +#endif
> > > > 
> > > > I think that adding CONFIG_IA64 to include/linux/dma-mapping.h is
> > > > wrong. I also think that you don't need to ifndef this extern.
> > > 
> > > Without this change ia64 would not build for me.
> > 
> > Odd. It works for me. Can you send your .config?
> 
> It built with CONFIG_IA64_SGI_SN2, but not CONFIG_IA64_GENERIC.
> The error was related to the machvec magic, where the extern was
> transformed into:
> 
> extern u64 ia64_mv.dma_get_required_mask(struct device *dev);
> 
> and the error was:
> 
> include/linux/dma-mapping.h:73: error: expected '=', ',' ';', 'asm' or '__attribute__' before '.' token
> 
> I'll be resubmitting the patch with this fixed and the #ifndef removed.

Ok, if you don't add IA64 specific stuff to
include/linux/dma-mapping.h, I think that there is no complaint from
non IA64 developers.


> > > > If you need this trick with only CONFIG_IA64_SGI_SN2, how about
> > > > something like this? It's simple and we can avoid duplicate the
> > > > generic dma_get_required_mask in arch/ia64/pci/pci.c
> > > 
> > > Actually I need it for CONFIG_IA64_GENERIC and CONFIG_IA64_SGI_SN2.
> > 
> > Hmm, but your patch puts sn_dma_get_required_mask in
> > arch/ia64/sn/pci/pci_dma.c. arch/ia64/sn/pci/pci_dma.c is compiled
> > only with CONFIG_IA64_SGI_SN2?
> 
> No, arch/ia64/sn/pci/pci_dma.c is complied with CONFIG_IA64_GENERIC
> as well, and if the kernel is booted on a SN2 platform, the
> sn_machvec becomes the default.

Ah, I see. Thanks,
