From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Thu, 23 Jun 2011 10:55:19 +0000
Subject: ia64: replace old cpumask functions with new one
Message-Id: <4E031B97.2010609@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com

We plan to remove old obsolete cpumask functions and plan to
change task->cpus_allowed implementation in future.

Then, this patch replace them with newer recommended functions.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/acpi.h            |    6 ++--
 arch/ia64/kernel/acpi.c                 |    6 ++--
 arch/ia64/kernel/cpufreq/acpi-cpufreq.c |    4 +-
 arch/ia64/kernel/iosapic.c              |    2 +-
 arch/ia64/kernel/irq_ia64.c             |   48 ++++++++++++++-------------
 arch/ia64/kernel/mca.c                  |   14 ++++----
 arch/ia64/kernel/msi_ia64.c             |   10 +++---
 arch/ia64/kernel/numa.c                 |   10 +++---
 arch/ia64/kernel/salinfo.c              |   27 ++++++++-------
 arch/ia64/kernel/setup.c                |   12 +++---
 arch/ia64/kernel/smp.c                  |   11 +++---
 arch/ia64/kernel/smpboot.c              |   56 +++++++++++++++---------------
 arch/ia64/kernel/topology.c             |   11 +++---
 arch/ia64/sn/kernel/sn2/sn_hwperf.c     |    2 +-
 14 files changed, 112 insertions(+), 107 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index a06dfb1..226c3bb 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -169,7 +169,7 @@ static inline void arch_acpi_set_pdc_bits(u32 *buf)
 #ifdef CONFIG_ACPI_NUMA
 extern cpumask_t early_cpu_possible_map;
 #define for_each_possible_early_cpu(cpu)  \
