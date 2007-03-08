From: Bernhard Walle <bwalle@suse.de>
Date: Thu, 08 Mar 2007 09:33:55 +0000
Subject: Re: [Fastboot] [PATCH] saved_max_pfn too small on a specific machine
Message-Id: <20070308093355.GC5158@strauss.suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="iFRdW5/EC4oqxDHL"
List-Id: <linux-ia64.vger.kernel.org>
References: <20070307082429.GA29770@verge.net.au>
In-Reply-To: <20070307082429.GA29770@verge.net.au>
To: linux-ia64@vger.kernel.org


--iFRdW5/EC4oqxDHL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

* Horms <horms@verge.net.au> [2007-03-08 01:35]:
> On Wed, Mar 07, 2007 at 10:47:43AM +0100, Bernhard Walle wrote:
> > * Horms <horms@verge.net.au> [2007-03-07 09:24]:
> > > As only md is used to calculate saved_max_pfn it seems reasonable
> > > to move setting saved_max_pfn to imediately after md is validated.
> > > This shouldn't change the logic at all. And it seems to make what is=
=20
> > > going on a little clearer.
> > >=20
> > > As suggested to me by Magnus Damm
> > >=20
> > > Cc: Magnus Damm <magnus.damm@gmail.com>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> >=20
> > (as the original patch was from me)
> > Acked-by: Bernhard Walle <bwalle@suse.de>
>=20
> Thanks.
>=20
> Feel free to roll this change into your patch if you like.

Not necessary since Tony already picked the patch:
http://git.kernel.org/?p=3Dlinux/kernel/git/aegl/linux-2.6.git;a=3Dcommitdi=
ff;h=3De55fdf11f3029bcd41b1b9547ad9db12c27eea76


Regards,
Bernhard

--iFRdW5/EC4oqxDHL
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFF79iDiGU2lt2vZFQRAv0PAJ9n+RCSuKzFMsGABYEKGJs4pQTGpgCeLBdX
WJRtieDEUHWhRbiMnh24Sdg=
=G/Rh
-----END PGP SIGNATURE-----

--iFRdW5/EC4oqxDHL--
