From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:19 +0000
Subject: [PATCH-tip v7 03/15] locking/rwsem: Move owner setting code from rwsem.c to rwsem-xadd.h
Message-Id: <1508351431-22375-4-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The setting of owner field is specific to rwsem-xadd, it is not needed
for rwsem-spinlock. This patch moves all the owner setting code to
the fast paths directly within rwsem-add.h file.

The rwsem_set_reader_owned() is now only called by the first reader.
So there is no need to do a read to check if the owner is properly
set first.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c |  7 +++----
 kernel/locking/rwsem-xadd.h | 26 +++++++++++++++++++++-----
 kernel/locking/rwsem.c      | 17 ++---------------
 kernel/locking/rwsem.h      | 11 ++++-------
 4 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 1d02b8b..8df0b51 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -131,11 +131,10 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 			return;
 		}
 		/*
-		 * It is not really necessary to set it to reader-owned here,
-		 * but it gives the spinners an early indication that the
-		 * readers now have the lock.
+		 * Set it to reader-owned for first reader.
 		 */
-		rwsem_set_reader_owned(sem);
+		if (!(oldcount >> RWSEM_READER_SHIFT))
+			rwsem_set_reader_owned(sem);
 	}
 
 	/*
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index f0e8ba3..f727b6c 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -29,17 +29,23 @@
  */
 static inline void __down_read(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count)
-		     & RWSEM_READ_FAILED_MASK))
+	int count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
+
+	if (unlikely(count & RWSEM_READ_FAILED_MASK))
 		rwsem_down_read_failed(sem);
+	else if ((count >> RWSEM_READER_SHIFT) = 1)
+		rwsem_set_reader_owned(sem);
 }
 
 static inline int __down_read_killable(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count)
-		& RWSEM_READ_FAILED_MASK)) {
+	int count = atomic_fetch_add_acquire(RWSEM_READER_BIAS, &sem->count);
+
+	if (unlikely(count & RWSEM_READ_FAILED_MASK)) {
 		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
 			return -EINTR;
+	} else if ((count >> RWSEM_READER_SHIFT) = 1) {
+		rwsem_set_reader_owned(sem);
 	}
 
 	return 0;
@@ -52,6 +58,8 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 	while (!((tmp = atomic_read(&sem->count)) & RWSEM_READ_FAILED_MASK)) {
 		if (tmp = atomic_cmpxchg_acquire(&sem->count, tmp,
 				   tmp + RWSEM_READER_BIAS)) {
+			if (!(tmp >> RWSEM_READER_SHIFT))
+				rwsem_set_reader_owned(sem);
 			return 1;
 		}
 	}
@@ -66,6 +74,7 @@ static inline void __down_write(struct rw_semaphore *sem)
 	if (unlikely(atomic_cmpxchg_acquire(&sem->count, 0,
 					    RWSEM_WRITER_LOCKED)))
 		rwsem_down_write_failed(sem);
+	rwsem_set_owner(sem);
 }
 
 static inline int __down_write_killable(struct rw_semaphore *sem)
@@ -74,12 +83,17 @@ static inline int __down_write_killable(struct rw_semaphore *sem)
 					    RWSEM_WRITER_LOCKED)))
 		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
 			return -EINTR;
