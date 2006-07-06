From: Greg Banks <gnb@melbourne.sgi.com>
Date: Thu, 06 Jul 2006 05:13:39 +0000
Subject: [PATCH] ia64: export node_to_cpu_mask
Message-Id: <1152162819.18333.357.camel@hole.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ia64: Export node_to_cpu_mask so that modules (e.g. sunrpc) can use
the node_to_cpumask() macro.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 arch/ia64/kernel/numa.c |    1 +
 1 files changed, 1 insertion(+)

Index: linus-git/arch/ia64/kernel/numa.c
=================================--- linus-git.orig/arch/ia64/kernel/numa.c	2006-07-05 15:53:15.390566417 +1000
+++ linus-git/arch/ia64/kernel/numa.c	2006-07-06 14:48:01.587159303 +1000
@@ -28,6 +28,7 @@ u16 cpu_to_node_map[NR_CPUS] __cacheline
 EXPORT_SYMBOL(cpu_to_node_map);
 
 cpumask_t node_to_cpu_mask[MAX_NUMNODES] __cacheline_aligned;
+EXPORT_SYMBOL_GPL(node_to_cpu_mask);
 
 /**
  * build_cpu_to_node_map - setup cpu to node and node to cpumask arrays


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


