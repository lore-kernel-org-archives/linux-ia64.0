From: Dennis Schridde <devurandom@gmx.net>
Date: Tue, 21 Jan 2014 19:40:00 +0000
Subject: Re: Kernel compiled with gcc-4.6+ fails to boot on ia64
Message-Id: <20140121204000.65b434eb@samson>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/4cuHYmS6WR7KItJTZQ4rcex"
List-Id: <linux-ia64.vger.kernel.org>
References: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31DB1BDA@ORSMSX106.amr.corp.intel.com>
To: linux-ia64@vger.kernel.org

--Sig_/4cuHYmS6WR7KItJTZQ4rcex
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Am Tue, 21 Jan 2014 17:32:13 +0000
schrieb "Luck, Tony" <tony.luck@intel.com>:

> > Please assist me in acquiring more information, as there currently
> > is no output at all on the serial console I am attached to (via the
> > management console, which is set up in EFI as the default console,
> > which appears in Linux as ttyS3). Usually I get output right from
> > the start, so I assume that the problem must be very early in the
> > boot process.
>=20
> Did you try the ia64 early console options.  See
> Documentation/ia64/serial.txt ... boot argument you need to add on a
> rx2600 will look something like this:
>=20
> console=3Duart,mmio,0xff5e0000
>=20
> but the hex number will be whatever you need for ttyS3 (run "dmesg |
> grep tty" on your kernel that does boot to find the right value).

I just tried that and there is still no output. I have=20
 append=3D"rd.lvm.lv=3Dmaroon/usr console=3Duart,mmio,0xf8050000"
in elilo.conf (and confirmed that it got installed that way in
\EFI\gentoo\elilo.conf). In a test with 3.12.7-gentoo compiled with
gcc-4.5.4, I could see the commandline being seen this way by the
kernel. The same version, cleaned, rebuilt with gcc-4.7.3, does not
output anything at all and reboots after a few seconds.

--Dennis

--Sig_/4cuHYmS6WR7KItJTZQ4rcex
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJS3s0RAAoJEGIxC0Gvwa5ape0P/ROMSnrkZmL3DNiJUiVEs60m
75JhylxbLrp+f16Bnw40ffFF4vPn9nHVpgACXuCGHlK2iUZXd3BuJcf9h5L7Qq0h
BXqm7kOGuUk+NsM32kou923MUfGu+D/RBpPBmoFnCWi82F+D9tPD1JmLTQQD5lj+
hDlKi+ZlXtroFkieuwPGiNRLjVopQeoNmAAKUCcc6JTRpMgBqbu6OW++vFmyTWse
i46QPiumVqZ7Sv7nBap5gb5yyt0JzjVMtZsJ07LIk5M5zVD9bfTJcMSA9aIdyEgQ
jTsTZVG21L5hpX9K9d51Iv/IJcQIau/vpkhtpBXGn9XVbQc+8mMtfBWNdpto/8KP
tkGko6oXdNc4d2az7rf95W2cESI9kS+Oc9aS6zs/hUvrmgcaZbZQEHw5Q+t5W47B
COejWzVVPWsajn1DfXE7mZbraDqxSejttG8+cM86VdobgQMwXXAkiCvVgF16eH7N
uhsunNrok2O0Hg+aZxazcbgoZ4ev2lYrWH9mivylhqICbNCEAbJUXJGzfag2SFkS
xBiS/h2A1sgepMpA9fMToFrgfUeUI0V0R0A2VoTfVKfJYikqWt6tnX1Z1J/YHCGM
eOffU6SNczLisfVCiYTuqKjCXc8dVCml0c4wmefrHjuXSBVnBNFBaCR0TI5ezI8H
U6GFe1UXNEMrm8C0T2Jy
=ZsLj
-----END PGP SIGNATURE-----

--Sig_/4cuHYmS6WR7KItJTZQ4rcex--
