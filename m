From: Alex Williamson <alex.williamson@hp.com>
Date: Thu, 23 Jun 2005 21:17:34 +0000
Subject: Re: [PATCH] pcibus_to_node implementation for IA64
Message-Id: <1119561454.5963.20.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0506231400360.13123@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 2005-06-23 at 14:02 -0700, Christoph Lameter wrote:
> --- linux-2.6.12.orig/arch/ia64/hp/common/sba_iommu.c	2005-06-17 12:48:29.000000000 -0700
> +++ linux-2.6.12/arch/ia64/hp/common/sba_iommu.c	2005-06-23 13:55:02.000000000 -0700
> @@ -1930,6 +1930,9 @@ sba_connect_bus(struct pci_bus *bus)
>  		for (ioc = ioc_list; ioc; ioc = ioc->next)
>  			if (ioc->handle = handle) {
>  				PCI_CONTROLLER(bus)->iommu = ioc;
> +#ifdef CONFIG_NUMA
> +				PCI_CONTROLLER(bus)->node = ioc->node;
> +#endif
>  				return;
>  			}

   This will work, but there's no reason to hide this in the platform
specific code.  The PCI root bridges are in ACPI namespace, a
pxm_to_node() lookup should be done there when the buses are discovered.
Then it would work on HP and DIG boxes.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

