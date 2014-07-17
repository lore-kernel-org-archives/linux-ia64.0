From: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Date: Thu, 17 Jul 2014 23:09:58 +0000
Subject: [RFC 1/2] workqueue: use the nearest NUMA node, not the local one
Message-Id: <20140717230958.GB32660@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140717230923.GA32660@linux.vnet.ibm.com>
In-Reply-To: <20140717230923.GA32660@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: benh@kernel.crashing.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Jiang Liu <jiang.liu@linux.intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

In the presence of memoryless nodes, the workqueue code incorrectly uses
cpu_to_node() to determine what node to prefer memory allocations come
from. cpu_to_mem() should be used instead, which will use the nearest
NUMA node with memory.

Signed-off-by: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 35974ac..0bba022 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -3547,7 +3547,12 @@ static struct worker_pool *get_unbound_pool(const struct workqueue_attrs *attrs)
 		for_each_node(node) {
 			if (cpumask_subset(pool->attrs->cpumask,
 					   wq_numa_possible_cpumask[node])) {
-				pool->node = node;
+				/*
+				 * We could use local_memory_node(node) here,
+				 * but it is expensive and the following caches
+				 * the same value.
+				 */
+				pool->node = cpu_to_mem(cpumask_first(pool->attrs->cpumask));
 				break;
 			}
 		}
@@ -4921,7 +4926,7 @@ static int __init init_workqueues(void)
 			pool->cpu = cpu;
 			cpumask_copy(pool->attrs->cpumask, cpumask_of(cpu));
 			pool->attrs->nice = std_nice[i++];
-			pool->node = cpu_to_node(cpu);
+			pool->node = cpu_to_mem(cpu);
 
 			/* alloc pool ID */
 			mutex_lock(&wq_pool_mutex);

