From: Martin Pool <mbp@sourcefrog.net>
Date: Tue, 13 Apr 2004 23:55:45 +0000
Subject: Re: oops in serial_out in 2.6.5
Message-Id: <20040413235544.GF13754@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="cz6wLo+OExbGG7q/"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413063757.GA11350@hp.com>
In-Reply-To: <20040413063757.GA11350@hp.com>
To: linux-ia64@vger.kernel.org


--cz6wLo+OExbGG7q/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 13 Apr 2004, Alex Williamson <alex.williamson@hp.com> wrote:
>=20
>    What's in your /var/lib/setserial/autoserial.conf?  What does the
> kernel print out for serial ports on bootup?  I'm guessing they're out
> of sync.  It would be nice if we could stop the oops, but I'm guessing
> the quicker fix is to reconfigure setserial to "kernel" configuration.=20
> Your ttyS0 on irq 49 is likely the builtin UART, not the MP UART.  If
> that fixes it, please report back the differences in config versus
> kernel serial port listings.  Thanks,

Autoserial.conf has

###PORT STATE GENERATED USING AUTOSAVE-ONCE###
###AUTOSAVE-ONCE###
###AUTOSAVE-ONCE###
###AUTOSAVE###
#
# If you want to configure this file by hand, use
# dpkg --configure setserial
# and change the configuration mode of the file to MANUAL. If you do not do=
 this# this file may be overwritten automatically the next time you upgrade=
 the
# package.
#
/dev/ttyS0 uart 16550A port 0x0000 irq 59 baud_base 115200 spd_normal skip_=
test
auto_irq
/dev/ttyS1 uart 16550A port 0x0000 irq 60 baud_base 115200 spd_normal skip_=
test
auto_irq
/dev/ttyS2 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_=
test
/dev/ttyS3 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_=
test
/dev/ttyS4 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_=
test
/dev/ttyS5 uart 16550A port 0x0000 irq 57 baud_base 115200 spd_normal skip_=
test

The kernel reported=20

Apr 13 16:18:25 kate kernel: Serial: 8250/16550 driver $Revision: 1.90 $ 4 =
ports, IRQ sharing enabled
Apr 13 16:18:25 kate kernel: ttyS0 at MMIO 0xf4050000 (irq =3D 49) is a 165=
50A
Apr 13 16:18:25 kate kernel: GSI 0x22(high,edge) -> CPU 0x0000 vector 75
Apr 13 16:18:25 kate kernel: ttyS1 at MMIO 0xff5e0000 (irq =3D 75) is a 165=
50A
Apr 13 16:18:25 kate kernel: GSI 0x23(high,edge) -> CPU 0x0000 vector 76
Apr 13 16:18:25 kate kernel: ttyS2 at MMIO 0xff5e2000 (irq =3D 76) is a 165=
50A
Apr 13 16:18:25 kate kernel: PCI: Found IRQ 49 for device 0000:e0:01.0
Apr 13 16:18:25 kate kernel: IOSAPIC: vector 49 -> CPU 0x0100, enabled
Apr 13 16:18:25 kate kernel: ttyS3 at MMIO 0xf4051000 (irq =3D 49) is a 164=
50
Apr 13 16:18:25 kate kernel: PCI: Found IRQ 49 for device 0000:e0:01.1
Apr 13 16:18:25 kate kernel: IOSAPIC: vector 49 -> CPU 0x0000, enabled
Apr 13 16:18:25 kate kernel: Couldn't register serial port 0000:e0:01.1: -28


I got my machine working again by just removing setserial.  Does it
ever do anything useful on legacy-free ia64?  I wouldn't think people
ever set IRQs or IO addresses by hand after bootup.

--=20
Martin=20

--cz6wLo+OExbGG7q/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAfH4APGPKP6Cz6IsRAi9PAJ0YxFyQJ/JnQK2uTANVcNQ29Mwz4gCeLGMx
SMcG7Zel3CiGrqBMUYtNzTM=
=mqZW
-----END PGP SIGNATURE-----

--cz6wLo+OExbGG7q/--
