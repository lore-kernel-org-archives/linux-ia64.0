From: Waiman Long <Waiman.Long@hpe.com>
Date: Fri, 17 Jun 2016 15:41:30 +0000
Subject: [RFC PATCH-tip/locking/core v3 04/10] locking/rwsem: Enable count-based spinning on reader
Message-Id: <1466178096-5623-5-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1466178096-5623-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

When the rwsem is owned by reader, writers stop optimistic spinning
simply because there is no easy way to figure out if all the readers
are actively running or not. However, there are scenarios where
the readers are unlikely to sleep and optimistic spinning can help
performance.

This patch provides an autotuning mechanism to find out if a rwsem
can benefit from count-based reader optimistic spinning. A count
(rspin_enabled) in the rwsem data structure is used to track if
optimistic spinning should be enabled. Reader spinning is enabled
by default. Each successful spin (with lock acquisition) will
increment the count by 1 and each unsuccessful spin will decrement
it by 4.  When the count reaches 0, reader spinning is disabled.
Modification of that count is protected by the osq lock. Therefore,
reader spinning will be maintained as long as at least 80% of the
spins are successful.

Both the spinning threshold and the default value for rspin_enabled
can be overridden by architecture specific rwsem.h header file.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 include/linux/rwsem.h       |   19 +++++++++++-
 kernel/locking/rwsem-xadd.c |   66 ++++++++++++++++++++++++++++++++++++++----
 2 files changed, 77 insertions(+), 8 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index dd1d142..8978f87 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -32,6 +32,8 @@ struct rw_semaphore {
 	raw_spinlock_t wait_lock;
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	struct optimistic_spin_queue osq; /* spinner MCS lock */
+	int rspin_enabled;	/* protected by osq lock */
+
 	/*
 	 * Write owner. Used as a speculative check to see
 	 * if the owner is running on the cpu.
@@ -69,8 +71,23 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 # define __RWSEM_DEP_MAP_INIT(lockname)
 #endif
 
+/*
+ * Each successful reader spin will increment the rspin_enabled by 1.
+ * Each unsuccessful spin, on the other hand, will decrement it by 2.
+ * Reader spinning will be permanently disabled when it reaches 0.
+ */
+#ifndef RWSEM_RSPIN_ENABLED_DEFAULT
+# define RWSEM_RSPIN_ENABLED_DEFAULT	40
+#endif
+#define RWSEM_RSPIN_ENABLED_MAX		1024
+
+#ifndef RWSEM_RSPIN_THRESHOLD
+# define RWSEM_RSPIN_THRESHOLD	(1 << 12)
+#endif
+
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
-#define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL
+#define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL, \
+		.rspin_enabled = RWSEM_RSPIN_ENABLED_DEFAULT
 #else
 #define __RWSEM_OPT_INIT(lockname)
 #endif
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 198b732..ce68b54 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -85,6 +85,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 	INIT_LIST_HEAD(&sem->wait_list);
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	sem->owner = NULL;
+	sem->rspin_enabled = RWSEM_RSPIN_ENABLED_DEFAULT;
 	osq_lock_init(&sem->osq);
 #endif
 }
@@ -347,9 +348,10 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	owner = READ_ONCE(sem->owner);
 	if (!rwsem_owner_is_writer(owner)) {
 		/*
-		 * Don't spin if the rwsem is readers owned.
+		 * Don't spin if the rwsem is readers owned and the
+		 * reader spinning threshold isn't set.
 		 */
-		ret = !rwsem_owner_is_reader(owner);
+		ret = !rwsem_owner_is_reader(owner) || sem->rspin_enabled;
 		goto done;
 	}
 
@@ -403,6 +405,8 @@ out:
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 {
 	bool taken = false;
+	int owner_state;	/* Lock owner state */
+	int rspin_cnt;		/* Count for reader spinning */
 
 	preempt_disable();
 
@@ -413,14 +417,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	if (!osq_lock(&sem->osq))
 		goto done;
 
+	rspin_cnt = sem->rspin_enabled ? RWSEM_RSPIN_THRESHOLD : 0;
+
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
-	 *  1) the owning writer isn't running; or
-	 *  2) readers own the lock as we can't determine if they are
-	 *     actively running or not.
+	 *  1) the owning writer isn't running,
+	 *  2) readers own the lock and reader spinning count has reached 0; or
+	 *  3) its timeslice has been used up.
 	 */
-	while (rwsem_spin_on_owner(sem) > 0) {
+	while ((owner_state = rwsem_spin_on_owner(sem)) >= 0) {
 		/*
 		 * Try to acquire the lock
 		 */
@@ -430,12 +436,24 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		}
 
 		/*
+		 * We only decremnt the rspin_cnt when the lock is owned
+		 * by readers (owner_state = 0). In which case,
+		 * rwsem_spin_on_owner() will essentially be a no-op
+		 * and we will be spinning in this main loop.
+		 */
+		if (owner_state = 0) {
+			if (!rspin_cnt)
+				break;
+			rspin_cnt--;
+		}
+
+		/*
 		 * When there's no owner, we might have preempted between the
 		 * owner acquiring the lock and setting the owner field. If
 		 * we're an RT task that will live-lock because we won't let
 		 * the owner complete.
 		 */
-		if (!sem->owner && (need_resched() || rt_task(current)))
+		if (!sem->owner && rt_task(current))
 			break;
 
 		/*
@@ -446,6 +464,28 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		 */
 		cpu_relax_lowlatency();
 	}
+	/*
+	 * Check the success or failure of writer spinning on reader so as
+	 * to adjust the rspin_enabled count accordingly.
+	 */
+	if (rwsem_owner_is_reader(sem->owner)) {
+		/*
+		 * Update rspin_enabled for reader spinning.
+		 *
+		 * Right now, we need more than 2/3 successful spins to
+		 * maintain reader spinning. We will get rid of it if we don't
+		 * have enough successful spins. The decrement amount is kind
+		 * of arbitrary and can be adjusted if necessary.
+		 */
+		if (taken && (sem->rspin_enabled < RWSEM_RSPIN_ENABLED_MAX)) {
+			sem->rspin_enabled++;
+		} else if (!taken) {
+			if  (sem->rspin_enabled > 2)
+				sem->rspin_enabled -= 2;
+			else
+				sem->rspin_enabled = 0;
+		}
+	}
 	osq_unlock(&sem->osq);
 done:
 	preempt_enable();
@@ -460,6 +500,13 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 	return osq_is_locked(&sem->osq);
 }
 
+/*
+ * Return true if reader optimistic spinning is enabled
+ */
+static inline bool reader_spinning_enabled(struct rw_semaphore *sem)
+{
+	return sem->rspin_enabled;
+}
 #else
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 {
@@ -470,6 +517,11 @@ static inline bool rwsem_has_spinner(struct rw_semaphore *sem)
 {
 	return false;
 }
+
+static inline bool reader_spinning_enabled(struct rw_semaphore *sem)
+{
+	return false;
+}
 #endif
 
 /*
-- 
1.7.1

