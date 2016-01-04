From: James Hogan <james.hogan@imgtec.com>
Date: Mon, 04 Jan 2016 23:24:04 +0000
Subject: Re: [PATCH v2 10/32] metag: reuse asm-generic/barrier.h
Message-Id: <20160104232404.GL17861@jhogan-linux.le.imgtec.org>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="2OzUYMsT4j3Kc+NU"
List-Id: <linux-ia64.vger.kernel.org>
References: <1451572003-2440-1-git-send-email-mst@redhat.com>
 <1451572003-2440-11-git-send-email-mst@redhat.com>
In-Reply-To: <1451572003-2440-11-git-send-email-mst@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org, Andrew Cooper <andrew.cooper3@citrix.com>, virtualization@lists.linux-foundation.org, Stefano Stabellini <stefano.stabellini@eu.citrix.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, David Miller <davem@davemloft.net>, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, x86@kernel.org, user-mode-linux-devel@lists.sourceforge.net, adi-buildroot-devel@lists.sourceforge.net, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, xen-devel@lists.xenproject.org, Ingo Molnar <mingo@kernel.org>

--2OzUYMsT4j3Kc+NU
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Dec 31, 2015 at 09:07:02PM +0200, Michael S. Tsirkin wrote:
> On metag dma_rmb, dma_wmb, smp_store_mb, read_barrier_depends,
> smp_read_barrier_depends, smp_store_release and smp_load_acquire  match
> the asm-generic variants exactly. Drop the local definitions and pull in
> asm-generic/barrier.h instead.
>=20
> This is in preparation to refactoring this code area.
>=20
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Arnd Bergmann <arnd@arndb.de>

Looks good, and confirmed no text change (once patch 1 is applied that
is).

Acked-by: James Hogan <james.hogan@imgtec.com>

Thanks
James

> ---
>  arch/metag/include/asm/barrier.h | 25 ++-----------------------
>  1 file changed, 2 insertions(+), 23 deletions(-)
>=20
> diff --git a/arch/metag/include/asm/barrier.h b/arch/metag/include/asm/ba=
rrier.h
> index 172b7e5..b5b778b 100644
> --- a/arch/metag/include/asm/barrier.h
> +++ b/arch/metag/include/asm/barrier.h
> @@ -44,9 +44,6 @@ static inline void wr_fence(void)
>  #define rmb()		barrier()
>  #define wmb()		mb()
> =20
> -#define dma_rmb()	rmb()
> -#define dma_wmb()	wmb()
> -
>  #ifndef CONFIG_SMP
>  #define fence()		do { } while (0)
>  #define smp_mb()        barrier()
> @@ -81,27 +78,9 @@ static inline void fence(void)
>  #endif
>  #endif
> =20
> -#define read_barrier_depends()		do { } while (0)
> -#define smp_read_barrier_depends()	do { } while (0)
> -
> -#define smp_store_mb(var, value) do { WRITE_ONCE(var, value); smp_mb(); =
} while (0)
> -
> -#define smp_store_release(p, v)						\
> -do {									\
> -	compiletime_assert_atomic_type(*p);				\
> -	smp_mb();							\
> -	WRITE_ONCE(*p, v);						\
> -} while (0)
> -
> -#define smp_load_acquire(p)						\
> -({									\
> -	typeof(*p) ___p1 =3D READ_ONCE(*p);				\
> -	compiletime_assert_atomic_type(*p);				\
> -	smp_mb();							\
> -	___p1;								\
> -})
> -
>  #define smp_mb__before_atomic()	barrier()
>  #define smp_mb__after_atomic()	barrier()
> =20
> +#include <asm-generic/barrier.h>
> +
>  #endif /* _ASM_METAG_BARRIER_H */
> --=20
> MST
>=20

--2OzUYMsT4j3Kc+NU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWiv8UAAoJEGwLaZPeOHZ6hSwQAJCVQc5QdNomZOnrxJp5uv9r
iT+zYpXRNC4k29ENp5iDq29d07OM1zooI0szDvvKi351dsFwfOXrEBIcoKJjLRcm
VGVtFCCI0IffzBGaMa2u16xywqgCogk+uMnlOmyk2cSM6lx0BdWIb6sL4fzkocfT
a1sTWJnh45/sQG+VQQUUFokjUM0UFCXOV+77I556Khe9tS5qgZnObEsAIk+lrY/3
lRo2nd2wbZsybzqlQVKp3nKYbFNUpoCGT/myPpj8A3NQ/FBUOs6LtpZvD0i06CJh
E01ASo6Cr5SvTyOAYsty+zcZvFGZPB+2i9jyv/7vGDBgdiCwLEX25gXxz9aS8GB6
2Oa2E/5z/uCltUZyM3y3Yz/K8XwnhORh3PMpZR/b2Ze5MnguCLy2zWrcKWdZhCJ+
UkNkLe3rcbdLSfCcK6kCSAwHoqj78IeHmBG+96vEwePwsQh7YkAKIoKSMxbx88BU
gD/yn8y+dc7wSJGYgHM4eBw35H3o7HTB6bPRZsw8/ak1nG8ClOMtWkoLB7a+9wOA
J5tM/aHE0ixB02QphdN8lkvqMA+U9EKmq6hBHZeiyIxNx/mCAm+6dcGv484Hh2UF
tvsj4erVkGZa9EJ3KL49xvAJx23RTZcR+a2djcLUlzeLr32UDWh3zuVzSoNc+ZKD
Cnc7cQMIdlTlucxbu/OU
=IkXd
-----END PGP SIGNATURE-----

--2OzUYMsT4j3Kc+NU--
