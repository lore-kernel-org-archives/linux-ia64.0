From: Horms <horms@verge.net.au>
Date: Wed, 14 Feb 2007 02:38:07 +0000
Subject: [PATCH] [IA64] Point saved_max_pfn to the max_pfn of the entire system
Message-Id: <20070214023806.GC24549@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Feb 13, 2007 at 06:25:34PM +0100, Bernhard Walle wrote:
> Hello,
> 
> * Zou Nan hai <nanhai.zou@intel.com> [2007-02-08 05:21]:
> >
> > 	This is reasonable.
> > 	So please apply the following patch to make saved_max_pfn point to
> > max_pfn of entire system.
> 
> So, as the patch works here also and it's necessary to make kdump
> working, I suggest including it mainline.

Agreed, below is a version of the patch for Linus' tree as of this morning.

-- 
Horms
  H: http://www.vergenet.net/~horms/
  W: http://www.valinux.co.jp/en/

[IA64] Point saved_max_pfn to the max_pfn of the entire system

	Please apply the following patch to make saved_max_pfn point to
max_pfn of entire system.

Signed-off-by: Zou Nan hai <nanhai.zou@intel.com>

Without this patch is so that vmcore is zero length on ia64.
This is because saved_max_pfn was wrongly being set to the
max_pfn of the crash kernel's address space, rather than the 
max_pfg on the physical memory of the machine - the whole purpose of
vmcore is to access physical memory that is not part of the
crash kernel's addresss space.

Updated for recent changes in Linus' tree.

Signed-off-by: Simon Horman <horms@verge.net.au>

 arch/ia64/kernel/efi.c   |    6 ++++++
 arch/ia64/mm/contig.c    |    5 -----
 arch/ia64/mm/discontig.c |    6 ------
 3 files changed, 6 insertions(+), 11 deletions(-)

Index: linux-2.6/arch/ia64/kernel/efi.c
=================================--- linux-2.6.orig/arch/ia64/kernel/efi.c	2007-02-14 11:15:11.000000000 +0900
+++ linux-2.6/arch/ia64/kernel/efi.c	2007-02-14 11:15:47.000000000 +0900
@@ -21,6 +21,7 @@
  *	Skip non-WB memory and ignore empty memory ranges.
  */
 #include <linux/module.h>
+#include <linux/bootmem.h>
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/types.h>
@@ -1009,6 +1010,11 @@
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
Index: linux-2.6/arch/ia64/mm/contig.c
=================================--- linux-2.6.orig/arch/ia64/mm/contig.c	2007-02-14 10:58:21.000000000 +0900
+++ linux-2.6/arch/ia64/mm/contig.c	2007-02-14 11:15:11.000000000 +0900
@@ -197,11 +197,6 @@
 
 	find_initrd();
 
-#ifdef CONFIG_CRASH_DUMP
-	/* If we are doing a crash dump, we still need to know the real mem
-	 * size before original memory map is reset. */
-	saved_max_pfn = max_pfn;
-#endif
 }
 
 #ifdef CONFIG_SMP
Index: linux-2.6/arch/ia64/mm/discontig.c
=================================--- linux-2.6.orig/arch/ia64/mm/discontig.c	2007-02-14 10:58:21.000000000 +0900
+++ linux-2.6/arch/ia64/mm/discontig.c	2007-02-14 11:15:11.000000000 +0900
@@ -480,12 +480,6 @@
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
