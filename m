From: Harald Welte <laforge@netfilter.org>
Date: Sat, 10 Jul 2004 07:15:33 +0000
Subject: Re: [netfilter-core] strict rejection of init -> core references causes problems
Message-Id: <20040710071532.GH5173@sunbeam2>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="3607uds81ZQvwCD0"
List-Id: <linux-ia64.vger.kernel.org>
References: <16622.17154.117052.31601@napali.hpl.hp.com>
In-Reply-To: <16622.17154.117052.31601@napali.hpl.hp.com>
To: linux-ia64@vger.kernel.org


--3607uds81ZQvwCD0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jul 09, 2004 at 12:19:46PM -0700, Luck, Tony wrote:
> >So what really happens is: calls from init to 'core' functions=20
> >and calls from 'exit' to core functions.
>=20
> Hmmm.  Neither of those should have tripped the check in the
> kernel module loader.  It should only go bang when you have a
> call from "core" to "init".  Does "exit" end up in a separate
> section?  Maybe I was mistakenly triggering on the exit->core?

Apparently yes:

  0 .text         00003f78  00000000  00000000  00000034  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  1 .init.text    0000029c  00000000  00000000  00003fac  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
  2 .exit.text    00000008  00000000  00000000  00004248  2**2
                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE

But also, we don't call __init from __exit (which would be crash once
__init has been purged from memory). =20

> Which module actually failed to load?

yes, I would be interested in that, too :)

> -Tony

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--3607uds81ZQvwCD0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFA75eUXaXGVTD0i/8RApqyAJ9QgIOEb35ET38bfkmipioj7kmq0gCdFDz1
ZS76s2DbBQxrNoZIncxm9KU=
=jOpD
-----END PGP SIGNATURE-----

--3607uds81ZQvwCD0--
