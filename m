From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Date: Fri, 10 Apr 2009 10:12:20 +0000
Subject: Re: cross-compilers
Message-Id: <20090410101220.GF7921@lug-owl.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="oeyAOmeIWsNJ4sHb"
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com> <20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com> <20090407225457.86f8a458.akpm@linux-foundation.org> <20090409003308.GK16602@bilbo.ozlabs.org> <20090408174443.79e71503.akpm@linux-foundation.org> <20090409215207.GN16602@bilbo.ozlabs.org> <20090409234750.GE7921@lug-owl.de>
In-Reply-To: <20090409234750.GE7921@lug-owl.de>
To: Andrew Morton <akpm@linux-foundation.org>, Alex Chiang <achiang@hp.com>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, Sam Ravnborg <sam@ravnborg.org>


--oeyAOmeIWsNJ4sHb
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-04-10 01:47:50 +0200, Jan-Benedict Glaw <jbglaw@lug-owl.de> wr=
ote:
> On Fri, 2009-04-10 07:52:07 +1000, Tony Breeds <tony@bakeyournoodle.com> =
wrote:
> > On Wed, Apr 08, 2009 at 05:44:43PM -0700, Andrew Morton wrote:
> >=20
> > > Please do.
> >=20
> > linux-next is built on powerpc so I needed to rebuild many of the compi=
lers for
> > intel.
>=20
> I've started a build-bot like script for binutils + GCC from CVS/GIT.
> If it builds through, I'll start uploading i686 hosted compilers
> later on today.

So... I've now build trunk kernel-only cross-compilers (hosted on
i686) for these targets:

	alpha-linux.tar.bz2
	am33_2.0-linux.tar.bz2
	arm-linux.tar.bz2
	avr-linux.tar.bz2
	bfin-uclinux.tar.bz2
	cris-linux.tar.bz2
	frv-linux.tar.bz2
	h8300-elf.tar.bz2
	hppa64-linux.tar.bz2
	hppa-linux.tar.bz2
	i386-linux.tar.bz2
	ia64-linux.tar.bz2
	m32r-linux.tar.bz2
	m68k-linux.tar.bz2
	mips64-linux.tar.bz2
	mips-linux.tar.bz2
	powerpc64-linux.tar.bz2
	powerpc-linux.tar.bz2
	s390-linux.tar.bz2
	sh3-linux.tar.bz2
	sh64-linux.tar.bz2
	sparc64-linux.tar.bz2
	sparc-linux.tar.bz2
	v850e-linux.tar.bz2
	vax-linux.tar.bz2
	x86_64-linux.tar.bz2
	xtensa-linux.tar.bz2

They seem to build reliably, I'd easily build them once a day. If
anybody is interested, I'll put them somewhere on lug-owl.de, or if
you wish, on kernel.org .

Comments?

MfG, JBG

--=20
      Jan-Benedict Glaw      jbglaw@lug-owl.de              +49-172-7608481
Signature of:          GDB has a 'break' feature; why doesn't it have 'fix'=
 too?
the second  :

--oeyAOmeIWsNJ4sHb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAknfG4QACgkQHb1edYOZ4btIhgCeJfszSwWkZev1aIafhUzqrSP6
SL0An2hUmcMMYDZ771s/V7IBg5LXoAjo
=Kw03
-----END PGP SIGNATURE-----

--oeyAOmeIWsNJ4sHb--
