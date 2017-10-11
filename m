From: Waiman Long <longman@redhat.com>
Date: Wed, 11 Oct 2017 18:02:01 +0000
Subject: [PATCH v6 10/11] locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
Message-Id: <1507744922-15196-11-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1507744922-15196-1-git-send-email-longman@redhat.com>
In-Reply-To: <1507744922-15196-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

This patch modifies rwsem_spin_on_owner() to return a tri-state value
to better reflect the state of lock holder which enables us to make a
better decision of what to do next.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 38a6c32..d0f3778 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -301,9 +301,13 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
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
 
@@ -327,7 +331,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 		if (!owner->on_cpu || need_resched() ||
 				vcpu_is_preempted(task_cpu(owner))) {
 			rcu_read_unlock();
-			return false;
+			return -1;
 		}
 
 		cpu_relax();
@@ -338,7 +342,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 	 * If there is a new owner or the owner is not set, we continue
 	 * spinning.
 	 */
-	return !rwsem_owner_is_reader(READ_ONCE(sem->owner));
+	return rwsem_owner_is_reader(READ_ONCE(sem->owner)) ? 0 : 1;
 }
 
 static bool
@@ -359,7 +363,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 	 *  2) readers own the lock as we can't determine if they are
 	 *     actively running or not.
 	 */
-	while (rwsem_spin_on_owner(sem)) {
+	while (rwsem_spin_on_owner(sem) > 0) {
 		/*
 		 * Try to acquire the lock
 		 */
-- 
1.8.3.1

