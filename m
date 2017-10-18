From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:27 +0000
Subject: [PATCH-tip v7 11/15] locking/rwsem: Remove rwsem_wake spinlock optimization
Message-Id: <1508351431-22375-12-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The rwsem_wake spinlock optimization was originally put there to
reduce lock contention in the wait_lock. However, the usefulness of
this optimization has been reduced because of the followings:

 1) The use of wake_q recently in the wakeup path has greatly
    reduce the wait_lock hold time.
 2) Contending writers used to produce false positive calls to
    rwsem_wake without waiter rather easily with the original locking
    scheme. This is no longer the case with the new locking scheme.
 3) Reader optimistic spinning reduces the chance of having waiters
    in the wait queue.

On the other hand, the complexity of making sure there is no missed
wakeup keeps increasing.  It is at a point where the drawback outgrows
its usefulness. So the optimization code is now taken out.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 62 +--------------------------------------------
 kernel/locking/rwsem-xadd.h |  6 ++---
 2 files changed, 4 insertions(+), 64 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 8205910..ba00795 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -714,72 +714,12 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
  * - up_read/up_write has decremented the active part of count if we come here
  */
 __visible
-struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, int count)
+struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem)
 {
 	unsigned long flags;
 	DEFINE_WAKE_Q(wake_q);
 
-	/*
-	* __rwsem_down_write_failed_common(sem)
-	*   rwsem_optimistic_spin(sem)
-	*     osq_unlock(sem->osq)
-	*   ...
-	*   atomic_long_add_return(&sem->count)
-	*
-	*      - VS -
-	*
-	*              __up_write()
-	*                if (atomic_long_sub_return_release(&sem->count) < 0)
-	*                  rwsem_wake(sem)
-	*                    osq_is_locked(&sem->osq)
-	*
-	* And __up_write() must observe !osq_is_locked() when it observes the
-	* atomic_long_add_return() in order to not miss a wakeup.
-	*
-	* This boils down to:
-	*
-	* [S.rel] X = 1                [RmW] r0 = (Y += 0)
-	*         MB                         RMB
-	* [RmW]   Y += 1               [L]   r1 = X
-	*
-	* exists (r0=1 /\ r1=0)
-	*/
-	smp_rmb();
-
-	/*
-	 * If a spinner is present and the handoff flag isn't set, it is
-	 * not necessary to do the wakeup.
-	 *
-	 * Try to do wakeup only if the trylock succeeds to minimize
-	 * spinlock contention which may introduce too much delay in the
-	 * unlock operation.
-	 *
-	 *    spinning writer		up_write/up_read caller
-	 *    ---------------		-----------------------
-	 * [S]   osq_unlock()		[L]   osq
-	 *	 MB			      RMB
-	 * [RmW] rwsem_try_write_lock() [RmW] spin_trylock(wait_lock)
-	 *
-	 * Here, it is important to make sure that there won't be a missed
-	 * wakeup while the rwsem is free and the only spinning writer goes
-	 * to sleep without taking the rwsem. Even when the spinning writer
-	 * is just going to break out of the waiting loop, it will still do
-	 * a trylock in rwsem_down_write_failed() before sleeping. IOW, if
-	 * rwsem_has_spinner() is true, it will guarantee at least one
-	 * trylock attempt on the rwsem later on.
-	 */
-	if (rwsem_has_spinner(sem) && !RWSEM_COUNT_HANDOFF(count)) {
-		/*
-		 * The smp_rmb() here is to make sure that the spinner
-		 * state is consulted before reading the wait_lock.
-		 */
-		smp_rmb();
-		if (!raw_spin_trylock_irqsave(&sem->wait_lock, flags))
-			return sem;
-		goto locked;
-	}
 	raw_spin_lock_irqsave(&sem->wait_lock, flags);
-locked:
 
 	if (!list_empty(&sem->wait_list))
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 2429d8e..1e87e85 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -139,7 +139,7 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *, int count);
+extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
 /*
@@ -224,7 +224,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 	tmp = atomic_add_return_release(-RWSEM_READER_BIAS, &sem->count);
 	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
 			= RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem, tmp);
+		rwsem_wake(sem);
 }
 
 /*
@@ -237,7 +237,7 @@ static inline void __up_write(struct rw_semaphore *sem)
 	rwsem_clear_owner(sem);
 	tmp = atomic_fetch_add_release(-RWSEM_WRITER_LOCKED, &sem->count);
 	if (unlikely(tmp & RWSEM_FLAG_WAITERS))
-		rwsem_wake(sem, tmp);
+		rwsem_wake(sem);
 }
 
 /*
-- 
1.8.3.1

