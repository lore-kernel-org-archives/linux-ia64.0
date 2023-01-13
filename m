From: David Hildenbrand <david@redhat.com>
Date: Fri, 13 Jan 2023 17:10:25 +0000
Subject: [PATCH mm-unstable v1 25/26] xtensa/mm: support __HAVE_ARCH_PTE_SWP_EXCLUSIVE
Message-Id: <20230113171026.582290-26-david@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230113171026.582290-1-david@redhat.com>
In-Reply-To: <20230113171026.582290-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe <jgg@nvidia.com>, Mike Rapoport <rppt@linux.ibm.com>, Yang Shi <shy828301@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Nadav Amit <namit@vmware.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Xu <peterx@redhat.com>, linux-mm@kvack.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, David Hildenbrand <david@redhat.com>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>

Let's support __HAVE_ARCH_PTE_SWP_EXCLUSIVE by using bit 1. This
bit should be safe to use for our usecase.

Most importantly, we can still distinguish swap PTEs from PAGE_NONE PTEs
(see pte_present()) and don't use one of the two reserved attribute
masks (1101 and 1111). Attribute mask 1100 and 1110 now identify swap PTEs.

While at it, remove SWP_TYPE_BITS (not really helpful as it's not used in
the actual swap macros) and mask the type in __swp_entry().

Cc: Chris Zankel <chris@zankel.net>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/xtensa/include/asm/pgtable.h | 32 ++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index 5b5484d707b2..1025e2dc292b 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -96,7 +96,7 @@
  *		+- - - - - - - - - - - - - - - - - - - - -+
  *   (PAGE_NONE)|    PPN    | 0 | 00 | ADW | 01 | 11 | 11 |
  *		+-----------------------------------------+
- *   swap	|     index     |   type   | 01 | 11 | 00 |
+ *   swap	|     index     |   type   | 01 | 11 | e0 |
  *		+-----------------------------------------+
  *
  * For T1050 hardware and earlier the layout differs for present and (PAGE_NONE)
@@ -112,6 +112,7 @@
  *   RI         ring (0=privileged, 1=user, 2 and 3 are unused)
  *   CA		cache attribute: 00 bypass, 01 writeback, 10 writethrough
  *		(11 is invalid and used to mark pages that are not present)
+ *   e		exclusive marker in swap PTEs
  *   w		page is writable (hw)
  *   x		page is executable (hw)
  *   index      swap offset / PAGE_SIZE (bit 11-31: 21 bits -> 8 GB)
@@ -158,6 +159,9 @@
 #define _PAGE_DIRTY		(1<<7)	/* software: page dirty */
 #define _PAGE_ACCESSED		(1<<8)	/* software: page accessed (read) */
 
+/* We borrow bit 1 to store the exclusive marker in swap PTEs. */
+#define _PAGE_SWP_EXCLUSIVE	(1<<1)
+
 #ifdef CONFIG_MMU
 
 #define _PAGE_CHG_MASK	   (PAGE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
@@ -343,19 +347,37 @@ ptep_set_wrprotect(struct mm_struct *mm, unsigned long addr, pte_t *ptep)
 }
 
 /*
- * Encode and decode a swap and file entry.
+ * Encode/decode swap entries and swap PTEs. Swap PTEs are all PTEs that
+ * are !pte_none() && !pte_present().
  */
-#define SWP_TYPE_BITS		5
-#define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > SWP_TYPE_BITS)
+#define MAX_SWAPFILES_CHECK() BUILD_BUG_ON(MAX_SWAPFILES_SHIFT > 5)
 
 #define __swp_type(entry)	(((entry).val >> 6) & 0x1f)
 #define __swp_offset(entry)	((entry).val >> 11)
 #define __swp_entry(type,offs)	\
-	((swp_entry_t){((type) << 6) | ((offs) << 11) | \
+	((swp_entry_t){(((type) & 0x1f) << 6) | ((offs) << 11) | \
 	 _PAGE_CA_INVALID | _PAGE_USER})
 #define __pte_to_swp_entry(pte)	((swp_entry_t) { pte_val(pte) })
 #define __swp_entry_to_pte(x)	((pte_t) { (x).val })
 
+#define __HAVE_ARCH_PTE_SWP_EXCLUSIVE
+static inline int pte_swp_exclusive(pte_t pte)
+{
+	return pte_val(pte) & _PAGE_SWP_EXCLUSIVE;
+}
+
+static inline pte_t pte_swp_mkexclusive(pte_t pte)
+{
+	pte_val(pte) |= _PAGE_SWP_EXCLUSIVE;
+	return pte;
+}
+
+static inline pte_t pte_swp_clear_exclusive(pte_t pte)
+{
+	pte_val(pte) &= ~_PAGE_SWP_EXCLUSIVE;
+	return pte;
+}
+
 #endif /*  !defined (__ASSEMBLY__) */
 
 
-- 
2.39.0
