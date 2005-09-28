From: Bruce Losure <blosure@americas.sgi.com>
Date: Wed, 28 Sep 2005 22:10:54 +0000
Subject: Re: [Lhms-devel] RE: [PATCH 0/4] V4 ia64 SPARSEMEM
Message-Id: <Pine.LNX.4.44.0509281710410.10386-100000@fsgi025.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1127779977.10315.6.camel@localhost>
In-Reply-To: <1127779977.10315.6.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


Looks good to me.   Thanks.

-Bruce

On Wed, 28 Sep 2005, Greg Edwards wrote:

> On Wed, Sep 28, 2005 at 11:42:44AM -0400, Bob Picco wrote:
> | I had a problem booting sparsemem_defconfig without modules on my rx260=
0.
> | After removing CONFIG_SGI_MBCS it booted fine.
> |=20
> | Badness in kref_get at lib/kref.c:32
> |=20
> | Call Trace:
> |  [<a000000100012080>] show_stack+0x80/0xa0
> |                                 sp=E000000003177c10 bsp=E000000003170fd0
> |  [<a0000001000120d0>] dump_stack+0x30/0x60
> |                                 sp=E000000003177de0 bsp=E000000003170fb8
> |  [<a0000001004edc20>] kref_get+0xa0/0xc0
> |                                 sp=E000000003177de0 bsp=E000000003170f98
> |  [<a0000001004ec570>] kobject_get+0x30/0x60
> |                                 sp=E000000003177de0 bsp=E000000003170f78
> |  [<a000000100646340>] get_bus+0x40/0xa0
> |                                 sp=E000000003177de0 bsp=E000000003170f58
> |  [<a000000100645ff0>] bus_add_driver+0x30/0x180
> |                                 sp=E000000003177de0 bsp=E000000003170f20
> |  [<a000000100647750>] driver_register+0x70/0xa0
> |                                 sp=E000000003177de0 bsp=E000000003170f00
> |  [<a000000100a5fc70>] cx_driver_register+0x70/0xa0
> |                                 sp=E000000003177de0 bsp=E000000003170ee0
> |  [<a000000100d8c3c0>] mbcs_init+0x80/0xc0
> |                                 sp=E000000003177de0 bsp=E000000003170ec0
> |  [<a000000100d5d170>] do_initcalls+0xb0/0x200
> |                                 sp=E000000003177de0 bsp=E000000003170e58
> |  [<a000000100d5d330>] do_basic_setup+0x70/0xa0
> |                                 sp=E000000003177de0 bsp=E000000003170e40
> |  [<a000000100009b70>] init+0x170/0x4e0
> |                                 sp=E000000003177de0 bsp=E000000003170e00
> |  [<a0000001000144f0>] kernel_thread_helper+0xd0/0x100
> |                                 sp=E000000003177e30 bsp=E000000003170dd0
> |  [<a0000001000094a0>] start_kernel_thread+0x20/0x40
> |                                 sp=E000000003177e30 bsp=E000000003170dd0
>=20
> Looks like mbcs_init could use a platform check.  Bruce, does this look
> ok?
>=20
> Signed-off-by: Greg Edwards <edwardsg@sgi.com>
>=20
>  drivers/char/mbcs.c |    3 +++
>  1 files changed, 3 insertions(+)
>=20
> Index: git-linus/drivers/char/mbcs.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- git-linus.orig/drivers/char/mbcs.c	2005-09=
-12 11:34:37.639213202 -0500
> +++ git-linus/drivers/char/mbcs.c	2005-09-28 12:37:02.756895426 -0500
> @@ -830,6 +830,9 @@ static int __init mbcs_init(void)
>  {
>  	int rv;
> =20
> +	if (!ia64_platform_is("sn2"))
> +		return -ENODEV;
> +
>  	// Put driver into chrdevs[].  Get major number.
>  	rv =3D register_chrdev(mbcs_major, DEVICE_NAME, &mbcs_ops);
>  	if (rv < 0) {
>=20

--=20
Bruce Losure                            internet: blosure@sgi.com
SGI                                     phone:    +1 651 683-7263
2750 Blue Water Rd			vnet:	  233-7263
Eagan, MN, USA 55121

