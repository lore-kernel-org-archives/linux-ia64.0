From: Mike Travis <travis@sgi.com>
Date: Wed, 30 Jan 2008 18:20:24 +0000
Subject: Re: x86/non-x86: percpu, node ids, apic ids x86.git fixup
Message-Id: <47A0BFE8.4020903@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200801301414.m0UEEgCC006371@hera.kernel.org> <Pine.LNX.4.64.0801301622460.11859@vixen.sonytel.be> <47A09F8A.3000309@sgi.com> <20080130161036.GA12293@elte.hu> <1FE6DD409037234FAB833C420AA843EC757C72@orsmsx424.amr.corp.intel.com> <20080130180623.GA24881@elte.hu>
In-Reply-To: <20080130180623.GA24881@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: "Luck, Tony" <tony.luck@intel.com>, Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Kernel Development <linux-kernel@vger.kernel.org>, Linux/PPC Development <linuxppc-dev@ozlabs.org>, linux-ia64@vger.kernel.org, sparclinux@vger.kernel.org

Ingo Molnar wrote:
> * Luck, Tony <tony.luck@intel.com> wrote:
> 
>>> thanks! Sorry about that: we cross-built on ARM but not on SMP 
>>> non-x86 platforms so this dependency/breakage went unnoticed.
>> Yes ... all ia64 builds (UP and SMP) are broken at the moment. Please 
>> Cc: me with the fixup patch.
> 
> Could you check the patch below? With this applied to latest -git, ia64 
> buils fine for me in a cross-compiling environment. (but i dont know 
> whether it boots ...)
> 
> 	Ingo

This patch is from a different patch set (aka "zero-based" patch).  That
one will be updated and resubmitted soon...

Thanks,
Mike

