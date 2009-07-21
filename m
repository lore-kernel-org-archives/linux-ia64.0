From: Tejun Heo <tj@kernel.org>
Date: Tue, 21 Jul 2009 12:12:27 +0000
Subject: [RFC PATCH] ia64: convert to dynamic percpu allocator
Message-Id: <4A65B0AB.5000608@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, lkml <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, linux-ia64@vger.kernel.org

Unlike other archs, ia64 reserves space for percpu areas during early
memory initialization.  The space for cpu0 is reserved separate in the
linker script.  Other cpus occupy a contiguous region indexed by cpu
number on contiguous memory model or are grouped by node on
discontiguous memory model.

As allocation and initialization are done by the arch code, all that
setup_per_cpu_areas() needs to do is communicating the determined
layout to the percpu allocator.  This patch implements
setup_per_cpu_areas() for both contig and discontig memory models and
drops HAVE_LEGACY_PER_CPU_AREA.

NOT_SIGNED_OFF_YET
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
I don't have access to an ia64 machine so I could only test with ski.
With sim_defconfig, it boots but I didn't have any userland.
discontig configuration builds fine but I couldn't test it.

Can you guys please verify this patch?

This patch is available in the following git tree.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/percpu.git review-ia64

Thanks.

 arch/ia64/Kconfig        |    3 -
 arch/ia64/kernel/setup.c |   12 ------
 arch/ia64/mm/contig.c    |   67 +++++++++++++++++++++++++++++++++
 arch/ia64/mm/discontig.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 161 insertions(+), 15 deletions(-)

Index: work/arch/ia64/Kconfig
=================================--- work.orig/arch/ia64/Kconfig
+++ work/arch/ia64/Kconfig
@@ -89,9 +89,6 @@ config GENERIC_TIME_VSYSCALL
 	bool
 	default y
 
-config HAVE_LEGACY_PER_CPU_AREA
-	def_bool y
-
 config HAVE_SETUP_PER_CPU_AREA
 	def_bool y
 
Index: work/arch/ia64/mm/contig.c
=================================--- work.orig/arch/ia64/mm/contig.c
+++ work/arch/ia64/mm/contig.c
@@ -186,6 +186,73 @@ alloc_per_cpu_data(void)
 	cpu_data = __alloc_bootmem(PERCPU_PAGE_SIZE * NR_CPUS-1,
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
+	unsigned int *cpu_map;
+	unsigned int cpu;
+	void *base, *grp0_base, *grp1_base = NULL;
+	int rc;
+
+	ai = pcpu_alloc_alloc_info(2, nr_cpu_ids);
+	if (!ai)
+		panic("failed to allocate pcpu_alloc_info");
+	cpu_map = ai->groups[0].cpu_map;
+
+	/* cpus are identity mapped to units */
+	for_each_possible_cpu(cpu)
+		cpu_map[cpu] = cpu;
+
+	/* determine bases */
+	base = grp0_base = __per_cpu_start + __per_cpu_offset[0];
+	if (num_possible_cpus() > 1) {
+		grp1_base = __per_cpu_start + __per_cpu_offset[1];
+		base = min(grp0_base, grp1_base);
+	}
+
+	/* set basic parameters */
+	ai->static_size		= __per_cpu_end - __per_cpu_start;
+	ai->reserved_size	= PERCPU_MODULE_RESERVE; /* tj - necessary? */
+	ai->dyn_size		= PERCPU_DYNAMIC_RESERVE;
+	ai->unit_size		= PERCPU_PAGE_SIZE;
+	ai->atom_size		= PAGE_SIZE;
+	ai->alloc_size		= PERCPU_PAGE_SIZE;
+
+	/*
+	 * BSP is always present and occupies separate statically
+	 * reserved area.
+	 */
+	ai->nr_groups = 0;
+	gi = &ai->groups[ai->nr_groups++];
+	gi->nr_units		= 1;
+	gi->base_offset		= grp0_base - base;
+	gi->cpu_map		= &cpu_map[0];
+
+	if (grp1_base) {
+		/* all APs occupy single contiguos region indexed by cpu id */
+		gi = &ai->groups[ai->nr_groups++];
+		gi->nr_units		= nr_cpu_ids - 1;
+		gi->base_offset		= grp1_base - base;
+		gi->cpu_map		= &cpu_map[1];
+	}
+
+	rc = pcpu_setup_first_chunk(ai, base);
+	if (rc)
+		panic("failed to setup percpu area (err=%d)", rc);
+
+	pcpu_free_alloc_info(ai);
+}
 #else
 #define alloc_per_cpu_data() do { } while (0)
 #endif /* CONFIG_SMP */
Index: work/arch/ia64/mm/discontig.c
=================================--- work.orig/arch/ia64/mm/discontig.c
+++ work/arch/ia64/mm/discontig.c
@@ -159,6 +159,100 @@ static void *per_cpu_node_setup(void *cp
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
+	struct pcpu_group_info *gi;
+	unsigned int *cpu_map;
+	void *base;
+	unsigned long base_offset;
+	unsigned int cpu;
+	int node, prev_node, unit, nr_units, rc;
+
+	ai = pcpu_alloc_alloc_info(MAX_NUMNODES + 1, nr_cpu_ids);
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
+	/*
+	 * Build cpu_map.  cpu0 is always mapped to unit0.  The rest
+	 * are grouped by node.
+	 */
+	unit = 0;
+	cpu_map[unit++] = 0;
+	for_each_node(node) {
+		for_each_possible_cpu(cpu) {
+			if (cpu = 0)
+				continue;
+			if (node = node_cpuid[cpu].nid)
+				cpu_map[unit++] = cpu;
+		}
+	}
+	nr_units = unit;
+
+	/* set basic parameters */
+	ai->static_size		= __per_cpu_end - __per_cpu_start;
+	ai->reserved_size	= PERCPU_MODULE_RESERVE; /* tj - necessary? */
+	ai->dyn_size		= PERCPU_DYNAMIC_RESERVE;
+	ai->unit_size		= PERCPU_PAGE_SIZE;
+	ai->atom_size		= PAGE_SIZE;
+	ai->alloc_size		= PERCPU_PAGE_SIZE;
+
+	/*
+	 * BSP is always present and occupies separate statically
+	 * reserved area.
+	 */
+	ai->nr_groups = 0;
+	gi = &ai->groups[ai->nr_groups++];
+	gi->nr_units		= 1;
+	gi->base_offset		= __per_cpu_offset[0] + base_offset;
+	gi->cpu_map		= &cpu_map[0];
+
+	/*
+	 * APs should be put into groups according to node.  Walk
+	 * cpu_map and create new groups at node boundaries.
+	 */
+	prev_node = -1;
+	for (unit = 1; unit < nr_units; unit++) {
+		unsigned int cpu = cpu_map[unit];
+
+		node = node_cpuid[cpu].nid;
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
Index: work/arch/ia64/kernel/setup.c
=================================--- work.orig/arch/ia64/kernel/setup.c
+++ work/arch/ia64/kernel/setup.c
@@ -856,18 +856,6 @@ identify_cpu (struct cpuinfo_ia64 *c)
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
