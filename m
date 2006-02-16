From: "Moore, Robert" <robert.moore@intel.com>
Date: Thu, 16 Feb 2006 22:54:03 +0000
Subject: RE: [PATCH] ACPI: fix vendor resource length computation
Message-Id: <971FCB6690CD0E4898387DBF7552B90E0461225F@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200602141613.09152.bjorn.helgaas@hp.com>
In-Reply-To: <200602141613.09152.bjorn.helgaas@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Renninger <trenn@suse.de>, "Luck, Tony" <tony.luck@intel.com>
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, Andreas Schwab <schwab@suse.de>, "Brown, Len" <len.brown@intel.com>, linux-acpi@vger.kernel.org, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, efocht@hpce.nec.com

I recently added a new interface to ACPICA to support this kind of
debugging. It enables/disables debug for a specific control method:

ACPI_STATUS
AcpiDebugTrace (
    char                    *Name,
    UINT32                  DebugLevel,
    UINT32                  DebugLayer,
    UINT32                  Flags);

It would be nice to see this exposed in Linux somehow.

Bob


> -----Original Message-----
> From: Thomas Renninger [mailto:trenn@suse.de]
> Sent: Thursday, February 16, 2006 12:59 AM
> To: Luck, Tony
> Cc: Moore, Robert; Bjorn Helgaas; Andreas Schwab; Brown, Len; linux-
> acpi@vger.kernel.org; linux-ia64@vger.kernel.org; Andrew Morton;
> efocht@hpce.nec.com
> Subject: Re: [PATCH] ACPI: fix vendor resource length computation
> 
> Luck, Tony wrote:
> >> I'm working on the alignment issue also, should be a fix this week.
> >
> > With Bjorn's tip on using console=uart,mmio,0x{address} I can now
> > get a complete trace from boot using acpi_dbg_level = 0xffffff ...
> > well in theory I can, I started the boot two days ago and have
> > 2.2 million lines of output so far, and it is still going!  Now
> > I'm just curious as to whether this will actually complete, but
> > if it doesn't do so in the next few days I'll have to abort the
> > boot and get back to using that system for regression testing on
> > other patches.
> >
> > Sadly, I think that using the "console=uart,..." flag may have
> > caused the kernel to skip the bit of acpi probing that caused the
> > unaligned traps, as I don't see any "unaligned" messages in the
> > output so far ... so this might be a completely futile exercise.
> >
> Better don't use the boot parameters. Try to identify at which point
> the culprit might lie and then embed the code you like to
> debug in the sources into:
> acpi_dbg_level=0xXY (whatever debug level, avoid mutex and other
>                         unnecessary stuff you don't need)
> ... bad code to debug
> 
> acpi_dbg_level=0xF
> 
> I expect the output will never end, there will pop up an acpi
interrupt
> or some polling is done by ACPI and you are trapped in endless
output...
> 
>     Thomas
