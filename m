From: Jack Steiner <steiner@sgi.com>
Date: Sat, 27 Dec 2003 14:27:22 +0000
Subject: [PATCH] - ia64_ctx.lock deadlock
Message-Id: <marc-linux-ia64-107253552523782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I hit a deadlock involving the ia64_ctx.lock. The lock
may be taken in interrupt context to process an IPI from smp_flush_tlb_mm.

Here is a patch:


--- linux_base/include/asm-ia64/mmu_context.h	Fri Dec 26 11:06:35 2003
+++ linux/include/asm-ia64/mmu_context.h	Sat Dec 27 08:19:35 2003
@@ -95,12 +95,13 @@
 static inline mm_context_t
 get_mmu_context (struct mm_struct *mm)
 {
+	unsigned long flags;
 	mm_context_t context = mm->context;
 
 	if (context)
 		return context;
 
-	spin_lock(&ia64_ctx.lock);
+	spin_lock_irqsave(&ia64_ctx.lock, flags);
 	{
 		/* re-check, now that we've got the lock: */
 		context = mm->context;
@@ -110,7 +111,7 @@
 			mm->context = context = ia64_ctx.next++;
 		}
 	}
-	spin_unlock(&ia64_ctx.lock);
+	spin_unlock_irqrestore(&ia64_ctx.lock, flags);
 	return context;
 }
 
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


