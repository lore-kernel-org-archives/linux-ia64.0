From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 08:57:32 +0000
Subject: [patch] make setup.c fit in 80 columns
Message-Id: <17009.63228.125577.673580@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[Resend with cc to linux-ia64...]

Tony,

It looks like this patch hasn't made it yet (it's not in the test-2.6
git repo, at least).

[IA64] reformat setup.c to fit in 80 columns

Purely a formatting change.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/kernel/setup.c
=================================--- a63eb89df905efd86a58940286a63c5f670b1c05/arch/ia64/kernel/setup.c  (mode:100644 sha1:b7e6b4cb374b89302f5ba58612bce333f7b8a1cd)
+++ uncommitted/arch/ia64/kernel/setup.c  (mode:100644)
@@ -1,7 +1,7 @@
 /*
  * Architecture-specific setup.
  *
- * Copyright (C) 1998-2001, 2003-2004 Hewlett-Packard Co
+ * Copyright (C) 1998-2001, 2003-2004, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  *	Stephane Eranian <eranian@hpl.hp.com>
  * Copyright (C) 2000, 2004 Intel Corp
@@ -81,29 +81,33 @@
 unsigned int num_io_spaces;
 
 /*
- * The merge_mask variable needs to be set to (max(iommu_page_size(iommu)) - 1).  This
- * mask specifies a mask of address bits that must be 0 in order for two buffers to be
- * mergeable by the I/O MMU (i.e., the end address of the first buffer and the start
- * address of the second buffer must be aligned to (merge_mask+1) in order to be
- * mergeable).  By default, we assume there is no I/O MMU which can merge physically
- * discontiguous buffers, so we set the merge_mask to ~0UL, which corresponds to a iommu
- * page-size of 2^64.
+ * The merge_mask variable needs to be set to
+ * (max(iommu_page_size(iommu)) - 1).  This mask specifies a mask of
+ * address bits that must be 0 in order for two buffers to be
+ * mergeable by the I/O MMU (i.e., the end address of the first buffer
+ * and the start address of the second buffer must be aligned to
+ * (merge_mask+1) in order to be mergeable).  By default, we assume
+ * there is no I/O MMU which can merge physically discontiguous
+ * buffers, so we set the merge_mask to ~0UL, which corresponds to a
+ * iommu page-size of 2^64.
  */
 unsigned long ia64_max_iommu_merge_mask = ~0UL;
 EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
 
 /*
- * We use a special marker for the end of memory and it uses the extra (+1) slot
+ * We use a special marker for the end of memory and it uses the extra
+ * (+1) slot
  */
 struct rsvd_region rsvd_region[IA64_MAX_RSVD_REGIONS + 1];
 int num_rsvd_regions;
 
 
 /*
- * Filter incoming memory segments based on the primitive map created from the boot
- * parameters. Segments contained in the map are removed from the memory ranges. A
- * caller-specified function is called with the memory ranges that remain after filtering.
- * This routine does not assume the incoming segments are sorted.
+ * Filter incoming memory segments based on the primitive map created
+ * from the boot parameters. Segments contained in the map are removed
+ * from the memory ranges. A caller-specified function is called with
+ * the memory ranges that remain after filtering.  This routine does
+ * not assume the incoming segments are sorted.
  */
 int
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
@@ -130,7 +134,8 @@
 		range_end   = min(end, rsvd_region[i].start);
 
 		if (range_start < range_end)
-			call_pernode_memory(__pa(range_start), range_end - range_start, func);
+			call_pernode_memory(__pa(range_start),
+					    range_end - range_start, func);
 
 		/* nothing more available in this segment */
 		if (range_end = end) return 0;
@@ -178,13 +183,17 @@
 	rsvd_region[n].end   = rsvd_region[n].start + sizeof(*ia64_boot_param);
 	n++;
 
-	rsvd_region[n].start = (unsigned long) __va(ia64_boot_param->efi_memmap);
-	rsvd_region[n].end   = rsvd_region[n].start + ia64_boot_param->efi_memmap_size;
+	rsvd_region[n].start = (unsigned long)
+		__va(ia64_boot_param->efi_memmap);
+	rsvd_region[n].end   +		rsvd_region[n].start + ia64_boot_param->efi_memmap_size;
 	n++;
 
