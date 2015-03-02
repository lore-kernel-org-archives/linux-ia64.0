From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 02 Mar 2015 11:47:47 +0000
Subject: [PATCH 06/16] ia64: fix up obsolete cpu function usage.
Message-Id: <1425296150-4722-6-git-send-email-rusty@rustcorp.com.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1425296150-4722-1-git-send-email-rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Rusty Russell <rusty@rustcorp.com.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Thanks to spatch, then a sweep for for_each_cpu_mask => for_each_cpu.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/acpi.h |  6 +++---
 arch/ia64/kernel/acpi.c      |  2 +-
 arch/ia64/kernel/iosapic.c   |  2 +-
 arch/ia64/kernel/irq_ia64.c  | 28 ++++++++++++++--------------
 arch/ia64/kernel/mca.c       | 10 +++++-----
 arch/ia64/kernel/numa.c      | 10 +++++-----
 arch/ia64/kernel/salinfo.c   | 24 ++++++++++++------------
 arch/ia64/kernel/setup.c     | 11 ++++++-----
 arch/ia64/kernel/smp.c       |  6 +++---
 arch/ia64/kernel/smpboot.c   | 42 ++++++++++++++++++++++--------------------
 arch/ia64/kernel/topology.c  |  6 +++---
 11 files changed, 75 insertions(+), 72 deletions(-)

diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
index a1d91ab4c5ef..aa0fdf125aba 100644
--- a/arch/ia64/include/asm/acpi.h
+++ b/arch/ia64/include/asm/acpi.h
@@ -117,7 +117,7 @@ static inline void arch_acpi_set_pdc_bits(u32 *buf)
 #ifdef CONFIG_ACPI_NUMA
 extern cpumask_t early_cpu_possible_map;
 #define for_each_possible_early_cpu(cpu)  \
-	for_each_cpu_mask((cpu), early_cpu_possible_map)
+	for_each_cpu((cpu), &early_cpu_possible_map)
 
 static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
 {
@@ -125,13 +125,13 @@ static inline void per_cpu_scan_finalize(int min_cpus, int reserve_cpus)
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
index 2c4498919d3c..35bf22cc71b7 100644
--- a/arch/ia64/kernel/acpi.c
+++ b/arch/ia64/kernel/acpi.c
@@ -483,7 +483,7 @@ acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa)
 	    (pa->apic_id << 8) | (pa->local_sapic_eid);
 	/* nid should be overridden as logical node id later */
 	node_cpuid[srat_num_cpus].nid = pxm;
-	cpu_set(srat_num_cpus, early_cpu_possible_map);
+	cpumask_set_cpu(srat_num_cpus, &early_cpu_possible_map);
 	srat_num_cpus++;
 }
 
diff --git a/arch/ia64/kernel/iosapic.c b/arch/ia64/kernel/iosapic.c
index cd44a57c73be..bc9501e36e77 100644
--- a/arch/ia64/kernel/iosapic.c
+++ b/arch/ia64/kernel/iosapic.c
@@ -690,7 +690,7 @@ skip_numa_setup:
 	do {
 		if (++cpu >= nr_cpu_ids)
 			cpu = 0;
-	} while (!cpu_online(cpu) || !cpu_isset(cpu, domain));
+	} while (!cpu_online(cpu) || !cpumask_test_cpu(cpu, &domain));
 
 	return cpu_physical_id(cpu);
 #else  /* CONFIG_SMP */
diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
index 3329177c262e..9f40d972969c 100644
--- a/arch/ia64/kernel/irq_ia64.c
+++ b/arch/ia64/kernel/irq_ia64.c
@@ -109,13 +109,13 @@ static inline int find_unassigned_vector(cpumask_t domain)
 	int pos, vector;
 
 	cpumask_and(&mask, &domain, cpu_online_mask);
-	if (cpus_empty(mask))
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
@@ -132,18 +132,18 @@ static int __bind_irq_vector(int irq, int vector, cpumask_t domain)
 	BUG_ON((unsigned)vector >= IA64_NUM_VECTORS);
 
 	cpumask_and(&mask, &domain, cpu_online_mask);
-	if (cpus_empty(mask))
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
 
