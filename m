From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 12 Feb 2004 23:56:04 +0000
Subject: Re: IA64 test report: 2.6.2-rc2/Lion 2004-2-11: 10/9 pass
Message-Id: <200402121656.04005.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720D38@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720D38@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wednesday 11 February 2004 4:09 am, Yu, Luming wrote:
> ACPI Features Tested: (prioritized).
> --------------------
> 2. PS/2 keyboard			Only work for about 5 minutes

We still have this IRQ issue:

	 pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for device 00003
	ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3

Or do we have confirmation that this is just a firmware defect?

Also, there's this:

	kernel unaligned access to 0xa000000100a59cc1, ip=0xa0000001003348e1

Probably not an ACPI issue, but it's be nice to know what it is.  Can
you look up the IP in the System.map?

I'll see whether I can dig up a Lion to play with the PS/2 problem.

