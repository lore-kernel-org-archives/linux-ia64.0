From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Tue, 04 Jul 2006 05:51:04 +0000
Subject: [Patch:BUG] oversight of copy pgdat array on each node for ia64's memory hotplug.
Message-Id: <20060704143906.8350.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

Hello.

I found a bug in memory hot-add code for ia64.

IA64's code has copies of pgdat's array on each node to reduce memory
access over crossing node. This array is used by NODE_DATA() macro.
When new node is hot-added, this pgdat's array should be updated and
copied on new node too.

However, I used for_each_online_node() in scatter_node_data() to copy
it. This meant its array is not copied on new node.
Because initialization of structures for new node was halfway,
so online_node_map couldn't be set at this time.

To copy arrays on new node, I changed it to check value of
pgdat_list[] which is source array of copies.
I tested this patch with my Memory Hotadd emulation on Tiger4.
This patch is for 2.6.17-git20.

Please apply.

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

---

 arch/ia64/mm/discontig.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

Index: pgdattest1/arch/ia64/mm/discontig.c
=================================--- pgdattest1.orig/arch/ia64/mm/discontig.c	2006-07-03 15:41:30.000000000 +0900
+++ pgdattest1/arch/ia64/mm/discontig.c	2006-07-03 15:44:48.000000000 +0900
@@ -313,10 +313,19 @@ static void __meminit scatter_node_data(
 	pg_data_t **dst;
 	int node;
 
-	for_each_online_node(node) {
-		dst = LOCAL_DATA_ADDR(pgdat_list[node])->pg_data_ptrs;
-		memcpy(dst, pgdat_list, sizeof(pgdat_list));
-	}
+	/*
+	 * for_each_online_map() can't be used at here.
+	 * node_online_map is not set for hot-added node at this time,
+	 * because here is halfway of initilization of new node's structure.
+	 * If for_each_online_node() is used, new node's pg_data_ptrs will
+	 * be not initialized. Insted of using it, pgdat_list[] is checked.
+	 */
+	for_each_node(node)
+		if (pgdat_list[node]){
+			dst = LOCAL_DATA_ADDR(pgdat_list[node])->pg_data_ptrs;
+			memcpy(dst, pgdat_list, sizeof(pgdat_list));
+		}
+
 }
 
 /**

-- 
Yasunori Goto 


