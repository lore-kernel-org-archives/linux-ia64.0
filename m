From: Russ Anderson <rja@sgi.com>
Date: Tue, 31 Aug 2004 21:12:25 +0000
Subject: [Patch] Per CPU MCA/INIT data save areas
Message-Id: <200408312112.i7VLCPc9002392@ben.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This is a patch to create per cpu MCA/INIT data save areas.

Signed-off-by: Russ Anderson <rja@sgi.com>

High level description:

  Linux currently has one MCA & INIT save area for saving
  stack and other data.  This patch creates per cpu MCA/INIT 
  save areas, so that each cpu can save its own MCA & INIT stack 
  data.

  The per MCA/INIT save areas replace the global areas defined
  in arch/ia64/kernel/mca.c for MCA processor state dump, 
  MCA stack, MCA stack frame, INIT stack, and MCA bspstore.

  The code to access those save areas is updated to use the
  per cpu save areas.

  No changes are made to the MCA flow, ie all the old locks
  are still in place.  The point of this patch is to establish
  the per cpu save areas.  Additional usage of the save areas,
  such as enabling concurrent INIT or MCA handling, will be
  the subject of other patches.

Detailed description:

  linux/include/asm-ia64/processor.h

	In the cpu_info structure, add a pointer
	to the MCA/INIT save area.

  linux/arch/ia64/mm/discontig.c

	On each node, allocate MCA/INIT space for each
	cpu that physically exists.  Set the cpu_info
	pointer to the MCA/INIT save area for that cpu.

  linux/arch/ia64/kernel/asm-offsets.c

	Define assembler constants to correspond with
	the c structure layout of the MCA/INIT save area.

  linux/arch/ia64/kernel/mca.c

	Remove the global save areas: 
		ia64_mca_proc_state_dump,
		ia64_mca_stack, 
		ia64_mca_stackframe,
		ia64_init_stack,
		ia64_mca_bspstore

  linux/include/asm-ia64/mca.h

	Define the structure layout of the MCA/INIT save area.

  linux/arch/ia64/kernel/mca_asm.S

	Replace the global MCA/INIT save pointers with the
	per CPU equivalents.

  linux/arch/ia64/kernel/minstate.h

	Replace global ia64_init_stack pointer with the
	per cpu INIT stack save area pointer.

Testing:

  Tested on SGI Altix.  Builds with zx1_defconfig.  Additional
  testing on other platforms is welcome.
-----------------------------------------------------------------

Index: linux/include/asm-ia64/mca.h
=================================--- linux.orig/include/asm-ia64/mca.h	2004-08-30 14:12:17.000000000 -0500
+++ linux/include/asm-ia64/mca.h	2004-08-31 10:40:06.000000000 -0500
@@ -5,6 +5,7 @@
  * Copyright (C) 1999, 2004 Silicon Graphics, Inc.
  * Copyright (C) Vijay Chander (vijay@engr.sgi.com)
  * Copyright (C) Srinivasa Thirumalachar (sprasad@engr.sgi.com)
+ * Copyright (C) Russ Anderson <rja@sgi.com>
  */
 
 #ifndef _ASM_IA64_MCA_H
@@ -107,6 +108,14 @@
 						 */
 } ia64_mca_os_to_sal_state_t;
 
+typedef struct ia64_mca_cpu_s {
+	u64		ia64_mca_proc_state_dump[512];
+	u64		ia64_mca_stack[1024] __attribute__((aligned(16)));
+	u64		ia64_mca_stackframe[32];
+	u64		ia64_mca_bspstore[1024];
+	u64		ia64_init_stack[KERNEL_STACK_SIZE/8] __attribute__((aligned(16)));
+} ia64_mca_cpu_t;
+
 extern void ia64_mca_init(void);
 extern void ia64_os_mca_dispatch(void);
 extern void ia64_os_mca_dispatch_end(void);
Index: linux/arch/ia64/mm/discontig.c
=================================--- linux.orig/arch/ia64/mm/discontig.c	2004-08-25 09:27:04.000000000 -0500
+++ linux/arch/ia64/mm/discontig.c	2004-08-31 11:45:25.000000000 -0500
@@ -4,6 +4,10 @@
  * Copyright (c) 2001 Tony Luck <tony.luck@intel.com>
  * Copyright (c) 2002 NEC Corp.
  * Copyright (c) 2002 Kimio Suganuma <k-suganuma@da.jp.nec.com>
