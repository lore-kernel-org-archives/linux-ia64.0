From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Mon, 10 Apr 2017 21:53:36 +0000
Subject: Re: [PATCH v3] ia64: fix module loading for gcc-5.4+
Message-Id: <20170410225336.5856d652@sf>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/WvVhLTJJ_SefDbpmjhBGQUU"
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
        <20170408195318.18080-1-slyfox@gentoo.org>
        <d8146490-2bc4-3884-a64e-1e5894a023e3@users.sourceforge.net>
In-Reply-To: <d8146490-2bc4-3884-a64e-1e5894a023e3@users.sourceforge.net>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H. J. Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

--Sig_/WvVhLTJJ_SefDbpmjhBGQUU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Apr 2017 19:23:28 +0200
SF Markus Elfring <elfring@users.sourceforge.net> wrote:

> > -	if (slot(insn) !=3D 2) {
> > +	if (slot(insn) !=3D 1 && slot(insn) !=3D 2) { =20
>=20
> +	int const s =3D slot(insn);
> +	if (s < 1 || s > 2) {
>=20
> Do run time characteristics matter for such a condition check here?

It's done once at kernel module load time. My guess would be
"not critical at all".

slot() is a pure arithmetic static inline function. You can compare
assembly output before and after your change.

You can measure the difference yourself using 'ski' emulator.
That's for example how I debugged and tested the patch:
     http://trofi.github.io/posts/199-ia64-machine-emulation.html

--=20

  Sergei

--Sig_/WvVhLTJJ_SefDbpmjhBGQUU
Content-Type: application/pgp-signature
Content-Description: =?unknown-8bit?b?0KbQuNGE0YDQvtCy0LDRjyDQv9C+0LTQv9C40YHRjA==?= OpenPGP

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQSZKa0VG5avZRlY01hxoe52YR/zqgUCWOv+4AAKCRBxoe52YR/z
qu2tAJ9bTNRr0bZqMxqIFQbjwkRsRdQDggCdHGzPTv1ncLzi5gutUHyILTE4qRk=
=S+Xn
-----END PGP SIGNATURE-----

--Sig_/WvVhLTJJ_SefDbpmjhBGQUU--
