From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 25 Aug 2004 06:28:35 +0000
Subject: Re: IA64 bitkeeper trees (again)
Message-Id: <20040825062835.GA6900@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="mYCpIKhGyMATD0i+"
List-Id: <linux-ia64.vger.kernel.org>
References: <4123D3A2.2050609@intel.com>
In-Reply-To: <4123D3A2.2050609@intel.com>
To: linux-ia64@vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 23, 2004 at 10:45:23AM -0700, Luck, Tony wrote:
> So what would you like the names of the symlinks to be?  I'm thinking
> of:
>=20
>    linux-ia64-release-2.6.8.1 -> release-2.6
>    linux-ia64-test-2.6.8.1    -> test-2.6
>    linux-ia64-release-2.6.9   -> release-2.6.next
>    linux-ia64-test-2.6.9      -> test-2.6.next
>=20
> but I'd be happy to entertain better suggstions.

Just an idea (and I may have misunderstood the process); why not name
the trees for the people they are going to, for example

test-2.6         -> linux-ia64-tony (the main IA64 development area)
test-2.6.next    -> linux-ia64-to-mm (patches waiting to go to -mm series)
release-2.6.next -> linux-ia64-to-linus (patches waiting to go to official =
kernel)

I'm still not sure where the other release tree fits in all of this
though.=20

Under this my thinking was a developer sends (non-trivial) patch that
first goes into -tony where it makes the core ia64 developers happy,
gets moved into -mm where it is picked up and used by a wider
audience, eventually it gets put into -linus where it is moved into
the main kernel.  Smaller patches, like a compile fix or whatever, go
straight from -tony to -linus?

-i

--mYCpIKhGyMATD0i+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBLDGTWDlSU/gp6ecRAoRhAJ909RaZaYpgIiGXH74BGFDgI23nrgCg3JTT
zzrLiDQHL+Bg2fNhSb1f1eg=
=UsJ6
-----END PGP SIGNATURE-----

--mYCpIKhGyMATD0i+--
