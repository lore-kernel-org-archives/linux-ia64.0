From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 21 Dec 2004 21:28:39 +0000
Subject: Re: [PATCH] add legacy resources to sysfs
Message-Id: <20041221212839.GF31261@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <200412211247.44883.jbarnes@engr.sgi.com>
In-Reply-To: <200412211247.44883.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, willy@debian.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Bjorn Helgaas <bjorn.helgaas@hp.com>

On Tue, Dec 21, 2004 at 12:47:44PM -0800, Jesse Barnes wrote:
> + * Find the base of legacy memory for @dev.  This is typically the first
> + * megabyte of bus address space for @dev or is simply 0 on platforms whose
> + * chipsets support legacy I/O and memory routing.  Returns 0 on success
> + * or a standard error code on failure.
> +int ia64_pci_get_legacy_mem(struct pci_bus *bus, unsigned long *addr)
> +{
> +	*addr = 0;
> +	return 0;
> +}

This is a slightly klunky interface.  How about:

 * Find the base of legacy memory for @dev.  This is typically the first
 * megabyte of bus address space for @dev or is simply 0 on platforms whose
 * chipsets support legacy I/O and memory routing.  Returns the base address
 * or an error pointer if an error occurred

The generic one is too trivial to demonstrate with, but the sn2 one
makes more sense:

> === arch/ia64/sn/pci/pci_dma.c 1.2 vs edited ==> +int sn_pci_get_legacy_mem(struct pci_bus *bus, unsigned long *addr)
> +{
> +	if (!SN_PCIBUS_BUSSOFT(bus))
> +		return -ENODEV;
> +
> +	*addr = SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem | __IA64_UNCACHED_OFFSET;
> +
> +	return 0;
> +}

int sn_pci_get_legacy_mem(struct pci_bus *bus)
{
	if (!SN_PCIBUS_BUSSOFT(bus))
		return ERR_PTR(-ENODEV);
	return SN_PCIBUS_BUSSOFT(bus)->bs_legacy_mem | __IA64_UNCACHED_OFFSET;
}

>  	b->class_dev.class = &pcibus_class;
>  	sprintf(b->class_dev.class_id, "%04x:%02x", pci_domain_nr(b), bus);
>  	error = class_device_register(&b->class_dev);
> +
>  	if (error)
>  		goto class_dev_reg_err;

Actually, I rather dislike having the newline there.  It implies a logical
separation between registering and testing for the error, whereas the logical
separation is much more like this:

        b->class_dev.class = &pcibus_class;
        sprintf(b->class_dev.class_id, "%04x:%02x", pci_domain_nr(b), bus);
	error = class_device_register(&b->class_dev);
	if (error)
		goto class_dev_reg_err;

	error = class_device_create_file(...)

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
