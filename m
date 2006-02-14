From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 14 Feb 2006 11:04:48 +0000
Subject: [PATCH] unify pfn_to_page take3 [23/23] ia64 pfn_to_page
Message-Id: <43F1B950.4040403@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <43F1A753.2020003@jp.fujitsu.com>
In-Reply-To: <43F1A753.2020003@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-ia64@vger.kernel.org

ia64 has special config CONFIG_VIRTUAL_MEM_MAP.
CONFIG_DISCONTIGMEM=y && CONFIG_VIRTUAL_MEM_MAP!=y looks invalid.

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: testtree/include/asm-ia64/page.h
=================================--- testtree.orig/include/asm-ia64/page.h
+++ testtree/include/asm-ia64/page.h
@@ -104,17 +104,20 @@ extern int ia64_pfn_valid (unsigned long
  # define ia64_pfn_valid(pfn) 1
  #endif

+#ifdef CONFIG_VIRTUAL_MEM_MAP
+extern struct page *vmem_map;
+# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
+# define pfn_to_page(pfn)	(vmem_map + (pfn))
+#else
+#include <asm-generic/memory_model.h>
+#endif
+
  #ifdef CONFIG_FLATMEM
  # define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-# define page_to_pfn(page)	((unsigned long) (page - mem_map))
-# define pfn_to_page(pfn)	(mem_map + (pfn))
  #elif defined(CONFIG_DISCONTIGMEM)
-extern struct page *vmem_map;
  extern unsigned long min_low_pfn;
  extern unsigned long max_low_pfn;
  # define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
-# define page_to_pfn(page)	((unsigned long) (page - vmem_map))
-# define pfn_to_page(pfn)	(vmem_map + (pfn))
  #endif

  #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)

