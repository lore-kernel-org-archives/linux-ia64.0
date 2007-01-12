From: "Zou, Nanhai" <nanhai.zou@intel.com>
Date: Fri, 12 Jan 2007 08:34:32 +0000
Subject: RE: [PATCH] Kdump documentation update for 2.6.20: ia64 portion
Message-Id: <10EA09EFD8728347A513008B6B0DA77A086BAA@pdsmsx411.ccr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070112060724.GC17379@verge.net.au>
References: <20070112060618.GA17379@verge.net.au>
In-Reply-To: <20070112060618.GA17379@verge.net.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Horms <horms@verge.net.au>, Vivek Goyal <vgoyal@in.ibm.com>
Cc: Mohan Kumar M <mohan@in.ibm.com>, Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, linux-kernel@vger.kernel.org, fastboot@lists.osdl.org, linux-ia64@vger.kernel.org


> -----Original Message-----
> From: linux-ia64-owner@vger.kernel.org
> [mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Horms
> Sent: 2007=C4=EA1=D4=C212=C8=D5 14:07
> To: Vivek Goyal
> Cc: Mohan Kumar M; Andrew Morton; Zou, Nanhai; Luck, Tony;
> linux-kernel@vger.kernel.org; fastboot@lists.osdl.org;
> linux-ia64@vger.kernel.org
> Subject: [PATCH] Kdump documentation update for 2.6.20: ia64 portion
>=20
> Hi,
>=20
> this patch fills in the portions for ia64 kexec.
>=20
> I'm actually not sure what options are required for the dump-capture
> kernel, but "init 1 irqpoll maxcpus=3D1" has been working fine for me.
> Or more to the point, I'm not sure if irqpoll is needed or not.
>=20
> This patch requires the documentation patch update that Vivek Goyal has
> been circulating, and I believe is currently in mm. Feel free to fold it
> into that change if it makes things easier for anyone.
>=20
> Signed-off-by: Simon Horman <horms@verge.net.au>
>=20
> Index: linux-2.6/Documentation/kdump/kdump.txt
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/Documentation/kdump/kdump.t=
xt	2007-01-12
> 14:37:46.000000000 +0900
> +++ linux-2.6/Documentation/kdump/kdump.txt	2007-01-12
> 14:46:53.000000000 +0900
> @@ -17,7 +17,7 @@
>  memory image to a dump file on the local disk, or across the network to
>  a remote system.
>=20
> -Kdump and kexec are currently supported on the x86, x86_64, ppc64 and IA=
64
> +Kdump and kexec are currently supported on the x86, x86_64, ppc64 and ia=
64
>  architectures.
>=20
>  When the system kernel boots, it reserves a small section of memory for
> @@ -227,7 +227,11 @@
>=20
>  Dump-capture kernel config options (Arch Dependent, ia64)
>  ----------------------------------------------------------
> -(To be filled)
> +
> +- No specific options are required to create a dump-capture kernel
> +  for ia64 other than those specified in the arch idependent section
> +  above. This means that it is possible to use the system kernel
> +  as a dump-capture kernel if desired.
>=20
>=20
>  Boot into System Kernel
> @@ -264,7 +268,8 @@
>  For ppc64:
>  	- Use vmlinux
>  For ia64:
> -	(To be filled)
> +	- Use vmlinux
> +
  You can also use gziped vmlinux.gz here.
>=20
>  If you are using a uncompressed vmlinux image then use following command
>  to load dump-capture kernel.
> @@ -280,18 +285,19 @@
>     --initrd=3D<initrd-for-dump-capture-kernel> \
>     --append=3D"root=3D<root-dev> <arch-specific-options>"
>=20
> +Please note, that --args-linux does not need to be specified for ia64.
> +It is planned to make this a no-op on that architecture, but for now
> +it should be omitted
> +
>  Following are the arch specific command line options to be used while
>  loading dump-capture kernel.
>=20
> -For i386 and x86_64:
> +For i386, x86_64 and ia64:
>  	"init 1 irqpoll maxcpus=3D1"
>=20
>  For ppc64:
>  	"init 1 maxcpus=3D1 noirqdistrib"
>=20
> -For IA64
> -	(To be filled)
> -
>=20
>  Notes on loading the dump-capture kernel:
>=20
   We can add note about that IA64 can automatically pick crash dump region=
 according to size to reserve.

Thanks
Zou Nan hai
