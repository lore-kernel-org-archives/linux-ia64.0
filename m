From: Jack Steiner <steiner@sgi.com>
Date: Mon, 24 Nov 2003 22:01:31 +0000
Subject: Re: udelay() & preemption & drifty ITCs
Message-Id: <marc-linux-ia64-106971154602602@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106955914311295@msgid-missing>
In-Reply-To: <marc-linux-ia64-106955914311295@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, Nov 24, 2003 at 01:25:15PM -0800, Jesse Barnes wrote:
> On Mon, Nov 24, 2003 at 01:00:43PM -0800, Jesse Barnes wrote:
> > On Sun, Nov 23, 2003 at 02:39:29PM -0800, Jesse Barnes wrote:
> > > Yep, it appears so.  I guess we need a 'preempt_disable/disable()' pair
> > > around the itc access.  Of course, callers under a spinlock are already
> > > protected, so maybe exposure to this problem isn't that large?
> > 
> > Here's the patch.  Compiles and boots, but I haven't made a test module
> > that illustrates this bug, so I haven't tested it.
> 
> Here's one that actually patches the affected routine.  Same caveat
> applies.

I dislike disabling preemption in udelay(). Although most delays are
short, there are some delays that are 100s or 1000s of usec long. Users running
soft-realtime really dont want preemption disabled unnecessarily.

On platforms with synchronized clocks, disabling preemption is not required. 

Even on platforms with drifty ITCs, preemption in udelay() is ok as long 
as migration is disabled. AFAIK, there is no standard API for disabling 
migration aside from saving/changing/restoring the cpus_allowed mask.




> 
> Jesse
> 
> diff -Nru a/include/asm-ia64/delay.h b/include/asm-ia64/delay.h
> --- a/include/asm-ia64/delay.h	Mon Nov 24 14:19:19 2003
> +++ b/include/asm-ia64/delay.h	Mon Nov 24 14:19:19 2003
> @@ -15,6 +15,7 @@
>  #include <linux/config.h>
>  #include <linux/kernel.h>
>  #include <linux/sched.h>
> +#include <linux/preempt.h>
>  #include <linux/compiler.h>
>  
>  #include <asm/intrinsics.h>
> @@ -81,11 +82,14 @@
>  static __inline__ void
>  udelay (unsigned long usecs)
>  {
> -	unsigned long start = ia64_get_itc();
> -	unsigned long cycles = usecs*local_cpu_data->cyc_per_usec;
> +	unsigned long start, cycles;
>  
> +	preempt_disable();
> +	start = ia64_get_itc();
> +	cycles = usecs*local_cpu_data->cyc_per_usec;
>  	while (ia64_get_itc() - start < cycles)
>  		/* skip */;
> +	preempt_enable();
>  }
>  
>  #endif /* _ASM_IA64_DELAY_H */

-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


