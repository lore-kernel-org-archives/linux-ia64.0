From: Simon Horman <horms@verge.net.au>
Date: Tue, 30 Oct 2007 01:40:11 +0000
Subject: Re: [PATCH 3/9] ia64: VIRT_CPU_ACCOUNTING (accurate cpu time accounting)
Message-Id: <20071030014010.GB5361@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <4714BE38.60807@jp.fujitsu.com>
In-Reply-To: <4714BE38.60807@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Oct 16, 2007 at 10:35:52PM +0900, Hidetoshi Seto wrote:
> > [3/9] ia64_cputime_to_nsec.patch
> 
> We need to define the type of cputime_t.
> It is clear that the unit should be better than msec.
> IBM arches defined it as usec.
> 
> On ia64, since the value of ar.itc is source of sched_clock(),
> there are enough parameters to convert cycles to nsecs.
> 
> Then, how long time we can save in u64?
> 
> 　0x 1 0000 0000 0000 0000 in hex
> 　18446744073 709 551 616 in decimal
> 　if in nsec, it will overflow after 213503 days, 584 years.
> 　if in usec, x1000 above.
> 
> It seems enough even in nsec.
> 
> So I practically make it in nsec.
> If there is situation which this definition is not acceptable,
> it would be better to have an option to switch the unit between
> nsec and usec.
> 
> Thanks,
> H.Seto
> 
> Signed-off-by: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
> 
> ---
>  arch/ia64/ia32/elfcore32.h |    5 +++
>  include/asm-ia64/cputime.h |   64 +++++++++++++++++++++++++++++----------------
>  2 files changed, 47 insertions(+), 22 deletions(-)
> 
> Index: linux-2.6.23/include/asm-ia64/cputime.h
> =================================> --- linux-2.6.23.orig/include/asm-ia64/cputime.h
> +++ linux-2.6.23/include/asm-ia64/cputime.h
> @@ -7,6 +7,10 @@
>  #ifndef __IA64_CPUTIME_H
>  #define __IA64_CPUTIME_H
> 
> +/*
> + * If we have CONFIG_VIRT_CPU_ACCOUNTING, we measure cpu time in nsec.
> + * Otherwise we measure cpu time in jiffies using the generic definitions.
> + */
>  #ifndef CONFIG_VIRT_CPU_ACCOUNTING
>  #include <asm-generic/cputime.h>
>  #else
> @@ -36,47 +40,63 @@
>  #define cputime_to_cputime64(__ct)	(__ct)
> 
>  /*
> - * Convert cputime <-> jiffies
> + * Convert cputime <-> jiffies (HZ)
>   */
> -#define cputime_to_jiffies(__ct)	(__ct)
> -#define jiffies_to_cputime(__jif)	(__jif)
> -#define cputime64_to_jiffies64(__ct)	(__ct)
> -#define jiffies64_to_cputime64(__jif)	(__jif)
> +#define cputime_to_jiffies(__ct)	((__ct) * HZ / NSEC_PER_SEC)
> +#define jiffies_to_cputime(__jif)	((__jif) * NSEC_PER_SEC / HZ)
> +#define cputime64_to_jiffies64(__ct)	((__ct) * HZ / NSEC_PER_SEC)
> +#define jiffies64_to_cputime64(__jif)	((__jif) * NSEC_PER_SEC / HZ)

It looks like cputime64_to_jiffies64 and cputime_to_jiffies will
overflow at (((2^64 -1) / HZ) + 1) ns. In the case where HZ is 1000,
this means it will overflow at (584/1000) years or about 213 days.
Similarly for cputime_to_clock_t(). Is this a problem?