@@ -242,7 +242,7 @@ void __setup_vector_irq(int cpu)
 		per_cpu(vector_irq, cpu)[vector] = -1;
 	/* Mark the inuse vectors */
 	for (irq = 0; irq < NR_IRQS; ++irq) {
-		if (!cpu_isset(cpu, irq_cfg[irq].domain))
+		if (!cpumask_test_cpu(cpu, &irq_cfg[irq].domain))
 			continue;
 		vector = irq_to_vector(irq);
 		per_cpu(vector_irq, cpu)[vector] = irq;
@@ -273,7 +273,7 @@ static int __irq_prepare_move(int irq, int cpu)
 		return -EBUSY;
 	if (cfg->vector = IRQ_VECTOR_UNASSIGNED || !cpu_online(cpu))
 		return -EINVAL;
-	if (cpu_isset(cpu, cfg->domain))
+	if (cpumask_test_cpu(cpu, &cfg->domain))
 		return 0;
 	domain = vector_allocation_domain(cpu);
 	vector = find_unassigned_vector(domain);
@@ -307,12 +307,12 @@ void irq_complete_move(unsigned irq)
 	if (likely(!cfg->move_in_progress))
 		return;
 
-	if (unlikely(cpu_isset(smp_processor_id(), cfg->old_domain)))
+	if (unlikely(cpumask_test_cpu(smp_processor_id(), &cfg->old_domain)))
 		return;
 
 	cpumask_and(&cleanup_mask, &cfg->old_domain, cpu_online_mask);
-	cfg->move_cleanup_count = cpus_weight(cleanup_mask);
-	for_each_cpu_mask(i, cleanup_mask)
+	cfg->move_cleanup_count = cpumask_weight(&cleanup_mask);
+	for_each_cpu(i, &cleanup_mask)
 		platform_send_ipi(i, IA64_IRQ_MOVE_VECTOR, IA64_IPI_DM_INT, 0);
 	cfg->move_in_progress = 0;
 }
@@ -338,12 +338,12 @@ static irqreturn_t smp_irq_move_cleanup_interrupt(int irq, void *dev_id)
 		if (!cfg->move_cleanup_count)
 			goto unlock;
 
-		if (!cpu_isset(me, cfg->old_domain))
+		if (!cpumask_test_cpu(me, &cfg->old_domain))
 			goto unlock;
 
 		spin_lock_irqsave(&vector_lock, flags);
 		__this_cpu_write(vector_irq[vector], -1);
-		cpu_clear(me, vector_table[vector]);
+		cpumask_clear_cpu(me, &vector_table[vector]);
 		spin_unlock_irqrestore(&vector_lock, flags);
 		cfg->move_cleanup_count--;
 	unlock:
diff --git a/arch/ia64/kernel/mca.c b/arch/ia64/kernel/mca.c
index 8bfd36af46f8..dd5801eb4c69 100644
--- a/arch/ia64/kernel/mca.c
+++ b/arch/ia64/kernel/mca.c
@@ -1293,7 +1293,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		monarch_cpu = cpu;
 		sos->monarch = 1;
 	} else {
-		cpu_set(cpu, mca_cpu);
+		cpumask_set_cpu(cpu, &mca_cpu);
 		sos->monarch = 0;
 	}
 	mprintk(KERN_INFO "Entered OS MCA handler. PSP=%lx cpu=%d "
@@ -1316,7 +1316,7 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
 		 */
 		ia64_mca_wakeup_all();
 	} else {
-		while (cpu_isset(cpu, mca_cpu))
+		while (cpumask_test_cpu(cpu, &mca_cpu))
 			cpu_relax();	/* spin until monarch wakes us */
 	}
 
