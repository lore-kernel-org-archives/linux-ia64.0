From: Russ Anderson <rja@sgi.com>
Date: Fri, 12 Nov 2004 23:27:27 +0000
Subject: [patch] per cpu MCA/INIT save areas (take 2)
Message-Id: <200411122327.iACNRR5h131335@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony and all,

This is a smaller version of the per cpu MCA/INIT save area
patch.  The main point is to get in the infrastructure for
the per cpu MCA/INIT save areas.  It allocates a per cpu 
MCA/INIT save area and used ar.k3 to hold a pointer to the area.
It modifies the TLB MCA recovery code to use the per cpu area 
instead of the global array (ia64_mca_tlb_list).  It also replaces
several MCA save areas with per cpu save areas.

If this looks acceptable, subsequent patches will expand this
functionality.  I want to make sure that this approach is
acceptable before going too far into left field.

Signed-off-by: Russ Anderson <rja@sgi.com>

High level description:

  Linux currently has one MCA & INIT save area for saving
  stack and other data.  This patch creates per cpu MCA 
  save areas, so that each cpu can save its own MCA stack 
  data.

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

  linux/include/asm-ia64/mca.h

	Define the structure layout of the MCA/INIT save area.

  linux/include/asm-ia64/kregs.h

	Define ar.k3 as used for MCA/INIT save area pointer.

  linux/arch/ia64/mm/init.c

	Replace global array ia64_mca_tlb_list with 
	ar.k3 pointing to per cpu area.

  linux/arch/ia64/mm/discontig.c

	On each node, allocate MCA/INIT space for each
	cpu that physically exists.  Set ar.k3 
	pointer to the MCA/INIT save area for that cpu.

  linux/arch/ia64/kernel/asm-offsets.c

	Define assembler constants to correspond with
	the c structure layout of the MCA/INIT save area.

  linux/arch/ia64/kernel/mca.c

	Remove the global save areas: 
		ia64_mca_proc_state_dump,
		ia64_mca_stack, 
		ia64_mca_stackframe,
		ia64_mca_bspstore

  linux/arch/ia64/kernel/mca_asm.S

	Replace the global MCA save pointers with the
	per CPU equivalents.

Testing:

  	Tested on SGI Altix.  Additional testing on other 
  	platforms is welcome.
-----------------------------------------------------------------
Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2004-11-12 16:59:15.000000000 -0600
+++ linux/include/asm-ia64/mca.h	2004-11-12 17:03:56.000000000 -0600
@@ -5,6 +5,7 @@
  * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
+ * Copyright (C) Russ Anderson (rja@sgi.com)
  */
 
 #ifndef _ASM_IA64_MCA_H
@@ -112,6 +113,17 @@
 						 */
 } ia64_mca_os_to_sal_state_t;
 
+#define IA64_MCA_BSPSTORE_SIZE 	024
+
+typedef struct ia64_mca_cpu_s {
+	struct ia64_mca_tlb_info ia64_mca_cpu_tlb;
+	u64	ia64_mca_stack[1024] __attribute__((aligned(16)));
+	u64	ia64_mca_proc_state_dump[512];
+	u64	ia64_mca_stackframe[32];
+	u64	ia64_mca_bspstore[IA64_MCA_BSPSTORE_SIZE];
+	u64	ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
+} ia64_mca_cpu_t;
+
 extern void ia64_mca_init(void);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
Index: linux/include/asm-ia64/kregs.h
=================================--- linux.orig/include/asm-ia64/kregs.h	2004-11-12 16:59:15.000000000 -0600
+++ linux/include/asm-ia64/kregs.h	2004-11-12 17:03:56.000000000 -0600
@@ -14,6 +14,7 @@
  */
 #define IA64_KR_IO_BASE		0	/* ar.k0: legacy I/O base address */
 #define IA64_KR_TSSD		1	/* ar.k1: IVE uses this as the TSSD */
+#define IA64_KR_MCA_INFO	3	/* ar.k3: phys addr of this cpu's mca_info struct */
 #define IA64_KR_CURRENT_STACK	4	/* ar.k4: what's mapped in IA64_TR_CURRENT_STACK */
 #define IA64_KR_FPU_OWNER	5	/* ar.k5: fpu-owner (UP only, at the moment) */
 #define IA64_KR_CURRENT		6	/* ar.k6: "current" task pointer */
