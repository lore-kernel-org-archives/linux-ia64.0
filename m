From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:40 +0000
Subject: [PATCH 21/35] cpumask: for_each_cpu(): for_each_cpu_mask which takes a pointer
Message-Id: <20081020170322.500086000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

We want to wean people off handing around cpumask_t's, and have them
pass by pointer instead.  This does for_each_cpu_mask().

We immediately convert core files who were doing
"for_each_cpu_mask(... *mask)" since this is clearer.

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 include/linux/cpumask.h |   27 +++++++++++++++------------
 kernel/sched.c          |   40 ++++++++++++++++++++--------------------
 kernel/workqueue.c      |    6 +++---
 lib/cpumask.c           |    2 +-
 mm/allocpercpu.c        |    4 ++--
 mm/vmstat.c             |    2 +-
 6 files changed, 42 insertions(+), 39 deletions(-)

--- linux-2.6.28.orig/include/linux/cpumask.h
+++ linux-2.6.28/include/linux/cpumask.h
@@ -97,9 +97,9 @@
  * void cpumask_onto(dst, orig, relmap)	*dst = orig relative to relmap
  * void cpumask_fold(dst, orig, sz)	dst bits = orig bits mod sz
  *
- * for_each_cpu_mask(cpu, mask)		for-loop cpu over mask
+ * for_each_cpu(cpu, mask)		for-loop cpu over mask
  *						using nr_cpumask_bits
- * for_each_cpu_mask_and(cpu, mask, and) for-loop cpu over (mask & and).
+ * for_each_cpu_and(cpu, mask, and)	for-loop cpu over (mask & and).
  *
  * int num_online_cpus()		Number of online CPUs
  * int num_possible_cpus()		Number of all possible CPUs
@@ -176,6 +176,9 @@ extern cpumask_t _unused_cpumask_arg_;
 #define cpus_weight_nr(cpumask)		cpus_weight(cpumask)
 #define for_each_cpu_mask_nr(cpu, mask)	for_each_cpu_mask(cpu, mask)
 #define cpumask_of_cpu(cpu) (*cpumask_of(cpu))
+#define for_each_cpu_mask(cpu, mask)	for_each_cpu(cpu, &(mask))
+#define for_each_cpu_mask_and(cpu, mask, and)	\
+		for_each_cpu_and(cpu, &(mask), &(and))
 /* End deprecated region. */
 
 #if NR_CPUS <= BITS_PER_LONG
@@ -439,9 +442,9 @@ extern cpumask_t cpu_mask_all;
 #define next_cpu(n, src)	({ (void)(src); 1; })
 #define any_online_cpu(mask)	0
 
-#define for_each_cpu_mask(cpu, mask)		\
+#define for_each_cpu(cpu, mask)			\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask)
-#define for_each_cpu_mask_and(cpu, mask, and)	\
+#define for_each_cpu_and(cpu, mask, and)	\
 	for ((cpu) = 0; (cpu) < 1; (cpu)++, (void)mask, (void)and)
 
 #else /* NR_CPUS > 1 */
