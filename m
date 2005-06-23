From: Andreas Schwab <schwab@suse.de>
Date: Thu, 23 Jun 2005 22:54:13 +0000
Subject: Re: [patch] Memory Error Handling Improvement
Message-Id: <jezmtgfzvu.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
In-Reply-To: <200506231730.j5NHUNa96698484@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Russ Anderson <rja@sgi.com> writes:

> Index: linux-2.6/arch/ia64/kernel/ia64_ksyms.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux-2.6.orig/arch/ia64/kernel/ia64_ksyms=
.c	2005-06-23 14:04:13.742356057 -0500
> +++ linux-2.6/arch/ia64/kernel/ia64_ksyms.c	2005-06-23 14:04:18.585065944=
 -0500
> @@ -123,5 +123,8 @@
>  # endif
>  #endif
> =20
> +extern char interrupt_pnr;
> +EXPORT_SYMBOL(interrupt_pnr);
> +
>  extern char ia64_ivt[];
>  EXPORT_SYMBOL(ia64_ivt);

This should use the header as well.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
