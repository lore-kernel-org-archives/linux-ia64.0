From: Martin Hicks <mort@wildopensource.com>
Date: Fri, 23 May 2003 19:00:21 +0000
Subject: Re: [Linux-ia64] [PATCH] 2.5 - Change mmu_gathers into per-cpu data
MIME-Version: 1
Content-Type: multipart/mixed; boundary="KlAEzMkarCnErv5Q"
Message-Id: <marc-linux-ia64-105590723706011@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706004@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706004@msgid-missing>
To: linux-ia64@vger.kernel.org

--KlAEzMkarCnErv5Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


On Fri, May 23, 2003 at 07:39:25PM +0100, Christoph Hellwig wrote:
> On Fri, May 23, 2003 at 01:52:46PM -0400, Martin Hicks wrote:
> >=20
> > Hello,
> >=20
> > Here is a patch to move the mmu_gathers struct into the per-cpu data
> > region.
> >=20
> > The patch is against the linux-ia64-2.5 tree.
>=20
> Could you also submit such a patch for asm-generic/tlb.h and the other ar=
ches?

Yes.  I was going to whip that up and post it to linux-kernel sometime
soon.

mh

--=20
Wild Open Source Inc.                  mort@wildopensource.com

--KlAEzMkarCnErv5Q
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE+zm/F0ZUZrUx/K+4RAswlAKC2GDpQkm9L3NGdauTeax/ttI7kZQCeLO9P
syP7UoFS/UNo08dXAqOgDnU=
=harX
-----END PGP SIGNATURE-----

--KlAEzMkarCnErv5Q--

