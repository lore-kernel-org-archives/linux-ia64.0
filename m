From: Preeti U Murthy <preeti@linux.vnet.ibm.com>
Date: Thu, 06 Mar 2014 02:32:11 +0000
Subject: Re: [PATCH 1/2] sched: Remove unused mc_capable() and smt_capable()
Message-Id: <5317DB5B.60109@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140304210621.16893.8772.stgit@bhelgaas-glaptop.roam.corp.google.com> <20140304210737.16893.54289.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140304210737.16893.54289.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-mips@linux-mips.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org

On 03/05/2014 02:37 AM, Bjorn Helgaas wrote:
> Remove mc_capable() and smt_capable().  Neither is used.
> 
> Both were added by 5c45bf279d37 ("sched: mc/smt power savings sched
> policy").  Uses of both were removed by 8e7fbcbc22c1 ("sched: Remove stale
> power aware scheduling remnants and dysfunctional knobs").
> 
> Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
> ---
>  arch/arm/include/asm/topology.h      |    3 ---
>  arch/ia64/include/asm/topology.h     |    1 -
>  arch/mips/include/asm/topology.h     |    4 ----
>  arch/powerpc/include/asm/topology.h  |    1 -
>  arch/sparc/include/asm/topology_64.h |    2 --
>  arch/x86/include/asm/topology.h      |    6 ------
>  6 files changed, 17 deletions(-)
> 
> diff --git a/arch/arm/include/asm/topology.h b/arch/arm/include/asm/topology.h
> index 58b8b84adcd2..2fe85fff5cca 100644
> --- a/arch/arm/include/asm/topology.h
> +++ b/arch/arm/include/asm/topology.h
> @@ -20,9 +20,6 @@ extern struct cputopo_arm cpu_topology[NR_CPUS];
>  #define topology_core_cpumask(cpu)	(&cpu_topology[cpu].core_sibling)
>  #define topology_thread_cpumask(cpu)	(&cpu_topology[cpu].thread_sibling)
>  
> -#define mc_capable()	(cpu_topology[0].socket_id != -1)
> -#define smt_capable()	(cpu_topology[0].thread_id != -1)
> -
>  void init_cpu_topology(void);
>  void store_cpu_topology(unsigned int cpuid);
>  const struct cpumask *cpu_coregroup_mask(int cpu);
> diff --git a/arch/ia64/include/asm/topology.h b/arch/ia64/include/asm/topology.h
> index a2496e449b75..5cb55a1e606b 100644
> --- a/arch/ia64/include/asm/topology.h
> +++ b/arch/ia64/include/asm/topology.h
> @@ -77,7 +77,6 @@ void build_cpu_to_node_map(void);
>  #define topology_core_id(cpu)			(cpu_data(cpu)->core_id)
>  #define topology_core_cpumask(cpu)		(&cpu_core_map[cpu])
>  #define topology_thread_cpumask(cpu)		(&per_cpu(cpu_sibling_map, cpu))
> -#define smt_capable() 				(smp_num_siblings > 1)
>  #endif
>  
>  extern void arch_fix_phys_package_id(int num, u32 slot);
> diff --git a/arch/mips/include/asm/topology.h b/arch/mips/include/asm/topology.h
> index 12609a17dc8b..20ea4859c822 100644
> --- a/arch/mips/include/asm/topology.h
> +++ b/arch/mips/include/asm/topology.h
> @@ -10,8 +10,4 @@
>  
>  #include <topology.h>
>  
> -#ifdef CONFIG_SMP
> -#define smt_capable()	(smp_num_siblings > 1)
> -#endif
> -
>  #endif /* __ASM_TOPOLOGY_H */
> diff --git a/arch/powerpc/include/asm/topology.h b/arch/powerpc/include/asm/topology.h
> index d0b5fca6b077..c9202151079f 100644
> --- a/arch/powerpc/include/asm/topology.h
> +++ b/arch/powerpc/include/asm/topology.h
> @@ -99,7 +99,6 @@ static inline int prrn_is_enabled(void)
>  
>  #ifdef CONFIG_SMP
>  #include <asm/cputable.h>
> -#define smt_capable()		(cpu_has_feature(CPU_FTR_SMT))
>  
>  #ifdef CONFIG_PPC64
>  #include <asm/smp.h>
> diff --git a/arch/sparc/include/asm/topology_64.h b/arch/sparc/include/asm/topology_64.h
> index 1754390a426f..a2d10fc64faf 100644
> --- a/arch/sparc/include/asm/topology_64.h
> +++ b/arch/sparc/include/asm/topology_64.h
> @@ -42,8 +42,6 @@ static inline int pcibus_to_node(struct pci_bus *pbus)
>  #define topology_core_id(cpu)			(cpu_data(cpu).core_id)
>  #define topology_core_cpumask(cpu)		(&cpu_core_map[cpu])
>  #define topology_thread_cpumask(cpu)		(&per_cpu(cpu_sibling_map, cpu))
> -#define mc_capable()				(sparc64_multi_core)
> -#define smt_capable()				(sparc64_multi_core)
>  #endif /* CONFIG_SMP */
>  
>  extern cpumask_t cpu_core_map[NR_CPUS];
> diff --git a/arch/x86/include/asm/topology.h b/arch/x86/include/asm/topology.h
> index d35f24e231cd..9bcc724cafdd 100644
> --- a/arch/x86/include/asm/topology.h
> +++ b/arch/x86/include/asm/topology.h
> @@ -133,12 +133,6 @@ static inline void arch_fix_phys_package_id(int num, u32 slot)
>  struct pci_bus;
>  void x86_pci_root_bus_resources(int bus, struct list_head *resources);
>  
> -#ifdef CONFIG_SMP
> -#define mc_capable()	((boot_cpu_data.x86_max_cores > 1) && \
> -			(cpumask_weight(cpu_core_mask(0)) != nr_cpu_ids))
> -#define smt_capable()			(smp_num_siblings > 1)
> -#endif
> -
>  #ifdef CONFIG_NUMA
>  extern int get_mp_bus_to_node(int busnum);
>  extern void set_mp_bus_to_node(int busnum, int node);
> 

Reviewed-by: Preeti U Murthy <preeti@linux.vnet.ibm.com>
> _______________________________________________
> Linuxppc-dev mailing list
> Linuxppc-dev@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/linuxppc-dev
> 

