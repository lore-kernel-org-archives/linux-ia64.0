From: "Brown, Len" <len.brown@intel.com>
Date: Thu, 22 Jan 2004 17:41:10 +0000
Subject: RE: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <BF1FE1855350A0479097B3A0D2A80EE0CC8A2D@hdsmsx402.hd.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200401210939.08782.bjorn.helgaas@hp.com>
In-Reply-To: <200401210939.08782.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>, "Nakajima, Jun" <jun.nakajima@intel.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org

Bjorn,

> irq = acpi_irq_to_vector(irq);

Yeah, this name is totally bogus; and your comments are absolutely
right.  I thank you for taking the time to address it.

When I first saw this I said to myself, "hmm, shouldn't it be
acpi_irq_to_irq()?", nah, that seems even more stupid!";-)

Looks like this is only used for the SCI listed in the FADT.  So maybe
we should just call it something like acpi_fadt_sci_to_irq()?

Thanks,
-Len

> -----Original Message-----
> From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com] 
> Sent: Thursday, January 22, 2004 11:38 AM
> To: Nakajima, Jun; acpi-devel@lists.sourceforge.net; 
> linux-ia64@vger.kernel.org
> Cc: Brown, Len
> Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
> 
> 
> On Wednesday 21 January 2004 8:36 pm, Nakajima, Jun wrote:
> 
> > > 	(b) is "acpi_interrupt_to_irq" a better name than
> > > 	    "acpi_irq_to_vector"?
> > 
> > I don't know what people imagine by "interrupt", but to me 
> it implies an
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
> 
> 
