From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 21 Sep 2004 14:57:59 +0000
Subject: Re: [ACPI] [PATCH] PCI IRQ resource deallocation support [2/3]
Message-Id: <200409210857.59457.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <414FEBDB.2050201@soft.fujitsu.com>
In-Reply-To: <414FEBDB.2050201@soft.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net
Cc: Kenji Kaneshige <kaneshige.kenji@soft.fujitsu.com>, akpm@osdl.org, greg@kroah.com, len.brown@intel.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

On Tuesday 21 September 2004 2:52 am, Kenji Kaneshige wrote:
> + * This function undoes the effect of one call to acpi_register_gsi().
> + * If this matches the last regstration, any IRQ resources for gsi

s/regstration/registration/ (also other occurrences below).

> +void
> +acpi_pci_irq_disable (
> + struct pci_dev  *dev)
> +{
> + unsigned char irq_disabled, irq;

pci_dev.irq is unsigned int, not unsigned char, so irq_disabled
should be unsigned int as well.

> +  * dev->irq is cleared by BIOS-assigned IRQ set during boot.
> +  */
> + pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &irq);
> + if (irq)
> +  pci_read_config_byte(dev, PCI_INTERRUPT_LINE, &irq);
> + dev->irq = irq;

Why do we need to fiddle with dev->irq?  I think it should
just be undefined after acpi_pci_irq_disable().
