From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 16 May 2002 07:58:47 +0000
Subject: [Linux-ia64] [Patch] add pfn_pte() etc for 2.5.15
Message-Id: <marc-linux-ia64-105590701905581@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	To compile 2.5.15 the functions pfn_pte(), pte_pfn() etc., are
needed.

Appended is my attempt at defining these.  It seems to work on the
simulator.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.538   -> 1.539  
#	include/asm-ia64/page.h	1.6     -> 1.7    
#	include/asm-ia64/pgtable.h	1.12    -> 1.13   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/05/16	peterc@wombat.chubb.wattle.id.au	1.539
# Use pfn_xxx and pte_pfn functions for page table entry manipulations.
# --------------------------------------------
#
diff -Nru a/include/asm-ia64/page.h b/include/asm-ia64/page.h
--- a/include/asm-ia64/page.h	Thu May 16 17:58:23 2002
+++ b/include/asm-ia64/page.h	Thu May 16 17:58:23 2002
@@ -81,7 +81,7 @@
 # define virt_to_page(kaddr)	(mem_map + MAP_NR_DENSE(kaddr))
 # define page_to_phys(page)	((page - mem_map) << PAGE_SHIFT)
 #endif
-#define VALID_PAGE(page)	((page - mem_map) < max_mapnr)
+
 
 typedef union ia64_va {
 	struct {
@@ -122,6 +122,13 @@
 		order = 0;
 	return order;
 }
+
+#define pfn_to_page(pfn)	(mem_map + (pfn))
+#define page_to_pfn(page)	((unsigned long)((page) - mem_map))
+
+#define pfn_valid(pfn)		((pfn) < max_mapnr)
+#define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)
+
 
 # endif /* __KERNEL__ */
 #endif /* !__ASSEMBLY__ */
diff -Nru a/include/asm-ia64/pgtable.h b/include/asm-ia64/pgtable.h
--- a/include/asm-ia64/pgtable.h	Thu May 16 17:58:23 2002
+++ b/include/asm-ia64/pgtable.h	Thu May 16 17:58:23 2002
@@ -209,18 +209,16 @@
 /*
  * Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
+ * also a page-frame-number and protection to a page table entry, 
+ * and vice versa.
  */
-#define mk_pte(page,pgprot)						\
-({									\
-	pte_t __pte;							\
-									\
-	pte_val(__pte) = (page_to_phys(page)) | pgprot_val(pgprot);	\
-	__pte;								\
-})
 
-/* This takes a physical page address that is used by the remapping functions */
-#define mk_pte_phys(physpage, pgprot) \
-({ pte_t __pte; pte_val(__pte) = physpage + pgprot_val(pgprot); __pte; })
+#define pfn_pte(pfn,prot)  ({ pte_t __pte; pte_val(__pte) = ((pfn)<<PAGE_SHIFT) + pgprot_val(prot); __pte; })
+
+#define mk_pte(page, pgprot) pfn_pte(page_to_pfn(page), (pgprot))
+
+/* pte_pfn -- extract page frame number from pte */
+#define pte_pfn(pte) ((pte_val(pte) & _PFN_MASK) >>PAGE_SHIFT)
 
 #define pte_modify(_pte, newprot) \
 	(__pte((pte_val(_pte) & _PAGE_CHG_MASK) | pgprot_val(newprot)))

