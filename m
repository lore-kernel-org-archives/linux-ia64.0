From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Fri, 30 Sep 2005 13:07:16 +0000
Subject: [PATCH]Remove pgdat list ver.2  [2/2]
Message-Id: <20050930210141.701B.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-ia64@vger.kernel.org

-------------------
This is for ia64. Pgdat insertion is not necessary.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


Index: pgdat_link/arch/ia64/mm/discontig.c
=================================--- pgdat_link.orig/arch/ia64/mm/discontig.c	2005-09-30 19:04:10.070261497 +0900
+++ pgdat_link/arch/ia64/mm/discontig.c	2005-09-30 19:06:42.850533063 +0900
@@ -376,30 +376,6 @@ static void __init *memory_less_node_all
 	return ptr;
 }
 
-/**
- * pgdat_insert - insert the pgdat into global pgdat_list
- * @pgdat: the pgdat for a node.
- */
-static void __init pgdat_insert(pg_data_t *pgdat)
-{
-	pg_data_t *prev = NULL, *next;
-
-	for_each_pgdat(next)
-		if (pgdat->node_id < next->node_id)
-			break;
-		else
-			prev = next;
-
-	if (prev) {
-		prev->pgdat_next = pgdat;
-		pgdat->pgdat_next = next;
-	} else {
-		pgdat->pgdat_next = pgdat_list;
-		pgdat_list = pgdat;
-	}
-
-	return;
-}
 
 /**
  * memory_less_nodes - allocate and initialize CPU only nodes pernode
@@ -695,11 +671,5 @@ void __init paging_init(void)
 				    pfn_offset, zholes_size);
 	}
 
-	/*
-	 * Make memory less nodes become a member of the known nodes.
-	 */
-	for_each_node_mask(node, memory_less_mask)
-		pgdat_insert(mem_data[node].pgdat);
-
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }


-- 
Yasunori Goto 

