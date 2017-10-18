From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:17 +0000
Subject: [PATCH-tip v7 01/15] locking/rwsem: relocate rwsem_down_read_failed()
Message-Id: <1508351431-22375-2-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The rwsem_down_read_failed*() functions were relocted from above the
optimistic spinning section to below that section. This enables
them to use functions in that section in future patches. There is no
code change.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 150 ++++++++++++++++++++++----------------------
 1 file changed, 75 insertions(+), 75 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 1fefe6d..db5dedf 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -219,81 +219,6 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 }
 
 /*
- * Wait for the read lock to be granted
- */
-static inline struct rw_semaphore __sched *
-__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
-{
-	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
-	struct rwsem_waiter waiter;
-	DEFINE_WAKE_Q(wake_q);
-
-	waiter.task = current;
-	waiter.type = RWSEM_WAITING_FOR_READ;
-
-	raw_spin_lock_irq(&sem->wait_lock);
-	if (list_empty(&sem->wait_list))
-		adjustment += RWSEM_WAITING_BIAS;
-	list_add_tail(&waiter.list, &sem->wait_list);
-
-	/* we're now waiting on the lock, but no longer actively locking */
-	count = atomic_long_add_return(adjustment, &sem->count);
-
-	/*
-	 * If there are no active locks, wake the front queued process(es).
-	 *
-	 * If there are no writers and we are first in the queue,
-	 * wake our own waiter to join the existing active readers !
-	 */
-	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS &&
-	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
-		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
-
-	raw_spin_unlock_irq(&sem->wait_lock);
-	wake_up_q(&wake_q);
-
-	/* wait to be given the lock */
-	while (true) {
-		set_current_state(state);
-		if (!waiter.task)
-			break;
-		if (signal_pending_state(state, current)) {
-			raw_spin_lock_irq(&sem->wait_lock);
-			if (waiter.task)
-				goto out_nolock;
-			raw_spin_unlock_irq(&sem->wait_lock);
-			break;
-		}
-		schedule();
-	}
-
-	__set_current_state(TASK_RUNNING);
-	return sem;
-out_nolock:
-	list_del(&waiter.list);
-	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
-	raw_spin_unlock_irq(&sem->wait_lock);
-	__set_current_state(TASK_RUNNING);
-	return ERR_PTR(-EINTR);
-}
-
-__visible struct rw_semaphore * __sched
-rwsem_down_read_failed(struct rw_semaphore *sem)
-{
-	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE);
-}
-EXPORT_SYMBOL(rwsem_down_read_failed);
-
-__visible struct rw_semaphore * __sched
-rwsem_down_read_failed_killable(struct rw_semaphore *sem)
-{
-	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE);
-}
-EXPORT_SYMBOL(rwsem_down_read_failed_killable);
-
-/*
  * This function must be called with the sem->wait_lock held to prevent
  * race conditions between checking the rwsem wait list and setting the
  * sem->count accordingly.
@@ -488,6 +413,81 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 #endif
 
 /*
+ * Wait for the read lock to be granted
+ */
+static inline struct rw_semaphore __sched *
+__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
+{
+	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
+	struct rwsem_waiter waiter;
+	DEFINE_WAKE_Q(wake_q);
+
+	waiter.task = current;
+	waiter.type = RWSEM_WAITING_FOR_READ;
+
+	raw_spin_lock_irq(&sem->wait_lock);
+	if (list_empty(&sem->wait_list))
+		adjustment += RWSEM_WAITING_BIAS;
+	list_add_tail(&waiter.list, &sem->wait_list);
+
+	/* we're now waiting on the lock, but no longer actively locking */
+	count = atomic_long_add_return(adjustment, &sem->count);
+
+	/*
+	 * If there are no active locks, wake the front queued process(es).
+	 *
+	 * If there are no writers and we are first in the queue,
+	 * wake our own waiter to join the existing active readers !
+	 */
+	if (count = RWSEM_WAITING_BIAS ||
+	    (count > RWSEM_WAITING_BIAS &&
+	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
+		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
+
+	raw_spin_unlock_irq(&sem->wait_lock);
+	wake_up_q(&wake_q);
+
+	/* wait to be given the lock */
+	while (true) {
+		set_current_state(state);
+		if (!waiter.task)
+			break;
+		if (signal_pending_state(state, current)) {
+			raw_spin_lock_irq(&sem->wait_lock);
+			if (waiter.task)
+				goto out_nolock;
+			raw_spin_unlock_irq(&sem->wait_lock);
+			break;
+		}
+		schedule();
+	}
+
+	__set_current_state(TASK_RUNNING);
+	return sem;
+out_nolock:
+	list_del(&waiter.list);
+	if (list_empty(&sem->wait_list))
+		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+	raw_spin_unlock_irq(&sem->wait_lock);
+	__set_current_state(TASK_RUNNING);
+	return ERR_PTR(-EINTR);
+}
+
+__visible struct rw_semaphore * __sched
+rwsem_down_read_failed(struct rw_semaphore *sem)
+{
+	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE);
+}
+EXPORT_SYMBOL(rwsem_down_read_failed);
+
+__visible struct rw_semaphore * __sched
+rwsem_down_read_failed_killable(struct rw_semaphore *sem)
+{
+	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE);
+}
+EXPORT_SYMBOL(rwsem_down_read_failed_killable);
+
+/*
  * Wait until we successfully acquire the write lock
  */
 static inline struct rw_semaphore *
-- 
1.8.3.1

