From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 30 Jul 2002 22:14:03 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905859@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" wrote:
> Thanks for comments.

welcome...one of my favorite topics...

> But how to distinguish PCI irqs from others?

IRQ number. I assume you mean PCI vs other IO subsystems.
The pcibios support has to uniquely identify each PCI IRQ Line
with a different IRQ number. And that number space has to
be shared with all interrupt sources.

request_irq() can (does?) branch to iosapic support based on IRQ number.

> It seems that all PCI drivers pass its pci_dev structure
> as the 4th argument of request_irq, but others won't
> (for example, serial.c).

The 4th arg is a "void *". It can be anything the driver wants
to identify device instance or even NULL (see ob600 mouse driver).
Don't make any assumptions about what the 4th argument is.

> I thought allocating a new vector in request_irq() is another
> level of dynamic allocation.

It doesn't need to be. Just replaces the allocation
which happens per PCI IRQ Line or per PCI Device.

BTW, "in request_irq()" to me means in that code path, not
immediately in that function.

> Once I took another approach and wrote a version that
> allocates a new vector when a driver calls pcibios_enable,
> but it turned out to be problematic because not all PCI
> device drivers call pci_enable() at their startup.

That's a driver bug. Please submit patches to David or the driver
maintainer. cpqfc driver doesn't call pci_enable_device() either.
I found this out since parisc-linux port will crash on A500 if
a driver attempts to access a PCI device that isn't enabled.
With PCI Hotplug of PCI cards, this will become more critical.

> So drivers that doesn't
> call pci_enable() are just working luckily (due to proper
> setting by BIOS etc.)

Yup. x86 is the least strict in terms of following programming interfaces.
But lots of issues (eg Posted PCI writes, DMA Mapping, long vs int)
make drivers non-portable to other arches. Alan Cox (LinuxTag 2002)
and Arjen van de Ven (OLS2002) both gave excellent talks on
driver portability. I also gave a talk on HP ZX1 at OLS 2002.
I highly reccomend David and Stephane's "IA64 Linux" book
to those seeking detailed 2.4 driver interface descriptions.

> Yes, once Alan Mayer at sgi did the work.
> But ccNUMA platforms can have various connection topology
> and simply dividing vector table into the number of nodes
> may not the best choice to do.

Right. That's why I suggested per CPU (vs per Node) as an alternative.
Different platforms can do it differently. I'd be interested in
implementing per CPU vector tables but HP isn't interested in funding it.

> I think iosapic.c should be as generic as possible enough to
> cover all IO SAPIC-based platforms and tuning for specific
> ccNUMA platforms should be considered separately.

Agreed.

cheers,
grant

