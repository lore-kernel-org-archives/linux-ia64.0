From: Martin Hicks <mort@wildopensource.com>
Date: Wed, 02 Jul 2003 12:22:42 +0000
Subject: Re: Early printk is Gone....???
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Zi0sgQQBxRFxMTsj"
Message-Id: <marc-linux-ia64-105714879932186@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105711058824791@msgid-missing>
In-Reply-To: <marc-linux-ia64-105711058824791@msgid-missing>
To: linux-ia64@vger.kernel.org


--Zi0sgQQBxRFxMTsj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable



On Wed, Jul 02, 2003 at 11:43:33AM +1000, Peter Chubb wrote:
>=20
> If I clone David's 2.5 tree (or use Linus's tree, same difference)
> CONFIG_IA64_EARLY_PRINTK is inoperative -- the code to do the work
> just isn't in the tree.

I just looked at the latest linux-ia64-2.5 bitkeeper tree and it appears
to be there.  Note that you cannot use EARLY_PRINTK with a Generic
kernel anymore.

mh

--=20
Wild Open Source Inc.                  mort@wildopensource.com

--Zi0sgQQBxRFxMTsj
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/As6S0ZUZrUx/K+4RAkGkAJ9m9kQpBn8g4KlM2s1r+RA0yFWTpgCg0SQ7
dRCTKVL1FUX7wXqtO3JVEOg=
=4QM1
-----END PGP SIGNATURE-----

--Zi0sgQQBxRFxMTsj--
