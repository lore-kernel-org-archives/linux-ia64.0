From: Davidlohr Bueso <dave@stgolabs.net>
Date: Thu, 06 Oct 2016 05:47:47 +0000
Subject: Re: [RFC PATCH-tip v4 01/10] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <20161006054747.GB29373@linux-80c1.suse>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
 <1471554672-38662-2-git-send-email-Waiman.Long@hpe.com>
 <20161004190601.GD24086@linux-80c1.suse>
 <57F4EFCA.6050503@hpe.com>
 <57F5181F.60202@hpe.com>
In-Reply-To: <57F5181F.60202@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Waiman Long <waiman.long@hpe.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On Wed, 05 Oct 2016, Waiman Long wrote:

>diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
>index 05a3785..1e6823a 100644
>--- a/kernel/locking/osq_lock.c
>+++ b/kernel/locking/osq_lock.c
>@@ -12,6 +12,23 @@
>  */
> static DEFINE_PER_CPU_SHARED_ALIGNED(struct optimistic_spin_node, 
>osq_node);
>
>+enum mbtype {
>+    acquire,
>+    release,
>+    relaxed,
>+};

No, please.

>+
>+static __always_inline int
>+_atomic_cmpxchg_(const enum mbtype barrier, atomic_t *v, int old, int new)
>+{
>+    if (barrier = acquire)
>+        return atomic_cmpxchg_acquire(v, old, new);
>+    else if (barrier = release)
>+        return atomic_cmpxchg_release(v, old, new);
>+    else
>+        return atomic_cmpxchg_relaxed(v, old, new);
>+}

Things like the above are icky. How about something like below? I'm not
crazy about it, but there are other similar macros, ie lockref. We still
provide the osq_lock/unlock to imply acquire/release and the new _relaxed
flavor, as I agree that should be the correct naming

While I have not touched osq_wait_next(), the following are impacted:

- node->locked is now completely without ordering for _relaxed() (currently
its under smp_load_acquire, which does not match and the race is harmless
to begin with as we just iterate again. For the acquire flavor, it is always
formed with ctr dep + smp_rmb().

- If osq_lock() fails we never guarantee any ordering.

What do you think?

Thanks,
Davidlohr


diff --git a/include/linux/osq_lock.h b/include/linux/osq_lock.h
index 703ea5c30a33..183ee51e6e54 100644
--- a/include/linux/osq_lock.h
+++ b/include/linux/osq_lock.h
@@ -29,9 +29,20 @@ static inline void osq_lock_init(struct optimistic_spin_queue *lock)
 	atomic_set(&lock->tail, OSQ_UNLOCKED_VAL);
 }
 
+/*
+ * Versions of osq_lock/unlock that do not imply or guarantee (load)-ACQUIRE
+ * (store)-RELEASE barrier semantics.
+ *
+ * Note that a failed call to either osq_lock() or osq_lock_relaxed() does
+ * not imply barriers... we are next to block.
+ */
+extern bool osq_lock_relaxed(struct optimistic_spin_queue *lock);
+extern void osq_unlock_relaxed(struct optimistic_spin_queue *lock);
+
 extern bool osq_lock(struct optimistic_spin_queue *lock);
 extern void osq_unlock(struct optimistic_spin_queue *lock);
 
+
 static inline bool osq_is_locked(struct optimistic_spin_queue *lock)
 {
 	return atomic_read(&lock->tail) != OSQ_UNLOCKED_VAL;
diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
index a70b90db3909..b1bf1e057565 100644
--- a/kernel/locking/mutex.c
+++ b/kernel/locking/mutex.c
@@ -316,7 +316,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
 	 * acquire the mutex all at once, the spinners need to take a
 	 * MCS (queued) lock first before spinning on the owner field.
 	 */
-	if (!osq_lock(&lock->osq))
+	if (!osq_lock_relaxed(&lock->osq))
 		goto done;
 
 	while (true) {
@@ -358,7 +358,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
 			}
 
 			mutex_set_owner(lock);
-			osq_unlock(&lock->osq);
+			osq_unlock_relaxed(&lock->osq);
 			return true;
 		}
 
@@ -380,7 +380,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
 		cpu_relax_lowlatency();
 	}
 
