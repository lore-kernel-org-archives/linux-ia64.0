From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 16 Mar 2009 04:26:26 +0000
Subject: [PULL] cpumask updates for ia64
Message-Id: <200903161444.26659.rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, travis@sgi.com

The following changes since commit 5bee17f18b595937e6beafeee5197868a3f74a06:
  Kyle McMartin (1):
        parisc: sba_iommu: fix build bug when CONFIG_PARISC_AGP=y

are available in the git repository at:

  ssh://master.kernel.org/home/ftp/pub/scm/linux/kernel/git/rusty/linux-2.6-cpumask-for-ia64.git master

Rusty Russell (5):
      cpumask: remove the now-obsoleted pcibus_to_cpumask(): ia64
      cpumask: arch_send_call_function_ipi_mask: ia64
      cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_bits.: ia64
      cpumask: Use accessors code.: ia64
      cpumask: use mm_cpumask() wrapper: ia64

 arch/ia64/include/asm/mmu_context.h |    6 +++---
 arch/ia64/include/asm/smp.h         |    3 ++-
 arch/ia64/include/asm/topology.h    |    5 -----
 arch/ia64/kernel/acpi.c             |    8 ++++----
 arch/ia64/kernel/mca.c              |    6 +++---
 arch/ia64/kernel/perfmon.c          |    4 ++--
 arch/ia64/kernel/salinfo.c          |    6 +++---
 arch/ia64/kernel/setup.c            |    4 ++--
 arch/ia64/kernel/smp.c              |    6 +++---
 arch/ia64/kernel/smpboot.c          |   17 +++++++----------
 arch/ia64/mm/tlb.c                  |    2 +-
 arch/ia64/sn/kernel/setup.c         |    2 +-
 arch/ia64/sn/kernel/sn2/sn2_smp.c   |   10 +++++-----
 arch/ia64/sn/kernel/sn2/sn_hwperf.c |    2 +-
 14 files changed, 37 insertions(+), 44 deletions(-)

