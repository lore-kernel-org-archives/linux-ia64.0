From: Jack Steiner <steiner@sgi.com>
Date: Tue, 17 Jan 2006 21:42:46 +0000
Subject: [PATCH] - Zonelists for nodes without cpus
Message-Id: <20060117214246.GA15872@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

If a node runs out of memory, ensure that memory on nodes w/o cpus is used
before using memory on nodes with cpus. 

	Signed-off-by: Jack Steiner <steiner@sgi.com>



Index: linux/include/asm-ia64/topology.h
=================================--- linux.orig/include/asm-ia64/topology.h	2006-01-17 14:27:48.473073976 -0600
+++ linux/include/asm-ia64/topology.h	2006-01-17 14:28:12.070373036 -0600
@@ -18,6 +18,10 @@
 #include <asm/smp.h>
 
 #ifdef CONFIG_NUMA
+
+/* Nodes w/o CPUs are preferred for memory allocations, see build_zonelists */
+#define PENALTY_FOR_NODE_WITH_CPUS 255
+
 /*
  * Returns the number of the node containing CPU 'cpu'
  */
