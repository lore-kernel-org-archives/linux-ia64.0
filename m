From: Jesse Barnes <jbarnes@sgi.com>
Date: Mon, 24 Feb 2003 22:12:11 +0000
Subject: [Linux-ia64] [PATCH] Another SN update [1/2]
Message-Id: <marc-linux-ia64-105590709805922@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's an update to the ia64 mmzone.h file that adds some SN2 specific
defines (which will probably have to be changed later, but it's a
start).

Thanks,
Jesse

--- linux-2.5.60-ia64/include/asm-ia64/mmzone.h	Mon Feb 10 10:39:17 2003
+++ linux-2.5.60-ia64-sn/include/asm-ia64/mmzone.h	Mon Feb 24 12:32:26 2003
@@ -76,7 +76,7 @@
 
 #define pfn_to_page(pfn)	(struct page *)(node_mem_map(pfn_to_nid(pfn)) + node_localnr(pfn, pfn_to_nid(pfn)))
 
-#define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> DIG_BANKSHIFT]
+#define pfn_to_nid(pfn)		 local_node_data->node_id_map[(pfn << PAGE_SHIFT) >> BANKSHIFT]
 
 #define page_to_pfn(page)	(long)((page - page_zone(page)->zone_mem_map) + page_zone(page)->zone_start_pfn)
 
@@ -110,15 +110,15 @@
  */
 #define NR_BANKS_PER_NODE	32
 #if defined(CONFIG_IA64_NODESIZE_16GB)
-# define DIG_BANKSHIFT		29
+# define BANKSHIFT		29
 #elif defined(CONFIG_IA64_NODESIZE_64GB)
-# define DIG_BANKSHIFT		31
+# define BANKSHIFT		31
 #elif defined(CONFIG_IA64_NODESIZE_256GB)
-# define DIG_BANKSHIFT		33
+# define BANKSHIFT		33
 #else
 # error Unsupported bank and nodesize!
 #endif
-#define BANKSIZE		(1UL << DIG_BANKSHIFT)
+#define BANKSIZE		(1UL << BANKSHIFT)
 #define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
 #define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
 
@@ -134,7 +134,30 @@
  * entry for the first page of the bank.
  */
 #define BANK_MEM_MAP_INDEX(kaddr) \
-	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> DIG_BANKSHIFT)
+	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
+
+#elif defined(CONFIG_IA64_SGI_SN2)
+/*
+ * SGI SN2 discontig definitions
+ */
+#define MAX_PHYSNODE_ID	2048	/* 2048 node ids (also called nasid) */
+#define NR_NODES	128	/* Maximum number of nodes in SSI */
+#define MAX_PHYS_MEMORY	(1UL << 49)
+
+#define BANKSHIFT		38
+#define NR_BANKS_PER_NODE	4
+#define SN2_NODE_SIZE		(64UL*1024*1024*1024)	/* 64GB per node */
+#define BANKSIZE		(SN2_NODE_SIZE/NR_BANKS_PER_NODE)
+#define BANK_OFFSET(addr)	((unsigned long)(addr) & (BANKSIZE-1))
+#define NR_BANKS		(NR_BANKS_PER_NODE * NR_NODES)
+#define VALID_MEM_KADDR(kaddr)	1
+
+/*
+ * Given a nodeid & a bank number, find the address of the mem_map
+ * entry for the first page of the bank.
+ */
+#define BANK_MEM_MAP_INDEX(kaddr) \
+	(((unsigned long)(kaddr) & (MAX_PHYS_MEMORY-1)) >> BANKSHIFT)
 
 #endif /* CONFIG_IA64_DIG */
 #endif /* _ASM_IA64_MMZONE_H */

