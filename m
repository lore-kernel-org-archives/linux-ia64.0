From: Greg KH <greg@kroah.com>
Date: Thu, 09 Jun 2005 16:53:53 +0000
Subject: Re: [PATCH 01/10] IOCHK interface for I/O error handling/detecting
Message-Id: <20050609165353.GB9597@kroah.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <42A8386F.2060100@jp.fujitsu.com> <42A83A8F.9020503@jp.fujitsu.com>
In-Reply-To: <42A83A8F.9020503@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Linas Vepstas <linas@austin.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, long <tlnguyen@snoqualmie.dp.intel.com>, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev <linuxppc64-dev@ozlabs.org>

On Thu, Jun 09, 2005 at 09:48:15PM +0900, Hidetoshi Seto wrote:
> --- linux-2.6.11.11.orig/lib/iomap.c
> +++ linux-2.6.11.11/lib/iomap.c
> @@ -210,3 +210,29 @@ void pci_iounmap(struct pci_dev *dev, vo
>  }
>  EXPORT_SYMBOL(pci_iomap);
>  EXPORT_SYMBOL(pci_iounmap);
> +
> +/*
> + * Clear/Read iocookie to check IO error while using iomap.
> + *
> + * Note that default iochk_clear-read pair interfaces don't have
> + * any effective error check, but some high-reliable platforms
> + * would provide useful information to you.
> + * And note that some action may be limited (ex. irq-unsafe)
> + * between the pair depend on the facility of the platform.
> + */
> +#ifndef HAVE_ARCH_IOMAP_CHECK
> +void iochk_init(void) { ; }
> +
> +void iochk_clear(iocookie *cookie, struct pci_dev *dev)
> +{
> +	/* no-ops */
> +}

A bit of a coding style difference between the two functions, yet they
do the same thing :)

> +
> +int iochk_read(iocookie *cookie)
> +{
> +	/* no-ops */
> +	return 0;
> +}

Why not just return the cookie?  Can this ever fail?

Shouldn't these go into a .h file and be made "static inline" so they
just compile away to nothing?

> +EXPORT_SYMBOL(iochk_clear);
> +EXPORT_SYMBOL(iochk_read);

EXPORT_SYMBOL_GPL() perhaps?

> +#endif /* HAVE_ARCH_IOMAP_CHECK */
> Index: linux-2.6.11.11/include/asm-generic/iomap.h
> =================================> --- linux-2.6.11.11.orig/include/asm-generic/iomap.h
> +++ linux-2.6.11.11/include/asm-generic/iomap.h
> @@ -60,4 +60,20 @@ struct pci_dev;
>  extern void __iomem *pci_iomap(struct pci_dev *dev, int bar, unsigned long 
>  max);
>  extern void pci_iounmap(struct pci_dev *dev, void __iomem *);
> 
> +/*
> + * IOMAP_CHECK provides additional interfaces for drivers to detect
> + * some IO errors, supports drivers having ability to recover errors.
> + *
> + * All works around iomap-check depends on the design of "iocookie"
> + * structure. Every architecture owning its iomap-check is free to
> + * define the actual design of iocookie to fit its special style.
> + */
> +#ifndef HAVE_ARCH_IOMAP_CHECK
> +typedef unsigned long iocookie;
> +#endif

Why typedef this if it isn't specified?

thanks,

greg k-h
