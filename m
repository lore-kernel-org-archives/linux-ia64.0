From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 14 Oct 2004 12:53:48 +0000
Subject: Re: [PATCH] Introduce PCI <-> CPU address conversion [1/2]
Message-Id: <20041014125348.GA9633@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20041014124737.GM16153@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <matthew@wil.cx>
Cc: Greg KH <greg@kroah.com>, linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

> +#define IS_MEMORY(l)	(((l) & PCI_BASE_ADDRESS_SPACE) = \
> +				PCI_BASE_ADDRESS_SPACE_MEMORY)
> +#define IS_64BIT(l)	(((l) & PCI_BASE_ADDRESS_MEM_TYPE_64) != 0)

Should got to pci.h with more descriptive names

>  /*
> + * Convert between the CPU's view of addresses on a PCI card and the PCI
> + * device's view of the same location.  The default implementation is a no-op
> + * as most architectures have the same addresses on the CPU and PCI busses.
> + */
> +
> +#ifndef pci_phys_to_bus
> +#define pci_phys_to_bus(busdev, addr, flags) (addr)
> +#define pci_bus_to_phys(busdev, addr, flags) (addr)
> +#endif

I'd rather have this declared in every architectures asm/ header, so it's
more explicit that it's an per-arch thing.  Also make it a static inline
so we get typechecking.

