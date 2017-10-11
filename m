From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:01:53 +0000
Subject: [PATCH v6 02/11] locking/rwsem: Implement a new locking scheme
Message-Id: <1507744922-15196-3-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The current way of using various reader, writer and waiting biases
in the rwsem code are confusing and hard to understand. I have to
reread the rwsem count guide in the rwsem-xadd.c file from time to
time to remind myself how this whole thing works. It also makes the
rwsem code harder to be optimized.

To make rwsem more sane, a new locking scheme similar to the one in
qrwlock is now being used.  The count is now a 32-bit atomic value
in all architectures. The current bit definitions are:

  Bit  0    - writer locked bit
  Bit  1    - waiters present bit
  Bits 2-7  - reserved for future extension
  Bits 8-31 - reader count

Now the cmpxchg instruction is used to acquire the write lock. The
read lock is still acquired with xadd instruction, so there is no
change here.  This scheme will allow up to 16M active readers which
should be more than enough. We can always use some more reserved bits
if necessary.

The same generic locking code will be used for all the architectures
and the architecture specific files will be retired.

This patch also hide the fastpath implementation of rwsem (now in
kernel/locking/rwsem-xadd.h) from the other kernel code as
include/linux/rwsem.h will not include it.

With a locking microbenchmark running on 3.13 based kernel, the total
locking rates (in Mops/s) of the benchmark on a 2-socket 36-core
x86-64 system before and after the patch were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        39.039   33.401   40.432   33.093
        2         9.767   17.250   11.424   18.763
        4         9.069   17.580   10.085   17.372
        8         9.390   15.372   11.733   14.507

The locking rates of the benchmark on a 16-processor Power8 system
were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        15.086   13.738    9.373   13.597
        2         4.864    6.280    5.514    6.309
        4         3.286    4.932    4.153    5.011
        8         2.637    2.248    3.528    2.189

The locking rates of the benchmark on a 32-core Cavium ARM64 system
were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        4.849    3.972    5.194    4.223
        2        3.165    4.628    3.077    4.885
        4        0.742    3.856    0.716    4.136
        8        1.639    2.443    1.330    2.475

For read lock, locking performance was about the same before and
after the patch. For write lock, the new code had better contended
performance (2 or more threads) for both x86 and ppc, but it seemed to
slow down a bit in arm64. The uncontended performance, however, suffers
quite a bit in ppc, but not in x86 and arm64. So cmpxchg does have a
noticeable higher cost than xadd in ppc, the elimination of the atomic
count reversal in slowpath helps the contended performance, though.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/asm-generic/rwsem.h   | 129 -------------------------------------
 include/linux/rwsem.h         |  12 ++--
 kernel/locking/percpu-rwsem.c |   2 +
 kernel/locking/rwsem-xadd.c   | 145 ++++++++++++++----------------------------
 kernel/locking/rwsem-xadd.h   | 117 ++++++++++++++++++++++++++++++++++
 kernel/locking/rwsem.h        |   4 ++
 6 files changed, 174 insertions(+), 235 deletions(-)
 delete mode 100644 include/asm-generic/rwsem.h
 create mode 100644 kernel/locking/rwsem-xadd.h

diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
deleted file mode 100644
index 6c6a214..0000000
--- a/include/asm-generic/rwsem.h
+++ /dev/null
@@ -1,129 +0,0 @@
-#ifndef _ASM_GENERIC_RWSEM_H
-#define _ASM_GENERIC_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "Please don't include <asm/rwsem.h> directly, use <linux/rwsem.h> instead."
-#endif
-
-#ifdef __KERNEL__
-
-/*
- * R/W semaphores originally for PPC using the stuff in lib/rwsem.c.
- * Adapted largely from include/asm-i386/rwsem.h
- * by Paul Mackerras <paulus@samba.org>.
- */
-
-/*
- * the semaphore definition
- */
-#ifdef CONFIG_64BIT
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0))
-		rwsem_down_read_failed(sem);
-}
-
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
-		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
-				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
-			return 1;
-		}
-	}
-	return 0;
-}
-
-/*
- * lock for writing
- */
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
-					     &sem->count);
-	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
-		rwsem_down_write_failed(sem);
-}
-
-static inline int __down_write_killable(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
-					     &sem->count);
-	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
-		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
-			return -EINTR;
-	return 0;
-}
-
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic_long_cmpxchg_acquire(&sem->count, RWSEM_UNLOCKED_VALUE,
-		      RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp = RWSEM_UNLOCKED_VALUE;
-}
-
-/*
- * unlock after reading
- */
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic_long_dec_return_release(&sem->count);
-	if (unlikely(tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0))
-		rwsem_wake(sem);
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	if (unlikely(atomic_long_sub_return_release(RWSEM_ACTIVE_WRITE_BIAS,
-						    &sem->count) < 0))
-		rwsem_wake(sem);
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	/*
-	 * When downgrading from exclusive to shared ownership,
-	 * anything inside the write-locked region cannot leak
-	 * into the read side. In contrast, anything in the
-	 * read-locked region is ok to be re-ordered into the
-	 * write side. As such, rely on RELEASE semantics.
-	 */
-	tmp = atomic_long_add_return_release(-RWSEM_WAITING_BIAS, &sem->count);
-	if (tmp < 0)
-		rwsem_downgrade_wake(sem);
-}
-
-#endif	/* __KERNEL__ */
-#endif	/* _ASM_GENERIC_RWSEM_H */
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 0ad7318..d0f59df 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -25,11 +25,10 @@
 #include <linux/rwsem-spinlock.h> /* use a generic implementation */
 #define __RWSEM_INIT_COUNT(name)	.count = RWSEM_UNLOCKED_VALUE
 #else
