From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 18:12:35 +0000
Subject: [RFC PATCH-tip 2/6] locking/rwsem: Enable optional count-based spinning on reader
Message-Id: <1465927959-39719-3-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465927959-39719-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, xfs@oss.sgi.com, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

When the rwsem is owned by reader, writers stop optimistic spinning
simply because there is no easy way to figure out if all the readers
are actively running or not. However, there are scenarios where
the readers are unlikely to sleep and optimistic spinning can help
performance.

This patch provides a way for the kernel code to designate specific
rwsems to be more aggressive in term of optimistic spinning that the
writers will continue to spin for some additional count-based time to
see if it can get the lock before sleeping. This aggressive spinning
mode should only be used on rwsems where the readers are unlikely to
go to sleep.

One can use the following function to designate rwsems that can be
benefited from more aggressive spinning:

void __rwsem_set_rspin_threshold_shift(struct rw_semaphore *sem,
					int shift)

A shift value of 0 will use the default 4K (shift = 12) iteration
count.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 include/linux/rwsem.h       |   21 ++++++++++++++++++++-
 kernel/locking/rwsem-xadd.c |   28 +++++++++++++++++++---------
 2 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index dd1d142..1c5f6ff 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -32,6 +32,8 @@ struct rw_semaphore {
 	raw_spinlock_t wait_lock;
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	struct optimistic_spin_queue osq; /* spinner MCS lock */
+	int rspin_threshold_shift;	/* reader spinning threshold shift */
+
 	/*
 	 * Write owner. Used as a speculative check to see
 	 * if the owner is running on the cpu.
@@ -70,9 +72,26 @@ static inline int rwsem_is_locked(struct rw_semaphore *sem)
 #endif
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
-#define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL
+#define __RWSEM_OPT_INIT(lockname) , .osq = OSQ_LOCK_UNLOCKED, .owner = NULL, \
+		.rspin_threshold_shift = 0
+
+#define	RWSEM_RSPIN_THRESHOLD_SHIFT_DEFAULT	12
+static inline void
+__rwsem_set_rspin_threshold(struct rw_semaphore *sem, int shift)
+{
+	sem->rspin_threshold_shift = shift;
+}
+
+static inline void rwsem_set_rspin_threshold(struct rw_semaphore *sem)
+{
+	__rwsem_set_rspin_threshold(sem, RWSEM_RSPIN_THRESHOLD_SHIFT_DEFAULT);
+}
 #else
 #define __RWSEM_OPT_INIT(lockname)
+
+static inline void
+__rwsem_set_rspin_threshold(struct rw_semaphore *sem, int shift) {}
+static inline void rwsem_set_rspin_threshold(struct rw_semaphore *sem) {}
 #endif
 
 #define __RWSEM_INITIALIZER(name)				\
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 29027c6..9703f4a 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -85,6 +85,7 @@ void __init_rwsem(struct rw_semaphore *sem, const char *name,
 	INIT_LIST_HEAD(&sem->wait_list);
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 	sem->owner = NULL;
+	sem->rspin_threshold_shift = 0;
 	osq_lock_init(&sem->osq);
 #endif
 }
@@ -347,9 +348,11 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 	owner = READ_ONCE(sem->owner);
 	if (!rwsem_owner_is_writer(owner)) {
 		/*
-		 * Don't spin if the rwsem is readers owned.
+		 * Don't spin if the rwsem is readers owned and the
+		 * reader spinning threshold isn't set.
 		 */
-		ret = !rwsem_owner_is_reader(owner);
+		ret = !rwsem_owner_is_reader(owner) ||
+		       sem->rspin_threshold_shift;
 		goto done;
 	}
 
@@ -398,7 +401,8 @@ out:
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 {
-	bool taken = false;
+	bool taken = false, can_spin;
+	int loopcnt;
 
 	preempt_disable();
 
@@ -409,6 +413,9 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	if (!osq_lock(&sem->osq))
 		goto done;
 
+	loopcnt = sem->rspin_threshold_shift
+		? (1 << sem->rspin_threshold_shift) : 0;
+
 	/*
 	 * Optimistically spin on the owner field and attempt to acquire the
 	 * lock whenever the owner changes. Spinning will be stopped when:
@@ -416,7 +423,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	 *  2) readers own the lock as we can't determine if they are
 	 *     actively running or not.
 	 */
-	while (rwsem_spin_on_owner(sem)) {
+	while ((can_spin = rwsem_spin_on_owner(sem)) || loopcnt) {
 		/*
 		 * Try to acquire the lock
 		 */
@@ -425,13 +432,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 			break;
 		}
 
+		if (!can_spin && loopcnt)
+			loopcnt--;
+
 		/*
-		 * When there's no owner, we might have preempted between the
-		 * owner acquiring the lock and setting the owner field. If
-		 * we're an RT task that will live-lock because we won't let
-		 * the owner complete.
+		 * The need_resched() check in rwsem_spin_on_owner() won't
+		 * break the loop anymore. So we need to check this in
+		 * the outer loop. If we're an RT task that will live-lock
+		 * because we won't let the owner complete.
 		 */
-		if (!sem->owner && (need_resched() || rt_task(current)))
+		if (need_resched() || rt_task(current))
 			break;
 
 		/*
-- 
1.7.1

