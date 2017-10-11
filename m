From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:01:58 +0000
Subject: [PATCH v6 07/11] locking/rwsem: Implement lock handoff to prevent lock starvation
Message-Id: <1507744922-15196-8-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

Because of writer lock stealing, it is possible that a constant
stream of incoming writers will cause a waiting writer or reader to
wait indefinitely leading to lock starvation.

The mutex code has a lock handoff mechanism to prevent lock starvation.
This patch implements a similar lock handoff mechanism to disable
lock stealing and force lock handoff to the first waiter in the queue
after at least a 10ms waiting period. The waiting period is used to
avoid discouraging lock stealing too much to affect performance.

A rwsem microbenchmark was run for 5 seconds on a 2-socket 40-core
80-thread x86-64 system with a 4.14-rc2 based kernel and 60 write_lock
threads with 1us sleep critical section.

For the unpatched kernel, the locking rate was 15,519 kop/s. However
there were 28 threads with only 1 locking operation done (practically
starved). The thread with the highest locking rate had done more than
646k of them.

For the patched kernel, the locking rate dropped to 12,590 kop/s. The
number of locking operations done per thread had a range of 14,450 -
22,648. The rwsem became much more fair with the tradeoff of lower
overall throughput.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 98 +++++++++++++++++++++++++++++++++++++--------
 kernel/locking/rwsem-xadd.h | 22 ++++++----
 2 files changed, 96 insertions(+), 24 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index e3ab430..bca412f 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -70,6 +70,7 @@ struct rwsem_waiter {
 	struct list_head list;
 	struct task_struct *task;
 	enum rwsem_waiter_type type;
+	unsigned long timeout;
 };
 
 enum rwsem_wake_type {
@@ -79,6 +80,16 @@ enum rwsem_wake_type {
 };
 
 /*
+ * The minimum waiting time (10ms) in the wait queue before initiating the
+ * handoff protocol.
+ *
+ * The queue head waiter that is aborted (killed) will pass the handoff
+ * bit, if set, to the next waiter, but the bit has to be cleared when
+ * the wait queue becomes empty.
+ */
+#define RWSEM_WAIT_TIMEOUT	((HZ - 1)/100 + 1)
+
+/*
  * handle the lock release when processes blocked on it that can now run
  * - if we come here from up_xxxx(), then:
  *   - the 'active part' of count (&0x0000ffff) reached 0 (but may have changed)
@@ -128,6 +139,13 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		adjustment = RWSEM_READER_BIAS;
 		oldcount = atomic_fetch_add(adjustment, &sem->count);
 		if (unlikely(oldcount & RWSEM_WRITER_LOCKED)) {
+			/*
+			 * Initiate handoff to reader, if applicable.
+			 */
+			if (!(oldcount & RWSEM_FLAG_HANDOFF) &&
+			    time_after(jiffies, waiter->timeout))
+				adjustment -= RWSEM_FLAG_HANDOFF;
+
 			atomic_sub(adjustment, &sem->count);
 			return;
 		}
@@ -170,6 +188,12 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		adjustment -= RWSEM_FLAG_WAITERS;
 	}
 
+	/*
+	 * Clear the handoff flag
+	 */
+	if (woken && RWSEM_COUNT_IS_HANDOFF(atomic_read(&sem->count)))
+		adjustment -= RWSEM_FLAG_HANDOFF;
+
 	if (adjustment)
 		atomic_add(adjustment, &sem->count);
 }
@@ -179,15 +203,20 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
  * race conditions between checking the rwsem wait list and setting the
  * sem->count accordingly.
  */
