From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
Date: Mon, 29 Mar 2004 01:24:33 +0000
Subject: Re: [ACPI] Re: [RFC] ACPI IRQ proposal
Message-Id: <20040329.102433.74728948.maeda@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403231537.14505.bjorn.helgaas@hp.com>
 <20040326.143930.41646618.maeda@jp.fujitsu.com>
 <20040326.175630.74755524.t-kochi@bq.jp.nec.com>
In-Reply-To: <20040326.175630.74755524.t-kochi@bq.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: t-kochi@bq.jp.nec.com
Cc: maeda.naoaki@jp.fujitsu.com, bjorn.helgaas@hp.com, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Hi, Kochi-san.

Thank you for your explanation of what may cause the problem.
As you guessed, the SCI of my machine is active-high, level interrupt. 
I had to notice that the following kernel messages were printed.

   tiger4 kernel: ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
   tiger4 kernel: register_intr: changing vector 39 from IO-SAPIC-edge to IO-SAPIC-level

In order to make sure that the spurious interrupts were caused by this problem,
I have tried to simply change the 2nd argument of acpi_register_gsi() to
ACPI_ACTIVE_HIGH, and then the spurious interrupts are gone.

Thanks,
Naoaki Maeda

From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Subject: [ACPI] Re: [RFC] ACPI IRQ proposal
Date: Fri, 26 Mar 2004 17:56:30 +0900 (JST)

> Hi Maeda-san, Bjorn,
> 
> Although the ACPI spec says that SCI is 'active-low, level' interrupt,
> there are many platforms that doesn't follow the rule (what I've seen
> are almost active-high, level).  I think Maeda-san's case is just
> a wrong polarity.
> 
> Usually those platforms would describe the polarity and trigger of
> SCI in 'interrupt source override' record in the ACPI MADT table.
> 
> The polarity and trigger are programmed in iosapic when MADT
> parsing is done, so we don't want to force 'ACPI_ACTIVE_LOW,
> ACPI_LEVEL_SENSITIVE' when SCI is enabled.
> 
> So maybe acpi_register_gsi() would take only one argument (u32 gsi)
> and the acpi_register_gsi() by itself will derive polarity and trigger
> from override table or iosapic_intr_info[]?
> 
> From: MAEDA Naoaki <maeda.naoaki@jp.fujitsu.com>
> Subject: Re: [RFC] ACPI IRQ proposal
> Date: Fri, 26 Mar 2004 14:39:30 +0900 (JST)
> 
> > Hi, Bjorn.
> > 
> > I've tried your patch in tiger4, but it causes spurious acpi interrupts,
> > and finally the IRQ is disabled by note_interrupt().
> > 
> > I guess the difference causing this problem is your patch enables the acpi
> > interrupt on acpi_register_gsi() called by acpi_os_install_interrupt_handler(),
> > but original acpi_os_install_interrupt_handler() calls acpi_irq_to_vector(),
> > which does not enable the interrupt, instead.
> > 
> > I am not sure the reason, but probably the enabling timing is too early
> > for the acpi interrupt.
> > 
> > Didn't you hit this problem?
> > 
> > Thanks,
> > Naoaki Maeda
> > 
> > ------- Original code 
> > #if defined(CONFIG_IA64) || defined(CONFIG_PCI_USE_VECTOR)
> >         irq = acpi_irq_to_vector(irq);
> >         if (irq < 0) {
> >                 printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
> >                        acpi_fadt.sci_int);
> >                 return AE_OK;
> >         }
> > #endif
> >         acpi_irq_handler = handler;
> >         acpi_irq_context = context;
> >         if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
> >                 printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
> >                 return AE_NOT_ACQUIRED;
> >         }
> >         acpi_irq_irq = irq;
> > --------
> > 
> > -------- Patched code
> >         irq = acpi_register_gsi(gsi, ACPI_ACTIVE_LOW, ACPI_LEVEL_SENSITIVE);
> >         if (irq < 0) {
> >                 printk(KERN_ERR PREFIX "SCI (ACPI interrupt %d) not registered\n",
> >                        gsi);
> >                 return AE_OK;
> >         }
> > 
> >         acpi_irq_handler = handler;
> >         acpi_irq_context = context;
> >         if (request_irq(irq, acpi_irq, SA_SHIRQ, "acpi", acpi_irq)) {
> >                 printk(KERN_ERR PREFIX "SCI (IRQ%d) allocation failed\n", irq);
> >                 return AE_NOT_ACQUIRED;
> >         }
> > --------
> > 
> > 
> > From: Bjorn Helgaas <bjorn.helgaas@hp.com>
> > Subject: [RFC] ACPI IRQ proposal
> > Date: Tue, 23 Mar 2004 15:37:14 -0700
> > 
> > > I think the ACPI/platform interactions for IRQ setup are unnecessarily
> > > complex.  Today we have:
> > > 
> > >     - boot-time parsing of all the _PRTs (platform subsys_initcall
> > >       calls acpi_pci_irq_init(), which calls either mp_parse_prt()
> > >       or iosapic_parse_prt() based on some #ifdefs).
> > > 
> > >     - pci_enable_device()-time IRQ enable (platform
> > >       pcibios_enable_resources() calls acpi_pci_irq_enable(), which
> > >       calls back to platform code, again based on some #ifdefs).
> > > 
> > > By defining a new platform interface, we should be able to get rid of
> > > the boot-time _PRT parsing and do everything cleanly at
> > > pci_enable_device()-time:
> > > 
> > >     int					/* Linux IRQ */
> > >     acpi_register_gsi(int gsi,
> > > 		      int polarity,	/* active high or low */
> > > 		      int trigger)	/* edge or level */
> > > 
> > > This is responsible for whatever APIC or IOSAPIC programming the
> > > platform needs, as well as allocating and returning a Linux IRQ.
> > > 
> > > By doing this, we get
> > > 
> > >     - possibility of hot-plugging a PCI root bridge (w/ _PRT)
> > >     - removal of architecture #ifdefs from pci_irq.c and osl.c
> > >     - removal of some Linux IRQ junk from acpi/pci_irq.c
> > > 
> > > If there are still some broken drivers that don't call pci_enable_device(),
> > > we still have the option of putting a hook somewhere that just calls
> > > acpi_pci_irq_enable() for all PCI devices.
> > > 
> > > Sample patch below only cleans up ia64; i386 and x86_64 looks a
> > > little more complicated.  Any comments?
> > 
> > -
> > To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id70&alloc_id638&op=click
> _______________________________________________
> Acpi-devel mailing list
> Acpi-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/acpi-devel