-	osq_unlock(&lock->osq);
+	osq_unlock_relaxed(&lock->osq);
 done:
 	/*
 	 * If we fell out of the spin path because of need_resched(),
diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
index 05a37857ab55..8c3d57698702 100644
--- a/kernel/locking/osq_lock.c
+++ b/kernel/locking/osq_lock.c
@@ -28,6 +28,17 @@ static inline struct optimistic_spin_node *decode_cpu(int encoded_cpu_val)
 	return per_cpu_ptr(&osq_node, cpu_nr);
 }
 
+static inline void set_node_locked_release(struct optimistic_spin_node *node)
+{
+	smp_store_release(&node->locked, 1);
+}
+
+static inline void set_node_locked_relaxed(struct optimistic_spin_node *node)
+{
+	WRITE_ONCE(node->locked, 1);
+
+}
+
 /*
  * Get a stable @node->next pointer, either for unlock() or unqueue() purposes.
  * Can return NULL in case we were the last queued and we updated @lock instead.
@@ -81,130 +92,140 @@ osq_wait_next(struct optimistic_spin_queue *lock,
 	return next;
 }
 
-bool osq_lock(struct optimistic_spin_queue *lock)
-{
-	struct optimistic_spin_node *node = this_cpu_ptr(&osq_node);
-	struct optimistic_spin_node *prev, *next;
-	int curr = encode_cpu(smp_processor_id());
-	int old;
-
-	node->locked = 0;
-	node->next = NULL;
-	node->cpu = curr;
-
-	/*
-	 * We need both ACQUIRE (pairs with corresponding RELEASE in
-	 * unlock() uncontended, or fastpath) and RELEASE (to publish
-	 * the node fields we just initialised) semantics when updating
-	 * the lock tail.
-	 */
-	old = atomic_xchg(&lock->tail, curr);
-	if (old = OSQ_UNLOCKED_VAL)
-		return true;
-
-	prev = decode_cpu(old);
-	node->prev = prev;
-	WRITE_ONCE(prev->next, node);
-
-	/*
-	 * Normally @prev is untouchable after the above store; because at that
-	 * moment unlock can proceed and wipe the node element from stack.
-	 *
-	 * However, since our nodes are static per-cpu storage, we're
-	 * guaranteed their existence -- this allows us to apply
-	 * cmpxchg in an attempt to undo our queueing.
-	 */
-
-	while (!READ_ONCE(node->locked)) {
-		/*
-		 * If we need to reschedule bail... so we can block.
-		 */
-		if (need_resched())
-			goto unqueue;
-
-		cpu_relax_lowlatency();
-	}
-	return true;
-
-unqueue:
-	/*
-	 * Step - A  -- stabilize @prev
-	 *
-	 * Undo our @prev->next assignment; this will make @prev's
-	 * unlock()/unqueue() wait for a next pointer since @lock points to us
-	 * (or later).
-	 */
-
-	for (;;) {
-		if (prev->next = node &&
-		    cmpxchg(&prev->next, node, NULL) = node)
-			break;
-
-		/*
-		 * We can only fail the cmpxchg() racing against an unlock(),
-		 * in which case we should observe @node->locked becomming
-		 * true.
-		 */
-		if (smp_load_acquire(&node->locked))
-			return true;
-
-		cpu_relax_lowlatency();
-
-		/*
-		 * Or we race against a concurrent unqueue()'s step-B, in which
-		 * case its step-C will write us a new @node->prev pointer.
-		 */
-		prev = READ_ONCE(node->prev);
-	}
-
-	/*
-	 * Step - B -- stabilize @next
-	 *
-	 * Similar to unlock(), wait for @node->next or move @lock from @node
-	 * back to @prev.
-	 */
-
-	next = osq_wait_next(lock, node, prev);
-	if (!next)
-		return false;
-
-	/*
-	 * Step - C -- unlink
-	 *
-	 * @prev is stable because its still waiting for a new @prev->next
-	 * pointer, @next is stable because our @node->next pointer is NULL and
-	 * it will wait in Step-A.
-	 */
-
-	WRITE_ONCE(next->prev, prev);
-	WRITE_ONCE(prev->next, next);
-
-	return false;
+#define OSQ_LOCK(EXT, FENCECB)						\
+bool osq_lock##EXT(struct optimistic_spin_queue *lock)			\
+{									\
+	struct optimistic_spin_node *node = this_cpu_ptr(&osq_node);	\
+	struct optimistic_spin_node *prev, *next;			\
+	int old, curr = encode_cpu(smp_processor_id());			\
+									\
+	node->locked = 0;						\
+	node->next = NULL;						\
+	node->cpu = curr;						\
+									\
+	/*								\
+	 * We need both ACQUIRE (pairs with corresponding RELEASE in	\
+	 * unlock() uncontended, or fastpath) and RELEASE (to publish	\
+	 * the node fields we just initialised) semantics when updating \
+	 * the lock tail.						\
+	 */								\
+	old = atomic_xchg(&lock->tail, curr);				\
+	if (old = OSQ_UNLOCKED_VAL)					\
+		return true;						\
+									\
+	prev = decode_cpu(old);						\
+	node->prev = prev;						\
+	WRITE_ONCE(prev->next, node);					\
+									\
+	/*								\
+	 * Normally @prev is untouchable after the above store; because \
+	 * at that moment unlock can proceed and wipe the node element  \
+	 * from stack.							\
+	 *								\
+	 * However, since our nodes are static per-cpu storage, we're   \
+	 * guaranteed their existence -- this allows us to apply	\
+	 * cmpxchg in an attempt to undo our queueing.			\
+	 */								\
+	while (!READ_ONCE(node->locked)) {				\
+		/*							\
+		 * If we need to reschedule bail... so we can block.	\
+		 */							\
+		if (need_resched())					\
+			goto unqueue;					\
+									\
+		cpu_relax_lowlatency();					\
+	}								\
+	FENCECB;							\
+	return true;							\
+									\
+unqueue:								\
+	/*								\
+	 * Step - A  -- stabilize @prev					\
+	 *								\
+	 * Undo our @prev->next assignment; this will make @prev's      \
+	 * unlock()/unqueue() wait for a next pointer since @lock	\
+	 * points to us (or later).					\
+	 */								\
+	for (;;) {							\
+		/*							\
+		 * Failed calls to osq_lock() do not guarantee		\
+		 * barriers, thus always rely on RELAXED semantics.	\
+		 */							\
+		if (prev->next = node &&				\
+		    cmpxchg_relaxed(&prev->next, node, NULL) = node)	\
+			break;						\
+									\
+		/*							\
+		 * We can only fail the cmpxchg() racing against an	\
+		 * unlock(), in which case we should observe		\
+		 * @node->locked becoming true.				\
+		 */							\
+		if (READ_ONCE(node->locked)) {				\
+			FENCECB;					\
+			return true;					\
+		}							\
+									\
+		cpu_relax_lowlatency();					\
+									\
+		/*							\
+		 * Or we race against a concurrent unqueue()'s step-B,  \
+		 * in which  case its step-C will write us a new	\
+		 * @node->prev pointer.					\
+		 */							\
+		prev = READ_ONCE(node->prev);				\
+	}								\
+									\
+	/*								\
+	 * Step - B -- stabilize @next					\
+	 *								\
+	 * Similar to unlock(), wait for @node->next or move @lock	\
+	 * from @node back to @prev.					\
+	 */								\
+									\
+	next = osq_wait_next(lock, node, prev);				\
+	if (!next)							\
+		return false;						\
+									\
+	/*								\
+	 * Step - C -- unlink						\
+	 *								\
+	 * @prev is stable because its still waiting for a new		\
+	 * @prev->next pointer, @next is stable because our		\
+	 * @node->next pointer is NULL and it will wait in Step-A.	\
+	 */								\
+									\
+	WRITE_ONCE(next->prev, prev);					\
+	WRITE_ONCE(prev->next, next);					\
+									\
+	return false;							\
 }
 
