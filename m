From: Kirill Korotaev <dev@openvz.org>
Date: Mon, 18 Dec 2006 12:11:34 +0000
Subject: [PATCH] IA64: virt_to_page() can be called with NULL arg
Message-Id: <45868576.30100@openvz.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, linux-ia64@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, devel@openvz.org

[IA64] virt_to_page() cannot be called with NULL (mainstream bug)

It does not return NULL when arg is NULL.

Signed-Off-By: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Signed-Off-By: Kirill Korotaev <dev@openvz.org>

--- linus-2.6.git/include/asm-ia64/pgalloc.h.orig	2006-12-18 14:59:09.000000000 +0300
+++ linus-2.6.git/include/asm-ia64/pgalloc.h	2006-12-18 15:07:44.000000000 +0300
@@ -137,7 +137,8 @@ pmd_populate_kernel(struct mm_struct *mm
 static inline struct page *pte_alloc_one(struct mm_struct *mm,
 					 unsigned long addr)
 {
-	return virt_to_page(pgtable_quicklist_alloc());
+	void *pg = pgtable_quicklist_alloc();
+	return pg ? virt_to_page(pg) : NULL;
 }
 
 static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
