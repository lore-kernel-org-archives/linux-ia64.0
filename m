From: "Moore, Robert" <robert.moore@intel.com>
Date: Mon, 13 Sep 2004 22:59:05 +0000
Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <37F890616C995246BE76B3E6B2DBE05501FB4ABB@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095103349.2512.16.camel@d845pe>
In-Reply-To: <1095103349.2512.16.camel@d845pe>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Moore, Robert" <robert.moore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Gerald Pfeifer <gp-l3A5Bk7waGM@public.gmane.org>
Cc: "Brown, Len" <len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Alex Williamson <alex.williamson-VXdhtT5mjnY@public.gmane.org>, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ACPI Developers <acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

Here's an example:

> -----Original Message-----
> From: acpi-devel-admin@lists.sourceforge.net [mailto:acpi-devel-=20
> admin@lists.sourceforge.net] On Behalf Of Martin Ginkel
> Sent: Wednesday, May 26, 2004 3:09 PM
> To: acpi-devel@lists.sourceforge.net
> Cc: oysteigi@stud.ntnu.no
> Subject: Re: [ACPI] Wrong AC state
>=20
> Martin Ginkel wrote:
> > On my laptop (Fujitsu-Siemens Amilo D 8830) this seems to be=20
> > partially broken. The /proc/ac_adapter/AC0/state has a value on-line

> > or off-line from boot-time and doesn't change later on.
>=20
> OK found a solution while reading the disassembled DSDT:
> The Code ist checking the OS-Version:
>=20
>      Method (_PSR, 0, NotSerialized)
>      {
>        If (LNot (LEqual (FAKE, 0x00)))
>        {
>          Return (0x00)
>        }
>        Else
>        {
>          If (LOr (LEqual (OSFL (), 0x00), LEqual (OSFL (), 0x04)))
>            {
>               Store (\_SB.PCI0.SBRG.EC0.XCIN, Local0)
>                                      }
>           Else
>            {
>               Store (ACIN, Local0)
>            }
>=20
>               Return (Local0)
>            }
>       }
>=20
>=20
> OSFL is returning 0x00 for win2000 and 0x04 for windows nt.
> I defined as a dirty fix:
> ./include/acpi/platform/aclinux.h:50:
> #define ACPI_OS_NAME               "Microsoft Windows NT"
>=20
> Now the Power Monitor reacts instantly.
>=20
> Well: the Bios seems to be designed for Microsoft Windows ;-P
>=20
>=20
> 	CU
> 	Martin
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: Oracle 10g
> Get certified on the hottest thing ever to hit the market... Oracle=20
> 10g. Take an Oracle 10g class now, and we'll give you the exam FREE.=20
> http://ads.osdn.com/?ad_id149&alloc_id=8166&op=3Dclick
> _______________________________________________
> Acpi-devel mailing list
> Acpi-devel@lists.sourceforge.net=20
> https://lists.sourceforge.net/lists/listinfo/acpi-devel

> -----Original Message-----
> From: Moore, Robert
> Sent: Monday, September 13, 2004 3:11 PM
> To: 'Gerald Pfeifer'
> Cc: Brown, Len; Alex Williamson; linux-ia64@vger.kernel.org; ACPI
> Developers
> Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
>=20
> I don't know what the specific machines were.  There was lots of
> discussion on the Linux/ACPI list before we did this.  I think they
were
> all 32-bit machines, however.
>=20
>=20
> > -----Original Message-----
> > From: Gerald Pfeifer [mailto:gp@suse.de]
> > Sent: Monday, September 13, 2004 2:30 PM
> > To: Moore, Robert
> > Cc: Brown, Len; Alex Williamson; linux-ia64@vger.kernel.org; ACPI
> > Developers
> > Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
> >
> > On Mon, 13 Sep 2004, Moore, Robert wrote:
> > > Not only is the !Windows code path apparently untested for the
most
> > > part, we have discovered many machines that simply do not work
> properly
> > > unless we report "Microsoft Windows NT" for the _OS string.
> >
> > Can you name some of these (broken) systems?
> >
> > Given that we apparently did not encounter this with our 2.6.5-based
> SLES9
> > kernel so far, I'm a bit sceptical that many (if any) ia64 machines
are
> > affected.
> >
> > Gerald
