From: Russ Anderson <rja@sgi.com>
Date: Thu, 06 Jan 2005 23:17:37 +0000
Subject: Re: [patch] per cpu MCA/INIT fixes.
Message-Id: <200501062317.j06NHba3217633@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200501060308.j0638M7s194286@ben.americas.sgi.com>
In-Reply-To: <200501060308.j0638M7s194286@ben.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony Luck wrote:
> >The above will probably conflict with Jack's recent change to 
> >stagger the per-node structures by one cacheline.  You may have to rediff 
> >against one of Tony's test trees.
> 
> I just applied and pushed Jack's patch to the test-2.6.11 tree, Russ, can
> you fix up your patch to apply cleanly on top of Jack's.
> 
> >> +#ifdef CONFIG_SMP
> >> +#include <asm/mca.h>
> >> +#endif
> >
> >Just a nit, header files should always be safe to include 
> >unconditionally.  If they're not, the headers need fixing (barring out of tree 
> >stuff like kdb of course).
> 
> Agreed ... this looks really ugly ... surely we want to support MCA
> on uni-processors as well as SMP!  What's the issue that provoked
> adding the #ifdef here?

An updated patch that applies on Jack's and builds with zx1 & tiger UP.
The SGI UP is previously broke.  Jesse is working on that.


--------------------------------------------------------------------------------------
Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2005-01-06 13:16:41.149172632 -0600
+++ linux/include/asm-ia64/mca.h	2005-01-06 16:02:51.004769134 -0600
@@ -61,6 +61,8 @@
 
 } ia64_mc_info_t;
 
+#define PERCPU_MCA_SIZE sizeof(struct ia64_mc_info_s)
+
 typedef struct ia64_mca_sal_to_os_state_s {
 	u64		imsto_os_gp;		/* GP of the os registered with the SAL */
 	u64		imsto_pal_proc;		/* PAL_PROC entry point - physical addr */
Index: linux/arch/ia64/mm/init.c
=================================--- linux.orig/arch/ia64/mm/init.c	2005-01-06 13:16:41.150149091 -0600
+++ linux/arch/ia64/mm/init.c	2005-01-06 13:19:59.042306891 -0600
@@ -287,12 +287,32 @@
 	ia64_patch_gate();
 }
 
+void
+set_mca_pointer(struct cpuinfo_ia64 *cpuinfo, void *cpu_data)
+{
+	void *my_cpu_data = ia64_imva(cpu_data);
+
+        /*
+         * The MCA info structure was allocated earlier and a physical address pointer
+         * saved in __per_cpu_mca[cpu].  Move that pointer into the cpuinfo structure.
+         */
+
+        cpuinfo->ia64_pa_mca_data = (__u64 *)__per_cpu_mca[smp_processor_id()];
+
+        cpuinfo->percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
+        ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(cpuinfo));
+
+        /*
+         * Set pal_base and pal_paddr in cpuinfo structure.
+         */
+        efi_get_pal_addr();
+}
+
 void __devinit
 ia64_mmu_init (void *my_cpu_data)
 {
 	unsigned long psr, pta, impl_va_bits;
 	extern void __devinit tlb_init (void);
-	struct cpuinfo_ia64 *cpuinfo;
 
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
@@ -357,22 +377,6 @@
 	ia64_set_rr(HPAGE_REGION_BASE, HPAGE_SHIFT << 2);
 	ia64_srlz_d();
 #endif
-
-	/*
-	 * The MCA info structure was allocated earlier and a physical address pointer
-	 * saved in k3.  Move that pointer into the cpuinfo structure and save
-	 * the physical address of the cpuinfo structure in k3.
-	 */
-	cpuinfo = (struct cpuinfo_ia64 *)my_cpu_data;
-	cpuinfo->ia64_pa_mca_data = (__u64 *)ia64_get_kr(IA64_KR_PA_CPU_INFO);
-
-	cpuinfo->percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
-	ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(my_cpu_data));
-
-	/*
-	 * Set pal_base and pal_paddr in cpuinfo structure.
-	 */
-	efi_get_pal_addr();
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2005-01-06 13:16:56.624098123 -0600
+++ linux/arch/ia64/mm/discontig.c	2005-01-06 13:19:59.044259810 -0600
@@ -350,12 +350,12 @@
 		mem_data[node].node_data = __va(pernode);
 		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
