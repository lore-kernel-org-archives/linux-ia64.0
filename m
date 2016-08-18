From: Waiman Long <Waiman.Long@hpe.com>
Date: Thu, 18 Aug 2016 21:11:10 +0000
Subject: [RFC PATCH-tip v4 08/10] locking/rwsem: Enable spinning readers
Message-Id: <1471554672-38662-9-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

This patch enables readers to optimistically spin when the
rspin_threshold is non-zero. That threshold value should only
be set when the lock owners of the rwsem are unlikely to go to
sleep. Otherwise enabling reader spinning may make the performance
worse in some cases.

On a 4-socket Haswell machine running on a 4.7-rc1 tip-based kernel,
the fio test with multithreaded randrw and randwrite tests on the
same file on a XFS partition on top of a NVDIMM with DAX were run,
the aggregated bandwidths before and after the reader optimistic
spinning patchset were as follows:

  Test      BW before patch     BW after patch  % change
  ----      ---------------     --------------  --------
  randrw        1352 MB/s          2164 MB/s      +60%
  randwrite     1710 MB/s          2550 MB/s      +49%

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 kernel/locking/rwsem-xadd.c |   48 ++++++++++++++++++++++++++++++++++++------
 1 files changed, 41 insertions(+), 7 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 8b118b3..d850214 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -83,6 +83,12 @@
  *	 (2) WAITING_BIAS - ACTIVE_WRITE_BIAS < count < 0
  */
 
+static inline bool count_has_writer(long count)
+{
+	return (count < RWSEM_WAITING_BIAS) || ((count < 0) &&
+	       (count > RWSEM_WAITING_BIAS - RWSEM_ACTIVE_WRITE_BIAS));
+}
+
 /*
  * Initialize an rwsem:
  */
@@ -286,6 +292,25 @@ static inline bool rwsem_try_write_lock_unqueued(struct rw_semaphore *sem)
 	}
 }
 
+/*
+ * Try to acquire read lock before the reader is put on wait queue
+ */
+static inline bool rwsem_try_read_lock_unqueued(struct rw_semaphore *sem)
+{
+	long count = atomic_long_read(&sem->count);
+
+	if (count_has_writer(count))
+		return false;
+	count = atomic_long_add_return_acquire(RWSEM_ACTIVE_READ_BIAS,
+					       &sem->count);
+	if (!count_has_writer(count))
+		return true;
+
+	/* Back out the change */
+	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
+	return false;
+}
+
 static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 {
 	struct task_struct *owner;
@@ -352,7 +377,8 @@ out:
 	return rwsem_owner_is_reader(READ_ONCE(sem->owner)) ? 0 : 1;
 }
 
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+				  enum rwsem_waiter_type type)
 {
 	bool taken = false;
 	int owner_state;	/* Lock owner state */
@@ -380,10 +406,11 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 		/*
 		 * Try to acquire the lock
 		 */
-		if (rwsem_try_write_lock_unqueued(sem)) {
-			taken = true;
+		taken = (type = RWSEM_WAITING_FOR_WRITE)
+		      ? rwsem_try_write_lock_unqueued(sem)
+		      : rwsem_try_read_lock_unqueued(sem);
+		if (taken)
 			break;
-		}
 
 		/*
 		 * We only decremnt the rspin_cnt when the lock is owned
@@ -418,7 +445,8 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	 * Check the success or failure of writer spinning on reader so as
 	 * to adjust the rspin_enabled count accordingly.
 	 */
-	if (rwsem_owner_is_reader(sem->owner)) {
+	if ((type = RWSEM_WAITING_FOR_WRITE) &&
+	    rwsem_owner_is_reader(sem->owner)) {
 		/*
 		 * Update rspin_enabled for reader spinning.
 		 *
@@ -458,7 +486,8 @@ static inline bool reader_spinning_enabled(struct rw_semaphore *sem)
 	return sem->rspin_enabled;
 }
 #else
-static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
+static bool rwsem_optimistic_spin(struct rw_semaphore *sem,
+				  enum rwsem_waiter_type type)
 {
 	return false;
 }
@@ -492,6 +521,11 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	 */
 	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
 
+	/* do optimistic spinning and steal lock if possible */
+	if (reader_spinning_enabled(sem) &&
+	    rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_READ))
+		return sem;
+
 	waiter.task = tsk;
 	waiter.type = RWSEM_WAITING_FOR_READ;
 
@@ -548,7 +582,7 @@ __rwsem_down_write_failed_common(struct rw_semaphore *sem, int state)
 	count = atomic_long_sub_return(RWSEM_ACTIVE_WRITE_BIAS, &sem->count);
 
 	/* do optimistic spinning and steal lock if possible */
-	if (rwsem_optimistic_spin(sem))
+	if (rwsem_optimistic_spin(sem, RWSEM_WAITING_FOR_WRITE))
 		return sem;
 
 	/*
-- 
1.7.1

