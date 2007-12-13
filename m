From: "de Dinechin, Christophe (Integrity VM)"
Date: Thu, 13 Dec 2007 15:03:07 +0000
Subject: [PATCH] ia64: Avoid unnecessary TLB flushes when allocating memory
Message-Id: <7575980D7C4188408E8BDB171DA164B73A875A92A6@G3W1111.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Picco, Robert W." <robert.picco@hp.com>, "tony.luck@intel.com" <tony.luck@intel.com>

Improve performance of memory allocations on ia64 by avoiding a global TLB purge to purge a single page from the file cache. This happens whenever we evict a page from the buffer cache to make room for some other allocation.

Test case: Run 'find /usr -type f | xargs cat > /dev/null' in the background to fill the buffer cache, then run something that uses memory, e.g. 'gmake -j50 install'. Instrumentation showed that the number of global TLB purges went from a few millions down to about 170 over a 12 hours run of the above.

The performance impact is particularly noticeable under virtualization, because a virtual TLB is generally both larger and slower to purge than a physical one.

Signed-off-by: Christophe de Dinechin <ddd@hp.com>

---

diff --git a/arch/ia64/mm/tlb.c b/arch/ia64/mm/tlb.c
index 1682fc6..66ae9c4 100644
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -10,6 +10,7 @@
  *              IPI based ptc implementation and A-step IPI implementation.
  * Rohit Seth <rohit.seth@intel.com>
  * Ken Chen <kenneth.w.chen@intel.com>
+ * Christophe de Dinechin <ddd@hp.com>: Avoid ptc.e on memory allocation
  */
 #include <linux/module.h>
 #include <linux/init.h>
@@ -89,9 +90,16 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
 {
        static DEFINE_SPINLOCK(ptcg_lock);

-       if (mm != current->active_mm || !current->mm) {
-               flush_tlb_all();
-               return;
+       struct mm_struct *active_mm = current->active_mm;
+
+       if (mm != active_mm) {
+               /* Restore region IDs for mm */
+               if (mm && active_mm) {
+                       activate_context(mm);
+               } else {
+                       flush_tlb_all();
+                       return;
+               }
        }

        /* HW requires global serialization of ptc.ga.  */
@@ -107,6 +115,10 @@ ia64_global_tlb_purge (struct mm_struct *mm, unsigned long start,
                } while (start < end);
        }
        spin_unlock(&ptcg_lock);
+
+        if (mm != active_mm) {
+                activate_context(active_mm);
+        }
 }

 void