@@ -1355,9 +1355,9 @@ ia64_mca_handler(struct pt_regs *regs, struct switch_stack *sw,
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
@@ -1822,7 +1822,7 @@ format_mca_init_stack(void *mca_data, unsigned long offset,
 	ti->cpu = cpu;
 	p->stack = ti;
 	p->state = TASK_UNINTERRUPTIBLE;
-	cpu_set(cpu, p->cpus_allowed);
+	cpumask_set_cpu(cpu, &p->cpus_allowed);
 	INIT_LIST_HEAD(&p->tasks);
 	p->parent = p->real_parent = p->group_leader = p;
 	INIT_LIST_HEAD(&p->children);
diff --git a/arch/ia64/kernel/numa.c b/arch/ia64/kernel/numa.c
index d288cde93606..92c376279c6d 100644
--- a/arch/ia64/kernel/numa.c
+++ b/arch/ia64/kernel/numa.c
@@ -39,7 +39,7 @@ void map_cpu_to_node(int cpu, int nid)
 	}
 	/* sanity check first */
 	oldnid = cpu_to_node_map[cpu];
-	if (cpu_isset(cpu, node_to_cpu_mask[oldnid])) {
+	if (cpumask_test_cpu(cpu, &node_to_cpu_mask[oldnid])) {
 		return; /* nothing to do */
 	}
 	/* we don't have cpu-driven node hot add yet...
@@ -47,16 +47,16 @@ void map_cpu_to_node(int cpu, int nid)
 	if (!node_online(nid))
 		nid = first_online_node;
 	cpu_to_node_map[cpu] = nid;
-	cpu_set(cpu, node_to_cpu_mask[nid]);
+	cpumask_set_cpu(cpu, &node_to_cpu_mask[nid]);
 	return;
 }
 
 void unmap_cpu_from_node(int cpu, int nid)
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
index ee9719eebb1e..1eeffb7fbb16 100644
--- a/arch/ia64/kernel/salinfo.c
+++ b/arch/ia64/kernel/salinfo.c
@@ -256,7 +256,7 @@ salinfo_log_wakeup(int type, u8 *buffer, u64 size, int irqsafe)
 			data_saved->buffer = buffer;
 		}
 	}
-	cpu_set(smp_processor_id(), data->cpu_event);
+	cpumask_set_cpu(smp_processor_id(), &data->cpu_event);
 	if (irqsafe) {
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -274,7 +274,7 @@ salinfo_timeout_check(struct salinfo_data *data)
 	unsigned long flags;
 	if (!data->open)
 		return;
-	if (!cpus_empty(data->cpu_event)) {
+	if (!cpumask_empty(&data->cpu_event)) {
 		spin_lock_irqsave(&data_saved_lock, flags);
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -308,7 +308,7 @@ salinfo_event_read(struct file *file, char __user *buffer, size_t count, loff_t
 	int i, n, cpu = -1;
 
 retry:
-	if (cpus_empty(data->cpu_event) && down_trylock(&data->mutex)) {
+	if (cpumask_empty(&data->cpu_event) && down_trylock(&data->mutex)) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
 		if (down_interruptible(&data->mutex))
@@ -317,9 +317,9 @@ retry:
 
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
@@ -451,7 +451,7 @@ retry:
 		call_on_cpu(cpu, salinfo_log_read_cpu, data);
 	if (!data->log_size) {
 		data->state = STATE_NO_DATA;
-		cpu_clear(cpu, data->cpu_event);
+		cpumask_clear_cpu(cpu, &data->cpu_event);
 	} else {
 		data->state = STATE_LOG_RECORD;
 	}
@@ -491,11 +491,11 @@ salinfo_log_clear(struct salinfo_data *data, int cpu)
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
@@ -509,7 +509,7 @@ salinfo_log_clear(struct salinfo_data *data, int cpu)
 	salinfo_log_new_read(cpu, data);
 	if (data->state = STATE_LOG_RECORD) {
 		spin_lock_irqsave(&data_saved_lock, flags);
-		cpu_set(cpu, data->cpu_event);
+		cpumask_set_cpu(cpu, &data->cpu_event);
 		salinfo_work_to_do(data);
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 	}
@@ -581,7 +581,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 		for (i = 0, data = salinfo_data;
 		     i < ARRAY_SIZE(salinfo_data);
 		     ++i, ++data) {
-			cpu_set(cpu, data->cpu_event);
+			cpumask_set_cpu(cpu, &data->cpu_event);
 			salinfo_work_to_do(data);
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
@@ -601,7 +601,7 @@ salinfo_cpu_callback(struct notifier_block *nb, unsigned long action, void *hcpu
 					shift1_data_saved(data, j);
 				}
 			}
-			cpu_clear(cpu, data->cpu_event);
+			cpumask_clear_cpu(cpu, &data->cpu_event);
 		}
 		spin_unlock_irqrestore(&data_saved_lock, flags);
 		break;
@@ -659,7 +659,7 @@ salinfo_init(void)
 
 		/* we missed any events before now */
 		for_each_online_cpu(j)
-			cpu_set(j, data->cpu_event);
+			cpumask_set_cpu(j, &data->cpu_event);
 
 		*sdir++ = dir;
 	}
diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
index d86669bcdfb2..b9761389cb8d 100644
--- a/arch/ia64/kernel/setup.c
+++ b/arch/ia64/kernel/setup.c
@@ -562,8 +562,8 @@ setup_arch (char **cmdline_p)
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
@@ -702,7 +702,8 @@ show_cpuinfo (struct seq_file *m, void *v)
 		   c->itc_freq / 1000000, c->itc_freq % 1000000,
 		   lpj*HZ/500000, (lpj*HZ/5000) % 100);
 #ifdef CONFIG_SMP
