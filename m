From: Matt Domsch <Matt_Domsch@dell.com>
Date: Fri, 06 Jan 2006 17:15:08 +0000
Subject: Re: [PATCH 2.6.15 1/2] ia64: use i386 dmi_scan.c
Message-Id: <20060106171508.GA19605@lists.us.dell.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060104221627.GA26064@lists.us.dell.com> <20060105173740.GA20650@lists.us.dell.com> <200601051054.18867.bjorn.helgaas@hp.com> <200601051702.00150.bjorn.helgaas@hp.com>
In-Reply-To: <200601051702.00150.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bjorn.helgaas@hp.com>
Cc: Alex Williamson <alex.williamson@hp.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-ia64@vger.kernel.org, ak@suse.de, openipmi-developer@lists.sourceforge.net, akpm@osdl.org, linux-kernel@vger.kernel.org

On Thu, Jan 05, 2006 at 05:02:00PM -0700, Bjorn Helgaas wrote:
> On Thursday 05 January 2006 10:54, Bjorn Helgaas wrote:
> > On Thursday 05 January 2006 10:37, Matt Domsch wrote:
> > > This system (Dell PowerEdge 7250, very very similar to an Intel
> > > 4-way Itanium2 server) doesn't have an SPMI table, but it does have
> > > the IPMI information in the SMBIOS table.
> > 
> > But the IPMI device *should* be described in the ACPI namespace, so
> > using acpi_bus_register_driver() should be sufficient.
> 
> You mentioned on IRC that /sys/firmware/acpi/namespace didn't
> contain anything that looked like an IPMI device.  Try dumping the
> actual DSDT and looking there -- I'm not sure everything makes it
> into /sys/firmware/acpi/...
> 
> Use the latest "pmtools" from here:
>     http://ftp.kernel.org/pub/linux/kernel/people/lenb/acpi/utils
> 
> and "iasl" to disassemble it.
> 
> I did this on an Intel Tiger, and didn't see any "IPI" devices in the
> namespace either.  I think it's a firmware bug if the hardware
> is there but not described in the namespace.
> 
> So maybe you'd have to grub through SMBIOS to workaround
> the firmware defect.

Indeed.  I updated the BIOS to the latest available, and it doesn't
list the IPMI controller in the ACPI namespace.  FWIW, this is
effectively an Intel S870BN4 "Tiger4" system.  FWIW2, the Dell
PowerEdge x8xx line (current shipping EM64T servers) doesn't have the
IPMI controller in the ACPI namespace either.

I reworked the patch, such that on EFI-capable systems, it uses
efi.smbios to find the _DMI_ table header, and on all non-EFI systems,
continues the brute force search from 0xF0000 as before.

Thanks,
Matt

-- 
Matt Domsch
Software Architect
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
