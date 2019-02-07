From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:24 +0000
Subject: [PATCH-tip 20/22] locking/rwsem: Enable count-based spinning on reader
Message-Id: <1549566446-27967-21-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

When the rwsem is owned by reader, writers stop optimistic spinning
simply because there is no easy way to figure out if all the readers
are actively running or not. However, there are scenarios where
the readers are unlikely to sleep and optimistic spinning can help
performance.

This patch provides a simple mechanism for spinning on a reader-owned
rwsem. It is a loop count threshold based spinning where the count will
get reset whenenver the rwsem reader count value changes indicating
that the rwsem is still active. There is another maximum count value
that limits that maximum number of spinnings that can happen.

When the loop or max counts reach 0, a bit will be set in the owner
field to indicate that no more optimistic spinning should be done on
this rwsem until it becomes writer owned again. Not even readers
is allowed to acquire the reader-locked rwsem for better fairness.

The spinning threshold and maximum values can be overridden by
architecture specific header file, if necessary. The current default
threshold value is 512 iterations.

With a locking microbenchmark running on 5.0 based kernel, the total
locking rates (in kops/s) of the benchmark on a 4-socket 56-core x86-64
system with equal numbers of readers and writers before all the reader
spining patches, before this patch and after this patch were as follows:

   # of Threads  Pre-rspin    Pre-Patch   Post-patch
   ------------  ---------    ---------   ----------
        2          1,926        2,120        8,057
        4          1,391        1,320        7,680
        8            716          694        7,284
       16            618          606        6,542
       32            501          487        1,449
       64             61           57          480

This patch gives a big boost in performance for mixed reader/writer
workloads.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/lock_events_list.h |  1 +
 kernel/locking/rwsem-xadd.c       | 63 +++++++++++++++++++++++++++++++++++----
 kernel/locking/rwsem-xadd.h       | 45 +++++++++++++++++++++-------
 3 files changed, 94 insertions(+), 15 deletions(-)

diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
index 54b6650..0052534 100644
--- a/kernel/locking/lock_events_list.h
+++ b/kernel/locking/lock_events_list.h
@@ -60,6 +60,7 @@
 LOCK_EVENT(rwsem_opt_rlock)	/* # of read locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_wlock)	/* # of write locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_fail)	/* # of failed opt-spinnings		*/
