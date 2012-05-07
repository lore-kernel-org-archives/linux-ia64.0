From: Mike Frysinger <vapier@gentoo.org>
Date: Mon, 07 May 2012 23:12:29 +0000
Subject: Re: getcpu() returns EFAULT when called via the vdso
Message-Id: <201205071912.30351.vapier@gentoo.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="nextPart1511845.acmmLYfxhp"
List-Id: <linux-ia64.vger.kernel.org>
References: <201205061645.24398.vapier@gentoo.org>
In-Reply-To: <201205061645.24398.vapier@gentoo.org>
To: linux-ia64@vger.kernel.org

--nextPart1511845.acmmLYfxhp
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

i think only one register is rotated because we called alloc with locals=3D=
1. =20
stepping through with gdb shows that -- on the first insn in=20
__kernel_syscall_via_epc, r32 is now the local variable on the stack, r33 a=
nd=20
r34 are 0.

> So you get -EFAULT because the VDSO tries to dereference a NULL
> pointer for each of the *cpu and *node arguments.

the kernel doesn't care if cpu/node are NULL:
SYSCALL_DEFINE3(getcpu, unsigned __user *, cpup, unsigned __user *, nodep,
        struct getcpu_cache __user *, unused)
{
    int err =3D 0;
    int cpu =3D raw_smp_processor_id();
    if (cpup)
        err |=3D put_user(cpu, cpup);
    if (nodep)
        err |=3D put_user(cpu_to_node(cpu), nodep);
    return err ? -EFAULT : 0;
}
=2Dmike

--nextPart1511845.acmmLYfxhp
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPqFbeAAoJEEFjO5/oN/WBX44P/0HpsKP/ebso0OHqCZRucrR1
YO7ITtpM8mqGbafXmlRacWeT3ujod+yRytO0yu0PafMIEEd1b7YskZcByK8ZYReT
/Gx3m1p9WPdRiB4MtNYJ/yorHy6jYsene99ebGC7nesZnOiG/zU5/k45b9nHSt6K
ULgY6JSigr9DDWswAk83F7znuLJlkoGzaL446KQP+E8rsgzjZZmVBsd6VBKzgXI5
E6cjQDFr60mrMBVr3RUpG06bqNqpt1I6Nb+88TbIDi6dYPVDMvbL0o48GcD5tRH+
sgjFkBEbfYxz8B6HVB23QkZQbK6BowcDzcLFBVbhBDU6mqI6gehlSBFjK4inAIH1
5fVUNMwzW6T4hCR9MAWDTrR8zFyZoOVZazQtM5iVCoNjv6VoI5sj5PcMVOhcmoQn
4f8TecvAPP3S9bI6EqqOYbB+79H7W0C2bGI55XBO19yAHQFNFpGdNi7W+Ki2rYHC
P5/4BtY+q72Im0KVZ2rgEwZXoUmGACBsCuIe3RV63di4vgzJSI4omvZKcwieaEJv
MqUIAKepYyAxp0WughFYUkF6DxQgy7kZJlQO+vEi0bP+ezUXrO7Ks8HaETDsq0A8
7m/ncDC9qeSpb46cQr4Q/dy0xi5BdCY59deyH64vOYzYyp8gcVs3mSaPmwuVa1+e
lBJZ4hYSAkLyAJ33I3P8
=mG0b
-----END PGP SIGNATURE-----

--nextPart1511845.acmmLYfxhp--
