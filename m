From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Sun, 05 Sep 2004 15:33:46 +0000
Subject: [PATCH] fix CONFIG_DISCONTIGMEM and CONFIG_VIRTUAL_MEMMAP
Message-Id: <200409050833.46503.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_aHzOBEIJjBr7zdA"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_aHzOBEIJjBr7zdA
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Looks like the patch that fixed Ian's problem introduced an ugly warning.  
Maybe we could just switch to requiring CONFIG_DISCONTIGMEM and 
CONFIG_VIRTUAL_MEMMAP for ia64 in general?  That would let us kill a lot of 
code and only have one code path, etc.  Benchmarks have shown that the 
overhead of CONFIG_DISCONTIGMEM is very difficult to measure (if you look at 
the code, the only added overhead in any fast path is an additional pointer 
dereference in alloc_pages).  CONFIG_VIRTUAL_MEMMAP is a little more 
expensive iirc, but still difficult to measure.

Jesse

--Boundary-00=_aHzOBEIJjBr7zdA
Content-Type: text/x-diff;
  charset="us-ascii";
  name="virtual-memmap+discontig-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="virtual-memmap+discontig-fix.patch"

===== include/asm-ia64/page.h 1.27 vs edited =====
--- 1.27/include/asm-ia64/page.h	2004-09-02 22:25:57 -07:00
+++ edited/include/asm-ia64/page.h	2004-09-05 08:28:38 -07:00
@@ -89,11 +89,11 @@
 #  define pfn_valid(pfn)       (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 #  define page_to_pfn(page)    ((unsigned long) (page - vmem_map))
 #  define pfn_to_page(pfn)     (vmem_map + (pfn))
-# endif
-#else /* !CONFIG_VIRTUAL_MEM_MAP */
-#define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#define page_to_pfn(page)	((unsigned long) (page - mem_map))
-#define pfn_to_page(pfn)	(mem_map + (pfn))
+# else /* !CONFIG_VIRTUAL_MEM_MAP */
+#  define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+#  define page_to_pfn(page)	((unsigned long) (page - mem_map))
+#  define pfn_to_page(pfn)	(mem_map + (pfn))
+# endif /* CONFIG_VIRTUAL_MEMMAP */
 #endif /* CONFIG_DISCONTIGMEM */
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)

--Boundary-00=_aHzOBEIJjBr7zdA--
