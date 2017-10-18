From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:24 +0000
Subject: [PATCH-tip v7 08/15] locking/rwsem: Enable readers spinning on writer
Message-Id: <1508351431-22375-9-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

This patch enables readers to optimistically spin on a
rwsem when it is owned by a writer instead of going to sleep
directly.  The rwsem_can_spin_on_owner() function is extracted
out of rwsem_optimistic_spin() and is called directly by
rwsem_down_read_failed() and rwsem_down_write_failed().

This patch may actually reduce performance under certain circumstances
as the readers may not be grouped together in the wait queue anymore.
So we may have a number of small reader groups among writers instead
of a large reader group. However, this change is needed for some of
the subsequent patches.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 68 +++++++++++++++++++++++++++++++++++++++------
 kernel/locking/rwsem-xadd.h |  1 +
 2 files changed, 60 insertions(+), 9 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 65717d8..15cdb28 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -224,6 +224,30 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
+ * Try to acquire read lock before the reader is put on wait queue.
+ * Lock acquisition isn't allowed if the rwsem is locked or a writer handoff
+ * is ongoing.
+ */
+static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+{
+	int count = atomic_read(&sem->count);
+
+	if (RWSEM_COUNT_WLOCKED(count) || RWSEM_COUNT_HANDOFF_WRITER(count))
+		return false;
+
+	count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
+	if (!RWSEM_COUNT_WLOCKED(count) && !RWSEM_COUNT_HANDOFF_WRITER(count)) {
+		if (!(count >> RWSEM_READER_SHIFT))
+			rwsem_set_reader_owned(sem);
+		return true;
+	}
+
+	/* Back out the change */
+	atomic_add(-RWSEM_READER_BIAS, &sem->count);
+	return false;
+}
+
+/*
  * Try to acquire write lock before the writer has been put on wait queue.
  */
 static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
@@ -314,16 +338,14 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
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
 
@@ -338,10 +360,12 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		/*
 		 * Try to acquire the lock
 		 */
-		if (rwsem_try_write_lock_unqueued(sem)) {
-			taken = true;
+		taken = (type = RWSEM_WAITING_FOR_WRITE)
+		      ? rwsem_try_write_lock_unqueued(sem)
+		      : rwsem_try_read_lock_unqueued(sem);
+
+		if (taken)
 			break;
-		}
 
 		/*
 		 * When there's no owner, we might have preempted between the
@@ -375,7 +399,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 }
 
 #else
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+{
+	return false;
+}
+
+static inline bool
+rwsem_optimistic_spin(struct rw_semaphore *sem, enum rwsem_waiter_type type)
 {
 	return false;
 }
@@ -402,10 +432,29 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 static inline struct rw_semaphore __sched *
 __rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
 {
+	bool can_spin;
 	int count, adjustment = -RWSEM_READER_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
+	/*
+	 * Undo read bias from down_read operation to stop active locking if:
+	 * 1) Optimistic spinners are present; or
+	 * 2) optimistic spinning is allowed.
+	 */
+	can_spin = rwsem_can_spin_on_owner(sem);
+	if (can_spin || rwsem_has_spinner(sem)) {
+		atomic_add(-RWSEM_READER_BIAS, &sem->count);
+		adjustment = 0;
+
+		/*
+		 * Do optimistic spinning and steal lock if possible.
+		 */
+		if (can_spin &&
+		    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+			return sem;
+	}
+
 	waiter.task = current;
 	waiter.type = RWSEM_WAITING_FOR_READ;
 	waiter.timeout = jiffies + RWSEM_WAIT_TIMEOUT;
@@ -487,7 +536,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	DEFINE_WAKE_Q(wake_q);
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_optimistic_spin(sem))
+	if (rwsem_can_spin_on_owner(sem) &&
+	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
 		return sem;
 
 	/*
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index a340ea4..db9726b 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -98,6 +98,7 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 				 RWSEM_FLAG_HANDOFF)
 
 #define RWSEM_COUNT_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
+#define RWSEM_COUNT_WLOCKED(c)	((c) & RWSEM_WRITER_LOCKED)
 #define RWSEM_COUNT_HANDOFF(c)	((c) & RWSEM_FLAG_HANDOFF)
 #define RWSEM_COUNT_HANDOFF_WRITER(c)		\
 	(((c) & RWSEM_FLAG_HANDOFFS) = RWSEM_FLAG_WHANDOFF)
-- 
1.8.3.1

