From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 10 Oct 2010 21:00:12 +0000
Subject: Re: [RFC][PATCH] [ia64] Raise minimum binutils version and remove
Message-Id: <1286744412.2955.239.camel@localhost>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-V8vZDyT7Yu9s+ctv3kWU"
List-Id: <linux-ia64.vger.kernel.org>
References: <1286158823.3916.227.camel@localhost>
In-Reply-To: <1286158823.3916.227.camel@localhost>
To: linux-ia64@vger.kernel.org


--=-V8vZDyT7Yu9s+ctv3kWU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2010-10-04 at 11:52 -0700, Tony Luck wrote:
> On Sun, Oct 3, 2010 at 7:20 PM, Ben Hutchings <ben@decadent.org.uk> wrote=
:
> > diff --git a/Documentation/Changes b/Documentation/Changes
> > index 4fb88f1..23fc499 100644
> > --- a/Documentation/Changes
> > +++ b/Documentation/Changes
> > @@ -30,7 +30,7 @@ isdn4k-utils.
> >
> >  o  Gnu C                  3.2                     # gcc --version
> >  o  Gnu make               3.80                    # make --version
> > -o  binutils               2.12                    # ld -v
> > +o  binutils               2.12 (2.16 for ia64)    # ld -v
> >  o  util-linux             2.10o                   # fdformat --version
> >  o  module-init-tools      0.9.10                  # depmod -V
> >  o  e2fsprogs              1.41.4                  # e2fsck -V
>=20
> Won't this file become a complete mess if each architecture starts
> specifying its own version for each of the tools?
[...]

Maybe, though the only things likely to need per-architecture fixes or
features are gcc and binutils.

By the way, I did a little more research and found that the bug
unwcheck.py is checking for was in binutils 2.16, so the minimum would
actually have to be 2.17 (or a distro-fixed 2.16).

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-V8vZDyT7Yu9s+ctv3kWU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATLIpS+e/yOyVhhEJAQLuZhAAkDFi+gtQCF9+r1c4V1+w0JbyH+OC0ZxT
K42HJEyonY+jZnnA8fXqcUI7yqnpz1Nb8GvWsLp2Bm3BhWow86dxEuLni9Fm7wV0
F6rbi00z2CdEPtaeuLvvEbWEn6R7tWwiks1vsxcwMfG1wGw5baKUiJUo2q5EtKWk
4gi//g8qmAkOvTH7lHCes2jUl6+OHaK5Co3o2eImVwFIkYmALIVZBiXhRO9PcrLi
t665eT65cZXI+rCc2zT+217eetx70UcW2LIxWhem+qvBrlijupcq5xogejMEghHX
N4OgXGN7YOO115dYbrM74xbCd/eoI1273KynJjKI0+EL/GNQd+GXq+eSAsGS5HeY
kOIFQWNnw8FNZCmCoKcoTUiuYBtvxpCYGdpua7C+TjBM1DYDeExI8/MMvJhgKgdW
hBlFzVBsAgor6/tJ4ThNYHQHPC9DvbAhPuKi+n+Gbom+wZaqjaWN7CyW6I3soOdk
ZW6i2TvLe+L7BpFqjc2I/KD2/8Hin0Aoa6Xi5uwFFy1moYr0nDROsdiic0p1+8pm
I/Wrw5PUF/nExbsH6fqicFYCPwGdAgls1dawJbXX5zGiaO+PnMOHHsB6iL/irP9s
3zYz/ZI/+MpZ4wZSBGim4g6ecvX33Wh++SSXROBI+NhK8oYcAgMvP9apCh1DxHnt
ZeFBxNxKecI=
=weNj
-----END PGP SIGNATURE-----

--=-V8vZDyT7Yu9s+ctv3kWU--
