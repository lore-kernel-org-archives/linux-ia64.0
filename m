From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 12 Aug 2003 23:34:45 +0000
Subject: Re: Discontig patch for 2.4.21
Message-Id: <marc-linux-ia64-106073158319638@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I applied this patch for 2.4.  There were a couple conflicts (for
instance, some of the non-ia64 ACPI stuff is already in 2.4), so I
wouldn't be too surprised if I messed something up, so please
look things over.

Bjorn


On Friday 01 August 2003 11:38 am, Jack Steiner wrote:
> Attached is the patch for discontig memory for 2.4.21. This patch
> has been tested on the ZX1 & NEC platforms & appears to work ok. It 
> also works on SN2 but there are additional patches (unrelated to 
> discontig) that at still needed in 2.4.21.
> 
> 
> Jesse barnes is pushing the patch into 2.6 & is still doing
> minor cleanup. Once he finishes, I'll update this patch with the
> cleanup that he has added to his patch. However, as far as I can tell,
> this patch is ok.
> 
> 
> 
> diff -Naur linux_base/arch/ia64/config.in linux/arch/ia64/config.in
> --- linux_base/arch/ia64/config.in	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/config.in	Mon Jul 28 10:19:02 2003
> @@ -66,6 +66,10 @@
>  fi
>  
>  if [ "$CONFIG_IA64_GENERIC" = "y" -o "$CONFIG_IA64_DIG" = "y" -o "$CONFIG_IA64_HP_ZX1" = "y" ]; then
> +	bool '  Enable NUMA support' CONFIG_NUMA
> +	if [ "$CONFIG_NUMA" = "y" ]; then
> +	  define_bool CONFIG_DISCONTIGMEM y
> +	fi
>  	bool '  Enable IA-64 Machine Check Abort' CONFIG_IA64_MCA
>  	define_bool CONFIG_PM y
>  fi
> diff -Naur linux_base/arch/ia64/kernel/acpi.c linux/arch/ia64/kernel/acpi.c
> --- linux_base/arch/ia64/kernel/acpi.c	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/kernel/acpi.c	Tue Jul 29 10:12:40 2003
> @@ -8,6 +8,9 @@
>   *  Copyright (C) 2000 Intel Corp.
>   *  Copyright (C) 2000,2001 J.I. Lee <jung-ik.lee@intel.com>
>   *  Copyright (C) 2001 Paul Diefenbaugh <paul.s.diefenbaugh@intel.com>
> + *  Copyright (C) 2001 Jenna Hall <jenna.s.hall@intel.com>
> + *  Copyright (C) 2001 Takayoshi Kochi <t-kouchi@cq.jp.nec.com>
> + *  Copyright (C) 2002 Erich Focht <efocht@ess.nec.de>
>   *
>   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>   *
> @@ -38,11 +41,14 @@
>  #include <linux/irq.h>
>  #include <linux/acpi.h>
>  #include <linux/efi.h>
> +#include <linux/mm.h>
> +#include <linux/mmzone.h>
>  #include <asm/io.h>
>  #include <asm/iosapic.h>
>  #include <asm/machvec.h>
>  #include <asm/page.h>
>  #include <asm/system.h>
> +#include <asm/numa.h>
>  
>  
>  #define PREFIX			"ACPI: "
> @@ -179,7 +185,6 @@
>  	acpi_status status;
>  	u8 *data;
>  	u32 length;
> -	int i;
>  
>  	status = acpi_find_vendor_resource(obj, &hp_ccsr_descriptor, &data, &length);
>  
> @@ -437,6 +442,194 @@
>  }
>  
>  
> +#ifdef CONFIG_ACPI_NUMA
> +
> +#define PXM_FLAG_LEN ((MAX_PXM_DOMAINS + 1)/32)
> +
> +static int __initdata srat_num_cpus;			/* number of cpus */
> +static u32 __initdata pxm_flag[PXM_FLAG_LEN];
> +#define pxm_bit_set(bit)	(set_bit(bit,(void *)pxm_flag))
> +#define pxm_bit_test(bit)	(test_bit(bit,(void *)pxm_flag))
> +/* maps to convert between proximity domain and logical node ID */
> +int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
> +int __initdata nid_to_pxm_map[NR_NODES];
> +struct acpi_table_slit __initdata *slit_table;
> +
> +/*
> + * ACPI 2.0 SLIT (System Locality Information Table)
> + * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
> + */
> +void __init
> +acpi_numa_slit_init (struct acpi_table_slit *slit)
> +{
> +	u32 len;
> +
> +	len = sizeof(struct acpi_table_header) + 8
> +		+ slit->localities * slit->localities;
> +	if (slit->header.length != len) {
> +		printk("KERN_INFO ACPI 2.0 SLIT: size mismatch: %d expected, %d actual\n",
> +		      len, slit->header.length);
> +		memset(numa_slit, 10, sizeof(numa_slit));
> +		return;
> +	}
> +	slit_table = slit;
> +}
> +
> +void __init
> +acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *pa)
> +{
> +	/* record this node in proximity bitmap */
> +	pxm_bit_set(pa->proximity_domain);
> +
> +	node_cpuid[srat_num_cpus].phys_id = (pa->apic_id << 8) | (pa->lsapic_eid);
> +	/* nid should be overridden as logical node id later */
> +	node_cpuid[srat_num_cpus].nid = pa->proximity_domain;
> +	srat_num_cpus++;
> +}
> +
> +void __init
> +acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *ma)
> +{
> +	unsigned long paddr, size, hole_size, min_hole_size;
> +	u8 pxm;
> +	struct node_memblk_s *p, *q, *pend;
> +
> +	pxm = ma->proximity_domain;
> +
> +	/* fill node memory chunk structure */
> +	paddr = ma->base_addr_hi;
> +	paddr = (paddr << 32) | ma->base_addr_lo;
> +	size = ma->length_hi;
> +	size = (size << 32) | ma->length_lo;
> +
> +	if (num_memblks >= NR_MEMBLKS) {
> +		printk(KERN_ERR "Too many mem chunks in SRAT. Ignoring %ld MBytes at %lx\n",
> +			size/(1024*1024), paddr);
> +		return;
> +	}
> +
> +	/* Ignore disabled entries */
> +	if (!ma->flags.enabled)
> +		return;
> +
> +	/*
> +	 * When the chunk is not the first one in the node, check distance
> +	 * from the other chunks. When the hole is too huge ignore the chunk.
> +	 * This restriction should be removed when multiple chunks per node
> +	 * is supported.
> +	 */
> +	pend = &node_memblk[num_memblks];
> +	min_hole_size = 0;
> +	for (p = &node_memblk[0]; p < pend; p++) {
> +		if (p->nid != pxm)
> +			continue;
> +		if (p->start_paddr < paddr)
> +			hole_size = paddr - (p->start_paddr + p->size);
> +		else
> +			hole_size = p->start_paddr - (paddr + size);
> +
> +		if (!min_hole_size || hole_size < min_hole_size)
> +			min_hole_size = hole_size;
> +	}
> +
> +#if 0	/* test */
> +	if (min_hole_size) {
> +		if (min_hole_size > size) {
> +			printk(KERN_ERR "Too huge memory hole. Ignoring %ld MBytes at %lx\n",
> +				size/(1024*1024), paddr);
> +			return;
> +		}
> +	}
> +#endif
> +
> +	/* record this node in proximity bitmap */
> +	pxm_bit_set(pxm);
> +
> +	/* Insertion sort based on base address */
> +	pend = &node_memblk[num_memblks];
> +	for (p = &node_memblk[0]; p < pend; p++) {
> +		if (paddr < p->start_paddr)
> +			break;
> +	}
> +	if (p < pend) {
> +		for (q = pend; q >= p; q--)
> +			*(q + 1) = *q;
> +	}
> +	p->start_paddr = paddr;
> +	p->size = size;
> +	p->nid = pxm;
> +	num_memblks++;
> +}
> +
> +void __init
> +acpi_numa_arch_fixup(void)
> +{
> +	int i, j, node_from, node_to;
> +
> +	if (srat_num_cpus = 0) {
> +		node_cpuid[0].phys_id = hard_smp_processor_id();
> +		return;
> +	}
> +
> +	/* calculate total number of nodes in system from PXM bitmap */
> +	numnodes = 0;		/* init total nodes in system */
> +
> +	memset(pxm_to_nid_map, -1, sizeof(pxm_to_nid_map));
> +	memset(nid_to_pxm_map, -1, sizeof(nid_to_pxm_map));
> +	for (i = 0; i < MAX_PXM_DOMAINS; i++) {
> +		if (pxm_bit_test(i)) {
> +			pxm_to_nid_map[i] = numnodes;
> +			nid_to_pxm_map[numnodes++] = i;
> +		}
> +	}
> +
> +	/* set logical node id in memory chunk structure */
> +	for (i = 0; i < num_memblks; i++)
> +		node_memblk[i].nid = pxm_to_nid_map[node_memblk[i].nid];
> +
> +	/* assign memory bank numbers for each chunk on each node */
> +	for (i = 0; i < numnodes; i++) {
> +		int bank;
> +
> +		bank = 0;
> +		for (j = 0; j < num_memblks; j++)
> +			if (node_memblk[j].nid = i)
> +				node_memblk[j].bank = bank++;
> +	}
> +
> +	/* set logical node id in cpu structure */
> +	for (i = 0; i < srat_num_cpus; i++)
> +		node_cpuid[i].nid = pxm_to_nid_map[node_cpuid[i].nid];
> +
> +	printk(KERN_INFO "Number of logical nodes in system = %d\n", numnodes);
> +	printk(KERN_INFO "Number of memory chunks in system = %d\n", num_memblks);
> +
> +	if (!slit_table) return;
> +	memset(numa_slit, -1, sizeof(numa_slit));
> +	for (i=0; i<slit_table->localities; i++) {
> +		if (!pxm_bit_test(i))
> +			continue;
> +		node_from = pxm_to_nid_map[i];
> +		for (j=0; j<slit_table->localities; j++) {
> +			if (!pxm_bit_test(j))
> +				continue;
> +			node_to = pxm_to_nid_map[j];
> +			node_distance(node_from, node_to) = 
> +				slit_table->entry[i*slit_table->localities + j];
> +		}
> +	}
> +
> +#ifdef SLIT_DEBUG
> +	printk(KERN_DEBUG "ACPI 2.0 SLIT locality table:\n");
> +	for (i = 0; i < numnodes; i++) {
> +		for (j = 0; j < numnodes; j++)
> +			printk(KERN_DEBUG "%03d ", node_distance(i,j));
> +		printk("\n");
> +	}
> +#endif
> +}
> +#endif /* CONFIG_ACPI_NUMA */
> +
>  static int __init
>  acpi_parse_fadt (unsigned long phys_addr, unsigned long size)
>  {
> @@ -487,12 +680,6 @@
>  int __init
>  acpi_boot_init (char *cmdline)
>  {
> -	int result;
> -
> -	/* Initialize the ACPI boot-time table parser */
> -	result = acpi_table_init(cmdline);
> -	if (result)
> -		return result;
>  
>  	/*
>  	 * MADT
> @@ -556,6 +743,22 @@
>  		available_cpus = 1; /* We've got at least one of these, no? */
>  	}
>  	smp_boot_data.cpu_count = total_cpus;
> +	smp_build_cpu_map();
> +
> +# ifdef CONFIG_NUMA
> +	/* If the platform did not have an SRAT table, initialize the
> +	 * node_cpuid table from the smp_boot_data array. All cpus
> +	 * will be on node 0.
> +	 */
> +	if (srat_num_cpus = 0) {
> +		int cpu, i=1;
> +		for (cpu=0; cpu<smp_boot_data.cpu_count; cpu++)
> +			if (smp_boot_data.cpu_phys_id[cpu] != hard_smp_processor_id())
> +				node_cpuid[i++].phys_id = smp_boot_data.cpu_phys_id[cpu];
> +	}
> +	build_cpu_to_node_map();
> +# endif
> +
>  #endif
>  	/* Make boot-up look pretty */
>  	printk(KERN_INFO "%d CPUs available, %d CPUs total\n", available_cpus, total_cpus);
> diff -Naur linux_base/arch/ia64/kernel/setup.c linux/arch/ia64/kernel/setup.c
> --- linux_base/arch/ia64/kernel/setup.c	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/kernel/setup.c	Tue Jul 29 15:29:42 2003
> @@ -40,6 +40,8 @@
>  #include <asm/system.h>
>  #include <asm/mca.h>
>  #include <asm/smp.h>
> +#include <asm/pgtable.h>
> +#include <asm/pgalloc.h>
>  #include <asm/tlb.h>
>  
>  #ifdef CONFIG_BLK_DEV_RAM
> @@ -56,7 +58,7 @@
>  extern char _end;
>  
>  #ifdef CONFIG_NUMA
> - struct cpuinfo_ia64 *boot_cpu_data;
> + struct cpuinfo_ia64 *_cpu_data[NR_CPUS];
>  #else
>   struct cpuinfo_ia64 _cpu_data[NR_CPUS] __attribute__ ((section ("__special_page_section")));
>   mmu_gather_t mmu_gathers[NR_CPUS];
> @@ -99,6 +101,7 @@
>  static struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
>  static int num_rsvd_regions;
>  
> +#ifndef CONFIG_DISCONTIGMEM
>  static unsigned long bootmap_start; /* physical address where the bootmem map is located */
>  
>  static int
> @@ -111,18 +114,74 @@
>  		*max_pfn = pfn;
>  	return 0;
>  }
> +#endif /* !CONFIG_DISCONTIGMEM */
>  
>  #define IGNORE_PFN0	1	/* XXX fix me: ignore pfn 0 until TLB miss handler is updated... */
>  
> +#ifdef CONFIG_DISCONTIGMEM
>  /*
> - * Free available memory based on the primitive map created from
> - * the boot parameters. This routine does not assume the incoming
> - * segments are sorted.
> + * efi_memmap_walk() knows nothing about layout of memory across nodes. Find
> + * out to which node a block of memory belongs.  Ignore memory that we cannot
> + * identify, and split blocks that run across multiple nodes.
> + *
> + * Take this opportunity to round the start address up and the end address
> + * down to page boundaries.
>   */
> +void
> +call_pernode_memory (unsigned long start, unsigned long end, void *arg)
> +{
> +	unsigned long rs, re;
> +	void (*func)(unsigned long, unsigned long, int);
> +	int i;
> +
> +	start = PAGE_ALIGN(start);
> +	end &= PAGE_MASK;
> +	if (start >= end)
> +		return;
> +
> +	func = arg;
> +
> +	if (!num_memblks) {
> +		/* this machine doesn't have SRAT, */
> +		/* so call func with nid=0, bank=0 */
> +		if (start < end)
> +			(*func)(start, end, 0);
> +		return;
> +	}
> +
> +	for (i = 0; i < num_memblks; i++) {
> +		rs = MAX(__pa(start), node_memblk[i].start_paddr);
> +		re = MIN(__pa(end), node_memblk[i].start_paddr+node_memblk[i].size);
> +
> +		if (rs < re)
> +			(*func)((unsigned long)__va(rs), (unsigned long)__va(re), node_memblk[i].nid);
> +		if ((unsigned long)__va(re) = end)
> +			break;
> +	}
> +}
> +
> +#else /* CONFIG_DISCONTIGMEM */
> +
>  static int
>  free_available_memory (unsigned long start, unsigned long end, void *arg)
>  {
> +	free_bootmem(__pa(start), end - start);
> +	return 0;
> +}
> +#endif /* CONFIG_DISCONTIGMEM */
> +
> +/*
> + * Filter incoming memory segments based on the primitive map created from
> + * the boot parameters. Segments contained in the map are removed from the
> + * memory ranges. A caller-specified function is called with the memory
> + * ranges that remain after filtering.
> + * This routine does not assume the incoming segments are sorted.
> + */
> +int
> +filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
> +{
>  	unsigned long range_start, range_end, prev_start;
> +	void (*func)(unsigned long, unsigned long, int);
>  	int i;
>  
>  #if IGNORE_PFN0
> @@ -136,13 +195,18 @@
>  	 * lowest possible address(walker uses virtual)
>  	 */
>  	prev_start = PAGE_OFFSET;
> +	func = arg;
>  
>  	for (i = 0; i < num_rsvd_regions; ++i) {
>  		range_start = MAX(start, prev_start);
>  		range_end   = MIN(end, rsvd_region[i].start);
>  
>  		if (range_start < range_end)
> -			free_bootmem(__pa(range_start), range_end - range_start);
> +#ifdef CONFIG_DISCONTIGMEM
> +			call_pernode_memory(range_start, range_end, func);
> +#else
> +			(*func)(range_start, range_end, 0);
> +#endif
>  
>  		/* nothing more available in this segment */
>  		if (range_end = end) return 0;
> @@ -154,6 +218,7 @@
>  }
>  
>  
> +#ifndef CONFIG_DISCONTIGMEM
>  /*
>   * Find a place to put the bootmap and return its starting address in bootmap_start.
>   * This address must be page-aligned.
> @@ -192,6 +257,7 @@
>  	}
>  	return 0;
>  }
> +#endif /* CONFIG_DISCONTIGMEM */
>  
>  static void
>  sort_regions (struct rsvd_region *rsvd_region, int max)
> @@ -256,6 +322,14 @@
>  
>  	sort_regions(rsvd_region, num_rsvd_regions);
>  
> +#ifdef CONFIG_DISCONTIGMEM
> +	{
> +		extern void discontig_mem_init(void);
> +		bootmap_size = max_pfn = 0;     /* stop gcc warnings */
> +		discontig_mem_init();
> +	}
> +#else /* !CONFIG_DISCONTIGMEM */
> +
>  	/* first find highest page frame number */
>  	max_pfn = 0;
>  	efi_memmap_walk(find_max_pfn, &max_pfn);
> @@ -272,8 +346,9 @@
>  	bootmap_size = init_bootmem(bootmap_start >> PAGE_SHIFT, max_pfn);
>  
>  	/* Free all available memory, then mark bootmem-map as being in use.  */
> -	efi_memmap_walk(free_available_memory, 0);
> +	efi_memmap_walk(filter_rsvd_memory, free_available_memory);
>  	reserve_bootmem(bootmap_start, bootmap_size);
> +#endif /* !CONFIG_DISCONTIGMEM */
>  
>  #ifdef CONFIG_BLK_DEV_INITRD
>  	if (ia64_boot_param->initrd_start) {
> @@ -300,6 +375,19 @@
>  
>  	efi_init();
>  
> +#ifdef CONFIG_ACPI_BOOT
> +	/* Initialize the ACPI boot-time table parser */
> +	acpi_table_init(*cmdline_p);
> +
> +# ifdef CONFIG_ACPI_NUMA
> +	acpi_numa_init();
> +# endif
> +#else
> +# ifdef CONFIG_SMP
> +	smp_build_cpu_map();	/* happens, e.g., with the Ski simulator */
> +# endif
> +#endif /* CONFIG_APCI_BOOT */
> +
>  	iomem_resource.end = ~0UL;	/* FIXME probably belongs elsewhere */
>  	find_memory();
>  
> @@ -448,6 +536,8 @@
>  		   c->itc_freq / 1000000, c->itc_freq % 1000000,
>  		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
>  	return 0;
> +#undef lpj
> +#undef cpu
>  }
>  
>  static void *
> @@ -548,7 +638,7 @@
>  	unsigned int max_ctx;
>  	struct cpuinfo_ia64 *my_cpu_data;
>  #ifdef CONFIG_NUMA
> -	int cpu, order;
> +	int cpu;
>  
>  	/*
>  	 * If NUMA is configured, the cpu_data array is not preallocated. The boot cpu
> @@ -557,34 +647,14 @@
>  	 * is required because some boot code references all cpu_data structures
>  	 * before the cpus are actually started.
>  	 */
> -	if (!boot_cpu_data) {
> -		my_cpu_data = alloc_bootmem_pages_node(NODE_DATA(numa_node_id()),
> -						       sizeof(struct cpuinfo_ia64));
> -		boot_cpu_data = my_cpu_data;
> -		my_cpu_data->cpu_data[0] = my_cpu_data;
> -		for (cpu = 1; cpu < NR_CPUS; ++cpu)
> -			my_cpu_data->cpu_data[cpu]
> -				= alloc_bootmem_pages_node(NODE_DATA(numa_node_id()),
> -							   sizeof(struct cpuinfo_ia64));
> -		for (cpu = 1; cpu < NR_CPUS; ++cpu)
> -			memcpy(my_cpu_data->cpu_data[cpu]->cpu_data,
> -			       my_cpu_data->cpu_data, sizeof(my_cpu_data->cpu_data));
> -		my_cpu_data->mmu_gathers = alloc_bootmem_pages_node(BOOT_NODE_DATA(boot_get_local_cnodeid()),
> -								    sizeof(mmu_gather_t));
> -	} else {
> -		order = get_order(sizeof(struct cpuinfo_ia64));
> -		my_cpu_data = page_address(alloc_pages_node(numa_node_id(), GFP_KERNEL, order));
> -		memcpy(my_cpu_data, boot_cpu_data->cpu_data[smp_processor_id()],
> -		       sizeof(struct cpuinfo_ia64));
> -		__free_pages(virt_to_page(boot_cpu_data->cpu_data[smp_processor_id()]),
> -			     order);
> -		for (cpu = 0; cpu < NR_CPUS; ++cpu)
> -			boot_cpu_data->cpu_data[cpu]->cpu_data[smp_processor_id()] = my_cpu_data;
> -
> -		my_cpu_data->mmu_gathers = page_address(boot_alloc_pages_node(boot_get_local_cnodeid(),
> -									      GFP_KERNEL,
> -									      get_order(sizeof(mmu_gather_t)));
> -	}
> +	for (cpu=0; cpu < NR_CPUS; cpu++)
> +		if (node_cpuid[cpu].phys_id = hard_smp_processor_id())
> +			break;
> +	my_cpu_data = _cpu_data[cpu];
> +	my_cpu_data->node_data->active_cpu_count++;
> +
> +	for (cpu=0; cpu<NR_CPUS; cpu++)
> +		_cpu_data[cpu]->cpu_data[smp_processor_id()] = my_cpu_data;
>  #else
>  	my_cpu_data = cpu_data(smp_processor_id());
>  	my_cpu_data->mmu_gathers = &mmu_gathers[smp_processor_id()];
> diff -Naur linux_base/arch/ia64/kernel/smpboot.c linux/arch/ia64/kernel/smpboot.c
> --- linux_base/arch/ia64/kernel/smpboot.c	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/kernel/smpboot.c	Mon Jul 28 16:10:20 2003
> @@ -584,3 +584,27 @@
>  		smp_num_cpus = 1;
>  	}
>  }
> +
> +/*
> + * Initialize the logical CPU number to SAPICID mapping
> + */
> +void __init
> +smp_build_cpu_map (void)
> +{
> +	int sapicid, cpu, i;
> +	int boot_cpu_id = hard_smp_processor_id();
> +
> +	for (cpu = 0; cpu < NR_CPUS; cpu++)
> +		ia64_cpu_to_sapicid[cpu] = -1;
> +
> +	ia64_cpu_to_sapicid[0] = boot_cpu_id;
> +
> +	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
> +		sapicid = smp_boot_data.cpu_phys_id[i];
> +		if (sapicid = -1 || sapicid = boot_cpu_id)
> +			continue;
> +		ia64_cpu_to_sapicid[cpu] = sapicid;
> +		cpu++;
> +	}
> +}
> +
> diff -Naur linux_base/arch/ia64/mm/Makefile linux/arch/ia64/mm/Makefile
> --- linux_base/arch/ia64/mm/Makefile	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/mm/Makefile	Mon Jul 28 10:19:02 2003
> @@ -12,6 +12,8 @@
>  export-objs := init.o
>  
>  obj-y	 := init.o fault.o tlb.o extable.o
> +obj-$(CONFIG_NUMA) += numa.o
> +obj-$(CONFIG_DISCONTIGMEM) += discontig.o
>  obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
>  
>  include $(TOPDIR)/Rules.make
> --- linux_base/arch/ia64/mm/discontig.c	Wed Dec 31 18:00:00 1969
> +++ linux/arch/ia64/mm/discontig.c	Tue Jul 29 20:10:49 2003
> @@ -0,0 +1,282 @@
> +/*
> + * Copyright (c) 2000, 2003 Silicon Graphics, Inc.  All rights reserved.
> + * Copyright (c) 2001 Intel Corp.
> + * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
> + * Copyright (c) 2002 NEC Corp.
> + * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
> + */
> +
> +/*
> + * Platform initialization for Discontig Memory
> + */
> +
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/bootmem.h>
> +#include <linux/mmzone.h>
> +#include <linux/acpi.h>
> +#include <linux/efi.h>
> +#include <asm/pgalloc.h>
> +#include <asm/tlb.h>
> +
> +
> +/*
> + * Round an address upward to the next multiple of GRANULE size.
> + */
> +#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
> +#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
> +
> +/*
> + * Used to locate BOOT_DATA prior to initializing the node data area.
> + */
> +#define BOOT_NODE_DATA(node)	pg_data_ptr[node]
> +
> +/*
> + * To prevent cache aliasing effects, align per-node structures so that they 
> + * start at addresses that are strided by node number.
> + */
> +#define NODEDATA_ALIGN(addr, node)	((((addr) + 1024*1024-1) & ~(1024*1024-1)) + (node)*PAGE_SIZE)
> +
> +
> +static struct ia64_node_data	*boot_node_data[NR_NODES] __initdata;
> +static pg_data_t		*pg_data_ptr[NR_NODES] __initdata;
> +static bootmem_data_t		bdata[NR_NODES] __initdata;
> +static unsigned long		boot_pernode[NR_NODES] __initdata;
> +static unsigned long		boot_pernodesize[NR_NODES] __initdata;
> +
> +extern int  filter_rsvd_memory (unsigned long start, unsigned long end, void *arg);
> +extern struct cpuinfo_ia64 *_cpu_data[NR_CPUS];
> +
> +
> +
> +/*
> + * We allocate one of the bootmem_data_t structs for each piece of memory
> + * that we wish to treat as a contiguous block.  Each such block must start
> + * on a GRANULE boundary.  Multiple banks per node is not supported.
> + *   (Note: on SN2, all memory on a node is trated as a single bank.
> + *   Holes within the bank are supported. This works because memory
> + *   from different banks is not interleaved. The bootmap bitmap
> + *   for the node is somewhat large but not too large).
> + */
> +static int __init
> +build_maps(unsigned long start, unsigned long end, int node)
> +{
> +	bootmem_data_t	*bdp;
> +	unsigned long cstart, epfn;
> +
> +	bdp = &bdata[node];
> +	epfn = GRANULEROUNDUP(__pa(end)) >> PAGE_SHIFT;
> +	cstart = GRANULEROUNDDOWN(__pa(start));
> +
> +	if (!bdp->node_low_pfn) {
> +		bdp->node_boot_start = cstart;
> +		bdp->node_low_pfn = epfn;
> +	} else {
> +		bdp->node_boot_start = min(cstart, bdp->node_boot_start);
> +		bdp->node_low_pfn = max(epfn, bdp->node_low_pfn);
> +	}
> +
> +	min_low_pfn = min(min_low_pfn, bdp->node_boot_start>>PAGE_SHIFT);
> +	max_low_pfn = max(max_low_pfn, bdp->node_low_pfn);
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * Count the number of cpus on the node
> + */
> +static __inline__ int
> +count_cpus(int node)
> +{
> +	int cpu, n=0;
> +
> +	for (cpu=0; cpu < NR_CPUS; cpu++)
> +		if (node = node_cpuid[cpu].nid)
> +			n++;
> +	return n;
> +}
> +
> +
> +/*
> + * Find space on each node for the bootmem map & other per-node data structures.
> + *
> + * Called by efi_memmap_walk to find boot memory on each node. Note that
> + * only blocks that are free are passed to this routine (currently filtered by
> + * free_available_memory).
> + */
> +static int __init
> +find_pernode_space(unsigned long start, unsigned long end, int node)
> +{
> +	unsigned long	mapsize, pages, epfn, map=0, cpu, cpus;
> +	unsigned long	pernodesize=0, pernode;
> +	unsigned long	cpu_data, mmu_gathers;
> +	unsigned long	pstart, length;
> +	bootmem_data_t	*bdp;
> +
> +	pstart = __pa(start);
> +	length = end - start;
> +	epfn = (pstart + length) >> PAGE_SHIFT;
> +	bdp = &bdata[node];
> +
> +	if (pstart < bdp->node_boot_start || epfn > bdp->node_low_pfn)
> +		return 0;
> +
> +	if (!boot_pernode[node]) {
> +		cpus = count_cpus(node);
> +		pernodesize += PAGE_ALIGN(sizeof(struct cpuinfo_ia64)) * cpus;
> +		pernodesize += L1_CACHE_ALIGN(sizeof(mmu_gather_t)) * cpus;
> +		pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
> +		pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
> +		pernodesize = PAGE_ALIGN(pernodesize);
> +		pernode = NODEDATA_ALIGN(pstart, node);
> +	
> +		if (pstart + length > (pernode + pernodesize)) {
> +			boot_pernode[node] = pernode;
> +			boot_pernodesize[node] = pernodesize;
> +			memset(__va(pernode), 0, pernodesize);
> +
> +			cpu_data = pernode;
> +			pernode += PAGE_ALIGN(sizeof(struct cpuinfo_ia64)) * cpus;
> +
> +			mmu_gathers = pernode;
> +			pernode += L1_CACHE_ALIGN(sizeof(mmu_gather_t)) * cpus;
> +
> +			pg_data_ptr[node] = __va(pernode);
> +			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
> +
> +			boot_node_data[node] = __va(pernode);
> +			pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
> +
> +			pg_data_ptr[node]->bdata = &bdata[node];
> +			pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
> +
> +			for (cpu=0; cpu < NR_CPUS; cpu++) {
> +				if (node = node_cpuid[cpu].nid) {
> +					_cpu_data[cpu] = __va(cpu_data);
> +					_cpu_data[cpu]->node_data = boot_node_data[node];
> +					_cpu_data[cpu]->nodeid = node;
> +					_cpu_data[cpu]->mmu_gathers = __va(mmu_gathers);
> +					cpu_data +=  PAGE_ALIGN(sizeof(struct cpuinfo_ia64));
> +					mmu_gathers += L1_CACHE_ALIGN(sizeof(mmu_gather_t));
> +				}
> +			}
> +
> +		}
> +	}
> +
> +	pernode = boot_pernode[node];
> +	pernodesize = boot_pernodesize[node];
> +	if (pernode && !bdp->node_bootmem_map) {
> +		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
> +		mapsize = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
> +
> +		if (pernode - pstart > mapsize)
> +			map = pstart;
> +		else if (pstart + length - pernode - pernodesize > mapsize)
> +			map = pernode + pernodesize;
> +
> +		if (map) {
> +			init_bootmem_node(
> +				BOOT_NODE_DATA(node),
> +				map>>PAGE_SHIFT, 
> +				bdp->node_boot_start>>PAGE_SHIFT,
> +				bdp->node_low_pfn);
> +		}
> +
> +	}
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * Free available memory to the bootmem allocator.
> + *
> + * Note that only blocks that are free are passed to this routine (currently 
> + * filtered by free_available_memory).
> + *
> + */
> +static int __init
> +discontig_free_bootmem_node(unsigned long start, unsigned long end, int node)
> +{
> +	free_bootmem_node(BOOT_NODE_DATA(node), __pa(start), end - start);
> +
> +	return 0;
> +}
> +
> +
> +/*
> + * Reserve the space used by the bootmem maps.
> + */
> +static void __init
> +discontig_reserve_bootmem(void)
> +{
> +	int		node;
> +	unsigned long	base, size, pages;
> +	bootmem_data_t	*bdp;
> +
> +	for (node = 0; node < numnodes; node++) {
> +		bdp = BOOT_NODE_DATA(node)->bdata;
> +
> +		pages = bdp->node_low_pfn - (bdp->node_boot_start>>PAGE_SHIFT);
> +		size = bootmem_bootmap_pages(pages) << PAGE_SHIFT;
> +		base = __pa(bdp->node_bootmem_map);
> +		reserve_bootmem_node(BOOT_NODE_DATA(node), base, size);
> +
> +		size = boot_pernodesize[node];
> +		base = __pa(boot_pernode[node]);
> +		reserve_bootmem_node(BOOT_NODE_DATA(node), base, size);
> +	}
> +}
> +
> +/*
> + * Initialize per-node data
> + *
> + * Finish setting up the node data for this node, then copy it to the other nodes.
> + *
> + */
> +static void __init
> +initialize_pernode_data(void)
> +{
> +	int	cpu, node;
> +
> +	memcpy(boot_node_data[0]->pg_data_ptrs, pg_data_ptr, sizeof(pg_data_ptr));
> +	memcpy(boot_node_data[0]->node_data_ptrs, boot_node_data, sizeof(boot_node_data));
> +
> +	for (node=1; node < numnodes; node++) {
> +		memcpy(boot_node_data[node], boot_node_data[0], sizeof(struct ia64_node_data));
> +		boot_node_data[node]->node = node;
> +	}
> +
> +	for (cpu=0; cpu < NR_CPUS; cpu++) {
> +		node = node_cpuid[cpu].nid;
> +		_cpu_data[cpu]->node_data = boot_node_data[node];
> +		_cpu_data[cpu]->nodeid = node;
> +	}
> +}
> +
> +
> +/*
> + * Called early in boot to setup the boot memory allocator, and to
> + * allocate the node-local pg_data & node-directory data structures..
> + */
> +void __init
> +discontig_mem_init(void)
> +{
> +	if (numnodes = 0) {
> +		printk("node info missing!\n");
> +		numnodes = 1;
> +	}
> +
> +	min_low_pfn = -1;
> +	max_low_pfn = 0;
> +
> +        efi_memmap_walk(filter_rsvd_memory, build_maps);
> +        efi_memmap_walk(filter_rsvd_memory, find_pernode_space);
> +        efi_memmap_walk(filter_rsvd_memory, discontig_free_bootmem_node);
> +
> +	discontig_reserve_bootmem();
> +	initialize_pernode_data();
> +}
> +
> diff -Naur linux_base/arch/ia64/mm/init.c linux/arch/ia64/mm/init.c
> --- linux_base/arch/ia64/mm/init.c	Sat Jul  5 22:59:38 2003
> +++ linux/arch/ia64/mm/init.c	Wed Jul 30 11:58:26 2003
> @@ -16,6 +16,7 @@
>  #include <linux/slab.h>
>  #include <linux/swap.h>
>  #include <linux/efi.h>
> +#include <linux/mmzone.h>
>  
>  #include <asm/bitops.h>
>  #include <asm/dma.h>
> @@ -26,16 +27,21 @@
>  #include <asm/sal.h>
>  #include <asm/system.h>
>  #include <asm/uaccess.h>
> +#include <asm/tlb.h>
> +#include <asm/numa.h>
>  
>  /* References to section boundaries: */
>  extern char _stext, _etext, _edata, __init_begin, __init_end;
>  
>  extern void ia64_tlb_init (void);
> +extern int  filter_rsvd_memory (unsigned long, unsigned long, void *);
>  
> +/* Note - may be changed by platform_setup */
>  unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
>  #define LARGE_GAP 0x40000000 /* Use virtual mem map if a hole is > than this */
>  
> -static unsigned long totalram_pages;
> +static unsigned long totalram_pages, reserved_pages;
> +struct page *zero_page_memmap_ptr;		/* map entry for zero page */
>  
>  unsigned long vmalloc_end = VMALLOC_END_INIT;
>  
> @@ -107,10 +113,11 @@
>  void
>  free_initmem (void)
>  {
> -	unsigned long addr;
> +	unsigned long addr, eaddr;
>  
>  	addr = (unsigned long) &__init_begin;
> -	for (; addr < (unsigned long) &__init_end; addr += PAGE_SIZE) {
> +	eaddr = (unsigned long) &__init_end;
> +	for (; addr < eaddr; addr += PAGE_SIZE) {
>  		clear_bit(PG_reserved, &virt_to_page((void *)addr)->flags);
>  		set_page_count(virt_to_page((void *)addr), 1);
>  		free_page(addr);
> @@ -186,58 +193,39 @@
>  void
>  show_mem(void)
>  {
> -	int i, total = 0, reserved = 0;
> -	int shared = 0, cached = 0;
> +	int i, reserved;
> +	int shared, cached;
> +	pg_data_t *pgdat;
> +	char *tchar = (numnodes > 1) ? "\t" : "";
>  
>  	printk("Mem-info:\n");
>  	show_free_areas();
>  
> -#ifdef CONFIG_DISCONTIGMEM
> -	{
> -		pg_data_t *pgdat = pgdat_list;
> -
> -		printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> -		do {
> -			printk("Node ID: %d\n", pgdat->node_id);
> -			for(i = 0; i < pgdat->node_size; i++) {
> -				if (PageReserved(pgdat->node_mem_map+i))
> -					reserved++;
> -				else if (PageSwapCache(pgdat->node_mem_map+i))
> -					cached++;
> -				else if (page_count(pgdat->node_mem_map + i))
> -					shared += page_count(pgdat->node_mem_map + i) - 1;
> -			}
> -			printk("\t%d pages of RAM\n", pgdat->node_size);
> -			printk("\t%d reserved pages\n", reserved);
> -			printk("\t%d pages shared\n", shared);
> -			printk("\t%d pages swap cached\n", cached);
> -			pgdat = pgdat->node_next;
> -		} while (pgdat);
> -		printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
> -		show_buffers();
> -		printk("%d free buffer pages\n", nr_free_buffer_pages());
> -	}
> -#else /* !CONFIG_DISCONTIGMEM */
>  	printk("Free swap:       %6dkB\n", nr_swap_pages<<(PAGE_SHIFT-10));
> -	i = max_mapnr;
> -	while (i-- > 0) {
> -		if (!VALID_PAGE(mem_map + i))
> -			continue;
> -		total++;
> -		if (PageReserved(mem_map+i))
> -			reserved++;
> -		else if (PageSwapCache(mem_map+i))
> -			cached++;
> -		else if (page_count(mem_map + i))
> -			shared += page_count(mem_map + i) - 1;
> +	for_each_pgdat(pgdat) {
> +		reserved=0;
> +		cached=0;
> +		shared=0;
> +		if (numnodes > 1)
> +			printk("Node ID: %d\n", pgdat->node_id);
> +		for(i = 0; i < pgdat->node_size; i++) {
> +			if (!VALID_PAGE(pgdat->node_mem_map+i))
> +				continue;
> +			if (PageReserved(pgdat->node_mem_map+i))
> +				reserved++;
> +			else if (PageSwapCache(pgdat->node_mem_map+i))
> +				cached++;
> +			else if (page_count(pgdat->node_mem_map + i))
> +				shared += page_count(pgdat->node_mem_map + i) - 1;
> +		}
> +		printk("%s%ld pages of RAM\n", tchar, pgdat->node_size);
> +		printk("%s%d reserved pages\n", tchar, reserved);
> +		printk("%s%d pages shared\n", tchar, shared);
> +		printk("%s%d pages swap cached\n", tchar, cached);
>  	}
> -	printk("%d pages of RAM\n", total);
> -	printk("%d reserved pages\n", reserved);
> -	printk("%d pages shared\n", shared);
> -	printk("%d pages swap cached\n", cached);
> -	printk("%ld pages in page table cache\n", pgtable_cache_size);
> +	printk("Total of %ld pages in page table cache\n", pgtable_cache_size);
>  	show_buffers();
> -#endif /* !CONFIG_DISCONTIGMEM */
> +	printk("%d free buffer pages\n", nr_free_buffer_pages());
>  }
>  
>  /*
> @@ -357,8 +345,10 @@
>  static int
>  create_mem_map_page_table (u64 start, u64 end, void *arg)
>  {
> -	unsigned long address, start_page, end_page;
> +	unsigned long address, start_page, end_page, next_blk_page;
> +	unsigned long blk_start;
>  	struct page *map_start, *map_end;
> +	int node=0;
>  	pgd_t *pgd;
>  	pmd_t *pmd;
>  	pte_t *pte;
> @@ -371,18 +361,35 @@
>  	start_page = (unsigned long) map_start & PAGE_MASK;
>  	end_page = PAGE_ALIGN((unsigned long) map_end);
>  
> +	/* force the first iteration to get node id */
> +	blk_start = start;
> +	next_blk_page = 0;
> +
>  	for (address = start_page; address < end_page; address += PAGE_SIZE) {
> +
> +		/* if we went across a node boundary, get new nid */
> +		if (address >= next_blk_page) {
> +			struct page *map_next_blk;
> +
> +			node = paddr_to_nid(__pa(blk_start));
> +
> +			/* get end addr of this memblk as next blk_start */
> +			blk_start = (unsigned long) __va(min(end, memblk_endpaddr(__pa(blk_start))));
> +			map_next_blk = vmem_map + MAP_NR_DENSE(blk_start);
> +			next_blk_page = PAGE_ALIGN((unsigned long) map_next_blk);
> +		}
> +
>  		pgd = pgd_offset_k(address);
>  		if (pgd_none(*pgd))
> -			pgd_populate(&init_mm, pgd, alloc_bootmem_pages(PAGE_SIZE));
> +			pgd_populate(&init_mm, pgd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
>  		pmd = pmd_offset(pgd, address);
>  
>  		if (pmd_none(*pmd))
> -			pmd_populate(&init_mm, pmd, alloc_bootmem_pages(PAGE_SIZE));
> +			pmd_populate(&init_mm, pmd, alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE));
>  		pte = pte_offset(pmd, address);
>  
>  		if (pte_none(*pte))
> -			set_pte(pte, mk_pte_phys(__pa(alloc_bootmem_pages(PAGE_SIZE)),
> +			set_pte(pte, mk_pte_phys(__pa(alloc_bootmem_pages_node(NODE_DATA(node), PAGE_SIZE)),
>  						 PAGE_KERNEL));
>   	}
>   	return 0;
> @@ -396,6 +403,14 @@
>  	int highmem;
>  };
>  
> +struct memmap_count_callback_data {
> +	int node;
> +	unsigned long num_physpages;
> +	unsigned long num_dma_physpages;
> +	unsigned long min_pfn;
> +	unsigned long max_pfn;
> +} cdata;
> +
>  static int
>  virtual_memmap_init (u64 start, u64 end, void *arg)
>  {
> @@ -451,17 +466,7 @@
>  		efi_memmap_walk(virtual_memmap_init, &args);
>  	}
>  
> -	return page_to_phys(end);
> -}
> -
> -static int
> -count_dma_pages (u64 start, u64 end, void *arg)
> -{
> -	unsigned long *count = arg;
> -
> -	if (end <= MAX_DMA_ADDRESS)
> -		*count += (end - start) >> PAGE_SHIFT;
> -	return 0;
> +	return page_to_phys(end-1) + PAGE_SIZE;;
>  }
>  
>  int
> @@ -472,16 +477,27 @@
>  	return __get_user(byte, (char *) page) = 0;
>  }
>  
> +#define GRANULEROUNDDOWN(n) ((n) & ~(IA64_GRANULE_SIZE-1))
> +#define GRANULEROUNDUP(n) (((n)+IA64_GRANULE_SIZE-1) & ~(IA64_GRANULE_SIZE-1))
> +#define ORDERROUNDDOWN(n) ((n) & ~((PAGE_SIZE<<MAX_ORDER)-1))
>  static int
> -count_pages (u64 start, u64 end, void *arg)
> +count_pages (u64 start, u64 end, int node)
>  {
> -	unsigned long *count = arg;
> -
> -	*count += (end - start) >> PAGE_SHIFT;
> +	start = __pa(start);
> +	end = __pa(end);
> +	if (node = cdata.node) {
> +		cdata.num_physpages += (end - start) >> PAGE_SHIFT;
> +		if (start <= __pa(MAX_DMA_ADDRESS))
> +			cdata.num_dma_physpages += (min(end, __pa(MAX_DMA_ADDRESS)) - start) >> PAGE_SHIFT;
> +		start = GRANULEROUNDDOWN(__pa(start));
> +		start = ORDERROUNDDOWN(start);
> +		end = GRANULEROUNDUP(__pa(end));
> +		cdata.max_pfn = max(cdata.max_pfn, end >> PAGE_SHIFT);
> +		cdata.min_pfn = min(cdata.min_pfn, start >> PAGE_SHIFT);
> +	}
>  	return 0;
>  }
>  
> -#ifndef CONFIG_DISCONTIGMEM
>  static int
>  find_largest_hole(u64 start, u64 end, void *arg)
>  {
> @@ -495,7 +511,6 @@
>  	last_end = end;
>  	return 0;
>  }
> -#endif
>  
>  /*
>   * Set up the page tables.
> @@ -506,73 +521,76 @@
>  	unsigned long max_dma;
>  	unsigned long zones_size[MAX_NR_ZONES];
>  	unsigned long zholes_size[MAX_NR_ZONES];
> -#ifndef CONFIG_DISCONTIGMEM
>  	unsigned long max_gap;
> -#endif
> +	int node;
>  
>  	/* initialize mem_map[] */
>  
> -	memset(zones_size, 0, sizeof(zones_size));
> -	memset(zholes_size, 0, sizeof(zholes_size));
> -
> -	num_physpages = 0;
> -	efi_memmap_walk(count_pages, &num_physpages);
> -
> -	num_dma_physpages = 0;
> -	efi_memmap_walk(count_dma_pages, &num_dma_physpages);
> -
>  	max_dma = virt_to_phys((void *) MAX_DMA_ADDRESS) >> PAGE_SHIFT;
> -
> -	if (max_low_pfn < max_dma) {
> -		zones_size[ZONE_DMA] = max_low_pfn;
> -		zholes_size[ZONE_DMA] = max_low_pfn - num_dma_physpages;
> -	} else {
> -		zones_size[ZONE_DMA] = max_dma;
> -		zholes_size[ZONE_DMA] = max_dma - num_dma_physpages;
> -		if (num_physpages > num_dma_physpages) {
> -			zones_size[ZONE_NORMAL] = max_low_pfn - max_dma;
> -			zholes_size[ZONE_NORMAL] = (max_low_pfn - max_dma)
> -					- (num_physpages - num_dma_physpages);
> -		}
> -	}
> -
> -#ifdef CONFIG_DISCONTIGMEM
> -	free_area_init_node(0, NULL, NULL, zones_size, 0, zholes_size);
> -#else
>  	max_gap = 0;
>  	efi_memmap_walk(find_largest_hole, (u64 *)&max_gap);
>  
> -	if (max_gap < LARGE_GAP) {
> -		vmem_map = (struct page *)0;
> -		free_area_init_node(0, NULL, NULL, zones_size, 0, zholes_size);
> +	for (node=0; node < numnodes; node++) {
> +		memset(zones_size, 0, sizeof(zones_size));
> +		memset(zholes_size, 0, sizeof(zholes_size));
> +		memset(&cdata, 0, sizeof(cdata));
> +
> +		cdata.node = node;
> +		cdata.min_pfn = ~0;
> +
> +		efi_memmap_walk(filter_rsvd_memory, count_pages);
> +		num_dma_physpages += cdata.num_dma_physpages;
> +		num_physpages += cdata.num_physpages;
> +
> +		if (cdata.min_pfn >= max_dma) {
> +			zones_size[ZONE_NORMAL] = cdata.max_pfn - cdata.min_pfn;
> +			zholes_size[ZONE_NORMAL] = cdata.max_pfn - cdata.min_pfn - cdata.num_physpages;
> +		} else if (cdata.max_pfn < max_dma) {
> +			zones_size[ZONE_DMA] = cdata.max_pfn - cdata.min_pfn;
> +			zholes_size[ZONE_DMA] = cdata.max_pfn - cdata.min_pfn - cdata.num_dma_physpages;
> +		} else {
> +			zones_size[ZONE_DMA] = max_dma - cdata.min_pfn;
> +			zholes_size[ZONE_DMA] = zones_size[ZONE_DMA] - cdata.num_dma_physpages;
> +			zones_size[ZONE_NORMAL] = cdata.max_pfn - max_dma;
> +			zholes_size[ZONE_NORMAL] = zones_size[ZONE_NORMAL] - (cdata.num_physpages - cdata.num_dma_physpages);
> +		}
> +	
> +		if (numnodes = 1 && max_gap < LARGE_GAP) {
> +			vmem_map = (struct page *)0;
> +			zones_size[ZONE_DMA] += cdata.min_pfn;
> +			zholes_size[ZONE_DMA] += cdata.min_pfn;
> +			free_area_init_core(0, NODE_DATA(node), &mem_map, zones_size, 0, zholes_size, NULL);
> +		} else {
> +	
> +			/* allocate virtual mem_map */
> +	
> +			if (node = 0) {
> +				unsigned long map_size;
> +				map_size = PAGE_ALIGN(max_low_pfn*sizeof(struct page));
> +				vmalloc_end -= map_size;
> +				mem_map = vmem_map = (struct page *) vmalloc_end;
> +				efi_memmap_walk(create_mem_map_page_table, 0);
> +				printk(KERN_INFO "Virtual mem_map starts at 0x%p\n", mem_map);
> +			}
> +	
> +			free_area_init_node(node, NODE_DATA(node), vmem_map+cdata.min_pfn, zones_size, 
> +				cdata.min_pfn<<PAGE_SHIFT, zholes_size);
> +		}
>  	}
> -	else {
> -		unsigned long map_size;
>  
> -		/* allocate virtual mem_map */
> -
> -		map_size = PAGE_ALIGN(max_low_pfn*sizeof(struct page));
> -		vmalloc_end -= map_size;
> -		vmem_map = (struct page *) vmalloc_end;
> -		efi_memmap_walk(create_mem_map_page_table, 0);
> -
> -		free_area_init_node(0, NULL, vmem_map, zones_size, 0, zholes_size);
> -		printk(KERN_INFO "Virtual mem_map starts at 0x%p\n", mem_map);
> -	}
> -#endif
> +	zero_page_memmap_ptr = virt_to_page(empty_zero_page);
>  }
>  
>  static int
>  count_reserved_pages (u64 start, u64 end, void *arg)
>  {
>  	unsigned long num_reserved = 0;
> -	unsigned long *count = arg;
>  	struct page *pg;
>  
>  	for (pg = virt_to_page((void *)start); pg < virt_to_page((void *)end); ++pg)
>  		if (PageReserved(pg))
>  			++num_reserved;
> -	*count += num_reserved;
> +	reserved_pages += num_reserved;
>  	return 0;
>  }
>  
> @@ -580,8 +598,10 @@
>  mem_init (void)
>  {
>  	extern char __start_gate_section[];
> -	long reserved_pages, codesize, datasize, initsize;
> +	long codesize, datasize, initsize;
>  	unsigned long num_pgt_pages;
> +	pg_data_t *pgdat;
> +
>  
>  #ifdef CONFIG_PCI
>  	/*
> @@ -598,10 +618,11 @@
>  	max_mapnr = max_low_pfn;
>  	high_memory = __va(max_low_pfn * PAGE_SIZE);
>  
> -	totalram_pages += free_all_bootmem();
> +	for_each_pgdat(pgdat)
> +		totalram_pages += free_all_bootmem_node(pgdat);
>  
>  	reserved_pages = 0;
> -	efi_memmap_walk(count_reserved_pages, &reserved_pages);
> +	efi_memmap_walk(filter_rsvd_memory, count_reserved_pages);
>  
>  	codesize =  (unsigned long) &_etext - (unsigned long) &_stext;
>  	datasize =  (unsigned long) &_edata - (unsigned long) &_etext;
> --- linux_base/arch/ia64/mm/numa.c	Wed Dec 31 18:00:00 1969
> +++ linux/arch/ia64/mm/numa.c	Wed Jul 30 09:45:38 2003
> @@ -0,0 +1,104 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * This file contains NUMA specific variables and functions which can
> + * be split away from DISCONTIGMEM and are used on NUMA machines with
> + * contiguous memory.
> + * 
> + *                         2002/08/07 Erich Focht <efocht@ess.nec.de>
> + */
> +
> +#include <linux/config.h>
> +#include <linux/kernel.h>
> +#include <linux/mm.h>
> +#include <linux/init.h>
> +#include <linux/bootmem.h>
> +#include <linux/mmzone.h>
> +#include <linux/smp.h>
> +#include <asm/numa.h>
> +
> +/*
> + * The following structures are usually initialized by ACPI or
> + * similar mechanisms and describe the NUMA characteristics of the machine.
> + */
> +int num_memblks = 0;
> +struct node_memblk_s node_memblk[NR_MEMBLKS];
> +struct node_cpuid_s node_cpuid[NR_CPUS];
> +/*
> + * This is a matrix with "distances" between nodes, they should be
> + * proportional to the memory access latency ratios.
> + */
> +u8 numa_slit[NR_NODES * NR_NODES];
> +
> +/* Identify which cnode a physical address resides on */
> +int
> +paddr_to_nid(unsigned long paddr)
> +{
> +	int	i;
> +
> +	for (i = 0; i < num_memblks; i++)
> +		if (paddr >= node_memblk[i].start_paddr &&
> +		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
> +			break;
> +
> +	return (i < num_memblks) ? node_memblk[i].nid : (num_memblks ? -1 : 0);
> +}
> +
> +/* return end addr of a memblk */
> +unsigned long
> +memblk_endpaddr(unsigned long paddr)
> +{
> +	int	i;
> +
> +	for (i = 0; i < num_memblks; i++)
> +		if (paddr >= node_memblk[i].start_paddr &&
> +		    paddr < node_memblk[i].start_paddr + node_memblk[i].size)
> +			return node_memblk[i].start_paddr + node_memblk[i].size;
> +
> +	return 0;
> +}
> +
> +
> +/* on which node is each logical CPU (one cacheline even for 64 CPUs) */
> +volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
> +
> +/* which logical CPUs are on which nodes */
> +volatile unsigned long node_to_cpu_mask[NR_NODES]  __cacheline_aligned;
> +
> +/*
> + * Build cpu to node mapping and initialize the per node cpu masks.
> + */
> +void __init
> +build_cpu_to_node_map (void)
> +{
> +	int cpu, i, node;
> +
> +	for(cpu = 0; cpu < NR_CPUS; ++cpu) {
> +		/*
> +		 * All Itanium NUMA platforms I know use ACPI, so maybe we
> +		 * can drop this ifdef completely.                    [EF]
> +		 */
> +#ifdef CONFIG_SMP
> +# ifdef CONFIG_ACPI_NUMA
> +		node = -1;
> +		for (i = 0; i < NR_CPUS; ++i) {
> +			extern volatile int ia64_cpu_to_sapicid[];
> +			if (ia64_cpu_to_sapicid[cpu] = node_cpuid[i].phys_id) {
> +				node = node_cpuid[i].nid;
> +				break;
> +			}
> +		}
> +# else
> +#		error Fixme: Dunno how to build CPU-to-node map.
> +# endif
> +		cpu_to_node_map[cpu] = node;
> +		if (node >= 0)
> +			__set_bit(cpu, &node_to_cpu_mask[node]);
> +#else
> +			__set_bit(0, &node_to_cpu_mask[0]);
> +#endif
> +	}
> +}
> +
> diff -Naur linux_base/drivers/acpi/Config.in linux/drivers/acpi/Config.in
> --- linux_base/drivers/acpi/Config.in	Sat Jul  5 22:59:38 2003
> +++ linux/drivers/acpi/Config.in	Wed Jul 30 09:45:38 2003
> @@ -36,6 +36,9 @@
>      tristate     '  Fan'		CONFIG_ACPI_FAN
>      tristate     '  Processor'		CONFIG_ACPI_PROCESSOR
>      dep_tristate '  Thermal Zone' CONFIG_ACPI_THERMAL $CONFIG_ACPI_PROCESSOR
> +    if [ "$CONFIG_NUMA" = "y" ]; then
> +      bool	 '  NUMA support' 	CONFIG_ACPI_NUMA
> +    fi
>      bool         '  Debug Statements' 	CONFIG_ACPI_DEBUG
>    fi
>  
> @@ -99,6 +102,7 @@
>      define_bool CONFIG_ACPI_FAN		n
>      define_bool CONFIG_ACPI_PROCESSOR	n
>      define_bool CONFIG_ACPI_THERMAL	n
> +    define_bool CONFIG_ACPI_NUMA	y
>      endmenu
>    fi
>  
> @@ -119,8 +123,10 @@
>      tristate     '  Fan'		CONFIG_ACPI_FAN
>      tristate     '  Processor'		CONFIG_ACPI_PROCESSOR
>      dep_tristate '  Thermal Zone' CONFIG_ACPI_THERMAL $CONFIG_ACPI_PROCESSOR
> -    bool         '  Debug Statements' 	CONFIG_ACPI_DEBUG
> +    if [ "$CONFIG_NUMA" = "y" ]; then
> +      bool	 '  NUMA support'	CONFIG_ACPI_NUMA
> +    fi
> +    bool         '  Debug Statements'	CONFIG_ACPI_DEBUG
>      endmenu
>    fi
> -
>  fi
> diff -Naur linux_base/drivers/acpi/Makefile linux/drivers/acpi/Makefile
> --- linux_base/drivers/acpi/Makefile	Sat Jul  5 22:59:38 2003
> +++ linux/drivers/acpi/Makefile	Mon Jul 28 10:19:02 2003
> @@ -51,5 +51,6 @@
>    obj-$(CONFIG_ACPI_THERMAL)	+= thermal.o
>    obj-$(CONFIG_ACPI_SYSTEM)	+= system.o
>  endif
> +obj-$(CONFIG_ACPI_NUMA)         += numa.o
>  
>  include $(TOPDIR)/Rules.make
> --- linux_base/drivers/acpi/numa.c	Wed Dec 31 18:00:00 1969
> +++ linux/drivers/acpi/numa.c	Mon Jul 28 16:10:20 2003
> @@ -0,0 +1,190 @@
> +/*
> + *  acpi_numa.c - ACPI NUMA support
> + *
> + *  Copyright (C) 2002 Takayoshi Kochi <t-kouchi@cq.jp.nec.com>
> + *
> + * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *
> + * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> + *
> + */
> +
> +#include <linux/config.h>
> +#include <linux/init.h>
> +#include <linux/kernel.h>
> +#include <linux/types.h>
> +#include <linux/errno.h>
> +#include <linux/acpi.h>
> +#include "acpi_bus.h"
> +
> +extern int __init acpi_table_parse_madt_family (enum acpi_table_id id, unsigned long madt_size, int entry_id, acpi_madt_entry_handler handler);
> +
> +#define SRAT_DEBUG 0
> +
> +void __init
> +acpi_table_print_srat_entry (
> +	acpi_table_entry_header	*header)
> +{
> +	if (!header)
> +		return;
> +
> +	switch (header->type) {
> +
> +	case ACPI_SRAT_PROCESSOR_AFFINITY:
> +	{
> +		struct acpi_table_processor_affinity *p > +			(struct acpi_table_processor_affinity*) header;
> +		if (SRAT_DEBUG || !p->flags.enabled)
> +			printk(KERN_INFO "SRAT Processor (id[0x%02x] eid[0x%02x]) in proximity domain %d %s\n",
> +		       		p->apic_id, p->lsapic_eid, p->proximity_domain,
> +		       		p->flags.enabled?"enabled":"disabled");
> +	}
> +		break;
> +
> +	case ACPI_SRAT_MEMORY_AFFINITY:
> +	{
> +		struct acpi_table_memory_affinity *p > +			(struct acpi_table_memory_affinity*) header;
> +		if (SRAT_DEBUG || !p->flags.enabled)
> +			printk(KERN_INFO "SRAT Memory (0x%08x%08x length 0x%08x%08x type 0x%x) in proximity domain %d %s%s\n",
> +		       		p->base_addr_hi, p->base_addr_lo, p->length_hi, p->length_lo,
> +		       		p->memory_type, p->proximity_domain,
> +		       		p->flags.enabled ? "enabled" : "disabled",
> +		       		p->flags.hot_pluggable ? " hot-pluggable" : "");
> +	}
> +		break;
> +
> +	default:
> +		printk(KERN_WARNING "Found unsupported SRAT entry (type = 0x%x)\n",
> +			header->type);
> +		break;
> +	}
> +}
> +
> +
> +static int __init
> +acpi_parse_slit (unsigned long phys_addr, unsigned long size)
> +{
> +	struct acpi_table_slit	*slit;
> +	u32			localities;
> +
> +	if (!phys_addr || !size)
> +		return -EINVAL;
> +
> +	slit = (struct acpi_table_slit *) __va(phys_addr);
> +
> +	/* downcast just for %llu vs %lu for i386/ia64  */
> +	localities = (u32) slit->localities;
> +
> +	printk(KERN_INFO "SLIT localities %ux%u\n", localities, localities);
> +
> +	acpi_numa_slit_init(slit);
> +
> +	return 0;
> +}
> +
> +
> +static int __init
> +acpi_parse_processor_affinity (acpi_table_entry_header *header)
> +{
> +	struct acpi_table_processor_affinity *processor_affinity = NULL;
> +
> +	processor_affinity = (struct acpi_table_processor_affinity*) header;
> +	if (!processor_affinity)
> +		return -EINVAL;
> +
> +	acpi_table_print_srat_entry(header);
> +
> +	/* let architecture-dependent part to do it */
> +	acpi_numa_processor_affinity_init(processor_affinity);
> +
> +	return 0;
> +}
> +
> +
> +static int __init
> +acpi_parse_memory_affinity (acpi_table_entry_header *header)
> +{
> +	struct acpi_table_memory_affinity *memory_affinity = NULL;
> +
> +	memory_affinity = (struct acpi_table_memory_affinity*) header;
> +	if (!memory_affinity)
> +		return -EINVAL;
> +
> +	acpi_table_print_srat_entry(header);
> +
> +	/* let architecture-dependent part to do it */
> +	acpi_numa_memory_affinity_init(memory_affinity);
> +
> +	return 0;
> +}
> +
> +
> +static int __init
> +acpi_parse_srat (unsigned long phys_addr, unsigned long size)
> +{
> +	struct acpi_table_srat	*srat = NULL;
> +
> +	if (!phys_addr || !size)
> +		return -EINVAL;
> +
> +	srat = (struct acpi_table_srat *) __va(phys_addr);
> +
> +	printk(KERN_INFO "SRAT revision %d\n", srat->table_revision);
> +
> +	return 0;
> +}
> +
> +
> +int __init
> +acpi_table_parse_srat (
> +	enum acpi_srat_entry_id	id,
> +	acpi_madt_entry_handler	handler)
> +{
> +	return acpi_table_parse_madt_family(ACPI_SRAT, sizeof(struct acpi_table_srat),
> +					    id, handler);
> +}
> +
> +
> +int __init
> +acpi_numa_init()
> +{
> +	int			result;
> +
> +	/* SRAT: Static Resource Affinity Table */
> +	result = acpi_table_parse(ACPI_SRAT, acpi_parse_srat);
> +
> +	if (result > 0) {
> +		result = acpi_table_parse_srat(ACPI_SRAT_PROCESSOR_AFFINITY,
> +					       acpi_parse_processor_affinity);
> +		result = acpi_table_parse_srat(ACPI_SRAT_MEMORY_AFFINITY,
> +					       acpi_parse_memory_affinity);
> +	} else {
> +		/* FIXME */
> +		printk("Warning: acpi_table_parse(ACPI_SRAT) returned %d!\n",result);
> +	}
> +
> +	/* SLIT: System Locality Information Table */
> +	result = acpi_table_parse(ACPI_SLIT, acpi_parse_slit);
> +	if (result < 1) {
> +		/* FIXME */
> +		printk("Warning: acpi_table_parse(ACPI_SLIT) returned %d!\n",result);
> +	}
> +
> +	acpi_numa_arch_fixup();
> +	return 0;
> +}
> diff -Naur linux_base/drivers/acpi/tables.c linux/drivers/acpi/tables.c
> --- linux_base/drivers/acpi/tables.c	Sat Jul  5 22:59:38 2003
> +++ linux/drivers/acpi/tables.c	Mon Jul 28 16:10:20 2003
> @@ -224,11 +224,13 @@
>  
>  
>  int __init
> -acpi_table_parse_madt (
> +acpi_table_parse_madt_family (
>  	enum acpi_table_id	id,
> +	unsigned long		madt_size,
> +	int			entry_id,
>  	acpi_madt_entry_handler	handler)
>  {
> -	struct acpi_table_madt	*madt = NULL;
> +	void			*madt = NULL;
>  	acpi_table_entry_header	*entry = NULL;
>  	unsigned long		count = 0;
>  	unsigned long		madt_end = 0;
> @@ -240,19 +242,21 @@
>  	/* Locate the MADT (if exists). There should only be one. */
>  
>  	for (i = 0; i < sdt.count; i++) {
> -		if (sdt.entry[i].id != ACPI_APIC)
> +		if (sdt.entry[i].id != id)
>  			continue;
> -		madt = (struct acpi_table_madt *)
> +		madt = (void *)
>  			__acpi_map_table(sdt.entry[i].pa, sdt.entry[i].size);
>  		if (!madt) {
> -			printk(KERN_WARNING PREFIX "Unable to map MADT\n");
> +			printk(KERN_WARNING PREFIX "Unable to map %s\n",
> +			       acpi_table_signatures[id]);
>  			return -ENODEV;
>  		}
>  		break;
>  	}
>  
>  	if (!madt) {
> -		printk(KERN_WARNING PREFIX "MADT not present\n");
> +		printk(KERN_WARNING PREFIX "%s not present\n",
> +		       acpi_table_signatures[id]);
>  		return -ENODEV;
>  	}
>  
> @@ -261,21 +265,31 @@
>  	/* Parse all entries looking for a match. */
>  
>  	entry = (acpi_table_entry_header *)
> -		((unsigned long) madt + sizeof(struct acpi_table_madt));
> +		((unsigned long) madt + madt_size);
>  
>  	while (((unsigned long) entry) < madt_end) {
> -		if (entry->type = id) {
> +		if (entry->type = entry_id) {
>  			count++;
>  			handler(entry);
>  		}
>  		entry = (acpi_table_entry_header *)
> -			((unsigned long) entry += entry->length);
> +			((unsigned long) entry + entry->length);
>  	}
>  
>  	return count;
>  }
>  
>  
> +int __init
> +acpi_table_parse_madt (
> +	enum acpi_madt_entry_id	id,
> +	acpi_madt_entry_handler	handler)
> +{
> +	return acpi_table_parse_madt_family(ACPI_APIC, sizeof(struct acpi_table_madt),
> +					    id, handler);
> +}
> +
> +
>  int __init
>  acpi_table_parse (
>  	enum acpi_table_id	id,
> diff -Naur linux_base/include/asm-ia64/acpi.h linux/include/asm-ia64/acpi.h
> --- linux_base/include/asm-ia64/acpi.h	Sat Jul  5 22:46:22 2003
> +++ linux/include/asm-ia64/acpi.h	Wed Jul 30 12:07:29 2003
> @@ -97,17 +97,18 @@
>  	} while (0)
>  
>  const char *acpi_get_sysname (void);
> -int acpi_boot_init (char *cdline);
>  int acpi_request_vector (u32 int_type);
>  int acpi_get_prt (struct pci_vector_struct **vectors, int *count);
>  int acpi_get_interrupt_model (int *type);
>  int acpi_irq_to_vector (u32 irq);
>  
> -#ifdef CONFIG_DISCONTIGMEM
> -#define NODE_ARRAY_INDEX(x)	((x) / 8)	/* 8 bits/char */
> -#define NODE_ARRAY_OFFSET(x)	((x) % 8)	/* 8 bits/char */
> -#define MAX_PXM_DOMAINS		(256)
> -#endif /* CONFIG_DISCONTIGMEM */
> +#ifdef CONFIG_ACPI_NUMA
> +#include <asm/numa.h>
> +/* Proximity bitmap length; _PXM is at most 255 (8 bit)*/
> +#define MAX_PXM_DOMAINS (256)
> +extern int __initdata pxm_to_nid_map[MAX_PXM_DOMAINS];
> +extern int __initdata nid_to_pxm_map[NR_NODES];
> +#endif
>  
>  #endif /*__KERNEL__*/
>  
> --- linux_base/include/asm-ia64/mmzone.h	Wed Dec 31 18:00:00 1969
> +++ linux/include/asm-ia64/mmzone.h	Wed Jul 30 12:04:50 2003
> @@ -0,0 +1,63 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (c) 2000,2003 Silicon Graphics, Inc.  All rights reserved.
> + * Copyright (c) 2002 NEC Corp.
> + * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
> + * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
> + */
> +#ifndef _ASM_IA64_MMZONE_H
> +#define _ASM_IA64_MMZONE_H
> +
> +#include <linux/config.h>
> +#include <linux/init.h>
> +
> +
> +#ifdef CONFIG_NUMA
> +
> +#ifdef CONFIG_IA64_DIG
> +
> +/*
> + * Platform definitions for DIG platform with contiguous memory.
> + */
> +#define MAX_PHYSNODE_ID	8		/* Maximum node number +1 */
> +#define NR_NODES	8		/* Maximum number of nodes in SSI */
> +#define NR_MEMBLKS	(NR_NODES * 32)
> +
> +
> +
> +
> +#elif CONFIG_IA64_SGI_SN2
> +
> +/*
> + * Platform definitions for DIG platform with contiguous memory.
> + */
> +#define MAX_PHYSNODE_ID	2048		/* Maximum node number +1 */
> +#define NR_NODES	256		/* Maximum number of compute nodes in SSI */
> +#define NR_MEMBLKS	(NR_NODES)
> +
> +#elif CONFIG_IA64_GENERIC
> +
> +
> +/*
> + * Platform definitions for GENERIC platform with contiguous or discontiguous memory.
> + */
> +#define MAX_PHYSNODE_ID 2048		/* Maximum node number +1 */
> +#define NR_NODES        256		/* Maximum number of nodes in SSI */
> +#define NR_MEMBLKS      (NR_NODES)
> +
> +
> +#else
> +#error unknown platform
> +#endif
> +
> +extern void build_cpu_to_node_map(void);
> +
> +#else /* CONFIG_NUMA */
> +
> +#define NR_NODES	1
> +
> +#endif /* CONFIG_NUMA */
> +#endif /* _ASM_IA64_MMZONE_H */
> --- linux_base/include/asm-ia64/nodedata.h	Wed Dec 31 18:00:00 1969
> +++ linux/include/asm-ia64/nodedata.h	Wed Jul 30 12:04:50 2003
> @@ -0,0 +1,66 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * Copyright (c) 2000 Silicon Graphics, Inc.  All rights reserved.
> + * Copyright (c) 2002 NEC Corp.
> + * Copyright (c) 2002 Erich Focht <efocht@ess.nec.de>
> + * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
> + */
> +
> +
> +#ifndef _ASM_IA64_NODEDATA_H
> +#define _ASM_IA64_NODEDATA_H
> +
> +
> +#include <asm/mmzone.h>
> +
> +/*
> + * Node Data. One of these structures is located on each node of a NUMA system.
> + */
> +
> +struct pglist_data;
> +struct ia64_node_data {
> +	short			node;
> +	short			active_cpu_count;
> +	/*
> +	 * The fields are read-only (after boot). They contain pointers to various structures
> +	 * located on other nodes. Ths data is replicated on each node in order to reduce
> +	 * off-node references.
> +	 */
> +        struct pglist_data	*pg_data_ptrs[NR_NODES];
> +	struct ia64_node_data	*node_data_ptrs[NR_NODES];
> +};
> +
> +
> +/*
> + * Return a pointer to the node_data structure for the executing cpu.
> + */
> +#define local_node_data		(local_cpu_data->node_data)
> +
> +
> +/*
> + * Return a pointer to the node_data structure for the specified node.
> + */
> +#define node_data(node)	(local_node_data->node_data_ptrs[node])
> +
> +
> +/*
> + * Given a node id, return a pointer to the pg_data_t for the node.
> + * The following 2 macros are similar. 
> + *
> + * NODE_DATA 	- should be used in all code not related to system
> + *		  initialization. It uses pernode data structures to minimize
> + *		  offnode memory references. However, these structure are not 
> + *		  present during boot. This macro can be used once cpu_init
> + *		  completes.
> + *
> + * NOTE:   The names of these macros are misleading but are difficult to change
> + *	   since they are used in generic linux & on other architecures.
> + */
> +#define NODE_DATA(nid)		(local_node_data->pg_data_ptrs[nid])
> +
> +extern struct pglist_data * __init boot_get_pg_data_ptr(long);
> +
> +#endif /* _ASM_IA64_NODEDATA_H */
> --- linux_base/include/asm-ia64/numa.h	Wed Dec 31 18:00:00 1969
> +++ linux/include/asm-ia64/numa.h	Wed Jul 30 12:07:23 2003
> @@ -0,0 +1,85 @@
> +/*
> + * This file is subject to the terms and conditions of the GNU General Public
> + * License.  See the file "COPYING" in the main directory of this archive
> + * for more details.
> + *
> + * This file contains NUMA specific prototypes and definitions.
> + * 
> + * 2002/08/05 Erich Focht <efocht@ess.nec.de>
> + *
> + */
> +#ifndef _ASM_IA64_NUMA_H
> +#define _ASM_IA64_NUMA_H
> +
> +#ifdef CONFIG_NUMA
> +
> +#ifdef CONFIG_DISCONTIGMEM
> +# include <asm/mmzone.h>
> +#else
> +# define NR_NODES     (8)
> +# define NR_MEMBLKS   (NR_NODES * 8)
> +#endif
> +
> +#include <linux/cache.h>
> +#include <linux/threads.h>
> +#include <linux/smp.h>
> +
> +#define NODEMASK_WORDCOUNT       ((NR_NODES+(BITS_PER_LONG-1))/BITS_PER_LONG)
> +
> +#define NODE_MASK_NONE   { [0 ... ((NR_NODES+BITS_PER_LONG-1)/BITS_PER_LONG)-1] = 0 }
> +
> +typedef unsigned long   nodemask_t[NODEMASK_WORDCOUNT];
> +                                                                                                                             
> +extern volatile char cpu_to_node_map[NR_CPUS] __cacheline_aligned;
> +extern volatile unsigned long node_to_cpu_mask[NR_NODES] __cacheline_aligned;
> +
> +/* Stuff below this line could be architecture independent */
> +
> +extern int num_memblks;		/* total number of memory chunks */
> +
> +/*
> + * List of node memory chunks. Filled when parsing SRAT table to
> + * obtain information about memory nodes.
> +*/
> +
> +struct node_memblk_s {
> +	unsigned long start_paddr;
> +	unsigned long size;
> +	int nid;		/* which logical node contains this chunk? */
> +	int bank;		/* which mem bank on this node */
> +};
> +
> +struct node_cpuid_s {
> +	u16	phys_id;	/* id << 8 | eid */
> +	int	nid;		/* logical node containing this CPU */
> +};
> +
> +extern struct node_memblk_s node_memblk[NR_MEMBLKS];
> +extern struct node_cpuid_s node_cpuid[NR_CPUS];
> +
> +/*
> + * ACPI 2.0 SLIT (System Locality Information Table)
> + * http://devresource.hp.com/devresource/Docs/TechPapers/IA64/slit.pdf
> + *
> + * This is a matrix with "distances" between nodes, they should be
> + * proportional to the memory access latency ratios.
> + */
> +
> +extern u8 numa_slit[NR_NODES * NR_NODES];
> +#define node_distance(from,to) (numa_slit[from * numnodes + to])
> +
> +extern int paddr_to_nid(unsigned long paddr);
> +extern unsigned long memblk_endpaddr(unsigned long paddr);
> +
> +#define local_nodeid (cpu_to_node_map[smp_processor_id()])
> +
> +#else /* !CONFIG_NUMA */
> +
> +#define node_distance(from,to) 10
> +#define paddr_to_nid(x) 0
> +#define memblk_endpaddr(x) ~0UL
> +#define local_nodeid 0
> +
> +#endif /* CONFIG_NUMA */
> +
> +#endif /* _ASM_IA64_NUMA_H */
> --- linux_base/include/asm-ia64/numnodes.h	Wed Dec 31 18:00:00 1969
> +++ linux/include/asm-ia64/numnodes.h	Wed Jul 30 12:04:50 2003
> @@ -0,0 +1,7 @@
> +#ifndef _ASM_MAX_NUMNODES_H
> +#define _ASM_MAX_NUMNODES_H
> +
> +#include <asm/mmzone.h>
> +#define MAX_NUMNODES	NR_NODES
> +
> +#endif /* _ASM_MAX_NUMNODES_H */
> diff -Naur linux_base/include/asm-ia64/page.h linux/include/asm-ia64/page.h
> --- linux_base/include/asm-ia64/page.h	Tue Jul 29 14:43:58 2003
> +++ linux/include/asm-ia64/page.h	Mon Jul 28 11:06:42 2003
> @@ -80,19 +80,8 @@
>   */
>  #define MAP_NR_DENSE(addr)	(((unsigned long) (addr) - PAGE_OFFSET) >> PAGE_SHIFT)
>  
> -#ifdef CONFIG_IA64_GENERIC
> -# include <asm/machvec.h>
> -# define virt_to_page(kaddr)	(mem_map + platform_map_nr(kaddr))
> -# define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
> -#elif defined (CONFIG_IA64_SGI_SN1)
> -# ifndef CONFIG_DISCONTIGMEM
> -#  define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
> -#  define page_to_phys(page)	XXX fix me
> -# endif
> -#else
> -# define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
> -# define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
> -#endif
> +#define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
> +#define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
>  
>  struct page;
>  extern int ia64_page_valid (struct page *);
> diff -Naur linux_base/include/asm-ia64/pgtable.h linux/include/asm-ia64/pgtable.h
> --- linux_base/include/asm-ia64/pgtable.h	Tue Jul 29 14:44:02 2003
> +++ linux/include/asm-ia64/pgtable.h	Wed Jul 30 12:07:32 2003
> @@ -163,7 +163,6 @@
>  	return (addr & (local_cpu_data->unimpl_pa_mask)) = 0;
>  }
>  
> -#ifndef CONFIG_DISCONTIGMEM
>  /*
>   * kern_addr_valid(ADDR) tests if ADDR is pointing to valid kernel
>   * memory.  For the return value to be meaningful, ADDR must be >> @@ -179,7 +178,6 @@
>   */
>  #define kern_addr_valid(addr)	(1)
>  
> -#endif
>  
>  /*
>   * Now come the defines and routines to manage and access the three-level
> @@ -227,10 +225,8 @@
>  #define pte_none(pte) 			(!pte_val(pte))
>  #define pte_present(pte)		(pte_val(pte) & (_PAGE_P | _PAGE_PROTNONE))
>  #define pte_clear(pte)			(pte_val(*(pte)) = 0UL)
> -#ifndef CONFIG_DISCONTIGMEM
>  /* pte_page() returns the "struct page *" corresponding to the PTE: */
>  #define pte_page(pte)			(mem_map + (unsigned long) ((pte_val(pte) & _PFN_MASK) >> PAGE_SHIFT))
> -#endif
>  
>  #define pmd_none(pmd)			(!pmd_val(pmd))
>  #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
> @@ -430,7 +426,8 @@
>   * for zero-mapped memory areas etc..
>   */
>  extern unsigned long empty_zero_page[PAGE_SIZE/sizeof(unsigned long)];
> -#define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
> +extern struct page *zero_page_memmap_ptr;
> +#define ZERO_PAGE(vaddr) (zero_page_memmap_ptr)
>  
>  /* We provide our own get_unmapped_area to cope with VA holes for userland */
>  #define HAVE_ARCH_UNMAPPED_AREA
> diff -Naur linux_base/include/asm-ia64/processor.h linux/include/asm-ia64/processor.h
> --- linux_base/include/asm-ia64/processor.h	Tue Jul 29 14:43:59 2003
> +++ linux/include/asm-ia64/processor.h	Wed Jul 30 12:04:50 2003
> @@ -87,6 +87,9 @@
>  #include <asm/rse.h>
>  #include <asm/unwind.h>
>  #include <asm/atomic.h>
> +#ifdef CONFIG_NUMA
> +#include <asm/nodedata.h>
> +#endif
>  
>  /* like above but expressed as bitfields for more efficient access: */
>  struct ia64_psr {
> @@ -188,8 +191,8 @@
>  	} ipi;
>  #endif
>  #ifdef CONFIG_NUMA
> -	void *node_directory;
> -	int numa_node_id;
> +	struct ia64_node_data *node_data;
> +	int nodeid;
>  	struct cpuinfo_ia64 *cpu_data[NR_CPUS];
>  #endif
>  	/* Platform specific word.  MUST BE LAST IN STRUCT */
> @@ -214,9 +217,9 @@
>   */
>  #ifdef CONFIG_NUMA
>  # define cpu_data(cpu)		local_cpu_data->cpu_data[cpu]
> -# define numa_node_id()		(local_cpu_data->numa_node_id)
> +# define numa_node_id()		(local_cpu_data->nodeid)
>  #else
> -  extern struct cpuinfo_ia64 _cpu_data[NR_CPUS];
> +  extern struct cpuinfo_ia64	_cpu_data[NR_CPUS];
>  # define cpu_data(cpu)		(&_cpu_data[cpu])
>  #endif
>  
> diff -Naur linux_base/include/asm-ia64/smp.h linux/include/asm-ia64/smp.h
> --- linux_base/include/asm-ia64/smp.h	Tue Jul 29 14:43:59 2003
> +++ linux/include/asm-ia64/smp.h	Wed Jul 30 12:04:50 2003
> @@ -124,6 +124,7 @@
>  extern int smp_call_function_single (int cpuid, void (*func) (void *info), void *info,
>  				     int retry, int wait);
>  
> +extern void smp_build_cpu_map(void);
>  
>  #endif /* CONFIG_SMP */
>  #endif /* _ASM_IA64_SMP_H */
> --- linux_base/include/asm-ia64/topology.h	Wed Dec 31 18:00:00 1969
> +++ linux/include/asm-ia64/topology.h	Wed Jul 30 12:07:30 2003
> @@ -0,0 +1,63 @@
> +/*
> + * linux/include/asm-ia64/topology.h
> + *
> + * Copyright (C) 2002, Erich Focht, NEC
> + *
> + * All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +#ifndef _ASM_IA64_TOPOLOGY_H
> +#define _ASM_IA64_TOPOLOGY_H
> +
> +#include <asm/acpi.h>
> +#include <asm/numa.h>
> +#include <asm/smp.h>
> +
> +#ifdef CONFIG_NUMA
> +/*
> + * Returns the number of the node containing CPU 'cpu'
> + */
> +#define __cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
> +
> +/*
> + * Returns a bitmask of CPUs on Node 'node'.
> + */
> +#define __node_to_cpu_mask(node) (node_to_cpu_mask[node])
> +
> +#else
> +#define __cpu_to_node(cpu) (0)
> +#define __node_to_cpumask(node) (&phys_cpu_present_map)
> +#endif
> +
> +/*
> + * Returns the number of the node containing MemBlk 'memblk'
> + */
> +#ifdef CONFIG_ACPI_NUMA
> +#define __memblk_to_node(memblk) (node_memblk[memblk].nid)
> +#else
> +#define __memblk_to_node(memblk) (memblk)
> +#endif
> +
> +/*
> + * Returns the number of the node containing Node 'nid'.
> + * Not implemented here. Multi-level hierarchies detected with
> + * the help of node_distance().
> + */
> +#define __parent_node(nid) (nid)
> +
> +/*
> + * Returns the number of the first CPU on Node 'node'.
> + */
> +#define __node_to_first_cpu(node) (__ffs(__node_to_cpu_mask(node)))
> +
> +/*
> + * Returns the number of the first MemBlk on Node 'node'
> + * Should be fixed when IA64 discontigmem goes in.
> + */
> +#define __node_to_memblk(node) (node)
> +
> +#endif /* _ASM_IA64_TOPOLOGY_H */
> diff -Naur linux_base/include/linux/acpi.h linux/include/linux/acpi.h
> --- linux_base/include/linux/acpi.h	Tue Jul 29 14:43:59 2003
> +++ linux/include/linux/acpi.h	Wed Jul 30 12:07:30 2003
> @@ -344,6 +344,14 @@
>  void acpi_table_print (struct acpi_table_header *, unsigned long);
>  void acpi_table_print_madt_entry (acpi_table_entry_header *);
>  
> +#ifdef CONFIG_ACPI_NUMA
> +int __init acpi_numa_init(void);
> +void __init acpi_numa_slit_init (struct acpi_table_slit *);
> +void __init acpi_numa_processor_affinity_init (struct acpi_table_processor_affinity *);
> +void __init acpi_numa_memory_affinity_init (struct acpi_table_memory_affinity *);
> +void __init acpi_numa_arch_fixup(void);
> +#endif
> +
>  #endif /*CONFIG_ACPI_BOOT*/
>  
>  
> diff -Naur linux_base/include/linux/mmzone.h linux/include/linux/mmzone.h
> --- linux_base/include/linux/mmzone.h	Tue Jul 29 14:43:59 2003
> +++ linux/include/linux/mmzone.h	Wed Jul 30 12:07:31 2003
> @@ -8,6 +8,12 @@
>  #include <linux/spinlock.h>
>  #include <linux/list.h>
>  #include <linux/wait.h>
> +#ifdef CONFIG_DISCONTIGMEM
> +#include <asm/numnodes.h>
> +#endif
> +#ifndef MAX_NUMNODES
> +#define MAX_NUMNODES 1
> +#endif
>  
>  /*
>   * Free memory management - zoned buddy allocator.
> @@ -110,7 +116,7 @@
>   * footprint of this construct is very small.
>   */
>  typedef struct zonelist_struct {
> -	zone_t * zones [MAX_NR_ZONES+1]; // NULL delimited
> +	zone_t * zones [MAX_NUMNODES*MAX_NR_ZONES+1]; // NULL delimited
>  } zonelist_t;
>  
>  #define GFP_ZONEMASK	0x0f
> @@ -144,8 +150,8 @@
>  extern int numnodes;
>  extern pg_data_t *pgdat_list;
>  
> -#define memclass(pgzone, classzone)	(((pgzone)->zone_pgdat = (classzone)->zone_pgdat) \
> -			&& ((pgzone) <= (classzone)))
> +#define memclass(pgzone, classzone)            (((pgzone) - (pgzone)->zone_pgdat->node_zones) <= \
> +((classzone) - (classzone)->zone_pgdat->node_zones))
>  
>  /*
>   * The following two are not meant for general usage. They are here as
> @@ -212,6 +218,18 @@
>  #define for_each_zone(zone) \
>  	for(zone = pgdat_list->node_zones; zone; zone = next_zone(zone))
>  
> +#ifdef CONFIG_NUMA
> +#define MAX_NR_MEMBLKS  BITS_PER_LONG /* Max number of Memory Blocks */
> +#include <asm/topology.h>
> +#else /* !CONFIG_NUMA */
> +#define MAX_NR_MEMBLKS  1
> +#endif /* CONFIG_NUMA */
> +
> +/* Returns the number of the current Node. */
> +
> +#ifndef CONFIG_NUMA
> +#define numa_node_id()          (__cpu_to_node(smp_processor_id()))
> +#endif
>  
>  #ifndef CONFIG_DISCONTIGMEM
>  
> diff -Naur linux_base/init/main.c linux/init/main.c
> --- linux_base/init/main.c	Sat Jul  5 22:59:38 2003
> +++ linux/init/main.c	Mon Jul 28 16:10:20 2003
> @@ -290,6 +290,7 @@
>  
>  
>  extern void setup_arch(char **);
> +extern void __init build_all_zonelists(void);
>  extern void cpu_idle(void);
>  
>  unsigned long wait_init_idle;
> @@ -360,6 +361,7 @@
>  	lock_kernel();
>  	printk(linux_banner);
>  	setup_arch(&command_line);
> +	build_all_zonelists();
>  	printk("Kernel command line: %s\n", saved_command_line);
>  	parse_options(command_line);
>  	trap_init();
> diff -Naur linux_base/mm/bootmem.c linux/mm/bootmem.c
> --- linux_base/mm/bootmem.c	Sat Jul  5 22:59:38 2003
> +++ linux/mm/bootmem.c	Mon Jul 28 16:10:20 2003
> @@ -49,8 +49,24 @@
>  	bootmem_data_t *bdata = pgdat->bdata;
>  	unsigned long mapsize = ((end - start)+7)/8;
>  
> -	pgdat->node_next = pgdat_list;
> -	pgdat_list = pgdat;
> +
> +	/*
> +	 * sort pgdat_list so that the lowest one comes first,
> +	 * which makes alloc_bootmem_low_pages work as desired.
> +	 */
> +	if (!pgdat_list || pgdat_list->node_start_paddr > pgdat->node_start_paddr) {
> +		pgdat->node_next = pgdat_list;
> +		pgdat_list = pgdat;
> +	} else {
> +		pg_data_t *tmp = pgdat_list;
> +		while (tmp->node_next) {
> +			if (tmp->node_next->node_start_paddr > pgdat->node_start_paddr)
> +				break;
> +			tmp = tmp->node_next;
> +		}
> +		pgdat->node_next = tmp->node_next;
> +		tmp->node_next = pgdat;
> +	}
>  
>  	mapsize = (mapsize + (sizeof(long) - 1UL)) & ~(sizeof(long) - 1UL);
>  	bdata->node_bootmem_map = phys_to_virt(mapstart << PAGE_SHIFT);
> @@ -259,16 +275,16 @@
>  	if (!bdata->node_bootmem_map) BUG();
>  
>  	count = 0;
> +	page = virt_to_page(phys_to_virt(bdata->node_boot_start));
>  	idx = bdata->node_low_pfn - (bdata->node_boot_start >> PAGE_SHIFT);
>  	for (i = find_first_zero_bit(bdata->node_bootmem_map, idx);
>  	     i < idx;
>  	     i = find_next_zero_bit(bdata->node_bootmem_map, idx, i + 1))
>  	{
> -		page = pgdat->node_mem_map + i;
>  		count++;
> -		ClearPageReserved(page);
> -		set_page_count(page, 1);
> -		__free_page(page);
> +		ClearPageReserved(page+i);
> +		set_page_count(page+i, 1);
> +		__free_page(page+i);
>  	}
>  	total += count;
>  
> diff -Naur linux_base/mm/page_alloc.c linux/mm/page_alloc.c
> --- linux_base/mm/page_alloc.c	Sat Jul  5 22:59:38 2003
> +++ linux/mm/page_alloc.c	Mon Jul 28 16:10:20 2003
> @@ -586,13 +586,44 @@
>  /*
>   * Builds allocation fallback zone lists.
>   */
> -static inline void build_zonelists(pg_data_t *pgdat)
> +static int __init build_zonelists_node(pg_data_t *pgdat, zonelist_t *zonelist, int j, int k)
>  {
> -	int i, j, k;
> +	zone_t *zone;
> +	switch (k) {
> +	default:
> +		BUG();
> +		/*
> +		 * fallthrough:
> +		 */
> +	case ZONE_HIGHMEM:
> +		zone = pgdat->node_zones + ZONE_HIGHMEM;
> +		if (zone->memsize) {
> +#ifndef CONFIG_HIGHMEM
> +			BUG();
> +#endif
> +			zonelist->zones[j++] = zone;
> +		}
> +	case ZONE_NORMAL:
> +		zone = pgdat->node_zones + ZONE_NORMAL;
> +		if (zone->memsize)
> +			zonelist->zones[j++] = zone;
> +	case ZONE_DMA:
> +		zone = pgdat->node_zones + ZONE_DMA;
> +		if (zone->memsize)
> +			zonelist->zones[j++] = zone;
> +	}
> +
> +	return j;
> +}
> +
> +static void __init build_zonelists(pg_data_t *pgdat)
> +{
> +	int i, j, k, node, local_node;
>  
> +	local_node = pgdat->node_id;
> +	printk("Building zonelist for node : %d\n", local_node);
>  	for (i = 0; i <= GFP_ZONEMASK; i++) {
>  		zonelist_t *zonelist;
> -		zone_t *zone;
>  
>  		zonelist = pgdat->node_zonelists + i;
>  		memset(zonelist, 0, sizeof(*zonelist));
> @@ -604,33 +635,32 @@
>  		if (i & __GFP_DMA)
>  			k = ZONE_DMA;
>  
> -		switch (k) {
> -			default:
> -				BUG();
> -			/*
> -			 * fallthrough:
> -			 */
> -			case ZONE_HIGHMEM:
> -				zone = pgdat->node_zones + ZONE_HIGHMEM;
> -				if (zone->memsize) {
> -#ifndef CONFIG_HIGHMEM
> -					BUG();
> -#endif
> -					zonelist->zones[j++] = zone;
> -				}
> -			case ZONE_NORMAL:
> -				zone = pgdat->node_zones + ZONE_NORMAL;
> -				if (zone->memsize)
> -					zonelist->zones[j++] = zone;
> -			case ZONE_DMA:
> -				zone = pgdat->node_zones + ZONE_DMA;
> -				if (zone->memsize)
> -					zonelist->zones[j++] = zone;
> -		}
> + 		j = build_zonelists_node(pgdat, zonelist, j, k);
> + 		/*
> + 		 * Now we build the zonelist so that it contains the zones
> + 		 * of all the other nodes.
> + 		 * We don't want to pressure a particular node, so when
> + 		 * building the zones for node N, we make sure that the
> + 		 * zones coming right after the local ones are those from
> + 		 * node N+1 (modulo N)
> + 		 */
> + 		for (node = local_node + 1; node < numnodes; node++)
> + 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
> + 		for (node = 0; node < local_node; node++)
> + 			j = build_zonelists_node(NODE_DATA(node), zonelist, j, k);
> + 
>  		zonelist->zones[j++] = NULL;
>  	} 
>  }
>  
> +void __init build_all_zonelists(void)
> +{
> +	int i;
> +
> +	for(i = 0 ; i < numnodes ; i++)
> +		build_zonelists(NODE_DATA(i));
> +}
> +
>  /*
>   * Helper functions to size the waitqueue hash table.
>   * Essentially these want to choose hash table sizes sufficiently
> @@ -742,7 +772,7 @@
>  			MAP_ALIGN((unsigned long)lmem_map - PAGE_OFFSET));
>  	}
>  	*gmap = pgdat->node_mem_map = lmem_map;
> -	pgdat->node_size = totalpages;
> +	pgdat->node_size = 0;
>  	pgdat->node_start_paddr = zone_start_paddr;
>  	pgdat->node_start_mapnr = (lmem_map - mem_map);
>  	pgdat->nr_zones = 0;
> @@ -766,6 +796,7 @@
>  		zone->zone_pgdat = pgdat;
>  		zone->free_pages = 0;
>  		zone->need_balance = 0;
> +		pgdat->node_size += realsize;
>  		if (!size)
>  			continue;
>  
> @@ -850,7 +881,6 @@
>  			  (unsigned long *) alloc_bootmem_node(pgdat, bitmap_size);
>  		}
>  	}
> -	build_zonelists(pgdat);
>  }
>  
>  void __init free_area_init(unsigned long *zones_size)
> 
> 
> 
> -- 
> Thanks
> 
> Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com
> 
> 

-- 
Bjorn Helgaas - bjorn.helgaas at hp.com
Linux and Open Source Lab
Hewlett-Packard Company

