From: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2012 10:53:57 +0000
Subject: [PATCH v2] arch/ia64: remove references to cpu_*_map.
Message-Id: <4F3B8EAE.4050809@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, Venkatesh Pallipadi <venki@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mike Travis <travis@sgi.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Gortmaker <paul.gortmaker@windriver.com>

From: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>

This was marked as obsolete for quite a while now.. Now it is time to remove
it altogether. And while doing this, get rid of first_cpu() as well.
Also, remove the redundant setting of cpu_online_mask in smp_prepare_cpus()
because the generic code would have already set cpu 0 in cpu_online_mask.

Reported-by: Tony Luck <tony.luck@intel.com>
Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
---
Tony, I thought it is better to not add your Tested-by to this version, because I
have changed the code, doing more cleanups.

This patch ought to go along with the patchsets that do cleanups in other
architectures as well.. And it looks like Rusty's patchset[1] is a superset of
Venki's patchset[2].. So, Rusty, would you kindly take this patch into your
patchset? (It should come before the 11/12 in your patchset. This should apply
at that point easily, because I have modified it to suit your 11/12 which also
touches ia64).

Thanks a lot!

[1] https://lkml.org/lkml/2012/2/15/4
[2] https://lkml.org/lkml/2012/2/14/380

 arch/ia64/kernel/acpi.c     |    6 +++---
 arch/ia64/kernel/irq_ia64.c |    8 ++++----
 arch/ia64/kernel/mca.c      |    6 ++++--
 arch/ia64/kernel/msi_ia64.c |    4 ++--
 arch/ia64/kernel/setup.c    |    2 +-
 arch/ia64/kernel/smp.c      |    2 +-
 arch/ia64/kernel/smpboot.c  |   19 +++++++------------
 arch/ia64/kernel/topology.c |    3 ++-
 8 files changed, 24 insertions(+), 26 deletions(-)

diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 5207035..2ad7328 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -844,7 +844,7 @@ early_param("additional_cpus", setup_additional_cpus);
  * are onlined, or offlined. The reason is per-cpu data-structures
  * are allocated by some modules at init time, and dont expect to
  * do this dynamically on cpu arrival/departure.
- * cpu_present_map on the other hand can change dynamically.
+ * cpu_present_mask on the other hand can change dynamically.
  * In case when cpu_hotplug is not compiled, then we resort to current
  * behaviour, which is cpu_possible = cpu_present.
  * - Ashok Raj
@@ -922,7 +922,7 @@ static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)
 
 	acpi_map_cpu2node(handle, cpu, physid);
 
-	cpu_set(cpu, cpu_present_map);
+	set_cpu_present(cpu, true);
 	ia64_cpu_to_sapicid[cpu] = physid;
 
 	acpi_processor_set_pdc(handle);
@@ -941,7 +941,7 @@ EXPORT_SYMBOL(acpi_map_lsapic);
 int acpi_unmap_lsapic(int cpu)
 {
 	ia64_cpu_to_sapicid[cpu] = -1;
-	cpu_clear(cpu, cpu_present_map);
+	set_cpu_present(cpu, false);
 
 #ifdef CONFIG_ACPI_NUMA
 	/* NUMA specific cleanup's */
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 782c3a35..51da772 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -118,7 +118,7 @@ static inline int find_unassigned_vector(cpumask_t domain)
 	cpumask_t mask;
 	int pos, vector;
 
-	cpus_and(mask, domain, cpu_online_map);
+	cpumask_and(&mask, &domain, cpu_online_mask);
 	if (cpus_empty(mask))
 		return -EINVAL;
 
@@ -141,7 +141,7 @@ static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 	BUG_ON((unsigned)irq >= NR_IRQS);
 	BUG_ON((unsigned)vector >= IA64_NUM_VECTORS);
 
-	cpus_and(mask, domain, cpu_online_map);
+	cpumask_and(&mask, &domain, cpu_online_mask);
 	if (cpus_empty(mask))
 		return -EINVAL;
 	if ((cfg->vector = vector) && cpus_equal(cfg->domain, domain))
@@ -179,7 +179,7 @@ static void __clear_irq_vector(int irq)
 	BUG_ON(cfg->vector = IRQ_VECTOR_UNASSIGNED);
 	vector = cfg->vector;
 	domain = cfg->domain;
-	cpus_and(mask, cfg->domain, cpu_online_map);
+	cpumask_and(&mask, &cfg->domain, cpu_online_mask);
 	for_each_cpu_mask(cpu, mask)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 	cfg->vector = IRQ_VECTOR_UNASSIGNED;
@@ -322,7 +322,7 @@ void irq_complete_move(unsigned irq)
 	if (unlikely(cpu_isset(smp_processor_id(), cfg->old_domain)))
 		return;
 
-	cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
+	cpumask_and(&cleanup_mask, &cfg->old_domain, cpu_online_mask);
 	cfg->move_cleanup_count = cpus_weight(cleanup_mask);
 	for_each_cpu_mask(i, cleanup_mask)
 		platform_send_ipi(i, IA64_IRQ_MOVE_VECTOR, IA64_IPI_DM_INT, 0);
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 8192009..26dbbd3 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1515,7 +1515,8 @@ static void
 ia64_mca_cmc_poll (unsigned long dummy)
 {
 	/* Trigger a CMC interrupt cascade  */
-	platform_send_ipi(first_cpu(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CMCP_VECTOR,
+							IA64_IPI_DM_INT, 0);
 }
 
 /*
@@ -1591,7 +1592,8 @@ static void
 ia64_mca_cpe_poll (unsigned long dummy)
 {
 	/* Trigger a CPE interrupt cascade  */
-	platform_send_ipi(first_cpu(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CPEP_VECTOR,
+							IA64_IPI_DM_INT, 0);
 }
 
 #endif /* CONFIG_ACPI */
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 94e0db7..fb2f1e6 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -57,7 +57,7 @@ int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 		return irq;
 
 	irq_set_msi_desc(irq, desc);
-	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
+	cpumask_and(&mask, &(irq_to_domain(irq)), cpu_online_mask);
 	dest_phys_id = cpu_physical_id(first_cpu(mask));
 	vector = irq_to_vector(irq);
 
@@ -179,7 +179,7 @@ msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
 	unsigned dest;
 	cpumask_t mask;
 
-	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
+	cpumask_and(&mask, &(irq_to_domain(irq)), cpu_online_mask);
 	dest = cpu_physical_id(first_cpu(mask));
 
 	msg->address_hi = 0;
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index cd57d73..4d1a550 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -486,7 +486,7 @@ mark_bsp_online (void)
 {
 #ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
-	cpu_set(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), true);
 #endif
 }
 
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index 0bd537b..8551979 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -77,7 +77,7 @@ stop_this_cpu(void)
 	/*
 	 * Remove this CPU:
 	 */
-	cpu_clear(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), false);
 	max_xtp();
 	local_irq_disable();
 	cpu_halt();
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 5590979..90916be 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -401,7 +401,7 @@ smp_callin (void)
 	/* Setup the per cpu irq handling data structures */
 	__setup_vector_irq(cpuid);
 	notify_cpu_starting(cpuid);
