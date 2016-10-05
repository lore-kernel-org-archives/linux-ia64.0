From: Waiman Long <waiman.long@hpe.com>
Date: Wed, 05 Oct 2016 15:11:27 +0000
Subject: Re: [RFC PATCH-tip v4 01/10] locking/osq: Make lock/unlock proper acquire/release barrier
Message-Id: <57F5181F.60202@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com> <1471554672-38662-2-git-send-email-Waiman.Long@hpe.com> <20161004190601.GD24086@linux-80c1.suse> <57F4EFCA.6050503@hpe.com>
In-Reply-To: <57F4EFCA.6050503@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>

On 10/05/2016 08:19 AM, Waiman Long wrote:
> On 10/04/2016 03:06 PM, Davidlohr Bueso wrote:
>> On Thu, 18 Aug 2016, Waiman Long wrote:
>>
>>> The osq_lock() and osq_unlock() function may not provide the necessary
>>> acquire and release barrier in some cases. This patch makes sure
>>> that the proper barriers are provided when osq_lock() is successful
>>> or when osq_unlock() is called.
>>
>> But why do we need these guarantees given that osq is only used 
>> internally
>> for lock owner spinning situations? Leaking out of the critical 
>> region will
>> obviously be bad if using it as a full lock, but, as is, this can 
>> only hurt
>> performance of two of the most popular locks in the kernel -- 
>> although yes,
>> using smp_acquire__after_ctrl_dep is nicer for polling.
>
> First of all, it is not obvious from the name osq_lock() that it is 
> not an acquire barrier in some cases. We either need to clearly 
> document it or has a variant name that indicate that, e.g. 
> osq_lock_relaxed, for example.
>
> Secondly, if we look at the use cases of osq_lock(), the additional 
> latency (for non-x86 archs) only matters if the master lock is 
> immediately available for acquisition after osq_lock() return. 
> Otherwise, it will be hidden in the spinning loop for that master 
> lock. So yes, there may be a slight performance hit in some cases, but 
> certainly not always.
>
>> If you need tighter osq for rwsems, could it be refactored such that 
>> mutexes
>> do not take a hit?
>>
>
> Yes, we can certainly do that like splitting into 2 variants, one with 
> acquire barrier guarantee and one without.
>

How about the following patch? Does that address your concern?

Cheers,
Longman

----------------------------------[ Cut Here 
]--------------------------------------
[PATCH] locking/osq: Provide 2 variants of lock/unlock functions

Despite the lock/unlock names, the osq_lock() and osq_unlock()
functions were not proper acquire and release barriers. To clarify
the situation, two different variants are now provided:

  1) osq_lock/osq_unlock - they are proper acquire (if successful)
     and release barriers respectively.

  2) osq_lock_relaxed/osq_unlock_relaxed - they do not provide the
     acquire/release barrier guarantee.

Both the mutex and rwsem optimistic spinning codes are modified to
use the relaxed variants which will be faster in some architectures as
the proper memory barrier semantics are not needed for queuing purpose.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
  include/linux/osq_lock.h    |    2 +
  kernel/locking/mutex.c      |    6 +-
  kernel/locking/osq_lock.c   |   89 
+++++++++++++++++++++++++++++++++++-------
  kernel/locking/rwsem-xadd.c |    4 +-
  4 files changed, 81 insertions(+), 20 deletions(-)

diff --git a/include/linux/osq_lock.h b/include/linux/osq_lock.h
index 703ea5c..72357d0 100644
--- a/include/linux/osq_lock.h
+++ b/include/linux/osq_lock.h
@@ -30,7 +30,9 @@ static inline void osq_lock_init(struct 
optimistic_spin_queue *lock)
  }

  extern bool osq_lock(struct optimistic_spin_queue *lock);
+extern bool osq_lock_relaxed(struct optimistic_spin_queue *lock);
  extern void osq_unlock(struct optimistic_spin_queue *lock);