-		mca_data_phys = (void *)pernode;
-		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
-
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
+		mca_data_phys = (void *)pernode;
+		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+
 		/*
 		 * Copy the static per-cpu data into the region we
 		 * just set aside and then setup __per_cpu_offset
@@ -370,13 +370,11 @@
 					 * The memory for the cpuinfo structure is allocated
 					 * here, but the data in the structure is initialized
 					 * later.  Save the physical address of the MCA save
-					 * area in IA64_KR_PA_CPU_INFO.  When the cpuinfo struct 
-					 * is initialized, the value in IA64_KR_PA_CPU_INFO
-					 * will be put in the cpuinfo structure and 
-					 * IA64_KR_PA_CPU_INFO will be set to the physical
-					 * addresss of the cpuinfo structure.
+					 * area in __per_cpu_mca[cpu].  When the cpuinfo struct 
+					 * is initialized, the value in __per_cpu_mca[cpu]
+					 * will be put in the cpuinfo structure.
 					 */
-					ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(mca_data_phys));
+					__per_cpu_mca[cpu] = __pa(mca_data_phys);
 					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
 				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
Index: linux/arch/ia64/kernel/efi.c
=================================--- linux.orig/arch/ia64/kernel/efi.c	2005-01-06 13:16:41.170654735 -0600
+++ linux/arch/ia64/kernel/efi.c	2005-01-06 13:19:59.056953780 -0600
@@ -414,15 +414,15 @@
  * ITR to enable safe PAL calls in virtual mode.  See IA-64 Processor
  * Abstraction Layer chapter 11 in ADAG
  */
-void
-efi_map_pal_code (void)
+
+static efi_memory_desc_t *
+pal_code_memdesc (void)
 {
 	void *efi_map_start, *efi_map_end, *p;
 	efi_memory_desc_t *md;
 	u64 efi_desc_size;
 	int pal_code_count = 0;
-	u64 mask, psr;
-	u64 vaddr;
+	u64 vaddr, mask;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -466,91 +466,58 @@
 		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
 			panic("Woah!  PAL code size bigger than a granule!");
 
-		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 #if EFI_DEBUG
+		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
+
 		printk(KERN_INFO "CPU %d: mapping PAL code [0x%lx-0x%lx) into [0x%lx-0x%lx)\n",
-		       smp_processor_id(), md->phys_addr,
-		       md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
-		       vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
+			smp_processor_id(), md->phys_addr,
+			md->phys_addr + (md->num_pages << EFI_PAGE_SHIFT),
+			vaddr & mask, (vaddr & mask) + IA64_GRANULE_SIZE);
 #endif
-
-		/*
-		 * Cannot write to CRx with PSR.ic=1
-		 */
-		psr = ia64_clear_ic();
-		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
-			 pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
-			 IA64_GRANULE_SHIFT);
-		ia64_set_psr(psr);		/* restore psr */
-		ia64_srlz_i();
-
+		return md;
 	}
+
+	return NULL;
 }
 
-/* 
- * Put pal_base and pal_paddr in the cpuinfo structure.
- */
 void
