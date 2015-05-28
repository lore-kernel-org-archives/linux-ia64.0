From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:35 +0000
Subject: [PATCH 3/5] mm/hugetlb: remove arch_prepare/release_hugepage from arch headers
Message-Id: <1432813957-46874-4-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

Nobody used these hooks so they were removed from common code,
and can now be removed from the architectures.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/arm/include/asm/hugetlb.h     | 9 ---------
 arch/arm64/include/asm/hugetlb.h   | 9 ---------
 arch/ia64/include/asm/hugetlb.h    | 9 ---------
 arch/metag/include/asm/hugetlb.h   | 9 ---------
 arch/mips/include/asm/hugetlb.h    | 9 ---------
 arch/powerpc/include/asm/hugetlb.h | 9 ---------
 arch/sh/include/asm/hugetlb.h      | 9 ---------
 arch/sparc/include/asm/hugetlb.h   | 9 ---------
 arch/tile/include/asm/hugetlb.h    | 9 ---------
 arch/x86/include/asm/hugetlb.h     | 9 ---------
 10 files changed, 90 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 31bb7dc..7d26f6c 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -63,15 +63,6 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 734c17e..2fd9b14 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -96,15 +96,6 @@ static inline pte_t huge_pte_wrprotect(pte_t pte)
 	return pte_wrprotect(pte);
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index ff1377b..ef65f02 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -65,15 +65,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/metag/include/asm/hugetlb.h b/arch/metag/include/asm/hugetlb.h
index f730b39..905ed42 100644
--- a/arch/metag/include/asm/hugetlb.h
+++ b/arch/metag/include/asm/hugetlb.h
@@ -67,15 +67,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index 4a5bb54..982bc06 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -110,15 +110,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 4bbd3c8..7eac89b 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -168,15 +168,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index b788a9b..ef489a5 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -79,15 +79,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 	clear_bit(PG_dcache_clean, &page->flags);
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index 3130d76..139e711 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -78,15 +78,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index 1abd00c..2fac5be 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -94,15 +94,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index dab7a3a..f8a29d2 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -80,15 +80,6 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 	return *ptep;
 }
 
-static inline int arch_prepare_hugepage(struct page *page)
-{
-	return 0;
-}
-
-static inline void arch_release_hugepage(struct page *page)
-{
-}
-
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
-- 
2.3.7

