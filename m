From: jbarnes@sgi.com (Jesse Barnes)
Date: Mon, 12 Jan 2004 19:11:54 +0000
Subject: Re: [PATCH] Updating our sn code in 2.6] - Patch 028
Message-Id: <20040112191154.GD11990@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040109234608.18009a2a.akpm@osdl.org>
In-Reply-To: <20040109234608.18009a2a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

2.6.1-mm2 compiles with NR_CPUSQ2 (and for sn2 btw, thanks), but I
haven't actually booted it on a >256p machine since they're still
somewhat rare :).  Do you think you'll do an official 2.6.2 release
before Linus gets back with this stuff in it?

Thanks,
Jesse

On Fri, Jan 09, 2004 at 11:46:08PM -0800, Andrew Morton wrote:
> Paul Jackson <pj@sgi.com> wrote:
> >
> > Rusty, responding to Andrew, on a cpumask failure seen by Jesse:
> > > Probably.  Paul Jackson acked them though, so I'm a little surprised.
> > 
> > Jesse or Rusty - could you send me the earlier parts of this
> > email thread?  I don't see it on lkml or ia64 email list.
> > 
> > I'd like to see what I missed in Rusty's patch.
> > 
> > Though I am less surprised than Rusty that I missed something;
> > I was in an easy going frame of mind when I read it.  I do
> > tougher reviews when I am more irritated and untrusting.
> > 
> 
> Is OK, looks like Rusty was missing a couple of mk_cpumask_const()
> invokations in a -mm patch.  I'm currently testing this:
> 
> --- 25/include/linux/cpumask.h~make-for_each_cpu-iterator-more-friendly-fix-fix	Sat Jan 10 02:15:29 2004
> +++ 25-akpm/include/linux/cpumask.h	Sat Jan 10 02:16:02 2004
> @@ -14,10 +14,10 @@ extern cpumask_t cpu_possible_map;
>  #define cpu_online(cpu)			cpu_isset(cpu, cpu_online_map)
>  #define cpu_possible(cpu)		cpu_isset(cpu, cpu_possible_map)
>  
> -#define for_each_cpu_mask(cpu, mask)			\
> -	for (cpu = first_cpu_const(mask);		\
> -		cpu < NR_CPUS;				\
> -		cpu = next_cpu_const(cpu, mask))
> +#define for_each_cpu_mask(cpu, mask)					\
> +	for (cpu = first_cpu_const(mk_cpumask_const(mask));		\
> +		cpu < NR_CPUS;						\
> +		cpu = next_cpu_const(cpu, mk_cpumask_const(mask)))
>  
>  #define for_each_cpu(cpu) for_each_cpu_mask(cpu, cpu_possible_map)
>  #define for_each_online_cpu(cpu) for_each_cpu_mask(cpu, cpu_online_map)
> 
> _
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
