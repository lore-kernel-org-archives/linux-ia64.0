From: Russ Anderson <rja@sgi.com>
Date: Fri, 10 Dec 2004 02:01:21 +0000
Subject: [patch] per cpu MCA/INIT save areas (take 3)
Message-Id: <200412100201.iBA21LtP173001@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Changes from the previous patch:

  * mm/init.c: Add efi_get_pal_addr() call to set pal_base and pal_paddr
    in cpuinfo later in the init process.  

  * efi.c: Add efi_get_pal_addr() to set pal_base and pal_paddr.

  * mca_asm.S: Remove extra stop bits.  
	Added some syntactic sugar macros.
	Make init stack per cpu, too.

  * minstate.h: Modify MINSTATE_START_SAVE_MIN_PHYS to use ar.k3.

  * Generate patch at correct level.

-----------------------------------------------------------------

High level description:

  Linux currently has one MCA & INIT save area for saving
  stack and other data.  This patch creates per cpu MCA 
  save areas, so that each cpu can save its own MCA stack 
  data.  CPU register ar.k3 is used to hold a physical 
  address pointer to the cpuinfo structure.  The cpuinfo
  structure has a physical address pointer to the MCA save 
  area.  The MCA handler runs in physical mode and the 
  physical address pointer avoids the problems associated
  with doing the virtual to physical translation.

  The per MCA save areas replace the global areas defined
  in arch/ia64/kernel/mca.c for MCA processor state dump, 
  MCA stack, MCA stack frame, and MCA bspstore.

  The code to access those save areas is updated to use the
  per cpu save areas.

  No changes are made to the MCA flow, ie all the old locks
  are still in place.  The point of this patch is to establish
  the per cpu save areas.  Additional usage of the save areas,
  such as enabling concurrent INIT or MCA handling, will be
  the subject of other patches.

Detailed description:

  include/asm-ia64/processor.h
	Add a physical address pointer to cpuinfo.
	Add pal_paddr, pal_base, and percpu_paddr to cpuinfo.

  include/asm-ia64/mca.h

	Define the structure layout of the MCA/INIT save area.
	Remove ia64_mca_tlb_info structure.  pal_paddr and
	pal_base are moved to the cpuinfo structure.

  include/asm-ia64/kregs.h

	Define ar.k3 as used for physical address pointer
	to this cpu's cpuinfo structure.

  arch/ia64/mm/init.c

	Replace global array ia64_mca_tlb_list with 
	ar.k3 pointing to this cpu's cpuinfo structure.
	Set physical address pointer to MCA save area in
	this cpu's cpuinfo structure.

  arch/ia64/mm/discontig.c

	On each node, allocate MCA/INIT space for each
	cpu that physically exists.  

  arch/ia64/kernel/asm-offsets.c

	Define assembler constants to correspond with
	the c structure layout of cpuinfo and the MCA/INIT 
	save area.

  arch/ia64/kernel/mca.c

	Remove the global save areas: 
		ia64_mca_proc_state_dump,
		ia64_mca_stack, 
		ia64_mca_stackframe,
		ia64_mca_bspstore,
		ia64_init_stack
		ia64_mca_tlb_info[NR_CPUS];

  arch/ia64/kernel/efi.c
	Add efi_get_pal_addr() to set pal_paddr and pal_base
	in cpuinfo.  Remove ia64_mca_tlb_list[] references.

  arch/ia64/kernel/mca_asm.S

	Replace the global MCA save pointers with the
	per CPU equivalents.  Replace ia64_mca_tlb_list
	with cpuinfo equivalents.

Testing:

  	Tested on SGI Altix by injecting memory multibit errors.  
	Additional testing on other platforms is welcome.

Signed-off-by: Russ Anderson <rja@sgi.com>

-----------------------------------------------------------------
Index: linux/include/asm-ia64/processor.h
=================================--- linux.orig/include/asm-ia64/processor.h	2004-12-07 14:36:53.178200157 -0600
+++ linux/include/asm-ia64/processor.h	2004-12-07 14:37:05.671022257 -0600
@@ -151,9 +151,12 @@
 	__u64 itc_freq;		/* frequency of ITC counter */
 	__u64 proc_freq;	/* frequency of processor */
 	__u64 cyc_per_usec;	/* itc_freq/1000000 */