+extern void osq_unlock_relaxed(struct optimistic_spin_queue *lock);

  static inline bool osq_is_locked(struct optimistic_spin_queue *lock)
  {
diff --git a/kernel/locking/mutex.c b/kernel/locking/mutex.c
index a70b90d..b1bf1e0 100644
--- a/kernel/locking/mutex.c
+++ b/kernel/locking/mutex.c
@@ -316,7 +316,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
       * acquire the mutex all at once, the spinners need to take a
       * MCS (queued) lock first before spinning on the owner field.
       */
-    if (!osq_lock(&lock->osq))
+    if (!osq_lock_relaxed(&lock->osq))
          goto done;

      while (true) {
@@ -358,7 +358,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
              }

              mutex_set_owner(lock);
-            osq_unlock(&lock->osq);
+            osq_unlock_relaxed(&lock->osq);
              return true;
          }

@@ -380,7 +380,7 @@ static bool mutex_optimistic_spin(struct mutex *lock,
          cpu_relax_lowlatency();
      }

-    osq_unlock(&lock->osq);
+    osq_unlock_relaxed(&lock->osq);
  done:
      /*
       * If we fell out of the spin path because of need_resched(),
diff --git a/kernel/locking/osq_lock.c b/kernel/locking/osq_lock.c
index 05a3785..1e6823a 100644
--- a/kernel/locking/osq_lock.c
+++ b/kernel/locking/osq_lock.c
@@ -12,6 +12,23 @@
   */
  static DEFINE_PER_CPU_SHARED_ALIGNED(struct optimistic_spin_node, 
osq_node);

+enum mbtype {
+    acquire,
+    release,
+    relaxed,
+};
+
+static __always_inline int
+_atomic_cmpxchg_(const enum mbtype barrier, atomic_t *v, int old, int new)
+{
+    if (barrier = acquire)
+        return atomic_cmpxchg_acquire(v, old, new);
+    else if (barrier = release)
+        return atomic_cmpxchg_release(v, old, new);
+    else
+        return atomic_cmpxchg_relaxed(v, old, new);
+}
+
  /*
   * We use the value 0 to represent "no CPU", thus the encoded value
   * will be the CPU number incremented by 1.
@@ -35,7 +52,8 @@ static inline struct optimistic_spin_node 
*decode_cpu(int encoded_cpu_val)
  static inline struct optimistic_spin_node *
  osq_wait_next(struct optimistic_spin_queue *lock,
            struct optimistic_spin_node *node,
-          struct optimistic_spin_node *prev)
+          struct optimistic_spin_node *prev,
+          const enum mbtype barrier)
  {
      struct optimistic_spin_node *next = NULL;
      int curr = encode_cpu(smp_processor_id());
@@ -50,7 +68,7 @@ osq_wait_next(struct optimistic_spin_queue *lock,

      for (;;) {
          if (atomic_read(&lock->tail) = curr &&
-            atomic_cmpxchg_acquire(&lock->tail, curr, old) = curr) {
+           _atomic_cmpxchg_(barrier, &lock->tail, curr, old) = curr) {
              /*
               * We were the last queued, we moved @lock back. @prev
               * will now observe @lock and will complete its
@@ -70,7 +88,13 @@ osq_wait_next(struct optimistic_spin_queue *lock,
           * wait for a new @node->next from its Step-C.
           */
          if (node->next) {
-            next = xchg(&node->next, NULL);
+            if (barrier = acquire)
+                next = xchg_acquire(&node->next, NULL);
+            else if (barrier = release)
+                next = xchg_release(&node->next, NULL);
+            else
+                next = xchg_relaxed(&node->next, NULL);
+
              if (next)
                  break;
          }
@@ -81,7 +105,11 @@ osq_wait_next(struct optimistic_spin_queue *lock,
      return next;
  }

