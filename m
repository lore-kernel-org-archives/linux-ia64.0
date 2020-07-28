From: Nicholas Piggin <npiggin@gmail.com>
Date: Tue, 28 Jul 2020 03:33:49 +0000
Subject: [PATCH 08/24] ia64: use asm-generic/mmu_context.h for no-op implementations
Message-Id: <20200728033405.78469-9-npiggin@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200728033405.78469-1-npiggin@gmail.com>
In-Reply-To: <20200728033405.78469-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arch@vger.kernel.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/ia64/include/asm/mmu_context.h | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/arch/ia64/include/asm/mmu_context.h b/arch/ia64/include/asm/mmu_context.h
index 2da0e2eb036b..87a0d5bc11ef 100644
--- a/arch/ia64/include/asm/mmu_context.h
+++ b/arch/ia64/include/asm/mmu_context.h
@@ -49,11 +49,6 @@ DECLARE_PER_CPU(u8, ia64_need_tlb_flush);
 extern void mmu_context_init (void);
 extern void wrap_mmu_context (struct mm_struct *mm);
 
-static inline void
-enter_lazy_tlb (struct mm_struct *mm, struct task_struct *tsk)
-{
-}
-
 /*
  * When the context counter wraps around all TLBs need to be flushed because
  * an old context number might have been reused. This is signalled by the
@@ -116,6 +111,7 @@ get_mmu_context (struct mm_struct *mm)
  * Initialize context number to some sane value.  MM is guaranteed to be a
  * brand-new address-space, so no TLB flushing is needed, ever.
  */
+#define init_new_context init_new_context
 static inline int
 init_new_context (struct task_struct *p, struct mm_struct *mm)
 {
@@ -123,12 +119,6 @@ init_new_context (struct task_struct *p, struct mm_struct *mm)
 	return 0;
 }
 
-static inline void
-destroy_context (struct mm_struct *mm)
-{
-	/* Nothing to do.  */
-}
-
 static inline void
 reload_context (nv_mm_context_t context)
 {
@@ -178,11 +168,10 @@ activate_context (struct mm_struct *mm)
 	} while (unlikely(context != mm->context));
 }
 
-#define deactivate_mm(tsk,mm)	do { } while (0)
-
 /*
  * Switch from address space PREV to address space NEXT.
  */
+#define activate_mm activate_mm
 static inline void
 activate_mm (struct mm_struct *prev, struct mm_struct *next)
 {
@@ -196,5 +185,7 @@ activate_mm (struct mm_struct *prev, struct mm_struct *next)
 
 #define switch_mm(prev_mm,next_mm,next_task)	activate_mm(prev_mm, next_mm)
 
+#include <asm-generic/mmu_context.h>
+
 # endif /* ! __ASSEMBLY__ */
 #endif /* _ASM_IA64_MMU_CONTEXT_H */
-- 
2.23.0
