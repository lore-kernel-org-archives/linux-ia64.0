From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 27 Aug 2008 23:21:20 +0000
Subject: Re: [PATCH 01/59] CRED: Wrap task credential accesses in the IA64
Message-Id: <20080828092120.b9b198bb.sfr@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Signature=_Thu__28_Aug_2008_09_21_20_+1000_X_XPTG5ZPJHlSZRb"
List-Id: <linux-ia64.vger.kernel.org>
References: <48B56ADA.8010808@yandex.ru>
	<20080827134541.19980.61042.stgit@warthog.procyon.org.uk>
	<20080827134547.19980.38813.stgit@warthog.procyon.org.uk>
	<25475.1219850678@redhat.com>
In-Reply-To: <25475.1219850678@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: Artem Bityutskiy <dedekind@yandex.ru>, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

--Signature=_Thu__28_Aug_2008_09_21_20_+1000_X_XPTG5ZPJHlSZRb
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi David, Artem,

On Wed, 27 Aug 2008 16:24:38 +0100 David Howells <dhowells@redhat.com> wrot=
e:
>
> Artem Bityutskiy <dedekind@yandex.ru> wrote:
>=20
> > Fine with me.
>=20
> Can I count that as an Acked-by?
>=20
> > Do you want us to put this patch to ubifs-2.6.git or you
> > prefer to make it go together with the rest of the CRED patches?
>=20
> Ummm...  I'll check.  I'm not sure exactly how Stephen wanted to play thi=
s.

I am happy for these patches to go into both the subsystem and creds
trees (the mess - if any - will be on my head).  I do expect this to
reduce conflicts in the longer term.

It is much better for that to happen than for a subsystem maintainer to
apply a slightly different fixup when I find a conflict.  If there is not
conflict between the subsystem tree and the creds tree, then it doesn't
matter if the patch is in both trees or not.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__28_Aug_2008_09_21_20_+1000_X_XPTG5ZPJHlSZRb
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAki14XAACgkQjjKRsyhoI8zPDwCfZJgXfWVihB1ZyDKMmnzfmyQi
JzAAoJjY/iI3TWx9UAkKoRzvU4NVrSpX
=2qhH
-----END PGP SIGNATURE-----

--Signature=_Thu__28_Aug_2008_09_21_20_+1000_X_XPTG5ZPJHlSZRb--
