From: Mike Rapoport <rppt@kernel.org>
Date: Fri, 04 Jun 2021 06:49:16 +0000
Subject: [PATCH v2 9/9] mm: replace CONFIG_FLAT_NODE_MEM_MAP with CONFIG_FLATMEM
Message-Id: <20210604064916.26580-10-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210604064916.26580-1-rppt@kernel.org>
In-Reply-To: <20210604064916.26580-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Jonathan Corbet <corbet@lwn.net>, Matt Turner <mattst88@gmail.com>, Mike Rapoport <rppt@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Richard Henderson <rth@twiddle.net>, Vineet Gupta <vgupta@synopsys.com>, kexec@lists.infradead.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

From: Mike Rapoport <rppt@linux.ibm.com>

After removal of the DISCONTIGMEM memory model the FLAT_NODE_MEM_MAP
configuration option is equivalent to FLATMEM.

Drop CONFIG_FLAT_NODE_MEM_MAP and use CONFIG_FLATMEM instead.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/mmzone.h | 4 ++--
 kernel/crash_core.c    | 2 +-
 mm/Kconfig             | 4 ----
 mm/page_alloc.c        | 6 +++---
 mm/page_ext.c          | 2 +-
 5 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index acdc51c7b259..1d5cafe5ccc3 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -777,7 +777,7 @@ typedef struct pglist_data {
 	struct zonelist node_zonelists[MAX_ZONELISTS];
 
 	int nr_zones; /* number of populated zones in this node */
-#ifdef CONFIG_FLAT_NODE_MEM_MAP	/* means !SPARSEMEM */
+#ifdef CONFIG_FLATMEM	/* means !SPARSEMEM */
 	struct page *node_mem_map;
 #ifdef CONFIG_PAGE_EXTENSION
 	struct page_ext *node_page_ext;
@@ -867,7 +867,7 @@ typedef struct pglist_data {
 
 #define node_present_pages(nid)	(NODE_DATA(nid)->node_present_pages)
 #define node_spanned_pages(nid)	(NODE_DATA(nid)->node_spanned_pages)
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
+#ifdef CONFIG_FLATMEM
 #define pgdat_page_nr(pgdat, pagenr)	((pgdat)->node_mem_map + (pagenr))
 #else
 #define pgdat_page_nr(pgdat, pagenr)	pfn_to_page((pgdat)->node_start_pfn + (pagenr))
diff --git a/kernel/crash_core.c b/kernel/crash_core.c
index 53eb8bc6026d..2b8446ea7105 100644
--- a/kernel/crash_core.c
+++ b/kernel/crash_core.c
@@ -483,7 +483,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	VMCOREINFO_OFFSET(page, compound_head);
 	VMCOREINFO_OFFSET(pglist_data, node_zones);
 	VMCOREINFO_OFFSET(pglist_data, nr_zones);
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
+#ifdef CONFIG_FLATMEM
 	VMCOREINFO_OFFSET(pglist_data, node_mem_map);
 #endif
 	VMCOREINFO_OFFSET(pglist_data, node_start_pfn);
diff --git a/mm/Kconfig b/mm/Kconfig
index bffe4bd859f3..ded98fb859ab 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -55,10 +55,6 @@ config FLATMEM
 	def_bool y
 	depends on !SPARSEMEM || FLATMEM_MANUAL
 
-config FLAT_NODE_MEM_MAP
-	def_bool y
-	depends on !SPARSEMEM
-
 #
 # SPARSEMEM_EXTREME (which is the default) does some bootmem
 # allocations when sparse_init() is called.  If this cannot
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 8f08135d3eb4..f039736541eb 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6444,7 +6444,7 @@ static void __meminit zone_init_free_lists(struct zone *zone)
 	}
 }
 
-#if !defined(CONFIG_FLAT_NODE_MEM_MAP)
+#if !defined(CONFIG_FLATMEM)
 /*
  * Only struct pages that correspond to ranges defined by memblock.memory
  * are zeroed and initialized by going through __init_single_page() during
@@ -7241,7 +7241,7 @@ static void __init free_area_init_core(struct pglist_data *pgdat)
 	}
 }
 
-#ifdef CONFIG_FLAT_NODE_MEM_MAP
+#ifdef CONFIG_FLATMEM
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 {
 	unsigned long __maybe_unused start = 0;
@@ -7289,7 +7289,7 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 }
 #else
 static void __ref alloc_node_mem_map(struct pglist_data *pgdat) { }
-#endif /* CONFIG_FLAT_NODE_MEM_MAP */
+#endif /* CONFIG_FLATMEM */
 
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 static inline void pgdat_set_deferred_range(pg_data_t *pgdat)
diff --git a/mm/page_ext.c b/mm/page_ext.c
index df6f74aac8e1..293b2685fc48 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -191,7 +191,7 @@ void __init page_ext_init_flatmem(void)
 	panic("Out of memory");
 }
 
-#else /* CONFIG_FLAT_NODE_MEM_MAP */
+#else /* CONFIG_FLATMEM */
 
 struct page_ext *lookup_page_ext(const struct page *page)
 {
-- 
2.28.0
