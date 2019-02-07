From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:15 +0000
Subject: [PATCH-tip 11/22] locking/rwsem: Implement a new locking scheme
Message-Id: <1549566446-27967-12-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

The current way of using various reader, writer and waiting biases
in the rwsem code are confusing and hard to understand. I have to
reread the rwsem count guide in the rwsem-xadd.c file from time to
time to remind myself how this whole thing works. It also makes the
rwsem code harder to be optimized.

To make rwsem more sane, a new locking scheme similar to the one in
qrwlock is now being used.  The count is now a 32-bit atomic value
in all architectures. The current bit definitions are:

  Bit  0   - writer locked bit
  Bit  1   - waiters present bit
  Bits 2-7 - reserved for future extension
  Bits 8-X - reader count (24/56 bits)

Now the cmpxchg instruction is used to acquire the write lock. The
read lock is still acquired with xadd instruction, so there is no
change here.  This scheme will allow up to 16M active readers which
should be more than enough. We can always use some more reserved bits
if necessary.

With that change, we can deterministically know if a rwsem has been
write-locked. Looking at the count alone, however, one cannot determine
for certain if a rwsem is owned by readers or not as the readers that
set the reader count bits may be in the process of backing out. So we
still need the reader-owned bit in the owner field to be sure.

With a locking microbenchmark running on 5.0 based kernel, the total
locking rates (in kops/s) of the benchmark on a 4-socket 56-core
x86-64 system before and after the patch were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        28,773   30,164   29,063   29,967
        2         7,435   15,167    6,746   13,198
        4         7,181   14,438    6,515   12,763
        8         6,918   13,796    6,747   13,419
       16         6,554   16,030    6,653   15,534

The locking rates of the benchmark on a Power9 system were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        11,527   12,378   11,527   12,195
        2         6,318   15,116    7,690   15,065
        4         3,957   16,812    4,495   16,884
        8         3,617   16,496    3,993   16,588

The locking rates of the benchmark on a 2-socket ARM64 system were
as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        23,703   23,208   23,923   23,167
        2         6,206   11,996    6,756   13,268
        4         6,098   12,343    6,928   15,064
        8         6,007   13,152    7,117   15,335

For x86, the locking rate dropped somewhat at low contention level with
the patch.  At high contention level, however, the performance recovered.
For both Power9 and ARM64, the patch caused no performance drop. In fact,
it improved a little bit after the patch.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 145 +++++++++++++++-----------------------------
 kernel/locking/rwsem-xadd.h |  85 +++++++++++++-------------
 2 files changed, 89 insertions(+), 141 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index fff231a..18a414e 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -9,6 +9,8 @@
  *
  * Optimistic spinning by Tim Chen <tim.c.chen@intel.com>
  * and Davidlohr Bueso <davidlohr@hp.com>. Based on mutexes.
+ *
+ * Rwsem count bit fields re-definition by Waiman Long <longman@redhat.com>.
  */
 #include <linux/rwsem.h>
 #include <linux/init.h>
