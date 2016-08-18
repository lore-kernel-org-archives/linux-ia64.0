From: Waiman Long <Waiman.Long@hpe.com>
Date: Thu, 18 Aug 2016 21:11:05 +0000
Subject: [RFC PATCH-tip v4 03/10] locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
Message-Id: <1471554672-38662-4-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

This patch modifies rwsem_spin_on_owner() to return a tri-state value
to better reflect the state of lock holder which enables us to make a
better decision of what to do next.

Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 kernel/locking/rwsem-xadd.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 9309e72..31cb286 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -352,9 +352,13 @@ done:
 }
 
 /*
- * Return true only if we can still spin on the owner field of the rwsem.
+ * Return the folowing three values depending on the lock owner state.
+ *   1	when owner has changed and no reader is detected yet.
+ *   0	when owner has change and/or owner is a reader.
+ *  -1	when optimistic spinning has to stop because either the owner stops
+ *	running or its timeslice has been used up.
  */
-static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
+static noinline int rwsem_spin_on_owner(struct rw_semaphore *sem)
 {
 	struct task_struct *owner = READ_ONCE(sem->owner);
 
@@ -374,7 +378,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 		/* abort spinning when need_resched or owner is not running */
 		if (!owner->on_cpu || need_resched()) {
 			rcu_read_unlock();
-			return false;
+			return -1;
 		}
 
 		cpu_relax_lowlatency();
@@ -385,7 +389,7 @@ out:
 	 * If there is a new owner or the owner is not set, we continue
 	 * spinning.
 	 */
-	return !rwsem_owner_is_reader(READ_ONCE(sem->owner));
+	return rwsem_owner_is_reader(READ_ONCE(sem->owner)) ? 0 : 1;
 }
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
@@ -408,7 +412,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem)
 	 *  2) readers own the lock as we can't determine if they are
 	 *     actively running or not.
 	 */
-	while (rwsem_spin_on_owner(sem)) {
+	while (rwsem_spin_on_owner(sem) > 0) {
 		/*
 		 * Try to acquire the lock
 		 */
-- 
1.7.1