+ * Copyright (c) 2003-2004 Silicon Graphics, Inc
+ *      Russ Anderson <rja@sgi.com>
+ *      Jesse Barnes <jbarnes@sgi.com>
+ *      Jack Steiner <steiner@sgi.com>
  */
 
 /*
@@ -21,6 +25,7 @@
 #include <asm/meminit.h>
 #include <asm/numa.h>
 #include <asm/sections.h>
+#include <asm/mca.h>
 
 /*
  * Track per-node information needed to setup the boot memory allocator, the
@@ -206,12 +211,33 @@
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
@@ -238,12 +264,15 @@
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
@@ -255,10 +284,11 @@
 static int __init find_pernode_space(unsigned long start, unsigned long len,
 				     int node)
 {
-	unsigned long epfn, cpu, cpus;
+	unsigned long epfn, cpu, cpus, phys_cpus;
 	unsigned long pernodesize = 0, pernode, pages, mapsize;
-	void *cpu_data;
+	void *cpu_data, *mca_data_phys;
 	struct bootmem_data *bdp = &mem_data[node].bootmem_data;
+	struct cpuinfo_ia64 *cpuinfo;
 
 	epfn = (start + len) >> PAGE_SHIFT;
 
@@ -281,9 +311,11 @@
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
 
@@ -302,6 +334,9 @@
 		mem_data[node].node_data = __va(pernode);
 		pernode += L1_CACHE_ALIGN(sizeof(struct ia64_node_data));
 
+		mca_data_phys = (void *)pernode;
+		pernode += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t)) * phys_cpus;
+
 		mem_data[node].pgdat->bdata = bdp;
 		pernode += L1_CACHE_ALIGN(sizeof(pg_data_t));
 
@@ -314,6 +349,11 @@
 			if (node = node_cpuid[cpu].nid) {
 				memcpy(__va(cpu_data), __phys_per_cpu_start,
 				       __per_cpu_end - __per_cpu_start);
+				if ((cpu = 0) || (node_cpuid[cpu].phys_id > 0)) {
+					cpuinfo = (struct cpuinfo_ia64 *)cpu_data;
+					cpuinfo->ia64_mca_data = mca_data_phys;
+					mca_data_phys += L1_CACHE_ALIGN(sizeof(ia64_mca_cpu_t));
+				}
 				__per_cpu_offset[cpu] = (char*)__va(cpu_data) -
 					__per_cpu_start;
 				cpu_data += PERCPU_PAGE_SIZE;
Index: linux/arch/ia64/kernel/mca.c
=================================--- linux.orig/arch/ia64/kernel/mca.c	2004-08-25 09:27:03.000000000 -0500
+++ linux/arch/ia64/kernel/mca.c	2004-08-31 11:44:40.000000000 -0500
@@ -3,6 +3,9 @@
  * Purpose:	Generic MCA handling layer
  *
  * Updated for latest kernel
+ * Copyright (C) 2004 Silicon Graphics, Inc
+ *	Russ Anderson <rja@sgi.com>
+ *
  * Copyright (C) 2003 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *
@@ -90,11 +93,6 @@
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
Index: linux/arch/ia64/kernel/minstate.h
=================================--- linux.orig/arch/ia64/kernel/minstate.h	2004-08-25 09:27:03.000000000 -0500
+++ linux/arch/ia64/kernel/minstate.h	2004-08-31 10:40:06.000000000 -0500
@@ -37,7 +37,9 @@
  * go virtual and don't want to destroy the iip or ipsr.
  */
 #define MINSTATE_START_SAVE_MIN_PHYS								\
-(pKStk) movl sp=ia64_init_stack+IA64_STK_OFFSET-IA64_PT_REGS_SIZE;				\
+(pKStk) addl r2=THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA, r0;;  /* cpu_info structure */      \
+(pKStk) ld8 r2=[r2];;				/* Address of local cpu MCA/INIT save area */	\
+(pKStk) addl sp=IA64_INIT_STACK+IA64_STK_OFFSET-IA64_PT_REGS_SIZE, r2;				\
 (pUStk)	mov ar.rsc=0;		/* set enforced lazy mode, pl 0, little-endian, loadrs=0 */	\
 (pUStk)	addl r22=IA64_RBS_OFFSET,r1;		/* compute base of register backing store */	\
 	;;											\
Index: linux/include/asm-ia64/processor.h
=================================--- linux.orig/include/asm-ia64/processor.h	2004-08-30 14:12:17.000000000 -0500
+++ linux/include/asm-ia64/processor.h	2004-08-31 11:46:06.000000000 -0500
@@ -2,6 +2,8 @@
 #define _ASM_IA64_PROCESSOR_H
 
 /*
+ * Copyright (C) 2004 Silicon Graphics, Inc
+ *      Russ Anderson <rja@sgi.com>
  * Copyright (C) 1998-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
@@ -171,6 +173,7 @@
 #ifdef CONFIG_NUMA
 	struct ia64_node_data *node_data;
 #endif
+	__u64 *ia64_mca_data;	/* prt to MCA/INIT processor state */
 };
 
 DECLARE_PER_CPU(struct cpuinfo_ia64, cpu_info);
Index: linux/arch/ia64/kernel/mca_asm.S
=================================--- linux.orig/arch/ia64/kernel/mca_asm.S	2004-08-25 09:27:03.000000000 -0500
+++ linux/arch/ia64/kernel/mca_asm.S	2004-08-31 10:40:06.000000000 -0500
@@ -1,6 +1,9 @@
 //
 // assembly portion of the IA64 MCA handling
 //
