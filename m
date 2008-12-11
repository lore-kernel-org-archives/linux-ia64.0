From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 11 Dec 2008 04:09:17 +0000
Subject: Re: [linux-next][PATCH] cpumask:cpumask_of_node-ia64 fix
Message-Id: <20081211130833.4FFA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081210164659.9ebb8158.sfr@canb.auug.org.au> <20081211105721.4FEE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20081211105721.4FEE.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64 <linux-ia64@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, "Luck, Tony" <tony.luck@intel.com>, Rusty Russell <rusty@rustcorp.com.au>, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>

Oops, sorry.

I forgot cc to linux-ia64.


> => Subject: [PATCH] cpumask:cpumask_of_node-ia64 fix
> Impact: bug fix
> 
> commit 07c636deede53ff3e96d54df0ece2c838e61951f introduce new CPU mask API and change cpu_mask variable type.
> 
> -----------------------------------------------
> -               cpumask_t cpu_mask;
> +               const struct cpumask *cpu_mask;
> --------------------------------------------------
> 
> 
> However, its change is incomplete. in build time, compiler output following type mismatch warnings.
> 
>   arch/ia64/kernel/iosapic.c:708: warning: passing argument 2 of '__cpu_clear' from incompatible pointer type
>   arch/ia64/kernel/iosapic.c:711: warning: passing argument 1 of '__cpus_weight' from incompatible pointer type
>   arch/ia64/kernel/iosapic.c:719: warning: passing argument 1 of '__first_cpu' from incompatible pointer type
>   arch/ia64/kernel/iosapic.c:720: warning: passing argument 2 of '__next_cpu' from incompatible pointer type
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: "Luck, Tony" <tony.luck@intel.com>
> CC: Rusty Russell <rusty@rustcorp.com.au>
> ---
>  arch/ia64/kernel/iosapic.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
> 
> Index: b/arch/ia64/kernel/iosapic.c
> =================================> --- a/arch/ia64/kernel/iosapic.c
> +++ b/arch/ia64/kernel/iosapic.c
> @@ -695,7 +695,7 @@ get_target_cpu (unsigned int gsi, int ir
>  #ifdef CONFIG_NUMA
>  	{
>  		int num_cpus, cpu_index, iosapic_index, numa_cpu, i = 0;
> -		const struct cpumask *cpu_mask;
> +		struct cpumask *cpu_mask;
>  
>  		iosapic_index = find_iosapic(gsi);
>  		if (iosapic_index < 0 ||
> @@ -705,10 +705,10 @@ get_target_cpu (unsigned int gsi, int ir
>  		cpu_mask = cpumask_of_node(iosapic_lists[iosapic_index].node);
>  		for_each_cpu_and(numa_cpu, cpu_mask, &domain) {
>  			if (!cpu_online(numa_cpu))
> -				cpu_clear(numa_cpu, cpu_mask);
> +				cpu_clear(numa_cpu, *cpu_mask);
>  		}
>  
> -		num_cpus = cpus_weight(cpu_mask);
> +		num_cpus = cpus_weight(*cpu_mask);
>  
>  		if (!num_cpus)
>  			goto skip_numa_setup;
> @@ -716,8 +716,8 @@ get_target_cpu (unsigned int gsi, int ir
>  		/* Use irq assignment to distribute across cpus in node */
>  		cpu_index = irq % num_cpus;
>  
> -		for (numa_cpu = first_cpu(cpu_mask) ; i < cpu_index ; i++)
> -			numa_cpu = next_cpu(numa_cpu, cpu_mask);
> +		for (numa_cpu = first_cpu(*cpu_mask) ; i < cpu_index ; i++)
> +			numa_cpu = next_cpu(numa_cpu, *cpu_mask);
>  
>  		if (numa_cpu != NR_CPUS)
>  			return cpu_physical_id(numa_cpu);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