-	rsvd_region[n].start = (unsigned long) __va(ia64_boot_param->command_line);
-	rsvd_region[n].end   = (rsvd_region[n].start
-				+ strlen(__va(ia64_boot_param->command_line)) + 1);
+	rsvd_region[n].start +		(unsigned long) __va(ia64_boot_param->command_line);
+	rsvd_region[n].end   +		(rsvd_region[n].start
+		 + strlen(__va(ia64_boot_param->command_line)) + 1);
 	n++;
 
 	rsvd_region[n].start = (unsigned long) ia64_imva((void *)KERNEL_START);
@@ -193,8 +202,10 @@
 
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
-		rsvd_region[n].start = (unsigned long)__va(ia64_boot_param->initrd_start);
-		rsvd_region[n].end   = rsvd_region[n].start + ia64_boot_param->initrd_size;
+		rsvd_region[n].start = (unsigned long)
+			__va(ia64_boot_param->initrd_start);
+		rsvd_region[n].end   +			rsvd_region[n].start + ia64_boot_param->initrd_size;
 		n++;
 	}
 #endif
@@ -220,7 +231,8 @@
 {
 #ifdef CONFIG_BLK_DEV_INITRD
 	if (ia64_boot_param->initrd_start) {
-		initrd_start = (unsigned long)__va(ia64_boot_param->initrd_start);
+		initrd_start = (unsigned long)
+			__va(ia64_boot_param->initrd_start);
 		initrd_end   = initrd_start+ia64_boot_param->initrd_size;
 
 		printk(KERN_INFO "Initial ramdisk at: 0x%lx (%lu bytes)\n",
@@ -236,12 +248,14 @@
 	unsigned long phys_iobase;
 
 	/*
-	 *  Set `iobase' to the appropriate address in region 6 (uncached access range).
+	 *  Set `iobase' to the appropriate address in region 6
+	 *  (uncached access range).
 	 *
-	 *  The EFI memory map is the "preferred" location to get the I/O port space base,
-	 *  rather the relying on AR.KR0. This should become more clear in future SAL
-	 *  specs. We'll fall back to getting it out of AR.KR0 if no appropriate entry is
-	 *  found in the memory map.
+	 *  The EFI memory map is the "preferred" location to get the
+	 *  I/O port space base, rather the relying on AR.KR0. This
+	 *  should become more clear in future SAL specs. We'll fall
+	 *  back to getting it out of AR.KR0 if no appropriate entry
+	 *  is found in the memory map.
 	 */
 	phys_iobase = efi_get_iobase();
 	if (phys_iobase)
@@ -249,8 +263,8 @@
 		ia64_set_kr(IA64_KR_IO_BASE, phys_iobase);
 	else {
 		phys_iobase = ia64_get_kr(IA64_KR_IO_BASE);
-		printk(KERN_INFO "No I/O port range found in EFI memory map, falling back "
-		       "to AR.KR0\n");
+		printk(KERN_INFO "No I/O port range found in EFI memory map, "
+		       "falling back to AR.KR0\n");
 		printk(KERN_INFO "I/O port base = 0x%lx\n", phys_iobase);
 	}
 	ia64_iobase = (unsigned long) ioremap(phys_iobase, 0);
@@ -264,9 +278,10 @@
 /**
  * early_console_setup - setup debugging console
  *
- * Consoles started here require little enough setup that we can start using
- * them very early in the boot process, either right after the machine
- * vector initialization, or even before if the drivers can detect their hw.
+ * Consoles started here require little enough setup that we can start
+ * using them very early in the boot process, either right after the
+ * machine vector initialization, or even before if the drivers can
+ * detect their hw.
  *
  * Returns non-zero if a console couldn't be setup.
  */
@@ -320,9 +335,9 @@
 		return;
 	}
 	/*
-	 * Total number of siblings that BSP has.  Though not all of them 
-	 * may have booted successfully. The correct number of siblings 
-	 * booted is in info.overview_num_log.
+	 * Total number of siblings that BSP has.  Though not all of
+	 * them may have booted successfully. The correct number of
+	 * siblings booted is in info.overview_num_log.
 	 */
 	smp_num_siblings = info.overview_tpc;
 	smp_num_cpucores = info.overview_cpp;
@@ -334,7 +349,8 @@
 {
 	unw_init();
 
-	ia64_patch_vtop((u64) __start___vtop_patchlist, (u64) __end___vtop_patchlist);
+	ia64_patch_vtop((u64) __start___vtop_patchlist,
+			(u64) __end___vtop_patchlist);
 
 	*cmdline_p = __va(ia64_boot_param->command_line);
 	strlcpy(saved_command_line, *cmdline_p, COMMAND_LINE_SIZE);
@@ -395,13 +411,11 @@
 
 	check_for_logical_procs();
 	if (smp_num_cpucores > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Core capable: number of cores=%d\n",
-		       smp_num_cpucores);
+		printk(KERN_INFO "cpu package is Multi-Core capable: "
+		       "number of cores=%d\n", smp_num_cpucores);
 	if (smp_num_siblings > 1)
-		printk(KERN_INFO
-		       "cpu package is Multi-Threading capable: number of siblings=%d\n",
-		       smp_num_siblings);
+		printk(KERN_INFO "cpu package is Multi-Threading capable: "
+		       "number of siblings=%d\n", smp_num_siblings);
 #endif
 
 	cpu_init();	/* initialize the bootstrap CPU */
@@ -417,10 +431,11 @@
 # endif
 # if defined(CONFIG_VGA_CONSOLE)
 		/*
-		 * Non-legacy systems may route legacy VGA MMIO range to system
-		 * memory.  vga_con probes the MMIO hole, so memory looks like
-		 * a VGA device to it.  The EFI memory map can tell us if it's
-		 * memory so we can avoid this problem.
+		 * Non-legacy systems may route legacy VGA MMIO range
+		 * to system memory.  vga_con probes the MMIO hole, so
+		 * memory looks like a VGA device to it.  The EFI
+		 * memory map can tell us if it's memory so we can
+		 * avoid this problem.
 		 */
 		if (efi_mem_type(0xA0000) != EFI_CONVENTIONAL_MEMORY)
 			conswitchp = &vga_con;
@@ -500,13 +515,14 @@
 		   "model      : %u\n"
 		   "revision   : %u\n"
 		   "archrev    : %u\n"
-		   "features   :%s\n"	/* don't change this---it _is_ right! */
+		   "features   :%s\n" /* don't change this---it _is_ right! */
 		   "cpu number : %lu\n"
 		   "cpu regs   : %u\n"
 		   "cpu MHz    : %lu.%06lu\n"
 		   "itc MHz    : %lu.%06lu\n"
 		   "BogoMIPS   : %lu.%02lu\n",
-		   cpunum, c->vendor, family, c->model, c->revision, c->archrev,
+		   cpunum, c->vendor, family, c->model,
+		   c->revision, c->archrev,
 		   features, c->ppn, c->number,
 		   c->proc_freq / 1000000, c->proc_freq % 1000000,
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
@@ -581,7 +597,8 @@
 	pal_vm_info_1_u_t vm1;
 	pal_vm_info_2_u_t vm2;
 	pal_status_t status;
-	unsigned long impl_va_msb = 50, phys_addr_size = 44;	/* Itanium defaults */
+	/* default to (safe) Merced values: */
+	unsigned long impl_va_msb = 50, phys_addr_size = 44;
 	int i;
 
 	for (i = 0; i < 5; ++i)
@@ -591,8 +608,10 @@
 #ifdef CONFIG_SMP
 	c->cpu = smp_processor_id();
 
-	/* below default values will be overwritten  by identify_siblings() 
-	 * for Multi-Threading/Multi-Core capable cpu's
+	/*
+	 * Below, default values will be overwritten by
+	 * identify_siblings() for Multi-Threading/Multi-Core capable
+	 * cpu's
 	 */
 	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
 	c->socket_id = -1;
@@ -632,19 +651,19 @@
 
         status = ia64_pal_cache_summary(&levels, &unique_caches);
         if (status != 0) {
-                printk(KERN_ERR "%s: ia64_pal_cache_summary() failed (status=%ld)\n",
-                       __FUNCTION__, status);
+                printk(KERN_ERR "%s: ia64_pal_cache_summary() failed "
+		       "(status=%ld)\n", __FUNCTION__, status);
                 max = SMP_CACHE_BYTES;
 		goto out;
         }
 
 	for (l = 0; l < levels; ++l) {
-		status = ia64_pal_cache_config_info(l, /* cache_type (data_or_unified)= */ 2,
+		status = ia64_pal_cache_config_info(l, PAL_CACHE_TYPE_DATA,
 						    &cci);
 		if (status != 0) {
 			printk(KERN_ERR
-			       "%s: ia64_pal_cache_config_info(l=%lu) failed (status=%ld)\n",
-			       __FUNCTION__, l, status);
+			       "%s: ia64_pal_cache_config_info(l=%lu) failed "
+			       "(status=%ld)\n", __FUNCTION__, l, status);
 			max = SMP_CACHE_BYTES;
 		}
 		line_size = 1 << cci.pcci_line_size;
@@ -683,12 +702,14 @@
 	get_max_cacheline_size();
 
 	/*
-	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't called
-	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because it
-	 * depends on the data returned by identify_cpu().  We break the dependency by
+	 * We can't pass "local_cpu_data" to identify_cpu() because we
+	 * haven't called ia64_mmu_init() yet.  And we can't call
+	 * ia64_mmu_init() first because it depends on the data
+	 * returned by identify_cpu().  We break the dependency by
 	 * accessing cpu_data() through the canonical per-CPU address.
 	 */
-	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
+	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info)
+			       - __per_cpu_start);
 	identify_cpu(cpu_info);
 
 #ifdef CONFIG_MCKINLEY
@@ -697,10 +718,13 @@
 		struct ia64_pal_retval iprv;
 
 		if (cpu_info->family = 0x1f) {
-			PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0, FEATURE_SET, 0);
-			if ((iprv.status = 0) && (iprv.v0 & 0x80) && (iprv.v2 & 0x80))
+			PAL_CALL_PHYS(iprv, PAL_PROC_GET_FEATURES, 0,
+				      FEATURE_SET, 0);
+			if ((iprv.status = 0) && (iprv.v0 & 0x80)
+			    && (iprv.v2 & 0x80))
 				PAL_CALL_PHYS(iprv, PAL_PROC_SET_FEATURES,
-				              (iprv.v1 | 0x80), FEATURE_SET, 0);
+				              (iprv.v1 | 0x80), FEATURE_SET,
+					      0);
 		}
 	}
 #endif
