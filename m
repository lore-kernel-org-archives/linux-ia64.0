From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:30 +0000
Subject: [PATCH-tip v7 14/15] locking/rwsem: Make waiting writer to optimistically spin for the lock
Message-Id: <1508351431-22375-15-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

When waiting writers set the handoff bit, they went back to sleep. This
introduced a waiting period during which the rwsem could not be
acquired, but the designated waiter was not ready to acquire it. To
help eliminating this waiting period, the writer that set the handoff
bit will then optimistically spin for the rwsem instead of going to
sleep immediately.

The waiting writer in the front of the queue will also set the handoff
bit after it has slept at least once to make rwsem favor writers more
than readers.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 64 ++++++++++++++++++++++++++++++++-------------
 1 file changed, 46 insertions(+), 18 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index edb5ecc..42129fa 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -294,17 +294,28 @@ static inline int rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
 
 /*
  * Try to acquire write lock before the writer has been put on wait queue.
+ *
+ * The fwaiter flag can only be set by a waiting writer at the head of the
+ * wait queue. So the handoff flag can be ignored and cleared in this case.
  */
-static inline int rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
+static inline int rwsem_try_write_lock_unqueued(struct rw_semaphore *sem,
+						bool fwaiter)
 {
-	int old, count = atomic_read(&sem->count);
+	int old, new, count = atomic_read(&sem->count);
 
 	while (true) {
-		if (RWSEM_COUNT_LOCKED_OR_HANDOFF(count))
+		if (RWSEM_COUNT_LOCKED(count))
 			return 0;
 
-		old = atomic_cmpxchg_acquire(&sem->count, count,
-				count + RWSEM_WRITER_LOCKED);
+		new = count + RWSEM_WRITER_LOCKED;
+		if (RWSEM_COUNT_HANDOFF(count)) {
+			if (fwaiter)
+				new -= RWSEM_FLAG_WHANDOFF;
+			else
+				return 0;
+		}
+
+		old = atomic_cmpxchg_acquire(&sem->count, count, new);
 		if (old = count) {
 			rwsem_set_owner(sem);
 			return 1;
@@ -389,7 +400,7 @@ static noinline int rwsem_spin_on_owner(struct rw_semaphore *sem)
 }
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
-				  enum rwsem_waiter_type type)
+				  enum rwsem_waiter_type type, bool fwaiter)
 {
 	int taken = 0;
 	bool reader = (type = RWSEM_WAITING_FOR_READ);
@@ -401,7 +412,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 	preempt_disable();
 
 	/* sem->wait_lock should not be held when doing optimistic spinning */
-	if (!osq_lock(&sem->osq))
+	if (!fwaiter && !osq_lock(&sem->osq))
 		goto done;
 
 	if (rwsem_is_spin_disabled(sem))
@@ -425,7 +436,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 		 * Try to acquire the lock
 		 */
 		taken = reader ? rwsem_try_read_lock_unqueued(sem)
-			       : rwsem_try_write_lock_unqueued(sem);
+			       : rwsem_try_write_lock_unqueued(sem, fwaiter);
 
 		if (taken)
 			break;
@@ -474,7 +485,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 		 */
 		cpu_relax();
 	}
-	osq_unlock(&sem->osq);
+	if (!fwaiter)
+		osq_unlock(&sem->osq);
 done:
 	preempt_enable();
 	return taken > 0;
@@ -494,8 +506,9 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	return false;
 }
 
-static inline bool
-rwsem_optimistic_spin(struct rw_semaphore *sem, enum rwsem_waiter_type type)
+static inline bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+					 enum rwsem_waiter_type type,
+					 bool fwaiter)
 {
 	return false;
 }
@@ -541,7 +554,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		 * Do optimistic spinning and steal lock if possible.
 		 */
 		if (can_spin &&
-		    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+		    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ, false))
 			return sem;
 	}
 
@@ -627,7 +640,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 	/* do optimistic spinning and steal lock if possible */
 	if (rwsem_can_spin_on_owner(sem, false) &&
-	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
+	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE, false))
 		return sem;
 
 	/*
@@ -637,7 +650,6 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_WRITE;
 	waiter.waking = false;
-	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
 
@@ -691,14 +703,30 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 		waiter.waking = false;
 		raw_spin_unlock_irq(&sem->wait_lock);
+		schedule();
 
-		if (first && !RWSEM_COUNT_HANDOFF(count) &&
-		    time_after(jiffies, waiter.timeout))
+		if (!first)
+			goto relock;
+		/*
+		 * As writer can optimistically spin for the rwsem here,
+		 * we are setting the handoff bit after it has slept at
+		 * least once.
+		 */
+		if (!RWSEM_COUNT_HANDOFF(count))
 			atomic_or(RWSEM_FLAG_WHANDOFF, &sem->count);
 
-		schedule();
+		/*
+		 * Optimistically spin on the lock after the handoff bit is
+		 * set.
+		 */
+		if (rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE, true)) {
+			 raw_spin_lock_irq(&sem->wait_lock);
+			 if (list_is_singular(&sem->wait_list))
+				atomic_sub(RWSEM_FLAG_WAITERS, &sem->count);
+			 break;
+		}
+relock:
 		set_current_state(state);
-
 		raw_spin_lock_irq(&sem->wait_lock);
 		count = atomic_read(&sem->count);
 	}
-- 
1.8.3.1

