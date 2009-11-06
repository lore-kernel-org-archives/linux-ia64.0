From: Thomas Gleixner <tglx@linutronix.de>
Date: Fri, 06 Nov 2009 22:42:01 +0000
Subject: [patch 12/16] ia64: Replace old style lock initializer
Message-Id: <20091106223806.892617900@linutronix.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091106223547.784916750@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

SPIN_LOCK_UNLOCKED is deprecated. Use __SPIN_LOCK_UNLOCKED instead.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/include/asm/rwsem.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/arch/ia64/include/asm/rwsem.h
=================================--- linux-2.6.orig/arch/ia64/include/asm/rwsem.h
+++ linux-2.6/arch/ia64/include/asm/rwsem.h
@@ -47,7 +47,7 @@ struct rw_semaphore {
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
 #define __RWSEM_INITIALIZER(name) \
-	{ RWSEM_UNLOCKED_VALUE, SPIN_LOCK_UNLOCKED, \
+	{ RWSEM_UNLOCKED_VALUE, __SPIN_LOCK_UNLOCKED((name).wait_lock), \
 	  LIST_HEAD_INIT((name).wait_list) }
 
 #define DECLARE_RWSEM(name) \


