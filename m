From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:18 +0000
Subject: [PATCH-tip 14/22] locking/rwsem: Add more rwsem owner access helpers
Message-Id: <1549566446-27967-15-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

Before combining owner and count, we are adding two new helpers for
accessing the owner value in the rwsem.

 1) struct task_struct *rwsem_get_owner(struct rw_semaphore *sem)
 2) bool is_rwsem_reader_owned(struct rw_semaphore *sem)

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 11 ++++++-----
 kernel/locking/rwsem-xadd.h | 32 ++++++++++++++++++++++++++------
 kernel/locking/rwsem.c      |  3 +--
 3 files changed, 33 insertions(+), 13 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 5f74bae..719d390 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -277,7 +277,7 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 		return false;
 
 	rcu_read_lock();
-	owner = READ_ONCE(sem->owner);
+	owner = rwsem_get_owner(sem);
 	if (owner) {
 		ret = is_rwsem_owner_spinnable(owner) &&
 		      owner_on_cpu(owner);
@@ -291,13 +291,13 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
  */
 static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 {
-	struct task_struct *owner = READ_ONCE(sem->owner);
+	struct task_struct *owner = rwsem_get_owner(sem);
 
 	if (!is_rwsem_owner_spinnable(owner))
 		return false;
 
 	rcu_read_lock();
-	while (owner && (READ_ONCE(sem->owner) = owner)) {
+	while (owner && (rwsem_get_owner(sem) = owner)) {
 		/*
 		 * Ensure we emit the owner->on_cpu, dereference _after_
 		 * checking sem->owner still matches owner, if that fails,
@@ -323,7 +323,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 	 * If there is a new owner or the owner is not set, we continue
 	 * spinning.
 	 */
-	return is_rwsem_owner_spinnable(READ_ONCE(sem->owner));
+	return is_rwsem_owner_spinnable(rwsem_get_owner(sem));
 }
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
@@ -361,7 +361,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		 * we're an RT task that will live-lock because we won't let
 		 * the owner complete.
 		 */
-		if (!sem->owner && (need_resched() || rt_task(current)))
+		if (!rwsem_get_owner(sem) &&
+		   (need_resched() || rt_task(current)))
 			break;
 
 		/*
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 6d4890d..277a134 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -83,6 +83,11 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 	WRITE_ONCE(sem->owner, NULL);
 }
 
+static inline struct task_struct *rwsem_get_owner(struct rw_semaphore *sem)
+{
+	return READ_ONCE(sem->owner);
+}
+
 /*
  * The task_struct pointer of the last owning reader will be left in
  * the owner field.
@@ -116,6 +121,23 @@ static inline bool is_rwsem_owner_spinnable(struct task_struct *owner)
 }
 
 /*
+ * Return true if the rwsem is owned by a reader.
+ */
+static inline bool is_rwsem_reader_owned(struct rw_semaphore *sem)
+{
+#ifdef CONFIG_DEBUG_RWSEMS
+	/*
+	 * Check the count to see if it is write-locked.
+	 */
+	long count = atomic_long_read(&sem->count);
+
+	if (count & RWSEM_WRITER_MASK)
+		return false;
+#endif
+	return (unsigned long)sem->owner & RWSEM_READER_OWNED;
+}
+
+/*
  * Return true if rwsem is owned by an anonymous writer or readers.
  */
 static inline bool rwsem_has_anonymous_owner(struct task_struct *owner)
@@ -135,6 +157,7 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
 {
 	unsigned long val = (unsigned long)current | RWSEM_READER_OWNED
 						   | RWSEM_ANONYMOUSLY_OWNED;
+
 	if (READ_ONCE(sem->owner) = (struct task_struct *)val)
 		cmpxchg_relaxed((unsigned long *)&sem->owner, val,
 				RWSEM_READER_OWNED | RWSEM_ANONYMOUSLY_OWNED);
@@ -181,8 +204,7 @@ static inline void __down_read(struct rw_semaphore *sem)
 	if (unlikely(atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
 			&sem->count) & RWSEM_READ_FAILED_MASK)) {
 		rwsem_down_read_failed(sem);
-		DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner &
-					RWSEM_READER_OWNED), sem);
+		DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	} else {
 		rwsem_set_reader_owned(sem);
 	}
@@ -194,8 +216,7 @@ static inline int __down_read_killable(struct rw_semaphore *sem)
 			&sem->count) & RWSEM_READ_FAILED_MASK)) {
 		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
 			return -EINTR;
-		DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner &
-					RWSEM_READER_OWNED), sem);
+		DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	} else {
 		rwsem_set_reader_owned(sem);
 	}
@@ -254,8 +275,7 @@ static inline void __up_read(struct rw_semaphore *sem)
 {
 	long tmp;
 
-	DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner & RWSEM_READER_OWNED),
-				sem);
+	DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	rwsem_clear_reader_owned(sem);
 	tmp = atomic_long_add_return_release(-RWSEM_READER_BIAS, &sem->count);
 	if (unlikely((tmp & (RWSEM_LOCK_MASK|RWSEM_FLAG_WAITERS))
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index bdfca7c..79fa6e4 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -203,8 +203,7 @@ int __sched down_write_killable_nested(struct rw_semaphore *sem, int subclass)
 
 void up_read_non_owner(struct rw_semaphore *sem)
 {
-	DEBUG_RWSEMS_WARN_ON(!((unsigned long)sem->owner & RWSEM_READER_OWNED),
-				sem);
+	DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	__up_read(sem);
 }
 
-- 
1.8.3.1
