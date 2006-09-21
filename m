From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Thu, 21 Sep 2006 05:49:09 +0000
Subject: RE: Kexec/Kdump: honour non-zero crashkernel offset.
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086AC4@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060920024544.733881000@tabatha.lab.ultramonkey.org>
In-Reply-To: <20060920024544.733881000@tabatha.lab.ultramonkey.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org


> -----Original Message-----
> From: Horms [mailto:horms@verge.net.au]
> Sent: 2006=C4=EA9=D4=C221=C8=D5 13:33
> To: Zou, Nanhai
> Cc: Luck, Tony; Linux-IA64; fastboot
> Subject: Re: Kexec/Kdump: honour non-zero crashkernel offset.
>=20
> On Thu, Sep 21, 2006 at 09:01:33AM +0800, Zou Nan hai wrote:
> >  This patch is incorrect.
> >  I think you will get a compile warning of base is used before it is
> > aligned a value here...
>=20
> Sorry about that.  Is this better?
>=20
> --
> Horms
>   H: http://www.vergenet.net/~horms/
>   W: http://www.valinux.co.jp/en/
>=20
> [IA64] Kexec/Kdump: honour non-zero crashkernel offset.
>=20
> There seems to be a value in both allowing the kernel to determine
> the base offset of the crashkernel automatically and allowing
> users's to sepcify it.
>=20
> The old behaviour on ia64, which is still the current behaviour on
> most architectures is for the user to always specify the address.
> Recently ia64 was changed so that it is always automatically determined.
>=20
> With this patch the kernel automatically determines the offset if
> the supplied value is 0, otherwise it uses the value provided.
>=20
> This should probably be backed by a documentation change.
>=20
> Signed-Off-By: Simon Horman <horms@verge.net.au>
>=20
> Index: linux-2.6-ia64/arch/ia64/kernel/setup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6-ia64.orig/arch/ia64/kernel/setup=
.c	2006-09-21
> 14:08:20.000000000 +0900
> +++ linux-2.6-ia64/arch/ia64/kernel/setup.c	2006-09-21
> 14:15:36.000000000 +0900
> @@ -257,7 +257,7 @@
>=20
>  #ifdef CONFIG_KEXEC
>  	/* crashkernel=3Dsize@offset specifies the size to reserve for a crash
> -	 * kernel.(offset is ingored for keep compatibility with other archs)
> +	 * kernel. If offset is 0, then it is determined automatically.
>  	 * By reserving this memory we guarantee that linux
>  	 * never set's it up as a DMA target.
>  	 * Useful for holding code to do something appropriate
> @@ -268,7 +268,11 @@
>  		unsigned long base, size;
>  		if (from) {
>  			size =3D memparse(from + 12, &from);
> -			if (size) {
> +			if (*from =3D '@')
> +				base =3D memparse(from+1, &from);
> +			else
> +				base =3D 0;
> +			if (size && !base) {
>  				sort_regions(rsvd_region, n);
>  				base =3D kdump_find_rsvd_region(size,
>  				rsvd_region, n);
	This patch is still incorrect. You will miss the rsvd_region code if base =
not equals 0.=20
=09
Zou Nan hai
