From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 22 Feb 2006 01:51:52 +0000
Subject: RE: IA64 non-contiguous memory space bugs
Message-Id: <200602220151.k1M1pqg09761@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <200602220132.k1M1Vxg09552@unix-os.sc.intel.com>
References: <20060222001359.GA23574@localhost.localdomain>
In-Reply-To: <20060222001359.GA23574@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'David Gibson' <david@gibson.dropbear.id.au>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

David Gibson wrote on Tuesday, February 21, 2006 4:14 PM
> Second problem is in the hugepage logic in free_pgtables()
> (mm/memory.c).  As far as I can tell it's complete crap, and only
> works by accident, for different accidental reasons on ppc64 and ia64,
> the only archs that have a non-trivial is_hugepage_only_range().
> Except that I'm not sure it does entirely work by accident on ia64:
> suppose a process has a hugepage mapping that begins some way after
> the beginning of the hugepage address range.  Before
> hugetlb_free_pgd_range() gets called on that area, it will be called
> on the next normal page VMA down - but with an end address at the
> beginning of the hugepage VMA and so extending into the hugepage
> address range.  I don't really understand the ia64 pagetable mapping
> stuff well enough to tell if that's dangerous or not.

Chen, Kenneth W wrote on Tuesday, February 21, 2006 5:32 PM
> I don't see any problem in the ia64 code.  The start and end address is
> what the vma specified.  Floor and ceiling is just a hint for free_pgtables()
> to free any left over page tables between vma holes (to prev and next).
> As far as I can tell, the code looks fine.


free_pgtables() has partial crap that the check of is_hugepage_only_range()
should be done on the entire vma range, not just the first hugetlb page.
Though, it's not possible to have a hugetlb vma while having normal page
instantiated inside that vma.  So the bug is mostly phantom.  For
correctness, it should be fixed.


--- linux-2.6.16-rc4/mm/memory.c.orig	2006-02-21 18:33:32.427186571 -0800
+++ linux-2.6.16-rc4/mm/memory.c	2006-02-21 18:37:22.414488441 -0800
@@ -270,6 +270,7 @@ void free_pgtables(struct mmu_gather **t
 	while (vma) {
 		struct vm_area_struct *next = vma->vm_next;
 		unsigned long addr = vma->vm_start;
+		unsigned long end = vma->vm_end;
 
 		/*
 		 * Hide vma from rmap and vmtruncate before freeing pgtables
@@ -277,8 +278,8 @@ void free_pgtables(struct mmu_gather **t
 		anon_vma_unlink(vma);
 		unlink_file_vma(vma);
 
-		if (is_hugepage_only_range(vma->vm_mm, addr, HPAGE_SIZE)) {
-			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
+		if (is_hugepage_only_range(vma->vm_mm, addr, end - addr)) {
+			hugetlb_free_pgd_range(tlb, addr, end
 				floor, next? next->vm_start: ceiling);
 		} else {
 			/*




