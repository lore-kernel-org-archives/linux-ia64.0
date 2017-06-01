From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:39:03 +0000
Subject: [PATCH v5 5/9] locking/rwsem: Enable readers spinning on writer
Message-Id: <1496338747-20398-6-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1496338747-20398-1-git-send-email-longman@redhat.com>
In-Reply-To: <1496338747-20398-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

This patch enables readers to optimistically spin on a rwsem when it
is owned by a writer instead of going to sleep directly. The key to
make this possible is the changes made to RWSEM_WAITING_BIAS that
enables us to check the status of the rwsem for read lock stealing
without taking the wait_lock.

The rwsem_can_spin_on_owner() function is extracted out
of rwsem_optimistic_spin() and is called directly by
rwsem_down_read_failed() and rwsem_down_write_failed().

On a 2-socket 36-core 72-thread x86-64 E5-2699 v3 system, a rwsem
microbenchmark was run with 36 locking threads (one/core) doing 250k
reader and writer lock/unlock operations each, the resulting locking
rates (avg of 3 runs) on a 4.12 based kernel were 520.1 Mop/s and
1760.2 Mop/s without and with the patch respectively. That was an
increase of about 238%.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 67 ++++++++++++++++++++++++++++++++++++---------
 1 file changed, 54 insertions(+), 13 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 4fb6cce..f82ce29 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -85,6 +85,12 @@
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
@@ -287,6 +293,25 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
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
@@ -356,16 +381,14 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 	return !rwsem_owner_is_reader(READ_ONCE(sem->owner));
 }
 
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+				  enum rwsem_waiter_type type)
 {
 	bool taken = false;
 
 	preempt_disable();
 
 	/* sem->wait_lock should not be held when doing optimistic spinning */
-	if (!rwsem_can_spin_on_owner(sem))
-		goto done;
-
 	if (!osq_lock(&sem->osq))
 		goto done;
 
@@ -380,10 +403,11 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
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
 
 		/*
 		 * When there's no owner, we might have preempted between the
@@ -417,7 +441,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 }
 
 #else
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+{
+	return false;
+}
+
+static inline bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+					 enum rwsem_waiter_type type)
 {
 	return false;
 }
@@ -434,7 +464,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 __visible
 struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 {
-	bool first_in_queue = false;
+	bool first_in_queue = false, can_spin;
 	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
@@ -444,14 +474,24 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 
 	/*
 	 * Undo read bias from down_read operation to stop active locking if:
-	 * 1) Optimistic spinners are present; or
-	 * 2) the wait_lock isn't free.
+	 * 1) Optimistic spinners are present;
+	 * 2) the wait_lock isn't free; or
+	 * 3) optimistic spinning is allowed.
 	 * Doing that after taking the wait_lock may otherwise block writer
 	 * lock stealing for too long impacting performance.
 	 */
-	if (rwsem_has_spinner(sem) || raw_spin_is_locked(&sem->wait_lock)) {
+	can_spin = rwsem_can_spin_on_owner(sem);
+	if (can_spin || rwsem_has_spinner(sem) ||
+	    raw_spin_is_locked(&sem->wait_lock)) {
 		atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
 		adjustment = 0;
+
+		/*
+		 * Do optimistic spinning and steal lock if possible.
+		 */
+		if (can_spin &&
+		    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+			return sem;
 	}
 
 	raw_spin_lock_irq(&sem->wait_lock);
@@ -509,7 +549,8 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	count = atomic_long_sub_return(RWSEM_ACTIVE_WRITE_BIAS, &sem->count);
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_optimistic_spin(sem))
+	if (rwsem_can_spin_on_owner(sem) &&
+	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
 		return sem;
 
 	/*
-- 
1.8.3.1

