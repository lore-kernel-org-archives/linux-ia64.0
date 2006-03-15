From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 15 Mar 2006 16:49:23 +0000
Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
Message-Id: <200603150949.23178.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <971FCB6690CD0E4898387DBF7552B90E04ABAAC2@orsmsx403.amr.corp.intel.com>
In-Reply-To: <971FCB6690CD0E4898387DBF7552B90E04ABAAC2@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Thomas Renninger <trenn@suse.de>

On Wednesday 15 March 2006 08:47, Moore, Robert wrote:
> They should be fixed in ACPICA version 20060217:
> 
> Fixed a problem where several resource descriptor types could overrun
> the internal descriptor buffer due to size miscalculation: VendorShort,
> VendorLong, and Interrupt. This was noticed on IA64 machines, but could
> affect all platforms.

Did you determine that the buffer overrun problem that caused
the slab corruption was the same thing that caused the unaligned
access messages?

Can you point me to the patch?  Or possibly a place to get the
20060217 ACPICA and the previous version, so I can extract the
patch myself?  I poked around the Intel ACPI web page, but could
only find the most recent ACPICA; there didn't seem to be any
history.

Bjorn

> > -----Original Message-----
> > From: Bjorn Helgaas [mailto:bjorn.helgaas@hp.com]
> > Sent: Tuesday, March 14, 2006 4:00 PM
> > To: Luck, Tony
> > Cc: linux-acpi@vger.kernel.org; linux-ia64@vger.kernel.org; Moore,
> Robert;
> > Thomas Renninger
> > Subject: Re: some new unaligned access while booting ia64 (HP rx2620)
> > 
> > On Thursday 02 February 2006 12:46, Luck, Tony wrote:
> > > Booting a snapshot of Linus' tree this morning I saw a few (new?)
> > > kernel unaligned access warnings:
> > >
> > > ACPI: Subsystem revision 20060127
> > > ACPI: Interpreter enabled
> > > ACPI: Using IOSAPIC for interrupt routing
> > > ACPI: PCI Root Bridge [PCI0] (0000:00)
> > > kernel unaligned access to 0xe00000407ec5a204, ip=0xa0000001003af8c0
> > > kernel unaligned access to 0xe00000407ec5a23c, ip=0xa0000001003af8c0
> > > kernel unaligned access to 0xe00000407ec5a28c, ip=0xa0000001003af8c0
> > > kernel unaligned access to 0xe00000407ec5a1fc, ip=0xa0000001003ae6c1
> > > kernel unaligned access to 0xe00000407ec5a204, ip=0xa0000001003ae6d1
> > > ACPI: PCI Interrupt Routing Table [\_SB_.SBA0.PCI0._PRT]
> > > ACPI: PCI Root Bridge [PCI1] (0000:20)
> > 
> > Did we ever resolve this?  Are we just waiting for new ACPI bits
> > to trickle into -mm and mainline?
> > 
> > I'd like to see the patch for just this issue, because it affects
> > SLES10, and Novell might balk at a complete ACPI CA update, but
> > might take just the individual patch.
> > 
> > Bjorn
> 
