From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 20 Oct 2004 19:26:56 +0000
Subject: [PATCH] top level scheduling domain for large NUMA boxes take #2
Message-Id: <200410201226.56390.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_AwrdBswH0893kxr"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_AwrdBswH0893kxr
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Sorry I included the sched.c bit last time.  Here's the patch again w/o it.  
It adds a top level scheduling domain for large systems that doesn't balance 
often.  Only affects NUMA platforms with more than 6 nodes.

Without the patch, large systems will have several disjoint scheduling 
domains, depending on their topology.  Obviously, this is undesirable since 
if one has a large machine, presumably one would like to make use of all of 
its CPUs.

Signed-off-by: John Hawkes <hawkes@sgi.com>
Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_AwrdBswH0893kxr
Content-Type: text/plain;
  charset="us-ascii";
  name="sched-domains-top-level-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sched-domains-top-level-4.patch"

===== arch/ia64/kernel/domain.c 1.3 vs edited =====
--- 1.3/arch/ia64/kernel/domain.c	2004-10-18 22:26:51 -07:00
+++ edited/arch/ia64/kernel/domain.c	2004-10-19 14:18:07 -07:00
@@ -119,6 +119,14 @@
  */
 static DEFINE_PER_CPU(struct sched_domain, node_domains);
 static struct sched_group *sched_group_nodes[MAX_NUMNODES];
+
+static DEFINE_PER_CPU(struct sched_domain, allnodes_domains);
+static struct sched_group sched_group_allnodes[MAX_NUMNODES];
+
+static int __devinit cpu_to_allnodes_group(int cpu)
+{
+	return cpu_to_node(cpu);
+}
 #endif
 
 /*
@@ -149,9 +157,21 @@
 		cpus_and(nodemask, nodemask, cpu_default_map);
 
 #ifdef CONFIG_NUMA
+		if (num_online_cpus()
+				> SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+			sd = &per_cpu(allnodes_domains, i);
+			*sd = SD_ALLNODES_INIT;
+			sd->span = cpu_default_map;
+			group = cpu_to_allnodes_group(i);
+			sd->groups = &sched_group_allnodes[group];
+			p = sd;
+		} else
+			p = NULL;
+
 		sd = &per_cpu(node_domains, i);
 		*sd = SD_NODE_INIT;
 		sd->span = sched_domain_node_span(node);
+		sd->parent = p;
 		cpus_and(sd->span, sd->span, cpu_default_map);
 #endif
 
@@ -201,6 +221,9 @@
 	}
 
 #ifdef CONFIG_NUMA
+	init_sched_build_groups(sched_group_allnodes, cpu_default_map,
+				&cpu_to_allnodes_group);
+
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		/* Set up node groups */
 		struct sched_group *sg, *prev;
@@ -282,6 +305,15 @@
 		power = SCHED_LOAD_SCALE + SCHED_LOAD_SCALE *
 				(cpus_weight(sd->groups->cpumask)-1) / 10;
 		sd->groups->cpu_power = power;
+
+#ifdef CONFIG_NUMA
+		sd = &per_cpu(allnodes_domains, i);
+		if (sd->groups) {
+			power = SCHED_LOAD_SCALE + SCHED_LOAD_SCALE *
+				(cpus_weight(sd->groups->cpumask)-1) / 10;
+			sd->groups->cpu_power = power;
+		}
+#endif
 	}
 
 #ifdef CONFIG_NUMA
===== include/asm-ia64/topology.h 1.12 vs edited =====
--- 1.12/include/asm-ia64/topology.h	2004-10-18 22:26:52 -07:00
+++ edited/include/asm-ia64/topology.h	2004-10-19 14:18:06 -07:00
@@ -58,7 +58,26 @@
 				| SD_BALANCE_EXEC	\
 				| SD_WAKE_BALANCE,	\
 	.last_balance		= jiffies,		\
-	.balance_interval	= 10,			\
+	.balance_interval	= 1,			\
+	.nr_balance_failed	= 0,			\
+}
+
+/* sched_domains SD_ALLNODES_INIT for IA64 NUMA machines */
+#define SD_ALLNODES_INIT (struct sched_domain) {	\
+	.span			= CPU_MASK_NONE,	\
+	.parent			= NULL,			\
+	.groups			= NULL,			\
+	.min_interval		= 80,			\
+	.max_interval		= 320,			\
+	.busy_factor		= 320,			\
+	.imbalance_pct		= 125,			\
+	.cache_hot_time		= (10*1000000),		\
+	.cache_nice_tries	= 1,			\
+	.per_cpu_gain		= 100,			\
+	.flags			= SD_LOAD_BALANCE	\
+				| SD_BALANCE_EXEC,	\
+	.last_balance		= jiffies,		\
+	.balance_interval	= 100*(63+num_online_cpus())/64,   \
 	.nr_balance_failed	= 0,			\
 }
 

--Boundary-00=_AwrdBswH0893kxr--