commit 5d8c39f68e1dc78c1a958e28bc685a5bac125b21
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Mar 16 14:12:48 2009 +1030

    cpumask: use mm_cpumask() wrapper: ia64
    
    Makes code futureproof against the impending change to mm->cpu_vm_mask.
    
    It's also a chance to use the new cpumask_ ops which take a pointer
    (the older ones are deprecated, but there's no hurry for arch code).
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/ia64/include/asm/mmu_context.h b/arch/ia64/include/asm/mmu_context.h
index 040bc87..7f2a456 100644
--- a/arch/ia64/include/asm/mmu_context.h
+++ b/arch/ia64/include/asm/mmu_context.h
@@ -87,7 +87,7 @@ get_mmu_context (struct mm_struct *mm)
 	/* re-check, now that we've got the lock: */
 	context = mm->context;
 	if (context = 0) {
-		cpus_clear(mm->cpu_vm_mask);
+		cpumask_clear(mm_cpumask(mm));
 		if (ia64_ctx.next >= ia64_ctx.limit) {
 			ia64_ctx.next = find_next_zero_bit(ia64_ctx.bitmap,
 					ia64_ctx.max_ctx, ia64_ctx.next);
@@ -166,8 +166,8 @@ activate_context (struct mm_struct *mm)
 
 	do {
 		context = get_mmu_context(mm);
-		if (!cpu_isset(smp_processor_id(), mm->cpu_vm_mask))
-			cpu_set(smp_processor_id(), mm->cpu_vm_mask);
+		if (!cpumask_test_cpu(smp_processor_id(), mm_cpumask(mm)))
+			cpumask_set_cpu(smp_processor_id(), mm_cpumask(mm));
 		reload_context(context);
 		/*
 		 * in the unlikely event of a TLB-flush by another thread,
diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index bd9818a..b9f3d7b 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -309,7 +309,7 @@ flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
 
 	preempt_disable();
 #ifdef CONFIG_SMP
-	if (mm != current->active_mm || cpus_weight(mm->cpu_vm_mask) != 1) {
+	if (mm != current->active_mm || cpumask_weight(mm_cpumask(mm)) != 1) {
 		platform_global_tlb_purge(mm, start, end, nbits);
 		preempt_enable();
 		return;
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index 209e1eb..3c2f242 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -133,7 +133,7 @@ sn2_ipi_flush_all_tlb(struct mm_struct *mm)
 	unsigned long itc;
 
 	itc = ia64_get_itc();
-	smp_flush_tlb_cpumask(mm->cpu_vm_mask);
+	smp_flush_tlb_cpumask(*mm_cpumask(mm));
 	itc = ia64_get_itc() - itc;
 	__get_cpu_var(ptcstats).shub_ipi_flushes_itc_clocks += itc;
 	__get_cpu_var(ptcstats).shub_ipi_flushes++;
@@ -182,7 +182,7 @@ sn2_global_tlb_purge(struct mm_struct *mm, unsigned long start,
 	nodes_clear(nodes_flushed);
 	i = 0;
 
-	for_each_cpu_mask(cpu, mm->cpu_vm_mask) {
+	for_each_cpu(cpu, mm_cpumask(mm)) {
 		cnode = cpu_to_node(cpu);
 		node_set(cnode, nodes_flushed);
 		lcpu = cpu;

commit 2af51a3f817a22661fcb52da7c96d078a699f40f
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Mar 16 14:12:43 2009 +1030

    cpumask: Use accessors code.: ia64
    
    Impact: use new API
    
    Use the accessors rather than frobbing bits directly.  Most of this is
    in arch code I haven't even compiled, but is straightforward.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Signed-off-by: Mike Travis <travis@sgi.com>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index c4f41ac..2f19d91 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -886,7 +886,7 @@ __init void prefill_possible_map(void)
 		possible, max((possible - available_cpus), 0));
 
 	for (i = 0; i < possible; i++)
-		cpu_set(i, cpu_possible_map);
+		set_cpu_possible(i, true);
 }
 
 int acpi_map_lsapic(acpi_handle handle, int *pcpu)
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 5229054..7700e23 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -581,14 +581,14 @@ smp_build_cpu_map (void)
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
 	cpus_clear(cpu_present_map);
-	cpu_set(0, cpu_present_map);
-	cpu_set(0, cpu_possible_map);
+	set_cpu_present(0, true);
+	set_cpu_possible(0, true);
 	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
 		sapicid = smp_boot_data.cpu_phys_id[i];
 		if (sapicid = boot_cpu_id)
 			continue;
-		cpu_set(cpu, cpu_present_map);
-		cpu_set(cpu, cpu_possible_map);
+		set_cpu_present(cpu, true);
+		set_cpu_possible(cpu, true);
 		ia64_cpu_to_sapicid[cpu] = sapicid;
 		cpu++;
 	}
@@ -626,12 +626,9 @@ smp_prepare_cpus (unsigned int max_cpus)
 	 */
 	if (!max_cpus) {
 		printk(KERN_INFO "SMP mode deactivated.\n");
-		cpus_clear(cpu_online_map);
-		cpus_clear(cpu_present_map);
-		cpus_clear(cpu_possible_map);
-		cpu_set(0, cpu_online_map);
-		cpu_set(0, cpu_present_map);
-		cpu_set(0, cpu_possible_map);
+		init_cpu_online(cpumask_of(0));
+		init_cpu_present(cpumask_of(0));
+		init_cpu_possible(cpumask_of(0));
 		return;
 	}
 }

commit 5dd3c9949a3e92ea7fd8c75d888031f7aff1f1d0
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Mar 16 14:12:42 2009 +1030

    cpumask: prepare for iterators to only go to nr_cpu_ids/nr_cpumask_bits.: ia64
    
    Impact: cleanup, futureproof
    
    In fact, all cpumask ops will only be valid (in general) for bit
    numbers < nr_cpu_ids.  So use that instead of NR_CPUS in various
    places.
    
    This is always safe: no cpu number can be >= nr_cpu_ids, and
    nr_cpu_ids is initialized to NR_CPUS at boot.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
    Signed-off-by: Mike Travis <travis@sgi.com>
    Acked-by: Ingo Molnar <mingo@elte.hu>

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index d541671..c4f41ac 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -924,9 +924,9 @@ int acpi_map_lsapic(acpi_handle handle, int *pcpu)
 	buffer.length = ACPI_ALLOCATE_BUFFER;
 	buffer.pointer = NULL;
 
-	cpus_complement(tmp_map, cpu_present_map);
-	cpu = first_cpu(tmp_map);
-	if (cpu >= NR_CPUS)
+	cpumask_complement(&tmp_map, cpu_present_mask);
+	cpu = cpumask_first(&tmp_map);
+	if (cpu >= nr_cpu_ids)
 		return -EINVAL;
 
 	acpi_map_cpu2node(handle, cpu, physid);
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index bab1de2..8f33a88 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1456,9 +1456,9 @@ ia64_mca_cmc_int_caller(int cmc_irq, void *arg)
 
 	ia64_mca_cmc_int_handler(cmc_irq, arg);
 
-	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
+	cpuid = cpumask_next(cpuid+1, cpu_online_mask);
 
-	if (cpuid < NR_CPUS) {
+	if (cpuid < nr_cpu_ids) {
 		platform_send_ipi(cpuid, IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 	} else {
 		/* If no log record, switch out of polling mode */
@@ -1525,7 +1525,7 @@ ia64_mca_cpe_int_caller(int cpe_irq, void *arg)
 
 	ia64_mca_cpe_int_handler(cpe_irq, arg);
 
-	for (++cpuid ; cpuid < NR_CPUS && !cpu_online(cpuid) ; cpuid++);
+	cpuid = cpumask_next(cpuid+1, cpu_online_mask);
 
 	if (cpuid < NR_CPUS) {
 		platform_send_ipi(cpuid, IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
diff --git a/arch/ia64/kernel/perfmon.c b/arch/ia64/kernel/perfmon.c
index 0e49975..6fc1e63 100644
--- a/arch/ia64/kernel/perfmon.c
+++ b/arch/ia64/kernel/perfmon.c
@@ -5603,7 +5603,7 @@ pfm_interrupt_handler(int irq, void *arg)
  * /proc/perfmon interface, for debug only
  */
 
-#define PFM_PROC_SHOW_HEADER	((void *)NR_CPUS+1)
+#define PFM_PROC_SHOW_HEADER	((void *)nr_cpu_ids+1)
 
 static void *
 pfm_proc_start(struct seq_file *m, loff_t *pos)
@@ -5612,7 +5612,7 @@ pfm_proc_start(struct seq_file *m, loff_t *pos)
 		return PFM_PROC_SHOW_HEADER;
 	}
 
-	while (*pos <= NR_CPUS) {
+	while (*pos <= nr_cpu_ids) {
 		if (cpu_online(*pos - 1)) {
 			return (void *)*pos;
 		}
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index ecb9eb7..7053c55 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -317,7 +317,7 @@ retry:
 	}
 
 	n = data->cpu_check;
-	for (i = 0; i < NR_CPUS; i++) {
+	for (i = 0; i < nr_cpu_ids; i++) {
 		if (cpu_isset(n, data->cpu_event)) {
 			if (!cpu_online(n)) {
 				cpu_clear(n, data->cpu_event);
@@ -326,7 +326,7 @@ retry:
 			cpu = n;
 			break;
 		}
-		if (++n = NR_CPUS)
+		if (++n = nr_cpu_ids)
 			n = 0;
 	}
 
@@ -337,7 +337,7 @@ retry:
 
 	/* for next read, start checking at next CPU */
 	data->cpu_check = cpu;
-	if (++data->cpu_check = NR_CPUS)
+	if (++data->cpu_check = nr_cpu_ids)
 		data->cpu_check = 0;
 
 	snprintf(cmd, sizeof(cmd), "read %d\n", cpu);
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 865af27..ae9ec3d 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -730,10 +730,10 @@ static void *
 c_start (struct seq_file *m, loff_t *pos)
 {
 #ifdef CONFIG_SMP
-	while (*pos < NR_CPUS && !cpu_isset(*pos, cpu_online_map))
+	while (*pos < nr_cpu_ids && !cpu_online(*pos))
 		++*pos;
 #endif
-	return *pos < NR_CPUS ? cpu_data(*pos) : NULL;
+	return *pos < nr_cpu_ids ? cpu_data(*pos) : NULL;
 }
 
 static void *
diff --git a/arch/ia64/sn/kernel/setup.c b/arch/ia64/sn/kernel/setup.c
index 02c5b8a..1209777 100644
--- a/arch/ia64/sn/kernel/setup.c
+++ b/arch/ia64/sn/kernel/setup.c
@@ -750,7 +750,7 @@ nasid_slice_to_cpuid(int nasid, int slice)
 {
 	long cpu;
 
-	for (cpu = 0; cpu < NR_CPUS; cpu++)
+	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		if (cpuid_to_nasid(cpu) = nasid &&
 					cpuid_to_slice(cpu) = slice)
 			return cpu;
diff --git a/arch/ia64/sn/kernel/sn2/sn2_smp.c b/arch/ia64/sn/kernel/sn2/sn2_smp.c
index e585f9a..209e1eb 100644
--- a/arch/ia64/sn/kernel/sn2/sn2_smp.c
+++ b/arch/ia64/sn/kernel/sn2/sn2_smp.c
@@ -461,7 +461,7 @@ bool sn_cpu_disable_allowed(int cpu)
 
 static void *sn2_ptc_seq_start(struct seq_file *file, loff_t * offset)
 {
-	if (*offset < NR_CPUS)
+	if (*offset < nr_cpu_ids)
 		return offset;
 	return NULL;
 }
@@ -469,7 +469,7 @@ static void *sn2_ptc_seq_start(struct seq_file *file, loff_t * offset)
 static void *sn2_ptc_seq_next(struct seq_file *file, void *data, loff_t * offset)
 {
 	(*offset)++;
-	if (*offset < NR_CPUS)
+	if (*offset < nr_cpu_ids)
 		return offset;
 	return NULL;
 }
@@ -491,7 +491,7 @@ static int sn2_ptc_seq_show(struct seq_file *file, void *data)
 		seq_printf(file, "# ptctest %d, flushopt %d\n", sn2_ptctest, sn2_flush_opt);
 	}
 
-	if (cpu < NR_CPUS && cpu_online(cpu)) {
+	if (cpu < nr_cpu_ids && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
 		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n", cpu, stat->ptc_l,
 				stat->change_rid, stat->shub_ptc_flushes, stat->nodes_flushed,
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index be33947..45f3c23 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -612,7 +612,7 @@ static int sn_hwperf_op_cpu(struct sn_hwperf_op_info *op_info)
 	op_info->a->arg &= SN_HWPERF_ARG_OBJID_MASK;
 
 	if (cpu != SN_HWPERF_ARG_ANY_CPU) {
-		if (cpu >= NR_CPUS || !cpu_online(cpu)) {
+		if (cpu >= nr_cpu_ids || !cpu_online(cpu)) {
 			r = -EINVAL;
 			goto out;
 		}

commit 40fe697a1759b85f5e06c490599f4f7b03de3be7
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Mar 16 14:12:41 2009 +1030

    cpumask: arch_send_call_function_ipi_mask: ia64
    
    We're weaning the core code off handing cpumask's around on-stack.
    This introduces arch_send_call_function_ipi_mask().
    
    We also take the chance to wean send_IPI_mask off the obsolescent
    for_each_cpu_mask(): making it take the pointer seemed the most
    natural way.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/ia64/include/asm/smp.h b/arch/ia64/include/asm/smp.h
index 21c4023..5984083 100644
--- a/arch/ia64/include/asm/smp.h
+++ b/arch/ia64/include/asm/smp.h
@@ -126,7 +126,8 @@ extern void identify_siblings (struct cpuinfo_ia64 *);
 extern int is_multithreading_enabled(void);
 
 extern void arch_send_call_function_single_ipi(int cpu);
-extern void arch_send_call_function_ipi(cpumask_t mask);
+extern void arch_send_call_function_ipi_mask(const struct cpumask *mask);
+#define arch_send_call_function_ipi_mask arch_send_call_function_ipi_mask
 
 #else /* CONFIG_SMP */
 
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index da8f020..2ea4199 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -166,11 +166,11 @@ send_IPI_allbutself (int op)
  * Called with preemption disabled.
  */
 static inline void
-send_IPI_mask(cpumask_t mask, int op)
+send_IPI_mask(const struct cpumask *mask, int op)
 {
 	unsigned int cpu;
 
-	for_each_cpu_mask(cpu, mask) {
+	for_each_cpu(cpu, mask) {
 			send_IPI_single(cpu, op);
 	}
 }
@@ -316,7 +316,7 @@ void arch_send_call_function_single_ipi(int cpu)
 	send_IPI_single(cpu, IPI_CALL_FUNC_SINGLE);
 }
 
-void arch_send_call_function_ipi(cpumask_t mask)
+void arch_send_call_function_ipi_mask(const struct cpumask *mask)
 {
 	send_IPI_mask(mask, IPI_CALL_FUNC);
 }

commit d4e3676dba299e24acb66de6da2a0bb44d0d2414
Author: Rusty Russell <rusty@rustcorp.com.au>
Date:   Mon Mar 16 14:12:40 2009 +1030

    cpumask: remove the now-obsoleted pcibus_to_cpumask(): ia64
    
    Impact: reduce stack usage for large NR_CPUS
    
    cpumask_of_pcibus() is the new version.
    
    Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/arch/ia64/include/asm/topology.h b/arch/ia64/include/asm/topology.h
index 32f3af1..6fbbf87 100644
--- a/arch/ia64/include/asm/topology.h
+++ b/arch/ia64/include/asm/topology.h
@@ -117,11 +117,6 @@ void build_cpu_to_node_map(void);
 
 extern void arch_fix_phys_package_id(int num, u32 slot);
 
-#define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) = -1 ? \
-					CPU_MASK_ALL : \
-					node_to_cpumask(pcibus_to_node(bus)) \
-				)
-
 #define cpumask_of_pcibus(bus)	(pcibus_to_node(bus) = -1 ?		\
 				 cpu_all_mask :				\
 				 cpumask_of_node(pcibus_to_node(bus)))

