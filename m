From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:02:02 +0000
Subject: [PATCH v6 11/11] locking/rwsem: Enable count-based spinning on reader
Message-Id: <1507744922-15196-12-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
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
rwsem. It is a loop count threshold based spinning where the count will
get reset whenenver the the rwsem reader count value changes indicating
that the rwsem is still active. There is another maximum count value
that limits that maximum number of spinnings that can happen.

When the loop or max counts reach 0, a bit will be set in the owner
field to indicate that no more optimistic spinning should be done on
this rwsem until it becomes writer owned again.

The spinning threshold and maximum values can be overridden by
architecture specific rwsem.h header file, if necessary. The current
default threshold value is 512 iterations.

On a 2-socket 40-core x86-64 Gold 6148 system, a rwsem microbenchmark
was run with 40 locking threads (one/core) doing 10s of equal number
of reader and writer lock/unlock operations on the same rwsem
alternatively, the resulting locking total rates on a 4.14 based
kernel were 927 kop/s and 3218 kop/s without and with the patch
respectively. That was an increase of about 247%.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 97 +++++++++++++++++++++++++++++++++++++++------
 kernel/locking/rwsem-xadd.h | 27 +++++++++++++
 2 files changed, 111 insertions(+), 13 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index d0f3778..62147a9 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -90,6 +90,22 @@ enum rwsem_wake_type {
 #define RWSEM_WAIT_TIMEOUT	((HZ - 1)/100 + 1)
 
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
+# define RWSEM_RSPIN_THRESHOLD	(1 << 9)
+# define RWSEM_RSPIN_MAX	(1 << 12)
+#endif
+
+/*
  * handle the lock release when processes blocked on it that can now run
  * - if we come here from up_xxxx(), then:
  *   - the 'active part' of count (&0x0000ffff) reached 0 (but may have changed)
@@ -230,8 +246,17 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
  * Try to acquire read lock before the reader is put on wait queue.
+ *
+ * To avoid writer starvation, it cannot acquire the lock if the reader
+ * count isn't 0 and there is a timestamp mismatch. In this case, the
+ * reader has to stop spinning.
+ *
+ * This will at least allow the reader count to go to 0 and wake up the
+ * first one in the wait queue which can initiate the handoff protocol,
+ * if necessary.
  */
-static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem,
+						bool *stop_spin)
 {
 	int count = atomic_read(&sem->count);
 
@@ -240,11 +265,21 @@ static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
 
 	count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
 	if (!(count & (RWSEM_FLAG_HANDOFF|RWSEM_WRITER_LOCKED))) {
-		if (!(count >> RWSEM_READER_SHIFT))
+		if (!(count >> RWSEM_READER_SHIFT)) {
 			rwsem_set_reader_owned(sem);
+		} else {
+			struct task_struct *owner = READ_ONCE(sem->owner);
+
+			if (rwsem_owner_is_reader(owner) &&
+			   !rwsem_owner_timestamp_match(owner)) {
+				*stop_spin = true;
+				goto backout;
+			}
+		}
 		return true;
 	}
 
+backout:
 	/* Back out the change */
 	atomic_add(-RWSEM_READER_BIAS, &sem->count);
 	return false;
@@ -272,7 +307,8 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	}
 }
 
-static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
+static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem,
+					   bool reader)
 {
 	struct task_struct *owner;
 	bool ret = true;
@@ -284,9 +320,9 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	owner = READ_ONCE(sem->owner);
 	if (!rwsem_owner_is_writer(owner)) {
 		/*
-		 * Don't spin if the rwsem is readers owned.
+		 * Don't spin if the rspin disable bit is set for writer.
 		 */
-		ret = !rwsem_owner_is_reader(owner);
+		ret = reader || !rwsem_owner_is_spin_disabled(owner);
 		goto done;
 	}
 
@@ -349,6 +385,11 @@ static noinline int rwsem_spin_on_owner(struct rw_semaphore *sem)
 rwsem_optimistic_spin(struct rw_semaphore *sem, enum rwsem_waiter_type type)
 {
 	bool taken = false;
+	bool stop_spin = false;
+	int owner_state;	/* Lock owner state */
+	int rspin_cnt = RWSEM_RSPIN_THRESHOLD;
+	int rspin_max = RWSEM_RSPIN_MAX;
+	int old_count = 0;
 
 	preempt_disable();
 
@@ -356,25 +397,55 @@ static noinline int rwsem_spin_on_owner(struct rw_semaphore *sem)
 	if (!osq_lock(&sem->osq))
 		goto done;
 
+	if (rwsem_is_spin_disabled(sem))
+		rspin_cnt = 0;
+
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
-	 *  1) the owning writer isn't running; or
-	 *  2) readers own the lock as we can't determine if they are
-	 *     actively running or not.
+	 *  1) the owning writer isn't running;
+	 *  2) writer: readers own the lock and spinning count has reached 0;
+	 *  3) reader: timestamp mismatch.
 	 */
