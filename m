From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 07 Feb 2005 14:32:43 +0000
Subject: Re: [PATCH 2.6.11-rc2 3/3] altix: tioca chip driver (agp)
Message-Id: <20050207143243.GA14410@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
In-Reply-To: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> +#include <linux/types.h>
> +#include <linux/interrupt.h>
> +#include <linux/pci.h>
> +#include <asm/sn/sn_sal.h>
> +#include <asm/sn/addrs.h>
> +#include <asm/sn/pcidev.h>
> +#include <asm/sn/pcibus_provider_defs.h>
> +#include "xtalk/xwidgetdev.h"
> +#include <asm/sn/tioca_provider.h>

Private headers after <asm/*> headers, please.  If tioca_provider.h needs
xwidgetdev.h the latter should move to <asm/sn/>

> +uint32_t tioca_gart_found;
> +EXPORT_SYMBOL(tioca_gart_found);	/* used by agp-sgi */
> +
> +LIST_HEAD(tioca_list);
> +EXPORT_SYMBOL(tioca_list);		/* used by agp-sgi */

All the exports aren't nice because they expose internals.  In cases
where AGP and PCI iommu code are similar interwinded (e.g. alpha and amd64)
we made building the agpgart code builin mandatory which sounds like the
way to go for altix aswell.

> +	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;

do you need the cast here?

> +	tioca_kern->ca_gart = (u64 *) page_address(tmp);

no need to cast.

> +	    kcalloc(1, tioca_kern->ca_pcigart_entries / 8, GFP_ATOMIC);

You just did a GFP_KERNEL allocation higher up in the same function,
so the GFP_ATOMIC shouldn't be nessecary here?

>
> +	if (!tioca_kern) {
> +		return -1;
> +	}

And you're leaking the previous allocation here.

> +
> +	/*
> +	 * Program the aperature and gart registers in TIOCA
> +	 */
> +
> +	ca_base->ca_gart_aperature = ap_reg;
> +	ca_base->ca_gart_ptr_table > +	    (uint64_t) (tioca_kern->ca_gart_coretalk_addr) | 1;

ca_gart_coretalk_addr already is uint64_t, no need to cast.

> +	list_for_each(tmp, tioca_kern->ca_devices) {
> +		pdev = pci_dev_b(tmp);

list_for_each_entry() please

> +	list_for_each(tmp, tioca_kern->ca_devices) {
> +		pdev = pci_dev_b(tmp);

dito

> +		if (pdev->class != (PCI_CLASS_DISPLAY_VGA << 8)) {
> +			continue;
> +		}

superflous braces.

> +/**
> + * tioca_dma_d64 - create a DMA mapping using 64-bit direct mode
> + * @paddr: system physical address
> + *
> + * Map @paddr into 64-bit CA bus space.  No device context is necessary.
> + */
> +static uint64_t
> +tioca_dma_d64(unsigned long paddr)
> +{
> +	dma_addr_t bus_addr;
> +
> +	/*
> +	 * 64 bit direct map is easy ... bits 53:0 come from the above
> +	 * coretalk address.  We just need to mask in the following optional
> +	 * bits of the 64-bit pci address:
> +	 *
> +	 *      63:60 - Coretalk Packet Type -  0x1 for Mem Get/Put (coherent)
> +	 *                                      0x2 for PIO (non-coherent)
> +	 *                                      We will always use 0x1
> +	 *      55:55 - Swap bytes
> +	 */
> +
> +	bus_addr = PHYS_TO_TIODMA(paddr);
> +
> +	BUG_ON(!bus_addr);
> +	BUG_ON(bus_addr >> 54);
> +
> +	/* Set upper nibble to Cache Coherent Memory op */
> +	bus_addr |= (1UL << 60);
> +
> +	return bus_addr;
> +}

little style-nipick - this would be more readable with the comment above
the function because it describes the function, ala:

/*
 * 64 bit direct map is easy ... bits 53:0 come from the above
 * coretalk address.  We just need to mask in the following optional
 * bits of the 64-bit pci address:
 *
 *      63:60 - Coretalk Packet Type -  0x1 for Mem Get/Put (coherent)
 *                                      0x2 for PIO (non-coherent)
 *                                      We will always use 0x1
 *      55:55 - Swap bytes
 */
static uint64_t
tioca_dma_d64(unsigned long paddr)
{
	dma_addr_t bus_addr = PHYS_TO_TIODMA(paddr);

	BUG_ON(!bus_addr);
	BUG_ON(bus_addr >> 54);

	/* Set upper nibble to Cache Coherent Memory op */
	return bus_addr | (1UL << 60);
}

(or even better with a kerneldoc header)

> +	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
> +	tioca_kern = (struct tioca_kernel *)tioca_common->ca_kernel_private;

no need to cast?

> +	xio_addr = PHYS_TO_TIODMA(paddr);
> +	if (!xio_addr)
> +		return 0;
> +
> +	/*
> +	 * Locate/allocate a map struct
> +	 */
> +	spin_lock_irqsave(&tioca_kern->ca_lock, flags);
> +
> +	for (ca_dmamap = tioca_kern->ca_dmamaps;
> +	     ca_dmamap != NULL; ca_dmamap = ca_dmamap->cad_next)
> +		if (ca_dmamap->cad_dma_addr = 0)
> +			break;

I don't think you should keep unused maps around but rather free them.

> +
> +	if (ca_dmamap = NULL) {
> +		ca_dmamap = (struct tioca_dmamap *)
> +		    kcalloc(1, sizeof(struct tioca_dmamap), GFP_ATOMIC);

no cast needed again.

> +      map_return:

strange indentation.  goto labels are written either

foo:

or

 foo:

in the kernel

> +	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
> +	tioca_kern = (struct tioca_kernel *)tioca_common->ca_kernel_private;

again, no need to cast.

> +	request_irq(SGI_TIOCA_ERROR,
> +		    tioca_error_intr_handler,
> +		    SA_SHIRQ, "TIOCA error", (void *)tioca_common);

request_irq may retun an error/

> +int
> +tioca_init_provider(void)
> +{
> +	if (sn_sal_rev_major() < 4 || sn_sal_rev_minor() < 0x06) {
> +		printk
> +		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
> +		     "for tioca support\n", __FUNCTION__);
> +		return 0;
> +	}

isn't that a little noisy for people who have systems without the hardware
this driver actually supports?  Also the hex notation for the SAL minor
is pure obsfucation.

