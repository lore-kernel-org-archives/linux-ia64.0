From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 23 Jan 2004 16:35:50 +0000
Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <200401230935.50385.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7F740D512C7C1046AB53446D3720017361886A@scsmsx402.sc.intel.com>
In-Reply-To: <7F740D512C7C1046AB53446D3720017361886A-exJ48ZlmiLrcnAH0NVKmOFDQ4js95KgL@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nakajima, Jun" <jun.nakajima-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

On Thursday 22 January 2004 8:36 pm, Nakajima, Jun wrote:
> > What does "vector" mean?  
> For MSI, vector means the (external) interrupt vector, i.e. the index in
> the IDT for MSI on x86. So acpi_irq_to_vector() is correct in that case.
> ACPI looks at IRQ or GSI (Global system interrupt) vector (yes, it's
> confusing). SOMETHING should be irq or gsi, as David suggested.
> 
> Since MSI does not require IRQ (but external interrupt vector), the way
> we did for x86 was to use the vector to unify IRQ and vector. So
> request_irq() actually gets the interrupt vector number, instead of irq.
> That's the reason I preferred acpi_irq_to_vector() in that code with MSI
> configured.

Sorry to drag this out even longer...  I promise I'll shut up
after this :-)

But this business about request_irq() getting an MSI interrupt vector
number, not an irq, is just a detail of the MSI and architecture
implementation.  Surely ACPI should just use the abstract Linux
interrupt interface (request_irq(), free_irq(), etc), which uses
the "irq" terminology, and should remain ignorant of whether MSI
is even present.

Bjorn

