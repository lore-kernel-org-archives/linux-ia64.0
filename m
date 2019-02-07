From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:09 +0000
Subject: [PATCH-tip 05/22] locking/rwsem: Move owner setting code from rwsem.c to rwsem.h
Message-Id: <1549566446-27967-6-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

The setting of owner field is specific to rwsem-xadd code, it is not needed
for rwsem-spinlock. This patch moves all the owner setting code closer
to the rwsem-xadd fast paths directly within rwsem.h file.

For __down_read() and __down_read_killable(), it is assumed that
rwsem will be marked as reader-owned when the functions return. That
is currently true except in the transient case that the waiter queue
just becomes empty. So a rwsem_set_reader_owned() call is added for
this case. The __rwsem_set_reader_owned() call in __rwsem_mark_wake()
is now necessary.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c |  6 +++---
 kernel/locking/rwsem.c      | 19 ++-----------------
 kernel/locking/rwsem.h      | 17 +++++++++++++++--
 3 files changed, 20 insertions(+), 22 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 0d518b5..c213869 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -176,9 +176,8 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			goto try_reader_grant;
 		}
 		/*
-		 * It is not really necessary to set it to reader-owned here,
-		 * but it gives the spinners an early indication that the
-		 * readers now have the lock.
+		 * Set it to reader-owned to give spinners an early
+		 * indication that readers now have the lock.
 		 */
 		__rwsem_set_reader_owned(sem, waiter->task);
 	}
@@ -441,6 +440,7 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 		 */
 		if (atomic_long_read(&sem->count) >= 0) {
 			raw_spin_unlock_irq(&sem->wait_lock);
+			rwsem_set_reader_owned(sem);
 			return sem;
 		}
 		adjustment += RWSEM_WAITING_BIAS;
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index e586f0d..59e5848 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -24,7 +24,6 @@ void __sched down_read(struct rw_semaphore *sem)
 	rwsem_acquire_read(&sem->dep_map, 0, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
-	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read);
@@ -39,7 +38,6 @@ int __sched down_read_killable(struct rw_semaphore *sem)
 		return -EINTR;
 	}
 
-	rwsem_set_reader_owned(sem);
 	return 0;
 }
 
@@ -52,10 +50,8 @@ int down_read_trylock(struct rw_semaphore *sem)
 {
 	int ret = __down_read_trylock(sem);
 
-	if (ret = 1) {
+	if (ret = 1)
 		rwsem_acquire_read(&sem->dep_map, 0, 1, _RET_IP_);
-		rwsem_set_reader_owned(sem);
-	}
 	return ret;
 }
 
@@ -70,7 +66,6 @@ void __sched down_write(struct rw_semaphore *sem)
 	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write);
@@ -88,7 +83,6 @@ int __sched down_write_killable(struct rw_semaphore *sem)
 		return -EINTR;
 	}
 
-	rwsem_set_owner(sem);
 	return 0;
 }
 
@@ -101,10 +95,8 @@ int down_write_trylock(struct rw_semaphore *sem)
 {
 	int ret = __down_write_trylock(sem);
 
-	if (ret = 1) {
+	if (ret = 1)
 		rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
-		rwsem_set_owner(sem);
-	}
 
 	return ret;
 }
@@ -119,7 +111,6 @@ void up_read(struct rw_semaphore *sem)
 	rwsem_release(&sem->dep_map, 1, _RET_IP_);
 	DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner & RWSEM_READER_OWNED));
 
-	rwsem_clear_reader_owned(sem);
 	__up_read(sem);
 }
 
@@ -133,7 +124,6 @@ void up_write(struct rw_semaphore *sem)
 	rwsem_release(&sem->dep_map, 1, _RET_IP_);
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current);
 
-	rwsem_clear_owner(sem);
 	__up_write(sem);
 }
 
@@ -147,7 +137,6 @@ void downgrade_write(struct rw_semaphore *sem)
 	lock_downgrade(&sem->dep_map, _RET_IP_);
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current);
 
-	rwsem_set_reader_owned(sem);
 	__downgrade_write(sem);
 }
 
@@ -161,7 +150,6 @@ void down_read_nested(struct rw_semaphore *sem, int subclass)
 	rwsem_acquire_read(&sem->dep_map, subclass, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
-	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read_nested);
@@ -172,7 +160,6 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
 	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(_down_write_nest_lock);
@@ -193,7 +180,6 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
 	rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write_nested);
@@ -208,7 +194,6 @@ int __sched down_write_killable_nested(struct rw_semaphore *sem, int subclass)
 		return -EINTR;
 	}
 
-	rwsem_set_owner(sem);
 	return 0;
 }
 
diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
index 067e265..f568391 100644
--- a/kernel/locking/rwsem.h
+++ b/kernel/locking/rwsem.h
@@ -161,6 +161,8 @@ static inline void __down_read(struct rw_semaphore *sem)
 {
 	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0))
 		rwsem_down_read_failed(sem);
+	else
+		rwsem_set_reader_owned(sem);
 }
 
 static inline int __down_read_killable(struct rw_semaphore *sem)
@@ -168,8 +170,9 @@ static inline int __down_read_killable(struct rw_semaphore *sem)
 	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0)) {
 		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
 			return -EINTR;
+	} else {
+		rwsem_set_reader_owned(sem);
 	}
-
 	return 0;
 }
 
@@ -180,6 +183,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
 		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp,
 				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
+			rwsem_set_reader_owned(sem);
 			return 1;
 		}
 	}
@@ -197,6 +201,7 @@ static inline void __down_write(struct rw_semaphore *sem)
 					     &sem->count);
 	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
 		rwsem_down_write_failed(sem);
+	rwsem_set_owner(sem);
 }
 
 static inline int __down_write_killable(struct rw_semaphore *sem)
@@ -208,6 +213,7 @@ static inline int __down_write_killable(struct rw_semaphore *sem)
 	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
 		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
 			return -EINTR;
+	rwsem_set_owner(sem);
 	return 0;
 }
 
@@ -217,7 +223,11 @@ static inline int __down_write_trylock(struct rw_semaphore *sem)
 
 	tmp = atomic_long_cmpxchg_acquire(&sem->count, RWSEM_UNLOCKED_VALUE,
 		      RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp = RWSEM_UNLOCKED_VALUE;
+	if (tmp = RWSEM_UNLOCKED_VALUE) {
+		rwsem_set_owner(sem);
+		return true;
+	}
+	return false;
 }
 
 /*
@@ -227,6 +237,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 {
 	long tmp;
 
+	rwsem_clear_reader_owned(sem);
 	tmp = atomic_long_dec_return_release(&sem->count);
 	if (unlikely(tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0))
 		rwsem_wake(sem);
@@ -237,6 +248,7 @@ static inline void __up_read(struct rw_semaphore *sem)
  */
 static inline void __up_write(struct rw_semaphore *sem)
 {
+	rwsem_clear_owner(sem);
 	if (unlikely(atomic_long_sub_return_release(RWSEM_ACTIVE_WRITE_BIAS,
 						    &sem->count) < 0))
 		rwsem_wake(sem);
@@ -257,6 +269,7 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
 	 * write side. As such, rely on RELEASE semantics.
 	 */
 	tmp = atomic_long_add_return_release(-RWSEM_WAITING_BIAS, &sem->count);
+	rwsem_set_reader_owned(sem);
 	if (tmp < 0)
 		rwsem_downgrade_wake(sem);
 }
-- 
1.8.3.1
