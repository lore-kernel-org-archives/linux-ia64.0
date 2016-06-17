From: Waiman Long <Waiman.Long@hpe.com>
Date: Fri, 17 Jun 2016 15:41:35 +0000
Subject: [RFC PATCH-tip/locking/core v3 09/10] locking/rwsem: Enable reactivation of reader spinning
Message-Id: <1466178096-5623-10-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

Reader optimistic spinning will be disabled once the rspin_enabled
count reaches 0. After that, it cannot be re-enabled. This may cause
an eligible rwsem locked out of reader spinning because of a series
of unfortunate events.

This patch looks at the regular writer-on-writer spinning history. If
there are sufficient more successful spin attempts than failed ones,
it will try to reactivate reader spinning.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 include/linux/rwsem.h       |   12 ++++++++----
 kernel/locking/rwsem-xadd.c |   27 +++++++++++++++++++++++++--
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 8978f87..98284b4 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -32,7 +32,11 @@ struct rw_semaphore {
 	raw_spinlock_t wait_lock;
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	struct optimistic_spin_queue osq; /* spinner MCS lock */
-	int rspin_enabled;	/* protected by osq lock */
+	/*
+	 * Reader optimistic spinning fields protected by osq lock
+	 */
+	uint16_t rspin_enabled;
+	int16_t  wspin_cnt;
 
 	/*
 	 * Write owner. Used as a speculative check to see
@@ -74,10 +78,10 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 /*
  * Each successful reader spin will increment the rspin_enabled by 1.
  * Each unsuccessful spin, on the other hand, will decrement it by 2.
- * Reader spinning will be permanently disabled when it reaches 0.
+ * Reader spinning will be disabled when it reaches 0.
  */
 #ifndef RWSEM_RSPIN_ENABLED_DEFAULT
-# define RWSEM_RSPIN_ENABLED_DEFAULT	40
+# define RWSEM_RSPIN_ENABLED_DEFAULT	30
 #endif
 #define RWSEM_RSPIN_ENABLED_MAX		1024
 
@@ -87,7 +91,7 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 #define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL, \
-		.rspin_enabled = RWSEM_RSPIN_ENABLED_DEFAULT
+		.rspin_enabled = RWSEM_RSPIN_ENABLED_DEFAULT, .wspin_cnt = 0
 #else
 #define __RWSEM_OPT_INIT(lockname)
 #endif
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 42c8dda..c6b6105 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -108,6 +108,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	sem->owner = NULL;
 	sem->rspin_enabled = RWSEM_RSPIN_ENABLED_DEFAULT;
+	sem->wspin_cnt = 0;
 	osq_lock_init(&sem->osq);
 #endif
 }
@@ -466,10 +467,32 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 		if (taken && (sem->rspin_enabled < RWSEM_RSPIN_ENABLED_MAX)) {
 			sem->rspin_enabled++;
 		} else if (!taken) {
-			if  (sem->rspin_enabled > 2)
+			if  (sem->rspin_enabled > 2) {
 				sem->rspin_enabled -= 2;
-			else
+			} else if (sem->rspin_enabled) {
 				sem->rspin_enabled = 0;
+				/*
+				 * Reset wspin_cnt so that it won't get
+				 * re-enabled too soon.
+				 */
+				if (sem->wspin_cnt > -30)
+					sem->wspin_cnt = -30;
+			}
+		}
+	} else if (type = RWSEM_WAITING_FOR_WRITE) {
+		/*
+		 * Every 10 successful writer-on-writer spins more than failed
+		 * spins will increment rspin_enabled to encourage more
+		 * writer-on-reader spinning attempts.
+		 */
+		if (taken) {
+			if ((++sem->wspin_cnt >= 10) &&
+			    (sem->rspin_enabled < RWSEM_RSPIN_ENABLED_MAX)) {
+				sem->wspin_cnt = 0;
+				sem->rspin_enabled++;
+			}
+		} else if (sem->wspin_cnt > -100) {
+			sem->wspin_cnt--;
 		}
 	}
 	osq_unlock(&sem->osq);
-- 
1.7.1

