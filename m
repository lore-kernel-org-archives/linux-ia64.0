From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 18 Dec 2003 19:56:14 +0000
Subject: Re: IA64 test report: 2.6.0-test11/tiger 2003-12-18: 9/9 pass
Message-Id: <marc-linux-ia64-107177785222846@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107174005310297@msgid-missing>
In-Reply-To: <marc-linux-ia64-107174005310297@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 18 December 2003 2:30 am, Yu, Luming wrote:
> Problems:
> 1.alloc 0xffff-0x0 from PCI IO for PCI Bus 0000:08 failed
> Known issue, bjorn has idea to fix it.

Nope.  This one:

	alloc 0x0-0x5fff from PCI IO for PCI Bus 0000:00 failed

is caused by the VGA driver having allocated ports before we discover
the PCI root bridges.  We know how to fix that.

All these:

	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:02 failed
	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:08 failed
	alloc 0xffff-0x0 from PCI IO for PCI Bus 0000:08 failed
	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:09 failed
	alloc 0xffffffff-0x0 from PCI mem for PCI Bus 0000:0f failed

just look like bogus _CRS entries.  (What does it mean to have an
address space descriptor that starts at 0xffffffff and ends at 0x0?)
These warnings should be innocuous, because we just ignore these
descriptors.

Similarly, these:

	acpi_serial_port: zero-length IO port range?
	acpi_serial_port: zero-length IO port range?

also look bogus (there's a UART device with an IO port space descriptor
with range_length of zero).  What's that supposed to mean?  Again, these
should be harmless, because we ignore these descriptors.

> 2. pci_irq-0302 [03] acpi_pci_irq_derive   : Unable to derive IRQ for device 0000:00:1f.1
> ACPI: No IRQ known for interrupt pin A of device 0000:00:1f.1
> Please refere http://bugzilla.kernel.org/show_bug.cgi?id34 

ACPI is supposed to tell us how PCI interrupts are routed.  Here's a
device that has no routing information.  Either the firmware is
broken, or the ACPI code in Linux hasn't implemented some piece of
the spec.

Can you please ask your firmware folks about

	1) Why the strange "0xffffffff-0x0" descriptors in PCI root
	   bridge _CRS?
	2) Why the zero-length IO port descriptors in UART _CRS?
	3) Why no IRQ routing information for PCI device 0000:00:1f.1?

If it turns out that Linux is just missing the smarts to interpret these
things, I'll be happy to fix that.  But right now, they all look like
firmware defects.

Bjorn

