From: Andreas Schwab <schwab@suse.de>
Date: Mon, 13 Feb 2006 21:28:18 +0000
Subject: Re: [PATCH] ia64: simplify and fix udelay()
Message-Id: <jefymnaqz1.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060213183344.21339.33094.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20060213183344.21339.33094.sendpatchset@tomahawk.engr.sgi.com>
	(hawkes@sgi.com's message of "Mon, 13 Feb 2006 10:33:44 -0800")
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: hawkes@sgi.com
Cc: Tony Luck <tony.luck@gmail.com>, Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Dimitri Sivanich <sivanich@sgi.com>, Jes Sorensen <jes@sgi.com>

hawkes@sgi.com writes:

> Index: linux/arch/ia64/sn/kernel/sn2/timer.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- linux.orig/arch/ia64/sn/kernel/sn2/timer.c=
	2006-02-08 17:59:42.000000000 -0800
> +++ linux/arch/ia64/sn/kernel/sn2/timer.c	2006-02-09 09:02:31.000000000 -=
0800
> @@ -28,9 +28,29 @@ static struct time_interpolator sn2_inte
>  	.source =3D TIME_SOURCE_MMIO64
>  };
> =20
> +extern void (*ia64_udelay)(unsigned long usecs);

Please put the declaration in a header.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
PGP key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
