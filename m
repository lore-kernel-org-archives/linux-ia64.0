From: akpm@linux-foundation.org
Date: Tue, 06 Mar 2007 10:34:21 +0000
Subject: [patch 1/6] ia64: point saved_max_pfn to the max_pfn of the entire system
Message-Id: <200703061034.l26AYLSM019336@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Horms <horms@verge.net.au>

Make saved_max_pfn point to max_pfn of entire system.

Without this patch is so that vmcore is zero length on ia64.  This is
because saved_max_pfn was wrongly being set to the max_pfn of the crash
kernel's address space, rather than the max_pfg on the physical memory of
the machine - the whole purpose of vmcore is to access physical memory that
is not part of the crash kernel's addresss space.

Updated for recent changes in Linus' tree.

Signed-off-by: Simon Horman <horms@verge.net.au>
Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>
Sort-Of-Acked-By: Jay Lan <jlan@sgi.com>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/ia64/kernel/efi.c   |    6 ++++++
 arch/ia64/mm/contig.c    |    5 -----
 arch/ia64/mm/discontig.c |    6 ------
 3 files changed, 6 insertions(+), 11 deletions(-)

diff -puN arch/ia64/kernel/efi.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system arch/ia64/kernel/efi.c
--- a/arch/ia64/kernel/efi.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system
+++ a/arch/ia64/kernel/efi.c
@@ -21,6 +21,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/module.h>
+#include <linux/bootmem.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -1009,6 +1010,11 @@ efi_memmap_init(unsigned long *s, unsign
 		} else
 			ae = efi_md_end(md);
 
+#ifdef CONFIG_CRASH_DUMP
+		/* saved_max_pfn should ignore max_addr= command line arg */
+		if (saved_max_pfn < (ae >> PAGE_SHIFT))
+			saved_max_pfn = (ae >> PAGE_SHIFT);
+#endif
 		/* keep within max_addr= and min_addr= command line arg */
 		as = max(as, min_addr);
 		ae = min(ae, max_addr);
diff -puN arch/ia64/mm/contig.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system arch/ia64/mm/contig.c
--- a/arch/ia64/mm/contig.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system
+++ a/arch/ia64/mm/contig.c
@@ -197,11 +197,6 @@ find_memory (void)
 
 	find_initrd();
 
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is reset. */
-	saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP
diff -puN arch/ia64/mm/discontig.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system arch/ia64/mm/discontig.c
--- a/arch/ia64/mm/discontig.c~ia64-point-saved_max_pfn-to-the-max_pfn-of-the-entire-system
+++ a/arch/ia64/mm/discontig.c
@@ -480,12 +480,6 @@ void __init find_memory(void)
 	max_pfn = max_low_pfn;
 
 	find_initrd();
-
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is reset. */
-        saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP
_
