From: Jesse Barnes <jbarnes@sgi.com>
Date: Sat, 01 Mar 2003 21:03:18 +0000
Subject: [Linux-ia64] [PATCH] fix include/asm-ia64/topology.h
Message-Id: <marc-linux-ia64-105590709805951@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Looks like this one slipped through the cracks when I sent out my last
update.

Thanks,
Jesse


--- linux-2.5.60-ia64/include/asm-ia64/topology.h	Mon Feb 10 10:37:55 2003
+++ linux-2.5.60-ia64-sn/include/asm-ia64/topology.h	Sat Mar  1 12:59:25 2003
@@ -26,7 +26,7 @@
 /*
  * Returns a bitmask of CPUs on Node 'node'.
  */
-#define node_to_cpumask(node) (node_to_cpumask[node])
+#define node_to_cpumask(node) (node_to_cpu_mask[node])
 
 #else
 #define cpu_to_node(cpu) (0)

