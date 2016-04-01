From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 01 Apr 2016 11:04:47 +0000
Subject: [PATCH 03/11] locking, rwsem: introduce basis for down_write_killable
Message-Id: <1459508695-14915-4-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Introduce a generic implementation necessary for down_write_killable.
This is a trivial extension of the already existing down_write call
which can be interrupted by SIGKILL.  This patch doesn't provide
down_write_killable yet because arches have to provide the necessary
pieces before.

rwsem_down_write_failed which is a generic slow path for the
write lock is extended to allow a task state and renamed to
__rwsem_down_write_failed_state. The return value is either a valid
semaphore pointer or ERR_PTR(-EINTR).

rwsem_down_write_failed_killable is exported as a new way to wait for
the lock and be killable.

For rwsem-spinlock implementation the current __down_write it updated
in a similar way as __rwsem_down_write_failed_state except it doesn't
need new exports just visible __down_write_killable.

Architectures which are not using the generic rwsem implementation are
supposed to provide their __down_write_killable implementation and
use rwsem_down_write_failed_killable for the slow path.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/asm-generic/rwsem.h     | 12 ++++++++++++
 include/linux/rwsem-spinlock.h  |  1 +
 include/linux/rwsem.h           |  2 ++
 kernel/locking/rwsem-spinlock.c | 22 ++++++++++++++++++++--
 kernel/locking/rwsem-xadd.c     | 31 +++++++++++++++++++++++++------
 5 files changed, 60 insertions(+), 8 deletions(-)

diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index b8d8a6cf4ca8..3fc94a046bf5 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -63,6 +63,18 @@ static inline void __down_write(struct rw_semaphore *sem)
 		rwsem_down_write_failed(sem);
 }
 
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	long tmp;
+
+	tmp = atomic_long_add_return_acquire(RWSEM_ACTIVE_WRITE_BIAS,
+				     (atomic_long_t *)&sem->count);
+	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
+		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
+			return -EINTR;
+	return 0;
+}
+
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
 	long tmp;
diff --git a/include/linux/rwsem-spinlock.h b/include/linux/rwsem-spinlock.h
index a733a5467e6c..ae0528b834cd 100644
--- a/include/linux/rwsem-spinlock.h
+++ b/include/linux/rwsem-spinlock.h
@@ -34,6 +34,7 @@ struct rw_semaphore {
 extern void __down_read(struct rw_semaphore *sem);
 extern int __down_read_trylock(struct rw_semaphore *sem);
 extern void __down_write(struct rw_semaphore *sem);
+extern int __must_check __down_write_killable(struct rw_semaphore *sem);
 extern int __down_write_trylock(struct rw_semaphore *sem);
 extern void __up_read(struct rw_semaphore *sem);
 extern void __up_write(struct rw_semaphore *sem);
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 8f498cdde280..7d7ae029dac5 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -14,6 +14,7 @@
 #include <linux/list.h>
 #include <linux/spinlock.h>
 #include <linux/atomic.h>
+#include <linux/err.h>
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 #include <linux/osq_lock.h>
 #endif
@@ -43,6 +44,7 @@ struct rw_semaphore {
 
 extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
diff --git a/kernel/locking/rwsem-spinlock.c b/kernel/locking/rwsem-spinlock.c
index bab26104a5d0..fb2db7b408f0 100644
--- a/kernel/locking/rwsem-spinlock.c
+++ b/kernel/locking/rwsem-spinlock.c
@@ -191,11 +191,12 @@ int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * get a write lock on the semaphore
  */
-void __sched __down_write(struct rw_semaphore *sem)
+int __sched __down_write_state(struct rw_semaphore *sem, int state)
 {
 	struct rwsem_waiter waiter;
 	struct task_struct *tsk;
 	unsigned long flags;
+	int ret = 0;
 
 	raw_spin_lock_irqsave(&sem->wait_lock, flags);
 
@@ -215,16 +216,33 @@ void __sched __down_write(struct rw_semaphore *sem)
 		 */
 		if (sem->count = 0)
 			break;
-		set_task_state(tsk, TASK_UNINTERRUPTIBLE);
+		if (signal_pending_state(state, current)) {
+			ret = -EINTR;
+			goto out;
+		}
+		set_task_state(tsk, state);
 		raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
 		schedule();
 		raw_spin_lock_irqsave(&sem->wait_lock, flags);
 	}
 	/* got the lock */
 	sem->count = -1;
+out:
 	list_del(&waiter.list);
 
 	raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
+
+	return ret;
+}
+
+void __sched __down_write(struct rw_semaphore *sem)
+{
+	__down_write_state(sem, TASK_UNINTERRUPTIBLE);
+}
+
+int __sched __down_write_killable(struct rw_semaphore *sem)
+{
+	return __down_write_state(sem, TASK_KILLABLE);
 }
 
 /*
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index a4d4de05b2d1..781b2628e41b 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -433,12 +433,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 /*
  * Wait until we successfully acquire the write lock
  */
-__visible
-struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
+static inline struct rw_semaphore *
+__rwsem_down_write_failed_state(struct rw_semaphore *sem, int state)
 {
 	long count;
 	bool waiting = true; /* any queued threads before us */
 	struct rwsem_waiter waiter;
+	struct rw_semaphore *ret = sem;
 
 	/* undo write bias from down_write operation, stop active locking */
 	count = rwsem_atomic_update(-RWSEM_ACTIVE_WRITE_BIAS, sem);
@@ -478,7 +479,7 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 		count = rwsem_atomic_update(RWSEM_WAITING_BIAS, sem);
 
 	/* wait until we successfully acquire the lock */
-	set_current_state(TASK_UNINTERRUPTIBLE);
+	set_current_state(state);
 	while (true) {
 		if (rwsem_try_write_lock(count, sem))
 			break;
@@ -486,21 +487,39 @@ struct rw_semaphore __sched *rwsem_down_write_failed(struct rw_semaphore *sem)
 
 		/* Block until there are no active lockers. */
 		do {
+			if (signal_pending_state(state, current)) {
+				raw_spin_lock_irq(&sem->wait_lock);
+				ret = ERR_PTR(-EINTR);
+				goto out;
+			}
 			schedule();
-			set_current_state(TASK_UNINTERRUPTIBLE);
+			set_current_state(state);
 		} while ((count = sem->count) & RWSEM_ACTIVE_MASK);
 
 		raw_spin_lock_irq(&sem->wait_lock);
 	}
+out:
 	__set_current_state(TASK_RUNNING);
-
 	list_del(&waiter.list);
 	raw_spin_unlock_irq(&sem->wait_lock);
 
-	return sem;
+	return ret;
+}
+
+__visible struct rw_semaphore * __sched
+rwsem_down_write_failed(struct rw_semaphore *sem)
+{
+	return __rwsem_down_write_failed_state(sem, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(rwsem_down_write_failed);
 
+__visible struct rw_semaphore * __sched
+rwsem_down_write_failed_killable(struct rw_semaphore *sem)
+{
+	return __rwsem_down_write_failed_state(sem, TASK_KILLABLE);
+}
+EXPORT_SYMBOL(rwsem_down_write_failed_killable);
+
 /*
  * handle waking up a waiter on the semaphore
  * - up_read/up_write has decremented the active part of count if we come here
-- 
2.8.0.rc3

