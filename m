From: Matthew Wilcox <matthew@wil.cx>
Date: Fri, 14 Jan 2005 14:09:03 +0000
Subject: Re: [PATCH]: Error in ACPI error handling results in WARN_ON
Message-Id: <20050114140903.GG30982@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <41E7CE5D.3010805@sgi.com>
In-Reply-To: <41E7CE5D.3010805@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 14, 2005 at 08:51:25AM -0500, Prarit Bhargava wrote:
> The issue here is the error handling within the ACPI layer.  gsi = 0 is a
> valid return value from acpi_pci_irq_lookup, while gsi = (-1) is the value
> returned when a PRT cannot be found.

> === drivers/acpi/pci_irq.c 1.35 vs edited ==> --- 1.35/drivers/acpi/pci_irq.c	2005-01-04 21:48:17 -05:00
> +++ edited/drivers/acpi/pci_irq.c	2005-01-13 16:08:10 -05:00
> @@ -487,10 +487,10 @@
>  	 * If no PRT entry was found, we'll try to derive an IRQ from the
>  	 * device's parent bridge.
>  	 */
> -	if (!gsi)
> +	if (gsi = (-1))

Brackets here just look clumsy; better to write:

	if (gsi = -1)

>   		gsi = acpi_pci_irq_derive(dev, pin,
>  					  &edge_level, &active_high_low);
> -	if (!gsi)
> +	if (!gsi = (-1))

And this is a mistake -- you didn't remove the !  Again, it should be:

	if (gsi = -1)

> === drivers/ide/ide-probe.c 1.90 vs edited ==> --- 1.90/drivers/ide/ide-probe.c	2004-12-10 14:12:14 -05:00
> +++ edited/drivers/ide/ide-probe.c	2005-01-14 07:16:42 -05:00
> @@ -841,7 +841,11 @@
>  	if (fixup)
>  		fixup(hwif);
>  
> -	hwif_init(hwif);
> +	if (!hwif_init(hwif))
> +	{
> +		printk("%s: Failed to initialize IDE interface\n", hwif->name);
> +		return -1;
> +	}
>  
>  	if (hwif->present) {
>  		u16 unit = 0;

Please send this one to linux-ide@vger.kernel.org

> === drivers/ide/pci/sgiioc4.c 1.22 vs edited ==> --- 1.22/drivers/ide/pci/sgiioc4.c	2005-01-06 20:35:35 -05:00
> +++ edited/drivers/ide/pci/sgiioc4.c	2005-01-14 07:23:27 -05:00
> @@ -669,7 +669,11 @@
>  		printk(KERN_INFO "%s: %s Bus-Master DMA disabled\n",
>  		       hwif->name, d->name);
>  
> -	probe_hwif_init(hwif);
> +	if (probe_hwif_init(hwif))
> +	{
> +		printk(KERN_INFO "%s: initialization failed\n", hwif->name);
> +		return -EIO;
> +	}
>  
>  	/* Create /proc/ide entries */
>  	create_proc_ide_interfaces(); 

May as well send this one along with it.  BTW, the normal coding style is
to place brackets on the same line as the conditional:

	if (probe_hwif_init(hwif)) {
		printk(...)
		return -EIO;
	}

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
