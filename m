From: Andreas Schwab <schwab@suse.de>
Date: Fri, 10 Oct 2003 08:36:59 +0000
Subject: Re: [PATCH] IO{R,W,RW}_BAD
Message-Id: <marc-linux-ia64-106577527920616@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106572723213144@msgid-missing>
In-Reply-To: <marc-linux-ia64-106572723213144@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Matthew Wilcox <willy@debian.org> writes:

> We need this patch to compile some drivers.  It's a mirror of the patch
> applied to i386 and other architectures.
>
> Index: include/asm-ia64/ioctl.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> RCS file: /var/cvs/linux-2.6/include/asm-ia64/=
ioctl.h,v
> retrieving revision 1.1
> diff -u -p -r1.1 ioctl.h
> --- include/asm-ia64/ioctl.h	29 Jul 2003 17:01:57 -0000	1.1
> +++ include/asm-ia64/ioctl.h	30 Sep 2003 22:23:28 -0000
> @@ -54,11 +54,21 @@
>  	 ((nr)   << _IOC_NRSHIFT) | \
>  	 ((size) << _IOC_SIZESHIFT))
> =20
> +/* provoke compile error for invalid uses of size argument */
> +extern int __invalid_size_argument_for_IOC;
> +#define _IOC_TYPECHECK(t) \
> +	((sizeof(t) =3D sizeof(t[1]) && \
> +	  sizeof(t) < (1 << _IOC_SIZEBITS)) ? \
> +	  sizeof(t) : __invalid_size_argument_for_IOC)

This needs to be implemented differently.  Glibc needs to include this
file for <sys/ioctl.h>, but the use of the undefined symbol will make it
impossible to compile without optimisation.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux AG, Deutschherrnstr. 15-19, D-90429 N=FCrnberg
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
