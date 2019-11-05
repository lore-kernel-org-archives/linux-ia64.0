From: Helge Deller <deller@gmx.de>
Date: Tue, 05 Nov 2019 14:29:05 +0000
Subject: Re: [PATCH 07/21] parisc: remove __ioremap
Message-Id: <23dd12c1-8af2-dd97-18f2-da3203d49a48@gmx.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191029064834.23438-1-hch@lst.de>
 <20191029064834.23438-8-hch@lst.de>
In-Reply-To: <20191029064834.23438-8-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, linux-kernel@vger.kernel.org, Guo Ren <guoren@kernel.org>, sparclinux@vger.kernel.org, linux-riscv@lists.infradead.org, Vincent Chen <deanbo422@gmail.com>, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, linux-hexagon@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, Arnd Bergmann <arnd@arndb.de>, linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org, Greentime Hu <green.hu@gmail.com>, nios2-dev@lists.rocketboards.org, Guan Xuetao <gxt@pku.edu.cn>, linux-arm-kernel@lists.infradead.org, Michal Simek <monstr@monstr.eu>, linux-parisc@vger.kernel.org, linux-mips@vger.kernel.org, linux-alpha@vger.kernel.org, linux-mtd@lists.infradead.org

On 29.10.19 07:48, Christoph Hellwig wrote:
> __ioremap is always called with the _PAGE_NO_CACHE, so fold the whole
> thing and rename it to ioremap.  This also allows to remove the special
> EISA quirk to force _PAGE_NO_CACHE.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Helge Deller <deller@gmx.de>

Helge

> ---
>  arch/parisc/include/asm/io.h | 11 +----------
>  arch/parisc/mm/ioremap.c     | 10 ++++------
>  2 files changed, 5 insertions(+), 16 deletions(-)
>
> diff --git a/arch/parisc/include/asm/io.h b/arch/parisc/include/asm/io.h
> index 93d37010b375..46212b52c23e 100644
> --- a/arch/parisc/include/asm/io.h
> +++ b/arch/parisc/include/asm/io.h
> @@ -127,16 +127,7 @@ static inline void gsc_writeq(unsigned long long val, unsigned long addr)
>  /*
>   * The standard PCI ioremap interfaces
>   */
> -
> -extern void __iomem * __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
> -
> -/* Most machines react poorly to I/O-space being cacheable... Instead let's
> - * define ioremap() in terms of ioremap_nocache().
> - */
> -static inline void __iomem * ioremap(unsigned long offset, unsigned long size)
> -{
> -	return __ioremap(offset, size, _PAGE_NO_CACHE);
> -}
> +void __iomem *ioremap(unsigned long offset, unsigned long size);
>  #define ioremap_nocache(off, sz)	ioremap((off), (sz))
>  #define ioremap_wc			ioremap_nocache
>  #define ioremap_uc			ioremap_nocache
> diff --git a/arch/parisc/mm/ioremap.c b/arch/parisc/mm/ioremap.c
> index f29f682352f0..6e7c005aa09b 100644
> --- a/arch/parisc/mm/ioremap.c
> +++ b/arch/parisc/mm/ioremap.c
> @@ -25,7 +25,7 @@
>   * have to convert them into an offset in a page-aligned mapping, but the
>   * caller shouldn't need to know that small detail.
>   */
> -void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned long flags)
> +void __iomem *ioremap(unsigned long phys_addr, unsigned long size)
>  {
>  	void __iomem *addr;
>  	struct vm_struct *area;
> @@ -36,10 +36,8 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
>  	unsigned long end = phys_addr + size - 1;
>  	/* Support EISA addresses */
>  	if ((phys_addr >= 0x00080000 && end < 0x000fffff) ||
> -	    (phys_addr >= 0x00500000 && end < 0x03bfffff)) {
> +	    (phys_addr >= 0x00500000 && end < 0x03bfffff))
>  		phys_addr |= F_EXTEND(0xfc000000);
> -		flags |= _PAGE_NO_CACHE;
> -	}
>  #endif
>
>  	/* Don't allow wraparound or zero size */
> @@ -65,7 +63,7 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
>  	}
>
>  	pgprot = __pgprot(_PAGE_PRESENT | _PAGE_RW | _PAGE_DIRTY |
> -			  _PAGE_ACCESSED | flags);
> +			  _PAGE_ACCESSED | _PAGE_NO_CACHE);
>
>  	/*
>  	 * Mappings have to be page-aligned
> @@ -90,7 +88,7 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
>
>  	return (void __iomem *) (offset + (char __iomem *)addr);
>  }
> -EXPORT_SYMBOL(__ioremap);
> +EXPORT_SYMBOL(ioremap);
>
>  void iounmap(const volatile void __iomem *io_addr)
>  {
>