-bool osq_lock(struct optimistic_spin_queue *lock)
+/*
+ * We don't need to provide any memory barrier guarantee if the locking 
fails.
+ */
+static inline bool
+__osq_lock(struct optimistic_spin_queue *lock, const enum mbtype barrier)
  {
      struct optimistic_spin_node *node = this_cpu_ptr(&osq_node);
      struct optimistic_spin_node *prev, *next;
@@ -124,6 +152,12 @@ bool osq_lock(struct optimistic_spin_queue *lock)

          cpu_relax_lowlatency();
      }
+    /*
+     * Add an acquire memory barrier, if necessary, for pairing with the
+     * release barrier in unlock.
+     */
+    if (barrier = acquire)
+        smp_acquire__after_ctrl_dep();
      return true;

  unqueue:
@@ -137,7 +171,7 @@ unqueue:

      for (;;) {
          if (prev->next = node &&
-            cmpxchg(&prev->next, node, NULL) = node)
+            cmpxchg_relaxed(&prev->next, node, NULL) = node)
              break;

          /*
@@ -164,7 +198,7 @@ unqueue:
       * back to @prev.
       */

-    next = osq_wait_next(lock, node, prev);
+    next = osq_wait_next(lock, node, prev, relaxed);
      if (!next)
          return false;

@@ -182,7 +216,8 @@ unqueue:
      return false;
  }

-void osq_unlock(struct optimistic_spin_queue *lock)
+static inline void
+__osq_unlock(struct optimistic_spin_queue *lock, const enum mbtype barrier)
  {
      struct optimistic_spin_node *node, *next;
      int curr = encode_cpu(smp_processor_id());
@@ -190,21 +225,45 @@ void osq_unlock(struct optimistic_spin_queue *lock)
      /*
       * Fast path for the uncontended case.
       */
-    if (likely(atomic_cmpxchg_release(&lock->tail, curr,
-                      OSQ_UNLOCKED_VAL) = curr))
+    if (likely(_atomic_cmpxchg_(barrier, &lock->tail, curr,
+                    OSQ_UNLOCKED_VAL) = curr))
          return;

      /*
       * Second most likely case.
       */
      node = this_cpu_ptr(&osq_node);
-    next = xchg(&node->next, NULL);
-    if (next) {
-        WRITE_ONCE(next->locked, 1);
+    next = xchg_relaxed(&node->next, NULL);
+    if (next)
+        goto unlock;
+
+    next = osq_wait_next(lock, node, NULL, barrier);
+    if (unlikely(!next))
          return;
-    }

-    next = osq_wait_next(lock, node, NULL);
-    if (next)
+unlock:
+    if (barrier = release)
+        smp_store_release(&next->locked, 1);
+    else
          WRITE_ONCE(next->locked, 1);
  }
+
+bool osq_lock(struct optimistic_spin_queue *lock)
+{
+    return __osq_lock(lock, acquire);
+}
+
+bool osq_lock_relaxed(struct optimistic_spin_queue *lock)
+{
+    return __osq_lock(lock, relaxed);
+}
+
+void osq_unlock(struct optimistic_spin_queue *lock)
+{
+    __osq_unlock(lock, release);
+}
+
+void osq_unlock_relaxed(struct optimistic_spin_queue *lock)
+{
+    __osq_unlock(lock, relaxed);
+}
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 2337b4b..88e95b1 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -389,7 +389,7 @@ static bool rwsem_optimistic_spin(struct 
rw_semaphore *sem)
      if (!rwsem_can_spin_on_owner(sem))
          goto done;

-    if (!osq_lock(&sem->osq))
+    if (!osq_lock_relaxed(&sem->osq))
          goto done;

      /*
@@ -425,7 +425,7 @@ static bool rwsem_optimistic_spin(struct 
rw_semaphore *sem)
           */
          cpu_relax_lowlatency();
      }
-    osq_unlock(&sem->osq);
+    osq_unlock_relaxed(&sem->osq);
  done:
      preempt_enable();
      return taken;
-- 
1.7.1



