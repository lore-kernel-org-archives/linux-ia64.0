From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 19 Aug 2004 05:24:36 +0000
Subject: Re: IA64 bitkeeper trees (again)
Message-Id: <20040819052436.GB1831@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="4zI0WCX1RcnW9Hbu"
List-Id: <linux-ia64.vger.kernel.org>
References: <4123D3A2.2050609@intel.com>
In-Reply-To: <4123D3A2.2050609@intel.com>
To: linux-ia64@vger.kernel.org


--4zI0WCX1RcnW9Hbu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 18, 2004 at 10:09:38PM +0000, Tony Luck wrote:
> The actual names all have "linux-ia64-" prepended.  E.g.
>=20
>   http://lia64.bkbits.net/linux-ia64-test-2.6.9
>=20
> The names of the trees all change when Linus makes a release.

I don't know how or if it's even possible, but is there some way to
make a linux-ia64-test-latest symbolic link (or something) that you
can pull from to always have the latest testing tree? =20

The initial reason I wanted this was because we clone the tree to a
local server and then do local clones from that to save bandwidth, and
I'd have to write a script to automatically figure out when the tree
changed over and re-clone it every time.  But I think it would be just
generally handy.

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--4zI0WCX1RcnW9Hbu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBJDmUWDlSU/gp6ecRAtwAAJ44u2FLKT2N8iSxlp9TIq5vNgkeDwCg1mkp
TlBP8KvPmbok6jAeh249TOk=
=Pc9X
-----END PGP SIGNATURE-----

--4zI0WCX1RcnW9Hbu--
