From: Matthew Wilcox <willy@debian.org>
Date: Thu, 03 Apr 2003 12:30:22 +0000
Subject: Re: [Linux-ia64] rx2600 console output with management card
Message-Id: <marc-linux-ia64-105590723705389@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705386@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705386@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

On Thu, Apr 03, 2003 at 08:53:03AM +0200, Bj=F6rn Torkelsson wrote:
> On Thu, 2003-04-03 at 08:36, Ian Wienand wrote:
> > Hello,
> >=20
> > Does anyone know if there is some trick to getting linux console
> > output through the management processor on the rx2600?  all the
> > documentation states that the management card processor output mirrors
> > the system console when not it it's managment mode -- which it does
> > until linux starts.

Yes, there's a trick ;-(  Here's how it works:

There's three methods for finding serial ports that apply to rx2600
w/ECI card.  First, we parse the HCDP table.  Second, we search the ACPI
namespace for serial ports.  Third, we walk the PCI busses looking for
serial ports.

The two built-in serial ports are in the ACPI namespace, the ECI card
actually contains a PCI bus where we find the serial ports.  Firmware
determines which port is listed in the HCDP table according to which
Console Input & Console Output devices were listed first.  Unfortunately,
you can't tell which one was selected first, so the safe thing to do is
make sure only one is listed.

> Which version of firmware do you have installed? When I upgraded the
> System and BMC firmware to 1.05 (System =3D 1.82, BMC =3D 1.40) I suddenly
> got the same behavior.
>=20
> Before the upgrade I had ttyS0 through the management processor,
> afterwards, however, I have the following mapping:

Yes, after upgrading your firmware, you have to restore your ConIn/ConOut
to sane values.

> console/serial A:       ttyS0
> serial B:               ttyS1
> console/MP:             ttyS3   (same as through the mangagement lan)
> remote/MP:              -----
> ups/MP:                 ttyS2

Mmm.. not exactly.  In the instance you quote here, ttyS3 would be
the mirrored port.  ttyS4 and ttyS5 are the local and remote sessions
respectively.

Of course, it should be:

ttyS0		mirrored console
ttyS1		serial A
ttyS2		serial B
ttyS3		UPS
ttyS4		local session
ttyS5		remote session

once you fix your ConIn/ConOut settings.

--=20
"It's not Hollywood.  War is real, war is primarily not about defeat or
victory, it is about death.  I've seen thousands and thousands of dead bodi=
es.
Do you think I want to have an academic debate on this subject?" -- Robert =
Fisk

