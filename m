From: Mike Travis <travis@sgi.com>
Date: Mon, 20 Oct 2008 17:03:45 +0000
Subject: [PATCH 26/35] cpumask: get rid of boutique sched.c allocations, use cpumask_var_t.
Message-Id: <20081020170323.199606000@polaris-admin.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081020170319.539427000@polaris-admin.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, davej@codemonkey.org.uk, David Miller <davem@davemloft.net>, Eric Dumazet <dada1@cosmosbay.com>, Jack Steiner <steiner@sgi.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Jes Sorensen <jes@sgi.com>, "H. Peter Anvin" <hpa@zytor.com>, peterz@infradead.org, Thomas Gleixner <tglx@linutronix.de>, Yinghai Lu <yhlu.kernel@gmail.com>, IA64 <linux-ia64@vger.kernel.org>, PowerPC <linuxppc-dev@ozlabs.org>, S390 <linux-s390@vger.kernel.org>, SPARC <sparclinux@vger.kernel.org>, linux-kernel@vger.kernel.org

Using lots of allocs rather than one big alloc is less efficient, but
who cares for this setup function?

From: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Signed-off-by: Mike Travis <travis@sgi.com>
---
 kernel/sched.c |  133 ++++++++++++++++++++++++---------------------------------
 1 file changed, 56 insertions(+), 77 deletions(-)

--- linux-2.6.28.orig/kernel/sched.c
+++ linux-2.6.28/kernel/sched.c
@@ -7291,40 +7291,6 @@ SD_INIT_FUNC(CPU)
  SD_INIT_FUNC(MC)
 #endif
 
-/*
- * To minimize stack usage kmalloc room for cpumasks and share the
- * space as the usage in build_sched_domains() dictates.  Used only
- * if the amount of space is significant.
- */
-struct allmasks {
-	cpumask_t tmpmask;			/* make this one first */
-	union {
-		cpumask_t nodemask;
-		cpumask_t this_sibling_map;
-		cpumask_t this_core_map;
-	};
-	cpumask_t send_covered;
-
-#ifdef CONFIG_NUMA
-	cpumask_t domainspan;
-	cpumask_t covered;
-	cpumask_t notcovered;
-#endif
-};
-
-#if	NR_CPUS > 128
-#define	SCHED_CPUMASK_ALLOC		1
-#define	SCHED_CPUMASK_FREE(v)		kfree(v)
-#define	SCHED_CPUMASK_DECLARE(v)	struct allmasks *v
-#else
-#define	SCHED_CPUMASK_ALLOC		0
-#define	SCHED_CPUMASK_FREE(v)
-#define	SCHED_CPUMASK_DECLARE(v)	struct allmasks _v, *v = &_v
-#endif
-
-#define	SCHED_CPUMASK_VAR(v, a) 	cpumask_t *v = (cpumask_t *) \
-			((unsigned long)(a) + offsetof(struct allmasks, v))
-
 static int default_relax_domain_level = -1;
 
 static int __init setup_relax_domain_level(char *str)
