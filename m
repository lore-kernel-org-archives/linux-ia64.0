From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Thu, 22 Jan 2004 03:36:43 +0000
Subject: RE: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <7F740D512C7C1046AB53446D37200173618864@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401210939.08782.bjorn.helgaas@hp.com>
In-Reply-To: <200401210939.08782.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

To be clear, the vector-based PCI interrupt support for MSI is in 2.6.1,
but the particular ACPI code in -mm was a bug fix that we added
recently.

> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> Sent: Wednesday, January 21, 2004 2:54 PM
> To: Nakajima, Jun; acpi-devel@lists.sourceforge.net; linux-
> 
> Any feedback on these questions from my previous mail:
> 
> 	(a) do you want the #ifdefs in ACPI (as in 2.6.1-mm5),
> 	    or in the platform-specific code (as in my patch)?

I would like to avoid #ifdefs even in -mm5.

> 
> 	(b) is "acpi_interrupt_to_irq" a better name than
> 	    "acpi_irq_to_vector"?

I don't know what people imagine by "interrupt", but to me it implies an
"event". 

If we have definitions of acpi_irq_to_vector(irq) for other
architectures (as you basically did), we can remove #ifdef CONFIG_IA64.
For x86, we can switch the definition using CONFIG_PCI_USE_VECTOR. 

> 
> 	(c) is acpi_os_install_interrupt_handler() saving the
> 	    wrong value in acpi_irq_irq?
> 

I think the original IA-64 code was wrong (so CONFIG_PCI_USE_VECTOR will
be wrong there, too).  The value of irq is covered to vector by
acpi_irq_to_vector(irq) in acpi_os_install_interrupt_handler(), then
this value is set to acpi_irq_irq. But
acpi_os_remove_interrupt_handler() is given acpi_irq_irq (i.e. vector),
then it again calls acpi_irq_to_vector() prior to calling
free_irq(irq,,).

Thanks,
Jun

