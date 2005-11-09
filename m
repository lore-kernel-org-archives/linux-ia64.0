From: Dean Roe <roe@sgi.com>
Date: Wed, 09 Nov 2005 20:25:06 +0000
Subject: [PATCH] - Make pfn_valid more precise for SGI Altix systems
Message-Id: <20051109202506.GA4152@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A single SGI Altix system can be divided into multiple partitions,
each running their own instance of the Linux kernel.  pfn_valid()
is currently not optimal for any but the first partition, since it
does not compare the pfn with min_low_pfn before calling the more
costly ia64_pfn_valid().

	Signed-off-by: Dean Roe <roe@sgi.com>



Index: linux-ia64-test/arch/ia64/kernel/ia64_ksyms.c
=================================--- linux-ia64-test.orig/arch/ia64/kernel/ia64_ksyms.c	2005-11-09 14:10:17.473464250 -0600
+++ linux-ia64-test/arch/ia64/kernel/ia64_ksyms.c	2005-11-09 14:10:50.800226042 -0600
@@ -42,6 +42,7 @@
 
 #ifdef CONFIG_VIRTUAL_MEM_MAP
 #include <linux/bootmem.h>
+EXPORT_SYMBOL(min_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 EXPORT_SYMBOL(max_low_pfn);	/* defined by bootmem.c, but not exported by generic code */
 #endif
 
Index: linux-ia64-test/include/asm-ia64/page.h
=================================--- linux-ia64-test.orig/include/asm-ia64/page.h	2005-11-09 14:10:17.484205369 -0600
+++ linux-ia64-test/include/asm-ia64/page.h	2005-11-09 14:10:50.803155438 -0600
@@ -112,8 +112,9 @@
 # define pfn_to_page(pfn)	(mem_map + (pfn))
 #elif defined(CONFIG_DISCONTIGMEM)
 extern struct page *vmem_map;
+extern unsigned long min_low_pfn;
 extern unsigned long max_low_pfn;
-# define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
+# define pfn_valid(pfn)		(((pfn) >= min_low_pfn) && ((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
 #endif

