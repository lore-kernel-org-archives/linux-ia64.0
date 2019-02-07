From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:17 +0000
Subject: [PATCH-tip 13/22] locking/rwsem: Remove rwsem_wake() wakeup optimization
Message-Id: <1549566446-27967-14-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

With the commit 59aabfc7e959 ("locking/rwsem: Reduce spinlock contention
in wakeup after up_read()/up_write()"), the rwsem_wake() forgoes doing
a wakeup if the wait_lock cannot be directly acquired and an optimistic
spinning locker is present.  This can help performance by avoiding
spinning on the wait_lock when it is contended.

With the later commit 133e89ef5ef3 ("locking/rwsem: Enable lockless
waiter wakeup(s)"), the performance advantage of the above optimization
diminishes as the average wait_lock hold time become much shorter.

By supporting rwsem lock handoff, we can no longer relies on the fact
that the presence of an optimistic spinning locker will ensure that the
lock will be acquired by a task soon. This can lead to missed wakeup
and application hang. So the commit 59aabfc7e959 ("locking/rwsem:
Reduce spinlock contention in wakeup after up_read()/up_write()")
will have to be reverted.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 74 ---------------------------------------------
 1 file changed, 74 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 12b1d61..5f74bae 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -378,25 +378,11 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	lockevent_cond_inc(rwsem_opt_fail, !taken);
 	return taken;
 }
-
-/*
- * Return true if the rwsem has active spinner
- */
-static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
-{
-	return osq_is_locked(&sem->osq);
-}
-
 #else
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 {
 	return false;
 }
-
-static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
-{
-	return false;
-}
 #endif
 
 /*
@@ -662,67 +648,7 @@ struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, long count)
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
-- 
1.8.3.1
