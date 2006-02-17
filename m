From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 17 Feb 2006 13:28:52 +0000
Subject: [PATCH: 004/012] Memory hotplug for new nodes v.2. (pgdat alloc caller for ia64)
Message-Id: <20060217211436.4070.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, "Tolentino, Matthew E" <matthew.e.tolentino@intel.com>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, x86-64 Discuss <discuss@x86-64.org>

This is caller of pgdat allocation for ia64.
If new memory belongs to new nodes, pgdat is allocated...

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat3/arch/ia64/mm/init.c
=================================--- pgdat3.orig/arch/ia64/mm/init.c	2006-02-17 15:51:04.000000000 +0900
+++ pgdat3/arch/ia64/mm/init.c	2006-02-17 16:14:59.000000000 +0900
@@ -20,6 +20,7 @@
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
 #include <linux/bitops.h>
+#include <linux/acpi.h>
 
 #include <asm/a.out.h>
 #include <asm/dma.h>
@@ -652,16 +653,32 @@ int add_memory(u64 start, u64 size)
 	struct zone *zone;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
-	int ret;
+	int ret, node, new_pgdat = 0;
 
-	pgdat = NODE_DATA(0);
+	node = acpi_paddr_to_node(start, size);
+
+	if (node < 0)
+	        node = 0; /* pxm is undefined in DSDT.
+			     This might be non NUMA case */
+
+	if (!node_online(node)){
+		ret = new_pgdat_init(node, start_pfn, nr_pages);
+		if (ret)
+			return ret;
+
+		new_pgdat = 1;
+	}
+	pgdat = NODE_DATA(node);
 
 	zone = pgdat->node_zones + ZONE_NORMAL;
 	ret = __add_pages(zone, start_pfn, nr_pages);
 
-	if (ret)
+	if (ret){
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __FUNCTION__,  ret);
+		if (new_pgdat)
+			release_pgdat(pgdat);
+	}
 
 	return ret;
 }

-- 
Yasunori Goto 


