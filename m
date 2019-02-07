From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:23 +0000
Subject: [PATCH-tip 19/22] locking/rwsem: Enable readers spinning on writer
Message-Id: <1549566446-27967-20-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

This patch enables readers to optimistically spin on a
rwsem when it is owned by a writer instead of going to sleep
directly.  The rwsem_can_spin_on_owner() function is extracted
out of rwsem_optimistic_spin() and is called directly by
__rwsem_down_read_failed_common() and __rwsem_down_write_failed_common().

This patch may actually reduce performance under certain circumstances
for reader-mostly workload as the readers may not be grouped together
in the wait queue anymore.  So we may have a number of small reader
groups among writers instead of a large reader group. However, this
change is needed for some of the subsequent patches.

With a locking microbenchmark running on 5.0 based kernel, the total
locking rates (in kops/s) of the benchmark on a 4-socket 56-core x86-64
system with equal numbers of readers and writers before and after the
patch were as follows:

   # of Threads  Pre-patch    Post-patch
   ------------  ---------    ----------
        2          1,926        2,120
        4          1,391        1,320
        8            716          694
       16            618          606
       32            501          487
       64             61           57

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/lock_events_list.h |  1 +
 kernel/locking/rwsem-xadd.c       | 80 ++++++++++++++++++++++++++++++++++-----
 kernel/locking/rwsem-xadd.h       |  3 ++
 3 files changed, 74 insertions(+), 10 deletions(-)

diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
index 4cde507..54b6650 100644
--- a/kernel/locking/lock_events_list.h
+++ b/kernel/locking/lock_events_list.h
@@ -57,6 +57,7 @@
 LOCK_EVENT(rwsem_sleep_writer)	/* # of writer sleeps			*/
 LOCK_EVENT(rwsem_wake_reader)	/* # of reader wakeups			*/
 LOCK_EVENT(rwsem_wake_writer)	/* # of writer wakeups			*/
+LOCK_EVENT(rwsem_opt_rlock)	/* # of read locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_wlock)	/* # of write locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_fail)	/* # of failed opt-spinnings		*/
 LOCK_EVENT(rwsem_rlock)		/* # of read locks acquired		*/
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 0a29aac..015edd6 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -240,6 +240,30 @@ static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem,
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
+ * Try to acquire read lock before the reader is put on wait queue.
+ * Lock acquisition isn't allowed if the rwsem is locked or a writer handoff
+ * is ongoing.
+ */
+static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+{
+	long count = atomic_long_read(&sem->count);
+
+	if (RWSEM_COUNT_WLOCKED_OR_HANDOFF(count))
+		return false;
+
+	count = atomic_long_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
+	if (!RWSEM_COUNT_WLOCKED_OR_HANDOFF(count)) {
+		rwsem_set_reader_owned(sem);
+		lockevent_inc(rwsem_opt_rlock);
+		return true;
+	}
+
+	/* Back out the change */
+	atomic_long_add(-RWSEM_READER_BIAS, &sem->count);
+	return false;
+}
+
+/*
  * Try to acquire write lock before the writer has been put on wait queue.
  */
 static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem,
@@ -291,8 +315,10 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 
 	BUILD_BUG_ON(!rwsem_has_anonymous_owner(RWSEM_OWNER_UNKNOWN));
 
-	if (need_resched())
+	if (need_resched()) {
+		lockevent_inc(rwsem_opt_fail);
 		return false;
+	}
 
 	rcu_read_lock();
 	owner = rwsem_get_owner(sem);
@@ -301,6 +327,7 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 		      owner_on_cpu(owner, sem);
 	}
 	rcu_read_unlock();
+	lockevent_cond_inc(rwsem_opt_fail, !ret);
 	return ret;
 }
 
@@ -371,9 +398,6 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	preempt_disable();
 
 	/* sem->wait_lock should not be held when doing optimistic spinning */
-	if (!rwsem_can_spin_on_owner(sem))
-		goto done;
-
 	if (!osq_lock(&sem->osq))
 		goto done;
 
@@ -388,10 +412,11 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 		/*
 		 * Try to acquire the lock
 		 */
-		if (rwsem_try_write_lock_unqueued(sem, wlock)) {
-			taken = true;
+		taken = wlock ? rwsem_try_write_lock_unqueued(sem, wlock)
+			      : rwsem_try_read_lock_unqueued(sem);
+
+		if (taken)
 			break;
-		}
 
 		/*
 		 * When there's no owner, we might have preempted between the
@@ -418,7 +443,13 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	return taken;
 }
 #else
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+{
+	return false;
+}
+
+static inline bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+					 const long wlock)
 {
 	return false;
 }
@@ -444,6 +475,33 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
+	if (!rwsem_can_spin_on_owner(sem))
+		goto queue;
+
+	/*
+	 * Undo read bias from down_read() and do optimistic spinning.
+	 */
+	atomic_long_add(-RWSEM_READER_BIAS, &sem->count);
+	adjustment = 0;
+	if (rwsem_optimistic_spin(sem, 0)) {
+		unsigned long flags;
+
+		/*
+		 * Opportunistically wake up other readers in the wait queue.
+		 * It has another chance of wakeup at unlock time.
+		 */
+		if ((atomic_long_read(&sem->count) & RWSEM_FLAG_WAITERS) &&
+		    raw_spin_trylock_irqsave(&sem->wait_lock, flags)) {
+			if (!list_empty(&sem->wait_list))
+				__rwsem_mark_wake(sem, RWSEM_WAKE_READ_OWNED,
+						  &wake_q);
+			raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
+			wake_up_q(&wake_q);
+		}
+		return sem;
+	}
+
+queue:
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
 	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
@@ -456,7 +514,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 		 * immediately as its RWSEM_READER_BIAS has already been
 		 * set in the count.
 		 */
-		if (!(atomic_long_read(&sem->count) & RWSEM_WRITER_MASK)) {
+		if (adjustment &&
+		   !(atomic_long_read(&sem->count) & RWSEM_WRITER_MASK)) {
 			raw_spin_unlock_irq(&sem->wait_lock);
 			rwsem_set_reader_owned(sem);
 			lockevent_inc(rwsem_rlock_fast);
@@ -543,7 +602,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	const long wlock = RWSEM_WRITER_LOCKED;
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_optimistic_spin(sem, wlock))
+	if (rwsem_can_spin_on_owner(sem) &&
+	    rwsem_optimistic_spin(sem, wlock))
 		return sem;
 
 	/*
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 1de6f1e..eb4ef36 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -109,9 +109,12 @@
 				 RWSEM_FLAG_HANDOFF)
 
 #define RWSEM_COUNT_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
+#define RWSEM_COUNT_WLOCKED(c)	((c) & RWSEM_WRITER_MASK)
 #define RWSEM_COUNT_HANDOFF(c)	((c) & RWSEM_FLAG_HANDOFF)
 #define RWSEM_COUNT_LOCKED_OR_HANDOFF(c)	\
 	((c) & (RWSEM_LOCK_MASK|RWSEM_FLAG_HANDOFF))
+#define RWSEM_COUNT_WLOCKED_OR_HANDOFF(c)	\
+	((c) & (RWSEM_WRITER_MASK | RWSEM_FLAG_HANDOFF))
 
 /*
  * Task structure pointer compression (64-bit only):
-- 
1.8.3.1
