From: Andreas Jaeger <aj@suse.de>
Date: Tue, 01 Jun 2004 09:48:56 +0000
Subject: Re: lib64 in fedora glibc
Message-Id: <hollj7wquv.fsf@reger.suse.de>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-=-="
List-Id: <linux-ia64.vger.kernel.org>
References: <20040528214105.GK9115@mustard.zk3.dec.com>
In-Reply-To: <20040528214105.GK9115@mustard.zk3.dec.com>
To: linux-ia64@vger.kernel.org

--=-=-=
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable

Grant Grundler <iod00d@hp.com> writes:

> On Fri, May 28, 2004 at 11:33:36PM -0400, Aron Griffis wrote:
>> > So I guess the question is what would make %%{_lib} be defined as lib6=
4.
>>=20
>> Right, that's why I suggested it appears they're preparing for the
>> transition.=20
>
> "the transition" might be necessary to support x86_64.
> Ie most of user space is 32-bit (using /lib) but some apps
> will run substantially better as native x86_64 binaries.

Just a clarification: AMD64 [1] has most of user space 64-bit.  Only a
few applications are 32-bit - but this lib/lib64 is the best way to
handle 32-bit packages (no need to change files).

> Moving to lib32 and lib64 makes sense in that environment.

Not lib32, just lib.

Andreas

Footnotes:=20
[1]  at least the SUSE distribution but I assume others as well.

=2D-=20
 Andreas Jaeger, aj@suse.de, http://www.suse.de/~aj
  SUSE Linux AG, Maxfeldstr. 5, 90409 N=FCrnberg, Germany
   GPG fingerprint =3D 93A3 365E CE47 B889 DF7F  FED1 389A 563C C272 A126

--=-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAvFEIOJpWPMJyoSYRAqHJAJwL9NBPnyFa4CpmA9XQhWnVo2h5ngCglgcd
z5eFAqhxqeuEhupWLC+Yfcg=
=cZ4x
-----END PGP SIGNATURE-----
--=-=-=--