-	seq_printf(m, "siblings   : %u\n", cpus_weight(cpu_core_map[cpunum]));
+	seq_printf(m, "siblings   : %u\n",
+		   cpumask_weight(&cpu_core_map[cpunum]));
 	if (c->socket_id != -1)
 		seq_printf(m, "physical id: %u\n", c->socket_id);
 	if (c->threads_per_core > 1 || c->cores_per_socket > 1)
@@ -933,8 +934,8 @@ cpu_init (void)
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
index 9fcd4e63048f..7f706d4f84f7 100644
--- a/arch/ia64/kernel/smp.c
+++ b/arch/ia64/kernel/smp.c
@@ -262,11 +262,11 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
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
@@ -276,7 +276,7 @@ smp_flush_tlb_cpumask(cpumask_t xcpumask)
 	if (flush_mycpu)
 		smp_local_flush_tlb();
 
-	for_each_cpu_mask(cpu, cpumask)
+	for_each_cpu(cpu, &cpumask)
 		while(counts[cpu] = (local_tlb_flush_counts[cpu].count & 0xffff))
 			udelay(FLUSH_DELAY);
 
diff --git a/arch/ia64/kernel/smpboot.c b/arch/ia64/kernel/smpboot.c
index 547a48d78bd7..15051e9c2c6f 100644
--- a/arch/ia64/kernel/smpboot.c
+++ b/arch/ia64/kernel/smpboot.c
@@ -434,7 +434,7 @@ smp_callin (void)
 	/*
 	 * Allow the master to continue.
 	 */
-	cpu_set(cpuid, cpu_callin_map);
+	cpumask_set_cpu(cpuid, &cpu_callin_map);
 	Dprintk("Stack on CPU %d at about %p\n",cpuid, &cpuid);
 }
 
@@ -475,13 +475,13 @@ do_boot_cpu (int sapicid, int cpu, struct task_struct *idle)
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
 		set_cpu_online(cpu, false);  /* was set in smp_callin() */
@@ -541,7 +541,7 @@ smp_prepare_cpus (unsigned int max_cpus)
 
 	smp_setup_percpu_timer();
 
-	cpu_set(0, cpu_callin_map);
+	cpumask_set_cpu(0, &cpu_callin_map);
 
 	local_cpu_data->loops_per_jiffy = loops_per_jiffy;
 	ia64_cpu_to_sapicid[0] = boot_cpu_id;
@@ -565,7 +565,7 @@ smp_prepare_cpus (unsigned int max_cpus)
 void smp_prepare_boot_cpu(void)
 {
 	set_cpu_online(smp_processor_id(), true);
-	cpu_set(smp_processor_id(), cpu_callin_map);
+	cpumask_set_cpu(smp_processor_id(), &cpu_callin_map);
 	set_numa_node(cpu_to_node_map[smp_processor_id()]);
 	per_cpu(cpu_state, smp_processor_id()) = CPU_ONLINE;
 	paravirt_post_smp_prepare_boot_cpu();
@@ -577,10 +577,10 @@ clear_cpu_sibling_map(int cpu)
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
@@ -592,12 +592,12 @@ remove_siblinginfo(int cpu)
 
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
@@ -673,7 +673,7 @@ int __cpu_disable(void)
 	remove_siblinginfo(cpu);
 	fixup_irqs();
 	local_flush_tlb_all();
-	cpu_clear(cpu, cpu_callin_map);
+	cpumask_clear_cpu(cpu, &cpu_callin_map);
 	return 0;
 }
 
