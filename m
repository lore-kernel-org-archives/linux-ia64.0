From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 23 Jul 2002 05:43:01 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.5.18 early printk, PCI segment, multi-IOMMU support
Message-Id: <marc-linux-ia64-105590701905813@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905804@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905804@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Mon, 22 Jul 2002 16:22:30 -0600, Bjorn Helgaas <bjorn_helgaas@hp.com> said:

  Bjorn> Tested on HP ZX1 and i2000.

  Bjorn> 10_early_printk.diff Early printk for MMIO UARTs.  UART
  Bjorn> address from HCDP or specified in config.

  Bjorn> 30_sci.diff Add acpi_irq_to_vector() to handle both legacy
  Bjorn> ISA and new GSI interrupt numbers.  Add support for SCI on
  Bjorn> GSI interrupt.

  Bjorn> 40_pcibios_segment.diff Add struct pci_controller for IA64
  Bjorn> sysdata.  Stash the PCI segment there and add support in
  Bjorn> config accessors.

  Bjorn> 50_iosapic_segment.diff Add segment support for PCI
  Bjorn> interrupts.

The above look fine to me.  I'm not really an ACPI expert so if
anybody has an issue with these (particularly the latter three), speak
up.

  Bjorn> 60_pci_tra.diff Add support for PCI root bridges with
  Bjorn> non-zero translation offsets.

This one handles only memory offsets.  Any particular reason for this?
Perhaps there should be at least a check which will warn/panic if a
non-zero I/O offset is found?

  Bjorn> 70_enable_device.diff Add a platform vector for
  Bjorn> pci_enable_device().  ZX1 needs this to associate a device
  Bjorn> with the correct IOMMU.

Hmmh, are you expecting other platform-specific work will have to be
done in pci_enable_device() in the future?  If all we really need here
is a platform-specific PCI-device -> IOMMU mapping, perhaps we should
call it just that.  OTOH, I can see that this is a natural callback
point.  Any comments by folks doing the hw support for other
(hotplug-capable) machines?

	--david