-	for_each_cpu_mask((cpu), early_cpu_possible_map)
+	for_each_cpu((cpu), &early_cpu_possible_map)

 static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
 {
@@ -177,13 +177,13 @@ static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
 	int cpu;
 	int next_nid = 0;

-	low_cpu = cpus_weight(early_cpu_possible_map);
+	low_cpu = cpumask_weight(&early_cpu_possible_map);

 	high_cpu = max(low_cpu, min_cpus);
 	high_cpu = min(high_cpu + reserve_cpus, NR_CPUS);

 	for (cpu = low_cpu; cpu < high_cpu; cpu++) {
-		cpu_set(cpu, early_cpu_possible_map);
+		cpumask_set_cpu(cpu, &early_cpu_possible_map);
 		if (node_cpuid[cpu].nid = NUMA_NO_NODE) {
 			node_cpuid[cpu].nid = next_nid;
 			next_nid++;
diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
index 3be485a..8bb460e 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -492,7 +492,7 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	    (pa->apic_id << 8) | (pa->local_sapic_eid);
 	/* nid should be overridden as logical node id later */
 	node_cpuid[srat_num_cpus].nid = pxm;
-	cpu_set(srat_num_cpus, early_cpu_possible_map);
+	cpumask_set_cpu(srat_num_cpus, &early_cpu_possible_map);
 	srat_num_cpus++;
 }

@@ -920,7 +920,7 @@ static int __cpuinit _acpi_map_lsapic(acpi_handle handle, int *pcpu)

 	acpi_map_cpu2node(handle, cpu, physid);

-	cpu_set(cpu, cpu_present_map);
+	set_cpu_present(cpu, true);
 	ia64_cpu_to_sapicid[cpu] = physid;

 	acpi_processor_set_pdc(handle);
@@ -939,7 +939,7 @@ EXPORT_SYMBOL(acpi_map_lsapic);
 int acpi_unmap_lsapic(int cpu)
 {
 	ia64_cpu_to_sapicid[cpu] = -1;
-	cpu_clear(cpu, cpu_present_map);
+	set_cpu_present(cpu, false);

 #ifdef CONFIG_ACPI_NUMA
 	/* NUMA specific cleanup's */
diff --git a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
index f09b174..1711786 100644
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ b/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
@@ -110,7 +110,7 @@ processor_get_freq (

 	pr_debug("processor_get_freq\n");

-	saved_mask = current->cpus_allowed;
+	cpumask_copy(&saved_mask, tsk_cpus_allowed(current));
 	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (smp_processor_id() != cpu)
 		goto migrate_end;
@@ -148,7 +148,7 @@ processor_set_freq (

 	pr_debug("processor_set_freq\n");

-	saved_mask = current->cpus_allowed;
+	cpumask_copy(&saved_mask, tsk_cpus_allowed(current));
 	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (smp_processor_id() != cpu) {
 		retval = -EAGAIN;
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index b0f9afe..cb36cc8 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -691,7 +691,7 @@ skip_numa_setup:
 	do {
 		if (++cpu >= nr_cpu_ids)
 			cpu = 0;
-	} while (!cpu_online(cpu) || !cpu_isset(cpu, domain));
+	} while (!cpu_online(cpu) || !cpumask_test_cpu(cpu, &domain));

 	return cpu_physical_id(cpu);
 #else  /* CONFIG_SMP */
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 782c3a35..4a04304 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -118,14 +118,14 @@ static inline int find_unassigned_vector(cpumask_t domain)
 	cpumask_t mask;
 	int pos, vector;

-	cpus_and(mask, domain, cpu_online_map);
-	if (cpus_empty(mask))
+	cpumask_and(&mask, &domain, cpu_online_mask);
+	if (cpumask_empty(&mask))
 		return -EINVAL;

 	for (pos = 0; pos < IA64_NUM_DEVICE_VECTORS; pos++) {
 		vector = IA64_FIRST_DEVICE_VECTOR + pos;
-		cpus_and(mask, domain, vector_table[vector]);
-		if (!cpus_empty(mask))
+		cpumask_and(&mask, &domain, &vector_table[vector]);
+		if (!cpumask_empty(&mask))
 			continue;
 		return vector;
 	}
@@ -141,19 +141,19 @@ static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 	BUG_ON((unsigned)irq >= NR_IRQS);
 	BUG_ON((unsigned)vector >= IA64_NUM_VECTORS);

-	cpus_and(mask, domain, cpu_online_map);
-	if (cpus_empty(mask))
+	cpumask_and(&mask, &domain, cpu_online_mask);
+	if (cpumask_empty(&mask))
 		return -EINVAL;
-	if ((cfg->vector = vector) && cpus_equal(cfg->domain, domain))
+	if ((cfg->vector = vector) && cpumask_equal(&cfg->domain, &domain))
 		return 0;
 	if (cfg->vector != IRQ_VECTOR_UNASSIGNED)
 		return -EBUSY;
-	for_each_cpu_mask(cpu, mask)
+	for_each_cpu(cpu, &mask)
 		per_cpu(vector_irq, cpu)[vector] = irq;
 	cfg->vector = vector;
 	cfg->domain = domain;
 	irq_status[irq] = IRQ_USED;
-	cpus_or(vector_table[vector], vector_table[vector], domain);
+	cpumask_or(&vector_table[vector], &vector_table[vector], &domain);
 	return 0;
 }

@@ -179,13 +179,13 @@ static void __clear_irq_vector(int irq)
 	BUG_ON(cfg->vector = IRQ_VECTOR_UNASSIGNED);
 	vector = cfg->vector;
 	domain = cfg->domain;
-	cpus_and(mask, cfg->domain, cpu_online_map);
-	for_each_cpu_mask(cpu, mask)
+	cpumask_and(&mask, &cfg->domain, cpu_online_mask);
+	for_each_cpu(cpu, &mask)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 	cfg->vector = IRQ_VECTOR_UNASSIGNED;
 	cfg->domain = CPU_MASK_NONE;
 	irq_status[irq] = IRQ_UNUSED;
-	cpus_andnot(vector_table[vector], vector_table[vector], domain);
+	cpumask_andnot(&vector_table[vector], &vector_table[vector], &domain);
 }

 static void clear_irq_vector(int irq)
@@ -202,8 +202,9 @@ ia64_native_assign_irq_vector (int irq)
 {
 	unsigned long flags;
 	int vector, cpu;
-	cpumask_t domain = CPU_MASK_NONE;
+	cpumask_t domain;

+	cpumask_clear(&domain);
 	vector = -ENOSPC;

 	spin_lock_irqsave(&vector_lock, flags);
@@ -254,7 +255,7 @@ void __setup_vector_irq(int cpu)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
-		if (!cpu_isset(cpu, irq_cfg[irq].domain))
+		if (!cpumask_test_cpu(cpu, &irq_cfg[irq].domain))
 			continue;
 		vector = irq_to_vector(irq);
 		per_cpu(vector_irq, cpu)[vector] = irq;
@@ -271,7 +272,7 @@ static enum vector_domain_type {
 static cpumask_t vector_allocation_domain(int cpu)
 {
 	if (vector_domain_type = VECTOR_DOMAIN_PERCPU)
-		return cpumask_of_cpu(cpu);
+		return *cpumask_of(cpu);
 	return CPU_MASK_ALL;
 }

@@ -285,7 +286,7 @@ static int __irq_prepare_move(int irq, int cpu)
 		return -EBUSY;
 	if (cfg->vector = IRQ_VECTOR_UNASSIGNED || !cpu_online(cpu))
 		return -EINVAL;
-	if (cpu_isset(cpu, cfg->domain))
+	if (cpumask_test_cpu(cpu, &cfg->domain))
 		return 0;
 	domain = vector_allocation_domain(cpu);
 	vector = find_unassigned_vector(domain);
@@ -319,12 +320,12 @@ void irq_complete_move(unsigned irq)
 	if (likely(!cfg->move_in_progress))
 		return;

-	if (unlikely(cpu_isset(smp_processor_id(), cfg->old_domain)))
+	if (unlikely(cpumask_test_cpu(smp_processor_id(), &cfg->old_domain)))
 		return;

-	cpus_and(cleanup_mask, cfg->old_domain, cpu_online_map);
-	cfg->move_cleanup_count = cpus_weight(cleanup_mask);
-	for_each_cpu_mask(i, cleanup_mask)
+	cpumask_and(&cleanup_mask, &cfg->old_domain, cpu_online_mask);
+	cfg->move_cleanup_count = cpumask_weight(&cleanup_mask);
+	for_each_cpu(i, &cleanup_mask)
 		platform_send_ipi(i, IA64_IRQ_MOVE_VECTOR, IA64_IPI_DM_INT, 0);
 	cfg->move_in_progress = 0;
 }
@@ -350,12 +351,12 @@ static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
 		if (!cfg->move_cleanup_count)
 			goto unlock;

-		if (!cpu_isset(me, cfg->old_domain))
+		if (!cpumask_test_cpu(me, &cfg->old_domain))
 			goto unlock;

 		spin_lock_irqsave(&vector_lock, flags);
 		__get_cpu_var(vector_irq)[vector] = -1;
-		cpu_clear(me, vector_table[vector]);
+		cpumask_clear_cpu(me, &vector_table[vector]);
 		spin_unlock_irqrestore(&vector_lock, flags);
 		cfg->move_cleanup_count--;
 	unlock:
@@ -408,8 +409,9 @@ int create_irq(void)
 {
 	unsigned long flags;
 	int irq, vector, cpu;
-	cpumask_t domain = CPU_MASK_NONE;
+	cpumask_t domain;

+	cpumask_clear(&domain);
 	irq = vector = -ENOSPC;
 	spin_lock_irqsave(&vector_lock, flags);
 	for_each_online_cpu(cpu) {
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 84fb405..cf23f43 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1294,7 +1294,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		monarch_cpu = cpu;
 		sos->monarch = 1;
 	} else {
-		cpu_set(cpu, mca_cpu);
+		cpumask_set_cpu(cpu, &mca_cpu);
 		sos->monarch = 0;
 	}
 	mprintk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d "
@@ -1317,7 +1317,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		 */
 		ia64_mca_wakeup_all();
 	} else {
-		while (cpu_isset(cpu, mca_cpu))
+		while (cpumask_test_cpu(cpu, &mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
 	}

@@ -1356,9 +1356,9 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		 * and put this cpu in the rendez loop.
 		 */
 		for_each_online_cpu(i) {
-			if (cpu_isset(i, mca_cpu)) {
+			if (cpumask_test_cpu(i, &mca_cpu)) {
 				monarch_cpu = i;
-				cpu_clear(i, mca_cpu);	/* wake next cpu */
+				cpumask_clear_cpu(i, &mca_cpu);	/* wake next cpu */
 				while (monarch_cpu != -1)
 					cpu_relax();	/* spin until last cpu leaves */
 				set_curr_task(cpu, previous_current);
@@ -1513,7 +1513,7 @@ static void
 ia64_mca_cmc_poll (unsigned long dummy)
 {
 	/* Trigger a CMC interrupt cascade  */
-	platform_send_ipi(first_cpu(cpu_online_map), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CMCP_VECTOR, IA64_IPI_DM_INT, 0);
 }

 /*
@@ -1589,7 +1589,7 @@ static void
 ia64_mca_cpe_poll (unsigned long dummy)
 {
 	/* Trigger a CPE interrupt cascade  */
-	platform_send_ipi(first_cpu(cpu_online_map), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
+	platform_send_ipi(cpumask_first(cpu_online_mask), IA64_CPEP_VECTOR, IA64_IPI_DM_INT, 0);
 }

 #endif /* CONFIG_ACPI */
@@ -1825,7 +1825,7 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 	ti->cpu = cpu;
 	p->stack = ti;
 	p->state = TASK_UNINTERRUPTIBLE;
-	cpu_set(cpu, p->cpus_allowed);
+	cpumask_set_cpu(cpu, &*tsk_cpus_allowed(p));
 	INIT_LIST_HEAD(&p->tasks);
 	p->parent = p->real_parent = p->group_leader = p;
 	INIT_LIST_HEAD(&p->children);
diff --git a/arch/ia64/kernel/msi_ia64.c b/arch/ia64/kernel/msi_ia64.c
index 009df54..8aa458c 100644
--- a/arch/ia64/kernel/msi_ia64.c
+++ b/arch/ia64/kernel/msi_ia64.c
@@ -17,7 +17,7 @@ static int ia64_set_msi_irq_affinity(struct irq_data *idata,
 {
 	struct msi_msg msg;
 	u32 addr, data;
-	int cpu = first_cpu(*cpu_mask);
+	int cpu = cpumask_first(cpu_mask);
 	unsigned int irq = idata->irq;

 	if (!cpu_online(cpu))
@@ -57,8 +57,8 @@ int ia64_setup_msi_irq(struct pci_dev *pdev, struct msi_desc *desc)
 		return irq;

 	irq_set_msi_desc(irq, desc);
-	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
-	dest_phys_id = cpu_physical_id(first_cpu(mask));
+	cpumask_and(&mask, &irq_to_domain(irq), cpu_online_mask);
+	dest_phys_id = cpu_physical_id(cpumask_first(&mask));
 	vector = irq_to_vector(irq);

 	msg.address_hi = 0;
@@ -179,8 +179,8 @@ msi_compose_msg(struct pci_dev *pdev, unsigned int irq, struct msi_msg *msg)
 	unsigned dest;
 	cpumask_t mask;

-	cpus_and(mask, irq_to_domain(irq), cpu_online_map);
-	dest = cpu_physical_id(first_cpu(mask));
+	cpumask_and(&mask, &irq_to_domain(irq), cpu_online_mask);
+	dest = cpu_physical_id(cpumask_first(&mask));

 	msg->address_hi = 0;
 	msg->address_lo diff --git a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
index c93420c..4d5437e 100644
--- a/arch/ia64/kernel/numa.c
+++ b/arch/ia64/kernel/numa.c
@@ -39,7 +39,7 @@ void __cpuinit map_cpu_to_node(int cpu, int nid)
 	}
 	/* sanity check first */
 	oldnid = cpu_to_node_map[cpu];
-	if (cpu_isset(cpu, node_to_cpu_mask[oldnid])) {
+	if (cpumask_test_cpu(cpu, &node_to_cpu_mask[oldnid])) {
 		return; /* nothing to do */
 	}
 	/* we don't have cpu-driven node hot add yet...
@@ -47,16 +47,16 @@ void __cpuinit map_cpu_to_node(int cpu, int nid)
 	if (!node_online(nid))
 		nid = first_online_node;
 	cpu_to_node_map[cpu] = nid;
-	cpu_set(cpu, node_to_cpu_mask[nid]);
+	cpumask_set_cpu(cpu, &node_to_cpu_mask[nid]);
 	return;
 }

 void __cpuinit unmap_cpu_from_node(int cpu, int nid)
 {
-	WARN_ON(!cpu_isset(cpu, node_to_cpu_mask[nid]));
+	WARN_ON(!cpumask_test_cpu(cpu, &node_to_cpu_mask[nid]));
 	WARN_ON(cpu_to_node_map[cpu] != nid);
 	cpu_to_node_map[cpu] = 0;
-	cpu_clear(cpu, node_to_cpu_mask[nid]);
+	cpumask_clear_cpu(cpu, &node_to_cpu_mask[nid]);
 }


@@ -71,7 +71,7 @@ void __init build_cpu_to_node_map(void)
 	int cpu, i, node;

 	for(node=0; node < MAX_NUMNODES; node++)
-		cpus_clear(node_to_cpu_mask[node]);
+		cpumask_clear(&node_to_cpu_mask[node]);

 	for_each_possible_early_cpu(cpu) {
 		node = -1;
diff --git a/arch/ia64/kernel/salinfo.c b/arch/ia64/kernel/salinfo.c
index 79802e5..b47c530 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -255,7 +255,7 @@ salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe)
 			data_saved->buffer = buffer;
 		}
 	}
-	cpu_set(smp_processor_id(), data->cpu_event);
+	cpumask_set_cpu(smp_processor_id(), &data->cpu_event);
 	if (irqsafe) {
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -273,7 +273,7 @@ salinfo_timeout_check(struct salinfo_data *data)
 	unsigned long flags;
 	if (!data->open)
 		return;
-	if (!cpus_empty(data->cpu_event)) {
+	if (!cpumask_empty(&data->cpu_event)) {
 		spin_lock_irqsave(&data_saved_lock, flags);
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -309,7 +309,7 @@ salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t
 	int i, n, cpu = -1;

 retry:
-	if (cpus_empty(data->cpu_event) && down_trylock(&data->mutex)) {
+	if (cpumask_empty(&data->cpu_event) && down_trylock(&data->mutex)) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
 		if (down_interruptible(&data->mutex))
@@ -318,9 +318,9 @@ retry:

 	n = data->cpu_check;
 	for (i = 0; i < nr_cpu_ids; i++) {
-		if (cpu_isset(n, data->cpu_event)) {
+		if (cpumask_test_cpu(n, &data->cpu_event)) {
 			if (!cpu_online(n)) {
-				cpu_clear(n, data->cpu_event);
+				cpumask_clear_cpu(n, &data->cpu_event);
 				continue;
 			}
 			cpu = n;
@@ -404,7 +404,8 @@ salinfo_log_release(struct inode *inode, struct file *file)
 static void
 call_on_cpu(int cpu, void (*fn)(void *), void *arg)
 {
-	cpumask_t save_cpus_allowed = current->cpus_allowed;
+	cpumask_t save_cpus_allowed;
+	cpumask_copy(&save_cpus_allowed, tsk_cpus_allowed(current));
 	set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	(*fn)(arg);
 	set_cpus_allowed_ptr(current, &save_cpus_allowed);
@@ -454,7 +455,7 @@ retry:
 		call_on_cpu(cpu, salinfo_log_read_cpu, data);
 	if (!data->log_size) {
 		data->state = STATE_NO_DATA;
-		cpu_clear(cpu, data->cpu_event);
+		cpumask_clear_cpu(cpu, &data->cpu_event);
 	} else {
 		data->state = STATE_LOG_RECORD;
 	}
@@ -496,11 +497,11 @@ salinfo_log_clear(struct salinfo_data *data, int cpu)
 	unsigned long flags;
 	spin_lock_irqsave(&data_saved_lock, flags);
 	data->state = STATE_NO_DATA;
-	if (!cpu_isset(cpu, data->cpu_event)) {
+	if (!cpumask_test_cpu(cpu, &data->cpu_event)) {
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 		return 0;
 	}
-	cpu_clear(cpu, data->cpu_event);
+	cpumask_clear_cpu(cpu, &data->cpu_event);
 	if (data->saved_num) {
 		shift1_data_saved(data, data->saved_num - 1);
 		data->saved_num = 0;
@@ -514,7 +515,7 @@ salinfo_log_clear(struct salinfo_data *data, int cpu)
 	salinfo_log_new_read(cpu, data);
 	if (data->state = STATE_LOG_RECORD) {
 		spin_lock_irqsave(&data_saved_lock, flags);
-		cpu_set(cpu, data->cpu_event);
+		cpumask_set_cpu(cpu, &data->cpu_event);
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
@@ -588,7 +589,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 		for (i = 0, data = salinfo_data;
 		     i < ARRAY_SIZE(salinfo_data);
 		     ++i, ++data) {
-			cpu_set(cpu, data->cpu_event);
+			cpumask_set_cpu(cpu, &data->cpu_event);
 			salinfo_work_to_do(data);
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -608,7 +609,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 					shift1_data_saved(data, j);
 				}
 			}
-			cpu_clear(cpu, data->cpu_event);
+			cpumask_clear_cpu(cpu, &data->cpu_event);
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 		break;
@@ -663,7 +664,7 @@ salinfo_init(void)

 		/* we missed any events before now */
 		for_each_online_cpu(j)
-			cpu_set(j, data->cpu_event);
+			cpumask_set_cpu(j, &data->cpu_event);

 		*sdir++ = dir;
 	}
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index 5e2c724..2112cb9 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -467,7 +467,7 @@ mark_bsp_online (void)
 {
 #ifdef CONFIG_SMP
 	/* If we register an early console, allow CPU 0 to printk */
-	cpu_set(smp_processor_id(), cpu_online_map);
+	set_cpu_online(smp_processor_id(), true);
 #endif
 }

@@ -544,8 +544,8 @@ setup_arch (char **cmdline_p)
 #  ifdef CONFIG_ACPI_HOTPLUG_CPU
 	prefill_possible_map();
 #  endif
-	per_cpu_scan_finalize((cpus_weight(early_cpu_possible_map) = 0 ?
-		32 : cpus_weight(early_cpu_possible_map)),
+	per_cpu_scan_finalize((cpumask_weight(&early_cpu_possible_map) = 0 ?
+		32 : cpumask_weight(&early_cpu_possible_map)),
 		additional_cpus > 0 ? additional_cpus : 0);
 # endif
 #endif /* CONFIG_APCI_BOOT */
@@ -684,7 +684,7 @@ show_cpuinfo (struct seq_file *m, void *v)
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
 		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
 #ifdef CONFIG_SMP
-	seq_printf(m, "siblings   : %u\n", cpus_weight(cpu_core_map[cpunum]));
+	seq_printf(m, "siblings   : %u\n", cpumask_weight(&cpu_core_map[cpunum]));
 	if (c->socket_id != -1)
 		seq_printf(m, "physical id: %u\n", c->socket_id);
 	if (c->threads_per_core > 1 || c->cores_per_socket > 1)
@@ -915,8 +915,8 @@ cpu_init (void)
 	 * (must be done after per_cpu area is setup)
 	 */
 	if (smp_processor_id() = 0) {
-		cpu_set(0, per_cpu(cpu_sibling_map, 0));
-		cpu_set(0, cpu_core_map[0]);
+		cpumask_set_cpu(0, &per_cpu(cpu_sibling_map, 0));
+		cpumask_set_cpu(0, &cpu_core_map[0]);
 	} else {
 		/*
 		 * Set ar.k3 so that assembly code in MCA handler can compute
diff --git a/arch/ia64/kernel/smp.c b/arch/ia64/kernel/smp.c
index be450a3..9f86422 100644
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
@@ -257,17 +257,18 @@ void
 smp_flush_tlb_cpumask(cpumask_t xcpumask)
 {
 	unsigned short *counts = __ia64_per_cpu_var(shadow_flush_counts);
-	cpumask_t cpumask = xcpumask;
+	cpumask_t cpumask;
 	int mycpu, cpu, flush_mycpu = 0;

+	cpumask_copy(&cpumask, &xcpumask);
 	preempt_disable();
 	mycpu = smp_processor_id();

-	for_each_cpu_mask(cpu, cpumask)
+	for_each_cpu(cpu, &cpumask)
 		counts[cpu] = local_tlb_flush_counts[cpu].count & 0xffff;

 	mb();
-	for_each_cpu_mask(cpu, cpumask) {
+	for_each_cpu(cpu, &cpumask) {
 		if (cpu = mycpu)
 			flush_mycpu = 1;
 		else
@@ -277,7 +278,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 	if (flush_mycpu)
 		smp_local_flush_tlb();

-	for_each_cpu_mask(cpu, cpumask)
+	for_each_cpu(cpu, &cpumask)
 		while(counts[cpu] = (local_tlb_flush_counts[cpu].count & 0xffff))
 			udelay(FLUSH_DELAY);

diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 14ec641..a5b6526 100644
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
@@ -451,7 +451,7 @@ smp_callin (void)
 	/*
 	 * Allow the master to continue.
 	 */
-	cpu_set(cpuid, cpu_callin_map);
+	cpumask_set_cpu(cpuid, &cpu_callin_map);
 	Dprintk("Stack on CPU %d at about %p\n",cpuid, &cpuid);
 }

@@ -539,16 +539,16 @@ do_rest:
 	 */
 	Dprintk("Waiting on callin_map ...");
 	for (timeout = 0; timeout < 100000; timeout++) {
-		if (cpu_isset(cpu, cpu_callin_map))
+		if (cpumask_test_cpu(cpu, &cpu_callin_map))
 			break;  /* It has booted */
 		udelay(100);
 	}
 	Dprintk("\n");

-	if (!cpu_isset(cpu, cpu_callin_map)) {
+	if (!cpumask_test_cpu(cpu, &cpu_callin_map)) {
 		printk(KERN_ERR "Processor 0x%x/0x%x is stuck.\n", cpu, sapicid);
 		ia64_cpu_to_sapicid[cpu] = -1;
-		cpu_clear(cpu, cpu_online_map);  /* was set in smp_callin() */
+		set_cpu_online(cpu, false);  /* was set in smp_callin() */
 		return -EINVAL;
 	}
 	return 0;
@@ -578,7 +578,7 @@ smp_build_cpu_map (void)
 	}

 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
-	cpus_clear(cpu_present_map);
+	cpumask_clear(cpu_present_mask);
 	set_cpu_present(0, true);
 	set_cpu_possible(0, true);
 	for (cpu = 1, i = 0; i < smp_boot_data.cpu_count; i++) {
@@ -609,8 +609,8 @@ smp_prepare_cpus (unsigned int max_cpus)
 	/*
 	 * We have the boot CPU online for sure.
 	 */
-	cpu_set(0, cpu_online_map);
-	cpu_set(0, cpu_callin_map);
+	set_cpu_online(0, true);
+	cpumask_set_cpu(0, &cpu_callin_map);

 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
@@ -633,8 +633,8 @@ smp_prepare_cpus (unsigned int max_cpus)

 void __devinit smp_prepare_boot_cpu(void)
 {
-	cpu_set(smp_processor_id(), cpu_online_map);
-	cpu_set(smp_processor_id(), cpu_callin_map);
+	set_cpu_online(smp_processor_id(), true);
+	cpumask_set_cpu(smp_processor_id(), &cpu_callin_map);
 	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 	paravirt_post_smp_prepare_boot_cpu();
@@ -646,10 +646,10 @@ clear_cpu_sibling_map(int cpu)
 {
 	int i;

-	for_each_cpu_mask(i, per_cpu(cpu_sibling_map, cpu))
-		cpu_clear(cpu, per_cpu(cpu_sibling_map, i));
-	for_each_cpu_mask(i, cpu_core_map[cpu])
-		cpu_clear(cpu, cpu_core_map[i]);
+	for_each_cpu(i, &per_cpu(cpu_sibling_map, cpu))
+		cpumask_clear_cpu(cpu, &per_cpu(cpu_sibling_map, i));
+	for_each_cpu(i, &cpu_core_map[cpu])
+		cpumask_clear_cpu(cpu, &cpu_core_map[i]);

 	per_cpu(cpu_sibling_map, cpu) = cpu_core_map[cpu] = CPU_MASK_NONE;
 }
@@ -661,12 +661,12 @@ remove_siblinginfo(int cpu)

 	if (cpu_data(cpu)->threads_per_core = 1 &&
 	    cpu_data(cpu)->cores_per_socket = 1) {
-		cpu_clear(cpu, cpu_core_map[cpu]);
-		cpu_clear(cpu, per_cpu(cpu_sibling_map, cpu));
+		cpumask_clear_cpu(cpu, &cpu_core_map[cpu]);
+		cpumask_clear_cpu(cpu, &per_cpu(cpu_sibling_map, cpu));
 		return;
 	}

-	last = (cpus_weight(cpu_core_map[cpu]) = 1 ? 1 : 0);
+	last = (cpumask_weight(&cpu_core_map[cpu]) = 1 ? 1 : 0);

 	/* remove it from all sibling map's */
 	clear_cpu_sibling_map(cpu);
@@ -690,7 +690,7 @@ int migrate_platform_irqs(unsigned int cpu)
 			/*
 			 * Now re-target the CPEI to a different processor
 			 */
-			new_cpei_cpu = any_online_cpu(cpu_online_map);
+			new_cpei_cpu = cpumask_any(cpu_online_mask);
 			mask = cpumask_of(new_cpei_cpu);
 			set_cpei_target_cpu(new_cpei_cpu);
 			data = irq_get_irq_data(ia64_cpe_irq);
@@ -732,17 +732,17 @@ int __cpu_disable(void)
 			return -EBUSY;
 	}

-	cpu_clear(cpu, cpu_online_map);
+	set_cpu_online(cpu, false);

 	if (migrate_platform_irqs(cpu)) {
-		cpu_set(cpu, cpu_online_map);
+		set_cpu_online(cpu, true);
 		return -EBUSY;
 	}

 	remove_siblinginfo(cpu);
 	fixup_irqs();
 	local_flush_tlb_all();
-	cpu_clear(cpu, cpu_callin_map);
+	cpumask_clear_cpu(cpu, &cpu_callin_map);
 	return 0;
 }

@@ -788,11 +788,11 @@ set_cpu_sibling_map(int cpu)

 	for_each_online_cpu(i) {
 		if ((cpu_data(cpu)->socket_id = cpu_data(i)->socket_id)) {
-			cpu_set(i, cpu_core_map[cpu]);
-			cpu_set(cpu, cpu_core_map[i]);
+			cpumask_set_cpu(i, &cpu_core_map[cpu]);
+			cpumask_set_cpu(cpu, &cpu_core_map[i]);
 			if (cpu_data(cpu)->core_id = cpu_data(i)->core_id) {
-				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
-				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
+				cpumask_set_cpu(i, &per_cpu(cpu_sibling_map, cpu));
+				cpumask_set_cpu(cpu, &per_cpu(cpu_sibling_map, i));
 			}
 		}
 	}
@@ -812,7 +812,7 @@ __cpu_up (unsigned int cpu)
 	 * Already booted cpu? not valid anymore since we dont
 	 * do idle loop tightspin anymore.
 	 */
-	if (cpu_isset(cpu, cpu_callin_map))
+	if (cpumask_test_cpu(cpu, &cpu_callin_map))
 		return -EINVAL;

 	per_cpu(cpu_state, cpu) = CPU_UP_PREPARE;
@@ -823,8 +823,8 @@ __cpu_up (unsigned int cpu)

 	if (cpu_data(cpu)->threads_per_core = 1 &&
 	    cpu_data(cpu)->cores_per_socket = 1) {
-		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
-		cpu_set(cpu, cpu_core_map[cpu]);
+		cpumask_set_cpu(cpu, &per_cpu(cpu_sibling_map, cpu));
+		cpumask_set_cpu(cpu, &cpu_core_map[cpu]);
 		return 0;
 	}

diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 0e0e0cc..737a5b4 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -147,7 +147,7 @@ static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,

 	if (cpu_data(cpu)->threads_per_core <= 1 &&
 		cpu_data(cpu)->cores_per_socket <= 1) {
-		cpu_set(cpu, this_leaf->shared_cpu_map);
+		cpumask_set_cpu(cpu, &this_leaf->shared_cpu_map);
 		return;
 	}

@@ -163,7 +163,7 @@ static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,
 			if (cpu_data(cpu)->socket_id = cpu_data(j)->socket_id
 				&& cpu_data(j)->core_id = csi.log1_cid
 				&& cpu_data(j)->thread_id = csi.log1_tid)
-				cpu_set(j, this_leaf->shared_cpu_map);
+				cpumask_set_cpu(j, &this_leaf->shared_cpu_map);

 		i++;
 	} while (i < num_shared &&
@@ -176,7 +176,7 @@ static void __cpuinit cache_shared_cpu_map_setup( unsigned int cpu,
 static void __cpuinit cache_shared_cpu_map_setup(unsigned int cpu,
 		struct cache_info * this_leaf)
 {
-	cpu_set(cpu, this_leaf->shared_cpu_map);
+	cpumask_set_cpu(cpu, &this_leaf->shared_cpu_map);
 	return;
 }
 #endif
@@ -219,7 +219,8 @@ static ssize_t show_shared_cpu_map(struct cache_info *this_leaf, char *buf)
 	ssize_t	len;
 	cpumask_t shared_cpu_map;

-	cpus_and(shared_cpu_map, this_leaf->shared_cpu_map, cpu_online_map);
+	cpumask_and(&shared_cpu_map, &this_leaf->shared_cpu_map,
+		    cpu_online_mask);
 	len = cpumask_scnprintf(buf, NR_CPUS+1, &shared_cpu_map);
 	len += sprintf(buf+len, "\n");
 	return len;
@@ -360,7 +361,7 @@ static int __cpuinit cache_add_dev(struct sys_device * sys_dev)
 	if (all_cpu_cache_info[cpu].kobj.parent)
 		return 0;

-	oldmask = current->cpus_allowed;
+	cpumask_copy(&oldmask, tsk_cpus_allowed(current));
 	retval = set_cpus_allowed_ptr(current, cpumask_of(cpu));
 	if (unlikely(retval))
 		return retval;
diff --git a/arch/ia64/sn/kernel/sn2/sn_hwperf.c b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
index 30862c0..b1f53e4 100644
--- a/arch/ia64/sn/kernel/sn2/sn_hwperf.c
+++ b/arch/ia64/sn/kernel/sn2/sn_hwperf.c
@@ -627,7 +627,7 @@ static int sn_hwperf_op_cpu(struct sn_hwperf_op_info *op_info)
 		}
 		else {
 			/* migrate the task before calling SAL */
-			save_allowed = current->cpus_allowed;
+			cpumask_copy(&save_allowed, tsk_cpus_allowed(current));
 			set_cpus_allowed_ptr(current, cpumask_of(cpu));
 			sn_hwperf_call_sal(op_info);
 			set_cpus_allowed_ptr(current, &save_allowed);
-- 
1.7.3.1



