From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:29 +0000
Subject: [PATCH-tip v7 13/15] locking/rwsem: Improve fairness to writers
Message-Id: <1508351431-22375-14-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

When the spin disable bit in the owner field is set, writers will
stop spinning. However, an incoming stream of readers will be able to
go to the front of the OSQ and acquire the lock continuously without
ever releasing the read lock. This can lead to writer starvation.

Two changes are made to improve fairness to writers and hence prevent
writer starvation. The readers will stop spinning and go to the wait
queue when:

 1) It is not the first reader and the current time doesn't match
    the timestamp stored in the owner field.
 2) Writers cannot spin on reader.

This will allow the reader count to eventually reach 0 and wake up
the first waiter in the wait queue.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 60 +++++++++++++++++++++++++++++++++------------
 kernel/locking/rwsem-xadd.h | 32 +++++++++++++++++++-----
 2 files changed, 70 insertions(+), 22 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 3bdbf39..edb5ecc 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -169,10 +169,11 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			return;
 		}
 		/*
-		 * Set it to reader-owned for first reader.
+		 * Since the wait queue head is a reader, we can set a
+		 * new timestamp even if it is not the first reader to
+		 * acquire the current lock.
 		 */
-		if (!(oldcount >> RWSEM_READER_SHIFT))
-			rwsem_set_reader_owned(sem);
+		rwsem_set_reader_owned(sem);
 	}
 
 	/*
@@ -249,44 +250,64 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
  * Try to acquire read lock before the reader is put on wait queue.
- * Lock acquisition isn't allowed if the rwsem is locked or a writer handoff
- * is ongoing.
+ *
+ * Lock acquisition isn't allowed if the rwsem is locked.
+ *
+ * To avoid writer starvation and have more more fairness, it has to stop
+ * spinning if the reader count isn't 0, waiter is present and there is a
+ * timestamp mismatch.
+ *
+ * This will allow the reader count to go to 0 and wake up the first one
+ * in the wait queue which can initiate the handoff protocol, if necessary.
+ *
+ * Return:  1 - lock acquired
+ *	    0 - lock acquisition failed
+ *	   -1 - stop spinning
  */
-static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+static inline int rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
 {
 	int count = atomic_read(&sem->count);
 
 	if (RWSEM_COUNT_WLOCKED(count) || RWSEM_COUNT_HANDOFF_WRITER(count))
-		return false;
+		return 0;
 
 	count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
 	if (!RWSEM_COUNT_WLOCKED(count) && !RWSEM_COUNT_HANDOFF_WRITER(count)) {
-		if (!(count >> RWSEM_READER_SHIFT))
+		if (!(count >> RWSEM_READER_SHIFT)) {
 			rwsem_set_reader_owned(sem);
-		return true;
+		} else if (count & RWSEM_FLAG_WAITERS) {
+			struct task_struct *owner = READ_ONCE(sem->owner);
+
+			if (rwsem_owner_is_reader(owner) &&
+			   !rwsem_owner_timestamp_match(owner)) {
+				atomic_add(-RWSEM_READER_BIAS, &sem->count);
+				return -1;
+			}
+		}
+		return 1;
 	}
 
 	/* Back out the change */
 	atomic_add(-RWSEM_READER_BIAS, &sem->count);
-	return false;
+	return 0;
 }
 
 /*
  * Try to acquire write lock before the writer has been put on wait queue.
  */
