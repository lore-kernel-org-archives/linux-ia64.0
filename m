From: Paul Burton <paul.burton@mips.com>
Date: Mon, 19 Aug 2019 20:57:30 +0000
Subject: Re: [PATCH 04/26] mips: remove ioremap_cachable
Message-Id: <20190819205722.4eir2edy6qgtgarl@pburton-laptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190817073253.27819-1-hch@lst.de>
 <20190817073253.27819-5-hch@lst.de>
In-Reply-To: <20190817073253.27819-5-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>, Guo Ren <guoren@kernel.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>, Vincent Chen <deanbo422@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "linux-hexagon@vger.kernel.org" <linux-hexagon@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-xtensa@linux-xtensa.org" <linux-xtensa@linux-xtensa.org>, Arnd Bergmann <arnd@arndb.de>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "openrisc@lists.librecores.org" <openrisc@lists.librecores.org>, Greentime Hu <green.hu@gmail.com>, linux-mtd@list

Hi Christoph,

On Sat, Aug 17, 2019 at 09:32:31AM +0200, Christoph Hellwig wrote:
> Just define ioremap_cache directly.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Acked-by: Paul Burton <paul.burton@mips.com>

Thanks,
    Paul

> ---
>  arch/mips/include/asm/io.h | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/arch/mips/include/asm/io.h b/arch/mips/include/asm/io.h
> index 97a280640daf..c02db986ddf5 100644
> --- a/arch/mips/include/asm/io.h
> +++ b/arch/mips/include/asm/io.h
> @@ -262,11 +262,11 @@ static inline void __iomem *ioremap_prot(phys_addr_t offset,
>  #define ioremap_uc ioremap_nocache
>  
>  /*
> - * ioremap_cachable -	map bus memory into CPU space
> + * ioremap_cache -	map bus memory into CPU space
>   * @offset:	    bus address of the memory
>   * @size:	    size of the resource to map
>   *
> - * ioremap_nocache performs a platform specific sequence of operations to
> + * ioremap_cache performs a platform specific sequence of operations to
>   * make bus memory CPU accessible via the readb/readw/readl/writeb/
>   * writew/writel functions and the other mmio helpers. The returned
>   * address is not guaranteed to be usable directly as a virtual
> @@ -276,9 +276,8 @@ static inline void __iomem *ioremap_prot(phys_addr_t offset,
>   * the CPU.  Also enables full write-combining.	 Useful for some
>   * memory-like regions on I/O busses.
>   */
> -#define ioremap_cachable(offset, size)					\
> +#define ioremap_cache(offset, size)					\
>  	__ioremap_mode((offset), (size), _page_cachable_default)
> -#define ioremap_cache ioremap_cachable
>  
>  /*
>   * ioremap_wc     -   map bus memory into CPU space
> -- 
> 2.20.1
> 
