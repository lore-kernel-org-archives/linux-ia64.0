From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:25 +0000
Subject: [PATCH-tip 21/22] locking/rwsem: Wake up all readers in wait queue
Message-Id: <1549566446-27967-22-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

When the front of the wait queue is a reader, other readers
immediately following the first reader will also be woken up at the
same time. However, if there is a writer in between. Those readers
behind the writer will not be woken up.

Because of optimistic spinning, the lock acquisition order is not FIFO
anyway. The lock handoff mechanism will ensure that lock starvation
will not happen.

Assuming that the lock hold times of the other readers still in the
queue will be about the same as the readers that are being woken up,
there is really not much additional cost other than the additional
latency due to the wakeup of additional tasks by the waker. Therefore
all the readers in the queue are woken up when the first waiter is a
reader to improve reader throughput.

With a locking microbenchmark running on 5.0 based kernel, the total
locking rates (in kops/s) of the benchmark on a 4-socket 56-core x86-64
system with equal numbers of readers and writers before all the reader
spining patches, before this patch and after this patch were as follows:

   # of Threads  Pre-rspin    Pre-Patch   Post-patch
   ------------  ---------    ---------   ----------
        2          1,926        8,057       7,397
        4          1,391        7,680       6,161
        8            716        7,284       6,405
       16            618        6,542       6,768
       32            501        1,449       6,550
       64             61          480       5,548
      112             75          769       5,216

At low contention level, there is a slight drop in performance. At high
contention level, however, this patch gives a big performance boost.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 3beb942..3cf2e84 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -180,16 +180,16 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 	}
 
 	/*
-	 * Grant an infinite number of read locks to the readers at the front
-	 * of the queue. We know that woken will be at least 1 as we accounted
-	 * for above. Note we increment the 'active part' of the count by the
+	 * Grant an infinite number of read locks to all the readers in the
+	 * queue. We know that woken will be at least 1 as we accounted for
+	 * above. Note we increment the 'active part' of the count by the
 	 * number of readers before waking any processes up.
 	 */
 	list_for_each_entry_safe(waiter, tmp, &sem->wait_list, list) {
 		struct task_struct *tsk;
 
 		if (waiter->type = RWSEM_WAITING_FOR_WRITE)
-			break;
+			continue;
 
 		woken++;
 		tsk = waiter->task;
-- 
1.8.3.1