+	rwsem_set_owner(sem);
 	return 0;
 }
 
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
-	return !atomic_cmpxchg_acquire(&sem->count, 0, RWSEM_WRITER_LOCKED);
+	bool taken = !atomic_cmpxchg_acquire(&sem->count, 0,
+					     RWSEM_WRITER_LOCKED);
+	if (taken)
+		rwsem_set_owner(sem);
+	return taken;
 }
 
 /*
@@ -100,6 +114,7 @@ static inline void __up_read(struct rw_semaphore *sem)
  */
 static inline void __up_write(struct rw_semaphore *sem)
 {
+	rwsem_clear_owner(sem);
 	if (unlikely(atomic_fetch_add_release(-RWSEM_WRITER_LOCKED,
 			&sem->count) & RWSEM_FLAG_WAITERS))
 		rwsem_wake(sem);
@@ -121,6 +136,7 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
 	 */
 	tmp = atomic_fetch_add_release(-RWSEM_WRITER_LOCKED+RWSEM_READER_BIAS,
 					&sem->count);
+	rwsem_set_reader_owned(sem);
 	if (tmp & RWSEM_FLAG_WAITERS)
 		rwsem_downgrade_wake(sem);
 }
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index e53f7746..a1451d8 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -23,7 +23,6 @@ void __sched down_read(struct rw_semaphore *sem)
 	rwsem_acquire_read(&sem->dep_map, 0, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
-	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read);
@@ -51,10 +50,8 @@ int down_read_trylock(struct rw_semaphore *sem)
 {
 	int ret = __down_read_trylock(sem);
 
-	if (ret = 1) {
+	if (ret = 1)
 		rwsem_acquire_read(&sem->dep_map, 0, 1, _RET_IP_);
-		rwsem_set_reader_owned(sem);
-	}
 	return ret;
 }
 
@@ -69,7 +66,6 @@ void __sched down_write(struct rw_semaphore *sem)
 	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write);
@@ -87,7 +83,6 @@ int __sched down_write_killable(struct rw_semaphore *sem)
 		return -EINTR;
 	}
 
-	rwsem_set_owner(sem);
 	return 0;
 }
 
@@ -100,10 +95,8 @@ int down_write_trylock(struct rw_semaphore *sem)
 {
 	int ret = __down_write_trylock(sem);
 
-	if (ret = 1) {
+	if (ret = 1)
 		rwsem_acquire(&sem->dep_map, 0, 1, _RET_IP_);
-		rwsem_set_owner(sem);
-	}
 
 	return ret;
 }
@@ -129,7 +122,6 @@ void up_write(struct rw_semaphore *sem)
 {
 	rwsem_release(&sem->dep_map, 1, _RET_IP_);
 
-	rwsem_clear_owner(sem);
 	__up_write(sem);
 }
 
@@ -142,7 +134,6 @@ void downgrade_write(struct rw_semaphore *sem)
 {
 	lock_downgrade(&sem->dep_map, _RET_IP_);
 
-	rwsem_set_reader_owned(sem);
 	__downgrade_write(sem);
 }
 
@@ -156,7 +147,6 @@ void down_read_nested(struct rw_semaphore *sem, int subclass)
 	rwsem_acquire_read(&sem->dep_map, subclass, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_read_trylock, __down_read);
-	rwsem_set_reader_owned(sem);
 }
 
 EXPORT_SYMBOL(down_read_nested);
@@ -167,7 +157,6 @@ void _down_write_nest_lock(struct rw_semaphore *sem, struct lockdep_map *nest)
 	rwsem_acquire_nest(&sem->dep_map, 0, 0, nest, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(_down_write_nest_lock);
@@ -187,7 +176,6 @@ void down_write_nested(struct rw_semaphore *sem, int subclass)
 	rwsem_acquire(&sem->dep_map, subclass, 0, _RET_IP_);
 
 	LOCK_CONTENDED(sem, __down_write_trylock, __down_write);
-	rwsem_set_owner(sem);
 }
 
 EXPORT_SYMBOL(down_write_nested);
@@ -202,7 +190,6 @@ int __sched down_write_killable_nested(struct rw_semaphore *sem, int subclass)
 		return -EINTR;
 	}
 
-	rwsem_set_owner(sem);
 	return 0;
 }
 
diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
index adcc5af..612109f 100644
--- a/kernel/locking/rwsem.h
+++ b/kernel/locking/rwsem.h
@@ -33,15 +33,12 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 	WRITE_ONCE(sem->owner, NULL);
 }
 
+/*
+ * This should only be called by the first reader that acquires the read lock.
+ */
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
-	/*
-	 * We check the owner value first to make sure that we will only
-	 * do a write to the rwsem cacheline when it is really necessary
-	 * to minimize cacheline contention.
-	 */
-	if (sem->owner != RWSEM_READER_OWNED)
-		WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
+	WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
 }
 
 static inline bool rwsem_owner_is_writer(struct task_struct *owner)
-- 
1.8.3.1

