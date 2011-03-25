From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 25 Mar 2011 20:51:48 +0000
Subject: [patch 01/23] ia64-build-fix.patch
Message-Id: <20110325204514.592066810@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 arch/ia64/include/asm/thread_info.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6-tip/arch/ia64/include/asm/thread_info.h
=================================--- linux-2.6-tip.orig/arch/ia64/include/asm/thread_info.h
+++ linux-2.6-tip/arch/ia64/include/asm/thread_info.h
@@ -91,7 +91,7 @@ struct thread_info {
 					     KERNEL_STACK_SIZE_ORDER);		\
 	struct task_struct *ret = page ? page_address(page) : NULL;		\
 										\
-	ret;
+	ret;								\
 })
 #define free_task_struct(tsk)	free_pages((unsigned long) (tsk), KERNEL_STACK_SIZE_ORDER)
 


