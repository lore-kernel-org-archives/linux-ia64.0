From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 15 May 2012 04:27:14 +0000
Subject: Re: loading linux-3.3 with ski sim crashes
Message-Id: <201205150027.15766.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart2129892.HB23eYeADW"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205110646.29925.vapier@gentoo.org>
In-Reply-To: <201205110646.29925.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart2129892.HB23eYeADW
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 15 May 2012 00:13:37 Mike Frysinger wrote:
> On Monday 14 May 2012 17:26:48 Tony Luck wrote:
> > On Fri, May 11, 2012 at 3:46 AM, Mike Frysinger <vapier@gentoo.org> wro=
te:
> > > i'm using gcc-4.5.3, binutils-2.22, and linux-3.3.  i did `make
> > > sim_defconfig`, then `make`, then `make boot`.
> >=20
> > Al Viro got SKI to boot just over a week ago. The only problem that he
> > reported was this one:
> >=20
> > http://www.spinics.net/lists/linux-scsi/msg59106.html
> >=20
> > Your stack trace doesn't look all that likely to match this (no scsi
> > anything in your trace) ... but worth trying either Al's patch or jejb's
> > proposed better patch.
>=20
> i tried linux-3.4-rc7 instead and doesn't oops on boot.  it hits scsi
> errors (not oops), but this looks like something i can poke further.

ok, those failings were due to incorrect use of simscsi and poor=20
documentation.  fortunately, strace helped, and i'm booting userland now.

i didn't need that patch to boot, but it didn't hurt either.
=2Dmike

--nextPart2129892.HB23eYeADW
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPsdsjAAoJEEFjO5/oN/WBKwMP/1uQstgyFM2bppn3Ym/DMiDa
skuXVgM8AW9ERdAvMOW5YQPCFaafPZIBNRhS1Sd6/UsmOrRDSxebu7mlO6hKd95u
ylO15iowG3ozMyE5H+iHBIdJuU6o3JIMEEWaIlNDt93eBT2xoaopQbHVZjzxX8WM
JTzOK3QTJ2z+fGdXFPwek85x/RItfwWVA2kL8Gl6QZARx/Gwh8AIm3WO+yUzDg8d
WCIxDEPpONPITwwWyl0EZDJ+s8KiDf6TO8Gy2kgWyhsYqGMUDxl6E2gEpO5g9u6N
uzKjoDL2AvrBLMlwFTnrtyAD+VrY/tmXtK5QzY47NckF2tpk3/qkattGMKhYgLhQ
iup1tI5rTSXtOk1SAfh1Y3KykN4ttzCTj4lOpqOTjNUbVs3R5mJ1w8nZtVBG02jJ
zd8LzXnKU6FDL+FRek0X7XnGUoZackeR3wjwWWVvetIfgKbO25Q7UpqNS4JrIRqL
X9w3epGTScSVuJltq+Uyl9XzJvgHtCOAQokUy/4RNhfS2Ow1J6fycvQGJzrw6wR8
1ym7IX8br31ug4Hqwf33b6YxOoCQXLkIG1V2yGu6JIxCgOWdVSYo7JiIh7aUETkU
Pg0YVIMN7wwuF7IRPebRly64eIzq3GAoTEtXj+aH1TYDi56PALH3HcaLbDbvGDrV
4Ci+ohXFuEeHtKx5ojRm
=OzXY
-----END PGP SIGNATURE-----

--nextPart2129892.HB23eYeADW--
