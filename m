From: "Zephaniah E. Hull" <warp@whitestar.soark.net>
Date: Tue, 15 Aug 2000 22:12:57 +0000
Subject: [Linux-ia64] Re: [Glide-patches] Glide patches for IA-64
MIME-Version: 1
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Message-Id: <marc-linux-ia64-105590678205328@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Note, I'm just the Debian Glide guy, not someone from 3Dfx.

On Tue, Aug 15, 2000 at 12:22:24AM -0700, David Mosberger wrote:
> As promised, here is the patch necessary to make Glide_V3 work on
> IA-64 Linux.  I tested this with an AGP Vodoo 3 1000, though it should
> work with other cards, too.=20

> The patch is relative to Glide_V3-DRI-3.10-6.src.rpm available from
> 3dfx (sorry, I didn't bother checking out the CVS tree at
> sourceforge).

Ick, any chance of getting it against the CVS tree? A lot has changed..
<snip>
> In the patch, getting rid of some of the compiler warnings may seem
> pedantic, but I think it would have been a LOT harder to find some of
> the bad casts if the other warnings had been left unfixed.  I'd
> strongly recommend to merge in those changes.  A clean build with gcc
> -O -Wall" goes a long way towards 64-bit cleanliness.

I have patches for glide2 and swlibs to make it all compile with -Wall
-Werror, working on getting them into the CVS tree, probably going to be
starting on glide3 soon..
>=20
> On the DRI front: note that you'll still need a 64-bit cleanup patch
> (and IA-64) support for the X server before DRM/DRI works on IA-64.  I
> plan to send that patch sometime tomorrow or on Wednesday.
>=20
> Enjoy,
>=20
> 	--david
>=20
> PS: If you're interested in seeing the IA-64 Linux Voodoo in action,
>     visit the HP booth at Linux World Expo in San Jose this week. ;-)

Wish I could be there..

Zephaniah E. Hull.

--=20
 PGP EA5198D1-Zephaniah E. Hull <warp@whitestar.soark.net>-GPG E65A7801
    Keys available at http://whitestar.soark.net/~warp/public_keys.
           CCs of replies from mailing lists are encouraged.

"And now, little kittens, we're going to run across red-hot
motherboards, with our bare feet." -- Buzh.

--CE+1k2dSO48ffgeK
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.2 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE5mcBpRFMAi+ZaeAERAtiyAJ9m3Gv+TSYo9VSc2rwSvKwHS60vFgCdHcv5
NPxf+uhj9COSOvleNObERzs=
=4KjL
-----END PGP SIGNATURE-----

--CE+1k2dSO48ffgeK--

