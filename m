From: Mike Rapoport <rppt@kernel.org>
Date: Sat, 27 Jun 2020 14:34:53 +0000
Subject: [PATCH 8/8] mm: move p?d_alloc_track to separate header file
Message-Id: <20200627143453.31835-9-rppt@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200627143453.31835-1-rppt@kernel.org>
In-Reply-To: <20200627143453.31835-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, Joerg Roedel <joro@8bytes.org>, Max Filippov <jcmvbkbc@gmail.com>, Mike Rapoport <rppt@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>, Stafford Horne <shorne@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Steven Rostedt <rostedt@goodmis.org>, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.orglinux

From: Joerg Roedel <jroedel@suse.de>

The functions are only used in two source files, both residing in mm/
subdirectory, so there is no need for them to be in the global <linux/mm.h>
header.  Move them to the new mm/pgalloc-track.h header and include it only
where needed.

[rppt: mv include/linux/pgalloc-track.h mm/]

Link: http://lkml.kernel.org/r/20200609120533.25867-1-joro@8bytes.org
Signed-off-by: Joerg Roedel <jroedel@suse.de>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Abdul Haleem <abdhalee@linux.vnet.ibm.com>
Cc: Satheesh Rajendran <sathnaga@linux.vnet.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Steven Rostedt (VMware) <rostedt@goodmis.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Christophe Leroy <christophe.leroy@csgroup.eu>
Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/mm.h | 45 ----------------------------------------
 mm/ioremap.c       |  2 ++
 mm/pgalloc-track.h | 51 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/vmalloc.c       |  1 +
 4 files changed, 54 insertions(+), 45 deletions(-)
 create mode 100644 mm/pgalloc-track.h

diff --git a/include/linux/mm.h b/include/linux/mm.h
index dc7b87310c10..5e878a3c7c57 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2093,51 +2093,11 @@ static inline pud_t *pud_alloc(struct mm_struct *mm, p4d_t *p4d,
 		NULL : pud_offset(p4d, address);
 }
 
-static inline p4d_t *p4d_alloc_track(struct mm_struct *mm, pgd_t *pgd,
-				     unsigned long address,
-				     pgtbl_mod_mask *mod_mask)
-
-{
-	if (unlikely(pgd_none(*pgd))) {
-		if (__p4d_alloc(mm, pgd, address))
-			return NULL;
-		*mod_mask |= PGTBL_PGD_MODIFIED;
-	}
-
-	return p4d_offset(pgd, address);
-}
-
-static inline pud_t *pud_alloc_track(struct mm_struct *mm, p4d_t *p4d,
-				     unsigned long address,
-				     pgtbl_mod_mask *mod_mask)
-{
-	if (unlikely(p4d_none(*p4d))) {
-		if (__pud_alloc(mm, p4d, address))
-			return NULL;
-		*mod_mask |= PGTBL_P4D_MODIFIED;
-	}
-
-	return pud_offset(p4d, address);
-}
-
 static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
 {
 	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
 		NULL: pmd_offset(pud, address);
 }
-
-static inline pmd_t *pmd_alloc_track(struct mm_struct *mm, pud_t *pud,
-				     unsigned long address,
-				     pgtbl_mod_mask *mod_mask)
-{
-	if (unlikely(pud_none(*pud))) {
-		if (__pmd_alloc(mm, pud, address))
-			return NULL;
-		*mod_mask |= PGTBL_PUD_MODIFIED;
-	}
-
-	return pmd_offset(pud, address);
-}
 #endif /* CONFIG_MMU */
 
 #if USE_SPLIT_PTE_PTLOCKS
@@ -2253,11 +2213,6 @@ static inline void pgtable_pte_page_dtor(struct page *page)
 	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd))? \
 		NULL: pte_offset_kernel(pmd, address))
 
-#define pte_alloc_kernel_track(pmd, address, mask)			\
-	((unlikely(pmd_none(*(pmd))) &&					\
-	  (__pte_alloc_kernel(pmd) || ({*(mask)|=PGTBL_PMD_MODIFIED;0;})))?\
-		NULL: pte_offset_kernel(pmd, address))
-
 #if USE_SPLIT_PMD_PTLOCKS
 
 static struct page *pmd_to_page(pmd_t *pmd)
diff --git a/mm/ioremap.c b/mm/ioremap.c
index 5ee3526f71b8..5fa1ab41d152 100644
--- a/mm/ioremap.c
+++ b/mm/ioremap.c
@@ -13,6 +13,8 @@
 #include <linux/export.h>
 #include <asm/cacheflush.h>
 
+#include "pgalloc-track.h"
+
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 static int __read_mostly ioremap_p4d_capable;
 static int __read_mostly ioremap_pud_capable;
diff --git a/mm/pgalloc-track.h b/mm/pgalloc-track.h
new file mode 100644
index 000000000000..1dcc865029a2
--- /dev/null
+++ b/mm/pgalloc-track.h
@@ -0,0 +1,51 @@
+/* SPDX-License-Identifier: GPL-2.0 */
+#ifndef _LINUX_PGALLLC_TRACK_H
+#define _LINUX_PGALLLC_TRACK_H
+
+#if defined(CONFIG_MMU)
+static inline p4d_t *p4d_alloc_track(struct mm_struct *mm, pgd_t *pgd,
+				     unsigned long address,
+				     pgtbl_mod_mask *mod_mask)
+{
+	if (unlikely(pgd_none(*pgd))) {
+		if (__p4d_alloc(mm, pgd, address))
+			return NULL;
+		*mod_mask |= PGTBL_PGD_MODIFIED;
+	}
+
+	return p4d_offset(pgd, address);
+}
+
+static inline pud_t *pud_alloc_track(struct mm_struct *mm, p4d_t *p4d,
+				     unsigned long address,
+				     pgtbl_mod_mask *mod_mask)
+{
+	if (unlikely(p4d_none(*p4d))) {
+		if (__pud_alloc(mm, p4d, address))
+			return NULL;
+		*mod_mask |= PGTBL_P4D_MODIFIED;
+	}
+
+	return pud_offset(p4d, address);
+}
+
+static inline pmd_t *pmd_alloc_track(struct mm_struct *mm, pud_t *pud,
+				     unsigned long address,
+				     pgtbl_mod_mask *mod_mask)
+{
+	if (unlikely(pud_none(*pud))) {
+		if (__pmd_alloc(mm, pud, address))
+			return NULL;
+		*mod_mask |= PGTBL_PUD_MODIFIED;
+	}
+
+	return pmd_offset(pud, address);
+}
+#endif /* CONFIG_MMU */
+
+#define pte_alloc_kernel_track(pmd, address, mask)			\
+	((unlikely(pmd_none(*(pmd))) &&					\
+	  (__pte_alloc_kernel(pmd) || ({*(mask)|=PGTBL_PMD_MODIFIED;0;})))?\
+		NULL: pte_offset_kernel(pmd, address))
+
+#endif /* _LINUX_PGALLLC_TRACK_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 5a2b55c8dd9a..5be3cf3b59de 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -41,6 +41,7 @@
 #include <asm/shmparam.h>
 
 #include "internal.h"
+#include "pgalloc-track.h"
 
 bool is_vmalloc_addr(const void *x)
 {
-- 
2.26.2
