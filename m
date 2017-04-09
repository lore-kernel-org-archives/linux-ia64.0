From: Sergei Trofimovich <slyfox@gentoo.org>
Date: Sun, 09 Apr 2017 08:51:21 +0000
Subject: Re: [PATCH v3] ia64: fix module loading for gcc-5.4
Message-Id: <20170409095121.5f0b6a1e@sf>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Sig_/dBGIy=ldhz8fqkj=tQOYud/"
List-Id: <linux-ia64.vger.kernel.org>
References: <to=<20170408081449.4872-1-slyfox@gentoo.org>
        <20170408195318.18080-1-slyfox@gentoo.org>
        <79cc2afd-1655-c276-a53f-2e2202a7e0ee@users.sourceforge.net>
In-Reply-To: <79cc2afd-1655-c276-a53f-2e2202a7e0ee@users.sourceforge.net>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Fenghua Yu <fenghua.yu@intel.com>, "H . J . Lu" <hjl.tools@gmail.com>, Tony Luck <tony.luck@intel.com>

--Sig_/dBGIy=ldhz8fqkj=tQOYud/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 9 Apr 2017 10:27:52 +0200
SF Markus Elfring <elfring@users.sourceforge.net> wrote:

> > That caused ia64 module loader to choke
> > on such instructions:
> >     fuse: invalid slot number 1 for IMM64 =20
>=20
> Why does it matter to check such a value?

I'm not sure I follow the question. Is your question about
linux kernel relocation code handler, gcc or ia64 instruction
format?

--=20

  Sergei

--Sig_/dBGIy=ldhz8fqkj=tQOYud/
Content-Type: application/pgp-signature
Content-Description: =?unknown-8bit?b?0KbQuNGE0YDQvtCy0LDRjyDQv9C+0LTQv9C40YHRjA==?= OpenPGP

-----BEGIN PGP SIGNATURE-----

iF0EARECAB0WIQSZKa0VG5avZRlY01hxoe52YR/zqgUCWOn2CQAKCRBxoe52YR/z
qjHKAJ9BqGiKhuAx1dLrbQtB8cl4seQ5EgCdEXnCNWhPRYZqFBCFYbEjsNcOK1c=
=mrfJ
-----END PGP SIGNATURE-----

--Sig_/dBGIy=ldhz8fqkj=tQOYud/--
