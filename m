From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 08 May 2011 22:15:39 +0000
Subject: Re: [PATCH] atomic: add *_dec_not_zero
Message-Id: <1304892939.2513.503.camel@pasglop>
List-Id: <linux-ia64.vger.kernel.org>
References: <1304458235-28473-1-git-send-email-sven@narfation.org>
In-Reply-To: <1304458235-28473-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Cc: linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org, linux-m68k-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-m32r-rQhvJZKUsGBRYuoOT4C5/9i2O/JbrIOy@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-cris-kernel-VrBV9hrLPhE@public.gmane.org, linux-parisc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Chris Metcalf <cmetcalf-kv+TWInifGbQT0dZR+AlfA@public.gmane.org>, David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-am33-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-alpha-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sparclinux-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org

On Tue, 2011-05-03 at 23:30 +0200, Sven Eckelmann wrote:
> Introduce an *_dec_not_zero operation.  Make this a special case of
> *_add_unless because batman-adv uses atomic_dec_not_zero in different
> places like re-broadcast queue or aggregation queue management. There
> are other non-final patches which may also want to use this macro.

For arch/powerpc:

Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

(Sorry for catching up late)

Cheers,
Ben.

> diff --git a/arch/powerpc/include/asm/atomic.h b/arch/powerpc/include/asm/atomic.h
> index b8f152e..906f49a 100644
> --- a/arch/powerpc/include/asm/atomic.h
> +++ b/arch/powerpc/include/asm/atomic.h
> @@ -213,6 +213,7 @@ static __inline__ int atomic_add_unless(atomic_t *v, int a, int u)
>  }
>  
>  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> +#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
>  
>  #define atomic_sub_and_test(a, v)	(atomic_sub_return((a), (v)) = 0)
>  #define atomic_dec_and_test(v)		(atomic_dec_return((v)) = 0)
> @@ -469,6 +470,7 @@ static __inline__ int atomic64_add_unless(atomic64_t *v, long a, long u)
>  }
>  
>  #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
> +#define atomic64_dec_not_zero(v) atomic64_add_unless((v), -1, 0)
>  
>  #else  /* __powerpc64__ */
>  #include <asm-generic/atomic64.h>
> diff --git a/arch/powerpc/include/asm/local.h b/arch/powerpc/include/asm/local.h
> index c2410af..3d4c58a 100644
> --- a/arch/powerpc/include/asm/local.h
> +++ b/arch/powerpc/include/asm/local.h
> @@ -134,6 +134,7 @@ static __inline__ int local_add_unless(local_t *l, long a, long u)
>  }
>  
>  #define local_inc_not_zero(l) local_add_unless((l), 1, 0)
> +#define local_dec_not_zero(l) local_add_unless((l), -1, 0)
>  
>  #define local_sub_and_test(a, l)	(local_sub_return((a), (l)) = 0)
>  #define local_dec_and_test(l)		(local_dec_return((l)) = 0)



