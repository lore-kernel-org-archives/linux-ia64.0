From: Martin Pool <mbp@samba.org>
Date: Thu, 25 Sep 2003 02:23:11 +0000
Subject: Re: Unaligned access question
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2Z2K0IlrPCVsbNpk"
Message-Id: <marc-linux-ia64-106445674530947@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106445366428887@msgid-missing>
In-Reply-To: <marc-linux-ia64-106445366428887@msgid-missing>
To: linux-ia64@vger.kernel.org


--2Z2K0IlrPCVsbNpk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 25 Sep 2003, Ian Wienand <ianw@gelato.unsw.edu.au> wrote:
> Hi,
>=20
> This isn't directly related to kernel development, but I am a bit
> stumped as to why my test program below causes an unaligned access
> when 'i' is 7 (that is, when it tries to access across a 64 bit
> boundary of 'array').  It's counter intuitive to me, I would have
> expected it either fault on all loads (for every value of 'i') or to
> have not faulted at all.

I think adding

  __attribute__ ((aligned (1)))=20

will make it read the structure in a way that can handle less-aligned
addresses.  (Or maybe 2-byte aligned.)  By default gcc assumes strong
alignment so that it can use faster operations (ld8 or something I
suppose).

As Peter said unaligned access will not necessarily trap.

--=20
Martin=20

--2Z2K0IlrPCVsbNpk
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQE/clGJPGPKP6Cz6IsRAog4AJ998iUv2T2GsG3oKt0gH4JD27xsYACcCT3G
hzSOKyVVQ0LR7pQpGEq6hsg=
=6cYr
-----END PGP SIGNATURE-----

--2Z2K0IlrPCVsbNpk--
