From: Grant Grundler <grundler@cup.hp.com>
Date: Thu, 01 Aug 2002 01:03:10 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905869@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

"KOCHI, Takayoshi" wrote:
> But PCI device driver will call request_irq() with dev->irq as
> IRQ number.  This number is usually set by PCI device scan
> routine in drivers/pci/pci.c (2.4.x) and is derived from
> the device's configuration space.

uhmm...emphasis on "derived from". pcibios can (and does
depending on platform) "fix up" the value that PCI Device scan
places in the pcidev.

> The number BIOS sets in
> that configuratoin space field is somewhat bogus in many
> Itanium platforms.

pcidev->irq != BIOS value or config space IRQ_LINE value.
pcidev->irq is just a "handle" for pcibios code to pass to
platform interrupt support. Both have to understand what
the handle means.

If you don't trust BIOS on your platform, it's ok if pcibios
support does the "magic" you describe below as long as the
platform interrupt support understands the result.

> So we have to embed into dev->irq
> some magic number, which is not used elsewhere, for each
> pci_dev in pci_fixup stage.

pcibios_fixup_bus() gets to mangle pcidev->irq values as needed.
This sounds right.

> It makes sense because
>  1) we can allocate interrupt vectors only for those who want them
>  2) it has explicit free API (free_irq), while pcibios_enable_device
>     doesn't have its counterpart.  This is good for PCI hotplug.

yes. I *think* (but don't know for sure) that's because more magic
might be needed to enable devices on some platforms than simply
flipping the MASTER enable bit in the PCI device command register
(config space). I suspect flipping MASTER enable bit off should
be enough.

> But many drivers assume dev->irq has some IRQ number associated with it
> and does like " printk("IRQ %d\n", dev->irq); "
> If dev->irq is the magic number, each driver will report its
> IRQ as the same number.  This may confuse users.

Use different magic numbers for each IRQ?
They can be any *int* value. You can even use them to index into
an array or structures. The trick is to fully hide the IRQ<->pcidev
relationship in the platform specific support.

> (And drivers don't have any means to know what number request_irq() 
>  allocated, either.)

Two comments on this one:
o drivers don't know anyway. pcidev->irq is just a "handle".

o request_irq() doesn't allocate pcidev->irq numbers.
  That's too late in the initialization process.

The pcidev->irq values have to be setup about the time the PCI bus
is "walked" and before the driver probe routine is called.
The IRQ doesn't have to be enabled until request_irq() is called.
"Enable" could mean allocate CPU vector, program iosapic RTE, etc.

Since I haven't worked on PCI hotplug, pcibios interface might be
deficient in how/where one can fixup pcidev->irq info.

> /proc/interrupts and /proc/irq/ (smp_affinity stuff) may
> involve confusion in matching irq number <-> device.
> We'd like to make user suprise as least as possible, don't we?

right.

> Yes.  BTW for PCI hotplug, there's more serious problem.
> If the device driver doesn't use 'struct pci_driver' and
> 'pci_register_driver()' API, removing the device may fail.

I haven't played with PCI Hotplug (yet). My gut reaction is you
should submit patches for drivers *you* need to hot plug/remove.
Same story as for pci_enable_device().

> I attended the OLS2002, Arjan's and your talks.
> Thank you...

welcome...HP paid for a very fun trip. ;^)

> per-CPU vector table has lots to do for smp irq affinity stuff.
> It may be a long-term solution, but not for short-term solution.

yes - definitely long term. irq affinity needs to track current
CPU and which vector it's using. I don't know how much work is
needed to fix/change that.

Clearly, having multiple vector tables will avoid sharing vectors on
larger systems (> 50 PCI slots).

How much pressure is on the vector table will also depend on how much
MSI or MSI-X (Message Signaled Interrupts) is used by the next round
of IO technology (infiniband, 10GbEther, etc).

thanks,
grant