Index: linux/arch/ia64/mm/init.c
=================================--- linux.orig/arch/ia64/mm/init.c	2004-11-12 16:59:15.000000000 -0600
+++ linux/arch/ia64/mm/init.c	2004-11-12 17:03:56.000000000 -0600
@@ -280,6 +280,7 @@
 	unsigned long psr, pta, impl_va_bits;
 	extern void __devinit tlb_init (void);
 	int cpu;
+	struct ia64_mca_cpu_s *mca_cpu;
 
 #ifdef CONFIG_DISABLE_VHPT
 #	define VHPT_ENABLE_BIT	0
@@ -348,16 +349,17 @@
 	cpu = smp_processor_id();
 
 	/* mca handler uses cr.lid as key to pick the right entry */
-	ia64_mca_tlb_list[cpu].cr_lid = ia64_getreg(_IA64_REG_CR_LID);
+	mca_cpu = (struct ia64_mca_cpu_s *)__va(ia64_get_kr(IA64_KR_MCA_INFO));
+	mca_cpu->ia64_mca_cpu_tlb.cr_lid = ia64_getreg(_IA64_REG_CR_LID);
 
 	/* insert this percpu data information into our list for MCA recovery purposes */
-	ia64_mca_tlb_list[cpu].percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
+	mca_cpu->ia64_mca_cpu_tlb.percpu_paddr = pte_val(mk_pte_phys(__pa(my_cpu_data), PAGE_KERNEL));
 	/* Also save per-cpu tlb flush recipe for use in physical mode mca handler */
-	ia64_mca_tlb_list[cpu].ptce_base = local_cpu_data->ptce_base;
-	ia64_mca_tlb_list[cpu].ptce_count[0] = local_cpu_data->ptce_count[0];
-	ia64_mca_tlb_list[cpu].ptce_count[1] = local_cpu_data->ptce_count[1];
-	ia64_mca_tlb_list[cpu].ptce_stride[0] = local_cpu_data->ptce_stride[0];
-	ia64_mca_tlb_list[cpu].ptce_stride[1] = local_cpu_data->ptce_stride[1];
+	mca_cpu->ia64_mca_cpu_tlb.ptce_base = local_cpu_data->ptce_base;
+	mca_cpu->ia64_mca_cpu_tlb.ptce_count[0] = local_cpu_data->ptce_count[0];
+	mca_cpu->ia64_mca_cpu_tlb.ptce_count[1] = local_cpu_data->ptce_count[1];
+	mca_cpu->ia64_mca_cpu_tlb.ptce_stride[0] = local_cpu_data->ptce_stride[0];
+	mca_cpu->ia64_mca_cpu_tlb.ptce_stride[1] = local_cpu_data->ptce_stride[1];
 }
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2004-11-12 16:59:15.000000000 -0600
+++ linux/arch/ia64/mm/discontig.c	2004-11-12 17:03:56.000000000 -0600
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
 
