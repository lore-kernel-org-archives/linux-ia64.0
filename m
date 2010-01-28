From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 28 Jan 2010 20:04:27 +0000
Subject: Re: "new" dependencies on ACPI/BIOS
Message-Id: <201001281304.28613.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
In-Reply-To: <4b61e3dc10565c4ca6@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 28 January 2010 12:22:04 pm Luck, Tony wrote:
> [Bjorn: I stuck your name in the "To" list as Jesse told me that you
>  know all about this code]
> 
> My shiniest, newest, ia64 development system used to work fine. But
> in 2.6.31 the USB keyboard and mouse on the console stopped working.
> ...
> The code now appears to walk ACPI looking for _CRS methods to find out
> which resources are attached to which busses.  When drivers are paired
> up with devices later, we check to make sure that the device has a
> correct parent.  For my system this seems to fail because the _CRS walk
> only turns up some IO resources and no MEM resources. So the echi
> (which wants mem 0x58328000 and mem 0x58324000) is out of luck and
> denied.
> ...
> ACPI: PCI Root Bridge [PCI0] (0000:00)
> pci_root PNP0A08:00: host bridge window [io  0x0000-0x0cf7]
> pci_root PNP0A08:00: host bridge window [io  0x1000-0x8fff]

> ACPI: PCI Root Bridge [PCI1] (0000:80)
> pci_root PNP0A08:01: host bridge window [io  0x9000-0xfffe]

> Is this a correct understanding of what the Linux pci code now expects
> to find?  Which bit of the ACPI spec should I use to beat the BIOS
> engineers over the head to point out the error of their ways?

On ia64, we've always used _CRS to find the resources for host bridges
(though we only recently started printing out the windows), and PCI
has always relied on what we find.  But if we only find I/O port
ranges, something is seriously wrong.

It's possible we're seeing something new in _CRS that we don't handle
correctly, e.g., maybe resource_to_window() is incorrectly rejecting
something.

I'd start with a patch like this (just the rsutils.c piece):
  http://bugzilla.kernel.org/attachment.cgi?id776

If you can post the output with that patch, we can manually decode the
_CRS buffer straight from ACPI, so we can at least figure out whether
to look at Linux or the BIOS.

If this is really a BIOS issue, I would expect Windows to fail
miserably as well.

Bjorn