-static inline bool rwsem_try_write_lock(int count, struct rw_semaphore *sem)
+static inline bool
+rwsem_try_write_lock(int count, struct rw_semaphore *sem, bool first)
 {
 	int new;
 
 	if (RWSEM_COUNT_IS_LOCKED(count))
 		return false;
 
+	if (!first && RWSEM_COUNT_IS_HANDOFF(count))
+		return false;
+
 	new = count + RWSEM_WRITER_LOCKED -
-	     (list_is_singular(&sem->wait_list) ? RWSEM_FLAG_WAITERS : 0);
+	     (list_is_singular(&sem->wait_list) ? RWSEM_FLAG_WAITERS : 0) -
+	     (count & RWSEM_FLAG_HANDOFF);
 
 	if (atomic_cmpxchg_acquire(&sem->count, count, new) = count) {
 		rwsem_set_owner(sem);
@@ -206,7 +235,7 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	int old, count = atomic_read(&sem->count);
 
 	while (true) {
-		if (RWSEM_COUNT_IS_LOCKED(count))
+		if (RWSEM_COUNT_IS_LOCKED_OR_HANDOFF(count))
 			return false;
 
 		old = atomic_cmpxchg_acquire(&sem->count, count,
@@ -362,6 +391,16 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 #endif
 
 /*
+ * This is safe to be called without holding the wait_lock.
+ */
+static inline bool
+rwsem_waiter_is_first(struct rw_semaphore *sem, struct rwsem_waiter *waiter)
+{
+	return list_first_entry(&sem->wait_list, struct rwsem_waiter, list)
+			= waiter;
+}
+
+/*
  * Wait for the read lock to be granted
  */
 static inline struct rw_semaphore __sched *
@@ -373,6 +412,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
+	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
 	if (list_empty(&sem->wait_list))
@@ -413,8 +453,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	return sem;
 out_nolock:
 	list_del(&waiter.list);
-	if (list_empty(&sem->wait_list))
-		atomic_add(-RWSEM_FLAG_WAITERS, &sem->count);
+	if (list_empty(&sem->wait_list)) {
+		int adjustment = -RWSEM_FLAG_WAITERS;
+
+		if (RWSEM_COUNT_IS_HANDOFF(atomic_read(&sem->count)))
+			adjustment -= RWSEM_FLAG_HANDOFF;
+		atomic_add(adjustment, &sem->count);
+	}
 	raw_spin_unlock_irq(&sem->wait_lock);
 	__set_current_state(TASK_RUNNING);
 	return ERR_PTR(-EINTR);
@@ -441,7 +486,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 __rwsem_down_write_failed_common(struct rw_semaphore *sem, int state)
 {
 	int count;
-	bool waiting = true; /* any queued threads before us */
+	bool first = false;	/* First one in queue */
 	struct rwsem_waiter waiter;
 	struct rw_semaphore *ret = sem;
 	DEFINE_WAKE_Q(wake_q);
@@ -456,17 +501,18 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 */
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_WRITE;
+	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
 
 	/* account for this before adding a new element to the list */
 	if (list_empty(&sem->wait_list))
-		waiting = false;
+		first = true;
 
 	list_add_tail(&waiter.list, &sem->wait_list);
 
 	/* we're now waiting on the lock, but no longer actively locking */
-	if (waiting) {
+	if (!first) {
 		count = atomic_read(&sem->count);
 
 		/*
@@ -498,19 +544,30 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	/* wait until we successfully acquire the lock */
 	set_current_state(state);
 	while (true) {
-		if (rwsem_try_write_lock(count, sem))
+		if (rwsem_try_write_lock(count, sem, first))
 			break;
+
 		raw_spin_unlock_irq(&sem->wait_lock);
 
 		/* Block until there are no active lockers. */
-		do {
+		for (;;) {
 			if (signal_pending_state(state, current))
 				goto out_nolock;
 
 			schedule();
 			set_current_state(state);
 			count = atomic_read(&sem->count);
-		} while (RWSEM_COUNT_IS_LOCKED(count));
+
+			if (!first)
+				first = rwsem_waiter_is_first(sem, &waiter);
+
+			if (!RWSEM_COUNT_IS_LOCKED(count))
+				break;
+
+			if (first && !RWSEM_COUNT_IS_HANDOFF(count) &&
+			    time_after(jiffies, waiter.timeout))
+				atomic_or(RWSEM_FLAG_HANDOFF, &sem->count);
+		}
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
@@ -524,10 +581,15 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	__set_current_state(TASK_RUNNING);
 	raw_spin_lock_irq(&sem->wait_lock);
 	list_del(&waiter.list);
-	if (list_empty(&sem->wait_list))
-		atomic_add(-RWSEM_FLAG_WAITERS, &sem->count);
-	else
+	if (list_empty(&sem->wait_list)) {
+		int adjustment = -RWSEM_FLAG_WAITERS;
+
+		if (RWSEM_COUNT_IS_HANDOFF(atomic_read(&sem->count)))
+			adjustment -= RWSEM_FLAG_HANDOFF;
+		atomic_add(adjustment, &sem->count);
+	} else {
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
+	}
 	raw_spin_unlock_irq(&sem->wait_lock);
 	wake_up_q(&wake_q);
 
@@ -553,7 +615,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
  * - up_read/up_write has decremented the active part of count if we come here
  */
 __visible
-struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
+struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, int count)
 {
 	unsigned long flags;
 	DEFINE_WAKE_Q(wake_q);
@@ -586,7 +648,9 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 	smp_rmb();
 
 	/*
-	 * If a spinner is present, it is not necessary to do the wakeup.
+	 * If a spinner is present and the handoff flag isn't set, it is
+	 * not necessary to do the wakeup.
+	 *
 	 * Try to do wakeup only if the trylock succeeds to minimize
 	 * spinlock contention which may introduce too much delay in the
 	 * unlock operation.
@@ -605,7 +669,7 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 	 * rwsem_has_spinner() is true, it will guarantee at least one
 	 * trylock attempt on the rwsem later on.
 	 */
-	if (rwsem_has_spinner(sem)) {
+	if (rwsem_has_spinner(sem) && !(count & RWSEM_FLAG_HANDOFF)) {
 		/*
 		 * The smp_rmb() here is to make sure that the spinner
 		 * state is consulted before reading the wait_lock.
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 9b30f0c..8cb12ed 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -74,7 +74,8 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
  *
  * Bit  0    - writer locked bit
  * Bit  1    - waiters present bit
- * Bits 2-7  - reserved
+ * Bit  2    - lock handoff bit
+ * Bits 3-7  - reserved
  * Bits 8-31 - 24-bit reader count
  *
  * atomic_fetch_add() is used to obtain reader lock, whereas atomic_cmpxchg()
@@ -82,19 +83,24 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
  */
 #define RWSEM_WRITER_LOCKED	0X00000001
 #define RWSEM_FLAG_WAITERS	0X00000002
+#define RWSEM_FLAG_HANDOFF	0X00000004
 #define RWSEM_READER_BIAS	0x00000100
 #define RWSEM_READER_SHIFT	8
 #define RWSEM_READER_MASK	(~((1U << RWSEM_READER_SHIFT) - 1))
 #define RWSEM_LOCK_MASK 	(RWSEM_WRITER_LOCKED|RWSEM_READER_MASK)
-#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_LOCKED|RWSEM_FLAG_WAITERS)
+#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_LOCKED|RWSEM_FLAG_WAITERS|\
+				 RWSEM_FLAG_HANDOFF)
 
 #define RWSEM_COUNT_IS_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
+#define RWSEM_COUNT_IS_HANDOFF(c)	((c) & RWSEM_FLAG_HANDOFF)
+#define RWSEM_COUNT_IS_LOCKED_OR_HANDOFF(c)	\
+	((c) & (RWSEM_LOCK_MASK|RWSEM_FLAG_HANDOFF))
 
 extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
+extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *, int count);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
 /*
@@ -165,7 +171,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 	tmp = atomic_add_return_release(-RWSEM_READER_BIAS, &sem->count);
 	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
 			= RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem);
+		rwsem_wake(sem, tmp);
 }
 
 /*
@@ -173,10 +179,12 @@ static inline void __up_read(struct rw_semaphore *sem)
  */
 static inline void __up_write(struct rw_semaphore *sem)
 {
+	int tmp;
+
 	rwsem_clear_owner(sem);
-	if (unlikely(atomic_fetch_add_release(-RWSEM_WRITER_LOCKED,
-			&sem->count) & RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem);
+	tmp = atomic_fetch_add_release(-RWSEM_WRITER_LOCKED, &sem->count);
+	if (unlikely(tmp & RWSEM_FLAG_WAITERS))
+		rwsem_wake(sem, tmp);
 }
 
 /*
-- 
1.8.3.1