@@ -328,6 +363,10 @@
 			if (node = node_cpuid[cpu].nid) {
 				memcpy(__va(cpu_data), __phys_per_cpu_start,
 				       __per_cpu_end - __per_cpu_start);
+				if ((cpu = 0) || (node_cpuid[cpu].phys_id > 0)) {
+					ia64_set_kr(IA64_KR_MCA_INFO, __pa(mca_data_phys));
+					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
+				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
 				cpu_data += PERCPU_PAGE_SIZE;
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2004-11-12 16:59:15.000000000 -0600
+++ linux/arch/ia64/kernel/mca.c	2004-11-12 17:03:56.000000000 -0600
@@ -85,10 +85,6 @@
 /* Used by mca_asm.S */
 ia64_mca_sal_to_os_state_t	ia64_sal_to_os_handoff_state;
 ia64_mca_os_to_sal_state_t	ia64_os_to_sal_handoff_state;
-u64				ia64_mca_proc_state_dump[512];
-u64				ia64_mca_stack[1024] __attribute__((aligned(16)));
-u64				ia64_mca_stackframe[32];
-u64				ia64_mca_bspstore[1024];
 u64				ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
 u64				ia64_mca_serialize;
 
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2004-11-12 16:59:15.000000000 -0600
+++ linux/arch/ia64/kernel/mca_asm.S	2004-11-12 17:03:56.000000000 -0600
@@ -1,6 +1,9 @@
 //
 // assembly portion of the IA64 MCA handling
 //
+// 04/11/12 Russ Anderson <rja@sgi.com>
+//		   Added per cpu MCA/INIT stack save areas.
+//
 // Mods by cfleck to integrate into kernel build
 // 00/03/15 davidm Added various stop bits to get a clean compile
 //
@@ -102,10 +105,6 @@
 	.global ia64_os_mca_dispatch_end
 	.global ia64_sal_to_os_handoff_state
 	.global	ia64_os_to_sal_handoff_state
-	.global	ia64_mca_proc_state_dump
-	.global	ia64_mca_stack
-	.global	ia64_mca_stackframe
-	.global	ia64_mca_bspstore
 	.global ia64_init_stack
 
 	.text
@@ -147,19 +146,10 @@
 	// Purge percpu data TC entries.
 begin_tlb_purge_and_reload:
 	mov r16=cr.lid
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
-	;;
-	adds r17=-IA64_MCA_TLB_INFO_SIZE,r17
+
+	mov	r2=ar.k3;;	// phys addr of MCA save area
+	addl	r2=IA64_MCA_TLB_INFO,r2;;
+	mov	r17=r2
 	;;
 	mov r23=r17		// save current ia64_mca_percpu_info addr pointer.
 	adds r17,r17
@@ -318,17 +308,18 @@
 done_tlb_purge_and_reload:
 
 	// Setup new stack frame for OS_MCA handling
-	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in r2
-	DATA_VA_TO_PA(r2);;
-	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
-	DATA_VA_TO_PA(r3);;
+	mov	r3=ar.k3;;		// phys addr of MCA save area
+	addl	r2=IA64_MCA_BSPSTORE,r3;;   // local bspstore area location in r2
+	addl	r3=IA64_MCA_STACKFRAME,r3;; // save stack frame to memory in r3
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
-	movl	r12=ia64_mca_stack
+
+	mov	r2=ar.k3;;		// phys addr of MCA save area
+	addl	r2=IA64_MCA_STACKFRAME,r2;;
+	mov	r12=r2
 	mov	r2=8*1024;;		// stack size must be same as C array
 	add	r12=r2,r12;;		// stack base @ bottom of array
 	adds	r12=-16,r12;;		// allow 16 bytes of scratch
 					// (C calling convention)
-	DATA_VA_TO_PA(r12);;
 
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
@@ -344,9 +335,8 @@
 ia64_os_mca_virtual_end:
 
 	// restore the original stack frame here
-	movl    r2=ia64_mca_stackframe	// restore stack frame from memory at r2
-	;;
-	DATA_VA_TO_PA(r2)
+	mov	r2=ar.k3;;		// phys addr of MCA save area
+	addl	r2=IA64_MCA_STACKFRAME,r2;;
 	movl    r4=IA64_PSR_MC
 	;;
 	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
@@ -387,7 +377,8 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump area to physical address
+	mov		r2=ar.k3;;		// phys addr of MCA save area
+	addl		r2=IA64_MCA_PROC_STATE_DUMP,r2;;
 
 // save ar.NaT
 	mov		r5=ar.unat                  // ar.unat
@@ -618,9 +609,8 @@
 ia64_os_mca_proc_state_restore:
 
 // Restore bank1 GR16-31
-	movl		r2=ia64_mca_proc_state_dump	// Convert virtual address
-	;;						// of OS state dump area
-	DATA_VA_TO_PA(r2)				// to physical address
+	mov		r2=ar.k3;;		// phys addr of MCA save area
+	addl		r2=IA64_MCA_PROC_STATE_DUMP,r2;;
 
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2004-11-12 16:59:15.000000000 -0600
+++ linux/arch/ia64/kernel/asm-offsets.c	2004-11-12 17:03:56.000000000 -0600
@@ -204,6 +204,13 @@
 
 	BLANK();
 	DEFINE(IA64_MCA_TLB_INFO_SIZE, sizeof (struct ia64_mca_tlb_info));
+	DEFINE(IA64_MCA_TLB_INFO, offsetof (struct ia64_mca_cpu_s, ia64_mca_cpu_tlb));
+	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
+	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
+	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
+	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
+	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
+
 	/* used by head.S */
 	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
