From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Fri, 26 Mar 2004 05:39:30 +0000
Subject: Re: [RFC] ACPI IRQ proposal
Message-Id: <20040326.143930.41646618.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403231537.14505.bjorn.helgaas@hp.com>
In-Reply-To: <200403231537.14505.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bjorn.helgaas@hp.com
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, maeda.naoaki@jp.fujitsu.com

Hi, Bjorn.

I've tried your patch in tiger4, but it causes spurious acpi interrupts,
and finally the IRQ is disabled by note_interrupt().

I guess the difference causing this problem is your patch enables the acpi
interrupt on acpi_register_gsi() called by acpi_os_install_interrupt_handler(),
but original acpi_os_install_interrupt_handler() calls acpi_irq_to_vector(),
which does not enable the interrupt, instead.

I am not sure the reason, but probably the enabling timing is too early
for the acpi interrupt.

Didn't you hit this problem?

Thanks,
Naoaki Maeda

------- Original code 
#if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
        irq = acpi_irq_to_vector(irq);
        if (irq < 0) {
                printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
                       acpi_fadt.sci_int);
                return AE_OK;
        }
#endif
        acpi_irq_handler = handler;
        acpi_irq_context = context;
        if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
                printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
                return AE_NOT_ACQUIRED;
        }
        acpi_irq_irq = irq;
--------

-------- Patched code
        irq = acpi_register_gsi(gsi, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
        if (irq < 0) {
                printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
                       gsi);
                return AE_OK;
        }

        acpi_irq_handler = handler;
        acpi_irq_context = context;
        if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
                printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
                return AE_NOT_ACQUIRED;
        }
--------


From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: [RFC] ACPI IRQ proposal
Date: Tue, 23 Mar 2004 15:37:14 -0700

> I think the ACPI/platform interactions for IRQ setup are unnecessarily
> complex.  Today we have:
> 
>     - boot-time parsing of all the _PRTs (platform subsys_initcall
>       calls acpi_pci_irq_init(), which calls either mp_parse_prt()
>       or iosapic_parse_prt() based on some #ifdefs).
> 
>     - pci_enable_device()-time IRQ enable (platform
>       pcibios_enable_resources() calls acpi_pci_irq_enable(), which
>       calls back to platform code, again based on some #ifdefs).
> 
> By defining a new platform interface, we should be able to get rid of
> the boot-time _PRT parsing and do everything cleanly at
> pci_enable_device()-time:
> 
>     int					/* Linux IRQ */
>     acpi_register_gsi(int gsi,
> 		      int polarity,	/* active high or low */
> 		      int trigger)	/* edge or level */
> 
> This is responsible for whatever APIC or IOSAPIC programming the
> platform needs, as well as allocating and returning a Linux IRQ.
> 
> By doing this, we get
> 
>     - possibility of hot-plugging a PCI root bridge (w/ _PRT)
>     - removal of architecture #ifdefs from pci_irq.c and osl.c
>     - removal of some Linux IRQ junk from acpi/pci_irq.c
> 
> If there are still some broken drivers that don't call pci_enable_device(),
> we still have the option of putting a hook somewhere that just calls
> acpi_pci_irq_enable() for all PCI devices.
> 
> Sample patch below only cleans up ia64; i386 and x86_64 looks a
> little more complicated.  Any comments?

