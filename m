From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 21 Jan 2004 20:18:19 +0000
Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <200401211318.19330.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401201607.32214.bjorn.helgaas@hp.com> <200401210939.08782.bjorn.helgaas@hp.com>
In-Reply-To: <200401210939.08782.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: Len Brown <len.brown@intel.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Wednesday 21 January 2004 9:39 am, Bjorn Helgaas wrote:
> There's also something fishy in this area that neither the -mm5
> code nor my patch addresses.  In the acpi_os_install_interrupt_handler()
> fragment above, we do the "acpi interrupt->irq" conversion and save
> the resulting irq in acpi_irq_irq.  The only place acpi_irq_irq is
> used is in acpi_os_terminate(), where it is passed to acpi_os_remove_
> interupt_handler(), where we apply the "acpi interrupt->irq" conversion
> AGAIN.  This seems wrong.

OK, I think I understand what's wrong there.  acpi_irq_irq needs to
be the PRE-CONVERSION interrupt, like this:

    acpi_status
    acpi_os_install_interrupt_handler(u32 interrupt, OSD_HANDLER handler, void *context)
    {
	unsigned int irq;

	interrupt = acpi_fadt.sci_int;
	irq = acpi_irq_to_vector(interrupt); 
	...
        acpi_irq_irq = interrupt;
	...
	if (request_irq(irq, ...))

Then acpi_os_terminate() will pass the pre-conversion value to
acpi_os_remove_interrupt_handler(), which will apply acpi_irq_to_vector()
and everything will match.

I'll make a note to clean this up after the previous issues in the
area are straightened out.

Bjorn

