From: "Moore, Robert" <robert.moore@intel.com>
Date: Fri, 17 Sep 2004 17:18:40 +0000
Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
Message-Id: <37F890616C995246BE76B3E6B2DBE05502070E56@orsmsx403.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1095103349.2512.16.camel@d845pe>
In-Reply-To: <1095103349.2512.16.camel@d845pe>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: "Moore, Robert" <robert.moore@intel.com>, Alex Williamson <alex.williamson@hp.com>
Cc: Gerald Pfeifer <gp@suse.de>, "Brown, Len" <len.brown@intel.com>, linux-ia64@vger.kernel.org, ACPI Developers <acpi-devel@lists.sourceforge.net>

A new example:

> -----Original Message-----
> From: Moore, Robert
> Sent: Friday, September 17, 2004 10:10 AM
> To: 'Andreas Leppert'; acpi-devel@lists.sourceforge.net
> Subject: RE: [ACPI] ACPI_OS_NAME: no battery or no ac_adapter
>=20
> In newer versions of ACPI CA, we have changed ACPI_OS_NAME to "Microsoft
> Windows NT" for exactly this reason.
>=20
> Bob
>=20
>=20
> > -----Original Message-----
> > From: acpi-devel-admin@lists.sourceforge.net [mailto:acpi-devel-
> > admin@lists.sourceforge.net] On Behalf Of Andreas Leppert
> > Sent: Friday, September 17, 2004 6:04 AM
> > To: acpi-devel@lists.sourceforge.net
> > Subject: [ACPI] ACPI_OS_NAME: no battery or no ac_adapter
> >
> > hi,
> >
> > i've a strange problem on my fujitsu laptop.  If i compile my kernel
> using
> > acpi, everything works fine, but acpi -V doesn't change the value of
> > ac_adapter info. it's always set to "on-line". it doesnt matter if the
> > ac_adapter is plugged in or not. always "on-line".
> >
> > then i found this:
> > http://sourceforge.net/mailarchive/message.php?msg_id=8560832
> >
> > so i changed the value of ACPI_OS_NAME in my
> > /usr/src/linux/include/acpi/platform/aclinux.h from "Linux" to
> "Microsoft
> > Windows NT". Now, ac_adapter changes its value from "on-line" to "off-
> > line" if i unplug the ac_adapter.
> >
> > But now, acpi -V doesnt show me any battery information. the line is
> just
> > omitted! so what to do?
> >
> > under http://andileppert.de/dsdtl.dsl you can find my dsdt. you will see
> > that there are a few _OS commands...  what can i do? this is a strange
> > thing...
> >
> > thanks in advance
> > Andi Leppert
> > _________________________________________________________
> > Mit WEB.DE FreePhone=AE mit h=F6chster Qualit=E4t ab 0 Ct./Min.
> > weltweit telefonieren! http://freephone.web.de/?mc=021201
> >
> >
> >
> > -------------------------------------------------------
> > This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
> > Project Admins to receive an Apple iPod Mini FREE for your judgement on
> > who ports your project to Linux PPC the best. Sponsored by IBM.
> > Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
> > _______________________________________________
> > Acpi-devel mailing list
> > Acpi-devel@lists.sourceforge.net
> > https://lists.sourceforge.net/lists/listinfo/acpi-devel

> -----Original Message-----
> From: Moore, Robert
> Sent: Tuesday, September 14, 2004 8:00 AM
> To: 'Alex Williamson'
> Cc: Gerald Pfeifer; Brown, Len; linux-ia64@vger.kernel.org; ACPI
> Developers
> Subject: RE: [ACPI] [PATCH] restore _OS object to "Linux" for ia64
>=20
>=20
> >
> >    But how can we be sure we're bug for bug and feature for feature
> > compatible with an arbitrary version of Windows?  I got curious and
> > looked at the DSDT on my home PC, generic VIA KM266 chipset.  Sure
> > enough:
>=20
> We aren't ever "sure".
>=20
> All I can say is that MS is the "defacto" implementation and that we
> attempt to both adhere to the ACPI spec and make some accommodations to
> the MS implementation (such as supporting the control method "implicit
> return")
>=20
> The NT/XP MS implementation is their best version with the fewest bugs, so
> this is the version that we are compatible with.
>=20
> Given this, and the fact that most iA32 platform BIOSs are developed and
> tested with XP, using the "Microsoft Windows NT" identification string
> seems to be the best way to go.  By doing this, we have fixed at least
> several machines (maybe more) that were not working properly under Linux,
> and there haven't been any problems reported that I know of.
>=20
> Bob
>=20

