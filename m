From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Wed, 14 Apr 2004 05:29:02 +0000
Subject: Re: Questions on the stack for IA64
Message-Id: <20040414052902.GD13040@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="HG+GLK89HZ1zG0kk"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
In-Reply-To: <20040413051722.84368.qmail@web61202.mail.yahoo.com>
To: linux-ia64@vger.kernel.org


--HG+GLK89HZ1zG0kk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 13, 2004 at 10:05:56PM -0700, Rahul Chaturvedi wrote:
> The register stack has more than enough registers to handle 26
> input's, 26 outputs and 26 local variables, so why would it not put
> all the locals into registers and pass them onto printf?

See

"Itanium Software Conventions and Runtime Architecture Guide"

http://www.intel.com/design/itanium/downloads/24535803.pdf

on page 43, where it says

 "The contents of the first eight parameter slots are always passed in
 registers, while the remaining parameters are always passed on the
 memory stack"

In general, your best references are probably everything on

http://www.intel.com/design/itanium/arch_spec.htm

and=20

http://www.lia64.org/book/

-i
ianw@gelato.unsw.edu.au
http://www.gelato.unsw.edu.au

--HG+GLK89HZ1zG0kk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAfMweWDlSU/gp6ecRAh+nAKDkT9cCaY3in7qJGFy4x4TFz3KfEgCdFWFl
9uUPEBxFTJiGvucljzE69+Q=
=jgbY
-----END PGP SIGNATURE-----

--HG+GLK89HZ1zG0kk--
