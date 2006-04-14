From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 14 Apr 2006 01:23:53 +0000
Subject: Setup an IA64 specific reclaim distance
Message-Id: <Pine.LNX.4.64.0604131823410.16211@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

RECLAIM_DISTANCE is checked on bootup against the SLIT table distances.
Zone reclaim is important for system that have higher latencies but not for
systems that have multiple nodes on one motherboard and therefore low latencies.

We found that on motherboard latencies are typically 1 to 1.4 of local memory
access speed whereas multinode systems which benefit from zone reclaim have
usually more than 1.5 times the latency of a local access.

Set the reclaim distance for IA64 to 1.5 times.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1-mm2/include/asm-ia64/topology.h
=================================--- linux-2.6.17-rc1-mm2.orig/include/asm-ia64/topology.h	2006-04-02 20:22:10.000000000 -0700
+++ linux-2.6.17-rc1-mm2/include/asm-ia64/topology.h	2006-04-13 17:49:18.000000000 -0700
@@ -23,6 +23,11 @@
 #define PENALTY_FOR_NODE_WITH_CPUS 255
 
 /*
+ * Distance above which we begin to use zone reclaim
+ */
+#define RECLAIM_DISTANCE 15
+
+/*
  * Returns the number of the node containing CPU 'cpu'
  */
 #define cpu_to_node(cpu) (int)(cpu_to_node_map[cpu])