@@ -718,11 +718,13 @@ static inline void set_cpu_sibling_map(int cpu)
 
 	for_each_online_cpu(i) {
 		if ((cpu_data(cpu)->socket_id = cpu_data(i)->socket_id)) {
-			cpu_set(i, cpu_core_map[cpu]);
-			cpu_set(cpu, cpu_core_map[i]);
+			cpumask_set_cpu(i, &cpu_core_map[cpu]);
+			cpumask_set_cpu(cpu, &cpu_core_map[i]);
 			if (cpu_data(cpu)->core_id = cpu_data(i)->core_id) {
-				cpu_set(i, per_cpu(cpu_sibling_map, cpu));
-				cpu_set(cpu, per_cpu(cpu_sibling_map, i));
+				cpumask_set_cpu(i,
+						&per_cpu(cpu_sibling_map, cpu));
+				cpumask_set_cpu(cpu,
+						&per_cpu(cpu_sibling_map, i));
 			}
 		}
 	}
@@ -742,7 +744,7 @@ __cpu_up(unsigned int cpu, struct task_struct *tidle)
 	 * Already booted cpu? not valid anymore since we dont
 	 * do idle loop tightspin anymore.
 	 */
-	if (cpu_isset(cpu, cpu_callin_map))
+	if (cpumask_test_cpu(cpu, &cpu_callin_map))
 		return -EINVAL;
 
 	per_cpu(cpu_state, cpu) = CPU_UP_PREPARE;
@@ -753,8 +755,8 @@ __cpu_up(unsigned int cpu, struct task_struct *tidle)
 
 	if (cpu_data(cpu)->threads_per_core = 1 &&
 	    cpu_data(cpu)->cores_per_socket = 1) {
-		cpu_set(cpu, per_cpu(cpu_sibling_map, cpu));
-		cpu_set(cpu, cpu_core_map[cpu]);
+		cpumask_set_cpu(cpu, &per_cpu(cpu_sibling_map, cpu));
+		cpumask_set_cpu(cpu, &cpu_core_map[cpu]);
 		return 0;
 	}
 
diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
index 965ab42fabb0..c01fe8991244 100644
--- a/arch/ia64/kernel/topology.c
+++ b/arch/ia64/kernel/topology.c
@@ -148,7 +148,7 @@ static void cache_shared_cpu_map_setup(unsigned int cpu,
 
 	if (cpu_data(cpu)->threads_per_core <= 1 &&
 		cpu_data(cpu)->cores_per_socket <= 1) {
-		cpu_set(cpu, this_leaf->shared_cpu_map);
+		cpumask_set_cpu(cpu, &this_leaf->shared_cpu_map);
 		return;
 	}
 
@@ -164,7 +164,7 @@ static void cache_shared_cpu_map_setup(unsigned int cpu,
 			if (cpu_data(cpu)->socket_id = cpu_data(j)->socket_id
 				&& cpu_data(j)->core_id = csi.log1_cid
 				&& cpu_data(j)->thread_id = csi.log1_tid)
-				cpu_set(j, this_leaf->shared_cpu_map);
+				cpumask_set_cpu(j, &this_leaf->shared_cpu_map);
 
 		i++;
 	} while (i < num_shared &&
@@ -177,7 +177,7 @@ static void cache_shared_cpu_map_setup(unsigned int cpu,
 static void cache_shared_cpu_map_setup(unsigned int cpu,
 		struct cache_info * this_leaf)
 {
-	cpu_set(cpu, this_leaf->shared_cpu_map);
+	cpumask_set_cpu(cpu, &this_leaf->shared_cpu_map);
 	return;
 }
 #endif
-- 
2.1.0

