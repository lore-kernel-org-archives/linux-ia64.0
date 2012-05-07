From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 07 May 2012 23:53:48 +0000
Subject: Re: getcpu() returns EFAULT when called via the vdso
Message-Id: <201205071953.50114.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1763928.G1DajcIKmv"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart1763928.G1DajcIKmv
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Monday 07 May 2012 13:58:53 Luck, Tony wrote:
> the disassembly of the sched_getcpu() code at runtime looks like:
>    0x2000000000203940 <+0>:     [MMI]       alloc r32=3Dar.pfs,9,1,0
>    0x2000000000203941 <+1>:                 adds r14=3D8,r13
>    0x2000000000203942 <+2>:                 mov r33=3Dr12;;
>    0x2000000000203950 <+16>:    [MMI]       ld8 r14=3D[r14]
>    0x2000000000203951 <+17>:                nop.m 0x0
>    0x2000000000203952 <+18>:                mov r15=3D1304
>    0x2000000000203960 <+32>:    [MII]       mov r35=3Dr0  <<<<<<<<<<<<<<<=
<<<<
>    0x2000000000203961 <+33>:                mov r34=3Dr0;;<<<<<<<<<<<<<<<=
<<<<
>    0x2000000000203962 <+34>:                mov b7=3Dr14;;
>    0x2000000000203970 <+48>:    [MIB]       nop.m 0x0
>    0x2000000000203971 <+49>:                nop.i 0x0
>    0x2000000000203972 <+50>:                br.call.sptk.many b6=3Db7;;
>=20
> When the "br.call" is executed, we flip to the new register
> frame and r34/r35 in the sched_getcpu() frame become r32/r33
> in the new frame.
>=20
> So you get -EFAULT because the VDSO tries to dereference a NULL
> pointer for each of the *cpu and *node arguments.

oh, i think i see.  the funcs implemented via the ia64 vdso are not the nor=
mal=20
kernel funcs.  instead they're hand coded assembly.  in this case, fsys_get=
cpu=20
in arch/ia64/kernel/fsys.S is lacking handling for NULL cpu/node arguments =
and=20
if either is NULL, it incorrectly fails.

EX(.fail_efault, probe.w.fault r32, 3)     // M This takes 5 cycles
EX(.fail_efault, probe.w.fault r33, 3)     // M This takes 5 cycles

i guess that needs to load some p reg with a NULL pointer test and then do =
the=20
loads/stores based on that.  calling getcpu(NULL, NULL, NULL) from userspac=
e=20
shouldn't trigger EFAULT.
=2Dmike

--nextPart1763928.G1DajcIKmv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPqGCOAAoJEEFjO5/oN/WBkjQP/1uRuZ82uytuRX+hDH/1k/NI
3xAoiS+09rgH4p/MLL9UniIXAZNi9jaOFolSs6tqeDj9AcKfejJss/ljFNndHLZk
fGZ60542siC+N2EeSYSDhO+Sxep5g+H2OCzkFshuAykz7YwSZ3gVqXjOZTsflBR7
oQMnFKZvvkXKkm0ZZr3zFtD/GYvVug6E9G9GD8byfIkIYizD4/D4HyaZzt4wZCkv
oE5aZ3vtkZMpcn6uJNgkJkSLw32WRkAAB4L1yXwO7kY7IM2dbgklM1jP/LDTIT6n
tHKwMB/QH7tB9jav6pxhlloBm6qgMBsmJ5O2NZp5IpcXT65Xlgqp4iakpSowobDz
0y07whN2mHc8HVJY9wNqC/VO0IRYOp3DwSCedJhaqj6LWtSIwl94GFODWkj5vgEc
kyMEVObtLvARRHgtlvo+wsZMc2R1VL1Gc6pUYiveVEi8+TxSgNZnDWh5s+mGeqCK
7+1LL53ujP0ELqUwhmeq5JgMzkIdzEXMAFmqgzYME+xSWlAwinN/pk8DIQjKoNri
qzc3pfA1iN1FFsRuH0bR5IDuwmKVJKwAkYO1QX6Ab48381YN5o6xY5u/vjD9w3tO
OtDIChdWa/99HsenbwH0a7kzx/tQz9YEwN1w9lD0+38a1GkZvMs7+ofLOpVJrHhO
bSdxbskPqyH/qRf5chPh
=lo1y
-----END PGP SIGNATURE-----

--nextPart1763928.G1DajcIKmv--