@@ -455,13 +458,13 @@ int __any_online_cpu(const cpumask_t *ma
 #define next_cpu(n, src)	__next_cpu((n), &(src))
 #define any_online_cpu(mask) __any_online_cpu(&(mask))
 
-#define for_each_cpu_mask(cpu, mask)			\
+#define for_each_cpu(cpu, mask)				\
 	for ((cpu) = -1;				\
-		(cpu) = next_cpu((cpu), (mask)),	\
+		(cpu) = __next_cpu((cpu), (mask)),	\
 		(cpu) < nr_cpumask_bits;)
-#define for_each_cpu_mask_and(cpu, mask, and)				\
-	for ((cpu) = -1;						\
-		(cpu) = cpumask_next_and((cpu), &(mask), &(and)),	\
+#define for_each_cpu_and(cpu, mask, and)			\
+	for ((cpu) = -1;					\
+		(cpu) = cpumask_next_and((cpu), (mask), (and)),	\
 		(cpu) < nr_cpumask_bits;)
 #endif
 
@@ -615,9 +618,9 @@ extern cpumask_t cpu_active_map;
 
 #define cpu_is_offline(cpu)	unlikely(!cpu_online(cpu))
 
-#define for_each_possible_cpu(cpu) for_each_cpu_mask((cpu), cpu_possible_map)
-#define for_each_online_cpu(cpu)   for_each_cpu_mask((cpu), cpu_online_map)
-#define for_each_present_cpu(cpu)  for_each_cpu_mask((cpu), cpu_present_map)
+#define for_each_possible_cpu(cpu) for_each_cpu((cpu), &cpu_possible_map)
+#define for_each_online_cpu(cpu)   for_each_cpu((cpu), &cpu_online_map)
+#define for_each_present_cpu(cpu)  for_each_cpu((cpu), &cpu_present_map)
 
 /* Arch-specific code may call this to initialize nr_cpu_ids based on
  * the cpu_possible_map. */
--- linux-2.6.28.orig/kernel/sched.c
+++ linux-2.6.28/kernel/sched.c
@@ -1512,7 +1512,7 @@ static int tg_shares_up(struct task_grou
 	struct sched_domain *sd = data;
 	int i;
 
-	for_each_cpu_mask(i, sd->span) {
+	for_each_cpu(i, &sd->span) {
 		rq_weight += tg->cfs_rq[i]->load.weight;
 		shares += tg->cfs_rq[i]->shares;
 	}
@@ -1526,7 +1526,7 @@ static int tg_shares_up(struct task_grou
 	if (!rq_weight)
 		rq_weight = cpus_weight(sd->span) * NICE_0_LOAD;
 
-	for_each_cpu_mask(i, sd->span) {
+	for_each_cpu(i, &sd->span) {
 		struct rq *rq = cpu_rq(i);
 		unsigned long flags;
 
@@ -2069,7 +2069,7 @@ find_idlest_group(struct sched_domain *s
 		/* Tally up the load of all CPUs in the group */
 		avg_load = 0;
 
-		for_each_cpu_mask_nr(i, group->cpumask) {
+		for_each_cpu(i, &group->cpumask) {
 			/* Bias balancing toward cpus of our domain */
 			if (local_group)
 				load = source_load(i, load_idx);
@@ -2111,7 +2111,7 @@ find_idlest_cpu(struct sched_group *grou
 	/* Traverse only the allowed CPUs */
 	cpus_and(*tmp, group->cpumask, p->cpus_allowed);
 
-	for_each_cpu_mask_nr(i, *tmp) {
+	for_each_cpu(i, tmp) {
 		load = weighted_cpuload(i);
 
 		if (load < min_load || (load = min_load && i = this_cpu)) {
@@ -3129,7 +3129,7 @@ find_busiest_group(struct sched_domain *
 		max_cpu_load = 0;
 		min_cpu_load = ~0UL;
 
-		for_each_cpu_mask_nr(i, group->cpumask) {
+		for_each_cpu(i, &group->cpumask) {
 			struct rq *rq;
 
 			if (!cpu_isset(i, *cpus))
@@ -3408,7 +3408,7 @@ find_busiest_queue(struct sched_group *g
 	unsigned long max_load = 0;
 	int i;
 
-	for_each_cpu_mask_nr(i, group->cpumask) {
+	for_each_cpu(i, &group->cpumask) {
 		unsigned long wl;
 
 		if (!cpu_isset(i, *cpus))
@@ -3950,7 +3950,7 @@ static void run_rebalance_domains(struct
 		int balance_cpu;
 
 		cpu_clear(this_cpu, cpus);
-		for_each_cpu_mask_nr(balance_cpu, cpus) {
+		for_each_cpu(balance_cpu, &cpus) {
 			/*
 			 * If this cpu gets work to do, stop the load balancing
 			 * work being done for other cpus. Next load
@@ -6934,7 +6934,7 @@ init_sched_build_groups(const cpumask_t 
 
 	cpus_clear(*covered);
 
-	for_each_cpu_mask_nr(i, *span) {
+	for_each_cpu(i, span) {
 		struct sched_group *sg;
 		int group = group_fn(i, cpu_map, &sg, tmpmask);
 		int j;
@@ -6945,7 +6945,7 @@ init_sched_build_groups(const cpumask_t 
 		cpus_clear(sg->cpumask);
 		sg->__cpu_power = 0;
 
-		for_each_cpu_mask_nr(j, *span) {
+		for_each_cpu(j, span) {
 			if (group_fn(j, cpu_map, NULL, tmpmask) != group)
 				continue;
 
@@ -7145,7 +7145,7 @@ static void init_numa_sched_groups_power
 	if (!sg)
 		return;
 	do {
-		for_each_cpu_mask_nr(j, sg->cpumask) {
+		for_each_cpu(j, &sg->cpumask) {
 			struct sched_domain *sd;
 
 			sd = &per_cpu(phys_domains, j);
@@ -7170,7 +7170,7 @@ static void free_sched_groups(const cpum
 {
 	int cpu, i;
 
-	for_each_cpu_mask_nr(cpu, *cpu_map) {
+	for_each_cpu(cpu, cpu_map) {
 		struct sched_group **sched_group_nodes
 			= sched_group_nodes_bycpu[cpu];
 
@@ -7417,7 +7417,7 @@ static int __build_sched_domains(const c
 	/*
 	 * Set up domains for cpus specified by the cpu_map.
 	 */
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd = NULL, *p;
 		SCHED_CPUMASK_VAR(nodemask, allmasks);
 
@@ -7484,7 +7484,7 @@ static int __build_sched_domains(const c
 
 #ifdef CONFIG_SCHED_SMT
 	/* Set up CPU (sibling) groups */
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		SCHED_CPUMASK_VAR(this_sibling_map, allmasks);
 		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
@@ -7501,7 +7501,7 @@ static int __build_sched_domains(const c
 
 #ifdef CONFIG_SCHED_MC
 	/* Set up multi-core groups */
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		SCHED_CPUMASK_VAR(this_core_map, allmasks);
 		SCHED_CPUMASK_VAR(send_covered, allmasks);
 
@@ -7568,7 +7568,7 @@ static int __build_sched_domains(const c
 			goto error;
 		}
 		sched_group_nodes[i] = sg;
-		for_each_cpu_mask_nr(j, *nodemask) {
+		for_each_cpu(j, nodemask) {
 			struct sched_domain *sd;
 
 			sd = &per_cpu(node_domains, j);
@@ -7614,21 +7614,21 @@ static int __build_sched_domains(const c
 
 	/* Calculate CPU power for physical packages and nodes */
 #ifdef CONFIG_SCHED_SMT
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd = &per_cpu(cpu_domains, i);
 
 		init_sched_groups_power(i, sd);
 	}
 #endif
 #ifdef CONFIG_SCHED_MC
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd = &per_cpu(core_domains, i);
 
 		init_sched_groups_power(i, sd);
 	}
 #endif
 
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd = &per_cpu(phys_domains, i);
 
 		init_sched_groups_power(i, sd);
@@ -7648,7 +7648,7 @@ static int __build_sched_domains(const c
 #endif
 
 	/* Attach the domains */
-	for_each_cpu_mask_nr(i, *cpu_map) {
+	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd;
 #ifdef CONFIG_SCHED_SMT
 		sd = &per_cpu(cpu_domains, i);
@@ -7731,7 +7731,7 @@ static void detach_destroy_domains(const
 
 	unregister_sched_domain_sysctl();
 
-	for_each_cpu_mask_nr(i, *cpu_map)
+	for_each_cpu(i, cpu_map)
 		cpu_attach_domain(NULL, &def_root_domain, i);
 	synchronize_sched();
 	arch_destroy_sched_domains(cpu_map, &tmpmask);
--- linux-2.6.28.orig/kernel/workqueue.c
+++ linux-2.6.28/kernel/workqueue.c
@@ -415,7 +415,7 @@ void flush_workqueue(struct workqueue_st
 	might_sleep();
 	lock_map_acquire(&wq->lockdep_map);
 	lock_map_release(&wq->lockdep_map);
-	for_each_cpu_mask_nr(cpu, *cpu_map)
+	for_each_cpu(cpu, cpu_map)
 		flush_cpu_workqueue(per_cpu_ptr(wq->cpu_wq, cpu));
 }
 EXPORT_SYMBOL_GPL(flush_workqueue);
@@ -546,7 +546,7 @@ static void wait_on_work(struct work_str
 	wq = cwq->wq;
 	cpu_map = wq_cpu_map(wq);
 
-	for_each_cpu_mask_nr(cpu, *cpu_map)
+	for_each_cpu(cpu, cpu_map)
 		wait_on_cpu_work(per_cpu_ptr(wq->cpu_wq, cpu), work);
 }
 
@@ -906,7 +906,7 @@ void destroy_workqueue(struct workqueue_
 	list_del(&wq->list);
 	spin_unlock(&workqueue_lock);
 
-	for_each_cpu_mask_nr(cpu, *cpu_map)
+	for_each_cpu(cpu, cpu_map)
 		cleanup_workqueue_thread(per_cpu_ptr(wq->cpu_wq, cpu));
  	cpu_maps_update_done();
 
--- linux-2.6.28.orig/lib/cpumask.c
+++ linux-2.6.28/lib/cpumask.c
@@ -28,7 +28,7 @@ int __any_online_cpu(const cpumask_t *ma
 {
 	int cpu;
 
-	for_each_cpu_mask(cpu, *mask) {
+	for_each_cpu(cpu, mask) {
 		if (cpu_online(cpu))
 			break;
 	}
--- linux-2.6.28.orig/mm/allocpercpu.c
+++ linux-2.6.28/mm/allocpercpu.c
@@ -34,7 +34,7 @@ static void percpu_depopulate(void *__pd
 static void __percpu_depopulate_mask(void *__pdata, cpumask_t *mask)
 {
 	int cpu;
-	for_each_cpu_mask_nr(cpu, *mask)
+	for_each_cpu(cpu, mask)
 		percpu_depopulate(__pdata, cpu);
 }
 
@@ -86,7 +86,7 @@ static int __percpu_populate_mask(void *
 	int cpu;
 
 	cpus_clear(populated);
-	for_each_cpu_mask_nr(cpu, *mask)
+	for_each_cpu(cpu, mask)
 		if (unlikely(!percpu_populate(__pdata, size, gfp, cpu))) {
 			__percpu_depopulate_mask(__pdata, &populated);
 			return -ENOMEM;
--- linux-2.6.28.orig/mm/vmstat.c
+++ linux-2.6.28/mm/vmstat.c
@@ -27,7 +27,7 @@ static void sum_vm_events(unsigned long 
 
 	memset(ret, 0, NR_VM_EVENT_ITEMS * sizeof(unsigned long));
 
-	for_each_cpu_mask_nr(cpu, *cpumask) {
+	for_each_cpu(cpu, cpumask) {
 		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
 
 		for (i = 0; i < NR_VM_EVENT_ITEMS; i++)

-- 