-	cpu_set(cpuid, cpu_online_map);
+	set_cpu_online(cpuid, true);
 	per_cpu(cpu_state, cpuid) = CPU_ONLINE;
 	spin_unlock(&vector_lock);
 	ipi_call_unlock_irq();
@@ -548,7 +548,7 @@ do_rest:
 	if (!cpu_isset(cpu, cpu_callin_map)) {
 		printk(KERN_ERR "Processor 0x%x/0x%x is stuck.\n", cpu, sapicid);
 		ia64_cpu_to_sapicid[cpu] = -1;
-		cpu_clear(cpu, cpu_online_map);  /* was set in smp_callin() */
+		set_cpu_online(cpu, false);  /* was set in smp_callin() */
 		return -EINVAL;
 	}
 	return 0;
@@ -578,8 +578,7 @@ smp_build_cpu_map (void)
 	}
 
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
-	cpus_clear(cpu_present_map);
-	set_cpu_present(0, true);
+	init_cpu_present(cpumask_of(0));
 	set_cpu_possible(0, true);
 	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
 		sapicid = smp_boot_data.cpu_phys_id[i];
@@ -606,10 +605,6 @@ smp_prepare_cpus (unsigned int max_cpus)
 
 	smp_setup_percpu_timer();
 
-	/*
-	 * We have the boot CPU online for sure.
-	 */
-	cpu_set(0, cpu_online_map);
 	cpu_set(0, cpu_callin_map);
 
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
@@ -633,7 +628,7 @@ smp_prepare_cpus (unsigned int max_cpus)
 
 void __devinit smp_prepare_boot_cpu(void)
 {
-	cpu_set(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), true);
 	cpu_set(smp_processor_id(), cpu_callin_map);
 	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
@@ -690,7 +685,7 @@ int migrate_platform_irqs(unsigned int cpu)
 			/*
 			 * Now re-target the CPEI to a different processor
 			 */
-			new_cpei_cpu = any_online_cpu(cpu_online_map);
+			new_cpei_cpu = cpumask_any(cpu_online_mask);
 			mask = cpumask_of(new_cpei_cpu);
 			set_cpei_target_cpu(new_cpei_cpu);
 			data = irq_get_irq_data(ia64_cpe_irq);
@@ -732,10 +727,10 @@ int __cpu_disable(void)
 			return -EBUSY;
 	}
 
-	cpu_clear(cpu, cpu_online_map);
+	set_cpu_online(cpu, false);
 
 	if (migrate_platform_irqs(cpu)) {
-		cpu_set(cpu, cpu_online_map);
+		set_cpu_online(cpu, true);
 		return -EBUSY;
 	}
 
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 9deb21d..c64460b 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -220,7 +220,8 @@ static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
 	ssize_t	len;
 	cpumask_t shared_cpu_map;
 
-	cpus_and(shared_cpu_map, this_leaf->shared_cpu_map, cpu_online_map);
+	cpumask_and(&shared_cpu_map,
+				&this_leaf->shared_cpu_map, cpu_online_mask);
 	len = cpumask_scnprintf(buf, NR_CPUS+1, &shared_cpu_map);
 	len += sprintf(buf+len, "\n");
 	return len;


