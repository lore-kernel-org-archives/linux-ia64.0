From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 04 Jun 2004 15:43:37 +0000
Subject: [PATCH] setup cpu_to_node for cpus not present
Message-Id: <1086363816.4241.20.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   In latest linux-2.5 bitkeeper, if you turn on CONFIG_HOTPLUG_CPU w/
an NR_CPUS greater than physically presents CPUs, you'll end up taking
an MCA in __alloc_percpu().  kmem_cache_alloc_node() gets called with a
node value of -1.  It seems other architectures are defaulting the
cpu_to_node map to zero for possible, but not present cpus.  Here's a
trivial patch that does the same for ia64.  Thanks,

	Alex

=== arch/ia64/kernel/smpboot.c 1.52 vs edited ==--- 1.52/arch/ia64/kernel/smpboot.c	Fri May 21 15:54:17 2004
+++ edited/arch/ia64/kernel/smpboot.c	Fri Jun  4 09:21:54 2004
@@ -525,7 +525,7 @@
 #else
 #		error Fixme: Dunno how to build CPU-to-node map.
 #endif
-		cpu_to_node_map[cpu] = node;
+		cpu_to_node_map[cpu] = (node >= 0) ? node : 0;
 		if (node >= 0)
 			cpu_set(cpu, node_to_cpu_mask[node]);
 	}


