From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Tue, 09 Mar 2004 23:44:39 +0000
Subject: Re: [ACPI] [PATCH] 4 of 6 introduce acpi_global_irq_to_irq()
Message-Id: <16462.22247.450237.896263@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200403091619.04333.bjorn.helgaas@hp.com>
	<200403091626.31461.bjorn.helgaas@hp.com>
In-Reply-To: <200403091626.31461.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: acpi-devel@lists.sourceforge.net, linux-ia64@vger.kernel.org, Andi Kleen <ak@suse.de>, "Nakajima, Jun" <jun.nakajima@intel.com>, "Brown, Len" <len.brown@intel.com>

>>>>> On Tue, 9 Mar 2004 16:26:31 -0700, Bjorn Helgaas <bjorn.helgaas@hp.com> said:

  Bjorn> i386, x86_64, ia64, ACPI: Introduce acpi_global_irq_to_irq()
  Bjorn> Rename acpi_irq_to_vector() to acpi_global_irq_to_irq().
  Bjorn> This function takes an ACPI global IRQ (often called a
  Bjorn> "global system interrupt", but "global_irq" seems to be
  Bjorn> commonly used in Linux), and converts it to a Linux IRQ.

  Bjorn> This removes IA64 and PCI_USE_VECTOR #ifdefs from ACPI.

The ia64-specific changes have my blessing.

However, I'd _much_ prefer "gsi" in lieu of "global_irq".  It's much
easier to think of the former as a numbering-scheme separate from the
Linux irq numbers.  Justs my 2 cents...

	--david
