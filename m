From: Robin Holt <holt@sgi.com>
Date: Thu, 07 Aug 2008 21:30:53 +0000
Subject: Re: [RFC] Fix early access to per-cpu variables
Message-Id: <20080807213053.GK6824@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
In-Reply-To: <57C9024A16AD2D4C97DC78E552063EA3083844C8@orsmsx505.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I manually fixed up the patch to put the tabs back, applied it an
boot tested it with generic_defconfig on a 128p 32 node NUMA system.
How many other configs would you like tested?  Architecturally, this
machine covers most of what SGI ships.

Thanks,
Robin


On Thu, Aug 07, 2008 at 02:04:14PM -0700, Luck, Tony wrote:
> We've been fighting a long running battle with the use
> of per-cpu variables in early boot code on ia64. In
> current code accessing them before cpu_init() has a
> chance to initialize ar.k3 with the physical address
> of the per-cpu page results in the system hanging.
> This is the reason that CONFIG_PRINTK_TIME results in
> a kernel that does not boot.
> 
> This patch fixes this by allocating the memory for the
> per-cpu page in kernel .data segment and initializing
> ar.k3 to point to it[1] in head.S before any C code has
> the opportunity to access a per-cpu variable.
> 
> Life is a little complex because the SMP=n case uses the
> __phys_per_cpu_start copy of the per cpu variables directly.
> 
> Tested with tiger_defconfig and generic_defconfig kernels
> on Intel tiger system (to check both the contig.c and
> discontig.c allocations).  But I'd appreciate hearing
> whether this works on a real NUMA system.
> 
> -Tony
> 
> [1] ar.k3 actually points at the physical address of the
> *END* of the per-cpu page to make life easy for the MCA
> code to use it in assembly code.
> 
> ---
> 
> diff --git a/arch/ia64/kernel/head.S b/arch/ia64/kernel/head.S
> index 41c7129..ae650f1 100644
> --- a/arch/ia64/kernel/head.S
> +++ b/arch/ia64/kernel/head.S
> @@ -359,7 +359,18 @@ start_ap:
>         mov ar.rsc=0            // place RSE in enforced lazy mode
>         ;;
>         loadrs                  // clear the dirty partition
> -       mov IA64_KR(PER_CPU_DATA)=r0    // clear physical per-CPU base
> +       movl r19=__phys_per_cpu_start
> +#ifndef CONFIG_SMP
> +       mov r18=PERCPU_PAGE_SIZE
> +       ;;
> +       add r19=r19,r18
> +#endif
> +       ;;
> +       tpa r19=r19
> +       ;;
> +       .pred.rel.mutex isBP,isAP
> +(isBP) mov IA64_KR(PER_CPU_DATA)=r19   // per-CPU base for cpu0
> +(isAP) mov IA64_KR(PER_CPU_DATA)=r0    // clear physical per-CPU base
>         ;;
>         mov ar.bspstore=r2      // establish the new RSE stack
>         ;;
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index 593279f..c27d5b2 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -927,17 +927,19 @@ cpu_init (void)
>         if (smp_processor_id() = 0) {
>                 cpu_set(0, per_cpu(cpu_sibling_map, 0));
>                 cpu_set(0, cpu_core_map[0]);
> +       } else {
> +               /*
> +                * Set ar.k3 so that assembly code in MCA handler can compute
> +                * physical addresses of per cpu variables with a simple:
> +                *   phys = ar.k3 + &per_cpu_var
> +                * and the alt-dtlb-miss handler can set per-cpu mapping into
> +                * the TLB when needed. head.S already did this for cpu0.
> +                */
> +               ia64_set_kr(IA64_KR_PER_CPU_DATA,
> +                           ia64_tpa(cpu_data) - (long) __per_cpu_start);
>         }
>  #endif
> 
> -       /*
> -        * We set ar.k3 so that assembly code in MCA handler can compute
> -        * physical addresses of per cpu variables with a simple:
> -        *   phys = ar.k3 + &per_cpu_var
> -        */
> -       ia64_set_kr(IA64_KR_PER_CPU_DATA,
> -                   ia64_tpa(cpu_data) - (long) __per_cpu_start);
> -
>         get_max_cacheline_size();
> 
>         /*
> diff --git a/arch/ia64/kernel/vmlinux.lds.S b/arch/ia64/kernel/vmlinux.lds.S
> index 5a77206..de71da8 100644
> --- a/arch/ia64/kernel/vmlinux.lds.S
> +++ b/arch/ia64/kernel/vmlinux.lds.S
> @@ -215,6 +215,9 @@ SECTIONS
>    /* Per-cpu data: */
>    percpu : { } :percpu
>    . = ALIGN(PERCPU_PAGE_SIZE);
> +#ifdef CONFIG_SMP
> +  . = . + PERCPU_PAGE_SIZE;    /* cpu0 per-cpu space */
> +#endif
>    __phys_per_cpu_start = .;
>    .data.percpu PERCPU_ADDR : AT(__phys_per_cpu_start - LOAD_OFFSET)
>         {
> diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
> index 798bf98..35ae83b 100644
> --- a/arch/ia64/mm/contig.c
> +++ b/arch/ia64/mm/contig.c
> @@ -163,8 +163,15 @@ per_cpu_init (void)
>          * get_zeroed_page().
>          */
>         if (first_time) {
> +               void *cpu0_data = __phys_per_cpu_start - PERCPU_PAGE_SIZE;
> +
>                 first_time=0;
> -               for (cpu = 0; cpu < NR_CPUS; cpu++) {
> +
> +               memcpy(cpu0_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
> +               __per_cpu_offset[0] = (char *) cpu0_data - __per_cpu_start;
> +               per_cpu(local_per_cpu_offset, 0) = __per_cpu_offset[0];
> +
> +               for (cpu = 1; cpu < NR_CPUS; cpu++) {
>                         memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
>                         __per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
>                         cpu_data += PERCPU_PAGE_SIZE;
> @@ -177,7 +184,7 @@ per_cpu_init (void)
>  static inline void
>  alloc_per_cpu_data(void)
>  {
> -       cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
> +       cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS-1,
>                                    PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
>  }
>  #else
> diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
> index d83125e..7690710 100644
> --- a/arch/ia64/mm/discontig.c
> +++ b/arch/ia64/mm/discontig.c
> @@ -143,7 +143,13 @@ static void *per_cpu_node_setup(void *cpu_data, int node)
>         int cpu;
> 
>         for_each_possible_early_cpu(cpu) {
> -               if (node = node_cpuid[cpu].nid) {
> +               if (cpu = 0) {
> +                       void *cpu0_data = __phys_per_cpu_start - PERCPU_PAGE_SIZE;
> +                       memcpy(cpu0_data, __phys_per_cpu_start,
> +                              __per_cpu_end - __per_cpu_start);
> +                       __per_cpu_offset[cpu] = (char*)cpu0_data -
> +                               __per_cpu_start;
> +               } else if (node = node_cpuid[cpu].nid) {
>                         memcpy(__va(cpu_data), __phys_per_cpu_start,
>                                __per_cpu_end - __per_cpu_start);
>                         __per_cpu_offset[cpu] = (char*)__va(cpu_data) -
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

