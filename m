From: "Nakajima, Jun" <jun.nakajima@intel.com>
Date: Wed, 10 Mar 2004 00:00:19 +0000
Subject: RE: [ACPI] [PATCH] 4 of 6 introduce acpi_global_irq_to_irq()
Message-Id: <7F740D512C7C1046AB53446D37200173FEB472@scsmsx402.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091626.31461.bjorn.helgaas@hp.com>
In-Reply-To: <200403091626.31461.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davidm@hpl.hp.com, Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>, "Brown, Len" <len.brown@intel.com>

I agree with David. And GSI is more consistent with the ACPI spec, and
you don't need to explain what it is.

Jun
>-----Original Message-----
>From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
>Sent: Tuesday, March 09, 2004 3:45 PM
>To: Bjorn Helgaas
>Cc: acpi-devel@lists.sourceforge.net; linux-ia64@vger.kernel.org; Andi
>Kleen; Nakajima, Jun; Brown, Len
>Subject: Re: [ACPI] [PATCH] 4 of 6 introduce acpi_global_irq_to_irq()
>
>>>>>> On Tue, 9 Mar 2004 16:26:31 -0700, Bjorn Helgaas
><bjorn.helgaas@hp.com> said:
>
>  Bjorn> i386, x86_64, ia64, ACPI: Introduce acpi_global_irq_to_irq()
>  Bjorn> Rename acpi_irq_to_vector() to acpi_global_irq_to_irq().
>  Bjorn> This function takes an ACPI global IRQ (often called a
>  Bjorn> "global system interrupt", but "global_irq" seems to be
>  Bjorn> commonly used in Linux), and converts it to a Linux IRQ.
>
>  Bjorn> This removes IA64 and PCI_USE_VECTOR #ifdefs from ACPI.
>
>The ia64-specific changes have my blessing.
>
>However, I'd _much_ prefer "gsi" in lieu of "global_irq".  It's much
>easier to think of the former as a numbering-scheme separate from the
>Linux irq numbers.  Justs my 2 cents...
>
>	--david
