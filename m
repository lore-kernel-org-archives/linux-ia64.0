From: "KOCHI, Takayoshi" <t-kouchi@mvf.biglobe.ne.jp>
Date: Tue, 30 Jul 2002 23:49:31 +0000
Subject: Re: [Linux-ia64] [PATCH] dynamic IRQ allocation
Message-Id: <marc-linux-ia64-105590701905861@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905851@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905851@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 30 Jul 2002 15:14:03 -0700
Grant Grundler <grundler@cup.hp.com> wrote:

> > But how to distinguish PCI irqs from others?
> 
> IRQ number. I assume you mean PCI vs other IO subsystems.
> The pcibios support has to uniquely identify each PCI IRQ Line
> with a different IRQ number. And that number space has to
> be shared with all interrupt sources.
> 
> request_irq() can (does?) branch to iosapic support based on IRQ number.

But PCI device driver will call request_irq() with dev->irq as
IRQ number.  This number is usually set by PCI device scan
routine in drivers/pci/pci.c (2.4.x) and is derived from
the device's configuration space.  The number BIOS sets in
that configuratoin space field is somewhat bogus in many
Itanium platforms.  So we have to embed into dev->irq
some magic number, which is not used elsewhere, for each
pci_dev in pci_fixup stage.

It makes sense because
 1) we can allocate interrupt vectors only for those who want them
 2) it has explicit free API (free_irq), while pcibios_enable_device
    doesn't have its counterpart.  This is good for PCI hotplug.

But many drivers assume dev->irq has some IRQ number associated with it
and does like " printk("IRQ %d\n", dev->irq); "
If dev->irq is the magic number, each driver will report its
IRQ as the same number.  This may confuse users.
(And drivers don't have any means to know what number request_irq() 
 allocated, either.)

/proc/interrupts and /proc/irq/ (smp_affinity stuff) may
involve confusion in matching irq number <-> device.

We'd like to make user suprise as least as possible, don't we?

> > It seems that all PCI drivers pass its pci_dev structure
> > as the 4th argument of request_irq, but others won't
> > (for example, serial.c).
> 
> The 4th arg is a "void *". It can be anything the driver wants
> to identify device instance or even NULL (see ob600 mouse driver).
> Don't make any assumptions about what the 4th argument is.

Exactly.


> > I thought allocating a new vector in request_irq() is another
> > level of dynamic allocation.
> 
> It doesn't need to be. Just replaces the allocation
> which happens per PCI IRQ Line or per PCI Device.
> 
> BTW, "in request_irq()" to me means in that code path, not
> immediately in that function.
> 
> > Once I took another approach and wrote a version that
> > allocates a new vector when a driver calls pcibios_enable,
> > but it turned out to be problematic because not all PCI
> > device drivers call pci_enable() at their startup.
> 
> That's a driver bug. Please submit patches to David or the driver
> maintainer. cpqfc driver doesn't call pci_enable_device() either.
> I found this out since parisc-linux port will crash on A500 if
> a driver attempts to access a PCI device that isn't enabled.
> With PCI Hotplug of PCI cards, this will become more critical.

Yes.  BTW for PCI hotplug, there's more serious problem.
If the device driver doesn't use 'struct pci_driver' and
'pci_register_driver()' API, removing the device may fail.

If there's one device in the system and the driver is modular,
you can remove the driver then remove the device.  But there
are two devices and you want to remove one of them, it can't
be helped without pci_register_driver() API.

> > So drivers that doesn't
> > call pci_enable() are just working luckily (due to proper
> > setting by BIOS etc.)
> 
> Yup. x86 is the least strict in terms of following programming interfaces.
> But lots of issues (eg Posted PCI writes, DMA Mapping, long vs int)
> make drivers non-portable to other arches. Alan Cox (LinuxTag 2002)
> and Arjen van de Ven (OLS2002) both gave excellent talks on
> driver portability. I also gave a talk on HP ZX1 at OLS 2002.

I attended the OLS2002, Arjan's and your talks.
Thank you...

> I highly reccomend David and Stephane's "IA64 Linux" book
> to those seeking detailed 2.4 driver interface descriptions.
> 
> > Yes, once Alan Mayer at sgi did the work.
> > But ccNUMA platforms can have various connection topology
> > and simply dividing vector table into the number of nodes
> > may not the best choice to do.
> 
> Right. That's why I suggested per CPU (vs per Node) as an alternative.
> Different platforms can do it differently. I'd be interested in
> implementing per CPU vector tables but HP isn't interested in funding it.

per-CPU vector table has lots to do for smp irq affinity stuff.
It may be a long-term solution, but not for short-term solution.

Thanks,
-- 
KOCHI, Takayoshi <t-kouchi@cq.jp.nec.com/t-kouchi@mvf.biglobe.ne.jp>


