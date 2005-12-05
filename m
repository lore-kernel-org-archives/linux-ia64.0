From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 05 Dec 2005 19:01:09 +0000
Subject: [PATCH 2/3] ia64 zone reclaim
Message-Id: <20051205190109.12037.28157.sendpatchset@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20051205190104.12037.69672.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: akpm@osdl.org, torvalds@osdl.org
Cc: linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org

IA64 zone reclaim

Set up a zone reclaim function for IA64. The zone reclaim function will
reclaim easily reclaimable pages. Off node allocations will occur if no
easily reclaimable pages exist anymore.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.15-rc4/arch/ia64/mm/numa.c
=================================--- linux-2.6.15-rc4.orig/arch/ia64/mm/numa.c	2005-11-30 22:25:15.000000000 -0800
+++ linux-2.6.15-rc4/arch/ia64/mm/numa.c	2005-12-05 10:12:14.000000000 -0800
@@ -17,6 +17,7 @@
 #include <linux/node.h>
 #include <linux/init.h>
 #include <linux/bootmem.h>
+#include <linux/swap.h>
 #include <asm/mmzone.h>
 #include <asm/numa.h>
 
@@ -71,3 +72,17 @@ int early_pfn_to_nid(unsigned long pfn)
 	return 0;
 }
 #endif
+
+/*
+ * Remove easily reclaimable local pages if watermarks would prevent a
+ * local allocation.
+ */
+int arch_zone_reclaim(struct zone *z, gfp_t  mask,
+				    unsigned int order)
+{
+	if (z->zone_pgdat->node_id = numa_node_id()) {
+		if (zone_reclaim(z, mask, 0, 0) > (1 << order))
+			return 1;
+	}
+	return 0;
+}
Index: linux-2.6.15-rc4/arch/ia64/Kconfig
=================================--- linux-2.6.15-rc4.orig/arch/ia64/Kconfig	2005-11-30 22:25:15.000000000 -0800
+++ linux-2.6.15-rc4/arch/ia64/Kconfig	2005-12-03 13:30:27.000000000 -0800
@@ -338,6 +338,10 @@ config HAVE_ARCH_EARLY_PFN_TO_NID
 	def_bool y
 	depends on NEED_MULTIPLE_NODES
 
+config ARCH_ZONE_RECLAIM
+	def_bool y
+	depends on NUMA
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
