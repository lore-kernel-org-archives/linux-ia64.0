From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 09 Apr 2017 10:38:36 +0000
Subject: Re: ia64: fix module loading for gcc-5.4
Message-Id: <20170409113836.08f3f68b@sf>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/VNLCMJGiW=8lsYIsWBhuA6e"
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
        <20170408195318.18080-1-slyfox@gentoo.org>
        <79cc2afd-1655-c276-a53f-2e2202a7e0ee@users.sourceforge.net>
        <20170409095121.5f0b6a1e@sf>
        <bc2dbb55-54b3-e62e-a54f-aa1bbbc3aa5f@users.sourceforge.net>
In-Reply-To: <bc2dbb55-54b3-e62e-a54f-aa1bbbc3aa5f@users.sourceforge.net>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H . J . Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

--Sig_/VNLCMJGiW=8lsYIsWBhuA6e
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 9 Apr 2017 11:02:43 +0200
SF Markus Elfring <elfring@users.sourceforge.net> wrote:

> >>> That caused ia64 module loader to choke
> >>> on such instructions:
> >>>     fuse: invalid slot number 1 for IMM64   =20
> >>
> >> Why does it matter to check such a value? =20
> >=20
> > I'm not sure I follow the question. Is your question about
> > linux kernel relocation code handler, gcc or ia64 instruction format? =
=20
>=20
> I am just curious if this source code could also work without
> the mentioned check.

It should work for valid code, yes. The flip side of check removal
is to miss malformed relocation (say, when instruction "address" is
wrong due to obscure toolchain bug). In this case apply_imm64()
would silently corrupt unrelated memory instead of crashing kernel.

> Would it make sense to check more than two values there?

AFAIU ia64 does not allow encoding imm64/imm60 instructions
spanning slot=3D0 at all.

ia64_patch_imm64() can handle only imm64 bundles that span
only both slot 1 and slot 2 at the same time. It can accept
either slot=3D1 "address" or slot=3D2 "address". Anything else would
be malformed.

--=20

  Sergei

--Sig_/VNLCMJGiW=8lsYIsWBhuA6e
Content-Type: application/pgp-signature
Content-Description: =?unknown-8bit?b?0KbQuNGE0YDQvtCy0LDRjyDQv9C+0LTQv9C40YHRjA==?= OpenPGP

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQSZKa0VG5avZRlY01hxoe52YR/zqgUCWOoPLAAKCRBxoe52YR/z
qsnwAJ44xz7DEeR1Vc/CeOUAQSAbS7fpyQCfYu0h1q91r9vHB8YJxmDnfQ913t0=
=Rt92
-----END PGP SIGNATURE-----

--Sig_/VNLCMJGiW=8lsYIsWBhuA6e--
