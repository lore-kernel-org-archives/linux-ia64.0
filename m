From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 26 Jan 2006 17:20:45 +0000
Subject: Re: [PATCH] RESEND - SN: Add initial ACPI support
Message-Id: <200601261020.45802.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060123160003.30149.60885.sendpatchset@attica.americas.sgi.com>
In-Reply-To: <20060123160003.30149.60885.sendpatchset@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

On Monday 23 January 2006 09:00, John Keller wrote:
> +obj-$(CONFIG_IA64_SGI_SN2)	+= acpi-ext.o

Just FYI, this code is moving into drivers/acpi soon.  Robert Moore
might have made a trivial interface change when he integrated it into
the ACPI CA.  No big deal, basically acpi-ext.c was arch-independent
and we moved it to generic code.

> + * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for

s/strcuture/structure/

>  /*
> - * sn_pci_controller_fixup() - This routine sets up a bus's resources
> - * consistent with the Linux PCI abstraction layer.
> + * sn_common_bus_fixup()
>   */

Nit: A comment that merely restates the function name is useless.
Actually, it's worse than useless because it takes up space and
requires maintenance.

> +void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)

This function looks very much like pci_acpi_scan_root().  Is this the
old, non-ACPI path?

> +	printk(KERN_INFO "ACPI  DSDT OEM Rev 0x%x\n",
> +	       acpi_gbl_DSDT->oem_revision);

Doesn't ACPI print something like this for you already?  (I think it's
KERN_DEBUG now, so usually not on the console, but still in dmesg.)

> +static int __init
> +sn_io_fixup(void)
> +{
> +	struct pci_bus *bus;
> +	struct pci_dev *pci_dev = NULL;
> +	extern void sn_init_cpei_timer(void);
> +#ifdef CONFIG_PROC_FS
> +	extern void register_sn_procfs(void);
> +#endif
> +
> +	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
> +		return 0;
> +
> +	/* Exit if running with old PROM without ACPI support */
> +	if (!SN_ACPI_BASE_SUPPORT())
> +		return 0;
> +
> +	sn_irq_lh_init();
> +	INIT_LIST_HEAD(&sn_sysdata_list);
> +	sn_init_cpei_timer();

Seems like a weird place to call sn_init_cpei_timer().  I guess I
have no idea what the CPEI stuff is, but it looks like it *could*
report platform errors other than PCI.  And you probably want to
call it even if you don't have ACPI support, don't you?

> +
> +#ifdef CONFIG_PROC_FS
> +	register_sn_procfs();
> +#endif
> +
> +	/*
> +	 * Generic Linux PCI Layer has created the pci_bus and pci_dev
> +	 * structures - time for us to add our SN Platform specific
> +	 * information.
> +	 */
> +
> +	bus = NULL;
> +	while ((bus = pci_find_next_bus(bus)) != NULL)
> +		sn_pci_bus_fixup(bus);
> +
> +	while ((pci_dev > +		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
> +		sn_pci_fixup_slot(pci_dev);
> +	}

You're doing these fixups with an fs_initcall().  I think they should
be done by hooking into pcibios_fixup_bus() (maybe we need a new platform
vector or optional function pointer there; I think PPC has something
like that already).  The initcall scheme won't work if you hot-plug
things.

Bjorn

