From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:39:07 +0000
Subject: [PATCH v5 9/9] locking/rwsem: Enable reader lock stealing
Message-Id: <1496338747-20398-10-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1496338747-20398-1-git-send-email-longman@redhat.com>
In-Reply-To: <1496338747-20398-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The rwsem has supported writer lock stealing for a long time. Reader
lock stealing isn't allowed as it may lead to writer lock starvation.
As a result, writers are preferred over readers. However, preferring
readers generally leads to better overall performance.

This patch now enables reader lock stealing on a rwsem as long as
the lock is reader-owned and optimistic spinning hasn't been disabled
because of long writer wait. This will improve overall performance
without running the risk of writer lock starvation.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index a571bec..f5caba8 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -529,6 +529,14 @@ struct rw_semaphore __sched *rwsem_down_read_failed(struct rw_semaphore *sem)
 		goto enqueue;
 
 	/*
+	 * Steal the lock if no writer was present and the optimistic
+	 * spinning disable bit isn't set.
+	 */
+	count = atomic_long_read(&sem->count);
+	if (!count_has_writer(count))
+		return sem;
+
+	/*
 	 * Undo read bias from down_read operation to stop active locking if:
 	 * 1) Optimistic spinners are present;
 	 * 2) the wait_lock isn't free; or
-- 
1.8.3.1

