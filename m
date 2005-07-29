From: Eric Dumazet <dada1@cosmosbay.com>
Date: Fri, 29 Jul 2005 08:30:19 +0000
Subject: Re: Add prefetch switch stack hook in scheduler function
Message-Id: <42E9E91B.9050403@cosmosbay.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------070106000105030207090808"
List-Id: <linux-ia64.vger.kernel.org>
References: <20050728090948.GA24222@elte.hu> <200507281914.j6SJErg31398@unix-os.sc.intel.com> <20050729070447.GA3032@elte.hu> <20050729070702.GA3327@elte.hu>
In-Reply-To: <20050729070702.GA3327@elte.hu>
To: Ingo Molnar <mingo@elte.hu>
Cc: "Chen, Kenneth W" <kenneth.w.chen@intel.com>, Keith Owens <kaos@ocs.com.au>, David.Mosberger@acm.org, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------070106000105030207090808
Content-Type: text/plain; charset="iso-8859-1"; format="flowed"
Content-Transfer-Encoding: quoted-printable

Ingo Molnar a =E9crit :


> unroll prefetch_range() loops manually.
>=20
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
>=20
>  include/linux/prefetch.h |   31 +++++++++++++++++++++++++++++--
>  1 files changed, 29 insertions(+), 2 deletions(-)
>=20
> Index: linux/include/linux/prefetch.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.orig/include/linux/prefetch.h
> +++ linux/include/linux/prefetch.h
> @@ -58,11 +58,38 @@ static inline void prefetchw(const void=20
>  static inline void prefetch_range(void *addr, size_t len)
>  {
>  #ifdef ARCH_HAS_PREFETCH
> -	char *cp;
> +	char *cp =3D addr;
>  	char *end =3D addr + len;
> =20
> -	for (cp =3D addr; cp < end; cp +=3D PREFETCH_STRIDE)
> +	/*
> +	 * Unroll agressively:
> +	 */
> +	if (len <=3D PREFETCH_STRIDE)
>  		prefetch(cp);
> +	else if (len <=3D 2*PREFETCH_STRIDE) {
> +		prefetch(cp);
> +		prefetch(cp + PREFETCH_STRIDE);
> +	}
> +	else if (len <=3D 3*PREFETCH_STRIDE) {
> +		prefetch(cp);
> +		prefetch(cp + PREFETCH_STRIDE);
> +		prefetch(cp + 2*PREFETCH_STRIDE);
> +	}
> +	else if (len <=3D 4*PREFETCH_STRIDE) {
> +		prefetch(cp);
> +		prefetch(cp + PREFETCH_STRIDE);
> +		prefetch(cp + 2*PREFETCH_STRIDE);
> +		prefetch(cp + 3*PREFETCH_STRIDE);
> +	}
> +	else if (len <=3D 5*PREFETCH_STRIDE) {
> +		prefetch(cp);
> +		prefetch(cp + PREFETCH_STRIDE);
> +		prefetch(cp + 2*PREFETCH_STRIDE);
> +		prefetch(cp + 3*PREFETCH_STRIDE);
> +		prefetch(cp + 4*PREFETCH_STRIDE);
> +	} else
> +		for (; cp < end; cp +=3D PREFETCH_STRIDE)
> +			prefetch(cp);
>  #endif
>  }
> =20
> -

Please test that len is a constant, or else the inlining is too large for t=
he non constant case.

Thank you

--------------070106000105030207090808
Content-Type: text/plain;
 name="prefetch_range"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="prefetch_range"

static inline void prefetch_range(void *addr, size_t len)
{
	char *cp;
	char *end = addr + len;

	if (__builtin_constant_p(len) && (len <= 5*PREFETCH_STRIDE)) {
		if (len <= PREFETCH_STRIDE)
	 		prefetch(cp);
		else if (len <= 2*PREFETCH_STRIDE) {
			prefetch(cp);
			prefetch(cp + PREFETCH_STRIDE);
		}
		else if (len <= 3*PREFETCH_STRIDE) {
			prefetch(cp);
			prefetch(cp + PREFETCH_STRIDE);
			prefetch(cp + 2*PREFETCH_STRIDE);
		}
		else if (len <= 4*PREFETCH_STRIDE) {
			prefetch(cp);
			prefetch(cp + PREFETCH_STRIDE);
			prefetch(cp + 2*PREFETCH_STRIDE);
			prefetch(cp + 3*PREFETCH_STRIDE);
		}
		else if (len <= 5*PREFETCH_STRIDE) {
			prefetch(cp);
			prefetch(cp + PREFETCH_STRIDE);
			prefetch(cp + 2*PREFETCH_STRIDE);
			prefetch(cp + 3*PREFETCH_STRIDE);
			prefetch(cp + 4*PREFETCH_STRIDE);
		}
	}
	else
		for (; cp < end; cp += PREFETCH_STRIDE)
			prefetch(cp);
}

--------------070106000105030207090808--
