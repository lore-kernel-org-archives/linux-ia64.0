From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 07 Jan 2005 00:14:59 +0000
Subject: [PATCH] codingstyle cleanup for hugetlbpage.c
Message-Id: <200501061614.59320.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_DSd3BdtT0Dce85d"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_DSd3BdtT0Dce85d
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This one just makes all the function definitions consistent and fixes a long 
line.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_DSd3BdtT0Dce85d
Content-Type: text/plain;
  charset="us-ascii";
  name="hugetlbpage-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="hugetlbpage-cleanup.patch"

===== arch/ia64/mm/hugetlbpage.c 1.31 vs edited =====
--- 1.31/arch/ia64/mm/hugetlbpage.c	2004-12-22 01:32:06 -08:00
+++ edited/arch/ia64/mm/hugetlbpage.c	2005-01-06 15:57:28 -08:00
@@ -14,7 +14,6 @@
 #include <linux/mm.h>
 #include <linux/hugetlb.h>
 #include <linux/pagemap.h>
-#include <linux/smp_lock.h>
 #include <linux/slab.h>
 #include <linux/sysctl.h>
 #include <asm/mman.h>
@@ -22,10 +21,9 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-unsigned int hpage_shift=HPAGE_SHIFT_DEFAULT;
+unsigned int hpage_shift = HPAGE_SHIFT_DEFAULT;
 
-static pte_t *
-huge_pte_alloc (struct mm_struct *mm, unsigned long addr)
+static pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr)
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
@@ -43,8 +41,7 @@
 	return pte;
 }
 
-static pte_t *
-huge_pte_offset (struct mm_struct *mm, unsigned long addr)
+static pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr)
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
@@ -67,9 +64,9 @@
 
 #define mk_pte_huge(entry) { pte_val(entry) |= _PAGE_P; }
 
-static void
-set_huge_pte (struct mm_struct *mm, struct vm_area_struct *vma,
-	      struct page *page, pte_t * page_table, int write_access)
+static void set_huge_pte(struct mm_struct *mm, struct vm_area_struct *vma,
+			 struct page *page, pte_t * page_table,
+			 int write_access)
 {
 	pte_t entry;
 
@@ -84,6 +81,7 @@
 	set_pte(page_table, entry);
 	return;
 }
+
 /*
  * This function checks for proper alignment of input addr and len parameters.
  */
@@ -100,7 +98,7 @@
 }
 
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
-			struct vm_area_struct *vma)
+			    struct vm_area_struct *vma)
 {
 	pte_t *src_pte, *dst_pte, entry;
 	struct page *ptepage;
@@ -124,10 +122,9 @@
 	return -ENOMEM;
 }
 
-int
-follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		    struct page **pages, struct vm_area_struct **vmas,
-		    unsigned long *st, int *length, int i)
+int follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			struct page **pages, struct vm_area_struct **vmas,
+			unsigned long *st, int *length, int i)
 {
 	pte_t *ptep, pte;
 	unsigned long start = *st;
@@ -161,7 +158,8 @@
 	return i;
 }
 
-struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr, int write)
+struct page *follow_huge_addr(struct mm_struct *mm, unsigned long addr,
+			      int write)
 {
 	struct page *page;
 	pte_t *ptep;
@@ -176,12 +174,14 @@
 	page += ((addr & ~HPAGE_MASK) >> PAGE_SHIFT);
 	return page;
 }
+
 int pmd_huge(pmd_t pmd)
 {
 	return 0;
 }
-struct page *
-follow_huge_pmd(struct mm_struct *mm, unsigned long address, pmd_t *pmd, int write)
+
+struct page *follow_huge_pmd(struct mm_struct *mm, unsigned long address,
+			     pmd_t *pmd, int write)
 {
 	return NULL;
 }
@@ -191,7 +191,7 @@
  * are hugetlb region specific.
  */
 void hugetlb_free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *prev,
-	unsigned long start, unsigned long end)
+			   unsigned long start, unsigned long end)
 {
 	unsigned long first = start & HUGETLB_PGDIR_MASK;
 	unsigned long last = end + HUGETLB_PGDIR_SIZE - 1;
@@ -228,7 +228,8 @@
 	clear_page_range(tlb, first, last);
 }
 
-void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start, unsigned long end)
+void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
+			  unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -287,8 +288,9 @@
 				ret = -ENOMEM;
 				goto out;
 			}
-			ret = add_to_page_cache(page, mapping, idx, GFP_ATOMIC);
-			if (! ret) {
+			ret = add_to_page_cache(page, mapping, idx,
+						GFP_ATOMIC);
+			if (!ret) {
 				unlock_page(page);
 			} else {
 				hugetlb_put_quota(mapping);
@@ -303,8 +305,9 @@
 	return ret;
 }
 
-unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr, unsigned long len,
-		unsigned long pgoff, unsigned long flags)
+unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
+					unsigned long len, unsigned long pgoff,
+					unsigned long flags)
 {
 	struct vm_area_struct *vmm;
 

--Boundary-00=_DSd3BdtT0Dce85d--
