From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Fri, 13 Feb 2004 16:10:52 +0000
Subject: Re: IA64 test report: 2.6.2-rc2/Lion 2004-2-11: 10/9 pass
Message-Id: <200402130910.52071.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <3ACA40606221794F80A5670F0AF15F8401720D38@PDSMSX403.ccr.corp.intel.com>
In-Reply-To: <3ACA40606221794F80A5670F0AF15F8401720D38@PDSMSX403.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Friday 13 February 2004 7:18 am, Yu, Luming wrote:
> > We still have this IRQ issue:
> > 
> > 	 pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to 
> > derive IRQ for device 00003
> > 	ACPI: No IRQ known for interrupt pin B of device 0000:00:03.3
> > 
> > Or do we have confirmation that this is just a firmware defect?
> > 
> 
> Not likely, PS/2 keyboard works well with 2.4 kernel.

The IRQ problem is separate from the PS/2 keyboard problem.  The
IRQ problem above is for device 00:03.3, which is the SMBus device
according to your lspci output.

