From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Date: Tue, 02 Nov 2004 09:31:22 +0000
Subject: Re: [PATCH] top level scheduler domain for ia64
Message-Id: <20041102.183122.115904953.t-kochi@bq.jp.nec.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200410191427.27336.jbarnes@engr.sgi.com>
In-Reply-To: <200410191427.27336.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Takayoshi Kochi <t-kochi@bq.jp.nec.com>
Subject: Re: [PATCH] top level scheduler domain for ia64
Date: Tue, 02 Nov 2004 16:36:36 +0900 (JST)

> I think the short-term solution is to make the boot-time parameter
> like Jesse said to control the creation and span size of the
> node domain and see what is necessary next.

This patch adds a new kernel parameter "nodes_per_domain"
which specifies how many nodes are included in a node 
scheduling domain.

Signed-off-by: Takayoshi Kochi <t-kochi@bq.jp.nec.com>

Index: 269-bk/arch/ia64/kernel/domain.c
=================================--- 269-bk/arch/ia64/kernel/domain.c	(revision 49)
+++ 269-bk/arch/ia64/kernel/domain.c	(working copy)
@@ -12,9 +12,9 @@
 #include <linux/init.h>
 #include <linux/topology.h>
 
-#define SD_NODES_PER_DOMAIN 6
+#ifdef CONFIG_NUMA
+static int sd_nodes_per_domain = 6;
 
-#ifdef CONFIG_NUMA
 /**
  * find_next_best_node - find the next node to include in a sched_domain
  * @node: node whose sched_domain we're building
@@ -77,7 +77,7 @@
 	cpus_or(span, span, nodemask);
 	set_bit(node, used_nodes);
 
-	for (i = 1; i < SD_NODES_PER_DOMAIN; i++) {
+	for (i = 1; i < sd_nodes_per_domain; i++) {
 		int next_node = find_next_best_node(node, used_nodes);
 		nodemask = node_to_cpumask(next_node);
 		cpus_or(span, span, nodemask);
@@ -158,7 +158,7 @@
 
 #ifdef CONFIG_NUMA
 		if (num_online_cpus()
-				> SD_NODES_PER_DOMAIN*cpus_weight(nodemask)) {
+				> sd_nodes_per_domain*cpus_weight(nodemask)) {
 			sd = &per_cpu(allnodes_domains, i);
 			*sd = SD_ALLNODES_INIT;
 			sd->span = cpu_default_map;
@@ -379,3 +379,18 @@
 #endif
 }
 
+#ifdef CONFIG_NUMA
+static int __init
+set_nodes_per_domain (char *str)
+{
+	int tmp;
+
+	get_option(&str, &tmp);
+	if (tmp > 1 && tmp <= MAX_NUMNODES)
+		sd_nodes_per_domain = tmp;
+
+	return 1;
+}
+
+__setup("nodes_per_domain=", set_nodes_per_domain);
+#endif


---
Takayoshi Kochi
