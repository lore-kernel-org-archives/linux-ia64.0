From: Dominik Dingel <dingel@linux.vnet.ibm.com>
Date: Thu, 28 May 2015 11:52:33 +0000
Subject: [PATCH 1/5] s390/mm: make hugepages_supported a boot time decision
Message-Id: <1432813957-46874-2-git-send-email-dingel@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

By dropping support for hugepages on machines which do not have
the hardware feature EDAT1, we fix a potential s390 KVM bug.

The bug would happen if a guest is backed by hugetlbfs (not supported currently),
but does not get pagetables with PGSTE.
This would lead to random memory overwrites.

Acked-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
---
 arch/s390/include/asm/page.h | 8 ++++----
 arch/s390/kernel/setup.c     | 2 ++
 arch/s390/mm/pgtable.c       | 2 ++
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/arch/s390/include/asm/page.h b/arch/s390/include/asm/page.h
index 53eacbd..0844b78 100644
--- a/arch/s390/include/asm/page.h
+++ b/arch/s390/include/asm/page.h
@@ -17,7 +17,10 @@
 #define PAGE_DEFAULT_ACC	0
 #define PAGE_DEFAULT_KEY	(PAGE_DEFAULT_ACC << 4)
 
-#define HPAGE_SHIFT	20
+#include <asm/setup.h>
+#ifndef __ASSEMBLY__
+
+extern unsigned int HPAGE_SHIFT;
 #define HPAGE_SIZE	(1UL << HPAGE_SHIFT)
 #define HPAGE_MASK	(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
@@ -27,9 +30,6 @@
 #define ARCH_HAS_PREPARE_HUGEPAGE
 #define ARCH_HAS_HUGEPAGE_CLEAR_FLUSH
 
-#include <asm/setup.h>
-#ifndef __ASSEMBLY__
-
 static inline void storage_key_init_range(unsigned long start, unsigned long end)
 {
 #if PAGE_DEFAULT_KEY
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index a5ea8bc..9ac282b 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -915,6 +915,8 @@ void __init setup_arch(char **cmdline_p)
 	 */
 	setup_hwcaps();
 
+	HPAGE_SHIFT = MACHINE_HAS_HPAGE ? 20 : 0;
+
 	/*
 	 * Create kernel page tables and switch to virtual addressing.
 	 */
diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
index b2c1542..f76791e 100644
--- a/arch/s390/mm/pgtable.c
+++ b/arch/s390/mm/pgtable.c
@@ -36,6 +36,8 @@
 #endif
 
 
+unsigned int HPAGE_SHIFT;
+
 unsigned long *crst_table_alloc(struct mm_struct *mm)
 {
 	struct page *page = alloc_pages(GFP_KERNEL, ALLOC_ORDER);
-- 
2.3.7

