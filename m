From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 01 Mar 2005 13:01:22 +0000
Subject: Re: Badness in iosapic_unregister_intr
Message-Id: <20050301130122.GH28741@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Mar 01, 2005 at 01:51:48PM +0900, Kenji Kaneshige wrote:
> I think the following patch will fix this problem.
> Could you try it?

Yes, it does.  Thank you!

Rebooting... ACPI: PCI interrupt for device 0000:a1:04.0 disabled
GSI 60 (level, low) -> vector 51 unregisterd.
ACPI: PCI interrupt for device 0000:a1:04.1 disabled
GSI 61 (level, low) -> vector 52 unregisterd.
ACPI: PCI interrupt for device 0000:a1:06.0 disabled
GSI 62 (level, low) -> vector 53 unregisterd.
ACPI: PCI interrupt for device 0000:a1:06.1 disabled
GSI 63 (level, low) -> vector 54 unregisterd.
ACPI: PCI interrupt for device 0000:c0:01.0 disabled
GSI 71 (level, low) -> vector 55 unregisterd. 
Synchronizing SCSI cache for disk sdb:
Restarting system.

> Thanks,
> Kenji Kaneshige
> --
> 
> This patch fix the error check in acpi_pci_irq_disable().
> 
> Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
> 
> 
> ---
> 
> linux-2.6.11-rc5-kanesige/drivers/acpi/pci_irq.c |    6 +++---
> 1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff -puN drivers/acpi/pci_irq.c~fix_acpi_pci_irq_disable 
> drivers/acpi/pci_irq.c
> --- linux-2.6.11-rc5/drivers/acpi/pci_irq.c~fix_acpi_pci_irq_disable 
> 2005-03-01 13:50:24.000000000 +0900
> +++ linux-2.6.11-rc5-kanesige/drivers/acpi/pci_irq.c	2005-03-01 
> 13:50:24.000000000 +0900
> @@ -460,7 +460,7 @@ void
> acpi_pci_irq_disable (
> 	struct pci_dev		*dev)
> {
> -	u32			gsi = 0;
> +	int			gsi = 0;
> 	u8			pin = 0;
> 	int			edge_level = ACPI_LEVEL_SENSITIVE;
> 	int			active_high_low = ACPI_ACTIVE_LOW;
> @@ -487,10 +487,10 @@ acpi_pci_irq_disable (
> 	 * If no PRT entry was found, we'll try to derive an IRQ from the
> 	 * device's parent bridge.
> 	 */
> -	if (!gsi)
> +	if (gsi < 0)
>  		gsi = acpi_pci_irq_derive(dev, pin,
> 					  &edge_level, &active_high_low);
> -	if (!gsi)
> +	if (gsi < 0)
> 		return_VOID;
> 
> 	/*
> 
> _
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
