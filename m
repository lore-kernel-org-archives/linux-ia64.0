From: Greg KH <gregkh@suse.de>
Date: Wed, 31 May 2006 23:34:08 +0000
Subject: Re: [PATCH 1/2] - Altix: Add initial ACPI support
Message-Id: <20060531233408.GA21244@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060531212320.32044.49013.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20060531212320.32044.49013.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net

On Wed, May 31, 2006 at 04:23:20PM -0500, John Keller wrote:
> Index: acpi-support/arch/ia64/pci/pci.c
> =================================> --- acpi-support.orig/arch/ia64/pci/pci.c	2006-05-31 12:37:50.539921986 -0500
> +++ acpi-support/arch/ia64/pci/pci.c	2006-05-31 14:10:50.889146925 -0500
> @@ -470,10 +470,11 @@ pcibios_fixup_resources(struct pci_dev *
>  	}
>  }
>  
> -static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
> +void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
>  {
>  	pcibios_fixup_resources(dev, 0, PCI_BRIDGE_RESOURCES);
>  }
> +EXPORT_SYMBOL(pcibios_fixup_device_resources);

EXPORT_SYMBOL_GPL() perhaps?

> --- acpi-support.orig/include/linux/pci.h	2006-05-31 12:37:50.647911309 -0500
> +++ acpi-support/include/linux/pci.h	2006-05-31 14:10:50.989137400 -0500
> @@ -397,6 +397,7 @@ extern struct bus_type pci_bus_type;
>  extern struct list_head pci_root_buses;	/* list of all known PCI buses */
>  extern struct list_head pci_devices;	/* list of all devices */
>  
> +void __devinit pcibios_fixup_device_resources(struct pci_dev *);

Don't put __devinit on a function prototype.  It does nothing.

thanks,

greg k-h