+	__u64 percpu_paddr;
 	__u64 ptce_base;
 	__u32 ptce_count[2];
 	__u32 ptce_stride[2];
+	__u64 pal_paddr;
+	__u64 pal_base;
 	struct task_struct *ksoftirqd;	/* kernel softirq daemon for this CPU */
 
 #ifdef CONFIG_SMP
@@ -174,6 +177,7 @@
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
 #endif
+	__u64 *ia64_pa_mca_data;	/* prt to MCA/INIT processor state */
 };
 
 DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2004-12-07 14:36:53.187964752 -0600
+++ linux/include/asm-ia64/mca.h	2004-12-07 20:37:48.557485891 -0600
@@ -5,6 +5,7 @@
  * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
+ * Copyright (C) Russ Anderson (rja@sgi.com)
  */
 
 #ifndef _ASM_IA64_MCA_H
@@ -48,17 +49,6 @@
 	IA64_MCA_RENDEZ_CHECKIN_DONE	=	0x1
 };
 
-/* the following data structure is used for TLB error recovery purposes */
-extern struct ia64_mca_tlb_info {
-	u64	cr_lid;
-	u64	percpu_paddr;
-	u64	ptce_base;
-	u32	ptce_count[2];
-	u32	ptce_stride[2];
-	u64	pal_paddr;
-	u64	pal_base;
-} ia64_mca_tlb_list[NR_CPUS];
-
 /* Information maintained by the MC infrastructure */
 typedef struct ia64_mc_info_s {
 	u64		imi_mca_handler;
@@ -112,6 +102,18 @@
 						 */
 } ia64_mca_os_to_sal_state_t;
 
+#define IA64_MCA_STACK_SIZE 	1024
+#define IA64_MCA_STACK_SIZE_BYTES 	(1024 * 8)
+#define IA64_MCA_BSPSTORE_SIZE 	1024
+
+typedef struct ia64_mca_cpu_s {
+	u64	ia64_mca_stack[IA64_MCA_STACK_SIZE] 		__attribute__((aligned(16)));
+	u64	ia64_mca_proc_state_dump[512] 			__attribute__((aligned(16)));
+	u64	ia64_mca_stackframe[32]				__attribute__((aligned(16)));
+	u64	ia64_mca_bspstore[IA64_MCA_BSPSTORE_SIZE] 	__attribute__((aligned(16)));
+	u64	ia64_init_stack[KERNEL_STACK_SIZE] 		__attribute__((aligned(16)));
+} ia64_mca_cpu_t;
+
 extern void ia64_mca_init(void);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
Index: linux/include/asm-ia64/kregs.h
=================================--- linux.orig/include/asm-ia64/kregs.h	2004-12-07 14:36:53.187964752 -0600
+++ linux/include/asm-ia64/kregs.h	2004-12-07 14:37:31.536456331 -0600
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define IA64_KR_PA_CPU_INFO	3	/* ar.k3: phys addr of this cpu's cpu_info struct */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
Index: linux/arch/ia64/mm/init.c
=================================--- linux.orig/arch/ia64/mm/init.c	2004-12-07 14:36:53.188941211 -0600
+++ linux/arch/ia64/mm/init.c	2004-12-07 16:12:17.769013209 -0600
@@ -40,6 +40,7 @@
 DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 
 extern void ia64_tlb_init (void);
