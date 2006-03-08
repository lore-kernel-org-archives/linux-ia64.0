From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 08 Mar 2006 13:41:26 +0000
Subject: [PATCH: 003/017](RFC) Memory hotplug for new nodes v.3.(get node id at probe memory)
Message-Id: <20060308212646.0028.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Joel Schopp <jschopp@austin.ibm.com>, Dave Hansen <haveblue@us.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>

When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
before calling add_memory_node(nid, start, size).

Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
define arch_nid_probe(paddr);

Powerpc has nice function. X86_64 has not.....

Note:
If memory is hot-plugged by firmware, there is another *good* information
like pxm.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/powerpc/mm/mem.c
=================================--- pgdat6.orig/arch/powerpc/mm/mem.c	2006-03-06 19:34:53.000000000 +0900
+++ pgdat6/arch/powerpc/mm/mem.c	2006-03-06 19:39:51.000000000 +0900
@@ -114,6 +114,11 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
+int __devinit arch_nid_probe(u64 start)
+{
+	return hot_add_scn_to_nid(start);
+}
+
 int __devinit arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
Index: pgdat6/include/linux/memory_hotplug.h
=================================--- pgdat6.orig/include/linux/memory_hotplug.h	2006-03-06 19:34:47.000000000 +0900
+++ pgdat6/include/linux/memory_hotplug.h	2006-03-06 19:40:57.000000000 +0900
@@ -63,6 +63,15 @@ extern int online_pages(unsigned long, u
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+#if defined(CONFIG_NUMA) && defined(CONFIG_ARCH_MEMORY_PROBE)
+extern int arch_nid_probe(u64 start);
+#else
+static inline int arch_nid_probe(u64 start)
+{
+	return 0;
+}
+#endif
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
Index: pgdat6/drivers/base/memory.c
=================================--- pgdat6.orig/drivers/base/memory.c	2006-03-06 19:16:37.000000000 +0900
+++ pgdat6/drivers/base/memory.c	2006-03-06 19:39:51.000000000 +0900
@@ -310,7 +310,8 @@ memory_probe_store(struct class *class, 
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
-	ret = add_memory(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	ret = add_memory_node(arch_nid_probe(phys_addr),
+			 phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
 	if (ret)
 		count = ret;
Index: pgdat6/arch/x86_64/mm/init.c
=================================--- pgdat6.orig/arch/x86_64/mm/init.c	2006-03-06 19:34:53.000000000 +0900
+++ pgdat6/arch/x86_64/mm/init.c	2006-03-06 19:39:51.000000000 +0900
@@ -493,6 +493,11 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
+int arch_nid_probe(u64 start)
+{
+	return 0;
+}
+
 int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdat = NODE_DATA(nid);

-- 
Yasunori Goto 