@@ -720,15 +744,19 @@
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(ia64_imva(empty_zero_page)));
 
 	/*
-	 * Initialize default control register to defer all speculative faults.  The
-	 * kernel MUST NOT depend on a particular setting of these bits (in other words,
-	 * the kernel must have recovery code for all speculative accesses).  Turn on
-	 * dcr.lc as per recommendation by the architecture team.  Most IA-32 apps
-	 * shouldn't be affected by this (moral: keep your ia32 locks aligned and you'll
-	 * be fine).
+	 * Initialize default control register to defer all
+	 * speculative faults.  The kernel MUST NOT depend on a
+	 * particular setting of these bits (in other words, the
+	 * kernel must have recovery code for all speculative
+	 * accesses).  Turn on dcr.lc as per recommendation by the
+	 * architecture team.  Most IA-32 apps shouldn't be affected
+	 * by this (moral: keep your ia32 locks aligned and you'll be
+	 * fine).
 	 */
-	ia64_setreg(_IA64_REG_CR_DCR,  (  IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_DR
-					| IA64_DCR_DA | IA64_DCR_DD | IA64_DCR_LC));
+	ia64_setreg(_IA64_REG_CR_DCR,  (  IA64_DCR_DP | IA64_DCR_DK
+					| IA64_DCR_DX | IA64_DCR_DR
+					| IA64_DCR_DA | IA64_DCR_DD
+					| IA64_DCR_LC));
 	atomic_inc(&init_mm.mm_count);
 	current->active_mm = &init_mm;
 	if (current->mm)
