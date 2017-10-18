From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:28 +0000
Subject: [PATCH-tip v7 12/15] locking/rwsem: Eliminate redundant writer wakeup calls
Message-Id: <1508351431-22375-13-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

When tasks with short lock hold time acquire a rwsem consecutively,
it is possible that they all try to wake up the same waiting task at
unlock time. Beside the first wakeup, the rests are a waste of precious
CPU cycles. This patch limits the actual wakeup call to only one.

To simplify sychronization of the waking flag, the inner schedule
loop of __rwsem_down_write_failed_common() is removed and
raw_spin_lock_irq() is always called after wakeup.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index ba00795..3bdbf39 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -70,6 +70,7 @@ struct rwsem_waiter {
 	struct list_head list;
 	struct task_struct *task;
 	enum rwsem_waiter_type type;
+	bool waking;	/* For writer, protected by wait_lock */
 	unsigned long timeout;
 };
 
@@ -129,6 +130,12 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 	if (waiter->type = RWSEM_WAITING_FOR_WRITE) {
 		if (wake_type = RWSEM_WAKE_ANY) {
 			/*
+			 * No redundant wakeup if the waiter is waking up.
+			 */
+			if (waiter->waking)
+				return;
+
+			/*
 			 * Mark writer at the front of the queue for wakeup.
 			 * Until the task is actually later awoken later by
 			 * the caller, other writers are able to steal it.
@@ -136,6 +143,7 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			 * will notice the queued writer.
 			 */
 			wake_q_add(wake_q, waiter->task);
+			waiter->waking = true;
 		}
 
 		return;
@@ -600,6 +608,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 */
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_WRITE;
+	waiter.waking = false;
 	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
@@ -646,29 +655,24 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		if (rwsem_try_write_lock(count, sem, first))
 			break;
 
-		raw_spin_unlock_irq(&sem->wait_lock);
+		if (signal_pending_state(state, current))
+			goto out_nolock;
 
-		/* Block until there are no active lockers. */
-		for (;;) {
-			if (signal_pending_state(state, current))
-				goto out_nolock;
+		if (!first)
+			first = rwsem_waiter_is_first(sem, &waiter);
 
-			schedule();
-			set_current_state(state);
-			count = atomic_read(&sem->count);
+		waiter.waking = false;
+		raw_spin_unlock_irq(&sem->wait_lock);
 
-			if (!first)
-				first = rwsem_waiter_is_first(sem, &waiter);
+		if (first && !RWSEM_COUNT_HANDOFF(count) &&
+		    time_after(jiffies, waiter.timeout))
+			atomic_or(RWSEM_FLAG_WHANDOFF, &sem->count);
 
-			if (!RWSEM_COUNT_LOCKED(count))
-				break;
-
-			if (first && !RWSEM_COUNT_HANDOFF(count) &&
-			    time_after(jiffies, waiter.timeout))
-				atomic_or(RWSEM_FLAG_WHANDOFF, &sem->count);
-		}
+		schedule();
+		set_current_state(state);
 
 		raw_spin_lock_irq(&sem->wait_lock);
+		count = atomic_read(&sem->count);
 	}
 	__set_current_state(TASK_RUNNING);
 	list_del(&waiter.list);
@@ -678,7 +682,6 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 out_nolock:
 	__set_current_state(TASK_RUNNING);
-	raw_spin_lock_irq(&sem->wait_lock);
 	list_del(&waiter.list);
 	adjustment = 0;
 	if (list_empty(&sem->wait_list))
-- 
1.8.3.1

