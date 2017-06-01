From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:39:00 +0000
Subject: [PATCH v5 2/9] locking/rwsem: Stop active read lock ASAP
Message-Id: <1496338747-20398-3-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1496338747-20398-1-git-send-email-longman@redhat.com>
In-Reply-To: <1496338747-20398-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

Currently, when down_read() fails, the active read locking isn't undone
until the rwsem_down_read_failed() function grabs the wait_lock. If the
wait_lock is contended, it may takes a while to get the lock. During
that period, writer lock stealing will be disabled because of the
active read lock.

This patch will release the active read lock ASAP when either the
optimisitic spinners are present or the trylock fails so that writer
lock stealing can happen sooner.

On a 2-socket 36-core x86-64 E5-2699 v3 system, a rwsem microbenchmark
was run with 36 locking threads (one/core) doing 250k reader and writer
lock/unlock operations each, the resulting locking rates (avg of 3
runs) on a 4.12 based kernel were 510.1 Mop/s and 520.1 Mop/s without
and with the patch respectively. That was an increase of about 2%.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 27 ++++++++++++++++++++++-----
 1 file changed, 22 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 13bdbc3..e6c2bd5 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -418,6 +418,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 __visible
 struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 {
+	bool first_in_queue = false;
 	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
@@ -425,13 +426,30 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
 
+	/*
+	 * Undo read bias from down_read operation to stop active locking if:
+	 * 1) Optimistic spinners are present; or
+	 * 2) the wait_lock isn't free.
+	 * Doing that after taking the wait_lock may otherwise block writer
+	 * lock stealing for too long impacting performance.
+	 */
+	if (rwsem_has_spinner(sem) || raw_spin_is_locked(&sem->wait_lock)) {
+		atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
+		adjustment = 0;
+	}
+
 	raw_spin_lock_irq(&sem->wait_lock);
-	if (list_empty(&sem->wait_list))
+	if (list_empty(&sem->wait_list)) {
 		adjustment += RWSEM_WAITING_BIAS;
+		first_in_queue = true;
+	}
 	list_add_tail(&waiter.list, &sem->wait_list);
 
-	/* we're now waiting on the lock, but no longer actively locking */
-	count = atomic_long_add_return(adjustment, &sem->count);
+	/* we're now waiting on the lock */
+	if (adjustment)
+		count = atomic_long_add_return(adjustment, &sem->count);
+	else
+		count = atomic_long_read(&sem->count);
 
 	/*
 	 * If there are no active locks, wake the front queued process(es).
@@ -440,8 +458,7 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	 * wake our own waiter to join the existing active readers !
 	 */
 	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS &&
-	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
+	    (count > RWSEM_WAITING_BIAS && first_in_queue))
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 
 	raw_spin_unlock_irq(&sem->wait_lock);
-- 
1.8.3.1

