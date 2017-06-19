From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 19 Jun 2017 18:02:26 +0000
Subject: [PATCH 2/7] rwsem-spinlock: Add killable versions of rwsem_down_read_failed()
Message-Id: <149789534632.9059.2901382369609922565.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
In-Reply-To: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

Rename rwsem_down_read_failed() in __rwsem_down_read_failed_common()
and teach it to abort waiting in case of pending signals and killable
state argument passed.

Note, that we shouldn't wake anybody up in EINTR path, as:

We check for (waiter.task) under spinlock before we go to out_nolock
path. Current task wasn't able to be woken up, so there are
a writer, owning the sem, or a writer, which is the first waiter.
In the both cases we shouldn't wake anybody. If there is a writer,
owning the sem, and we were the only waiter, remove RWSEM_WAITING_BIAS,
as there are no waiters anymore.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/rwsem.h       |    1 +
 kernel/locking/rwsem-xadd.c |   33 ++++++++++++++++++++++++++++++---
 2 files changed, 31 insertions(+), 3 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index dd1d14250340..0ad7318ff299 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -44,6 +44,7 @@ struct rw_semaphore {
 };
 
 extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
+extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *);
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 34e727f18e49..02f660666ab8 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -221,8 +221,8 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 /*
  * Wait for the read lock to be granted
  */
-__visible
-struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
+static inline struct rw_semaphore __sched *
+__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
 {
 	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
 	struct rwsem_waiter waiter;
@@ -255,17 +255,44 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 
 	/* wait to be given the lock */
 	while (true) {
-		set_current_state(TASK_UNINTERRUPTIBLE);
+		set_current_state(state);
 		if (!waiter.task)
 			break;
+		if (signal_pending_state(state, current)) {
+			raw_spin_lock_irq(&sem->wait_lock);
+			if (waiter.task)
+				goto out_nolock;
+			raw_spin_unlock_irq(&sem->wait_lock);
+			break;
+		}
 		schedule();
 	}
 
 	__set_current_state(TASK_RUNNING);
 	return sem;
+out_nolock:
+	list_del(&waiter.list);
+	if (list_empty(&sem->wait_list))
+		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
+	raw_spin_unlock_irq(&sem->wait_lock);
+	__set_current_state(TASK_RUNNING);
+	return ERR_PTR(-EINTR);
+}
+
+__visible struct rw_semaphore * __sched
+rwsem_down_read_failed(struct rw_semaphore *sem)
+{
+	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE);
 }
 EXPORT_SYMBOL(rwsem_down_read_failed);
 
+__visible struct rw_semaphore * __sched
+rwsem_down_read_failed_killable(struct rw_semaphore *sem)
+{
+	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE);
+}
+EXPORT_SYMBOL(rwsem_down_read_failed_killable);
+
 /*
  * This function must be called with the sem->wait_lock held to prevent
  * race conditions between checking the rwsem wait list and setting the