-static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
+static inline int rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 {
 	int old, count = atomic_read(&sem->count);
 
 	while (true) {
 		if (RWSEM_COUNT_LOCKED_OR_HANDOFF(count))
-			return false;
+			return 0;
 
 		old = atomic_cmpxchg_acquire(&sem->count, count,
 				count + RWSEM_WRITER_LOCKED);
 		if (old = count) {
 			rwsem_set_owner(sem);
-			return true;
+			return 1;
 		}
 
 		count = old;
@@ -370,7 +391,7 @@ static noinline int rwsem_spin_on_owner(struct rw_semaphore *sem)
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 				  enum rwsem_waiter_type type)
 {
-	bool taken = false;
+	int taken = 0;
 	bool reader = (type = RWSEM_WAITING_FOR_READ);
 	int owner_state;	/* Lock owner state */
 	int rspin_cnt = RWSEM_RSPIN_THRESHOLD;
@@ -390,10 +411,17 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
 	 *  1) the owning writer isn't running; or
-	 *  2) writer: readers own the lock and spinning count has reached 0;
+	 *  2) readers own the lock and spinning count has reached 0;
 	 */
 	while ((owner_state = rwsem_spin_on_owner(sem)) >= 0) {
 		/*
+		 * For fairness, reader will stop taking reader-owned lock
+		 * when writers cannot spin on reader.
+		 */
+		if (reader && !rspin_cnt && !owner_state)
+			break;
+
+		/*
 		 * Try to acquire the lock
 		 */
 		taken = reader ? rwsem_try_read_lock_unqueued(sem)
@@ -449,7 +477,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 	osq_unlock(&sem->osq);
 done:
 	preempt_enable();
-	return taken;
+	return taken > 0;
 }
 
 /*
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 1e87e85..ea87bf1 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -4,10 +4,16 @@
 #include <linux/rwsem.h>
 
 /*
- * The owner field of the rw_semaphore structure will be set to
- * RWSEM_READ_OWNED when a reader grabs the lock. A writer will clear
- * the owner field when it unlocks. A reader, on the other hand, will
- * not touch the owner field when it unlocks.
+ * When a reader acquires the lock, the RWSEM_READ_OWNED bit of the owner
+ * field will be set. In addition, a timestamp based on the current jiffies
+ * value will be put into the upper bits of the owner. An incoming reader in
+ * the slowpath will not be allowed to join the read lock if the current
+ * time does not match the timestamp. This check will prevent a continuous
+ * stream of incoming readers from monopolizing the lock and starving the
+ * writers.
+ *
+ * A writer will clear the owner field when it unlocks. A reader, on the
+ * other hand, will not touch the owner field when it unlocks.
  *
  * In essence, the owner field now has the following 3 states:
  *  1) 0
@@ -19,8 +25,11 @@
  *  3) Other non-zero value
  *     - a writer owns the lock
  */
-#define RWSEM_READER_OWNED	(1UL)
-#define RWSEM_SPIN_DISABLED	(2UL)
+#define RWSEM_READER_OWNED		(1UL)
+#define RWSEM_SPIN_DISABLED		(2UL)
+#define RWSEM_READER_TIMESTAMP_SHIFT	8
+#define RWSEM_READER_TIMESTAMP_MASK	\
+	~((1UL << RWSEM_READER_TIMESTAMP_SHIFT) - 1)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
@@ -46,6 +55,8 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
 	WRITE_ONCE(sem->owner, (void *)RWSEM_READER_OWNED);
+	WRITE_ONCE(sem->owner, (void *)(RWSEM_READER_OWNED |
+		  (jiffies << RWSEM_READER_TIMESTAMP_SHIFT)));
 }
 
 static inline bool rwsem_owner_is_writer(struct task_struct *owner)
@@ -58,6 +69,15 @@ static inline bool rwsem_owner_is_reader(struct task_struct *owner)
 	return (unsigned long)owner & RWSEM_READER_OWNED;
 }
 
+/*
+ * Return true if the timestamp matches the current time.
+ */
+static inline bool rwsem_owner_timestamp_match(struct task_struct *owner)
+{
+	return ((unsigned long)owner & RWSEM_READER_TIMESTAMP_MASK) =
+	       (jiffies << RWSEM_READER_TIMESTAMP_SHIFT);
+}
+
 static inline bool rwsem_owner_is_spin_disabled(struct task_struct *owner)
 {
 	return (unsigned long)owner & RWSEM_SPIN_DISABLED;
-- 
1.8.3.1

