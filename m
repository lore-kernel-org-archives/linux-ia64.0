From: Ben Hutchings <ben@decadent.org.uk>
Date: Wed, 16 May 2012 22:29:00 +0000
Subject: Re: [PATCH 3.0.y, 3.2.y] ia64: Add accept4() syscall
Message-Id: <1337207340.4107.55.camel@deadeye>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-MGKbH9bC/8ev0CxP2Dmp"
List-Id: <linux-ia64.vger.kernel.org>
References: <20120516215700.GA10476@burratino>
In-Reply-To: <20120516215700.GA10476@burratino>
To: linux-ia64@vger.kernel.org


--=-MGKbH9bC/8ev0CxP2Dmp
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-05-16 at 16:57 -0500, Jonathan Nieder wrote:
> From: =C3=89meric Maschino <emeric.maschino@gmail.com>
>=20
> commit 65cc21b4523e94d5640542a818748cd3be8cd6b4 upstream.
>=20
> While debugging udev > 170 failure on Debian Wheezy
> (http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D648325), it appears
> that the issue was in fact due to missing accept4() in ia64.
>=20
> This patch simply adds accept4() to ia64.
[...]

Queued up for 3.2.y.

Ben.

--=20
Ben Hutchings
The two most common things in the universe are hydrogen and stupidity.

--=-MGKbH9bC/8ev0CxP2Dmp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT7QqLOe/yOyVhhEJAQqzRA/8Dxxe4ZAqhYvmiCukflIEsM51JBlCmu+7
bC8jMylUu162MdycUE/oHrJcyw6lPUdrCrXTTKasfUuOK9A+jImV2Q2P1p8gQaJq
Spkd/U96nbg09brbW4Uvzjw17k+jVq17W/efywN5r31G2DrC8WsbkVkb8jyUWya4
AA+X7oevfN311LMwFoB3aBDwcJ6u5IPILHIdDUZopArhMpw2ymY9LDY1ovN+TIrS
Uawtr4XV+4JQ1zddKRR/k257Kot1C/U/5sSPdcHU/E3SyzwIDtdjmlWL19ge9UHl
WMBrz8BwbeL4uBfC0Mf8DVu5HESlwVagOr10nwhGnlkdUVHQZ2ZJrJruXumqoqVh
tfFjiKHTzj3q+cBRS/gFhHVb+lM8w6FZtzdKG5hs9qg2vpHcChQ15XVZKOePz80b
YQc5q+xMfHufG2UnW2PvDSioQPUe5uTtlZ4NGp16ssqNSrwCBvHevWysBe6yEw2E
oBoI8o+dWZD3mW/TGgNi4R4n9BVXu79wPPkQIZqNba5KYppK01T48+oR5zhLPG1l
PCM5mI1M1QE9rx3TjU81GoqML6kCXhi4Vu5Ml4tfubTmhGq/gzANPi3F9p3urtwZ
1gqhrCdUjKpmGKOZq0bM7adOjUXAuufeMsZ9gxwVttaV8vJstdT9H3BHgJKCbS0k
DSKpRiRc9Ew=
=T06C
-----END PGP SIGNATURE-----

--=-MGKbH9bC/8ev0CxP2Dmp--
