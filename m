From: Waiman Long <Waiman.Long@hpe.com>
Date: Thu, 18 Aug 2016 21:11:07 +0000
Subject: [RFC PATCH-tip v4 05/10] locking/rwsem: move down rwsem_down_read_failed function
Message-Id: <1471554672-38662-6-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

Move the rwsem_down_read_failed() function down to below the
optimistic spinning section before enabling optimistic spinning for
the readers. It is because the rwsem_down_read_failed() function will
call rwsem_optimistic_spin() in later patch.

There is no change in code.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 kernel/locking/rwsem-xadd.c |  116 +++++++++++++++++++++---------------------
 1 files changed, 58 insertions(+), 58 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 4654624..6b5bd6e 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -218,64 +218,6 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 }
 
 /*
- * Wait for the read lock to be granted
- */
-__visible
-struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
-{
-	long count, adjustment = 0;
-	struct rwsem_waiter waiter;
-	struct task_struct *tsk = current;
-	WAKE_Q(wake_q);
-
-	/*
-	 * Undo read bias from down_read operation to stop active locking.
-	 * Doing that after taking the wait_lock may block writer lock
-	 * stealing for too long impacting system performance.
-	 */
-	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
-
-	waiter.task = tsk;
-	waiter.type = RWSEM_WAITING_FOR_READ;
-
-	raw_spin_lock_irq(&sem->wait_lock);
-	if (list_empty(&sem->wait_list))
-		adjustment = RWSEM_WAITING_BIAS;
-	list_add_tail(&waiter.list, &sem->wait_list);
-
-	/* we're now waiting on the lock */
-	if (adjustment)
-		count = atomic_long_add_return(adjustment, &sem->count);
-	else
-		count = atomic_long_read(&sem->count);
-
-	/*
-	 * If there are no active locks, wake the front queued process(es).
-	 *
-	 * If there are no writers and we are first in the queue,
-	 * wake our own waiter to join the existing active readers !
-	 */
-	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS && adjustment))
-		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
-
-	raw_spin_unlock_irq(&sem->wait_lock);
-	wake_up_q(&wake_q);
-
-	/* wait to be given the lock */
-	while (true) {
-		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
-		if (!waiter.task)
-			break;
-		schedule();
-	}
-
-	__set_task_state(tsk, TASK_RUNNING);
-	return sem;
-}
-EXPORT_SYMBOL(rwsem_down_read_failed);
-
-/*
  * This function must be called with the sem->wait_lock held to prevent
  * race conditions between checking the rwsem wait list and setting the
  * sem->count accordingly.
@@ -517,6 +459,64 @@ static inline bool reader_spinning_enabled(struct rw_semaphore *sem)
 #endif
 
 /*
+ * Wait for the read lock to be granted
+ */
+__visible
+struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
+{
+	long count, adjustment = 0;
+	struct rwsem_waiter waiter;
+	struct task_struct *tsk = current;
+	WAKE_Q(wake_q);
+
+	/*
+	 * Undo read bias from down_read operation to stop active locking.
+	 * Doing that after taking the wait_lock may block writer lock
+	 * stealing for too long impacting system performance.
+	 */
+	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
+
+	waiter.task = tsk;
+	waiter.type = RWSEM_WAITING_FOR_READ;
+
+	raw_spin_lock_irq(&sem->wait_lock);
+	if (list_empty(&sem->wait_list))
+		adjustment = RWSEM_WAITING_BIAS;
+	list_add_tail(&waiter.list, &sem->wait_list);
+
+	/* we're now waiting on the lock */
+	if (adjustment)
+		count = atomic_long_add_return(adjustment, &sem->count);
+	else
+		count = atomic_long_read(&sem->count);
+
+	/*
+	 * If there are no active locks, wake the front queued process(es).
+	 *
+	 * If there are no writers and we are first in the queue,
+	 * wake our own waiter to join the existing active readers !
+	 */
+	if (count = RWSEM_WAITING_BIAS ||
+	    (count > RWSEM_WAITING_BIAS && adjustment))
+		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
+
+	raw_spin_unlock_irq(&sem->wait_lock);
+	wake_up_q(&wake_q);
+
+	/* wait to be given the lock */
+	while (true) {
+		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
+		if (!waiter.task)
+			break;
+		schedule();
+	}
+
+	__set_task_state(tsk, TASK_RUNNING);
+	return sem;
+}
+EXPORT_SYMBOL(rwsem_down_read_failed);
+
+/*
  * Wait until we successfully acquire the write lock
  */
 static inline struct rw_semaphore *
-- 
1.7.1

