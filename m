From: Jason Uhlenkott <jasonuhl@sgi.com>
Date: Sun, 24 Oct 2004 00:47:15 +0000
Subject: [PATCH] fix pgtable.h comments
Message-Id: <20041024004715.GA391294@dragonfly.csd.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Remove some statements from comments in <asm-ia64/pgtable.h> whose
correctness is page size dependent.

Signed-off-by: Jason Uhlenkott <jasonuhl@sgi.com>

--- a/include/asm-ia64/pgtable.h	2004-10-23 16:56:50.000000000 -0700
+++ b/include/asm-ia64/pgtable.h	2004-10-23 17:31:12.000000000 -0700
@@ -6,7 +6,7 @@
  * the IA-64 page table tree.
  *
  * This hopefully works with any (fixed) IA-64 page-size, as defined
- * in <asm/page.h> (currently 8192).
+ * in <asm/page.h>.
  *
  * Copyright (C) 1998-2004 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
@@ -309,15 +309,15 @@
 }
 
 /* The offset in the 1-level directory is given by the 3 region bits
-   (61..63) and the seven level-1 bits (33-39).  */
+   (61..63) and the level-1 bits.  */
 static inline pgd_t*
 pgd_offset (struct mm_struct *mm, unsigned long address)
 {
 	return mm->pgd + pgd_index(address);
 }
 
-/* In the kernel's mapped region we have a full 43 bit space available and completely
-   ignore the region number (since we know its in region number 5). */
+/* In the kernel's mapped region we completely ignore the region number
+   (since we know it's in region number 5). */
 #define pgd_offset_k(addr) \
 	(init_mm.pgd + (((addr) >> PGDIR_SHIFT) & (PTRS_PER_PGD - 1)))
 