@@ -7367,14 +7333,35 @@ static void set_domain_attribute(struct 
 static int __build_sched_domains(const cpumask_t *cpu_map,
 				 struct sched_domain_attr *attr)
 {
-	int i;
+	int i, err = -ENOMEM;
 	struct root_domain *rd;
-	SCHED_CPUMASK_DECLARE(allmasks);
-	cpumask_t *tmpmask;
+	cpumask_var_t nodemask, this_sibling_map, this_core_map, send_covered,
+		tmpmask;
 #ifdef CONFIG_NUMA
+	cpumask_var_t domainspan, covered, notcovered;
 	struct sched_group **sched_group_nodes = NULL;
 	int sd_allnodes = 0;
 
+	if (!alloc_cpumask_var(&domainspan, GFP_KERNEL))
+		goto out;
+	if (!alloc_cpumask_var(&covered, GFP_KERNEL))
+		goto free_domainspan;
+	if (!alloc_cpumask_var(&notcovered, GFP_KERNEL))
+		goto free_covered;
+#endif
+
+	if (!alloc_cpumask_var(&nodemask, GFP_KERNEL))
+		goto free_notcovered;
+	if (!alloc_cpumask_var(&this_sibling_map, GFP_KERNEL))
+		goto free_nodemask;
+	if (!alloc_cpumask_var(&this_core_map, GFP_KERNEL))
+		goto free_this_sibling_map;
+	if (!alloc_cpumask_var(&send_covered, GFP_KERNEL))
+		goto free_this_core_map;
+	if (!alloc_cpumask_var(&tmpmask, GFP_KERNEL))
+		goto free_send_covered;
+
+#ifdef CONFIG_NUMA
 	/*
 	 * Allocate the per-node list of sched groups
 	 */
@@ -7382,34 +7369,16 @@ static int __build_sched_domains(const c
 				    GFP_KERNEL);
 	if (!sched_group_nodes) {
 		printk(KERN_WARNING "Can not alloc sched group node list\n");
-		return -ENOMEM;
+		goto free_tmpmask;
 	}
 #endif
 
 	rd = alloc_rootdomain();
 	if (!rd) {
 		printk(KERN_WARNING "Cannot alloc root domain\n");
-#ifdef CONFIG_NUMA
-		kfree(sched_group_nodes);
-#endif
-		return -ENOMEM;
+		goto free_sched_groups;
 	}
 
-#if SCHED_CPUMASK_ALLOC
-	/* get space for all scratch cpumask variables */
-	allmasks = kmalloc(sizeof(*allmasks), GFP_KERNEL);
-	if (!allmasks) {
-		printk(KERN_WARNING "Cannot alloc cpumask array\n");
-		kfree(rd);
-#ifdef CONFIG_NUMA
-		kfree(sched_group_nodes);
-#endif
-		return -ENOMEM;
-	}
-#endif
-	tmpmask = (cpumask_t *)allmasks;
-
-
 #ifdef CONFIG_NUMA
 	sched_group_nodes_bycpu[first_cpu(*cpu_map)] = sched_group_nodes;
 #endif
@@ -7419,7 +7388,6 @@ static int __build_sched_domains(const c
 	 */
 	for_each_cpu(i, cpu_map) {
 		struct sched_domain *sd = NULL, *p;
-		SCHED_CPUMASK_VAR(nodemask, allmasks);
 
 		*nodemask = node_to_cpumask(cpu_to_node(i));
 		cpus_and(*nodemask, *nodemask, *cpu_map);
@@ -7485,9 +7453,6 @@ static int __build_sched_domains(const c
 #ifdef CONFIG_SCHED_SMT
 	/* Set up CPU (sibling) groups */
 	for_each_cpu(i, cpu_map) {
-		SCHED_CPUMASK_VAR(this_sibling_map, allmasks);
-		SCHED_CPUMASK_VAR(send_covered, allmasks);
-
 		*this_sibling_map = per_cpu(cpu_sibling_map, i);
 		cpus_and(*this_sibling_map, *this_sibling_map, *cpu_map);
 		if (i != first_cpu(*this_sibling_map))
@@ -7502,9 +7467,6 @@ static int __build_sched_domains(const c
 #ifdef CONFIG_SCHED_MC
 	/* Set up multi-core groups */
 	for_each_cpu(i, cpu_map) {
-		SCHED_CPUMASK_VAR(this_core_map, allmasks);
-		SCHED_CPUMASK_VAR(send_covered, allmasks);
-
 		*this_core_map = cpu_coregroup_map(i);
 		cpus_and(*this_core_map, *this_core_map, *cpu_map);
 		if (i != first_cpu(*this_core_map))
@@ -7518,9 +7480,6 @@ static int __build_sched_domains(const c
 
 	/* Set up physical groups */
 	for (i = 0; i < nr_node_ids; i++) {
-		SCHED_CPUMASK_VAR(nodemask, allmasks);
-		SCHED_CPUMASK_VAR(send_covered, allmasks);
-
 		*nodemask = node_to_cpumask(i);
 		cpus_and(*nodemask, *nodemask, *cpu_map);
 		if (cpus_empty(*nodemask))
@@ -7534,8 +7493,6 @@ static int __build_sched_domains(const c
 #ifdef CONFIG_NUMA
 	/* Set up node groups */
 	if (sd_allnodes) {
-		SCHED_CPUMASK_VAR(send_covered, allmasks);
-
 		init_sched_build_groups(cpu_map, cpu_map,
 					&cpu_to_allnodes_group,
 					send_covered, tmpmask);
@@ -7544,9 +7501,6 @@ static int __build_sched_domains(const c
 	for (i = 0; i < nr_node_ids; i++) {
 		/* Set up node groups */
 		struct sched_group *sg, *prev;
-		SCHED_CPUMASK_VAR(nodemask, allmasks);
-		SCHED_CPUMASK_VAR(domainspan, allmasks);
-		SCHED_CPUMASK_VAR(covered, allmasks);
 		int j;
 
 		*nodemask = node_to_cpumask(i);
@@ -7581,7 +7535,6 @@ static int __build_sched_domains(const c
 		prev = sg;
 
 		for (j = 0; j < nr_node_ids; j++) {
-			SCHED_CPUMASK_VAR(notcovered, allmasks);
 			int n = (i + j) % nr_node_ids;
 			node_to_cpumask_ptr(pnodemask, n);
 
@@ -7660,14 +7613,40 @@ static int __build_sched_domains(const c
 		cpu_attach_domain(sd, rd, i);
 	}
 
-	SCHED_CPUMASK_FREE((void *)allmasks);
-	return 0;
+	err = 0;
+
+free_tmpmask:
+	free_cpumask_var(tmpmask);
+free_send_covered:
+	free_cpumask_var(send_covered);
+free_this_core_map:
+	free_cpumask_var(this_core_map);
+free_this_sibling_map:
+	free_cpumask_var(this_sibling_map);
+free_nodemask:
+	free_cpumask_var(nodemask);
+free_notcovered:
+#ifdef CONFIG_NUMA
+	free_cpumask_var(notcovered);
+free_covered:
+	free_cpumask_var(covered);
+free_domainspan:
+	free_cpumask_var(domainspan);
+out:
+#endif
+	return err;
+
+free_sched_groups:
+#ifdef CONFIG_NUMA
+	kfree(sched_group_nodes);
+#endif
+	goto free_tmpmask;
 
 #ifdef CONFIG_NUMA
 error:
 	free_sched_groups(cpu_map, tmpmask);
-	SCHED_CPUMASK_FREE((void *)allmasks);
-	return -ENOMEM;
+	kfree(rd);
+	goto free_tmpmask;
 #endif
 }
 

-- 
