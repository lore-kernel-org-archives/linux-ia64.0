From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 06 Jan 2006 02:50:03 +0000
Subject: [PATCH] Simple memory hot-add for ia64.
Message-Id: <20060106114249.5649.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>

Hello Tony-san.

Fortunately, 2.6.15 includes memory hot-add function for i386 and ppc.
So, I made a patch for ia64.
This doesn't make new pgdat. All of new memory will belong to
node 0 by this patch. But this is simplest first step and best start for
future work.

I tested on my Tiger4. Please apply.

(This patch doesn't use ZONE_EASY_RECLAIM yet, because its zone will be useful
 for just hot-remove.)

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: new_feature_patch/arch/ia64/mm/init.c
=================================--- new_feature_patch.orig/arch/ia64/mm/init.c	2006-01-05 15:43:10.000000000 +0900
+++ new_feature_patch/arch/ia64/mm/init.c	2006-01-05 20:23:00.000000000 +0900
@@ -635,3 +635,38 @@ mem_init (void)
 	ia32_mem_init();
 #endif
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+void online_page(struct page *page)
+{
+	ClearPageReserved(page);
+	set_page_count(page, 1);
+	__free_page(page);
+	totalram_pages++;
+	num_physpages++;
+}
+
+int add_memory(u64 start, u64 size)
+{
+	pg_data_t *pgdat;
+	struct zone *zone;
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+	int ret;
+
+	pgdat = NODE_DATA(0);
+
+	zone = pgdat->node_zones + ZONE_NORMAL;
+	ret = __add_pages(zone, start_pfn, nr_pages);
+
+	if (ret)
+		printk("%s: Problem encountered in __add_pages() as ret=%d\n", __func__,  ret);
+
+	return ret;
+}
+
+int remove_memory(u64 start, u64 size)
+{
+	return -EINVAL;
+}
+#endif

-- 
Yasunori Goto 


