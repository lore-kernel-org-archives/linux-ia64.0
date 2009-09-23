From: Tejun Heo <tj@kernel.org>
Date: Wed, 23 Sep 2009 05:06:21 +0000
Subject: [PATCH 4/5] ia64: convert to dynamic percpu allocator
Message-Id: <1253682382-24740-5-git-send-email-tj@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1253682382-24740-1-git-send-email-tj@kernel.org>
In-Reply-To: <1253682382-24740-1-git-send-email-tj@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Nick Piggin <npiggin@suse.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Rusty Russell <rusty@rustcorp.com.au>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64 <linux-ia64@vger.kernel.org>

Unlike other archs, ia64 reserves space for percpu areas during early
memory initialization.  These areas occupy a contiguous region indexed
by cpu number on contiguous memory model or are grouped by node on
discontiguous memory model.

As allocation and initialization are done by the arch code, all that
setup_per_cpu_areas() needs to do is communicating the determined
layout to the percpu allocator.  This patch implements
setup_per_cpu_areas() for both contig and discontig memory models and
drops HAVE_LEGACY_PER_CPU_AREA.

Please note that for contig model, the allocation itself is modified
only to allocate for possible cpus instead of NR_CPUS.  As dynamic
percpu allocator can handle non-direct mapping, there's no reason to
allocate memory for cpus which aren't possible.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64 <linux-ia64@vger.kernel.org>
---
 arch/ia64/Kconfig        |    3 --
 arch/ia64/kernel/setup.c |   12 ------
 arch/ia64/mm/contig.c    |   58 ++++++++++++++++++++++++++++---
 arch/ia64/mm/discontig.c |   85 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 138 insertions(+), 20 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 011a1cd..e624611 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -89,9 +89,6 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default y
 
-config HAVE_LEGACY_PER_CPU_AREA
-	def_bool y
-
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 5d77c1e..bc1ef4a 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -855,18 +855,6 @@ identify_cpu (struct cpuinfo_ia64 *c)
 }
 
 /*
- * In UP configuration, setup_per_cpu_areas() is defined in
- * include/linux/percpu.h
- */
-#ifdef CONFIG_SMP
-void __init
-setup_per_cpu_areas (void)
-{
-	/* start_kernel() requires this... */
-}
-#endif
-
-/*
  * Do the following calculations:
  *
  * 1. the max. cache line size.
diff --git a/arch/ia64/mm/contig.c b/arch/ia64/mm/contig.c
index 351da0a..54bf540 100644
--- a/arch/ia64/mm/contig.c
+++ b/arch/ia64/mm/contig.c
@@ -163,11 +163,11 @@ per_cpu_init (void)
 	first_time = false;
 
 	/*
-	 * get_free_pages() cannot be used before cpu_init() done.  BSP
-	 * allocates "NR_CPUS" pages for all CPUs to avoid that AP calls
-	 * get_zeroed_page().
+	 * get_free_pages() cannot be used before cpu_init() done.
+	 * BSP allocates PERCPU_PAGE_SIZE bytes for all possible CPUs
+	 * to avoid that AP calls get_zeroed_page().
 	 */
-	for (cpu = 0; cpu < NR_CPUS; cpu++) {
+	for_each_possible_cpu(cpu) {
 		void *src = cpu = 0 ? cpu0_data : __phys_per_cpu_start;
 
 		memcpy(cpu_data, src, __per_cpu_end - __per_cpu_start);
@@ -196,9 +196,57 @@ skip:
 static inline void
 alloc_per_cpu_data(void)
 {
-	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS,
+	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * num_possible_cpus(),
 				   PERCPU_PAGE_SIZE, __pa(MAX_DMA_ADDRESS));
 }
+
+/**
+ * setup_per_cpu_areas - setup percpu areas
+ *
+ * Arch code has already allocated and initialized percpu areas.  All
+ * this function has to do is to teach the determined layout to the
+ * dynamic percpu allocator, which happens to be more complex than
+ * creating whole new ones using helpers.
+ */
+void __init
+setup_per_cpu_areas(void)
+{
+	struct pcpu_alloc_info *ai;
+	struct pcpu_group_info *gi;
+	unsigned int cpu;
+	ssize_t static_size, reserved_size, dyn_size;
+	int rc;
+
+	ai = pcpu_alloc_alloc_info(1, num_possible_cpus());
+	if (!ai)
+		panic("failed to allocate pcpu_alloc_info");
+	gi = &ai->groups[0];
+
+	/* units are assigned consecutively to possible cpus */
+	for_each_possible_cpu(cpu)
+		gi->cpu_map[gi->nr_units++] = cpu;
+
+	/* set parameters */
+	static_size = __per_cpu_end - __per_cpu_start;
+	reserved_size = PERCPU_MODULE_RESERVE;
+	dyn_size = PERCPU_PAGE_SIZE - static_size - reserved_size;
+	if (dyn_size < 0)
+		panic("percpu area overflow static=%zd reserved=%zd\n",
+		      static_size, reserved_size);
+
+	ai->static_size		= static_size;
+	ai->reserved_size	= reserved_size;
+	ai->dyn_size		= dyn_size;
+	ai->unit_size		= PERCPU_PAGE_SIZE;
+	ai->atom_size		= PAGE_SIZE;
+	ai->alloc_size		= PERCPU_PAGE_SIZE;
+
+	rc = pcpu_setup_first_chunk(ai, __per_cpu_start + __per_cpu_offset[0]);
+	if (rc)
+		panic("failed to setup percpu area (err=%d)", rc);
+
+	pcpu_free_alloc_info(ai);
+}
 #else
 #define alloc_per_cpu_data() do { } while (0)
 #endif /* CONFIG_SMP */
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 200282b..40e4c1f 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -172,6 +172,91 @@ static void *per_cpu_node_setup(void *cpu_data, int node)
 	return cpu_data;
 }
 
