From: Nick Pollitt <npollitt@sgi.com>
Date: Mon, 14 Jul 2003 19:20:37 +0000
Subject: HUGETLB pages on multiple nodes
Message-Id: <marc-linux-ia64-105821072317881@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Seth,  It looks like at boot time all the hugepages will get allocated 
on the boot node.  We'd like to spread the pages across multiple nodes 
on NUMA systems.  Here's a simple patch to round-robin the pages during 
kernel init.  Comments?

Nick

=== arch/ia64/mm/hugetlbpage.c 1.2 vs edited ==--- 1.2/arch/ia64/mm/hugetlbpage.c	Mon May 19 09:18:44 2003
+++ edited/arch/ia64/mm/hugetlbpage.c	Thu Jul 10 11:35:05 2003
@@ -419,7 +419,12 @@
 	struct page *page;
 
 	for (i = 0; i < htlbpage_max; ++i) {
+#ifdef CONFIG_NUMA
+		int node = i % num_memblks;
+		page = alloc_pages_node(node, __GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
+#else
 		page = alloc_pages(__GFP_HIGHMEM, HUGETLB_PAGE_ORDER);
+#endif /* CONFIG_NUMA */
 		if (!page)
 			break;
 		for (j = 0; j < HPAGE_SIZE/PAGE_SIZE; ++j)

