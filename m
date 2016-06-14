From: Waiman Long <Waiman.Long@hpe.com>
Date: Tue, 14 Jun 2016 22:48:05 +0000
Subject: [RFC PATCH-tip v2 2/6] locking/rwsem: Stop active read lock ASAP
Message-Id: <1465944489-43440-3-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1465944489-43440-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

Currently, when down_read() fails, the active read locking isn't undone
until the rwsem_down_read_failed() function grabs the wait_lock. If the
wait_lock is contended, it may takes a while to get the lock. During
that period, writer lock stealing will be disabled because of the
active read lock.

This patch will release the active read lock ASAP so that writer lock
stealing can happen sooner. The only downside is when the reader is
the first one in the wait queue as it has to issue another atomic
operation to update the count.

On a 4-socket Haswell machine running on a 4.7-rc1 tip-based kernel,
the fio test with multithreaded randrw and randwrite tests on the
same file on a XFS partition on top of a NVDIMM with DAX were run,
the aggregated bandwidths before and after the patch were as follows:

  Test      BW before patch     BW after patch  % change
  ----      ---------------     --------------  --------
  randrw        1210 MB/s          1352 MB/s      +12%
  randwrite     1622 MB/s          1710 MB/s      +5.4%

The write-only microbench also showed improvement because some read
locking was done by the XFS code.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 kernel/locking/rwsem-xadd.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 2031281..29027c6 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -230,11 +230,18 @@ __rwsem_mark_wake(struct rw_semaphore *sem,
 __visible
 struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 {
-	long count, adjustment = -RWSEM_ACTIVE_READ_BIAS;
+	long count, adjustment = 0;
 	struct rwsem_waiter waiter;
 	struct task_struct *tsk = current;
 	WAKE_Q(wake_q);
 
+	/*
+	 * Undo read bias from down_read operation, stop active locking.
+	 * Doing that after taking the wait_lock may block writer lock
+	 * stealing for too long.
+	 */
+	atomic_long_add(-RWSEM_ACTIVE_READ_BIAS, &sem->count);
+
 	/* set up my own style of waitqueue */
 	waiter.task = tsk;
 	waiter.type = RWSEM_WAITING_FOR_READ;
@@ -244,8 +251,11 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 		adjustment += RWSEM_WAITING_BIAS;
 	list_add_tail(&waiter.list, &sem->wait_list);
 
-	/* we're now waiting on the lock, but no longer actively locking */
-	count = atomic_long_add_return(adjustment, &sem->count);
+	/* we're now waiting on the lock */
+	if (adjustment)
+		count = atomic_long_add_return(adjustment, &sem->count);
+	else
+		count = atomic_long_read(&sem->count);
 
 	/* If there are no active locks, wake the front queued process(es).
 	 *
@@ -253,8 +263,7 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 	 * wake our own waiter to join the existing active readers !
 	 */
 	if (count = RWSEM_WAITING_BIAS ||
-	    (count > RWSEM_WAITING_BIAS &&
-	     adjustment != -RWSEM_ACTIVE_READ_BIAS))
+	    (count > RWSEM_WAITING_BIAS && adjustment))
 		sem = __rwsem_mark_wake(sem, RWSEM_WAKE_ANY, &wake_q);
 
 	raw_spin_unlock_irq(&sem->wait_lock);
-- 
1.7.1