+#ifdef CONFIG_SMP
+/**
+ * setup_per_cpu_areas - setup percpu areas
+ *
+ * Arch code has already allocated and initialized percpu areas.  All
+ * this function has to do is to teach the determined layout to the
+ * dynamic percpu allocator, which happens to be more complex than
+ * creating whole new ones using helpers.
+ */
+void __init setup_per_cpu_areas(void)
+{
+	struct pcpu_alloc_info *ai;
+	struct pcpu_group_info *uninitialized_var(gi);
+	unsigned int *cpu_map;
+	void *base;
+	unsigned long base_offset;
+	unsigned int cpu;
+	ssize_t static_size, reserved_size, dyn_size;
+	int node, prev_node, unit, nr_units, rc;
+
+	ai = pcpu_alloc_alloc_info(MAX_NUMNODES, nr_cpu_ids);
+	if (!ai)
+		panic("failed to allocate pcpu_alloc_info");
+	cpu_map = ai->groups[0].cpu_map;
+
+	/* determine base */
+	base = (void *)ULONG_MAX;
+	for_each_possible_cpu(cpu)
+		base = min(base,
+			   (void *)(__per_cpu_offset[cpu] + __per_cpu_start));
+	base_offset = (void *)__per_cpu_start - base;
+
+	/* build cpu_map, units are grouped by node */
+	unit = 0;
+	for_each_node(node)
+		for_each_possible_cpu(cpu)
+			if (node = node_cpuid[cpu].nid)
+				cpu_map[unit++] = cpu;
+	nr_units = unit;
+
+	/* set basic parameters */
+	static_size = __per_cpu_end - __per_cpu_start;
+	reserved_size = PERCPU_MODULE_RESERVE;
+	dyn_size = PERCPU_PAGE_SIZE - static_size - reserved_size;
+	if (dyn_size < 0)
+		panic("percpu area overflow static=%zd reserved=%zd\n",
+		      static_size, reserved_size);
+
+	ai->static_size		= static_size;
+	ai->reserved_size	= reserved_size;
+	ai->dyn_size		= dyn_size;
+	ai->unit_size		= PERCPU_PAGE_SIZE;
+	ai->atom_size		= PAGE_SIZE;
+	ai->alloc_size		= PERCPU_PAGE_SIZE;
+
+	/*
+	 * CPUs are put into groups according to node.  Walk cpu_map
+	 * and create new groups at node boundaries.
+	 */
+	prev_node = -1;
+	ai->nr_groups = 0;
+	for (unit = 0; unit < nr_units; unit++) {
+		cpu = cpu_map[unit];
+		node = node_cpuid[cpu].nid;
+
+		if (node = prev_node) {
+			gi->nr_units++;
+			continue;
+		}
+		prev_node = node;
+
+		gi = &ai->groups[ai->nr_groups++];
+		gi->nr_units		= 1;
+		gi->base_offset		= __per_cpu_offset[cpu] + base_offset;
+		gi->cpu_map		= &cpu_map[unit];
+	}
+
+	rc = pcpu_setup_first_chunk(ai, base);
+	if (rc)
+		panic("failed to setup percpu area (err=%d)", rc);
+
+	pcpu_free_alloc_info(ai);
+}
+#endif
+
 /**
  * fill_pernode - initialize pernode data.
  * @node: the node id.
-- 
1.6.4.2