@@ -23,52 +25,20 @@
 #include "lock_events.h"
 
 /*
- * Guide to the rw_semaphore's count field for common values.
- * (32-bit case illustrated, similar for 64-bit)
- *
- * 0x0000000X	(1) X readers active or attempting lock, no writer waiting
- *		    X = #active_readers + #readers attempting to lock
- *		    (X*ACTIVE_BIAS)
- *
- * 0x00000000	rwsem is unlocked, and no one is waiting for the lock or
- *		attempting to read lock or write lock.
- *
- * 0xffff000X	(1) X readers active or attempting lock, with waiters for lock
- *		    X = #active readers + # readers attempting lock
- *		    (X*ACTIVE_BIAS + WAITING_BIAS)
- *		(2) 1 writer attempting lock, no waiters for lock
- *		    X-1 = #active readers + #readers attempting lock
- *		    ((X-1)*ACTIVE_BIAS + ACTIVE_WRITE_BIAS)
- *		(3) 1 writer active, no waiters for lock
- *		    X-1 = #active readers + #readers attempting lock
- *		    ((X-1)*ACTIVE_BIAS + ACTIVE_WRITE_BIAS)
- *
- * 0xffff0001	(1) 1 reader active or attempting lock, waiters for lock
- *		    (WAITING_BIAS + ACTIVE_BIAS)
- *		(2) 1 writer active or attempting lock, no waiters for lock
- *		    (ACTIVE_WRITE_BIAS)
+ * Guide to the rw_semaphore's count field.
  *
- * 0xffff0000	(1) There are writers or readers queued but none active
- *		    or in the process of attempting lock.
- *		    (WAITING_BIAS)
- *		Note: writer can attempt to steal lock for this count by adding
- *		ACTIVE_WRITE_BIAS in cmpxchg and checking the old count
+ * When the RWSEM_WRITER_LOCKED bit in count is set, the lock is owned
+ * by a writer.
  *
- * 0xfffe0001	(1) 1 writer active, or attempting lock. Waiters on queue.
- *		    (ACTIVE_WRITE_BIAS + WAITING_BIAS)
- *
- * Note: Readers attempt to lock by adding ACTIVE_BIAS in down_read and checking
- *	 the count becomes more than 0 for successful lock acquisition,
- *	 i.e. the case where there are only readers or nobody has lock.
- *	 (1st and 2nd case above).
- *
- *	 Writers attempt to lock by adding ACTIVE_WRITE_BIAS in down_write and
- *	 checking the count becomes ACTIVE_WRITE_BIAS for successful lock
- *	 acquisition (i.e. nobody else has lock or attempts lock).  If
- *	 unsuccessful, in rwsem_down_write_failed, we'll check to see if there
- *	 are only waiters but none active (5th case above), and attempt to
- *	 steal the lock.
+ * The lock is owned by readers when
+ * (1) the RWSEM_WRITER_LOCKED isn't set in count,
+ * (2) some of the reader bits are set in count, and
+ * (3) the owner field has RWSEM_READ_OWNED bit set.
  *
+ * Having some reader bits set is not enough to guarantee a readers owned
+ * lock as the readers may be in the process of backing out from the count
+ * and a writer has just released the lock. So another writer may steal
+ * the lock immediately after that.
  */
 
 /*
@@ -114,9 +84,8 @@ enum rwsem_wake_type {
 
 /*
  * handle the lock release when processes blocked on it that can now run
- * - if we come here from up_xxxx(), then:
- *   - the 'active part' of count (&0x0000ffff) reached 0 (but may have changed)
- *   - the 'waiting part' of count (&0xffff0000) is -ve (and will still be so)
+ * - if we come here from up_xxxx(), then the RWSEM_FLAG_WAITERS bit must
+ *   have been set.
  * - there must be someone on the queue
  * - the wait_lock must be held by the caller
  * - tasks are marked for wakeup, the caller must later invoke wake_up_q()
@@ -160,22 +129,11 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 	 * so we can bail out early if a writer stole the lock.
 	 */
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
-		adjustment = RWSEM_ACTIVE_READ_BIAS;
- try_reader_grant:
+		adjustment = RWSEM_READER_BIAS;
 		oldcount = atomic_long_fetch_add(adjustment, &sem->count);
-		if (unlikely(oldcount < RWSEM_WAITING_BIAS)) {
-			/*
-			 * If the count is still less than RWSEM_WAITING_BIAS
-			 * after removing the adjustment, it is assumed that
-			 * a writer has stolen the lock. We have to undo our
-			 * reader grant.
-			 */
-			if (atomic_long_add_return(-adjustment, &sem->count) <
-			    RWSEM_WAITING_BIAS)
-				return;
-
-			/* Last active locker left. Retry waking readers. */
-			goto try_reader_grant;
+		if (unlikely(oldcount & RWSEM_WRITER_MASK)) {
+			atomic_long_sub(adjustment, &sem->count);
+			return;
 		}
 		/*
 		 * Set it to reader-owned to give spinners an early
@@ -215,11 +173,11 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		wake_q_add_safe(wake_q, tsk);
 	}
 
-	adjustment = woken * RWSEM_ACTIVE_READ_BIAS - adjustment;
+	adjustment = woken * RWSEM_READER_BIAS - adjustment;
 	lockevent_cond_inc(rwsem_wake_reader, woken);
 	if (list_empty(&sem->wait_list)) {
 		/* hit end of list above */
-		adjustment -= RWSEM_WAITING_BIAS;
+		adjustment -= RWSEM_FLAG_WAITERS;
 	}
 
 	if (adjustment)
