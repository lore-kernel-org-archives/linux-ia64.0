From: john stultz <johnstul@us.ibm.com>
Date: Thu, 26 Apr 2007 21:18:21 +0000
Subject: Re: [PATCH 1/3] ia64: convert to use clocksource code
Message-Id: <1177622301.6031.16.camel@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
In-Reply-To: <20070426202632.23343.54944.sendpatchset@rambler.zko.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Keilty <peter.keilty@hp.com>
Cc: linux-ia64@vger.kernel.org, Eric Whitney <eric.whitney@hp.com>, linux-kernel@vger.kernel.org

On Thu, 2007-04-26 at 16:26 -0400, Peter Keilty wrote:
> From: Peter Keilty <peter.keilty@hp.com>
> 
> Initial ia64 conversion to the generic timekeeping/clocksource code.
> 
> Signed-off-by: Peter Keilty <peter.keilty@hp.com>
> Signed-off-by: John Stultz <johnstul@us.ibm.com>

Peter,
	Thanks so much for pushing this on! I suspect this patch needs to be
updated a touch, as I'm not sure if it still compiles in light of recent
changes...


> diff --git a/arch/ia64/kernel/cyclone.c b/arch/ia64/kernel/cyclone.c
> index e00b215..280383b 100644
> --- a/arch/ia64/kernel/cyclone.c
> +++ b/arch/ia64/kernel/cyclone.c
> @@ -3,6 +3,7 @@ #include <linux/smp.h>
>  #include <linux/time.h>
>  #include <linux/errno.h>
>  #include <linux/timex.h>
> +#include <linux/clocksource.h>
>  #include <asm/io.h>
> 
>  /* IBM Summit (EXA) Cyclone counter code*/
> @@ -18,13 +19,21 @@ void __init cyclone_setup(void)
>  	use_cyclone = 1;
>  }
> 
> +static void __iomem *cyclone_mc_ptr;
> 
> -struct time_interpolator cyclone_interpolator = {
> -	.source =	TIME_SOURCE_MMIO64,
> -	.shift =	16,
> -	.frequency =	CYCLONE_TIMER_FREQ,
> -	.drift =	-100,
> -	.mask =		(1LL << 40) - 1
> +static cycle_t read_cyclone(void)
> +{
> +	return (cycle_t)readq((void __iomem *)cyclone_mc_ptr);
> +}
> +
> +static struct clocksource clocksource_cyclone = {
> +        .name           = "cyclone",
> +        .rating         = 300,
> +        .read           = read_cyclone,
> +        .mask           = (1LL << 40) - 1,

Daniel Walker pointed out to me on IRC that CLOCKSOURCE_MASK() should
probably be used here.

> +        .mult           = 0, /*to be caluclated*/
> +        .shift          = 16,
> +        .is_continuous  = 1,

.is_continuous no longer exists. 

You want to use:
.flags = CLOCK_SOURCE_IS_CONTINUOUS 

This holds for all the clocksources introduced.


thanks
-john


