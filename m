From: Axel Thimm <Axel.Thimm@ATrpms.net>
Date: Wed, 05 Apr 2006 16:35:21 +0000
Subject: Re: : IA64 ISOs based on Fedora Core 5
Message-Id: <20060405163521.GS30438@neu.nirvana>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="ctZH5Gqgrl5HoVnD"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--ctZH5Gqgrl5HoVnD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 05, 2006 at 10:44:45AM +0100, David Woodhouse wrote:
> On Tue, 2006-04-04 at 22:25 -0400, Paul Nasrat wrote:
> > I assume for the weekly snapshots of rawhide that you'll be putting
> > unique (eg date based) names on the isos so they can be readily
> > identified, else you're going to run into trouble tracking issues
> > across media sets.=20
>=20
> To be honest, I'm not convinced that weekly ISO builds are particularly
> useful -- we don't do that for rawhide on other architectures either.
> It's probably better just to encourage people to use rsync to keep up
> with rawhide, rather than downloading it all over again each week.
>=20
> >  Do these isos correspond with FC5 or a random snapshot?
>=20
> Rawhide for about a week leading up to March 20th was identical to FC5
> in all but the 'fedora-release' package.=20
>=20
> If making an IA64 'FC5' I'd be inclined to replace the fedora-release
> package too. In fact, you almost certainly want to do that anyway, since
> you'll be publishing the errata, and fedora-release contains the yum
> configuration.

That might be helpful:

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D187250

> Aside from the updates, the next task is building Extras and Livna for
> IA64, of course...

and who's going to do ATrpms? ;)
--=20
Axel.Thimm at ATrpms.net

--ctZH5Gqgrl5HoVnD
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2.2 (GNU/Linux)

iD8DBQFEM/HJQBVS1GOamfERAhmqAJ4sDIcAHvOMR7XFVBqPaYDk8d+e3gCeIDAT
ctPqfuCXSTKADZGFnAMYB3s=
=aKNc
-----END PGP SIGNATURE-----

--ctZH5Gqgrl5HoVnD--
