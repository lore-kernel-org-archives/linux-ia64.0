From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 14 Sep 2004 04:27:40 +0000
Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <1095136060.8780.23.camel@mythbox>
List-Id: <linux-ia64.vger.kernel.org>
References: <37F890616C995246BE76B3E6B2DBE05501FB4ABB@orsmsx403.amr.corp.intel.com>
In-Reply-To: <37F890616C995246BE76B3E6B2DBE05501FB4ABB@orsmsx403.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Moore, Robert" <robert.moore@intel.com>
Cc: Gerald Pfeifer <gp@suse.de>, "Brown, Len" <len.brown@intel.com>, linux-ia64@vger.kernel.org, ACPI Developers <acpi-devel@lists.sourceforge.net>

On Mon, 2004-09-13 at 15:59 -0700, Moore, Robert wrote:
> Here's an example:
> 

   But how can we be sure we're bug for bug and feature for feature
compatible with an arbitrary version of Windows?  I got curious and
looked at the DSDT on my home PC, generic VIA KM266 chipset.  Sure
enough:

    Name (OSFL, 0x00)
    Method (_INI, 0, NotSerialized)
    {
        \_SB.PCI0.IODT ()
        If (MCTH (\_OS, "Microsoft Windows NT"))
        {
            Store (0x00, OSFL)
        }
        Else
        {
            If (MCTH (\_OS, "Microsoft Windows"))
            {
                Store (0x01, OSFL)
            }
            Else
            {
                If (MCTH (\_OS, "Microsoft WindowsME: Millennium Edition"))
                {
                    Store (0x02, OSFL)
                }
                Else
                {
                    Store (0x03, OSFL)
                }
            }
        }
    }

Looking for consumers of OSFL...

        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A03"))
            Name (_ADR, 0x00)
            Name (_BBN, 0x00)
            Method (_S3D, 0, NotSerialized)
            {
                If (OSFL)
                {
                    Return (0x02)
                }
                Else
                {
                    Return (0x03)
                }
            }

OK, maybe that's a good thing...  several more like that on USB devices.

        Device (SYSR)
        {
            Name (_HID, EisaId ("PNP0C02"))
            Method (_STA, 0, NotSerialized)
            {
                If (OSFL)
                {
                    Return (0x0F)
                }

                Return (0x00)
            }
             Name (IORG, ResourceTemplate ()
            {
                FixedIO (0x0010, 0x10)
                FixedIO (0x0022, 0x1E)
                FixedIO (0x0044, 0x1C)
                ...
            })
            Method (_CRS, 0, NotSerialized)
            {
                Return (IORG)
            }
        }

Hmm, it's not so obvious this one is a win.  There's another like that
for a PNP0C01 device listing Memory32Fixed ranges.  And another named
PIC providing an interrupt resource.  The motherboard driver could have
made use of these if they were marked as present, but they aren't for
"Microsoft Windows NT".

    Method (_PTS, 1, NotSerialized)
    {
        Store (Arg0, DBG8)
        If (LAnd (LEqual (Arg0, 0x04), LEqual (\_SB.PCI0.OSFL, 0x02)))
        {
            Sleep (0x0BB8)
        }
        ...
        If (LNot (\_SB.PCI0.OSFL))
        {
            Store (\_SB.PCI0.TLBC, PTB1)
        }
       ...
       Store (\_SB.PCI0.OSFL, \_SB.PCI0.W2FG)
       ...

Ok, we're doing some special stuff here, a stall for Windows ME, a store
for Windows NT, but how do we know those aren't bug workarounds specific
to that version?  There's a corresponding Windows NT check in the _WAK
method. 

   Of course these are all examples of i386 ACPI implementations.  If
there was an ia64 ACPI implementation that used _OS, who's to say that
"Microsoft Windows NT" wouldn't be the untested case.  I don't know what
Windows sets the _OS to for their ia64 releases.  "Microsoft Windows NT"
might be as arbitrary as setting it to "foo" there.

   I assume a blacklist was discussed when this was brought up earlier
on the list.  I'll have to go look why that didn't fly.  Thanks,

	Alex

