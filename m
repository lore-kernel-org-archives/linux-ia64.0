From: Mike Frysinger <vapier@gentoo.org>
Date: Tue, 08 May 2012 22:31:59 +0000
Subject: Re: getcpu() returns EFAULT when called via the vdso
Message-Id: <201205081832.01092.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1406265.jBrRuf9GU5"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart1406265.jBrRuf9GU5
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 08 May 2012 17:13:28 Tony Luck wrote:
> On Mon, May 7, 2012 at 4:53 PM, Mike Frysinger wrote:
> > i guess that needs to load some p reg with a NULL pointer test and then
> > do the loads/stores based on that.  calling getcpu(NULL, NULL, NULL)
> > from userspace shouldn't trigger EFAULT.
>=20
> We could do that (see attached, untested, patch). But it wouldn't help
> the sched_getcpu() code much ... it would stop getting -EFAULT, but
> it still wouldn't have the right return value.

wouldn't it though ?  the return value with getcpu is just "0" when things=
=20
worked.  if i do:
	int i;
	syscall(__NR_getcpu, &i, NULL, NULL);
this should return 0 and fill in "i" with the cpu value.  i think your prop=
osed=20
patch would make things work as no fault would be triggered, and the return=
=20
value (r8) would be set to 0.

i'll have to rebuild the kernel to double check though.
=2Dmike

--nextPart1406265.jBrRuf9GU5
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPqZ7gAAoJEEFjO5/oN/WB35MP/0UiWJr/SRYy+jrBtGgC15ly
azMWswu0WKVCHiv5cpIV1b8wPaUbsVMDcQwJ06ow8lTdi9TWEKiV7svPacGrIPle
LA5IdvSWzFxryh3U2tGL3aEJ8xvvvszIXJTUtkXCwnQZ+woYGvAQQaJPE+YtTaic
n2iXQlVYar239+7hqS2R86/Wjj3PfCbWf3lClMQL2Q5hwior0Ta6eLKBof6wGdHQ
gZLuifFOrsj6PLO8GkyvfnfU5L/5Cxnz/R2nDQNugZ+3ND4HrkdVGpK4HFvdAHqY
QhZwC5qRKcSauqXJIV6Dla+i6e6CSUlCNCJ0xGtVlZAUf9AzUkXo1cn3Xf1x+hAL
0hUFtIhsTgj5JTiuPVda7/INlS1WmsYvNp6WCTA3lVbRpzGR14U0ZKRn/sn+P8ic
YttpXBLj3z7FhpSucz0YdDxTMHb5TpbS06yLglV5JjiqNVDm+tvQnSZo4ZSe+wj+
y0c1SSWmuvzLSYoIOf8/b8PRdpqiYLz4xqLhSXYq/mIGQAepzd4JaKB16N+vR+8y
hITpN+9mkvh6FdBp0GTHxHAjh99HM70acsuhX9kmLOEgx+sQjRQny2dOGVxpw85g
hyhDJpz7iTFLmU/5ZKvFflNR78Ye7+RQDgTRCP9pNyAG/6M9AmYFDLfOj9radPD6
ulkJk6Yl12AQgSE8+uax
=JFa+
-----END PGP SIGNATURE-----

--nextPart1406265.jBrRuf9GU5--
