From: Alex Chiang <achiang@hp.com>
Date: Wed, 05 Sep 2007 23:01:42 +0000
Subject: [PATCH] ia64: rewrap long multi-line comments to 80 columns
Message-Id: <20070905230142.GA32277@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Alex Chiang <achiang@hp.com>

Some of the multi-line comments in arch/ia64/kernel/setup.c
aren't word-wrapped at 80 columns, making them somewhat difficult
to read. Rewrap those multi-line comments to 80 columns (but
leave the long one-liners alone).

Signed-off-by: Alex Chiang <achiang@hp.com>

---

diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 407efea..59e862c 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -106,20 +106,20 @@ EXPORT_SYMBOL(io_space);
 unsigned int num_io_spaces;
 
 /*
- * "flush_icache_range()" needs to know what processor dependent stride size to use
- * when it makes i-cache(s) coherent with d-caches.
+ * "flush_icache_range()" needs to know what processor dependent stride size to
+ * use when it makes i-cache(s) coherent with d-caches.
  */
 #define	I_CACHE_STRIDE_SHIFT	5	/* Safest way to go: 32 bytes by 32 bytes */
 unsigned long ia64_i_cache_stride_shift = ~0;
 
 /*
- * The merge_mask variable needs to be set to (max(iommu_page_size(iommu)) - 1).  This
- * mask specifies a mask of address bits that must be 0 in order for two buffers to be
- * mergeable by the I/O MMU (i.e., the end address of the first buffer and the start
- * address of the second buffer must be aligned to (merge_mask+1) in order to be
- * mergeable).  By default, we assume there is no I/O MMU which can merge physically
- * discontiguous buffers, so we set the merge_mask to ~0UL, which corresponds to a iommu
- * page-size of 2^64.
+ * The merge_mask variable needs to be set to (max(iommu_page_size(iommu)) - 1).
+ * This mask specifies a mask of address bits that must be 0 in order for two
+ * buffers to be mergeable by the I/O MMU (i.e., the end address of the first
+ * buffer and the start address of the second buffer must be aligned to
+ * (merge_mask+1) in order to be mergeable).  By default, we assume there is no
+ * I/O MMU which can merge physically discontiguous buffers, so we set the
+ * merge_mask to ~0UL, which corresponds to a iommu page-size of 2^64.
  */
 unsigned long ia64_max_iommu_merge_mask = ~0UL;
 EXPORT_SYMBOL(ia64_max_iommu_merge_mask);
@@ -132,10 +132,11 @@ int num_rsvd_regions __initdata;
 
 
 /*
- * Filter incoming memory segments based on the primitive map created from the boot
- * parameters. Segments contained in the map are removed from the memory ranges. A
- * caller-specified function is called with the memory ranges that remain after filtering.
- * This routine does not assume the incoming segments are sorted.
+ * Filter incoming memory segments based on the primitive map created from the
+ * boot parameters. Segments contained in the map are removed from the memory
+ * ranges. A caller-specified function is called with the memory ranges that
+ * remain after filtering.  This routine does not assume the incoming segments
+ * are sorted.
  */
 int __init
 filter_rsvd_memory (unsigned long start, unsigned long end, void *arg)
@@ -889,10 +890,11 @@ cpu_init (void)
 	get_max_cacheline_size();
 
 	/*
-	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't called
-	 * ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first because it
-	 * depends on the data returned by identify_cpu().  We break the dependency by
-	 * accessing cpu_data() through the canonical per-CPU address.
+	 * We can't pass "local_cpu_data" to identify_cpu() because we haven't
+	 * called ia64_mmu_init() yet.  And we can't call ia64_mmu_init() first
+	 * because it depends on the data returned by identify_cpu().  We break
+	 * the dependency by accessing cpu_data() through the canonical per-CPU
+	 * address.
 	 */
 	cpu_info = cpu_data + ((char *) &__ia64_per_cpu_var(cpu_info) - __per_cpu_start);
 	identify_cpu(cpu_info);
@@ -926,13 +928,13 @@ cpu_init (void)
 	ia64_set_kr(IA64_KR_PT_BASE, __pa(ia64_imva(empty_zero_page)));
 
 	/*
-	 * Initialize default control register to defer speculative faults except
-	 * for those arising from TLB misses, which are not deferred.  The
-	 * kernel MUST NOT depend on a particular setting of these bits (in other words,
-	 * the kernel must have recovery code for all speculative accesses).  Turn on
-	 * dcr.lc as per recommendation by the architecture team.  Most IA-32 apps
-	 * shouldn't be affected by this (moral: keep your ia32 locks aligned and you'll
-	 * be fine).
+	 * Initialize default control register to defer speculative faults
+	 * except for those arising from TLB misses, which are not deferred.
+	 * The kernel MUST NOT depend on a particular setting of these bits (in
+	 * other words, the kernel must have recovery code for all speculative
+	 * accesses).  Turn on dcr.lc as per recommendation by the architecture
+	 * team.  Most IA-32 apps shouldn't be affected by this (moral: keep
+	 * your ia32 locks aligned and you'll be fine).
 	 */
 	ia64_setreg(_IA64_REG_CR_DCR,  (  IA64_DCR_DP | IA64_DCR_DK | IA64_DCR_DX | IA64_DCR_DR
 					| IA64_DCR_DA | IA64_DCR_DD | IA64_DCR_LC));
