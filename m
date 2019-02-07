From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:16 +0000
Subject: [PATCH-tip 12/22] locking/rwsem: Implement lock handoff to prevent lock starvation
Message-Id: <1549566446-27967-13-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

Because of writer lock stealing, it is possible that a constant
stream of incoming writers will cause a waiting writer or reader to
wait indefinitely leading to lock starvation.

The mutex code has a lock handoff mechanism to prevent lock starvation.
This patch implements a similar lock handoff mechanism to disable
lock stealing and force lock handoff to the first waiter in the queue
after at least a 5ms waiting period. The waiting period is used to
avoid discouraging lock stealing too much to affect performance.

A rwsem microbenchmark was run for 8 seconds on a 4-socket 56-core
128-thread x86-64 system with a v5.0 based kernel and 112 write_lock
threads with 5us sleep critical section.

Before the patch, the min/mean/max numbers of locking operations for
the locking threads were 1/7,708/542,988. After the patch, the figures
became 6,031/7,267/9,476. It can be seen that the rwsem became much more
fair, though there was a slight drop of about 6% in the mean locking
operations done which was a tradeoff of having better fairness.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/lock_events_list.h |   2 +
 kernel/locking/rwsem-xadd.c       | 110 +++++++++++++++++++++++++++++++-------
 kernel/locking/rwsem-xadd.h       |  23 +++++---
 3 files changed, 109 insertions(+), 26 deletions(-)

diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
index c33c5df..4cde507 100644
--- a/kernel/locking/lock_events_list.h
+++ b/kernel/locking/lock_events_list.h
@@ -62,6 +62,8 @@
 LOCK_EVENT(rwsem_rlock)		/* # of read locks acquired		*/
 LOCK_EVENT(rwsem_rlock_fast)	/* # of fast read locks acquired	*/
 LOCK_EVENT(rwsem_rlock_fail)	/* # of failed read lock acquisitions	*/
+LOCK_EVENT(rwsem_rlock_handoff)	/* # of read lock handoffs		*/
 LOCK_EVENT(rwsem_wlock)		/* # of write locks acquired		*/
 LOCK_EVENT(rwsem_wlock_fail)	/* # of failed write lock acquisitions	*/
+LOCK_EVENT(rwsem_wlock_handoff)	/* # of write lock handoffs		*/
 #endif /* CONFIG_RWSEM_XCHGADD_ALGORITHM */
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 18a414e..12b1d61 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -74,6 +74,7 @@ struct rwsem_waiter {
 	struct list_head list;
 	struct task_struct *task;
 	enum rwsem_waiter_type type;
+	unsigned long timeout;
 };
 
 enum rwsem_wake_type {
@@ -83,6 +84,12 @@ enum rwsem_wake_type {
 };
 
 /*
+ * The minimum waiting time (5ms) in the wait queue before initiating the
+ * handoff protocol.
+ */
+#define RWSEM_WAIT_TIMEOUT	((HZ - 1)/200 + 1)
+
+/*
  * handle the lock release when processes blocked on it that can now run
  * - if we come here from up_xxxx(), then the RWSEM_FLAG_WAITERS bit must
  *   have been set.
@@ -132,6 +139,15 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		adjustment = RWSEM_READER_BIAS;
 		oldcount = atomic_long_fetch_add(adjustment, &sem->count);
 		if (unlikely(oldcount & RWSEM_WRITER_MASK)) {
+			/*
+			 * Initiate handoff to reader, if applicable.
+			 */
+			if (!(oldcount & RWSEM_FLAG_HANDOFF) &&
+			    time_after(jiffies, waiter->timeout)) {
+				adjustment -= RWSEM_FLAG_HANDOFF;
+				lockevent_inc(rwsem_rlock_handoff);
+			}
+
 			atomic_long_sub(adjustment, &sem->count);
 			return;
 		}
@@ -180,6 +196,12 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		adjustment -= RWSEM_FLAG_WAITERS;
 	}
 
+	/*
+	 * Clear the handoff flag
+	 */
+	if (woken && RWSEM_COUNT_HANDOFF(atomic_long_read(&sem->count)))
+		adjustment -= RWSEM_FLAG_HANDOFF;
+
 	if (adjustment)
 		atomic_long_add(adjustment, &sem->count);
 }
