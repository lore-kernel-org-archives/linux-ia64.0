From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 18:12:38 +0000
Subject: [RFC PATCH-tip 5/6] locking/rwsem: Enable spinning readers
Message-Id: <1465927959-39719-6-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

This patch enables readers to optimistically spin when the
rspin_threshold is non-zero. That threshold value should only
be set when the lock owners of the rwsem are unlikely to go to
sleep. Otherwise enabling reader spinning may make the performance
worse in some cases.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 kernel/locking/rwsem-xadd.c |   45 +++++++++++++++++++++++++++++++++++++-----
 1 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 689a138..be2a327 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -83,6 +83,12 @@
  *	 (2) WAITING_BIAS - ACTIVE_WRITE_BIAS < count < 0
  */
 
+static inline bool count_has_writer(long count)
+{
+	return (count < RWSEM_WAITING_BIAS) || ((count < 0) &&
+	       (count > RWSEM_WAITING_BIAS - RWSEM_ACTIVE_WRITE_BIAS));
+}
+
 /*
  * Initialize an rwsem:
  */
@@ -294,6 +300,25 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	}
 }
 
+/*
+ * Try to acquire read lock before the reader is put on wait queue
+ */
+static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+{
+	long count = atomic_long_read(&sem->count);
+
+	if (count_has_writer(count))
+		return false;
+	count = atomic_long_add_return_acquire(RWSEM_ACTIVE_READ_BIAS,
+					       &sem->count);
+	if (!count_has_writer(count))
+		return true;
+
+	/* Back out the change */
+	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
+	return false;
+}
+
 static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 {
 	struct task_struct *owner;
@@ -357,7 +382,8 @@ out:
 	return !rwsem_owner_is_reader(READ_ONCE(sem->owner));
 }
 
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+				  enum rwsem_waiter_type type)
 {
 	bool taken = false, can_spin;
 	int loopcnt;
@@ -385,10 +411,11 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		/*
 		 * Try to acquire the lock
 		 */
-		if (rwsem_try_write_lock_unqueued(sem)) {
-			taken = true;
+		taken = (type = RWSEM_WAITING_FOR_WRITE)
+		      ? rwsem_try_write_lock_unqueued(sem)
+		      : rwsem_try_read_lock_unqueued(sem);
+		if (taken)
 			break;
-		}
 
 		if (!can_spin && loopcnt)
 			loopcnt--;
@@ -425,7 +452,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 }
 
 #else
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+				  enum rwsem_waiter_type type)
 {
 	return false;
 }
@@ -454,6 +482,11 @@ struct rw_semaphore __sched * rwsem_down_read_failed(struct rw_semaphore *sem)
 	 */
 	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
 
+	/* do optimistic spinning and steal lock if possible */
+	if (sem->rspin_threshold_shift &&
+	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+		return sem;
+
 	/* set up my own style of waitqueue */
 	waiter.task = tsk;
 	waiter.type = RWSEM_WAITING_FOR_READ;
@@ -510,7 +543,7 @@ __rwsem_down_write_failed_common(struct rw_semaphore *sem, int state)
 	count = atomic_long_sub_return(RWSEM_ACTIVE_WRITE_BIAS, &sem->count);
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_optimistic_spin(sem))
+	if (rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
 		return sem;
 
 	/*
-- 
1.7.1

