From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 29 Nov 2012 23:34:26 +0000
Subject: Re: getcpu() returns EFAULT when called via the vdso
Message-Id: <201211291834.27817.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart338589118.JjGEEBqMPK"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart338589118.JjGEEBqMPK
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Tuesday 15 May 2012 01:41:11 Mike Frysinger wrote:
> On Tuesday 08 May 2012 17:13:28 Tony Luck wrote:
> > On Mon, May 7, 2012 at 4:53 PM, Mike Frysinger <vapier@gentoo.org> wrot=
e:
> > > i guess that needs to load some p reg with a NULL pointer test and th=
en
> > > do the loads/stores based on that.  calling getcpu(NULL, NULL, NULL)
> > > from userspace shouldn't trigger EFAULT.
> >=20
> > We could do that (see attached, untested, patch). But it wouldn't help
> > the sched_getcpu() code much ... it would stop getting -EFAULT, but
> > it still wouldn't have the right return value.
>=20
> seems to work for me
> Tested-by: Mike Frysinger <vapier@gentoo.org>

was this patch going to get merged at some point ?
=2Dmike

--nextPart338589118.JjGEEBqMPK
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJQt/EDAAoJEEFjO5/oN/WBXd0P/iJbRUt0vWiOL22510mriDVp
ojrXUaAYEhd/CcmxkxbvzkoB7sbuzLwgiN1zrLGM4yHmDwoISxpYAtG7gbYcxH0s
HkfVQRGsiKqdxM9zNKGTbGcLv3xrwWnCGiv7jMlm4NE93F+6ptm76QWF60X+O2iX
tsHM7aTWmuLWl/AgKxcwqVmDWfnIHrAFFPU20+gbMHEMX4dc2yPJwHEUJ/yPE9ED
EMBIYy9ppaTS/fpOYaacqVGxz8vqPSnHpmgQmRFCd5FYcSNi+nbR6T5zGVtKLVJy
eMHMn5p9lY2oVgon37deYTz82eqknxLmlEsl41F2voGvCuq1U4hG+gWs9nYF5UuM
Tye1DB+GVAXhHfuALQNwVUwCfT3wYY3+GEhq7HOQDFZj4MeqMTyFAv7TKZiOR5Qn
a/YlY1OxsBNjKP/yiH6XXsSrI2l/yhLpJ+qd4HjrUywuzhMyDtKHLm5J4rQ2v9OJ
oBOc0+j9CvBof4nvvtbAZcWwcOHzAQ7K/kwUbJlEHcs92vCrr05YmnEC2wH9T7Ss
637E/hPX5tqxlfGUlqdnerTEUgGGVdIKzTcMdxondMAI8UoxoIQAcrFA5KfBjPnZ
mdika0Vt/F2t7Q1FxdE+G4mCjsakkmMuGIaWyuZZ+Q7orv1D0FbNBvyvkC9cdUOe
H/5/Q7iFZZ1xr9FG/RKS
=JBrx
-----END PGP SIGNATURE-----

--nextPart338589118.JjGEEBqMPK--
