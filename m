From: Petr Tesarik <ptesarik@suse.cz>
Date: Fri, 02 May 2008 10:02:11 +0000
Subject: Re: [BUG?][2.6.25-mm1] sleeping during IRQ disabled
Message-Id: <1209722531.8563.7.camel@elijah.suse.cz>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="=-eXyy5WtMxS5hMLazJ59t"
List-Id: <linux-ia64.vger.kernel.org>
References: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080502182440.6E5F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
To: linux-ia64@vger.kernel.org


--=-eXyy5WtMxS5hMLazJ59t
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-05-02 at 18:27 +0900, KOSAKI Motohiro wrote:
> Hi
>=20
> On ia64 2.6.25-mm1, below message is displayed at stress test running.
> Is it bug or not?

This surely is a bug. I bet this was introduced by Hidetoshi's latest
commit:

commit 38477ad75188b2a7370fef7145f956e6c446928b
Author: Hidetoshi Seto
Date:   Mon Apr 21 14:34:39 2008 -0700

    [IA64] disable interrupts on exit of ia64_trace_syscall

Obviously, if interrupts are disabled and notify_resume_user
synchronizes the RBS, the following condition in __might_sleep() is
true:

	if ((in_atomic() || irqs_disabled()) &&

Cheers,
Petr Tesarik

---------------------------------------------
> BUG: sleeping function called from invalid context at kernel/rwsem.c:21
> in_atomic():0, irqs_disabled():1
>=20
> Call Trace:
>  [<a000000100015d00>] show_stack+0x80/0xa0
>                                 sp=3De00001608577f840 bsp=3De000016085771=
038
>  [<a000000100015d50>] dump_stack+0x30/0x60
>                                 sp=3De00001608577fa10 bsp=3De000016085771=
020
>  [<a000000100092e80>] __might_sleep+0x1e0/0x2e0
>                                 sp=3De00001608577fa10 bsp=3De000016085770=
ff0
>  [<a000000100791f00>] down_read+0x20/0x60
>                                 sp=3De00001608577fa10 bsp=3De000016085770=
fd0
>  [<a00000010015cd50>] access_process_vm+0x70/0x3a0
>                                 sp=3De00001608577fa10 bsp=3De000016085770=
f28
>  [<a000000100030f60>] ia64_sync_kernel_rbs+0x40/0x100
>                                 sp=3De00001608577fa20 bsp=3De000016085770=
ef0
>  [<a00000010002f640>] do_sync_rbs+0xc0/0x100
>                                 sp=3De00001608577fa30 bsp=3De000016085770=
ec0
>  [<a00000010000b250>] unw_init_running+0x70/0xa0
>                                 sp=3De00001608577fa40 bsp=3De000016085770=
e98
>  [<a000000100033ee0>] ia64_sync_krbs+0x80/0xa0
>                                 sp=3De00001608577fe20 bsp=3De000016085770=
e80
>  [<a0000001000168a0>] do_notify_resume_user+0x1c0/0x1e0
>                                 sp=3De00001608577fe20 bsp=3De000016085770=
e50
>  [<a00000010000b0e0>] notify_resume_user+0x40/0x60
>                                 sp=3De00001608577fe20 bsp=3De000016085770=
e00
>  [<a00000010000b010>] skip_rbs_switch+0xe0/0x110
>                                 sp=3De00001608577fe30 bsp=3De000016085770=
e00
>  [<a000000000010720>] __kernel_syscall_via_break+0x0/0x20
>                                 sp=3De000016085780000 bsp=3De000016085770=
e0
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-eXyy5WtMxS5hMLazJ59t
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBIGuajjpY2ODFi2ogRAhlqAJ9t6tGz+nbnmWHnT6ogjk5tzqTYAgCfeg0q
AVzb/ak4Uuham9ruHWS5DuQ=
=281f
-----END PGP SIGNATURE-----

--=-eXyy5WtMxS5hMLazJ59t--
