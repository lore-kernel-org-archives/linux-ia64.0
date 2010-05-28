From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Date: Fri, 28 May 2010 20:58:09 +0000
Subject: Re: [git pull] Fix ia64 build breakage
Message-Id: <1275080289.9702.58.camel@useless.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
References: <4bff019827164eea63@agluck-desktop.sc.intel.com>
In-Reply-To: <4bff019827164eea63@agluck-desktop.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: linux-ia64@vger.kernel.org

On Thu, 2010-05-27 at 16:34 -0700, Luck, Tony wrote:
> Hi Linus,
> 
> please pull from:
> 
> 	git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6.git release
> 
> This will update the files shown below.
> 
> Thanks!
> 
> -Tony
> 
>  arch/ia64/kernel/smpboot.c |    4 ++++
>  arch/ia64/mm/numa.c        |   17 +++++++++++++++++
>  2 files changed, 21 insertions(+), 0 deletions(-)
> 
> Tony Luck (1):
>       [IA64] Fix build breakage
> 
> Andrew: These changes appear to have gone to Linus without passing
> through linux-next (where I'd have caught the breakage earlier).
> Did they slip through a crack?
> 
> ---
> 
> commit 4ec37de89d8c758ee8115e0e64b3f994910789ee
> Author: Tony Luck <tony.luck@intel.com>
> Date:   Thu May 27 15:35:13 2010 -0700
> 
>     [IA64] Fix build breakage
>     
>     In commit 0ac0c0d0f837c499afd02a802f9cf52d3027fa3b
>     cpusets: randomize node rotor used in cpuset_mem_spread_node()
>     
>     Jack Steiner fixed a problem with too many small tasks being
>     assigned to node 0. Copy his code to ia64 to avoid build error.
>     
>         arch/ia64/kernel/smpboot.c:641: error: ‘cpu_to_node_map’ undeclared (first use in this function)
>     
>     In commit 3bccd996276b108c138e8176793a26ecef54d573
>     numa: ia64: use generic percpu var numa_node_id() implementation
>     
>     Lee Schermerhorn added some set_numa_node() calls - but these
>     only work on CONFIG_NUMA=y configurations. Surround the calls
>     with #ifdef CONFIG_NUMA

Tony:

Can I get your .config?  I thought I tested ia64 !NUMA, but I see now
that when I edit the .config and 'make silentoldconfig', IA64_GENERIC
just selects NUMA again.  Even 'make allnoconfig' on ia64 generates
a .config with NUMA=y.  I tried changing IA64_GENERIC to IA64_HP_ZX1
that does not select NUMA, but the build fails elsewhere because
NODE_DATA is apparently not defined for !NUMA.  So, I'd like to get
your .config to duplicate the build error that you're fixing here.

I had intended that asm-generic/topology.h define the stubs for the
missing calls when !NUMA as it does for several other functions and
avoid the ifdefs in the code.  Apparently I just dreamed that I did
that...

I'll send an update patch when I get it figured out.

Thanks,
Lee

>     
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
> index 518e876..6a1380e 100644
> --- a/arch/ia64/kernel/smpboot.c
> +++ b/arch/ia64/kernel/smpboot.c
> @@ -390,11 +390,13 @@ smp_callin (void)
>  
>  	fix_b0_for_bsp();
>  
> +#ifdef CONFIG_NUMA
>  	/*
>  	 * numa_node_id() works after this.
>  	 */
>  	set_numa_node(cpu_to_node_map[cpuid]);
>  	set_numa_mem(local_memory_node(cpu_to_node_map[cpuid]));
> +#endif
>  
>  	ipi_call_lock_irq();
>  	spin_lock(&vector_lock);
> @@ -638,7 +640,9 @@ void __devinit smp_prepare_boot_cpu(void)
>  {
>  	cpu_set(smp_processor_id(), cpu_online_map);
>  	cpu_set(smp_processor_id(), cpu_callin_map);
> +#ifdef CONFIG_NUMA
>  	set_numa_node(cpu_to_node_map[smp_processor_id()]);
> +#endif
>  	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
>  	paravirt_post_smp_prepare_boot_cpu();
>  }
> diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
> index 3efea7d..2437718 100644
> --- a/arch/ia64/mm/numa.c
> +++ b/arch/ia64/mm/numa.c
> @@ -17,6 +17,7 @@
>  #include <linux/init.h>
>  #include <linux/bootmem.h>
>  #include <linux/module.h>
> +#include <linux/random.h>
>  #include <asm/mmzone.h>
>  #include <asm/numa.h>
>  
> @@ -50,6 +51,22 @@ paddr_to_nid(unsigned long paddr)
>  	return (i < num_node_memblks) ? node_memblk[i].nid : (num_node_memblks ? -1 : 0);
>  }
>  
> +/*
> + * Return the bit number of a random bit set in the nodemask.
> + *   (returns -1 if nodemask is empty)
> + */
> +int __node_random(const nodemask_t *maskp)
> +{
> +	int w, bit = -1;
> +
> +	w = nodes_weight(*maskp);
> +	if (w)
> +		bit = bitmap_ord_to_pos(maskp->bits,
> +			get_random_int() % w, MAX_NUMNODES);
> +	return bit;
> +}
> +EXPORT_SYMBOL(__node_random);
> +
>  #if defined(CONFIG_SPARSEMEM) && defined(CONFIG_NUMA)
>  /*
>   * Because of holes evaluate on section limits.

