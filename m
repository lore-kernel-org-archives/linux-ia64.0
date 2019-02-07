From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:14 +0000
Subject: [PATCH-tip 10/22] locking/rwsem: Enable lock event counting
Message-Id: <1549566446-27967-11-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

Add lock event counting calls so that we can track the number of lock
events happening in the rwsem code.

With CONFIG_LOCK_EVENT_COUNTS on and booting a 1-socket 22-core
44-thread x86-64 system, the non-zero rwsem counts after system bootup
were as follows:

  rwsem_opt_fail3
  rwsem_opt_wlock647
  rwsem_rlock6
  rwsem_rlock_fast
  rwsem_wake_reader3
  rwsem_wake_writer9
  rwsem_wlock3

It can be seen that most of the lock acquisitions in the slowpath were
writer-locks in the optimistic spinning code path with no sleeping at
all. Only about 4% of locks were acquired after sleeping.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 arch/Kconfig                      |  2 +-
 kernel/locking/lock_events_list.h | 17 +++++++++++++++++
 kernel/locking/rwsem-xadd.c       | 12 ++++++++++++
 3 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index af147c2..7471791 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -891,7 +891,7 @@ config ARCH_USE_MEMREMAP_PROT
 config LOCK_EVENT_COUNTS
 	bool "Locking event counts collection"
 	depends on DEBUG_FS
-	depends on QUEUED_SPINLOCKS
+	depends on (QUEUED_SPINLOCKS || RWSEM_XCHGADD_ALGORITHM)
 	---help---
 	  Enable light-weight counting of various locking related events
 	  in the system with minimal performance impact. This reduces
diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
index 8b4d2e1..c33c5df 100644
--- a/kernel/locking/lock_events_list.h
+++ b/kernel/locking/lock_events_list.h
@@ -48,3 +48,20 @@
 LOCK_EVENT(lock_use_node4)	/* # of locking ops that use 4th percpu node */
 LOCK_EVENT(lock_no_node)	/* # of locking ops w/o using percpu node    */
 #endif /* CONFIG_QUEUED_SPINLOCKS */
+
+#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
+/*
+ * Locking events for rwsem
+ */
+LOCK_EVENT(rwsem_sleep_reader)	/* # of reader sleeps			*/
+LOCK_EVENT(rwsem_sleep_writer)	/* # of writer sleeps			*/
+LOCK_EVENT(rwsem_wake_reader)	/* # of reader wakeups			*/
+LOCK_EVENT(rwsem_wake_writer)	/* # of writer wakeups			*/
+LOCK_EVENT(rwsem_opt_wlock)	/* # of write locks opt-spin acquired	*/
+LOCK_EVENT(rwsem_opt_fail)	/* # of failed opt-spinnings		*/
+LOCK_EVENT(rwsem_rlock)		/* # of read locks acquired		*/
+LOCK_EVENT(rwsem_rlock_fast)	/* # of fast read locks acquired	*/
+LOCK_EVENT(rwsem_rlock_fail)	/* # of failed read lock acquisitions	*/
+LOCK_EVENT(rwsem_wlock)		/* # of write locks acquired		*/
+LOCK_EVENT(rwsem_wlock_fail)	/* # of failed write lock acquisitions	*/
+#endif /* CONFIG_RWSEM_XCHGADD_ALGORITHM */
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 62422a6..fff231a 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -20,6 +20,7 @@
 #include <linux/osq_lock.h>
 
 #include "rwsem-xadd.h"
+#include "lock_events.h"
 
 /*
  * Guide to the rw_semaphore's count field for common values.
@@ -147,6 +148,7 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			 * will notice the queued writer.
 			 */
 			wake_q_add(wake_q, waiter->task);
+			lockevent_inc(rwsem_wake_writer);
 		}
 
 		return;
@@ -214,6 +216,7 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 	}
 
 	adjustment = woken * RWSEM_ACTIVE_READ_BIAS - adjustment;
+	lockevent_cond_inc(rwsem_wake_reader, woken);
 	if (list_empty(&sem->wait_list)) {
 		/* hit end of list above */
 		adjustment -= RWSEM_WAITING_BIAS;
@@ -269,6 +272,7 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 				      count + RWSEM_ACTIVE_WRITE_BIAS);
 		if (old = count) {
 			rwsem_set_owner(sem);
+			lockevent_inc(rwsem_opt_wlock);
 			return true;
 		}
 
@@ -394,6 +398,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	osq_unlock(&sem->osq);
 done:
 	preempt_enable();
+	lockevent_cond_inc(rwsem_opt_fail, !taken);
 	return taken;
 }
 
@@ -441,6 +446,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		if (atomic_long_read(&sem->count) >= 0) {
 			raw_spin_unlock_irq(&sem->wait_lock);
 			rwsem_set_reader_owned(sem);
+			lockevent_inc(rwsem_rlock_fast);
 			return sem;
 		}
 		adjustment += RWSEM_WAITING_BIAS;
@@ -477,9 +483,11 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 			break;
 		}
 		schedule();
+		lockevent_inc(rwsem_sleep_reader);
 	}
 
 	__set_current_state(TASK_RUNNING);
+	lockevent_inc(rwsem_rlock);
 	return sem;
 out_nolock:
 	list_del(&waiter.list);
@@ -487,6 +495,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		atomic_long_add(-RWSEM_WAITING_BIAS, &sem->count);
 	raw_spin_unlock_irq(&sem->wait_lock);
 	__set_current_state(TASK_RUNNING);
+	lockevent_inc(rwsem_rlock_fail);
 	return ERR_PTR(-EINTR);
 }
 
@@ -580,6 +589,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 				goto out_nolock;
 
 			schedule();
+			lockevent_inc(rwsem_sleep_writer);
 			set_current_state(state);
 		} while ((count = atomic_long_read(&sem->count)) & RWSEM_ACTIVE_MASK);
 
@@ -588,6 +598,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	__set_current_state(TASK_RUNNING);
 	list_del(&waiter.list);
 	raw_spin_unlock_irq(&sem->wait_lock);
+	lockevent_inc(rwsem_wlock);
 
 	return ret;
 
@@ -601,6 +612,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		__rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 	raw_spin_unlock_irq(&sem->wait_lock);
 	wake_up_q(&wake_q);
+	lockevent_inc(rwsem_wlock_fail);
 
 	return ERR_PTR(-EINTR);
 }
-- 
1.8.3.1