-efi_get_pal_addr(void)
+efi_get_pal_addr (void)
 {
-	void *efi_map_start, *efi_map_end, *p;
-	efi_memory_desc_t *md;
-	u64 efi_desc_size;
-	int pal_code_count = 0;
-	u64 mask;
-	u64 vaddr;
+	efi_memory_desc_t *md = pal_code_memdesc();
+	u64 vaddr, mask;
 	struct cpuinfo_ia64 *cpuinfo;
 
-	efi_map_start = __va(ia64_boot_param->efi_memmap);
-	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
-	efi_desc_size = ia64_boot_param->efi_memdesc_size;
-
-	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
-		md = p;
-		if (md->type != EFI_PAL_CODE)
-			continue;
+	if (md != NULL) {
 
-		if (++pal_code_count > 1) {
-			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
-			       md->phys_addr);
-			continue;
-		}
-		/*
-		 * The only ITLB entry in region 7 that is used is the one installed by
-		 * __start().  That entry covers a 64MB range.
-		 */
-		mask  = ~((1 << KERNEL_TR_PAGE_SHIFT) - 1);
 		vaddr = PAGE_OFFSET + md->phys_addr;
-
-		/*
-		 * We must check that the PAL mapping won't overlap with the kernel
-		 * mapping.
-		 *
-		 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
-		 * 256KB and that only one ITR is needed to map it. This implies that the
-		 * PAL code is always aligned on its size, i.e., the closest matching page
-		 * size supported by the TLB. Therefore PAL code is guaranteed never to
-		 * cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
-		 * now the following test is enough to determine whether or not we need a
-		 * dedicated ITR for the PAL code.
-		 */
-		if ((vaddr & mask) = (KERNEL_START & mask)) {
-			printk(KERN_INFO "%s: no need to install ITR for PAL code\n",
-			       __FUNCTION__);
-			continue;
-		}
-
-		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
-			panic("Woah!  PAL code size bigger than a granule!");
-
 		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 
-		/* insert this TR into our list for MCA recovery purposes */
 		cpuinfo = (struct cpuinfo_ia64 *)__va(ia64_get_kr(IA64_KR_PA_CPU_INFO));
 		cpuinfo->pal_base = vaddr & mask;
 		cpuinfo->pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
-		printk(KERN_INFO "CPU %d: late efi pal_base 0x%lx pal_paddr 0x%lx\n",
-			smp_processor_id(), cpuinfo->pal_base, cpuinfo->pal_paddr);
+	}
+}
+
+void
+efi_map_pal_code (void)
+{
+	efi_memory_desc_t *md = pal_code_memdesc();
+	u64 vaddr, mask, psr;
+
+	if (md != NULL) {
+
+		vaddr = PAGE_OFFSET + md->phys_addr;
+		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
+
+		/*
+		 * Cannot write to CRx with PSR.ic=1
+		 */
+		psr = ia64_clear_ic();
+		ia64_itr(0x1, IA64_TR_PALCODE, vaddr & mask,
+			pte_val(pfn_pte(md->phys_addr >> PAGE_SHIFT, PAGE_KERNEL)),
+			IA64_GRANULE_SHIFT);
+		ia64_set_psr(psr);		/* restore psr */
+		ia64_srlz_i();
 	}
 }
 
Index: linux/arch/ia64/kernel/setup.c
=================================--- linux.orig/arch/ia64/kernel/setup.c	2005-01-06 13:16:41.171631194 -0600
+++ linux/arch/ia64/kernel/setup.c	2005-01-06 15:24:29.152848789 -0600
@@ -60,6 +60,7 @@
 unsigned long __per_cpu_offset[NR_CPUS];
 EXPORT_SYMBOL(__per_cpu_offset);
 #endif
+unsigned long __per_cpu_mca[NR_CPUS];
 
 DEFINE_PER_CPU(struct cpuinfo_ia64, cpu_info);
 DEFINE_PER_CPU(unsigned long, local_per_cpu_offset);
