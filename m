From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Fri, 23 Jan 2004 03:36:17 +0000
Subject: RE: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <7F740D512C7C1046AB53446D3720017361886A@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401210939.08782.bjorn.helgaas@hp.com>
In-Reply-To: <200401210939.08782.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas-VXdhtT5mjnY@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

> What does "vector" mean?  
For MSI, vector means the (external) interrupt vector, i.e. the index in
the IDT for MSI on x86. So acpi_irq_to_vector() is correct in that case.
ACPI looks at IRQ or GSI (Global system interrupt) vector (yes, it's
confusing). SOMETHING should be irq or gsi, as David suggested.

Since MSI does not require IRQ (but external interrupt vector), the way
we did for x86 was to use the vector to unify IRQ and vector. So
request_irq() actually gets the interrupt vector number, instead of irq.
That's the reason I preferred acpi_irq_to_vector() in that code with MSI
configured.

Jun
> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> Sent: Thursday, January 22, 2004 8:38 AM
> To: Nakajima, Jun; acpi-devel@lists.sourceforge.net; linux-
> ia64@vger.kernel.org
> Cc: Brown, Len
> Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
> 
> On Wednesday 21 January 2004 8:36 pm, Nakajima, Jun wrote:
> 
> > > 	(b) is "acpi_interrupt_to_irq" a better name than
> > > 	    "acpi_irq_to_vector"?
> >
> > I don't know what people imagine by "interrupt", but to me it
implies an
> > "event".
> 
> Are you saying that you think "acpi_irq_to_vector" is the right name?
> What does "vector" mean?  The return value of that function is in
> fact a Linux IRQ, and is passed to request_irq() and free_irq().  So
> I think the correct name is "acpi_SOMETHING_to_irq".  If you don't
> like "interrupt", you can propose something else.  I just think it's
> misleading for the name to contain "to_vector", when it's really
> doing "to_irq".
> 

