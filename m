From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 22 Jan 2004 16:38:18 +0000
Subject: Re: [ACPI] [PATCH] add acpi_interrupt_to_irq
Message-Id: <200401220938.18951.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <7F740D512C7C1046AB53446D37200173618864@scsmsx402.sc.intel.com>
In-Reply-To: <7F740D512C7C1046AB53446D37200173618864@scsmsx402.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Nakajima, Jun" <jun.nakajima@intel.com>, acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org
Cc: "Brown, Len" <len.brown@intel.com>

On Wednesday 21 January 2004 8:36 pm, Nakajima, Jun wrote:

> > 	(b) is "acpi_interrupt_to_irq" a better name than
> > 	    "acpi_irq_to_vector"?
> 
> I don't know what people imagine by "interrupt", but to me it implies an
> "event". 

Are you saying that you think "acpi_irq_to_vector" is the right name?
What does "vector" mean?  The return value of that function is in
fact a Linux IRQ, and is passed to request_irq() and free_irq().  So
I think the correct name is "acpi_SOMETHING_to_irq".  If you don't
like "interrupt", you can propose something else.  I just think it's
misleading for the name to contain "to_vector", when it's really
doing "to_irq".


