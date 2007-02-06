From: akpm@linux-foundation.org
Date: Tue, 06 Feb 2007 00:20:00 +0000
Subject: [patch 02/13] IA64: virt_to_page() can be called with NULL arg
Message-Id: <200702060021.l160L3b6004184@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Kirill Korotaev <dev@openvz.org>

It does not return NULL when arg is NULL.

Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-off-by: Kirill Korotaev <dev@openvz.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/asm-ia64/pgalloc.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff -puN include/asm-ia64/pgalloc.h~ia64-virt_to_page-can-be-called-with-null-arg include/asm-ia64/pgalloc.h
--- a/include/asm-ia64/pgalloc.h~ia64-virt_to_page-can-be-called-with-null-arg
+++ a/include/asm-ia64/pgalloc.h
@@ -137,7 +137,8 @@ pmd_populate_kernel(struct mm_struct *mm
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	return virt_to_page(pgtable_quicklist_alloc());
+	void *pg = pgtable_quicklist_alloc();
+	return pg ? virt_to_page(pg) : NULL;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
_