@@ -574,6 +575,7 @@
 cpu_init (void)
 {
 	extern void __devinit ia64_mmu_init (void *);
+	extern void set_mca_pointer (struct cpuinfo_ia64 *, void *);
 	unsigned long num_phys_stacked;
 	pal_vm_info_2_u_t vmi;
 	unsigned int max_ctx;
@@ -628,6 +630,7 @@
 		BUG();
 
 	ia64_mmu_init(ia64_imva(cpu_data));
+	set_mca_pointer(cpu_info, cpu_data);
 
 #ifdef CONFIG_IA32_SUPPORT
 	ia32_cpu_init();
Index: linux/arch/ia64/mm/contig.c
=================================--- linux.orig/arch/ia64/mm/contig.c	2005-01-06 13:16:41.151125551 -0600
+++ linux/arch/ia64/mm/contig.c	2005-01-06 16:01:15.956171788 -0600
@@ -24,6 +24,7 @@
 #include <asm/pgalloc.h>
 #include <asm/pgtable.h>
 #include <asm/sections.h>
+#include <asm/mca.h>
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 static unsigned long num_dma_physpages;
@@ -177,7 +178,7 @@
 void *
 per_cpu_init (void)
 {
-	void *cpu_data;
+	void *cpu_data, *mca_data;
 	int cpu;
 
 	/*
@@ -188,11 +189,15 @@
 	if (smp_processor_id() = 0) {
 		cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
 					   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
+		mca_data = __alloc_bootmem(PERCPU_MCA_SIZE * NR_CPUS,
+					   PERCPU_MCA_SIZE, __pa(MAX_DMA_ADDRESS));
 		for (cpu = 0; cpu < NR_CPUS; cpu++) {
 			memcpy(cpu_data, __phys_per_cpu_start, __per_cpu_end - __per_cpu_start);
 			__per_cpu_offset[cpu] = (char *) cpu_data - __per_cpu_start;
 			cpu_data += PERCPU_PAGE_SIZE;
 			per_cpu(local_per_cpu_offset, cpu) = __per_cpu_offset[cpu];
+			__per_cpu_mca[cpu] = (unsigned long)mca_data;
+			mca_data += PERCPU_MCA_SIZE;
 		}
 	}
 	return __per_cpu_start + __per_cpu_offset[smp_processor_id()];
Index: linux/include/asm-ia64/percpu.h
=================================--- linux.orig/include/asm-ia64/percpu.h	2005-01-06 13:16:41.149172632 -0600
+++ linux/include/asm-ia64/percpu.h	2005-01-06 15:25:19.889677562 -0600
@@ -56,6 +56,8 @@
 
 #endif	/* SMP */
 
+extern unsigned long __per_cpu_mca[NR_CPUS];
+
 #define EXPORT_PER_CPU_SYMBOL(var)		EXPORT_SYMBOL(per_cpu__##var)
 #define EXPORT_PER_CPU_SYMBOL_GPL(var)		EXPORT_SYMBOL_GPL(per_cpu__##var)
 
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2005-01-06 13:16:41.171631194 -0600
+++ linux/arch/ia64/kernel/mca_asm.S	2005-01-06 13:19:59.070624210 -0600
@@ -147,7 +147,6 @@
 	GET_PERCPU_PADDR(r2)	// paddr of percpu_paddr in cpuinfo struct
 	;;
 	mov	r17=r2
-	mov 	r23=r2		// save current ia64_mca_percpu_info addr pointer.
 	;;
 	adds r17=8,r17
 	;;
@@ -247,7 +246,9 @@
 	srlz.d
 	;;
 	// 2. Reload DTR register for PERCPU data.
-	mov r17=r23
+	GET_PERCPU_PADDR(r2)		// paddr of percpu_paddr in cpuinfo struct
+	;;
+	mov r17=r2
 	movl r16=PERCPU_ADDR		// vaddr
 	movl r18=PERCPU_PAGE_SHIFT<<2
 	;;
@@ -262,7 +263,9 @@
 	srlz.d
 	;;
 	// 3. Reload ITR for PAL code.
-	adds r17@,r23
+	GET_CPUINFO_PAL_PADDR(r2)	// paddr of pal_paddr in cpuinfo struct
+	;;
+	mov r17=r2
 	;;
 	ld8 r18=[r17],8			// pte
 	;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2005-01-06 13:16:41.171631194 -0600
+++ linux/arch/ia64/kernel/asm-offsets.c	2005-01-06 16:02:33.841535054 -0600
@@ -205,6 +205,7 @@
 	BLANK();
 	/* used by arch/ia64/kernel/mca_asm.S */
 	DEFINE(IA64_CPUINFO_PERCPU_PADDR, offsetof (struct cpuinfo_ia64, percpu_paddr));
+	DEFINE(IA64_CPUINFO_PAL_PADDR, offsetof (struct cpuinfo_ia64, pal_paddr));
 	DEFINE(IA64_CPUINFO_PA_MCA_INFO, offsetof (struct cpuinfo_ia64, ia64_pa_mca_data));
 	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
 	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
Index: linux/include/asm-ia64/mca_asm.h
=================================--- linux.orig/include/asm-ia64/mca_asm.h	2005-01-06 13:16:41.150149091 -0600
+++ linux/include/asm-ia64/mca_asm.h	2005-01-06 13:19:59.072577129 -0600
@@ -53,6 +53,10 @@
 	mov	reg	= ar.k3;;						\
 	addl	reg	= IA64_CPUINFO_PERCPU_PADDR,reg
 
+#define GET_CPUINFO_PAL_PADDR(reg)						\
+	mov	reg	= ar.k3;;						\
+	addl	reg	= IA64_CPUINFO_PAL_PADDR,reg
+
 /*
  * This macro gets the physical address of this cpu's MCA save structure.
  */

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