-void osq_unlock(struct optimistic_spin_queue *lock)
-{
-	struct optimistic_spin_node *node, *next;
-	int curr = encode_cpu(smp_processor_id());
-
-	/*
-	 * Fast path for the uncontended case.
-	 */
-	if (likely(atomic_cmpxchg_release(&lock->tail, curr,
-					  OSQ_UNLOCKED_VAL) = curr))
-		return;
-
-	/*
-	 * Second most likely case.
-	 */
-	node = this_cpu_ptr(&osq_node);
-	next = xchg(&node->next, NULL);
-	if (next) {
-		WRITE_ONCE(next->locked, 1);
-		return;
-	}
-
-	next = osq_wait_next(lock, node, NULL);
-	if (next)
-		WRITE_ONCE(next->locked, 1);
+OSQ_LOCK(, smp_acquire__after_ctrl_dep())
+OSQ_LOCK(_relaxed, )
+
+#define OSQ_UNLOCK(EXT, FENCE)						\
+void osq_unlock##EXT(struct optimistic_spin_queue *lock)                \
+{									\
+	struct optimistic_spin_node *node, *next;			\
+	int curr = encode_cpu(smp_processor_id());			\
+									\
+	/* Fast path for the uncontended case. */			\
+	if (likely(atomic_cmpxchg_##FENCE(&lock->tail, curr,		\
+					  OSQ_UNLOCKED_VAL) = curr))	\
+		return;							\
+									\
+	/* Second most likely case. */					\
+	node = this_cpu_ptr(&osq_node);					\
+	next = xchg(&node->next, NULL);					\
+	if (next)							\
+		goto done_setlocked;					\
+									\
+	next = osq_wait_next(lock, node, NULL);				\
+	if (!next)							\
+		return;							\
+done_setlocked:								\
+	set_node_locked_##FENCE(next);					\
 }
+
+OSQ_UNLOCK(, release)
+OSQ_UNLOCK(_relaxed, relaxed)
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 2337b4bb2366..88e95b114392 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -389,7 +389,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	if (!rwsem_can_spin_on_owner(sem))
 		goto done;
 
-	if (!osq_lock(&sem->osq))
+	if (!osq_lock_relaxed(&sem->osq))
 		goto done;
 
 	/*
@@ -425,7 +425,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		 */
 		cpu_relax_lowlatency();
 	}
-	osq_unlock(&sem->osq);
+	osq_unlock_relaxed(&sem->osq);
 done:
 	preempt_enable();
 	return taken;



