From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Fri, 24 Sep 2004 05:52:29 +0000
Subject: Re: [ACPI] [PATCH] PCI IRQ resource deallocation support [2/3]
Message-Id: <20040924.145229.108814142.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <414FEBDB.2050201@soft.fujitsu.com>
	<200409210857.59457.bjorn.helgaas@hp.com>
	<4150D458.3050400@jp.fujitsu.com>
In-Reply-To: <4150D458.3050400-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kaneshige.kenji-+CUm20s59erQFUHtdCDX3A@public.gmane.org
Cc: bjorn.helgaas-VXdhtT5mjnY@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, kaneshige.kenji-tPnzhWqfZ96MLkP6nYsO9A@public.gmane.org, akpm-3NddpPZAyC0@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Subject: Re: [ACPI] [PATCH] PCI IRQ resource deallocation support [2/3]
Date: Wed, 22 Sep 2004 10:24:40 +0900

> >> +  * dev->irq is cleared by BIOS-assigned IRQ set during boot.
> >> +  */
> >> + pci_read_config_byte(dev, PCI_INTERRUPT_PIN, &irq);
> >> + if (irq)
> >> +  pci_read_config_byte(dev, PCI_INTERRUPT_LINE, &irq);
> >> + dev->irq = irq;
> > 
> > Why do we need to fiddle with dev->irq?  I think it should
> > just be undefined after acpi_pci_irq_disable().
> 
> I had been considering what the "undefined dev->irq" was.
> In fact, I had other ideas that was clearing it by zero or
> -1 (0xffffffff). But I didn't know if we can use these values
> as a undefined IRQ number. So I'm clearing it by the value
> which was assigned by PCI core code (pci_read_irq()) before
> acpi_pci_irq_enable() was called. 

I think it has little sense in restoring value from the configuration
space to dev->irq or clearing it.

If we do preventive programming, it may be worth
trying to define some magic constant (e.g. PCI_UNDEFINED_IRQ) and
panic/BUG when the irq is being enabled.
Otherwise, leaving dev->irq as it is would be ok.

---
Takayoshi Kochi <t-kochi@bq.jp.nec.com>
