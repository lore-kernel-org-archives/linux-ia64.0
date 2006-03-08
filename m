From: Yasunori Goto <y-goto@jp.fujitsu.com>
Date: Wed, 08 Mar 2006 13:42:11 +0000
Subject: [PATCH: 008/017](RFC) Memory hotplug for new nodes v.3. (allocate pgdat for ia64)
Message-Id: <20060308213020.0032.Y-GOTO@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Joel Schopp <jschopp@austin.ibm.com>
Cc: linux-ia64@vger.kernel.org, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>

This is a patch to allocate pgdat and per node data area for ia64.
The size for them can be calculated by compute_pernodesize().

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Index: pgdat6/arch/ia64/mm/discontig.c
=================================--- pgdat6.orig/arch/ia64/mm/discontig.c	2006-03-06 18:26:11.000000000 +0900
+++ pgdat6/arch/ia64/mm/discontig.c	2006-03-06 18:26:15.000000000 +0900
@@ -115,7 +115,7 @@ static int __init early_nr_cpus_node(int
  * compute_pernodesize - compute size of pernode data
  * @node: the node id.
  */
-static unsigned long __init compute_pernodesize(int node)
+static unsigned long __meminit compute_pernodesize(int node)
 {
 	unsigned long pernodesize = 0, cpus;
 
@@ -728,6 +728,18 @@ void __init paging_init(void)
 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
 }
 
+pg_data_t *arch_alloc_nodedata(int nid)
+{
+	unsigned long size = compute_pernodesize(nid);
+
+	return kzalloc(size, GFP_KERNEL);
+}
+
+void arch_free_nodedata(pg_data_t *pgdat)
+{
+	kfree(pgdat);
+}
+
 void arch_refresh_nodedata(int update_node, pg_data_t *update_pgdat)
 {
 	pgdat_list[update_node] = update_pgdat;

-- 
Yasunori Goto 