> 
>  /*
>   * Convert cputime <-> milliseconds
>   */
> -#define cputime_to_msecs(__ct)		jiffies_to_msecs(__ct)
> -#define msecs_to_cputime(__msecs)	msecs_to_jiffies(__msecs)
> +#define cputime_to_msecs(__ct)		((__ct) / NSEC_PER_MSEC)
> +#define msecs_to_cputime(__msecs)	((__msecs) * NSEC_PER_MSEC)
> 
>  /*
>   * Convert cputime <-> seconds
>   */
> -#define cputime_to_secs(__ct)		((__ct) / HZ)
> -#define secs_to_cputime(__secs)		((__secs) * HZ)
> -
> -/*
> - * Convert cputime <-> timespec
> - */
> -#define timespec_to_cputime(__val)	timespec_to_jiffies(__val)
> -#define cputime_to_timespec(__ct,__val)	jiffies_to_timespec(__ct,__val)
> +#define cputime_to_secs(__ct)		((__ct) / NSEC_PER_SEC)
> +#define secs_to_cputime(__secs)		((__secs) * NSEC_PER_SEC)
> 
>  /*
> - * Convert cputime <-> timeval
> + * Convert cputime <-> timespec (nsec)
>   */
> -#define timeval_to_cputime(__val)	timeval_to_jiffies(__val)
> -#define cputime_to_timeval(__ct,__val)	jiffies_to_timeval(__ct,__val)
> +static inline cputime_t timespec_to_cputime(struct timespec *val)
> +{
> +	cputime_t ret = val->tv_sec * NSEC_PER_SEC;
> +	return (ret + val->tv_nsec);
> +}
> +static inline void cputime_to_timespec(const cputime_t ct, struct timespec *val)
> +{
> +	val->tv_sec  = ct / NSEC_PER_SEC;
> +	val->tv_nsec = ct % NSEC_PER_SEC;
> +}
> +
> +/*
> + * Convert cputime <-> timeval (msec)
> + */
> +static inline cputime_t timeval_to_cputime(struct timeval *val)
> +{
> +	cputime_t ret = val->tv_sec * NSEC_PER_SEC;
> +	return (ret + val->tv_usec * NSEC_PER_USEC);
> +}
> +static inline void cputime_to_timeval(const cputime_t ct, struct timeval *val)
> +{
> +	val->tv_sec = ct / NSEC_PER_SEC;
> +	val->tv_usec = (ct % NSEC_PER_SEC) / NSEC_PER_USEC;
> +}
> 
>  /*
> - * Convert cputime <-> clock
> + * Convert cputime <-> clock (USER_HZ)
>   */
> -#define cputime_to_clock_t(__ct)	jiffies_to_clock_t(__ct)
> -#define clock_t_to_cputime(__x)		clock_t_to_jiffies(__x)
> +#define cputime_to_clock_t(__ct)	((__ct) * USER_HZ / NSEC_PER_SEC)
> +#define clock_t_to_cputime(__x)		((__x) * NSEC_PER_SEC / USER_HZ)
> 
>  /*
>   * Convert cputime64 to clock.
>   */
> -#define cputime64_to_clock_t(__ct)      jiffies_64_to_clock_t(__ct)
> +#define cputime64_to_clock_t(__ct)      cputime_to_clock_t((cputime_t)__ct)
> 
>  #endif /* CONFIG_VIRT_CPU_ACCOUNTING */
>  #endif /* __IA64_CPUTIME_H */
> Index: linux-2.6.23/arch/ia64/ia32/elfcore32.h
> =================================> --- linux-2.6.23.orig/arch/ia64/ia32/elfcore32.h
> +++ linux-2.6.23/arch/ia64/ia32/elfcore32.h
> @@ -30,7 +30,12 @@
>  	int	si_errno;			/* errno */
>  };
> 
> +#ifdef CONFIG_VIRT_CPU_ACCOUNTING
> +#define cputime_to_timeval(a,b) \
> +	do { (b)->tv_usec = 0; (b)->tv_sec = (a)/NSEC_PER_SEC; } while(0)
> +#else
>  #define jiffies_to_timeval(a,b) do { (b)->tv_usec = 0; (b)->tv_sec = (a)/HZ; }while(0)
> +#endif
> 
>  struct elf_prstatus
>  {
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

