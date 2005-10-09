From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Sun, 09 Oct 2005 00:38:00 +0000
Subject: RE: [PATCH] 2.6.14-rc3: wider use of for_each_cpu_mask() in arch/ia64
Message-Id: <B05667366EE6204181EABE9C1B1C0EB5086EED40@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
In-Reply-To: <20051008174331.27208.6062.sendpatchset@tomahawk.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

hawkes@sgi.com wrote on Saturday, October 08, 2005 10:44 AM
> --- linux.orig/arch/ia64/kernel/module.c	2005-08-28
16:41:01.000000000 -0700
> +++ linux/arch/ia64/kernel/module.c	2005-10-07 14:34:09.000000000
-0700
> @@ -948,7 +948,8 @@
>  {
>  	unsigned int i;
>  	for (i = 0; i < NR_CPUS; i++)
> -		if (cpu_possible(i))
> -			memcpy(pcpudst + __per_cpu_offset[i], src,
size);
> +	for_each_cpu_mask(i, cpu_possible_map) {
> +		memcpy(pcpudst + __per_cpu_offset[i], src, size);
> +	}
>  }
>  #endif /* CONFIG_SMP */

Looks like you forgot to delete the for (i=0 ...) clause.


> --- linux.orig/arch/ia64/kernel/smpboot.c	2005-08-28
16:41:01.000000000 -0700
> +++ linux/arch/ia64/kernel/smpboot.c	2005-10-07 14:36:51.000000000
-0700
> @@ -695,8 +695,9 @@
>  	 */
>  
>  	for (cpu = 0; cpu < NR_CPUS; cpu++)
> -		if (cpu_online(cpu))
> -			bogosum += cpu_data(cpu)->loops_per_jiffy;
> +	for_each_cpu_mask(cpu, cpu_online_map) {
> +		bogosum += cpu_data(cpu)->loops_per_jiffy;
> +	}

Same here.
