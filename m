From: Prasad Joshi <prasadjoshi124@gmail.com>
Date: Mon, 14 Mar 2011 17:37:36 +0000
Subject: [RFC][PATCH v2 06/23] (ia64) __vmalloc: add gfp flags variant of pte,
Message-Id: <AANLkTi=6TB3FAb25cdaJUdTMsNMNp7ACAhgW6YVCv6ew@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, Prasad Joshi <prasadjoshi124@gmail.com>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

__vmalloc: propagating GFP allocation flag.

- adds functions to allow caller to pass the GFP flag for memory allocation
- helps in fixing the Bug 30702 (__vmalloc(GFP_NOFS) can callback
		  file system evict_inode).

Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
---
Chnagelog:
arch/ia64/include/asm/pgalloc.h |   24 +++++++++++++++++++++---
1 files changed, 21 insertions(+), 3 deletions(-)
---
diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 96a8d92..0e46e47 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -39,9 +39,15 @@ pgd_populate(struct mm_struct *mm, pgd_t *
pgd_entry, pud_t * pud)
 	pgd_val(*pgd_entry) = __pa(pud);
 }

+static inline pud_t *
+__pud_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pud_alloc_one(mm, addr, GFP_KERNEL);
 }

 static inline void pud_free(struct mm_struct *mm, pud_t *pud)
@@ -57,9 +63,15 @@ pud_populate(struct mm_struct *mm, pud_t *
pud_entry, pmd_t * pmd)
 	pud_val(*pud_entry) = __pa(pmd);
 }

+static inline pmd_t *
+__pmd_alloc_one(struct mm_struct *mm, unsigned long addr, gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long addr)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pmd_alloc_one(mm, addr, GFP_KERNEL);
 }

 static inline void pmd_free(struct mm_struct *mm, pmd_t *pmd)
@@ -95,10 +107,16 @@ static inline pgtable_t pte_alloc_one(struct
mm_struct *mm, unsigned long addr)
 	return page;
 }

+static inline pte_t *__pte_alloc_one_kernel(struct mm_struct *mm,
+					  unsigned long addr, gfp_t gfp_mask)
+{
+	return quicklist_alloc(0, gfp_mask, NULL);
+}
+
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
 					  unsigned long addr)
 {
-	return quicklist_alloc(0, GFP_KERNEL, NULL);
+	return __pte_alloc_one_kernel(mm, addr, GFP_KERNEL);
 }

 static inline void pte_free(struct mm_struct *mm, pgtable_t pte)
