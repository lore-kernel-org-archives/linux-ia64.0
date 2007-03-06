From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Tue, 06 Mar 2007 08:34:44 +0000
Subject: RE: [patch 1/3] IA64: put kdump_find_rsvd_region in __init
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086C06@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070306073755.795769464@tabatha.lab.ultramonkey.org>
In-Reply-To: <20070306073755.795769464@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2007=C4=EA3=D4=C26=C8=D5 15:29
> To: Linux-IA64; fastboot@lists.osdl.org
> Cc: Luck, Tony; Zou, Nanhai; Magnus Damm
> Subject: [patch 1/3] IA64: put kdump_find_rsvd_region in __init
>=20
> kdump_find_rsvd_region() is only called by
> reserve_memory() which is in __init, so it seems that
> kdump_find_rsvd_region() should also be in there.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> Index: linux-2.6/arch/ia64/kernel/efi.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/arch/ia64/kernel/efi.c	2007=
-03-06 16:30:10.000000000
> +0900
> +++ linux-2.6/arch/ia64/kernel/efi.c	2007-03-06 16:30:13.000000000 +0900
> @@ -1136,7 +1136,7 @@
>  /* find a block of memory aligned to 64M exclude reserved regions
>     rsvd_regions are sorted
>   */
> -unsigned long
> +unsigned long __init
>  kdump_find_rsvd_region (unsigned long size,
>  		struct rsvd_region *r, int n)
>  {
>=20
> --
>=20
 This patch looks good to me.

Zou Nan hai

> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
