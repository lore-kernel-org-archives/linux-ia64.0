From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:48:55 +0000
Subject: [PATCH 02/15] ia64/pv_ops: preparation: introduce ia64_set_rr0_to_rr4() to make kernel paravirtualiz
Message-Id: <1207716548181-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

make kernel paravirtualization friendly by introducing
ia64_set_rr0_to_rr4().
ia64/Xen will replace setting rr[0-4] with single hypercall later.

Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 include/asm-ia64/intrinsics.h  |   10 ++++++++++
 include/asm-ia64/mmu_context.h |    6 +-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/asm-ia64/intrinsics.h b/include/asm-ia64/intrinsics.h
index f1135b5..72f0383 100644
--- a/include/asm-ia64/intrinsics.h
+++ b/include/asm-ia64/intrinsics.h
@@ -18,6 +18,15 @@
 # include <asm/gcc_intrin.h>
 #endif
 
+#define ia64_set_rr0_to_rr4(val0, val1, val2, val3, val4)	\
+do {								\
+	ia64_set_rr(0x0000000000000000UL, (val0));		\
+	ia64_set_rr(0x2000000000000000UL, (val1));		\
+	ia64_set_rr(0x4000000000000000UL, (val2));		\
+	ia64_set_rr(0x6000000000000000UL, (val3));		\
+	ia64_set_rr(0x8000000000000000UL, (val4));		\
+} while (0)
+
 /*
  * Force an unresolved reference if someone tries to use
  * ia64_fetch_and_add() with a bad value.
@@ -183,4 +192,5 @@ extern long ia64_cmpxchg_called_with_bad_pointer (void);
 #endif /* !CONFIG_IA64_DEBUG_CMPXCHG */
 
 #endif
+
 #endif /* _ASM_IA64_INTRINSICS_H */
diff --git a/include/asm-ia64/mmu_context.h b/include/asm-ia64/mmu_context.h
index cef2400..040bc87 100644
--- a/include/asm-ia64/mmu_context.h
+++ b/include/asm-ia64/mmu_context.h
@@ -152,11 +152,7 @@ reload_context (nv_mm_context_t context)
 #  endif
 #endif
 
-	ia64_set_rr(0x0000000000000000UL, rr0);
-	ia64_set_rr(0x2000000000000000UL, rr1);
-	ia64_set_rr(0x4000000000000000UL, rr2);
-	ia64_set_rr(0x6000000000000000UL, rr3);
-	ia64_set_rr(0x8000000000000000UL, rr4);
+	ia64_set_rr0_to_rr4(rr0, rr1, rr2, rr3, rr4);
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 
-- 
1.5.3

