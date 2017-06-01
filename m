From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:39:06 +0000
Subject: [PATCH v5 8/9] locking/rwsem: Enable count-based spinning on reader
Message-Id: <1496338747-20398-9-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1496338747-20398-1-git-send-email-longman@redhat.com>
In-Reply-To: <1496338747-20398-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

When the rwsem is owned by reader, writers stop optimistic spinning
simply because there is no easy way to figure out if all the readers
are actively running or not. However, there are scenarios where
the readers are unlikely to sleep and optimistic spinning can help
performance.

This patch provides a simple mechanism for spinning on a reader-owned
rwsem. It is a loop count threshold based spinning where the count
will get reset whenenver the the rwsem count value changes indicating
that the rwsem is still active. There is another maximum count value
that limits that maximum number of spinnings that can happen.

When the loop or max counts reach 0, a bit will be set in the owner
field to indicate that no more optimistic spinning should be done on
this rwsem until it becomes writer owned.

The spinning threshold and maximum values can be overridden by
architecture specific rwsem.h header file, if necessary. The current
default threshold value is 1024 iterations.

On a 2-socket 36-core 72-thread x86-64 E5-2699 v3 system, a rwsem
microbenchmark was run with 36 locking threads (one/core) doing 250k
reader and writer lock/unlock operations each, the resulting locking
rates (avg of 3 runs) on a 4.12 based kernel were 1760.2 Mop/s and
5439.0 Mop/s without and with the patch respectively. That was an
increase of about 209%.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 72 ++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 61 insertions(+), 11 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 7d030a2..a571bec 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -133,6 +133,22 @@ enum rwsem_wake_type {
 };
 
 /*
+ * Reader-owned rwsem spinning threshold and maximum value
+ *
+ * This threshold and maximum values can be overridden by architecture
+ * specific value. The loop count will be reset whenenver the rwsem count
+ * value changes. The max value constrains the total number of reader-owned
+ * lock spinnings that can happen.
+ */
+#ifdef	ARCH_RWSEM_RSPIN_THRESHOLD
+# define RWSEM_RSPIN_THRESHOLD	ARCH_RWSEM_RSPIN_THRESHOLD
+# define RWSEM_RSPIN_MAX	ARCH_RWSEM_RSPIN_MAX
+#else
+# define RWSEM_RSPIN_THRESHOLD	(1 << 10)
+# define RWSEM_RSPIN_MAX	(1 << 14)
+#endif
+
+/*
  * handle the lock release when processes blocked on it that can now run
  * - if we come here from up_xxxx(), then:
  *   - the 'active part' of count (&0x0000ffff) reached 0 (but may have changed)
@@ -324,9 +340,9 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	owner = READ_ONCE(sem->owner);
 	if (!rwsem_owner_is_writer(owner)) {
 		/*
-		 * Don't spin if the rwsem is readers owned.
+		 * Don't spin if the rspin disable bit is set.
 		 */
-		ret = !rwsem_owner_is_reader(owner);
+		ret = !rwsem_owner_is_spin_disabled(owner);
 		goto done;
 	}
 
@@ -389,6 +405,10 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 				  enum rwsem_waiter_type type)
 {
 	bool taken = false;
+	int owner_state;	/* Lock owner state */
+	int rspin_cnt = RWSEM_RSPIN_THRESHOLD;
+	int rspin_max = RWSEM_RSPIN_MAX;
+	long old_count = 0;
 
 	preempt_disable();
 
@@ -396,14 +416,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 	if (!osq_lock(&sem->osq))
 		goto done;
 
+	if (rwsem_is_spin_disabled(sem))
+		rspin_cnt = 0;
+
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
 	 *  1) the owning writer isn't running; or
-	 *  2) readers own the lock as we can't determine if they are
-	 *     actively running or not.
+	 *  2) readers own the lock and reader spinning count has reached 0.
 	 */
-	while (rwsem_spin_on_owner(sem) > 0) {
+	while ((owner_state = rwsem_spin_on_owner(sem)) >= 0) {
 		/*
 		 * Try to acquire the lock
 		 */
@@ -414,6 +436,33 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 			break;
 
 		/*
+		 * We only decremnt the rspin_cnt when the lock is owned
+		 * by readers (owner_state = 0). In which case,
+		 * rwsem_spin_on_owner() will essentially be a no-op
+		 * and we will be spinning in this main loop. The spinning
+		 * count will be reset whenever the rwsem count value
+		 * changes.
+		 */
+		if (!owner_state) {
+			long count;
+
+			if (!rspin_cnt || !rspin_max) {
+				if (!rwsem_is_spin_disabled(sem))
+					rwsem_set_spin_disable(sem);
+				break;
+			}
+
+			count = atomic_long_read(&sem->count);
+			if (count != old_count) {
+				old_count = count;
+				rspin_cnt = RWSEM_RSPIN_THRESHOLD;
+			} else {
+				rspin_cnt--;
+			}
+			rspin_max--;
+		}
+
+		/*
 		 * When there's no owner, we might have preempted between the
 		 * owner acquiring the lock and setting the owner field. If
 		 * we're an RT task that will live-lock because we won't let
@@ -468,7 +517,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 __visible
 struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 {
-	bool first_in_queue = false, can_spin;
+	bool first_in_queue = false;
 	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
@@ -476,6 +525,9 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
 
+	if (!rwsem_can_spin_on_owner(sem))
+		goto enqueue;
+
 	/*
 	 * Undo read bias from down_read operation to stop active locking if:
 	 * 1) Optimistic spinners are present;
@@ -484,20 +536,18 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	 * Doing that after taking the wait_lock may otherwise block writer
 	 * lock stealing for too long impacting performance.
 	 */
-	can_spin = rwsem_can_spin_on_owner(sem);
-	if (can_spin || rwsem_has_spinner(sem) ||
-	    raw_spin_is_locked(&sem->wait_lock)) {
+	if (rwsem_has_spinner(sem) || raw_spin_is_locked(&sem->wait_lock)) {
 		atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
 		adjustment = 0;
 
 		/*
 		 * Do optimistic spinning and steal lock if possible.
 		 */
-		if (can_spin &&
-		    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+		if (rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
 			return sem;
 	}
 
+enqueue:
 	raw_spin_lock_irq(&sem->wait_lock);
 	if (list_empty(&sem->wait_list)) {
 		adjustment += RWSEM_WAITING_BIAS;
-- 
1.8.3.1