+LOCK_EVENT(rwsem_opt_nospin)	/* # of disabled reader opt-spinnings	*/
 LOCK_EVENT(rwsem_rlock)		/* # of read locks acquired		*/
 LOCK_EVENT(rwsem_rlock_fast)	/* # of fast read locks acquired	*/
 LOCK_EVENT(rwsem_rlock_fail)	/* # of failed read lock acquisitions	*/
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 015edd6..3beb942 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -95,6 +95,22 @@ enum rwsem_wake_type {
 #define RWSEM_WAIT_TIMEOUT	((HZ - 1)/200 + 1)
 
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
  * - if we come here from up_xxxx(), then the RWSEM_FLAG_WAITERS bit must
  *   have been set.
@@ -324,7 +340,7 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	owner = rwsem_get_owner(sem);
 	if (owner) {
 		ret = is_rwsem_owner_spinnable(owner) &&
-		      owner_on_cpu(owner, sem);
+		     (is_rwsem_owner_reader(owner) || owner_on_cpu(owner, sem));
 	}
 	rcu_read_unlock();
 	lockevent_cond_inc(rwsem_opt_fail, !ret);
@@ -359,7 +375,8 @@ static noinline enum owner_state rwsem_spin_on_owner(struct rw_semaphore *sem)
 	 * This enables the spinner to move forward and do a trylock
 	 * earlier.
 	 */
-	while (owner && (READ_ONCE(sem->owner) = owner)) {
+	while (owner && !is_rwsem_owner_reader(owner)
+		     && (READ_ONCE(sem->owner) = owner)) {
 		/*
 		 * Ensure we emit the owner->on_cpu, dereference _after_
 		 * checking sem->owner still matches owner, if that fails,
@@ -394,6 +411,10 @@ static noinline enum owner_state rwsem_spin_on_owner(struct rw_semaphore *sem)
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 {
 	bool taken = false;
+	enum owner_state owner_state;
+	int rspin_cnt = RWSEM_RSPIN_THRESHOLD;
+	int rspin_max = RWSEM_RSPIN_MAX;
+	int old_rcount = 0;
 
 	preempt_disable();
 
@@ -401,14 +422,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	if (!osq_lock(&sem->osq))
 		goto done;
 
+	if (!is_rwsem_spinnable(sem))
+		rspin_cnt = 0;
+
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
 	 *  1) the owning writer isn't running; or
-	 *  2) readers own the lock as we can't determine if they are
-	 *     actively running or not.
+	 *  2) readers own the lock and spinning count has reached 0.
 	 */
-	while (rwsem_spin_on_owner(sem) = OWNER_SPINNABLE) {
+	while ((owner_state = rwsem_spin_on_owner(sem)) != OWNER_NONSPINNABLE) {
 		/*
 		 * Try to acquire the lock
 		 */
@@ -429,6 +452,36 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 			break;
 
 		/*
+		 * We only decremnt rspin_cnt when a writer is trying to
+		 * acquire a lock owned by readers. In which case,
+		 * rwsem_spin_on_owner() will essentially be a no-op
+		 * and we will be spinning in this main loop. The spinning
+		 * count will be reset whenever the rwsem count value
+		 * changes.
+		 */
+		if (wlock && (owner_state = OWNER_READER)) {
+			int rcount;
+
+			if (!rspin_cnt || !rspin_max) {
+				if (is_rwsem_spinnable(sem)) {
+					rwsem_set_nonspinnable(sem);
+					lockevent_inc(rwsem_opt_nospin);
+				}
+				break;
+			}
+
+			rcount = atomic_long_read(&sem->count)
+					>> RWSEM_READER_SHIFT;
+			if (rcount != old_rcount) {
+				old_rcount = rcount;
+				rspin_cnt = RWSEM_RSPIN_THRESHOLD;
+			} else {
+				rspin_cnt--;
+			}
+			rspin_max--;
+		}
+
+		/*
 		 * The cpu_relax() call is a compiler barrier which forces
 		 * everything in this loop to be re-loaded. We don't need
 		 * memory barriers as we'll eventually observe the right
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index eb4ef36..be67dbd 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -5,18 +5,20 @@
  *  - RWSEM_READER_OWNED (bit 0): The rwsem is owned by readers
  *  - RWSEM_ANONYMOUSLY_OWNED (bit 1): The rwsem is anonymously owned,
  *    i.e. the owner(s) cannot be readily determined. It can be reader
- *    owned or the owning writer is indeterminate.
+ *    owned or the owning writer is indeterminate. Optimistic spinning
+ *    should be disabled if this flag is set.
  *
  * When a writer acquires a rwsem, it puts its task_struct pointer
- * into the owner field. It is cleared after an unlock.
+ * into the owner field or the count itself (64-bit only. It should
+ * be cleared after an unlock.
  *
  * When a reader acquires a rwsem, it will also puts its task_struct
- * pointer into the owner field with both the RWSEM_READER_OWNED and
- * RWSEM_ANONYMOUSLY_OWNED bits set. On unlock, the owner field will
- * largely be left untouched. So for a free or reader-owned rwsem,
- * the owner value may contain information about the last reader that
- * acquires the rwsem. The anonymous bit is set because that particular
- * reader may or may not still own the lock.
+ * pointer into the owner field with the RWSEM_READER_OWNED bit set.
+ * On unlock, the owner field will largely be left untouched. So
+ * for a free or reader-owned rwsem, the owner value may contain
+ * information about the last reader that acquires the rwsem. The
+ * anonymous bit may also be set to permanently disable optimistic
+ * spinning on a reader-own rwsem until a writer comes along.
  *
  * That information may be helpful in debugging cases where the system
  * seems to hang on a reader owned rwsem especially if only one reader
@@ -182,8 +184,7 @@ static inline struct task_struct *rwsem_get_owner(struct rw_semaphore *sem)
 static inline void __rwsem_set_reader_owned(struct rw_semaphore *sem,
 					    struct task_struct *owner)
 {
-	unsigned long val = (unsigned long)owner | RWSEM_READER_OWNED
-						 | RWSEM_ANONYMOUSLY_OWNED;
+	unsigned long val = (unsigned long)owner | RWSEM_READER_OWNED;
 
 	WRITE_ONCE(sem->owner, (struct task_struct *)val);
 }
@@ -209,6 +210,14 @@ static inline bool is_rwsem_owner_reader(struct task_struct *owner)
 }
 
 /*
+ * Return true if the rwsem is spinnable.
+ */
+static inline bool is_rwsem_spinnable(struct rw_semaphore *sem)
+{
+	return is_rwsem_owner_spinnable(READ_ONCE(sem->owner));
+}
+
+/*
  * Return true if the rwsem is owned by a reader.
  */
 static inline bool is_rwsem_reader_owned(struct rw_semaphore *sem)
@@ -226,6 +235,22 @@ static inline bool is_rwsem_reader_owned(struct rw_semaphore *sem)
 }
 
 /*
+ * Set the RWSEM_ANONYMOUSLY_OWNED flag if the RWSEM_READER_OWNED flag
+ * remains set. Otherwise, the operation will be aborted.
+ */
+static inline void rwsem_set_nonspinnable(struct rw_semaphore *sem)
+{
+	long owner = (long)READ_ONCE(sem->owner);
+
+	while (is_rwsem_owner_reader((struct task_struct *)owner)) {
+		if (!is_rwsem_owner_spinnable((struct task_struct *)owner))
+			break;
+		owner = cmpxchg((long *)&sem->owner, owner,
+				owner | RWSEM_ANONYMOUSLY_OWNED);
+	}
+}
+
+/*
  * Return true if rwsem is owned by an anonymous writer or readers.
  */
 static inline bool rwsem_has_anonymous_owner(struct task_struct *owner)
-- 
1.8.3.1
