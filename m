From: dcn@sgi.com (Dean Nelson)
Date: Wed, 23 Mar 2005 19:00:21 +0000
Subject: [PATCH] Export node_online_map and node_possible_map
Message-Id: <4241BCC5.mailxH3J11SP5W@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Export node_online_map and node_possible_map so that kernel modules can use
the nodemask macros, like, for_each_node() and for_each_online_node().

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/mm/page_alloc.c
=================================--- linux-2.6.orig/mm/page_alloc.c	2005-03-17 08:55:23.253781240 -0600
+++ linux-2.6/mm/page_alloc.c	2005-03-17 09:23:51.648987691 -0600
@@ -43,7 +43,9 @@
  * initializer cleaner
  */
 nodemask_t node_online_map = { { [0] = 1UL } };
+EXPORT_SYMBOL(node_online_map);
 nodemask_t node_possible_map = NODE_MASK_ALL;
+EXPORT_SYMBOL(node_possible_map);
 struct pglist_data *pgdat_list;
 unsigned long totalram_pages;
 unsigned long totalhigh_pages;