> 
> ----------------->
> Subject: generic: percpu infrastructure to rebase the per cpu area to zero
> From: travis@sgi.com
> 
>     * Support an option
> 
> 	CONFIG_HAVE_ZERO_BASED_PER_CPU
> 
>       that makes offsets for per cpu variables to start at zero.
> 
>       If a percpu area starts at zero then:
> 
> 	-  We do not need RELOC_HIDE anymore
> 
> 	-  Provides for the future capability of architectures providing
> 	   a per cpu allocator that returns offsets instead of pointers.
> 	   The offsets would be independent of the processor so that
> 	   address calculations can be done in a processor independent way.
> 	   Per cpu instructions can then add the processor specific offset
> 	   at the last minute possibly in an atomic instruction.
> 
>       The data the linker provides is different for zero based percpu segments:
> 
> 	__per_cpu_load	-> The address at which the percpu area was loaded
> 	__per_cpu_size	-> The length of the per cpu area
> 
>     * Removes the &__per_cpu_x in lockdep. The __per_cpu_x are already
>       pointers. There is no need to take the address.
> 
>     * Changes generic setup_per_cpu_areas to allocate per_cpu space in
>       node local memory.  This requires a generic early_cpu_to_node function.
> 
> Signed-off-by: Mike Travis <travis@sgi.com>
> Reviewed-by: Christoph Lameter <clameter@sgi.com>
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> ---
>  arch/ia64/Kconfig                     |    2 -
>  arch/ia64/kernel/module.c             |   11 --------
>  arch/powerpc/Kconfig                  |    2 -
>  arch/sparc64/mm/init.c                |    5 ++++
>  include/asm-alpha/topology.h          |    1 
>  include/asm-generic/percpu.h          |    7 ++++-
>  include/asm-generic/sections.h        |   10 ++++++++
>  include/asm-generic/topology.h        |    3 ++
>  include/asm-generic/vmlinux.lds.h     |   15 ++++++++++++
>  include/asm-ia64/percpu.h             |   29 +++++------------------
>  include/asm-ia64/topology.h           |    1 
>  include/asm-mips/mach-ip27/topology.h |    1 
>  include/asm-powerpc/percpu.h          |   29 +----------------------
>  include/asm-powerpc/topology.h        |    1 
>  include/asm-s390/percpu.h             |   42 +++++++---------------------------
>  include/asm-sparc64/percpu.h          |   22 ++---------------
>  init/main.c                           |   18 ++++++++------
>  kernel/lockdep.c                      |    4 +--
>  18 files changed, 78 insertions(+), 125 deletions(-)
> 
> Index: linux-x86.q/arch/ia64/Kconfig
> =================================> --- linux-x86.q.orig/arch/ia64/Kconfig
> +++ linux-x86.q/arch/ia64/Kconfig
> @@ -80,7 +80,7 @@ config GENERIC_TIME_VSYSCALL
>  	bool
>  	default y
>  
> -config ARCH_SETS_UP_PER_CPU_AREA
> +config HAVE_SETUP_PER_CPU_AREA
>  	def_bool y
>  
>  config DMI
> Index: linux-x86.q/arch/ia64/kernel/module.c
> =================================> --- linux-x86.q.orig/arch/ia64/kernel/module.c
> +++ linux-x86.q/arch/ia64/kernel/module.c
> @@ -940,14 +940,3 @@ module_arch_cleanup (struct module *mod)
>  	if (mod->arch.core_unw_table)
>  		unw_remove_unwind_table(mod->arch.core_unw_table);
>  }
> -
> -#ifdef CONFIG_SMP
> -void
> -percpu_modcopy (void *pcpudst, const void *src, unsigned long size)
> -{
> -	unsigned int i;
> -	for_each_possible_cpu(i) {
> -		memcpy(pcpudst + per_cpu_offset(i), src, size);
> -	}
> -}
> -#endif /* CONFIG_SMP */
> Index: linux-x86.q/arch/powerpc/Kconfig
> =================================> --- linux-x86.q.orig/arch/powerpc/Kconfig
> +++ linux-x86.q/arch/powerpc/Kconfig
> @@ -42,7 +42,7 @@ config GENERIC_HARDIRQS
>  	bool
>  	default y
>  
> -config ARCH_SETS_UP_PER_CPU_AREA
> +config HAVE_SETUP_PER_CPU_AREA
>  	def_bool PPC64
>  
>  config IRQ_PER_CPU
> Index: linux-x86.q/arch/sparc64/mm/init.c
> =================================> --- linux-x86.q.orig/arch/sparc64/mm/init.c
> +++ linux-x86.q/arch/sparc64/mm/init.c
> @@ -1328,6 +1328,11 @@ pgd_t swapper_pg_dir[2048];
>  static void sun4u_pgprot_init(void);
>  static void sun4v_pgprot_init(void);
>  
> +/* Dummy function */
> +void __init setup_per_cpu_areas(void)
> +{
> +}
> +
>  void __init paging_init(void)
>  {
>  	unsigned long end_pfn, pages_avail, shift, phys_base;
> Index: linux-x86.q/include/asm-alpha/topology.h
> =================================> --- linux-x86.q.orig/include/asm-alpha/topology.h
> +++ linux-x86.q/include/asm-alpha/topology.h
> @@ -6,6 +6,7 @@
>  #include <asm/machvec.h>
>  
>  #ifdef CONFIG_NUMA
> +#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
>  static inline int cpu_to_node(int cpu)
>  {
>  	int node;
> Index: linux-x86.q/include/asm-generic/percpu.h
> =================================> --- linux-x86.q.orig/include/asm-generic/percpu.h
> +++ linux-x86.q/include/asm-generic/percpu.h
> @@ -43,7 +43,12 @@ extern unsigned long __per_cpu_offset[NR
>   * Only S390 provides its own means of moving the pointer.
>   */
>  #ifndef SHIFT_PERCPU_PTR
> -#define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
> +# ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
> +#  define SHIFT_PERCPU_PTR(__p, __offset) \
> +	((__typeof(__p))(((void *)(__p)) + (__offset)))
> +# else
> +#  define SHIFT_PERCPU_PTR(__p, __offset)	RELOC_HIDE((__p), (__offset))
> +# endif /* CONFIG_HAVE_ZERO_BASED_PER_CPU */
>  #endif
>  
>  /*
> Index: linux-x86.q/include/asm-generic/sections.h
> =================================> --- linux-x86.q.orig/include/asm-generic/sections.h
> +++ linux-x86.q/include/asm-generic/sections.h
> @@ -11,7 +11,17 @@ extern char _sinittext[], _einittext[];
>  extern char _sextratext[] __attribute__((weak));
>  extern char _eextratext[] __attribute__((weak));
>  extern char _end[];
> +#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
> +extern char __per_cpu_load[];
> +extern char ____per_cpu_size[];
> +#define __per_cpu_size ((unsigned long)&____per_cpu_size)
> +#define __per_cpu_start ((char *)0)
> +#define __per_cpu_end ((char *)__per_cpu_size)
> +#else
>  extern char __per_cpu_start[], __per_cpu_end[];
> +#define __per_cpu_load __per_cpu_start
> +#define __per_cpu_size (__per_cpu_end - __per_cpu_start)
> +#endif
>  extern char __kprobes_text_start[], __kprobes_text_end[];
>  extern char __initdata_begin[], __initdata_end[];
>  extern char __start_rodata[], __end_rodata[];
> Index: linux-x86.q/include/asm-generic/topology.h
> =================================> --- linux-x86.q.orig/include/asm-generic/topology.h
> +++ linux-x86.q/include/asm-generic/topology.h
> @@ -32,6 +32,9 @@
>  #ifndef cpu_to_node
>  #define cpu_to_node(cpu)	(0)
>  #endif
> +#ifndef early_cpu_to_node
> +#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
> +#endif
>  #ifndef parent_node
>  #define parent_node(node)	(0)
>  #endif
> Index: linux-x86.q/include/asm-generic/vmlinux.lds.h
> =================================> --- linux-x86.q.orig/include/asm-generic/vmlinux.lds.h
> +++ linux-x86.q/include/asm-generic/vmlinux.lds.h
> @@ -341,6 +341,20 @@
>    	*(.initcall7.init)						\
>    	*(.initcall7s.init)
>  
> +#ifdef CONFIG_HAVE_ZERO_BASED_PER_CPU
> +#define PERCPU(align)							\
> +	. = ALIGN(align);						\
> +	percpu : { } :percpu						\
> +	__per_cpu_load = .;						\
> +	.data.percpu 0 : AT(__per_cpu_load - LOAD_OFFSET) {		\
> +		*(.data.percpu.first)					\
> +		*(.data.percpu)						\
> +		*(.data.percpu.shared_aligned)				\
> +		____per_cpu_size = .;					\
> +	}								\
> +	. = __per_cpu_load + ____per_cpu_size;				\
> +	data : { } :data
> +#else
>  #define PERCPU(align)							\
>  	. = ALIGN(align);						\
>  	__per_cpu_start = .;						\
> @@ -349,3 +363,4 @@
>  		*(.data.percpu.shared_aligned)				\
>  	}								\
>  	__per_cpu_end = .;
> +#endif
> Index: linux-x86.q/include/asm-ia64/percpu.h
> =================================> --- linux-x86.q.orig/include/asm-ia64/percpu.h
> +++ linux-x86.q/include/asm-ia64/percpu.h
> @@ -19,34 +19,14 @@
>  # define PER_CPU_ATTRIBUTES	__attribute__((__model__ (__small__)))
>  #endif
>  
> -#define DECLARE_PER_CPU(type, name)				\
> -	extern PER_CPU_ATTRIBUTES __typeof__(type) per_cpu__##name
> -
> -/*
> - * Pretty much a literal copy of asm-generic/percpu.h, except that percpu_modcopy() is an
> - * external routine, to avoid include-hell.
> - */
>  #ifdef CONFIG_SMP
>  
> -extern unsigned long __per_cpu_offset[NR_CPUS];
> -#define per_cpu_offset(x) (__per_cpu_offset[x])
> -
> -/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
> -DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
> +#define __my_cpu_offset	__ia64_per_cpu_var(local_per_cpu_offset)
>  
> -#define per_cpu(var, cpu)  (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset[cpu]))
> -#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
> -#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __ia64_per_cpu_var(local_per_cpu_offset)))
> -
> -extern void percpu_modcopy(void *pcpudst, const void *src, unsigned long size);
> -extern void setup_per_cpu_areas (void);
>  extern void *per_cpu_init(void);
>  
>  #else /* ! SMP */
>  
> -#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
> -#define __get_cpu_var(var)			per_cpu__##var
> -#define __raw_get_cpu_var(var)			per_cpu__##var
>  #define per_cpu_init()				(__phys_per_cpu_start)
>  
>  #endif	/* SMP */
> @@ -57,7 +37,12 @@ extern void *per_cpu_init(void);
>   * On the positive side, using __ia64_per_cpu_var() instead of __get_cpu_var() is slightly
>   * more efficient.
>   */
> -#define __ia64_per_cpu_var(var)	(per_cpu__##var)
> +#define __ia64_per_cpu_var(var)	per_cpu__##var
> +
> +#include <asm-generic/percpu.h>
> +
> +/* Equal to __per_cpu_offset[smp_processor_id()], but faster to access: */
> +DECLARE_PER_CPU(unsigned long, local_per_cpu_offset);
>  
>  #endif /* !__ASSEMBLY__ */
>  
> Index: linux-x86.q/include/asm-ia64/topology.h
> =================================> --- linux-x86.q.orig/include/asm-ia64/topology.h
> +++ linux-x86.q/include/asm-ia64/topology.h
> @@ -31,6 +31,7 @@
>   * Returns the number of the node containing CPU 'cpu'
>   */
>  #define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
> +#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
>  
>  /*
>   * Returns a bitmask of CPUs on Node 'node'.
> Index: linux-x86.q/include/asm-mips/mach-ip27/topology.h
> =================================> --- linux-x86.q.orig/include/asm-mips/mach-ip27/topology.h
> +++ linux-x86.q/include/asm-mips/mach-ip27/topology.h
> @@ -23,6 +23,7 @@ struct cpuinfo_ip27 {
>  extern struct cpuinfo_ip27 sn_cpu_info[NR_CPUS];
>  
>  #define cpu_to_node(cpu)	(sn_cpu_info[(cpu)].p_nodeid)
> +#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
>  #define parent_node(node)	(node)
>  #define node_to_cpumask(node)	(hub_data(node)->h_cpus)
>  #define node_to_first_cpu(node)	(first_cpu(node_to_cpumask(node)))
> Index: linux-x86.q/include/asm-powerpc/percpu.h
> =================================> --- linux-x86.q.orig/include/asm-powerpc/percpu.h
> +++ linux-x86.q/include/asm-powerpc/percpu.h
> @@ -16,34 +16,9 @@
>  #define __my_cpu_offset() get_paca()->data_offset
>  #define per_cpu_offset(x) (__per_cpu_offset(x))
>  
> -/* var is in discarded region: offset to particular copy we want */
> -#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
> -#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __my_cpu_offset()))
> -#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, local_paca->data_offset))
> +#endif /* CONFIG_SMP */
> +#endif /* __powerpc64__ */
>  
> -/* A macro to avoid #include hell... */
> -#define percpu_modcopy(pcpudst, src, size)			\
> -do {								\
> -	unsigned int __i;					\
> -	for_each_possible_cpu(__i)				\
> -		memcpy((pcpudst)+__per_cpu_offset(__i),		\
> -		       (src), (size));				\
> -} while (0)
> -
> -extern void setup_per_cpu_areas(void);
> -
> -#else /* ! SMP */
> -
> -#define per_cpu(var, cpu)			(*((void)(cpu), &per_cpu__##var))
> -#define __get_cpu_var(var)			per_cpu__##var
> -#define __raw_get_cpu_var(var)			per_cpu__##var
> -
> -#endif	/* SMP */
> -
> -#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
> -
> -#else
>  #include <asm-generic/percpu.h>
> -#endif
>  
>  #endif /* _ASM_POWERPC_PERCPU_H_ */
> Index: linux-x86.q/include/asm-powerpc/topology.h
> =================================> --- linux-x86.q.orig/include/asm-powerpc/topology.h
> +++ linux-x86.q/include/asm-powerpc/topology.h
> @@ -15,6 +15,7 @@ static inline int cpu_to_node(int cpu)
>  	return numa_cpu_lookup_table[cpu];
>  }
>  
> +#define early_cpu_to_node(cpu)	cpu_to_node(cpu)
>  #define parent_node(node)	(node)
>  
>  static inline cpumask_t node_to_cpumask(int node)
> Index: linux-x86.q/include/asm-s390/percpu.h
> =================================> --- linux-x86.q.orig/include/asm-s390/percpu.h
> +++ linux-x86.q/include/asm-s390/percpu.h
> @@ -13,49 +13,25 @@
>   */
>  #if defined(__s390x__) && defined(MODULE)
>  
> -#define __reloc_hide(var,offset) (*({			\
> +#define SHIFT_PERCPU_PTR(ptr,offset) (({			\
>  	extern int simple_identifier_##var(void);	\
>  	unsigned long *__ptr;				\
> -	asm ( "larl %0,per_cpu__"#var"@GOTENT"		\
> -	    : "=a" (__ptr) : "X" (per_cpu__##var) );	\
> -	(typeof(&per_cpu__##var))((*__ptr) + (offset));	}))
> +	asm ( "larl %0, %1@GOTENT"		\
> +	    : "=a" (__ptr) : "X" (ptr) );		\
> +	(typeof(ptr))((*__ptr) + (offset));	}))
>  
>  #else
>  
> -#define __reloc_hide(var, offset) (*({				\
> +#define SHIFT_PERCPU_PTR(ptr, offset) (({				\
>  	extern int simple_identifier_##var(void);		\
>  	unsigned long __ptr;					\
> -	asm ( "" : "=a" (__ptr) : "0" (&per_cpu__##var) );	\
> -	(typeof(&per_cpu__##var)) (__ptr + (offset)); }))
> +	asm ( "" : "=a" (__ptr) : "0" (ptr) );			\
> +	(typeof(ptr)) (__ptr + (offset)); }))
>  
>  #endif
>  
> -#ifdef CONFIG_SMP
> +#define __my_cpu_offset S390_lowcore.percpu_offset
>  
> -extern unsigned long __per_cpu_offset[NR_CPUS];
> -
> -#define __get_cpu_var(var) __reloc_hide(var,S390_lowcore.percpu_offset)
> -#define __raw_get_cpu_var(var) __reloc_hide(var,S390_lowcore.percpu_offset)
> -#define per_cpu(var,cpu) __reloc_hide(var,__per_cpu_offset[cpu])
> -#define per_cpu_offset(x) (__per_cpu_offset[x])
> -
> -/* A macro to avoid #include hell... */
> -#define percpu_modcopy(pcpudst, src, size)			\
> -do {								\
> -	unsigned int __i;					\
> -	for_each_possible_cpu(__i)				\
> -		memcpy((pcpudst)+__per_cpu_offset[__i],		\
> -		       (src), (size));				\
> -} while (0)
> -
> -#else /* ! SMP */
> -
> -#define __get_cpu_var(var) __reloc_hide(var,0)
> -#define __raw_get_cpu_var(var) __reloc_hide(var,0)
> -#define per_cpu(var,cpu) __reloc_hide(var,0)
> -
> -#endif /* SMP */
> -
> -#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
> +#include <asm-generic/percpu.h>
>  
>  #endif /* __ARCH_S390_PERCPU__ */
> Index: linux-x86.q/include/asm-sparc64/percpu.h
> =================================> --- linux-x86.q.orig/include/asm-sparc64/percpu.h
> +++ linux-x86.q/include/asm-sparc64/percpu.h
> @@ -7,7 +7,6 @@ register unsigned long __local_per_cpu_o
>  
>  #ifdef CONFIG_SMP
>  
> -#define setup_per_cpu_areas()			do { } while (0)
>  extern void real_setup_per_cpu_areas(void);
>  
>  extern unsigned long __per_cpu_base;
> @@ -16,29 +15,14 @@ extern unsigned long __per_cpu_shift;
>  	(__per_cpu_base + ((unsigned long)(__cpu) << __per_cpu_shift))
>  #define per_cpu_offset(x) (__per_cpu_offset(x))
>  
> -/* var is in discarded region: offset to particular copy we want */
> -#define per_cpu(var, cpu) (*RELOC_HIDE(&per_cpu__##var, __per_cpu_offset(cpu)))
> -#define __get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __local_per_cpu_offset))
> -#define __raw_get_cpu_var(var) (*RELOC_HIDE(&per_cpu__##var, __local_per_cpu_offset))
> -
> -/* A macro to avoid #include hell... */
> -#define percpu_modcopy(pcpudst, src, size)			\
> -do {								\
> -	unsigned int __i;					\
> -	for_each_possible_cpu(__i)				\
> -		memcpy((pcpudst)+__per_cpu_offset(__i),		\
> -		       (src), (size));				\
> -} while (0)
> +#define __my_cpu_offset __local_per_cpu_offset
> +
>  #else /* ! SMP */
>  
>  #define real_setup_per_cpu_areas()		do { } while (0)
>  
> -#define per_cpu(var, cpu)			(*((void)cpu, &per_cpu__##var))
> -#define __get_cpu_var(var)			per_cpu__##var
> -#define __raw_get_cpu_var(var)			per_cpu__##var
> -
>  #endif	/* SMP */
>  
> -#define DECLARE_PER_CPU(type, name) extern __typeof__(type) per_cpu__##name
> +#include <asm-generic/percpu.h>
>  
>  #endif /* __ARCH_SPARC64_PERCPU__ */
> Index: linux-x86.q/init/main.c
> =================================> --- linux-x86.q.orig/init/main.c
> +++ linux-x86.q/init/main.c
> @@ -374,18 +374,20 @@ EXPORT_SYMBOL(__per_cpu_offset);
>  
>  static void __init setup_per_cpu_areas(void)
>  {
> -	unsigned long size, i;
> -	char *ptr;
> -	unsigned long nr_possible_cpus = num_possible_cpus();
> +	unsigned long size;
> +	int cpu;
>  
>  	/* Copy section for each CPU (we discard the original) */
>  	size = ALIGN(PERCPU_ENOUGH_ROOM, PAGE_SIZE);
> -	ptr = alloc_bootmem_pages(size * nr_possible_cpus);
>  
> -	for_each_possible_cpu(i) {
> -		__per_cpu_offset[i] = ptr - __per_cpu_start;
> -		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
> -		ptr += size;
> +	printk(KERN_INFO "(generic)PERCPU: Allocating %lu bytes of per cpu data\n", size);
> +
> +	for_each_possible_cpu(cpu) {
> +		char *ptr = alloc_bootmem_pages_node(
> +				NODE_DATA(early_cpu_to_node(cpu)), size);
> +
> +		__per_cpu_offset[cpu] = ptr - __per_cpu_start;
> +		memcpy(ptr, __per_cpu_load, __per_cpu_size);
>  	}
>  }
>  #endif /* CONFIG_HAVE_SETUP_PER_CPU_AREA */
> Index: linux-x86.q/kernel/lockdep.c
> =================================> --- linux-x86.q.orig/kernel/lockdep.c
> +++ linux-x86.q/kernel/lockdep.c
> @@ -609,8 +609,8 @@ static int static_obj(void *obj)
>  	 * percpu var?
>  	 */
>  	for_each_possible_cpu(i) {
> -		start = (unsigned long) &__per_cpu_start + per_cpu_offset(i);
> -		end   = (unsigned long) &__per_cpu_start + PERCPU_ENOUGH_ROOM
> +		start = (unsigned long) __per_cpu_start + per_cpu_offset(i);
> +		end   = (unsigned long) __per_cpu_start + PERCPU_ENOUGH_ROOM
>  					+ per_cpu_offset(i);
>  
>  		if ((addr >= start) && (addr < end))