@@ -233,22 +191,15 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
  */
 static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem)
 {
-	/*
-	 * Avoid trying to acquire write lock if count isn't RWSEM_WAITING_BIAS.
-	 */
-	if (count != RWSEM_WAITING_BIAS)
+	long new;
+
+	if (RWSEM_COUNT_LOCKED(count))
 		return false;
 
-	/*
-	 * Acquire the lock by trying to set it to ACTIVE_WRITE_BIAS. If there
-	 * are other tasks on the wait list, we need to add on WAITING_BIAS.
-	 */
-	count = list_is_singular(&sem->wait_list) ?
-			RWSEM_ACTIVE_WRITE_BIAS :
-			RWSEM_ACTIVE_WRITE_BIAS + RWSEM_WAITING_BIAS;
+	new = count + RWSEM_WRITER_LOCKED -
+	     (list_is_singular(&sem->wait_list) ? RWSEM_FLAG_WAITERS : 0);
 
-	if (atomic_long_cmpxchg_acquire(&sem->count, RWSEM_WAITING_BIAS, count)
-							= RWSEM_WAITING_BIAS) {
+	if (atomic_long_cmpxchg_acquire(&sem->count, count, new) = count) {
 		rwsem_set_owner(sem);
 		return true;
 	}
@@ -265,11 +216,11 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	long old, count = atomic_long_read(&sem->count);
 
 	while (true) {
-		if (!(count = 0 || count = RWSEM_WAITING_BIAS))
+		if (RWSEM_COUNT_LOCKED(count))
 			return false;
 
 		old = atomic_long_cmpxchg_acquire(&sem->count, count,
-				      count + RWSEM_ACTIVE_WRITE_BIAS);
+				count + RWSEM_WRITER_LOCKED);
 		if (old = count) {
 			rwsem_set_owner(sem);
 			lockevent_inc(rwsem_opt_wlock);
@@ -428,7 +379,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 static inline struct rw_semaphore __sched *
 __rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
 {
-	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
+	long count, adjustment = -RWSEM_READER_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
@@ -440,16 +391,16 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		/*
 		 * In case the wait queue is empty and the lock isn't owned
 		 * by a writer, this reader can exit the slowpath and return
-		 * immediately as its RWSEM_ACTIVE_READ_BIAS has already
-		 * been set in the count.
+		 * immediately as its RWSEM_READER_BIAS has already been
+		 * set in the count.
 		 */
-		if (atomic_long_read(&sem->count) >= 0) {
+		if (!(atomic_long_read(&sem->count) & RWSEM_WRITER_MASK)) {
 			raw_spin_unlock_irq(&sem->wait_lock);
 			rwsem_set_reader_owned(sem);
 			lockevent_inc(rwsem_rlock_fast);
 			return sem;
 		}
-		adjustment += RWSEM_WAITING_BIAS;
+		adjustment += RWSEM_FLAG_WAITERS;
 	}
 	list_add_tail(&waiter.list, &sem->wait_list);
 
@@ -462,9 +413,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 * If there are no writers and we are first in the queue,
 	 * wake our own waiter to join the existing active readers !
 	 */
-	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS &&
-	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
+	if (!RWSEM_COUNT_LOCKED(count) ||
+	   (!(count & RWSEM_WRITER_MASK) && (adjustment & RWSEM_FLAG_WAITERS)))
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 
 	raw_spin_unlock_irq(&sem->wait_lock);
@@ -492,7 +442,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 out_nolock:
 	list_del(&waiter.list);
 	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+		atomic_long_add(-RWSEM_FLAG_WAITERS, &sem->count);
 	raw_spin_unlock_irq(&sem->wait_lock);
 	__set_current_state(TASK_RUNNING);
 	lockevent_inc(rwsem_rlock_fail);
@@ -525,9 +475,6 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	struct rw_semaphore *ret = sem;
 	DEFINE_WAKE_Q(wake_q);
 
-	/* undo write bias from down_write operation, stop active locking */
-	count = atomic_long_sub_return(RWSEM_ACTIVE_WRITE_BIAS, &sem->count);
-
 	/* do optimistic spinning and steal lock if possible */
 	if (rwsem_optimistic_spin(sem))
 		return sem;
@@ -553,10 +500,12 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 		/*
 		 * If there were already threads queued before us and there are
-		 * no active writers, the lock must be read owned; so we try to
-		 * wake any read locks that were queued ahead of us.
+		 * no active writers and some readers, the lock must be read
+		 * owned; so we try to  any read locks that were queued ahead
+		 * of us.
 		 */
-		if (count > RWSEM_WAITING_BIAS) {
+		if (!(count & RWSEM_WRITER_MASK) &&
+		     (count & RWSEM_READER_MASK)) {
 			__rwsem_mark_wake(sem, RWSEM_WAKE_READERS, &wake_q);
 			/*
 			 * The wakeup is normally called _after_ the wait_lock
@@ -573,8 +522,9 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 			wake_q_init(&wake_q);
 		}
 
-	} else
-		count = atomic_long_add_return(RWSEM_WAITING_BIAS, &sem->count);
+	} else {
+		count = atomic_long_add_return(RWSEM_FLAG_WAITERS, &sem->count);
+	}
 
 	/* wait until we successfully acquire the lock */
 	set_current_state(state);
@@ -591,7 +541,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 			schedule();
 			lockevent_inc(rwsem_sleep_writer);
 			set_current_state(state);
-		} while ((count = atomic_long_read(&sem->count)) & RWSEM_ACTIVE_MASK);
+			count = atomic_long_read(&sem->count);
+		} while (RWSEM_COUNT_LOCKED(count));
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
@@ -607,7 +558,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	raw_spin_lock_irq(&sem->wait_lock);
 	list_del(&waiter.list);
 	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+		atomic_long_add(-RWSEM_FLAG_WAITERS, &sem->count);
 	else
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 	raw_spin_unlock_irq(&sem->wait_lock);
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 6d2478c..1febd17 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -37,24 +37,26 @@
 #endif
 
 /*
- * R/W semaphores originally for PPC using the stuff in lib/rwsem.c.
- * Adapted largely from include/asm-i386/rwsem.h
- * by Paul Mackerras <paulus@samba.org>.
- */
-
-/*
- * the semaphore definition
+ * The definition of the atomic counter in the semaphore:
+ *
+ * Bit  0   - writer locked bit
+ * Bit  1   - waiters present bit
+ * Bits 2-7 - reserved
+ * Bits 8-X - 24-bit (32-bit) or 56-bit reader count
+ *
+ * atomic_long_fetch_add() is used to obtain reader lock, whereas
+ * atomic_long_cmpxchg() will be used to obtain writer lock.
  */
-#ifdef CONFIG_64BIT
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
+#define RWSEM_WRITER_LOCKED	(1UL << 0)
+#define RWSEM_FLAG_WAITERS	(1UL << 1)
+#define RWSEM_READER_SHIFT	8
+#define RWSEM_READER_BIAS	(1UL << RWSEM_READER_SHIFT)
+#define RWSEM_READER_MASK	(~(RWSEM_READER_BIAS - 1))
+#define RWSEM_WRITER_MASK	RWSEM_WRITER_LOCKED
+#define RWSEM_LOCK_MASK		(RWSEM_WRITER_MASK|RWSEM_READER_MASK)
+#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_MASK|RWSEM_FLAG_WAITERS)
 
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+#define RWSEM_COUNT_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
@@ -169,7 +171,8 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
  */
 static inline void __down_read(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0)) {
+	if (unlikely(atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
+			&sem->count) & RWSEM_READ_FAILED_MASK)) {
 		rwsem_down_read_failed(sem);
 		DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner &
 					RWSEM_READER_OWNED), sem);
@@ -180,7 +183,8 @@ static inline void __down_read(struct rw_semaphore *sem)
 
 static inline int __down_read_killable(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0)) {
+	if (unlikely(atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
+			&sem->count) & RWSEM_READ_FAILED_MASK)) {
 		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
 			return -EINTR;
 		DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner &
@@ -195,9 +199,10 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 {
 	long tmp;
 
-	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
+	while (!((tmp = atomic_long_read(&sem->count)) &
+			RWSEM_READ_FAILED_MASK)) {
 		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
-				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
+				   tmp + RWSEM_READER_BIAS)) {
 			rwsem_set_reader_owned(sem);
 			return 1;
 		}
@@ -210,22 +215,16 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
  */
 static inline void __down_write(struct rw_semaphore *sem)
 {
-	long tmp;
-
-	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
-					     &sem->count);
-	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
+	if (unlikely(atomic_long_cmpxchg_acquire(&sem->count, 0,
+						 RWSEM_WRITER_LOCKED)))
 		rwsem_down_write_failed(sem);
 	rwsem_set_owner(sem);
 }
 
 static inline int __down_write_killable(struct rw_semaphore *sem)
 {
-	long tmp;
-
-	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
-					     &sem->count);
-	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
+	if (unlikely(atomic_long_cmpxchg_acquire(&sem->count, 0,
+						 RWSEM_WRITER_LOCKED)))
 		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
 			return -EINTR;
 	rwsem_set_owner(sem);
@@ -234,15 +233,11 @@ static inline int __down_write_killable(struct rw_semaphore *sem)
 
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
-	long tmp;
-
-	tmp = atomic_long_cmpxchg_acquire(&sem->count, RWSEM_UNLOCKED_VALUE,
-		      RWSEM_ACTIVE_WRITE_BIAS);
-	if (tmp = RWSEM_UNLOCKED_VALUE) {
+	bool taken = !atomic_long_cmpxchg_acquire(&sem->count, 0,
+						  RWSEM_WRITER_LOCKED);
+	if (taken)
 		rwsem_set_owner(sem);
-		return true;
-	}
-	return false;
+	return taken;
 }
 
 /*
@@ -255,8 +250,9 @@ static inline void __up_read(struct rw_semaphore *sem)
 	DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner & RWSEM_READER_OWNED),
 				sem);
 	rwsem_clear_reader_owned(sem);
-	tmp = atomic_long_dec_return_release(&sem->count);
-	if (unlikely(tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0))
+	tmp = atomic_long_add_return_release(-RWSEM_READER_BIAS, &sem->count);
+	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
+			= RWSEM_FLAG_WAITERS))
 		rwsem_wake(sem);
 }
 
@@ -267,8 +263,8 @@ static inline void __up_write(struct rw_semaphore *sem)
 {
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current, sem);
 	rwsem_clear_owner(sem);
-	if (unlikely(atomic_long_sub_return_release(RWSEM_ACTIVE_WRITE_BIAS,
-						    &sem->count) < 0))
+	if (unlikely(atomic_long_fetch_add_release(-RWSEM_WRITER_LOCKED,
+			&sem->count) & RWSEM_FLAG_WAITERS))
 		rwsem_wake(sem);
 }
 
@@ -287,8 +283,9 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
 	 * write side. As such, rely on RELEASE semantics.
 	 */
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current, sem);
-	tmp = atomic_long_add_return_release(-RWSEM_WAITING_BIAS, &sem->count);
+	tmp = atomic_long_fetch_add_release(
+		-RWSEM_WRITER_LOCKED+RWSEM_READER_BIAS, &sem->count);
 	rwsem_set_reader_owned(sem);
-	if (tmp < 0)
+	if (tmp & RWSEM_FLAG_WAITERS)
 		rwsem_downgrade_wake(sem);
 }
-- 
1.8.3.1