+extern void efi_get_pal_addr (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
 
@@ -279,7 +280,7 @@
 {
 	unsigned long psr, pta, impl_va_bits;
 	extern void __devinit tlb_init (void);
-	int cpu;
+	struct cpuinfo_ia64 *cpuinfo;
 
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
@@ -345,19 +346,21 @@
 	ia64_srlz_d();
 #endif
 
-	cpu = smp_processor_id();
+	/*
+	 * The MCA info structure was allocated earlier and a physical address pointer
+	 * saved in k3.  Move that pointer into the cpuinfo structure and save
+	 * the physical address of the cpuinfo structure in k3.
+	 */
+	cpuinfo = (struct cpuinfo_ia64 *)my_cpu_data;
+	cpuinfo->ia64_pa_mca_data = (__u64 *)ia64_get_kr(IA64_KR_PA_CPU_INFO);
 
-	/* mca handler uses cr.lid as key to pick the right entry */
-	ia64_mca_tlb_list[cpu].cr_lid = ia64_getreg(_IA64_REG_CR_LID);
+	cpuinfo->percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
+	ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(my_cpu_data));
 
-	/* insert this percpu data information into our list for MCA recovery purposes */
-	ia64_mca_tlb_list[cpu].percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
-	/* Also save per-cpu tlb flush recipe for use in physical mode mca handler */
-	ia64_mca_tlb_list[cpu].ptce_base = local_cpu_data->ptce_base;
-	ia64_mca_tlb_list[cpu].ptce_count[0] = local_cpu_data->ptce_count[0];
-	ia64_mca_tlb_list[cpu].ptce_count[1] = local_cpu_data->ptce_count[1];
-	ia64_mca_tlb_list[cpu].ptce_stride[0] = local_cpu_data->ptce_stride[0];
-	ia64_mca_tlb_list[cpu].ptce_stride[1] = local_cpu_data->ptce_stride[1];
+	/*
+	 * Set pal_base and pal_paddr in cpuinfo structure.
+	 */
+	efi_get_pal_addr();
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2004-12-07 14:36:53.188941211 -0600
+++ linux/arch/ia64/mm/discontig.c	2004-12-07 14:37:05.675904554 -0600
@@ -4,6 +4,10 @@
  * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
+ * Copyright (c) 2004 Silicon Graphics, Inc
+ *	Russ Anderson <rja@sgi.com>
+ *	Jesse Barnes <jbarnes@sgi.com>
+ *	Jack Steiner <steiner@sgi.com>
  */
 
 /*
@@ -22,6 +26,7 @@
 #include <asm/meminit.h>
 #include <asm/numa.h>
 #include <asm/sections.h>
+#include <asm/mca.h>
 
 /*
  * Track per-node information needed to setup the boot memory allocator, the
@@ -220,12 +225,34 @@
 }
 
 /**
+ * early_nr_phys_cpus_node - return number of physical cpus on a given node
+ * @node: node to check
+ *
+ * Count the number of physical cpus on @node.  These are cpus that actually
+ * exist.  We can't use nr_cpus_node() yet because
+ * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
+ * called yet.
+ */
+static int early_nr_phys_cpus_node(int node)
+{
+	int cpu, n = 0;
+
+	for (cpu = 0; cpu < NR_CPUS; cpu++)
+		if (node = node_cpuid[cpu].nid)
+			if ((cpu = 0) || node_cpuid[cpu].phys_id)
+				n++;
+
+	return n;
+}
+
+
+/**
  * early_nr_cpus_node - return number of cpus on a given node
  * @node: node to check
  *
  * Count the number of cpus on @node.  We can't use nr_cpus_node() yet because
  * acpi_boot_init() (which builds the node_to_cpu_mask array) hasn't been
- * called yet.
+ * called yet.  Note that node 0 will also count all non-existent cpus.
  */
 static int early_nr_cpus_node(int node)
 {
@@ -252,12 +279,15 @@
  *   |                        |
  *   |~~~~~~~~~~~~~~~~~~~~~~~~| <-- NODEDATA_ALIGN(start, node) for the first
  *   |    PERCPU_PAGE_SIZE *  |     start and length big enough
- *   |        NR_CPUS         |
+ *   |    cpus_on_this_node   | Node 0 will also have entries for all non-existent cpus.
  *   |------------------------|
  *   |   local pg_data_t *    |
  *   |------------------------|
  *   |  local ia64_node_data  |
  *   |------------------------|
+ *   |    MCA/INIT data *     |
+ *   |    cpus_on_this_node   |
+ *   |------------------------|
  *   |          ???           |
  *   |________________________|
  *
@@ -269,9 +299,9 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpu, cpus, phys_cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	void *cpu_data;
+	void *cpu_data, *mca_data_phys;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
 
 	epfn = (start + len) >> PAGE_SHIFT;
@@ -295,9 +325,11 @@
 	 * for good alignment and alias prevention.
 	 */
 	cpus = early_nr_cpus_node(node);
+	phys_cpus = early_nr_phys_cpus_node(node);
 	pernodesize += PERCPU_PAGE_SIZE * cpus;
 	pernodesize += L1_CACHE_ALIGN(sizeof(pg_data_t));
 	pernodesize += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
+	pernodesize += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
 	pernodesize = PAGE_ALIGN(pernodesize);
 	pernode = NODEDATA_ALIGN(start, node);
 
@@ -316,6 +348,9 @@
 		mem_data[node].node_data = __va(pernode);
 		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
+		mca_data_phys = (void *)pernode;
+		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
@@ -328,6 +363,20 @@
 			if (node = node_cpuid[cpu].nid) {
 				memcpy(__va(cpu_data), __phys_per_cpu_start,
 				       __per_cpu_end - __per_cpu_start);
+				if ((cpu = 0) || (node_cpuid[cpu].phys_id > 0)) {
+					/* 
+					 * The memory for the cpuinfo structure is allocated
+					 * here, but the data in the structure is initialized
+					 * later.  Save the physical address of the MCA save
+					 * area in IA64_KR_PA_CPU_INFO.  When the cpuinfo struct 
+					 * is initialized, the value in IA64_KR_PA_CPU_INFO
+					 * will be put in the cpuinfo structure and 
+					 * IA64_KR_PA_CPU_INFO will be set to the physical
+					 * addresss of the cpuinfo structure.
+					 */
+					ia64_set_kr(IA64_KR_PA_CPU_INFO, __pa(mca_data_phys));
+					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
+				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
 				cpu_data += PERCPU_PAGE_SIZE;
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2004-12-07 14:36:53.189917671 -0600
+++ linux/arch/ia64/kernel/mca.c	2004-12-07 23:20:43.505921076 -0600
@@ -85,11 +85,6 @@
 /* Used by mca_asm.S */
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
-u64				ia64_mca_proc_state_dump[512];
-u64				ia64_mca_stack[1024] __attribute__((aligned(16)));
-u64				ia64_mca_stackframe[32];
-u64				ia64_mca_bspstore[1024];
-u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
 u64				ia64_mca_serialize;
 
 /* In mca_asm.S */
@@ -98,8 +93,6 @@
 
 static ia64_mc_info_t		ia64_mc_info;
 
-struct ia64_mca_tlb_info ia64_mca_tlb_list[NR_CPUS];
-
 #define MAX_CPE_POLL_INTERVAL (15*60*HZ) /* 15 minutes */
 #define MIN_CPE_POLL_INTERVAL (2*60*HZ)  /* 2 minutes */
 #define CMC_POLL_INTERVAL     (1*60*HZ)  /* 1 minute */
Index: linux/arch/ia64/kernel/efi.c
=================================--- linux.orig/arch/ia64/kernel/efi.c	2004-12-07 14:36:53.189917671 -0600
+++ linux/arch/ia64/kernel/efi.c	2004-12-07 16:21:01.558369027 -0600
@@ -423,7 +423,6 @@
 	int pal_code_count = 0;
 	u64 mask, psr;
 	u64 vaddr;
-	int cpu;
 
 	efi_map_start = __va(ia64_boot_param->efi_memmap);
 	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
@@ -485,11 +484,73 @@
 		ia64_set_psr(psr);		/* restore psr */
 		ia64_srlz_i();
 
-		cpu = smp_processor_id();
+	}
+}
+
+/* 
+ * Put pal_base and pal_paddr in the cpuinfo structure.
+ */
+void
+efi_get_pal_addr(void)
+{
+	void *efi_map_start, *efi_map_end, *p;
+	efi_memory_desc_t *md;
+	u64 efi_desc_size;
+	int pal_code_count = 0;
+	u64 mask;
+	u64 vaddr;
+	struct cpuinfo_ia64 *cpuinfo;
+
+	efi_map_start = __va(ia64_boot_param->efi_memmap);
+	efi_map_end   = efi_map_start + ia64_boot_param->efi_memmap_size;
+	efi_desc_size = ia64_boot_param->efi_memdesc_size;
+
+	for (p = efi_map_start; p < efi_map_end; p += efi_desc_size) {
+		md = p;
+		if (md->type != EFI_PAL_CODE)
+			continue;
+
+		if (++pal_code_count > 1) {
+			printk(KERN_ERR "Too many EFI Pal Code memory ranges, dropped @ %lx\n",
+			       md->phys_addr);
+			continue;
+		}
+		/*
+		 * The only ITLB entry in region 7 that is used is the one installed by
+		 * __start().  That entry covers a 64MB range.
+		 */
+		mask  = ~((1 << KERNEL_TR_PAGE_SHIFT) - 1);
+		vaddr = PAGE_OFFSET + md->phys_addr;
+
+		/*
+		 * We must check that the PAL mapping won't overlap with the kernel
+		 * mapping.
+		 *
+		 * PAL code is guaranteed to be aligned on a power of 2 between 4k and
+		 * 256KB and that only one ITR is needed to map it. This implies that the
+		 * PAL code is always aligned on its size, i.e., the closest matching page
+		 * size supported by the TLB. Therefore PAL code is guaranteed never to
+		 * cross a 64MB unless it is bigger than 64MB (very unlikely!).  So for
+		 * now the following test is enough to determine whether or not we need a
+		 * dedicated ITR for the PAL code.
+		 */
+		if ((vaddr & mask) = (KERNEL_START & mask)) {
+			printk(KERN_INFO "%s: no need to install ITR for PAL code\n",
+			       __FUNCTION__);
+			continue;
+		}
+
+		if (md->num_pages << EFI_PAGE_SHIFT > IA64_GRANULE_SIZE)
+			panic("Woah!  PAL code size bigger than a granule!");
+
+		mask  = ~((1 << IA64_GRANULE_SHIFT) - 1);
 
 		/* insert this TR into our list for MCA recovery purposes */
-		ia64_mca_tlb_list[cpu].pal_base = vaddr & mask;
-		ia64_mca_tlb_list[cpu].pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
+		cpuinfo = (struct cpuinfo_ia64 *)__va(ia64_get_kr(IA64_KR_PA_CPU_INFO));
+		cpuinfo->pal_base = vaddr & mask;
+		cpuinfo->pal_paddr = pte_val(mk_pte_phys(md->phys_addr, PAGE_KERNEL));
+		printk(KERN_INFO "CPU %d: late efi pal_base 0x%lx pal_paddr 0x%lx\n",
+			smp_processor_id(), cpuinfo->pal_base, cpuinfo->pal_paddr);
 	}
 }
 
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2004-12-07 14:36:53.189917671 -0600
+++ linux/arch/ia64/kernel/mca_asm.S	2004-12-08 22:38:11.897996104 -0600
@@ -13,6 +13,9 @@
 //		   2. Restore current thread pointer to kr6
 //		   3. Move stack ptr 16 bytes to conform to C calling convention
 //
+// 04/11/12 Russ Anderson <rja@sgi.com>
+//		   Added per cpu MCA/INIT stack save areas.
+//
 #include <linux/config.h>
 #include <linux/threads.h>
 
@@ -102,11 +105,6 @@
 	.global ia64_os_mca_dispatch_end
 	.global ia64_sal_to_os_handoff_state
 	.global	ia64_os_to_sal_handoff_state
-	.global	ia64_mca_proc_state_dump
-	.global	ia64_mca_stack
-	.global	ia64_mca_stackframe
-	.global	ia64_mca_bspstore
-	.global ia64_init_stack
 
 	.text
 	.align 16
@@ -146,23 +144,12 @@
 	// The following code purges TC and TR entries. Then reload all TC entries.
 	// Purge percpu data TC entries.
 begin_tlb_purge_and_reload:
-	mov r16=cr.lid
-	LOAD_PHYSICAL(p0,r17,ia64_mca_tlb_list) // Physical address of ia64_mca_tlb_list
-	mov r19=0
-	mov r20=NR_CPUS
-	;;
-1:	cmp.eq p6,p7=r19,r20
-(p6)	br.spnt.few err
-	ld8 r18=[r17],IA64_MCA_TLB_INFO_SIZE
-	;;
-	add r19=1,r19
-	cmp.eq p6,p7=r18,r16
-(p7)	br.sptk.few 1b
+	GET_PERCPU_PADDR(r2)	// paddr of percpu_paddr in cpuinfo struct
 	;;
-	adds r17=-IA64_MCA_TLB_INFO_SIZE,r17
+	mov	r17=r2
+	mov 	r23=r2		// save current ia64_mca_percpu_info addr pointer.
 	;;
-	mov r23=r17		// save current ia64_mca_percpu_info addr pointer.
-	adds r17,r17
+	adds r17=8,r17
 	;;
 	ld8 r18=[r17],8		// r18=ptce_base
   	;;
@@ -215,7 +202,7 @@
 	srlz.d
 	;;
 	// 3. Purge ITR for PAL code.
-	adds r17H,r23
+	adds r17@,r23
 	;;
 	ld8 r16=[r17]
 	mov r18=IA64_GRANULE_SHIFT<<2
@@ -260,7 +247,7 @@
 	srlz.d
 	;;
 	// 2. Reload DTR register for PERCPU data.
-	adds r17=8,r23
+	mov r17=r23
 	movl r16=PERCPU_ADDR		// vaddr
 	movl r18=PERCPU_PAGE_SHIFT<<2
 	;;
@@ -318,17 +305,14 @@
 done_tlb_purge_and_reload:
 
 	// Setup new stack frame for OS_MCA handling
-	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in r2
-	DATA_VA_TO_PA(r2);;
-	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
-	DATA_VA_TO_PA(r3);;
+	GET_MCA_BSPSTORE(r2)		// paddr of bspstore save area
+	GET_MCA_STACKFRAME(r3);;	// paddr of stack frame save area
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
-	movl	r12=ia64_mca_stack
-	mov	r2=8*1024;;		// stack size must be same as C array
-	add	r12=r2,r12;;		// stack base @ bottom of array
-	adds	r12=-16,r12;;		// allow 16 bytes of scratch
+	GET_MCA_STACK(r2);;		// paddr of stack save area
+					// stack size must be same as C array
+	addl	r2=8*1024-16,r2;;	// stack base @ bottom of array
+	mov	r12=r2			// allow 16 bytes of scratch
 					// (C calling convention)
-	DATA_VA_TO_PA(r12);;
 
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
@@ -344,9 +328,7 @@
 ia64_os_mca_virtual_end:
 
 	// restore the original stack frame here
-	movl    r2=ia64_mca_stackframe	// restore stack frame from memory at r2
-	;;
-	DATA_VA_TO_PA(r2)
+	GET_MCA_STACKFRAME(r2);;	// phys addr of MCA save area
 	movl    r4=IA64_PSR_MC
 	;;
 	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
@@ -387,7 +369,7 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump area to physical address
+	GET_MCA_DUMP_PADDR(r2);;  // phys addr of MCA save area
 
 // save ar.NaT
 	mov		r5=ar.unat                  // ar.unat
@@ -618,9 +600,7 @@
 ia64_os_mca_proc_state_restore:
 
 // Restore bank1 GR16-31
-	movl		r2=ia64_mca_proc_state_dump	// Convert virtual address
-	;;						// of OS state dump area
-	DATA_VA_TO_PA(r2)				// to physical address
+	GET_MCA_DUMP_PADDR(r2);;		// phys addr of proc state dump area
 
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2004-12-07 14:36:53.190894130 -0600
+++ linux/arch/ia64/kernel/asm-offsets.c	2004-12-07 14:37:05.680786851 -0600
@@ -203,7 +203,15 @@
 #endif
 
 	BLANK();
-	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+	/* used by arch/ia64/kernel/mca_asm.S */
+	DEFINE(IA64_CPUINFO_PERCPU_PADDR, offsetof (struct cpuinfo_ia64, percpu_paddr));
+	DEFINE(IA64_CPUINFO_PA_MCA_INFO, offsetof (struct cpuinfo_ia64, ia64_pa_mca_data));
+	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
+	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
+	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
+	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
+	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
+
 	/* used by head.S */
 	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
 
Index: linux/include/asm-ia64/mca_asm.h
=================================--- linux.orig/include/asm-ia64/mca_asm.h	2004-12-07 14:36:53.187964752 -0600
+++ linux/include/asm-ia64/mca_asm.h	2004-12-08 18:28:38.312163352 -0600
@@ -47,6 +47,37 @@
 	dep	addr	= temp, addr, 61, 3
 
 /*
+ * This macro gets the physical address of this cpu's cpuinfo structure.
+ */
+#define GET_PERCPU_PADDR(reg)							\
+	mov	reg	= ar.k3;;						\
+	addl	reg	= IA64_CPUINFO_PERCPU_PADDR,reg
+
+/*
+ * This macro gets the physical address of this cpu's MCA save structure.
+ */
+#define GET_CPUINFO_MCA_PADDR(reg)						\
+	mov	reg	= ar.k3;;						\
+	addl	reg	= IA64_CPUINFO_PA_MCA_INFO,reg;;			\
+	ld8	reg	= [reg]
+
+#define	GET_MCA_BSPSTORE(reg)							\
+	GET_CPUINFO_MCA_PADDR(reg);;						\
+	addl	reg	= IA64_MCA_BSPSTORE,reg
+
+#define	GET_MCA_STACKFRAME(reg)							\
+	GET_CPUINFO_MCA_PADDR(reg);;						\
+	addl	reg	= IA64_MCA_STACKFRAME,reg
+
+#define	GET_MCA_STACK(reg)							\
+	GET_CPUINFO_MCA_PADDR(reg);;						\
+	addl	reg	= IA64_MCA_STACK,reg
+
+#define	GET_MCA_DUMP_PADDR(reg)							\
+	GET_CPUINFO_MCA_PADDR(reg);;						\
+	addl	reg	= IA64_MCA_PROC_STATE_DUMP,reg
+
+/*
  * This macro jumps to the instruction at the given virtual address
  * and starts execution in physical mode with all the address
  * translations turned off.
Index: linux/arch/ia64/kernel/minstate.h
=================================--- linux.orig/arch/ia64/kernel/minstate.h	2004-11-29 09:21:40.049402653 -0600
+++ linux/arch/ia64/kernel/minstate.h	2004-12-09 08:50:41.024754508 -0600
@@ -37,12 +37,15 @@
  * go virtual and don't want to destroy the iip or ipsr.
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKStk) movl sp=ia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
+(pKStk) mov r3=ar.k3;;										\
+(pKStk) addl r3=IA64_CPUINFO_PA_MCA_INFO,r3;;							\
+(pKStk) ld8 r3 = [r3];;										\
+(pKStk) addl r3=IA64_INIT_STACK,r3;;								\
+(pKStk) addl sp=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r3;						\
 (pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
 (pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
 	;;											\
 (pUStk)	mov r24=ar.rnat;									\
-(pKStk) tpa r1=sp;				/* compute physical addr of sp	*/		\
 (pUStk)	addl r1=IA64_STK_OFFSET-IA64_PT_REGS_SIZE,r1;	/* compute base of memory stack */	\
 (pUStk)	mov r23=ar.bspstore;				/* save ar.bspstore */			\
 (pUStk)	dep r22=-1,r22,61,3;			/* compute kernel virtual addr of RBS */	\

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
