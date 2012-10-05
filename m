From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Date: Fri, 05 Oct 2012 02:38:20 +0000
Subject: [PATCH 10/10] memory-hotplug : remove sysfs file of node
Message-Id: <506E481C.8050804@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <506E43E0.70507@jp.fujitsu.com>
In-Reply-To: <506E43E0.70507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, cl@linux.com, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, wency@cn.fujitsu.com

From: Wen Congyang <wency@cn.fujitsu.com>

This patch introduces a new function try_offline_node() to
remove sysfs file of node when all memory sections of this
node are removed. If some memory sections of this node are
not removed, this function does nothing.

CC: David Rientjes <rientjes@google.com>
CC: Jiang Liu <liuj97@gmail.com>
CC: Len Brown <len.brown@intel.com>
CC: Christoph Lameter <cl@linux.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 mm/memory_hotplug.c |   54 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 54 insertions(+)

Index: linux-3.6/mm/memory_hotplug.c
=================================--- linux-3.6.orig/mm/memory_hotplug.c	2012-10-04 18:30:31.767709165 +0900
+++ linux-3.6/mm/memory_hotplug.c	2012-10-04 18:32:46.907842637 +0900
@@ -29,6 +29,7 @@
 #include <linux/suspend.h>
 #include <linux/mm_inline.h>
 #include <linux/firmware-map.h>
+#include <linux/stop_machine.h>
 
 #include <asm/tlbflush.h>
 
@@ -1276,6 +1277,57 @@ int offline_memory(u64 start, u64 size)
 	return 0;
 }
 
+static int check_cpu_on_node(void *data)
+{
+	struct pglist_data *pgdat = data;
+	int cpu;
+
+	for_each_online_cpu(cpu) {
+		if (cpu_to_node(cpu) = pgdat->node_id)
+			/*
+			 * the cpu on this node is onlined, and we can't
+			 * offline this node.
+			 */
+			return -EBUSY;
+	}
+
+	return 0;
+}
+
+/* offline the node if all memory sections of this node are removed */
+static void try_offline_node(int nid)
+{
+	unsigned long start_pfn = NODE_DATA(nid)->node_start_pfn;
+	unsigned long end_pfn = start_pfn + NODE_DATA(nid)->node_spanned_pages;
+	unsigned long pfn;
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
+		unsigned long section_nr = pfn_to_section_nr(pfn);
+
+		if (!present_section_nr(section_nr))
+			continue;
+
+		if (pfn_to_nid(pfn) != nid)
+			continue;
+
+		/*
+		 * some memory sections of this node are not removed, and we
+		 * can't offline node now.
+		 */
+		return;
+	}
+
+	if (stop_machine(check_cpu_on_node, NODE_DATA(nid), NULL))
+		return;
+
+	/*
+	 * all memory sections of this node are removed, we can offline this
+	 * node now.
+	 */
+	node_set_offline(nid);
+	unregister_one_node(nid);
+}
+
 int __ref remove_memory(int nid, u64 start, u64 size)
 {
 	int ret = 0;
@@ -1296,6 +1348,8 @@ int __ref remove_memory(int nid, u64 sta
 	firmware_map_remove(start, start + size, "System RAM");
 
 	arch_remove_memory(start, size);
+
+	try_offline_node(nid);
 out:
 	unlock_memory_hotplug();
 	return ret;