+// 04/08/27 Russ Anderson <rja@sgi.com>
+//		   Added per cpu MCA/INIT stack save areas.
+//
 // Mods by cfleck to integrate into kernel build
 // 00/03/15 davidm Added various stop bits to get a clean compile
 //
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
@@ -318,17 +316,17 @@
 done_tlb_purge_and_reload:
 
 	// Setup new stack frame for OS_MCA handling
-	movl	r2=ia64_mca_bspstore;;	// local bspstore area location in r2
-	DATA_VA_TO_PA(r2);;
-	movl	r3=ia64_mca_stackframe;; // save stack frame to memory in r3
-	DATA_VA_TO_PA(r3);;
+	addl	r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
+	ld8	r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
+	addl	r3 = IA64_MCA_STACKFRAME, r2
+	addl	r12 = IA64_MCA_STACK, r2
+	addl	r2 = IA64_MCA_BSPSTORE, r2;;
+
 	rse_switch_context(r6,r3,r2);;	// RSC management in this new context
-	movl	r12=ia64_mca_stack
 	mov	r2=8*1024;;		// stack size must be same as C array
 	add	r12=r2,r12;;		// stack base @ bottom of array
 	adds	r12=-16,r12;;		// allow 16 bytes of scratch
 					// (C calling convention)
-	DATA_VA_TO_PA(r12);;
 
         // Enter virtual mode from physical mode
 	VIRTUAL_MODE_ENTER(r2, r3, ia64_os_mca_virtual_begin, r4)
@@ -344,9 +342,9 @@
 ia64_os_mca_virtual_end:
 
 	// restore the original stack frame here
-	movl    r2=ia64_mca_stackframe	// restore stack frame from memory at r2
-	;;
-	DATA_VA_TO_PA(r2)
+	addl	r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
+	ld8	r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
+	addl	r2 = IA64_MCA_STACKFRAME, r2;;
 	movl    r4=IA64_PSR_MC
 	;;
 	rse_return_context(r4,r3,r2)	// switch from interrupt context for RSE
@@ -387,8 +385,10 @@
 ia64_os_mca_proc_state_dump:
 // Save bank 1 GRs 16-31 which will be used by c-language code when we switch
 //  to virtual addressing mode.
-	LOAD_PHYSICAL(p0,r2,ia64_mca_proc_state_dump)// convert OS state dump area to physical address
-
+	addl		r2 = THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA,r0;;
+	ld8		r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
+	addl		r2 = IA64_MCA_PROC_STATE_DUMP, r2;;
+					// r2 now points at ia64_mca_proc_state_dump area
 // save ar.NaT
 	mov		r5=ar.unat                  // ar.unat
 
@@ -618,9 +618,10 @@
 ia64_os_mca_proc_state_restore:
 
 // Restore bank1 GR16-31
-	movl		r2=ia64_mca_proc_state_dump	// Convert virtual address
-	;;						// of OS state dump area
-	DATA_VA_TO_PA(r2)				// to physical address
+	addl		r2=THIS_CPU(cpu_info) + IA64_CPUINFO_MCA_DATA, r0;;
+	ld8		r2=[r2];;	// r2 pointing to top of this cpu's MCA/INIT save area
+	addl		r2 = IA64_MCA_PROC_STATE_DUMP, r2;;
+					// r2 now points at ia64_mca_proc_state_dump area
 
 restore_GRs:                                    // restore bank-1 GRs 16-31
 	bsw.1;;
Index: linux/arch/ia64/kernel/asm-offsets.c
=================================--- linux.orig/arch/ia64/kernel/asm-offsets.c	2004-08-25 09:27:03.000000000 -0500
+++ linux/arch/ia64/kernel/asm-offsets.c	2004-08-31 10:40:06.000000000 -0500
@@ -194,6 +194,13 @@
 	DEFINE(IA64_CPUINFO_NSEC_PER_CYC_OFFSET, offsetof (struct cpuinfo_ia64, nsec_per_cyc));
 	DEFINE(IA64_TIMESPEC_TV_NSEC_OFFSET, offsetof (struct timespec, tv_nsec));
 
+    /* used by arch/ia64/kernel/mca_asm.S */
+	DEFINE(IA64_CPUINFO_MCA_DATA, offsetof (struct cpuinfo_ia64, ia64_mca_data));
+	DEFINE(IA64_MCA_PROC_STATE_DUMP, offsetof (struct ia64_mca_cpu_s, ia64_mca_proc_state_dump));
+	DEFINE(IA64_MCA_STACK, offsetof (struct ia64_mca_cpu_s, ia64_mca_stack));
+	DEFINE(IA64_MCA_STACKFRAME, offsetof (struct ia64_mca_cpu_s, ia64_mca_stackframe));
+	DEFINE(IA64_MCA_BSPSTORE, offsetof (struct ia64_mca_cpu_s, ia64_mca_bspstore));
+	DEFINE(IA64_INIT_STACK, offsetof (struct ia64_mca_cpu_s, ia64_init_stack));
 
 	DEFINE(CLONE_IDLETASK_BIT, 12);
 #if CLONE_IDLETASK != (1 << 12)
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
