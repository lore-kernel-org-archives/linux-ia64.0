From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Mon, 25 Apr 2005 15:26:06 +0000
Subject: Re: [PATCH 2.6.12 1/1] pcdp: add PCDP pci interface support
Message-Id: <200504250926.07022.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
In-Reply-To: <20050421202619.31042.93421.39277@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Saturday 23 April 2005 12:00 pm, Mark Maule wrote:
> Resend with changes per Bjorn Helgaas comments.  Changes from original:
> 
> + Change globals to vga_console_iobase/vga_console_membase.
> + Address style-related comments.

This looks good to me, except that I think we should remove the
EFI_PCDP references below.  The idea of supporting multiple VGA
devices is completely orthogonal to the PCDP.

> +#ifdef CONFIG_EFI_PCDP
> +unsigned long vga_console_iobase;
> +unsigned long vga_console_membase;
> +#endif

> - * videoram directly without any black magic.
> + * videoram directly without any black magic.  If we're in a PCDP
> + * environment, add in the vga mmio offset supplied by the table.
>   */
>  
> +#if defined(CONFIG_EFI_PCDP)
> +extern unsigned long vga_console_iobase;
> +extern unsigned long vga_console_membase;
> +
> +#define VGA_MAP_MEM(x)	((unsigned long) ioremap(vga_console_membase + (x), 0))
> +#else
>  #define VGA_MAP_MEM(x)	((unsigned long) ioremap((x), 0))
> +#endif
