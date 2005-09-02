From: Andreas Schwab <schwab@suse.de>
Date: Fri, 02 Sep 2005 19:21:34 +0000
Subject: Re: [PATCH] altix: Add volatile qualifiers in places where it seems necessary
Message-Id: <jeu0h3ff7l.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
In-Reply-To: <20050902153612.8521.73623.91869@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Mark Maule <maule@sgi.com> writes:

> Index: volatile/include/asm-ia64/sn/io.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D> --- volatile.orig/include/asm-ia64/sn/io.h	200=
5-09-02 09:13:20.730793919 -0500
> +++ volatile/include/asm-ia64/sn/io.h	2005-09-02 12:35:33.897375370 -0500
> @@ -36,6 +36,13 @@
>  #define __sn_readq_relaxed ___sn_readq_relaxed
> =20
>  /*
> + * Convenience macros for read/modify/write operations using above acces=
sors
> + */
> +
> +#define __sn_rwq_relaxed(addr, op, val) \
> +	{uint64_t r =3D __sn_readq_relaxed(addr); r op (val); writeq(r, addr);}

The local variable should be renamed to something less likely to clash
with names used in the arguments.  The expansion should be surrounded by
do ... while(0) to make it a proper statement immune from the dangling
else problem.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
