From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:02:00 +0000
Subject: [PATCH v6 09/11] locking/rwsem: Enable time-based reader lock stealing
Message-Id: <1507744922-15196-10-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

Because of writer lock stealing and optimistic spinning, writers
were preferred over readers in rwsem. However, preferring readers is
generally good for performance. However, we need to do it in a way
that won't starve writers as an incoming stream of readers will not
allow a wakeup call to happen which is needed to allow a waiting
writer to set the handoff bit to initiate the handoff protocol.

Now the owner field is extended to hold a timestamp put in by the
first reader that acquires the lock. An incoming reader is allowed
to steal the lock if the lock is reader owned, the handoff bit isn't
set and the owner timestamp matches the current time.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 45 +++++++++++++++++++++++++++-------
 kernel/locking/rwsem-xadd.h | 60 +++++++++++++++++++++++++++++++++++----------
 2 files changed, 83 insertions(+), 22 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 52305c3..38a6c32 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -150,10 +150,11 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
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
@@ -400,6 +401,22 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	return osq_is_locked(&sem->osq);
 }
 
+static inline bool
+rwsem_reader_steal_lock(struct rw_semaphore *sem, int count)
+{
+	struct task_struct *owner = READ_ONCE(sem->owner);
+
+	/*
+	 * Reader can steal the lock if:
+	 * 1) the lock is reader-owned;
+	 * 2) the handoff bit isn't set; and
+	 * 3) the time stamp in the owner field matches the current time
+	 *    when it is properly initialized.
+	 */
+	return !(count & (RWSEM_WRITER_LOCKED|RWSEM_FLAG_HANDOFF)) &&
+		(!rwsem_owner_is_reader(owner) ||
+		  rwsem_owner_timestamp_match(owner));
+}
 #else
 static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 {
@@ -416,6 +433,12 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 {
 	return false;
 }
+
+static inline bool
+rwsem_reader_steal_lock(struct rw_semaphore *sem, int count)
+{
+	return false;
+}
 #endif
 
 /*
@@ -432,13 +455,16 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
  * Wait for the read lock to be granted
  */
 static inline struct rw_semaphore __sched *
-__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
+__rwsem_down_read_failed_common(struct rw_semaphore *sem, int count, int state)
 {
 	bool can_spin;
-	int count, adjustment = -RWSEM_READER_BIAS;
+	int adjustment = -RWSEM_READER_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
+	if (rwsem_reader_steal_lock(sem, count))
+		return sem;
+
 	/*
 	 * Undo read bias from down_read operation to stop active locking if:
 	 * 1) Optimistic spinners are present; or
@@ -513,16 +539,17 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 }
 
 __visible struct rw_semaphore * __sched
-rwsem_down_read_failed(struct rw_semaphore *sem)
+rwsem_down_read_failed(struct rw_semaphore *sem, int count)
 {
-	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE);
+	return __rwsem_down_read_failed_common(sem, count,
+					       TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(rwsem_down_read_failed);
 
 __visible struct rw_semaphore * __sched
-rwsem_down_read_failed_killable(struct rw_semaphore *sem)
+rwsem_down_read_failed_killable(struct rw_semaphore *sem, int count)
 {
-	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE);
+	return __rwsem_down_read_failed_common(sem, count, TASK_KILLABLE);
 }
 EXPORT_SYMBOL(rwsem_down_read_failed_killable);
 
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 8cb12ed..bf47d4a 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -4,21 +4,32 @@
 #include <linux/rwsem.h>
 
 /*
- * The owner field of the rw_semaphore structure will be set to
- * RWSEM_READ_OWNED when a reader grabs the lock. A writer will clear
- * the owner field when it unlocks. A reader, on the other hand, will
- * not touch the owner field when it unlocks.
+ * When a reader acquires the lock, the RWSEM_READ_OWNED bit of the owner
+ * field will be set. In addition, a timestamp based on the current jiffies
+ * value will be put into the upper bits of the owner. An incoming reader will
+ * now be allowed to join the read lock iff the current time matches the
+ * timestamp. This will greatly favor the readers which is generally good
+ * for improving throughput. The timestamp check, however, will prevent
+ * a continuous stream of incoming readers from monopolizing the lock
+ * and starving the writers.
+ *
+ * A writer will clear the owner field when it unlocks. A reader, on the
+ * other hand, will not touch the owner field when it unlocks.
  *
  * In essence, the owner field now has the following 3 states:
  *  1) 0
  *     - lock is free or the owner hasn't set the field yet
- *  2) RWSEM_READER_OWNED
+ *  2) (owner & RWSEM_READER_OWNED) = RWSEM_READER_OWNED
  *     - lock is currently or previously owned by readers (lock is free
- *       or not set by owner yet)
+ *       or not set by owner yet). The other bits in the owner field can
+ *       be used for other purpose.
  *  3) Other non-zero value
  *     - a writer owns the lock
  */
-#define RWSEM_READER_OWNED	((struct task_struct *)1UL)
+#define RWSEM_READER_OWNED		(1UL)
+#define RWSEM_READER_TIMESTAMP_SHIFT	8
+#define RWSEM_READER_TIMESTAMP_MASK	\
+	~((1UL << RWSEM_READER_TIMESTAMP_SHIFT) - 1)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
@@ -43,17 +54,32 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
  */
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
-	WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
+	WRITE_ONCE(sem->owner, (void *)(RWSEM_READER_OWNED |
+		  (jiffies << RWSEM_READER_TIMESTAMP_SHIFT)));
 }
 
 static inline bool rwsem_owner_is_writer(struct task_struct *owner)
 {
-	return owner && owner != RWSEM_READER_OWNED;
+	return owner && !((unsigned long)owner & RWSEM_READER_OWNED);
 }
 
 static inline bool rwsem_owner_is_reader(struct task_struct *owner)
 {
-	return owner = RWSEM_READER_OWNED;
+	return (unsigned long)owner & RWSEM_READER_OWNED;
+}
+
+/*
+ * Return true if the timestamp matches the current time.
+ */
+static inline bool rwsem_owner_timestamp_match(struct task_struct *owner)
+{
+	return ((unsigned long)owner & RWSEM_READER_TIMESTAMP_MASK) =
+	       (jiffies << RWSEM_READER_TIMESTAMP_SHIFT);
+}
+
+static inline bool rwsem_is_reader_owned(struct rw_semaphore *sem)
+{
+	return rwsem_owner_is_reader(READ_ONCE(sem->owner));
 }
 #else
 static inline void rwsem_set_owner(struct rw_semaphore *sem)
@@ -67,6 +93,11 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
 }
+
+static inline bool rwsem_is_reader_owned(struct rw_semaphore *sem)
+{
+	return false;
+}
 #endif
 
 /*
@@ -96,8 +127,11 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 #define RWSEM_COUNT_IS_LOCKED_OR_HANDOFF(c)	\
 	((c) & (RWSEM_LOCK_MASK|RWSEM_FLAG_HANDOFF))
 
-extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
+extern struct rw_semaphore *
+rwsem_down_read_failed(struct rw_semaphore *sem, int count);
+extern struct rw_semaphore *
+rwsem_down_read_failed_killable(struct rw_semaphore *sem, int count);
+
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *, int count);
@@ -111,7 +145,7 @@ static inline void __down_read(struct rw_semaphore *sem)
 	int count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
 
 	if (unlikely(count & RWSEM_READ_FAILED_MASK))
-		rwsem_down_read_failed(sem);
+		rwsem_down_read_failed(sem, count);
 	else if ((count >> RWSEM_READER_SHIFT) = 1)
 		rwsem_set_reader_owned(sem);
 }
-- 
1.8.3.1

