From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Wed, 21 Jan 2004 22:42:37 +0000
Subject: RE: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <7F740D512C7C1046AB53446D37200173618863@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401210939.08782.bjorn.helgaas@hp.com>
In-Reply-To: <200401210939.08782.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: "Brown, Len" <len.brown@intel.com>

One notes. In x86, although you assumed interrupt = IRQ, that's not the
case with so called "vector-based PCI interrupt handling" in support of
MSI (which is 2.6.1). With this, do_IRQ(irq, ...) will get the vector
number instead of IRQ, which is same as IPF. 

I think we can use the common code for that configuration at least in
ACPI. If you look at 2.6.1-mm5, for example, we also have
acpi_irq_to_vector(), which is doing the same thing as IPF does.

Thanks,
Jun
> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org [mailto:linux-ia64-
> owner@vger.kernel.org] On Behalf Of Bjorn Helgaas
> Sent: Wednesday, January 21, 2004 12:18 PM
> To: acpi-devel@lists.sourceforge.net; linux-ia64@vger.kernel.org
> Cc: Brown, Len; Nakajima, Jun
> Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
> 
> On Wednesday 21 January 2004 9:39 am, Bjorn Helgaas wrote:
> > There's also something fishy in this area that neither the -mm5
> > code nor my patch addresses.  In the
acpi_os_install_interrupt_handler()
> > fragment above, we do the "acpi interrupt->irq" conversion and save
> > the resulting irq in acpi_irq_irq.  The only place acpi_irq_irq is
> > used is in acpi_os_terminate(), where it is passed to
acpi_os_remove_
> > interupt_handler(), where we apply the "acpi interrupt->irq"
conversion
> > AGAIN.  This seems wrong.
> 
> OK, I think I understand what's wrong there.  acpi_irq_irq needs to
> be the PRE-CONVERSION interrupt, like this:
> 
>     acpi_status
>     acpi_os_install_interrupt_handler(u32 interrupt, OSD_HANDLER
handler,
> void *context)
>     {
> 	unsigned int irq;
> 
> 	interrupt = acpi_fadt.sci_int;
> 	irq = acpi_irq_to_vector(interrupt);
> 	...
>         acpi_irq_irq = interrupt;
> 	...
> 	if (request_irq(irq, ...))
> 
> Then acpi_os_terminate() will pass the pre-conversion value to
> acpi_os_remove_interrupt_handler(), which will apply
acpi_irq_to_vector()
> and everything will match.
> 
> I'll make a note to clean this up after the previous issues in the
> area are straightened out.
> 
> Bjorn
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64"
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
