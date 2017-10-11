From: Rik van Riel <riel@surriel.com>
Date: Wed, 11 Oct 2017 14:15:04 +0000
Subject: Re: [PATCH v4 2/2] pid: Remove pidhash
Message-Id: <1507731304.21121.185.camel@surriel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-AYGNdimZ+8zX7U9vDWIK"
List-Id: <linux-ia64.vger.kernel.org>
References: <201710111737.ZHqmaPa5%fengguang.wu@intel.com>
In-Reply-To: <201710111737.ZHqmaPa5%fengguang.wu@intel.com>
To: kbuild test robot <lkp@intel.com>, Gargi Sharma <gs051095@gmail.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, julia.lawall@lip6.fr, akpm@linux-foundation.org, mingo@kernel.org, pasha.tatashin@oracle.com, ktkhai@virtuozzo.com, oleg@redhat.com, ebiederm@xmission.com, hch@infradead.org, Tony Luck <tony.luck@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>


--=-AYGNdimZ+8zX7U9vDWIK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-10-11 at 17:47 +0800, kbuild test robot wrote:

> > > '__compiletime_assert_33' declared with attribute error:
> > > BUILD_BUG_ON failed: sizeof(struct upid) !=3D 32
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_compiletime_assert(condition, msg, __compi=
letime_assert_,
> __LINE__)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0^
> =C2=A0=C2=A0=C2=A0include/linux/compiler.h:556:4: note: in definition of =
macro
> '__compiletime_assert'
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0prefix ## suffix();=C2=A0=C2=A0=
=C2=A0=C2=A0\
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~~
> =C2=A0=C2=A0=C2=A0include/linux/compiler.h:576:2: note: in expansion of m=
acro
> '_compiletime_assert'
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0_compiletime_assert(condition, msg, __compi=
letime_assert_,
> __LINE__)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~~~~~~~~~~~~~~~
> =C2=A0=C2=A0=C2=A0include/linux/build_bug.h:46:37: note: in expansion of =
macro
> 'compiletime_assert'
> =C2=A0=C2=A0=C2=A0=C2=A0#define BUILD_BUG_ON_MSG(cond, msg) compiletime_a=
ssert(!(cond),
> msg)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0^~~~~~~~~~~~~~~~~~
> =C2=A0=C2=A0=C2=A0include/linux/build_bug.h:70:2: note: in expansion of m=
acro
> 'BUILD_BUG_ON_MSG'
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUILD_BUG_ON_MSG(condition, "BUILD_BUG_ON f=
ailed: " #condition)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~~~~~~~~~~~~
> > > arch/ia64/kernel/asm-offsets.c:33:2: note: in expansion of macro
> > > 'BUILD_BUG_ON'
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUILD_BUG_ON(sizeof(struct upid) !=3D 32);
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0^~~~~~~~~~~~
>=20
Looks like arch/ia64/kernel/asm-offsets.c throws a BUILD_BUG
if sizeof(struct upid) !=3D 32.

Your patch reduced the size of struct upid, which is a nice
thing, but now IA64 no longer builds.

Lets see what IA64 was doing with the size of struct upid
in the first place:

in arch/ia64/kernel/asm-offsets.c:

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUILD_BUG_ON(sizeof(struct =
upid) !=3D 32);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0DEFINE(IA64_UPID_SHIFT, 5);

Grepping for IA64_UPID_SHIFT leads us to some assembly
code implementing fsys_getpid (why is that in assembly?!):

        add r8=3DIA64_PID_LEVEL_OFFSET,r17
        ;;
        ld4 r8=3D[r8]                             // r8 =3D pid->level
        add r17=3DIA64_PID_UPID_OFFSET,r17        // r17 =3D &pid->numbers[=
0]
        ;;
        shl r8=3Dr8,IA64_UPID_SHIFT
        ;;
        add r17=3Dr17,r8                          // r17 =3D &pid->numbers[=
pid->level]
        ;;
        ld4 r8=3D[r17]                            // r8 =3D pid->numbers[pi=
d->level].nr
        ;;
        mov r17=3D0

Luckily it looks like this is only referencing the first members of struct =
upid,
and you are removing the last member, so I suspect you will be fine changin=
g the IA64
to this:

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0BUILD_BUG_ON(sizeof(struct =
upid) !=3D 16);
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0DEFINE(IA64_UPID_SHIFT, 4);

Tony, does that look ok to you?

--=20
All Rights Reversed.
--=-AYGNdimZ+8zX7U9vDWIK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJZ3idoAAoJEM553pKExN6DhDsH/1zSxXsfqGt8shlFNJWZEx4C
3hufcIL5u16G0XPIYOIj+yj9CMyRDfNLcQIokAVE/dKesRM5lYTOTpzaGtglQ/wI
6a5UHlrjTnziUpE0//87p1bhUZNLPzBGy2SVPAxtm3PDJBoDf+Nx6HD9qQe/+K/W
rVti3M9sJz9o4V7z3s92dJwZAP9toNtziZas81AYUQuXthOrhH9qC0GF98FsrtpM
ua13vkHW2N2Mc63G305DmZY0nqzLuNN6/ijqWdn77qOiV1t4XBUUUTzKcM9CR6ts
cvbNJhLXpq7yPOmdcllw4EzgqB3VhyaJw+ZL2V4UKT3Wgum3/hmIyAfwWaI1Njg=
=FrUo
-----END PGP SIGNATURE-----

--=-AYGNdimZ+8zX7U9vDWIK--

