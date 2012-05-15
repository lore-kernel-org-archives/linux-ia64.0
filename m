From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 15 May 2012 05:41:11 +0000
Subject: Re: getcpu() returns EFAULT when called via the vdso
Message-Id: <201205150141.12655.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart2914234.N9p8QcNVCb"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart2914234.N9p8QcNVCb
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 08 May 2012 17:13:28 Tony Luck wrote:
> On Mon, May 7, 2012 at 4:53 PM, Mike Frysinger <vapier@gentoo.org> wrote:
> > i guess that needs to load some p reg with a NULL pointer test and then
> > do the loads/stores based on that.  calling getcpu(NULL, NULL, NULL)
> > from userspace shouldn't trigger EFAULT.
>=20
> We could do that (see attached, untested, patch). But it wouldn't help
> the sched_getcpu() code much ... it would stop getting -EFAULT, but
> it still wouldn't have the right return value.

seems to work for me
Tested-by: Mike Frysinger <vapier@gentoo.org>

also, strace shows the successful syscall via the vdso, but not the failing=
=20
ones.  not sure where things are going wrong with that though.
=2Dmike

--nextPart2914234.N9p8QcNVCb
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPsex4AAoJEEFjO5/oN/WBD9wQANvFfAXaSr54wJHPMDKEVrWi
Z6u5BObZP5UoA9tpTRbRLHaaRtGXS7QUzib9t4CfSE1qEOwnGN7bq4go/YFP3JFa
5Zv/rxz0KsY23aRSc8ly6CI9gDVeaZIFMHu5+a5Bns9xTLvA8fe+dbbyhgK7/MqB
VA2RLyGbUWfplhpmRcoDgel9G2RAZtyh3IcqxAU6iamzrI8u/NADarIBj1AtKw40
/24pG2jYHHjEuyirIOSe1WFdHVa7Om4u+ycX107/0LvvCx7UMancniyckdz2DGiz
nAcqoPVhjBsdReks3/HR47AGtQnBkaIJBkUY3oealKW+1F/8Gfc1Gk9547MXReBF
9MwENkzvc0S8XEOdOZOPT9RXn6bg6cwbaknm6KQjf9ZlLPH+sguhk90+0lMAeA1F
N7ahfHenERfrN6P/frQsI4j5zoXZkWJczT1NlbVGJmHQGs6tBO86bRK0Tl8jO+h9
i6ty5OFeUi1qNWpO5Lg2nbwyhBQ2YDuNGp2I1xi4wlat9dwAkbiXfmI1LAjWxGnv
l+0EQxnoHPPxX/0DxY1tGnO3N+Q/ZWFVkwC+KPuS3l64zv8NECtfVemdtinKlFo7
kAkFMzzWc+A1JHRb22/j4gLFBsKzuhLmoE2dq8vnZA8eAdPTfDPBEYOAHrpcPfA9
iCC8TCCAUJsyrdshSE1q
=A+Hw
-----END PGP SIGNATURE-----

--nextPart2914234.N9p8QcNVCb--