@@ -189,15 +211,19 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
  * race conditions between checking the rwsem wait list and setting the
  * sem->count accordingly.
  */
-static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem)
+static inline bool
+rwsem_try_write_lock(long count, struct rw_semaphore *sem, bool first)
 {
 	long new;
 
 	if (RWSEM_COUNT_LOCKED(count))
 		return false;
 
-	new = count + RWSEM_WRITER_LOCKED -
-	     (list_is_singular(&sem->wait_list) ? RWSEM_FLAG_WAITERS : 0);
+	if (!first && RWSEM_COUNT_HANDOFF(count))
+		return false;
+
+	new = (count & ~RWSEM_FLAG_HANDOFF) + RWSEM_WRITER_LOCKED -
+	      (list_is_singular(&sem->wait_list) ? RWSEM_FLAG_WAITERS : 0);
 
 	if (atomic_long_cmpxchg_acquire(&sem->count, count, new) = count) {
 		rwsem_set_owner(sem);
@@ -216,7 +242,7 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	long old, count = atomic_long_read(&sem->count);
 
 	while (true) {
-		if (RWSEM_COUNT_LOCKED(count))
+		if (RWSEM_COUNT_LOCKED_OR_HANDOFF(count))
 			return false;
 
 		old = atomic_long_cmpxchg_acquire(&sem->count, count,
@@ -374,6 +400,16 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
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
@@ -385,6 +421,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
+	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
 	if (list_empty(&sem->wait_list)) {
@@ -441,8 +478,12 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	return sem;
 out_nolock:
 	list_del(&waiter.list);
-	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_FLAG_WAITERS, &sem->count);
+	if (list_empty(&sem->wait_list)) {
+		int adjustment = -RWSEM_FLAG_WAITERS -
+			(atomic_long_read(&sem->count) & RWSEM_FLAG_HANDOFF);
+
+		atomic_long_add(adjustment, &sem->count);
+	}
 	raw_spin_unlock_irq(&sem->wait_lock);
 	__set_current_state(TASK_RUNNING);
 	lockevent_inc(rwsem_rlock_fail);
@@ -469,8 +510,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 static inline struct rw_semaphore *
 __rwsem_down_write_failed_common(struct rw_semaphore *sem, int state)
 {
-	long count;
-	bool waiting = true; /* any queued threads before us */
+	long count, adjustment;
+	bool first;	/* First one in queue */
 	struct rwsem_waiter waiter;
 	struct rw_semaphore *ret = sem;
 	DEFINE_WAKE_Q(wake_q);
@@ -485,17 +526,17 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 */
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_WRITE;
+	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
 
 	raw_spin_lock_irq(&sem->wait_lock);
 
 	/* account for this before adding a new element to the list */
-	if (list_empty(&sem->wait_list))
-		waiting = false;
+	first = list_empty(&sem->wait_list);
 
 	list_add_tail(&waiter.list, &sem->wait_list);
 
 	/* we're now waiting on the lock, but no longer actively locking */
-	if (waiting) {
+	if (!first) {
 		count = atomic_long_read(&sem->count);
 
 		/*
@@ -529,12 +570,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
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
 
@@ -542,7 +584,29 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 			lockevent_inc(rwsem_sleep_writer);
 			set_current_state(state);
 			count = atomic_long_read(&sem->count);
-		} while (RWSEM_COUNT_LOCKED(count));
+
+			if (!first)
+				first = rwsem_waiter_is_first(sem, &waiter);
+
+			if (!RWSEM_COUNT_LOCKED(count))
+				break;
+
+			if (first && !RWSEM_COUNT_HANDOFF(count) &&
+			    time_after(jiffies, waiter.timeout)) {
+				atomic_long_or(RWSEM_FLAG_HANDOFF, &sem->count);
+				/*
+				 * Make sure the handoff bit is seen by
+				 * others before proceeding.
+				 */
+				smp_mb__after_atomic();
+				lockevent_inc(rwsem_wlock_handoff);
+				/*
+				 * Do a trylock after setting the handoff
+				 * flag to avoid missed wakeup.
+				 */
+				break;
+			}
+		}
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
@@ -557,9 +621,15 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	__set_current_state(TASK_RUNNING);
 	raw_spin_lock_irq(&sem->wait_lock);
 	list_del(&waiter.list);
+	adjustment = 0;
 	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_FLAG_WAITERS, &sem->count);
-	else
+		adjustment -= RWSEM_FLAG_WAITERS;
+	if (first)
+		adjustment -= (atomic_long_read(&sem->count) &
+			       RWSEM_FLAG_HANDOFF);
+	if (adjustment)
+		atomic_long_add(adjustment, &sem->count);
+	if (!list_empty(&sem->wait_list))
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 	raw_spin_unlock_irq(&sem->wait_lock);
 	wake_up_q(&wake_q);
@@ -587,7 +657,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
  * - up_read/up_write has decremented the active part of count if we come here
  */
 __visible
-struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
+struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, long count)
 {
 	unsigned long flags;
 	DEFINE_WAKE_Q(wake_q);
@@ -620,7 +690,9 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 	smp_rmb();
 
 	/*
-	 * If a spinner is present, it is not necessary to do the wakeup.
+	 * If a spinner is present and the handoff flag isn't set, it is
+	 * not necessary to do the wakeup.
+	 *
 	 * Try to do wakeup only if the trylock succeeds to minimize
 	 * spinlock contention which may introduce too much delay in the
 	 * unlock operation.
@@ -639,7 +711,7 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 	 * rwsem_has_spinner() is true, it will guarantee at least one
 	 * trylock attempt on the rwsem later on.
 	 */
-	if (rwsem_has_spinner(sem)) {
+	if (rwsem_has_spinner(sem) && !RWSEM_COUNT_HANDOFF(count)) {
 		/*
 		 * The smp_rmb() here is to make sure that the spinner
 		 * state is consulted before reading the wait_lock.
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 1febd17..6d4890d 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -41,7 +41,8 @@
  *
  * Bit  0   - writer locked bit
  * Bit  1   - waiters present bit
- * Bits 2-7 - reserved
+ * Bit  2   - lock handoff bit
+ * Bits 3-7 - reserved
  * Bits 8-X - 24-bit (32-bit) or 56-bit reader count
  *
  * atomic_long_fetch_add() is used to obtain reader lock, whereas
@@ -49,14 +50,20 @@
  */
 #define RWSEM_WRITER_LOCKED	(1UL << 0)
 #define RWSEM_FLAG_WAITERS	(1UL << 1)
+#define RWSEM_FLAG_HANDOFF	(1UL << 2)
+
 #define RWSEM_READER_SHIFT	8
 #define RWSEM_READER_BIAS	(1UL << RWSEM_READER_SHIFT)
 #define RWSEM_READER_MASK	(~(RWSEM_READER_BIAS - 1))
 #define RWSEM_WRITER_MASK	RWSEM_WRITER_LOCKED
 #define RWSEM_LOCK_MASK		(RWSEM_WRITER_MASK|RWSEM_READER_MASK)
-#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_MASK|RWSEM_FLAG_WAITERS)
+#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_MASK|RWSEM_FLAG_WAITERS|\
+				 RWSEM_FLAG_HANDOFF)
 
 #define RWSEM_COUNT_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
+#define RWSEM_COUNT_HANDOFF(c)	((c) & RWSEM_FLAG_HANDOFF)
+#define RWSEM_COUNT_LOCKED_OR_HANDOFF(c)	\
+	((c) & (RWSEM_LOCK_MASK|RWSEM_FLAG_HANDOFF))
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
@@ -163,7 +170,7 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
 extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, long count);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
 /*
@@ -253,7 +260,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 	tmp = atomic_long_add_return_release(-RWSEM_READER_BIAS, &sem->count);
 	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
 			= RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem);
+		rwsem_wake(sem, tmp);
 }
 
 /*
@@ -261,11 +268,13 @@ static inline void __up_read(struct rw_semaphore *sem)
  */
 static inline void __up_write(struct rw_semaphore *sem)
 {
+	long tmp;
+
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current, sem);
 	rwsem_clear_owner(sem);
-	if (unlikely(atomic_long_fetch_add_release(-RWSEM_WRITER_LOCKED,
-			&sem->count) & RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem);
+	tmp = atomic_long_fetch_add_release(-RWSEM_WRITER_LOCKED, &sem->count);
+	if (unlikely(tmp & RWSEM_FLAG_WAITERS))
+		rwsem_wake(sem, tmp);
 }
 
 /*
-- 
1.8.3.1
