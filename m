From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 22 Apr 2014 03:09:31 +0000
Subject: Re: [PATCH 3/4] ARCH: AUDIT: implement syscall_get_arch for all arches
Message-Id: <20140422130931.940f53412d30730aa4bc820b@canb.auug.org.au>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Signature=_Tue__22_Apr_2014_13_09_31_+1000_flia9hF+yPUdnFYF"
List-Id: <linux-ia64.vger.kernel.org>
References: <1395266643-3139-1-git-send-email-eparis@redhat.com>
	<1395266643-3139-3-git-send-email-eparis@redhat.com>
In-Reply-To: <1395266643-3139-3-git-send-email-eparis@redhat.com>
To: Eric Paris <eparis@redhat.com>
Cc: linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, microblaze-uclinux@itee.uq.edu.au, linux@openrisc.net, linux-audit@redhat.com, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

--Signature=_Tue__22_Apr_2014_13_09_31_+1000_flia9hF+yPUdnFYF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Eric,

[I just noticed that this turned up in linux-next ...]

On Wed, 19 Mar 2014 18:04:02 -0400 Eric Paris <eparis@redhat.com> wrote:
>
> diff --git a/arch/powerpc/include/asm/syscall.h b/arch/powerpc/include/as=
m/syscall.h
> index b54b2ad..4271544 100644
> --- a/arch/powerpc/include/asm/syscall.h
> +++ b/arch/powerpc/include/asm/syscall.h
> @@ -13,6 +13,8 @@
>  #ifndef _ASM_SYSCALL_H
>  #define _ASM_SYSCALL_H	1
> =20
> +#include <uapi/linux/audit.h>
> +#include <linux/compat.h>

You don't need linux/compat.h, I think, but you do need to include
linux/thread_info.h for is_32bit_task() below.

>  #include <linux/sched.h>
> =20
>  /* ftrace syscalls requires exporting the sys_call_table */
> @@ -86,4 +88,14 @@ static inline void syscall_set_arguments(struct task_s=
truct *task,
>  	memcpy(&regs->gpr[3 + i], args, n * sizeof(args[0]));
>  }
> =20
> +static inline int syscall_get_arch(void)
> +{
> +	int arch =3D AUDIT_ARCH_PPC;
> +
> +#ifdef CONFIG_PPC64
> +	if (!is_32bit_task())
> +		arch =3D AUDIT_ARCH_PPC64;
> +#endif
> +	return arch;

This could just be

	return is_32bit_task() ? AUDIT_ARCH_PPC : AUDIT_ARCH_PPC64;

as is_32bit_task() is always defined (and is (1) for !CONFIG_PPC64).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__22_Apr_2014_13_09_31_+1000_flia9hF+yPUdnFYF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTVd1wAAoJEMDTa8Ir7ZwVHfUQAJBjX5ikUyun82MFtAMdTh2x
9nOveILFcSwGt4ZDyYica+UARDkB0KbtMB38pF7MPePG9f93twRYMnRskrM5XaN0
GDLOJxVoikuMRlt2HxyIVmrLs0JvCccOZz+Uy1Pq50RlB+GqBqCPbDMd7IZBQYKb
MdPoYr+0wIe2eMYRc+Rj9CBzCuY79FoQhCl6rIMsQRJ1/SrD7zvDP8x8J2n/8hpk
+jbgeX30zDIQlCP/a5MjSBFdmqW6N8d5GKLcNPdBSdWe0Ff8G/d/8gz8Q2lvyNxQ
dZdNxa116iZwE5H8p6zLchiwyel3vZzvLCMILCoc1ysMxQXx9Z+sfroFAjYjClm9
EIzBfzV7GR8QsssjCKSkcfFgfviHxIWFWo1ypmlnU/HMNkDB4ywHF6u6t8sx54c0
ZAfKuXa4gs+y99SuEoNbqPB1ssGwhFGdPV9A5n5m5aP8BaRYDFvat7rKA46mWCE2
JFA5CNWHCqzR3Ap/FDht3SeTNFUmDOnY/mfLB5CtjYg8HoTkAT+GB2eXKM9nn5nB
9UiqxLBFgfp1S0aFYlQqixJN872WxkT3L+V7V9DSwLR83RS4PBoSTWKivdZ4/01Y
DOhcrsMkZuOtcJO5QQrZ7hU31ngIHOuVdesryVcVTnh28r1IfviH/YW9xXoC9aS1
axXNb3h4pYFXeMyYxoZ0
=gnUE
-----END PGP SIGNATURE-----

--Signature=_Tue__22_Apr_2014_13_09_31_+1000_flia9hF+yPUdnFYF--
