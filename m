From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
Date: Wed, 06 Jul 2005 06:26:27 +0000
Subject: Re: [PATCH 2.6.13-rc1 01/10] IOCHK interface for I/O error
Message-Id: <20050706.152627.68274440.yoshfuji@linux-ipv6.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42CB63B2.6000505@jp.fujitsu.com>
In-Reply-To: <42CB63B2.6000505@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: seto.hidetoshi@jp.fujitsu.com
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com, linas@austin.ibm.com, benh@kernel.crashing.org, tlnguyen@snoqualmie.dp.intel.com, linux-pci@atrey.karlin.mff.cuni.cz, linuxppc64-dev@ozlabs.org, yoshfuji@linux-ipv6.org

In article <42CB63B2.6000505@jp.fujitsu.com> (at Wed, 06 Jul 2005 13:53:06 +0900), Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> says:

> Index: linux-2.6.13-rc1/lib/iomap.c
> =================================> --- linux-2.6.13-rc1.orig/lib/iomap.c
> +++ linux-2.6.13-rc1/lib/iomap.c
> @@ -230,3 +230,9 @@ void pci_iounmap(struct pci_dev *dev, vo
>   }
>   EXPORT_SYMBOL(pci_iomap);
>   EXPORT_SYMBOL(pci_iounmap);
> +
> +#ifndef HAVE_ARCH_IOMAP_CHECK
> +/* Since generic funcs are inlined and defined in header, just export */
> +EXPORT_SYMBOL(iochk_clear);
> +EXPORT_SYMBOL(iochk_read);
> +#endif
> Index: linux-2.6.13-rc1/include/asm-generic/iomap.h
> =================================> --- linux-2.6.13-rc1.orig/include/asm-generic/iomap.h
> +++ linux-2.6.13-rc1/include/asm-generic/iomap.h
:
> + */
> +#ifdef HAVE_ARCH_IOMAP_CHECK
> +extern void iochk_init(void);
> +extern void iochk_clear(iocookie *cookie, struct pci_dev *dev);
> +extern int iochk_read(iocookie *cookie);
> +#else
> +static inline void iochk_init(void) {}
> +static inline void iochk_clear(iocookie *cookie, struct pci_dev *dev) {}
> +static inline int iochk_read(iocookie *cookie) { return 0; }
> +#endif
> +
>   #endif

It looks strange to me.
You cannot export "static inline" functions.
You can export iochk_{init,clear,read} only
if HAVE_ARCH_IOMAP_CHECK is defined.

--yoshfuji
