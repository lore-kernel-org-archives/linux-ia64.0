From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 15 May 2012 04:13:37 +0000
Subject: Re: loading linux-3.3 with ski sim crashes
Message-Id: <201205150013.38048.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart11057624.F94EWE29Rz"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205110646.29925.vapier@gentoo.org>
In-Reply-To: <201205110646.29925.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart11057624.F94EWE29Rz
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 14 May 2012 17:26:48 Tony Luck wrote:
> On Fri, May 11, 2012 at 3:46 AM, Mike Frysinger <vapier@gentoo.org> wrote:
> > i'm using gcc-4.5.3, binutils-2.22, and linux-3.3.  i did `make
> > sim_defconfig`, then `make`, then `make boot`.
>=20
> Al Viro got SKI to boot just over a week ago. The only problem that he
> reported was this one:
>=20
> http://www.spinics.net/lists/linux-scsi/msg59106.html
>=20
> Your stack trace doesn't look all that likely to match this (no scsi
> anything in your trace) ... but worth trying either Al's patch or jejb's
> proposed better patch.

i tried linux-3.4-rc7 instead and doesn't oops on boot.  it hits scsi error=
s=20
(not oops), but this looks like something i can poke further.
=2Dmike

--nextPart11057624.F94EWE29Rz
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPsdfxAAoJEEFjO5/oN/WB5ukP+gOcfAcg8vkgFpZ4YxwZV7Nf
mdFWP7KpoRAby+59fJSbpGyeqxMAUEa1qESYPyNg47Us7LDKdBzZ+Aq0gNmumtrk
TcsAaNp0HBhrrF5uZ6/D1NZknqd9AMB31y0RbBy4pA87uQQLhOx3UhQ5vTOz61DS
GEqy7zQgUbuPB3DdVXZkDfFV0f9qhKk9vjpZQI8hyujruFYUVx8WlaRG5z8jDjpH
AXHpDhzvqHpXnaSmBRI6afDRfPGlGHNYCGeMXQ6+hJmVnB3GhzycVGUj66waIFRY
fOlNgoyXHLFnIGDmzr1iQ+tHg+fj/9J3jcuyGT/0F1v5iVpelOyVoJwgA8hPV8ef
Y/sxidluwTL2dZFMQasbcTi0kHpOsss47JEwTAf2rsxwx/7k+FFAJPO/aJqddIiA
73gtJFSjRwWybkndHgbDOQq2yCy0JMg8+rdojnTbcDwFlDuVfj9RN3waqn+Wydir
xvzAOu/pxQXKOjaZOEfH4Ypx2+Tty/GqjMC9lhO1UmytDtflc/yGVm/+6JQFNtcF
Z2P3U23IzXcFmTG3XbgsVvEnA1GGPNacsT7XXxFba4YIFzcJa3KsiKSo6Uf4SScY
vSw2OTPwh32J4ARAabEMnvDLN9XsBsAAk1ThuJFwB3cVt9Ro62+2ovjOP2gFsgQS
EJrj+3ezd1eDmYlWKBlq
=HXwU
-----END PGP SIGNATURE-----

--nextPart11057624.F94EWE29Rz--