-/* All arch specific implementations share the same struct */
 struct rw_semaphore {
-	atomic_long_t count;
-	struct list_head wait_list;
+	atomic_t count;
 	raw_spinlock_t wait_lock;
+	struct list_head wait_list;
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	struct optimistic_spin_queue osq; /* spinner MCS lock */
 	/*
@@ -50,16 +49,15 @@ struct rw_semaphore {
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
-/* Include the arch specific part */
-#include <asm/rwsem.h>
+#define RWSEM_UNLOCKED_VALUE	0
 
 /* In all implementations count != 0 means locked */
 static inline int rwsem_is_locked(struct rw_semaphore *sem)
 {
-	return atomic_long_read(&sem->count) != 0;
+	return atomic_read(&sem->count) != RWSEM_UNLOCKED_VALUE;
 }
 
-#define __RWSEM_INIT_COUNT(name)	.count = ATOMIC_LONG_INIT(RWSEM_UNLOCKED_VALUE)
+#define __RWSEM_INIT_COUNT(name)	.count = ATOMIC_INIT(RWSEM_UNLOCKED_VALUE)
 #endif
 
 /* Common initializer macros and functions */
diff --git a/kernel/locking/percpu-rwsem.c b/kernel/locking/percpu-rwsem.c
index 883cf1b..f17dad9 100644
--- a/kernel/locking/percpu-rwsem.c
+++ b/kernel/locking/percpu-rwsem.c
@@ -7,6 +7,8 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 
+#include "rwsem.h"
+
 int __percpu_init_rwsem(struct percpu_rw_semaphore *sem,
 			const char *name, struct lock_class_key *rwsem_key)
 {
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index db5dedf..39dc5be 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -21,52 +21,20 @@
 #include "rwsem.h"
 
 /*
- * Guide to the rw_semaphore's count field for common values.
- * (32-bit case illustrated, similar for 64-bit)
+ * Guide to the rw_semaphore's count field.
  *
- * 0x0000000X	(1) X readers active or attempting lock, no writer waiting
- *		    X = #active_readers + #readers attempting to lock
- *		    (X*ACTIVE_BIAS)
+ * When the RWSEM_WRITER_LOCKED bit in count is set, the lock is owned
+ * by a writer.
  *
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
- *
- * 0xffff0000	(1) There are writers or readers queued but none active
- *		    or in the process of attempting lock.
- *		    (WAITING_BIAS)
- *		Note: writer can attempt to steal lock for this count by adding
- *		ACTIVE_WRITE_BIAS in cmpxchg and checking the old count
- *
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
+ * (3) the owner field is RWSEM_READ_OWNED.
  *
+ * Having some reader bits set is not enough to guarantee a readers owned
+ * lock as the readers may be in the process of backing out from the count
+ * and a writer has just released the lock. So another writer may steal
+ * the lock immediately after that.
  */
 
 /*
@@ -82,7 +50,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 	debug_check_no_locks_freed((void *)sem, sizeof(*sem));
 	lockdep_init_map(&sem->dep_map, name, key, 0);
 #endif
-	atomic_long_set(&sem->count, RWSEM_UNLOCKED_VALUE);
+	atomic_set(&sem->count, RWSEM_UNLOCKED_VALUE);
 	raw_spin_lock_init(&sem->wait_lock);
 	INIT_LIST_HEAD(&sem->wait_list);
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
@@ -128,7 +96,7 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			      struct wake_q_head *wake_q)
 {
 	struct rwsem_waiter *waiter, *tmp;
-	long oldcount, woken = 0, adjustment = 0;
+	int oldcount, woken = 0, adjustment = 0;
 
 	/*
 	 * Take a peek at the queue head waiter such that we can determine
@@ -157,22 +125,11 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 	 * so we can bail out early if a writer stole the lock.
 	 */
 	if (wake_type != RWSEM_WAKE_READ_OWNED) {
-		adjustment = RWSEM_ACTIVE_READ_BIAS;
- try_reader_grant:
-		oldcount = atomic_long_fetch_add(adjustment, &sem->count);
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
+		adjustment = RWSEM_READER_BIAS;
+		oldcount = atomic_fetch_add(adjustment, &sem->count);
+		if (unlikely(oldcount & RWSEM_WRITER_LOCKED)) {
+			atomic_sub(adjustment, &sem->count);
+			return;
 		}
 		/*
 		 * It is not really necessary to set it to reader-owned here,
@@ -208,14 +165,14 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		smp_store_release(&waiter->task, NULL);
 	}
 
-	adjustment = woken * RWSEM_ACTIVE_READ_BIAS - adjustment;
+	adjustment = woken * RWSEM_READER_BIAS - adjustment;
 	if (list_empty(&sem->wait_list)) {
 		/* hit end of list above */
-		adjustment -= RWSEM_WAITING_BIAS;
+		adjustment -= RWSEM_FLAG_WAITERS;
 	}
 
 	if (adjustment)
-		atomic_long_add(adjustment, &sem->count);
+		atomic_add(adjustment, &sem->count);
 }
 
 /*
@@ -223,24 +180,17 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
  * race conditions between checking the rwsem wait list and setting the
  * sem->count accordingly.
  */
-static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem)
+static inline bool rwsem_try_write_lock(int count, struct rw_semaphore *sem)
 {
-	/*
-	 * Avoid trying to acquire write lock if count isn't RWSEM_WAITING_BIAS.
-	 */
-	if (count != RWSEM_WAITING_BIAS)
+	int new;
+
+	if (RWSEM_COUNT_IS_LOCKED(count))
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
+	if (atomic_cmpxchg_acquire(&sem->count, count, new) = count) {
 		rwsem_set_owner(sem);
 		return true;
 	}
@@ -254,14 +204,14 @@ static inline bool rwsem_try_write_lock(long count, struct rw_semaphore *sem)
  */
 static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 {
-	long old, count = atomic_long_read(&sem->count);
+	int old, count = atomic_read(&sem->count);
 
 	while (true) {
-		if (!(count = 0 || count = RWSEM_WAITING_BIAS))
+		if (RWSEM_COUNT_IS_LOCKED(count))
 			return false;
 
-		old = atomic_long_cmpxchg_acquire(&sem->count, count,
-				      count + RWSEM_ACTIVE_WRITE_BIAS);
+		old = atomic_cmpxchg_acquire(&sem->count, count,
+				count + RWSEM_WRITER_LOCKED);
 		if (old = count) {
 			rwsem_set_owner(sem);
 			return true;
@@ -418,7 +368,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 static inline struct rw_semaphore __sched *
 __rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
 {
-	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
+	int count, adjustment = -RWSEM_READER_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
@@ -427,11 +377,11 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 	raw_spin_lock_irq(&sem->wait_lock);
 	if (list_empty(&sem->wait_list))
-		adjustment += RWSEM_WAITING_BIAS;
+		adjustment += RWSEM_FLAG_WAITERS;
 	list_add_tail(&waiter.list, &sem->wait_list);
 
 	/* we're now waiting on the lock, but no longer actively locking */
-	count = atomic_long_add_return(adjustment, &sem->count);
+	count = atomic_add_return(adjustment, &sem->count);
 
 	/*
 	 * If there are no active locks, wake the front queued process(es).
@@ -439,9 +389,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	 * If there are no writers and we are first in the queue,
 	 * wake our own waiter to join the existing active readers !
 	 */
-	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS &&
-	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
+	if (!RWSEM_COUNT_IS_LOCKED(count))
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 
 	raw_spin_unlock_irq(&sem->wait_lock);
@@ -467,7 +415,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 out_nolock:
 	list_del(&waiter.list);
 	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+		atomic_add(-RWSEM_FLAG_WAITERS, &sem->count);
 	raw_spin_unlock_irq(&sem->wait_lock);
 	__set_current_state(TASK_RUNNING);
 	return ERR_PTR(-EINTR);
@@ -493,15 +441,12 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 static inline struct rw_semaphore *
 __rwsem_down_write_failed_common(struct rw_semaphore *sem, int state)
 {
-	long count;
+	int count;
 	bool waiting = true; /* any queued threads before us */
 	struct rwsem_waiter waiter;
 	struct rw_semaphore *ret = sem;
 	DEFINE_WAKE_Q(wake_q);
 
-	/* undo write bias from down_write operation, stop active locking */
-	count = atomic_long_sub_return(RWSEM_ACTIVE_WRITE_BIAS, &sem->count);
-
 	/* do optimistic spinning and steal lock if possible */
 	if (rwsem_optimistic_spin(sem))
 		return sem;
@@ -523,14 +468,14 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 	/* we're now waiting on the lock, but no longer actively locking */
 	if (waiting) {
-		count = atomic_long_read(&sem->count);
+		count = atomic_read(&sem->count);
 
 		/*
 		 * If there were already threads queued before us and there are
 		 * no active writers, the lock must be read owned; so we try to
 		 * wake any read locks that were queued ahead of us.
 		 */
-		if (count > RWSEM_WAITING_BIAS) {
+		if (!(count & RWSEM_WRITER_LOCKED)) {
 			__rwsem_mark_wake(sem, RWSEM_WAKE_READERS, &wake_q);
 			/*
 			 * The wakeup is normally called _after_ the wait_lock
@@ -547,8 +492,9 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 			wake_q_init(&wake_q);
 		}
 
-	} else
-		count = atomic_long_add_return(RWSEM_WAITING_BIAS, &sem->count);
+	} else {
+		count = atomic_add_return(RWSEM_FLAG_WAITERS, &sem->count);
+	}
 
 	/* wait until we successfully acquire the lock */
 	set_current_state(state);
@@ -564,7 +510,8 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 
 			schedule();
 			set_current_state(state);
-		} while ((count = atomic_long_read(&sem->count)) & RWSEM_ACTIVE_MASK);
+			count = atomic_read(&sem->count);
+		} while (RWSEM_COUNT_IS_LOCKED(count));
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
@@ -579,7 +526,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	raw_spin_lock_irq(&sem->wait_lock);
 	list_del(&waiter.list);
 	if (list_empty(&sem->wait_list))
-		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+		atomic_add(-RWSEM_FLAG_WAITERS, &sem->count);
 	else
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 	raw_spin_unlock_irq(&sem->wait_lock);
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
new file mode 100644
index 0000000..3820719
--- /dev/null
+++ b/kernel/locking/rwsem-xadd.h
@@ -0,0 +1,117 @@
+#ifndef _ASM_GENERIC_RWSEM_H
+#define _ASM_GENERIC_RWSEM_H
+
+#include <linux/rwsem.h>
+
+/*
+ * The definition of the atomic counter in the semaphore:
+ *
+ * Bit  0    - writer locked bit
+ * Bit  1    - waiters present bit
+ * Bits 2-7  - reserved
+ * Bits 8-31 - 24-bit reader count
+ *
+ * atomic_fetch_add() is used to obtain reader lock, whereas atomic_cmpxchg()
+ * will be used to obtain writer lock.
+ */
+#define RWSEM_WRITER_LOCKED	0X00000001
+#define RWSEM_FLAG_WAITERS	0X00000002
+#define RWSEM_READER_BIAS	0x00000100
+#define RWSEM_READER_SHIFT	8
+#define RWSEM_READER_MASK	(~((1U << RWSEM_READER_SHIFT) - 1))
+#define RWSEM_LOCK_MASK 	(RWSEM_WRITER_LOCKED|RWSEM_READER_MASK)
+#define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_LOCKED|RWSEM_FLAG_WAITERS)
+
+#define RWSEM_COUNT_IS_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
+
+/*
+ * lock for reading
+ */
+static inline void __down_read(struct rw_semaphore *sem)
+{
+	if (unlikely(atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count)
+		     & RWSEM_READ_FAILED_MASK))
+		rwsem_down_read_failed(sem);
+}
+
+static inline int __down_read_trylock(struct rw_semaphore *sem)
+{
+	int tmp;
+
+	while (!((tmp = atomic_read(&sem->count)) & RWSEM_READ_FAILED_MASK)) {
+		if (tmp = atomic_cmpxchg_acquire(&sem->count, tmp,
+				   tmp + RWSEM_READER_BIAS)) {
+			return 1;
+		}
+	}
+	return 0;
+}
+
+/*
+ * lock for writing
+ */
+static inline void __down_write(struct rw_semaphore *sem)
+{
+	if (unlikely(atomic_cmpxchg_acquire(&sem->count, 0,
+					    RWSEM_WRITER_LOCKED)))
+		rwsem_down_write_failed(sem);
+}
+
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	if (unlikely(atomic_cmpxchg_acquire(&sem->count, 0,
+					    RWSEM_WRITER_LOCKED)))
+		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
+			return -EINTR;
+	return 0;
+}
+
+static inline int __down_write_trylock(struct rw_semaphore *sem)
+{
+	return !atomic_cmpxchg_acquire(&sem->count, 0, RWSEM_WRITER_LOCKED);
+}
+
+/*
+ * unlock after reading
+ */
+static inline void __up_read(struct rw_semaphore *sem)
+{
+	int tmp;
+
+	tmp = atomic_add_return_release(-RWSEM_READER_BIAS, &sem->count);
+	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
+			= RWSEM_FLAG_WAITERS))
+		rwsem_wake(sem);
+}
+
+/*
+ * unlock after writing
+ */
+static inline void __up_write(struct rw_semaphore *sem)
+{
+	if (unlikely(atomic_fetch_add_release(-RWSEM_WRITER_LOCKED,
+			&sem->count) & RWSEM_FLAG_WAITERS))
+		rwsem_wake(sem);
+}
+
+/*
+ * downgrade write lock to read lock
+ */
+static inline void __downgrade_write(struct rw_semaphore *sem)
+{
+	int tmp;
+
+	/*
+	 * When downgrading from exclusive to shared ownership,
+	 * anything inside the write-locked region cannot leak
+	 * into the read side. In contrast, anything in the
+	 * read-locked region is ok to be re-ordered into the
+	 * write side. As such, rely on RELEASE semantics.
+	 */
+	tmp = atomic_fetch_add_release(-RWSEM_WRITER_LOCKED+RWSEM_READER_BIAS,
+					&sem->count);
+	if (tmp & RWSEM_FLAG_WAITERS)
+		rwsem_downgrade_wake(sem);
+}
+
+#endif	/* _ASM_GENERIC_RWSEM_H */
diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
index a699f40..adcc5af 100644
--- a/kernel/locking/rwsem.h
+++ b/kernel/locking/rwsem.h
@@ -66,3 +66,7 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
 }
 #endif
+
+#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
+#include "rwsem-xadd.h"
+#endif
-- 
1.8.3.1

