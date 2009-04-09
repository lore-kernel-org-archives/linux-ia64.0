From: Jan-Benedict Glaw <jbglaw@lug-owl.de>
Date: Thu, 09 Apr 2009 23:47:50 +0000
Subject: Re: cross-compilers
Message-Id: <20090409234750.GE7921@lug-owl.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="HoGc7FifFwma1EOu"
List-Id: <linux-ia64.vger.kernel.org>
References: <20090408003921.GA5054@ldl.fc.hp.com> <20090408010331.GB10768@sgi.com> <20090408054612.GA6744@ldl.fc.hp.com> <20090407225457.86f8a458.akpm@linux-foundation.org> <20090409003308.GK16602@bilbo.ozlabs.org> <20090408174443.79e71503.akpm@linux-foundation.org> <20090409215207.GN16602@bilbo.ozlabs.org>
In-Reply-To: <20090409215207.GN16602@bilbo.ozlabs.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alex Chiang <achiang@hp.com>, Robin Holt <holt@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org


--HoGc7FifFwma1EOu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-04-10 07:52:07 +1000, Tony Breeds <tony@bakeyournoodle.com> wr=
ote:
> On Wed, Apr 08, 2009 at 05:44:43PM -0700, Andrew Morton wrote:
>=20
> > Please do.
>=20
> linux-next is built on powerpc so I needed to rebuild many of the compile=
rs for
> intel.

I've started a build-bot like script for binutils + GCC from CVS/GIT.
If it builds through, I'll start uploading i686 hosted compilers
later on today.

MfG, JBG

--=20
      Jan-Benedict Glaw      jbglaw@lug-owl.de              +49-172-7608481
Signature of:                   ...und wenn Du denkst, es geht nicht mehr,
the second  :                          kommt irgendwo ein Lichtlein her.

--HoGc7FifFwma1EOu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkneiSYACgkQHb1edYOZ4bswUgCfQlTr6onpcA6ggwT0MTQZiY2J
Ke8AnR0ncRP8sQj1/DK9NaoD56Hu9lHM
=bb10
-----END PGP SIGNATURE-----

--HoGc7FifFwma1EOu--
