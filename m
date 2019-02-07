From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:26 +0000
Subject: [PATCH-tip 22/22] locking/rwsem: Ensure an RT task will not spin on reader
Message-Id: <1549566446-27967-23-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

An RT task can do optimistic spinning only if the lock holder is
actually running. If the state of the lock holder isn't known, there
is a possibility that high priority of the RT task may block forward
progress of the lock holder if they happen to reside on the same CPU.
This will lead to deadlock. So we have to make sure that an RT task
will not spin on a reader-owned rwsem.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 3cf2e84..ac1f6c4 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -349,12 +349,14 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 
 /*
  * Return the folowing three values depending on the lock owner state.
+ *   2	when owner is currently NULL
  *   1	when owner changes and no reader is detected yet.
  *   0	when owner changes and the new owner may be a reader.
  *  -1	when optimistic spinning has to stop because either the owner stops
  *	running, is unknown, or its timeslice has been used up.
  */
 enum owner_state {
+	OWNER_NULL = 2,
 	OWNER_SPINNABLE = 1,
 	OWNER_READER = 0,
 	OWNER_NONSPINNABLE = -1,
@@ -405,7 +407,8 @@ static noinline enum owner_state rwsem_spin_on_owner(struct rw_semaphore *sem)
 	owner = rwsem_get_owner(sem);
 	if (!is_rwsem_owner_spinnable(owner))
 		return OWNER_NONSPINNABLE;
-	return is_rwsem_owner_reader(owner) ? OWNER_READER : OWNER_SPINNABLE;
+	return !owner ? OWNER_NULL :
+	       is_rwsem_owner_reader(owner) ? OWNER_READER : OWNER_SPINNABLE;
 }
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
@@ -442,12 +445,13 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 			break;
 
 		/*
-		 * When there's no owner, we might have preempted between the
-		 * owner acquiring the lock and setting the owner field. If
-		 * we're an RT task that will live-lock because we won't let
-		 * the owner complete.
+		 * An RT task cannot do optimistic spinning if it cannot
+		 * be sure the lock holder is running. When there's no owner
+		 * or is reader-owned, an RT task has to stop spinning or
+		 * live-lock may happen if the current task and the lock
+		 * holder happen to run in the same CPU.
 		 */
-		if (!rwsem_get_owner(sem) &&
+		if ((owner_state != OWNER_SPINNABLE) &&
 		   (need_resched() || rt_task(current)))
 			break;
 
-- 
1.8.3.1
