From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 06 Oct 2004 06:43:19 +0000
Subject: [RFC/PATCH] pfn_valid more generic : ia64 part [2/2]
Message-Id: <41639407.9050504@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LinuxIA64 <linux-ia64@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>


This is ia64 + generic_arch/CONFIG_DISCONTIG part.
This patch doesn't cover all ia64 configration.

BTW, my previous e-mail was named "arch independent part [0/2]"....
it should be [1/2] , sorry.

Kame <kamezawa.hiroyu@jp.fujitsu.com>

---

 test-pfn-valid-kamezawa/arch/ia64/mm/discontig.c |    2 ++
 test-pfn-valid-kamezawa/arch/ia64/mm/init.c      |   12 ------------
 test-pfn-valid-kamezawa/include/asm-ia64/page.h  |    4 +++-
 3 files changed, 5 insertions(+), 13 deletions(-)

diff -puN include/asm-ia64/page.h~ia64_careful_pfn_valid include/asm-ia64/page.h
--- test-pfn-valid/include/asm-ia64/page.h~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/include/asm-ia64/page.h	2004-10-05 15:22:23.000000000 +0900
@@ -78,7 +78,9 @@ do {						\
 #define virt_addr_valid(kaddr)	pfn_valid(__pa(kaddr) >> PAGE_SHIFT)

 #ifdef CONFIG_VIRTUAL_MEM_MAP
-extern int ia64_pfn_valid (unsigned long pfn);
+#define CAREFUL_PFN_VALID 1
+#define  ia64_pfn_valid(x)	careful_pfn_valid(x)
 #else
 # define ia64_pfn_valid(pfn) 1
 #endif
diff -puN arch/ia64/mm/discontig.c~ia64_careful_pfn_valid arch/ia64/mm/discontig.c
--- test-pfn-valid/arch/ia64/mm/discontig.c~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/arch/ia64/mm/discontig.c	2004-10-05 15:22:23.000000000 +0900
@@ -475,6 +475,7 @@ void __init find_memory(void)
 	max_pfn = max_low_pfn;

 	find_initrd();
+	pfn_valid_init();
 }

 /**
@@ -692,4 +693,5 @@ void paging_init(void)
 	}

 	zero_page_memmap_ptr = virt_to_page(ia64_imva(empty_zero_page));
+	pfn_valid_setup();
 }
diff -puN arch/ia64/mm/init.c~ia64_careful_pfn_valid arch/ia64/mm/init.c
--- test-pfn-valid/arch/ia64/mm/init.c~ia64_careful_pfn_valid	2004-10-05 15:22:23.000000000 +0900
+++ test-pfn-valid-kamezawa/arch/ia64/mm/init.c	2004-10-05 15:22:23.000000000 +0900
@@ -455,18 +455,6 @@ memmap_init (unsigned long size, int nid
 }

 int
-ia64_pfn_valid (unsigned long pfn)
-{
-	char byte;
-	struct page *pg = pfn_to_page(pfn);
-
-	return     (__get_user(byte, (char *) pg) = 0)
-		&& ((((u64)pg & PAGE_MASK) = (((u64)(pg + 1) - 1) & PAGE_MASK))
-			|| (__get_user(byte, (char *) (pg + 1) - 1) = 0));
-}
-EXPORT_SYMBOL(ia64_pfn_valid);
-
-int
 find_largest_hole (u64 start, u64 end, void *arg)
 {
 	u64 *max_gap = arg;

_



