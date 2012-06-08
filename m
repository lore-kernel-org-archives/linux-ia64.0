From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 08 Jun 2012 02:09:50 +0000
Subject: Re: [PATCH] IA64: Export <asm/cmpxchg.h> to userland
Message-Id: <1339121390.21665.98.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-HrfK5sSEM81Idtni22K0"
List-Id: <linux-ia64.vger.kernel.org>
References: <1339041112.21665.77.camel@deadeye.wl.decadent.org.uk>
In-Reply-To: <1339041112.21665.77.camel@deadeye.wl.decadent.org.uk>
To: linux-ia64@vger.kernel.org


--=-HrfK5sSEM81Idtni22K0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2012-06-08 at 10:43 +0900, Greg Kroah-Hartman wrote:
> On Thu, Jun 07, 2012 at 09:07:13PM +0100, Ben Hutchings wrote:
> > On Thu, Jun 07, 2012 at 04:54:56PM +0000, Luck, Tony wrote:
> > > > Parts of <asm/intrinsics.h> were moved to <asm/cmpxchg.h>, and the
> > > > former now includes the latter.  The former is exported to userland
> > > > so the latter must be too.
> > >=20
> > > Already received and applied a patch that does this (though it added
> > > the cmpxchg.h a few lines earlier that you did).
> > >=20
> > > See commit: 98e4cff73
> > >=20
> > > It didn't get marked for stable though ... so if you need this to
> > > get pulled into the stable branches you'll need to poke Greg etc.
> > > manually.
> >=20
> > Greg, please cherry-pick commit
> > 85f8f7759e418c814ee2ceacf73eddb9bed39492 ('[IA64] Add cmpxchg.h to
> > exported userspace headers') for 3.4.y.
>=20
> I tried, but it doesn't apply properly.  Can someone backport it and
> send it to me?

Sorry, I mean 98e4cff73a18af27f0d40d0b0d37f105dfc1994a; the former
commit is already in 3.4 and resulted in this breakage.

Ben.

--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.

--=-HrfK5sSEM81Idtni22K0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAT9Fe7ue/yOyVhhEJAQrroQ/7Btyg2mbCnK0fDDGhhkJHpTSTpi9f60Ze
ldNJpZyMFzxYrS9AQZUnB40Nfqyv96Eb07C7usbHYcE8Mg+wNdGjxBZs2lGPWYCq
uEFkdM7KAz5FxyxGdu3RUsCSlNRYCs4nHpZJrHxAf96MIcH7IzlhENZWYdNiQUXw
OUt1oRv0Ek+u4EJuaUTpEmhh0/ple6zMiaoQN3Rw5X6eL7dSJA+yNtSxzzXg6FAH
xoaI4vsGJKzekZz+5NiXRo3vE5wCGYOEu8ndkz5dwGeaLxtwUqu9GISIQRSWlnUr
ubSps/OQ3rOXkqFYHh6pwJLpJ5mkk89w62kOeyPtKtvf/BsUvBxG+tmmtph5fD7d
uoLVKMzQCrwnYS2HuRdYq1am9B7L4PK8ySOHEhl6lR4ARuRlJWo/QHVO69tp9no4
njB8KkFFYRpkD8ck8u+sHADK2bCU5aFQSRD2xfcfd4y6NACeaEcWETCSsdza2Q8k
hE0+S0ebJ4Wb7fKlVxhsrAYAv/vYiL+dnMx3xki6szYp8QpUUZS/gHZpldjmLoPW
xsDflk4S29hiPWA323GemR1/TKle04/mVrOH9tBrMNpFGssFjlEW4t/Ry8Gej3Cp
ytym9XmsxoC5RfY3SE1OTzwJu41J8nPdN8MnOY3YrPsfIckwace5bVyyqzCtUiTt
plUdnjU6S1A=
=2oQW
-----END PGP SIGNATURE-----

--=-HrfK5sSEM81Idtni22K0--
