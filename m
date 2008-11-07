From: Simon Horman <horms@verge.net.au>
Date: Fri, 07 Nov 2008 02:49:48 +0000
Subject: Re: [PATCH] Reserve elfcorehdr memory in CONFIG_CRASH_DUMP
Message-Id: <20081107024946.GA20889@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4913A8C0.8090108@sgi.com>
In-Reply-To: <4913A8C0.8090108@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Jay Lan <jlan@sgi.com>
Cc: "kexec@lists.infradead.org" <kexec@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

On Thu, Nov 06, 2008 at 06:32:32PM -0800, Jay Lan wrote:
> IA64 kdump kernel failed to initialize /proc/vmcore in 2.6.28-rc2.
> A bug was introduced in this patch commit:
> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3Dco=
mmitdiff;h=D9a9855d0b06ca6d6cc92596fedcc03f8512e062
>=20
> The problem was that the call to reserve_elfcorehdr() should be placed
> in CONFIG_CRASH_DUMP rather than in CONFIG_CRASH_KERNEL, which does
> not exist.
>=20
> The patch fixes the problem.
>=20
> Signed-off-by: Jay Lan <jlan@sgi.com>

Acked-by: Simon Horman <horms@verge.net.au>

> ---
>  arch/ia64/kernel/setup.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> Index: linux/arch/ia64/kernel/setup.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/kernel/setup.c	2008-1=
1-06 18:01:18.000000000 -0800
> +++ linux/arch/ia64/kernel/setup.c	2008-11-06 18:05:42.047332827 -0800
> @@ -359,7 +359,7 @@ reserve_memory (void)
>  	}
>  #endif
> =20
> -#ifdef CONFIG_CRASH_KERNEL
> +#ifdef CONFIG_CRASH_DUMP
>  	if (reserve_elfcorehdr(&rsvd_region[n].start,
>  			       &rsvd_region[n].end) =3D 0)
>  		n++;


--=20
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

