From: Heiko Carstens <heiko.carstens@de.ibm.com>
Date: Mon, 23 May 2011 07:27:40 +0000
Subject: Re: [PATCHv2] atomic: add *_dec_not_zero
Message-Id: <20110523072740.GA2377@osiris.boeblingen.de.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1304458235-28473-1-git-send-email-sven@narfation.org>
 <1305748194-23351-1-git-send-email-sven@narfation.org>
In-Reply-To: <1305748194-23351-1-git-send-email-sven@narfation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sven Eckelmann <sven@narfation.org>
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Hirokazu Takata <takata@linux-m32r.org>, linux-m32r@ml.linux-m32r.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux390@de.ibm.com, linux-s390@vger.kernel.org, Paul Mundt <lethal@linux-sh.org>, linux-sh@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, linux-arch@vger.kernel.org

On Wed, May 18, 2011 at 09:49:54PM +0200, Sven Eckelmann wrote:
> Introduce an *_dec_not_zero operation.  Make this a special case of
> *_add_unless because batman-adv uses atomic_dec_not_zero in different
> places like re-broadcast queue or aggregation queue management. There
> are other non-final patches which may also want to use this macro.
[...]
> ---
> This is actually the same patch as before, but I am still waiting for
> some (N)Acks for ia64, m32r, s390, sh and generic.
[...]
> diff --git a/arch/s390/include/asm/atomic.h b/arch/s390/include/asm/atomic.h
> index d9db138..09972c3 100644
> --- a/arch/s390/include/asm/atomic.h
> +++ b/arch/s390/include/asm/atomic.h
> @@ -109,6 +109,7 @@ static inline int atomic_add_unless(atomic_t *v, int a, int u)
>  }
> 
>  #define atomic_inc_not_zero(v) atomic_add_unless((v), 1, 0)
> +#define atomic_dec_not_zero(v) atomic_add_unless((v), -1, 0)
> 
>  #undef __CS_LOOP
> 
> @@ -326,6 +327,7 @@ static inline long long atomic64_dec_if_positive(atomic64_t *v)
>  #define atomic64_dec_return(_v)		atomic64_sub_return(1, _v)
>  #define atomic64_dec_and_test(_v)	(atomic64_sub_return(1, _v) = 0)
>  #define atomic64_inc_not_zero(v)	atomic64_add_unless((v), 1, 0)
> +#define atomic64_dec_not_zero(v)	atomic64_add_unless((v), -1, 0)
> 
>  #define smp_mb__before_atomic_dec()	smp_mb()
>  #define smp_mb__after_atomic_dec()	smp_mb()

Acked-by: Heiko Carstens <heiko.carstens@de.ibm.com>