@@ -757,11 +785,12 @@
 	normal_xtp();
 #endif
 
-	/* set ia64_ctx.max_rid to the maximum RID that is supported by all CPUs: */
+	/* set ia64_ctx.max_rid to the max RID that's supported by all CPUs: */
 	if (ia64_pal_vm_summary(NULL, &vmi) = 0)
 		max_ctx = (1U << (vmi.pal_vm_info_2_s.rid_size - 3)) - 1;
 	else {
-		printk(KERN_WARNING "cpu_init: PAL VM summary failed, assuming 18 RID bits\n");
+		printk(KERN_WARNING "cpu_init: PAL VM summary failed, "
+		       "assuming 18 RID bits\n");
 		max_ctx = (1U << 15) - 1;	/* use architected minimum */
 	}
 	while (max_ctx < ia64_ctx.max_ctx) {
@@ -771,8 +800,8 @@
 	}
 
 	if (ia64_pal_rse_info(&num_phys_stacked, NULL) != 0) {
-		printk(KERN_WARNING "cpu_init: PAL RSE info failed; assuming 96 physical "
-		       "stacked regs\n");
+		printk(KERN_WARNING "cpu_init: PAL RSE info failed; "
+		       "assuming 96 physical stacked regs\n");
 		num_phys_stacked = 96;
 	}
 	/* size of physical stacked register partition plus 8 bytes: */
