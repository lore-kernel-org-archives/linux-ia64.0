From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 16 Nov 2006 20:40:53 +0000
Subject: [PATCH] Fix DISCONTIGMEM without VIRTUAL_MEM_MAP
Message-Id: <20061116204052.GP19143@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


make allnoconfig currently fails to build because it selects DISCONTIGMEM
without VIRTUAL_MEM_MAP.  I see no particular reason this combination
ought to fail, so I fixed it by:

 - Including memory_model.h in all circumstances, except when both
   DISCONTIGMEM and VIRTUAL_MEM_MAP are enabled.
 - Defining ia64_pfn_valid() to 1 unless VIRTUAL_MEM_MAP is enabled

Signed-off-by: Matthew Wilcox <matthew@wil.cx>

diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 947cb72..485759b 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -101,7 +101,7 @@ #define virt_addr_valid(kaddr)	pfn_valid
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 extern int ia64_pfn_valid (unsigned long pfn);
-#elif defined(CONFIG_FLATMEM)
+#else
 # define ia64_pfn_valid(pfn) 1
 #endif
 
@@ -110,12 +110,11 @@ extern struct page *vmem_map;
 #ifdef CONFIG_DISCONTIGMEM
 # define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
+#else
+# include <asm-generic/memory_model.h>
 #endif
-#endif
-
-#if defined(CONFIG_FLATMEM) || defined(CONFIG_SPARSEMEM)
-/* FLATMEM always configures mem_map (mem_map = vmem_map if necessary) */
-#include <asm-generic/memory_model.h>
+#else
+# include <asm-generic/memory_model.h>
 #endif
 
 #ifdef CONFIG_FLATMEM

