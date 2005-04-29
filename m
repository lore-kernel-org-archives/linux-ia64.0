From: Andreas Schwab <schwab@suse.de>
Date: Fri, 29 Apr 2005 19:10:50 +0000
Subject: Re: Incorrect return types for atomic64 functions in IA64 atomic.h
Message-Id: <jer7gtv1ol.fsf@sykes.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <200504291443.16040.gerald.feldman@hp.com>
In-Reply-To: <200504291443.16040.gerald.feldman@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

Jerry Feldman <gerald.feldman@hp.com> writes:

> @@ -124,7 +124,7 @@ atomic_add_negative (int i, atomic_t *v)
>         return atomic_add_return(i, v) < 0;
>  }
> =20
> -static __inline__ int
> +static __inline__ __s64
>  atomic64_add_negative (__s64 i, atomic64_t *v)
>  {
>         return atomic64_add_return(i, v) < 0;

This is wrong.  The return value is a boolean.

Andreas.

--=20
Andreas Schwab, SuSE Labs, schwab@suse.de
SuSE Linux Products GmbH, Maxfeldstra=DFe 5, 90409 N=FCrnberg, Germany
Key fingerprint =3D 58CA 54C7 6D53 942B 1756  01D3 44D5 214B 8276 4ED5
"And now for something completely different."
