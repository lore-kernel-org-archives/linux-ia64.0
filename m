From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Tue, 31 Aug 2004 05:53:32 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <20040831055332.GG2897@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="zS7rBR6csb6tI2e1"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
To: linux-ia64@vger.kernel.org


--zS7rBR6csb6tI2e1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Aug 26, 2004 at 01:19:49PM -0700, Christoph Lameter wrote:
> One issue that bothers me is that it is no longer possible to swap pte,
> pmd and pgd entries via cmpxchg. My page fault scalability patches are ba=
sed
> on that ability. The Itanium can only do a cmpxchg with a 64 bit value.
> The long VHPT entries are 32 bytes long.

As others have said, for the initial patch this shouldn't be an issue
(we have started making sure that the lvhpt patches will apply ontop
of your patches too).

However, in the longer term the length a pte is.  To do anything
interesting with the long format vhpt we are going to need more bits
in a PTE for things like protection keys and page sizes.  We have some
preliminary patches at

http://www.gelato.unsw.edu.au/cgi-bin/viewcvs.cgi/cvs/kernel/pteextension/

which do this, and we are building ontop of this approach.  The
essence of the change is=20

-typedef struct { unsigned long pte; } pte_t;
+typedef struct { unsigned long pte; unsigned long itir; } pte_t;

I would like to know from the experienced hackers what the chances of
getting a change like this in are, or if anyone has any other ideas.

-i

--zS7rBR6csb6tI2e1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBNBJcWDlSU/gp6ecRAj/ZAJwPg215+mijBrTJEyQxBjFWdeFKBACfSqGY
9u5oy/NQklz0b5hOMY+JbuI=
=Ailh
-----END PGP SIGNATURE-----

--zS7rBR6csb6tI2e1--