-	while (rwsem_spin_on_owner(sem) > 0) {
+	while ((owner_state = rwsem_spin_on_owner(sem)) >= 0) {
 		/*
 		 * Try to acquire the lock
 		 */
 		taken = (type = RWSEM_WAITING_FOR_WRITE)
 		      ? rwsem_try_write_lock_unqueued(sem)
-		      : rwsem_try_read_lock_unqueued(sem);
+		      : rwsem_try_read_lock_unqueued(sem, &stop_spin);
 
-		if (taken)
+		if (taken || stop_spin)
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
+			int count;
+
+			if (!rspin_cnt || !rspin_max) {
+				if (!rwsem_is_spin_disabled(sem))
+					rwsem_set_spin_disabled(sem);
+				break;
+			}
+
+			count = atomic_read(&sem->count) >> RWSEM_READER_SHIFT;
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
@@ -474,7 +545,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 * 1) Optimistic spinners are present; or
 	 * 2) optimistic spinning is allowed.
 	 */
-	can_spin = rwsem_can_spin_on_owner(sem);
+	can_spin = rwsem_can_spin_on_owner(sem, true);
 	if (can_spin || rwsem_has_spinner(sem)) {
 		atomic_add(-RWSEM_READER_BIAS, &sem->count);
 		adjustment = 0;
@@ -570,7 +641,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	DEFINE_WAKE_Q(wake_q);
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_can_spin_on_owner(sem) &&
+	if (rwsem_can_spin_on_owner(sem, false) &&
 	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
 		return sem;
 
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index bf47d4a..6b60aac 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -27,6 +27,7 @@
  *     - a writer owns the lock
  */
 #define RWSEM_READER_OWNED		(1UL)
+#define RWSEM_SPIN_DISABLED		(2UL)
 #define RWSEM_READER_TIMESTAMP_SHIFT	8
 #define RWSEM_READER_TIMESTAMP_MASK	\
 	~((1UL << RWSEM_READER_TIMESTAMP_SHIFT) - 1)
@@ -81,6 +82,32 @@ static inline bool rwsem_is_reader_owned(struct rw_semaphore *sem)
 {
 	return rwsem_owner_is_reader(READ_ONCE(sem->owner));
 }
+
+static inline bool rwsem_owner_is_spin_disabled(struct task_struct *owner)
+{
+	return (unsigned long)owner & RWSEM_SPIN_DISABLED;
+}
+
+/*
+ * Try to set an optimistic spinning disable bit while it is reader-owned.
+ */
+static inline void rwsem_set_spin_disabled(struct rw_semaphore *sem)
+{
+	struct task_struct *owner = READ_ONCE(sem->owner);
+
+	/*
+	 * Failure in cmpxchg() will be ignored, and the caller is expected
+	 * to retry later.
+	 */
+	if (rwsem_owner_is_reader(owner))
+		cmpxchg(&sem->owner, owner,
+			(void *)((unsigned long)owner|RWSEM_SPIN_DISABLED));
+}
+
+static inline bool rwsem_is_spin_disabled(struct rw_semaphore *sem)
+{
+	return rwsem_owner_is_spin_disabled(READ_ONCE(sem->owner));
+}
 #else
 static inline void rwsem_set_owner(struct rw_semaphore *sem)
 {
-- 
1.8.3.1

