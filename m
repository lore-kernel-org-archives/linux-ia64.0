From: Prasad Joshi <prasadjoshi124@gmail.com>
Date: Fri, 18 Mar 2011 20:05:47 +0000
Subject: Re: [RFC][PATCH v3 17/22] mm, ia64: add gfp flags variant of pud,
Message-Id: <20110318200547.GR4746@prasad-kvm>
List-Id: <linux-ia64.vger.kernel.org>
References: <20110318195307.GH4746@prasad-kvm>
 <20110318195507.GI4746@prasad-kvm>
 <20110318195643.GJ4746@prasad-kvm>
 <20110318195754.GK4746@prasad-kvm>
 <20110318195926.GL4746@prasad-kvm>
 <20110318200045.GM4746@prasad-kvm>
 <20110318200150.GN4746@prasad-kvm>
 <20110318200254.GO4746@prasad-kvm>
 <20110318200401.GP4746@prasad-kvm>
 <20110318200452.GQ4746@prasad-kvm>
In-Reply-To: <20110318200452.GQ4746@prasad-kvm>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, prasadjoshi124@gmail.com, mitra@kqinfotech.com


- Added __pud_alloc_one which allows caller to specify the gfp_t flag.
   Like pud_alloc_one the function calls quicklist_alloc() and passes
   the given allocation flag.

- Changed pud_alloc_one to call __pud_alloc_one using GFP_KERNEL.

- Added similar changes for pte and pmd allocation functions.

- Helps in fixing the Bug 30702.

Signed-off-by: Prasad Joshi <prasadjoshi124@gmail.com>
Signed-off-by: Anand Mitra <mitra@kqinfotech.com>
---
 arch/ia64/include/asm/pgalloc.h |   24 +++++++++++++++++++++---
 1 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/pgalloc.h b/arch/ia64/include/asm/pgalloc.h
index 96a8d92..0e46e47 100644
--- a/arch/ia64/include/asm/pgalloc.h
+++ b/arch/ia64/include/asm/pgalloc.h
@@ -39,9 +39,15 @@ pgd_populate(struct mm_struct *mm, pgd_t * pgd_entry, pud_t * pud)
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
@@ -57,9 +63,15 @@ pud_populate(struct mm_struct *mm, pud_t * pud_entry, pmd_t * pmd)
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
@@ -95,10 +107,16 @@ static inline pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long addr)
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
-- 
1.7.0.4

