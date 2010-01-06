From: Anton Blanchard <anton@samba.org>
Date: Wed, 06 Jan 2010 04:55:12 +0000
Subject: [patch 3/6] ia64: cpumask_of_node() should handle -1 as a node
Message-Id: <20100106045525.082530491@samba.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100106045509.245662398@samba.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>, Andrew Morton <akpm@linux-foundation.org>

pcibus_to_node can return -1 if we cannot determine which node a pci bus
is on. If passed -1, cpumask_of_node will negatively index the lookup array
and pull in random data:

# cat /sys/devices/pci0000:00/0000:00:01.0/local_cpus
00000000,00000003,00000000,00000000
# cat /sys/devices/pci0000:00/0000:00:01.0/local_cpulist
64-65

Change cpumask_of_node to check for -1 and return cpu_all_mask in this
case:

# cat /sys/devices/pci0000:00/0000:00:01.0/local_cpus
ffffffff,ffffffff,ffffffff,ffffffff
# cat /sys/devices/pci0000:00/0000:00:01.0/local_cpulist
0-127

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-cpumask/arch/ia64/include/asm/topology.h
=================================--- linux-cpumask.orig/arch/ia64/include/asm/topology.h	2010-01-06 15:20:22.832584260 +1100
+++ linux-cpumask/arch/ia64/include/asm/topology.h	2010-01-06 15:26:46.620650121 +1100
@@ -33,7 +33,9 @@
 /*
  * Returns a bitmask of CPUs on Node 'node'.
  */
-#define cpumask_of_node(node) (&node_to_cpu_mask[node])
+#define cpumask_of_node(node) ((node) = -1 ?				\
+			       cpu_all_mask :				\
+			       &node_to_cpu_mask[node])
 
 /*
  * Returns the number of the node containing Node 'nid'.

-- 

