From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Tue, 01 Mar 2005 04:51:48 +0000
Subject: Re: Badness in iosapic_unregister_intr
Message-Id: <4223F4E4.2050109@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20050228180600.GB28741@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Matthew,

Matthew Wilcox wrote:
> Not sure where the problem lies on this one ...
> 
> On an hp rx4640, at shutdown of an unmodified 2.6.11-rc5 kernel, I get:
> 
> Rebooting... ACPI: PCI interrupt for device 0000:a1:04.0 disabled
> iosapic_unregister_intr(4294967295) unbalanced
> Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
> ACPI: PCI interrupt for device 0000:a1:04.1 disabled
> iosapic_unregister_intr(4294967295) unbalanced
> Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
> ACPI: PCI interrupt for device 0000:a1:06.0 disabled
> iosapic_unregister_intr(4294967295) unbalanced
> Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
> ACPI: PCI interrupt for device 0000:a1:06.1 disabled
> iosapic_unregister_intr(4294967295) unbalanced
> Badness in iosapic_unregister_intr at arch/ia64/kernel/iosapic.c:636
> 
> Anyone else seeing it?  I wonder if it only happens for devices behind
> a PCI-PCI bridge:
> 
> 0000:a0:02.0 PCI bridge: IBM PCI-X to PCI-X Bridge (rev 02)
> 0000:a1:04.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
> 0000:a1:04.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
> 0000:a1:06.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
> 0000:a1:06.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (rev 01)
> 

I think the following patch will fix this problem.
Could you try it?

Thanks,
Kenji Kaneshige
--

This patch fix the error check in acpi_pci_irq_disable().

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>


---

 linux-2.6.11-rc5-kanesige/drivers/acpi/pci_irq.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff -puN drivers/acpi/pci_irq.c~fix_acpi_pci_irq_disable drivers/acpi/pci_irq.c
--- linux-2.6.11-rc5/drivers/acpi/pci_irq.c~fix_acpi_pci_irq_disable	2005-03-01 13:50:24.000000000 +0900
+++ linux-2.6.11-rc5-kanesige/drivers/acpi/pci_irq.c	2005-03-01 13:50:24.000000000 +0900
@@ -460,7 +460,7 @@ void
 acpi_pci_irq_disable (
 	struct pci_dev		*dev)
 {
-	u32			gsi = 0;
+	int			gsi = 0;
 	u8			pin = 0;
 	int			edge_level = ACPI_LEVEL_SENSITIVE;
 	int			active_high_low = ACPI_ACTIVE_LOW;
@@ -487,10 +487,10 @@ acpi_pci_irq_disable (
 	 * If no PRT entry was found, we'll try to derive an IRQ from the
 	 * device's parent bridge.
 	 */
-	if (!gsi)
+	if (gsi < 0)
  		gsi = acpi_pci_irq_derive(dev, pin,
 					  &edge_level, &active_high_low);
-	if (!gsi)
+	if (gsi < 0)
 		return_VOID;
 
 	/*

_

