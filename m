From: "Paul E. McKenney" <paulmck@kernel.org>
Date: Sun, 05 Jun 2022 19:58:25 +0000
Subject: Re: [PATCH] ia64: fix sparse warnings with cmpxchg() & xchg()
Message-Id: <20220605195825.GW1790663@paulmck-ThinkPad-P17-Gen-1>
List-Id: <linux-ia64.vger.kernel.org>
References: <87h7547k8c.fsf@toke.dk>
 <20220605160738.79736-1-luc.vanoostenryck@gmail.com>
In-Reply-To: <20220605160738.79736-1-luc.vanoostenryck@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, kernel test robot <lkp@intel.com>, Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@redhat.com>

On Sun, Jun 05, 2022 at 06:07:38PM +0200, Luc Van Oostenryck wrote:
> On IA64, new sparse's warnings where issued after fixing
> some __rcu annotations in kernel/bpf/.
>=20
> These new warnings are false positives and appear on IA64 because
> on this architecture, the macros for cmpxchg() and xchg() make
> casts that ignore sparse annotations.
>=20
> This patch contains the minimal patch to fix this issue:
> adding a missing cast and some missing '__force'.
>=20
> Link: https://lore.kernel.org/r/20220601120013.bq5a3ynbkc3hngm5@mail
> Reported-by: kernel test robot <lkp@intel.com>
> Cc: Toke H=F8iland-J=F8rgensen <toke@redhat.com>
> Signed-off-by: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>

Looks good to me!

Acked-by: Paul E. McKenney <paulmck@kernel.org>

> ---
>=20
> Note: This patch is only compile tested on defconfig. The corresponding
>       binary is unchanged (except some .rodata with the kernel version)
>       as it should be.
>=20
>  arch/ia64/include/uapi/asm/cmpxchg.h | 28 ++++++++++++++--------------
>  1 file changed, 14 insertions(+), 14 deletions(-)
>=20
> diff --git a/arch/ia64/include/uapi/asm/cmpxchg.h b/arch/ia64/include/uap=
i/asm/cmpxchg.h
> index 2c2f3cfeaa77..ca2e02685343 100644
> --- a/arch/ia64/include/uapi/asm/cmpxchg.h
> +++ b/arch/ia64/include/uapi/asm/cmpxchg.h
> @@ -33,24 +33,24 @@ extern void ia64_xchg_called_with_bad_pointer(void);
>  									\
>  	switch (size) {							\
>  	case 1:								\
> -		__xchg_result =3D ia64_xchg1((__u8 *)ptr, x);		\
> +		__xchg_result =3D ia64_xchg1((__u8 __force *)ptr, x);	\
>  		break;							\
>  									\
>  	case 2:								\
> -		__xchg_result =3D ia64_xchg2((__u16 *)ptr, x);		\
> +		__xchg_result =3D ia64_xchg2((__u16 __force *)ptr, x);	\
>  		break;							\
>  									\
>  	case 4:								\
> -		__xchg_result =3D ia64_xchg4((__u32 *)ptr, x);		\
> +		__xchg_result =3D ia64_xchg4((__u32 __force *)ptr, x);	\
>  		break;							\
>  									\
>  	case 8:								\
> -		__xchg_result =3D ia64_xchg8((__u64 *)ptr, x);		\
> +		__xchg_result =3D ia64_xchg8((__u64 __force *)ptr, x);	\
>  		break;							\
>  	default:							\
>  		ia64_xchg_called_with_bad_pointer();			\
>  	}								\
> -	__xchg_result;							\
> +	(__typeof__ (*(ptr)) __force) __xchg_result;			\
>  })
> =20
>  #ifndef __KERNEL__
> @@ -76,42 +76,42 @@ extern long ia64_cmpxchg_called_with_bad_pointer(void=
);
>  									\
>  	switch (size) {							\
>  	case 1:								\
> -		_o_ =3D (__u8) (long) (old);				\
> +		_o_ =3D (__u8) (long __force) (old);			\
>  		break;							\
>  	case 2:								\
> -		_o_ =3D (__u16) (long) (old);				\
> +		_o_ =3D (__u16) (long __force) (old);			\
>  		break;							\
>  	case 4:								\
> -		_o_ =3D (__u32) (long) (old);				\
> +		_o_ =3D (__u32) (long __force) (old);			\
>  		break;							\
>  	case 8:								\
> -		_o_ =3D (__u64) (long) (old);				\
> +		_o_ =3D (__u64) (long __force) (old);			\
>  		break;							\
>  	default:							\
>  		break;							\
>  	}								\
>  	switch (size) {							\
>  	case 1:								\
> -		_r_ =3D ia64_cmpxchg1_##sem((__u8 *) ptr, new, _o_);	\
> +		_r_ =3D ia64_cmpxchg1_##sem((__u8 __force *) ptr, new, _o_);	\
>  		break;							\
>  									\
>  	case 2:								\
> -		_r_ =3D ia64_cmpxchg2_##sem((__u16 *) ptr, new, _o_);	\
> +		_r_ =3D ia64_cmpxchg2_##sem((__u16 __force *) ptr, new, _o_);	\
>  		break;							\
>  									\
>  	case 4:								\
> -		_r_ =3D ia64_cmpxchg4_##sem((__u32 *) ptr, new, _o_);	\
> +		_r_ =3D ia64_cmpxchg4_##sem((__u32 __force *) ptr, new, _o_);	\
>  		break;							\
>  									\
>  	case 8:								\
> -		_r_ =3D ia64_cmpxchg8_##sem((__u64 *) ptr, new, _o_);	\
> +		_r_ =3D ia64_cmpxchg8_##sem((__u64 __force *) ptr, new, _o_);	\
>  		break;							\
>  									\
>  	default:							\
>  		_r_ =3D ia64_cmpxchg_called_with_bad_pointer();		\
>  		break;							\
>  	}								\
> -	(__typeof__(old)) _r_;						\
> +	(__typeof__(old) __force) _r_;					\
>  })
> =20
>  #define cmpxchg_acq(ptr, o, n)	\
> --=20
> 2.36.1
>=20
