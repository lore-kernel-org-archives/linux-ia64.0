From: "de Dinechin, Christophe (Manageability Solns)"
Date: Wed, 14 Mar 2007 16:50:24 +0000
Subject: [PATCH] Avoiding global TLB purges when allocating memory
Message-Id: <83F79A7ADD078044B2E58CB97FB5857163009B@G3W0637.americas.hpqcorp.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The patch below improves performance when the system is under memory
pressure, by avoiding a TLB purge (broadcast on all processors) just to
purge a single page. This case is frequently seen when the system tries
to evict buffer cache memory to make room for something else.

An easy reproducer is to run 'find /usr -type f | xargs cat > /dev/null'
to fill the buffer cache on a more or less continuous basis, while doing
a gmake -j50 install on a 4-way box to keep allocating memory.
Instrumentation showed that the number of global TLB purges went from a
few millions down to about 170 over a 12 hours run.

Opinions?


Regards,
Christophe

diff -Naur linux-2.6.20.3/arch/ia64/mm/tlb.c
linux-2.6.20.3-ptce-avoidance/arch/ia64/mm/tlb.c
--- linux-2.6.20.3/arch/ia64/mm/tlb.c	2007-03-13 19:27:08.000000000
+0100
+++ linux-2.6.20.3-ptce-avoidance/arch/ia64/mm/tlb.c	2007-03-14
23:32:59.000000000 +0100
@@ -10,6 +10,7 @@
  *              IPI based ptc implementation and A-step IPI
implementation.
  * Rohit Seth <rohit.seth@intel.com>
  * Ken Chen <kenneth.w.chen@intel.com>
+ * Christophe de Dinechin <ddd@hp.com>: Avoid ptc.e on memory
allocation
  */
 #include <linux/module.h>
 #include <linux/init.h>
@@ -89,9 +90,16 @@
 {
 	static DEFINE_SPINLOCK(ptcg_lock);
 
-	if (mm != current->active_mm || !current->mm) {
-		flush_tlb_all();
-		return;
+	struct mm_struct *active_mm = current->active_mm;
+
+	if (mm != active_mm) {
+		/* Restore region IDs for mm */
+		if (mm && active_mm) {
+			activate_context(mm);
+		} else {
+			flush_tlb_all();
+			return;
+		}
 	}
 
 	/* HW requires global serialization of ptc.ga.  */
@@ -107,6 +115,10 @@
 		} while (start < end);
 	}
 	spin_unlock(&ptcg_lock);
+
+        if (mm != active_mm) {
+                activate_context(active_mm);
+        }
 }
 
 void
