From: John Keller <jpk@sgi.com>
Date: Fri, 27 Jan 2006 13:54:00 +0000
Subject: Re: [PATCH] RESEND - SN: Add initial ACPI support
Message-Id: <200601271354.k0RDs1uV037880@fcbayern.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200601261020.45802.bjorn.helgaas@hp.com>
In-Reply-To: <200601261020.45802.bjorn.helgaas@hp.com> from "Bjorn Helgaas" at Jan 26, 2006 10:20:45 AM
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <linux-acpi-owner@vger.kernel.org>
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org

Bjorn,

Just noticed that my last reply didn't respond to all your comments....

John
----


> 
> On Monday 23 January 2006 09:00, John Keller wrote:
> > +obj-$(CONFIG_IA64_SGI_SN2)	+= acpi-ext.o
> 
> Just FYI, this code is moving into drivers/acpi soon.  Robert Moore
> might have made a trivial interface change when he integrated it into
> the ACPI CA.  No big deal, basically acpi-ext.c was arch-independent
> and we moved it to generic code.

Yes, I saw earlier discussions of this, and am aware it's coming soon,
and I believe it is already in Len's acpica tree.

...

> 
> > +void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
> 
> This function looks very much like pci_acpi_scan_root().  Is this the
> old, non-ACPI path?

Correct. sn_pci_controller_fixup() is the old non-ACPI path.

