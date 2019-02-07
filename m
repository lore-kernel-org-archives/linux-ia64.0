From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:22 +0000
Subject: [PATCH-tip 18/22] locking/rwsem: Make rwsem_spin_on_owner() return a tri-state value
Message-Id: <1549566446-27967-19-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

This patch modifies rwsem_spin_on_owner() to return a tri-state value
to better reflect the state of lock holder which enables us to make a
better decision of what to do next.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c | 25 +++++++++++++++++++------
 kernel/locking/rwsem-xadd.h |  5 +++++
 2 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 21d462f..0a29aac 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -305,14 +305,24 @@ static inline bool rwsem_can_spin_on_owner(struct rw_semaphore *sem)
 }
 
 /*
- * Return true only if we can still spin on the owner field of the rwsem.
+ * Return the folowing three values depending on the lock owner state.
+ *   1	when owner changes and no reader is detected yet.
+ *   0	when owner changes and the new owner may be a reader.
+ *  -1	when optimistic spinning has to stop because either the owner stops
+ *	running, is unknown, or its timeslice has been used up.
  */
-static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
+enum owner_state {
+	OWNER_SPINNABLE = 1,
+	OWNER_READER = 0,
+	OWNER_NONSPINNABLE = -1,
+};
+
+static noinline enum owner_state rwsem_spin_on_owner(struct rw_semaphore *sem)
 {
 	struct task_struct *owner = rwsem_get_owner(sem);
 
 	if (!is_rwsem_owner_spinnable(owner))
-		return false;
+		return OWNER_NONSPINNABLE;
 
 	rcu_read_lock();
 	/*
@@ -337,7 +347,7 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 		 */
 		if (need_resched() || !owner_on_cpu(owner, sem)) {
 			rcu_read_unlock();
-			return false;
+			return OWNER_NONSPINNABLE;
 		}
 
 		cpu_relax();
@@ -348,7 +358,10 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 	 * If there is a new owner or the owner is not set, we continue
 	 * spinning.
 	 */
-	return is_rwsem_owner_spinnable(rwsem_get_owner(sem));
+	owner = rwsem_get_owner(sem);
+	if (!is_rwsem_owner_spinnable(owner))
+		return OWNER_NONSPINNABLE;
+	return is_rwsem_owner_reader(owner) ? OWNER_READER : OWNER_SPINNABLE;
 }
 
 static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
@@ -371,7 +384,7 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 	 *  2) readers own the lock as we can't determine if they are
 	 *     actively running or not.
 	 */
-	while (rwsem_spin_on_owner(sem)) {
+	while (rwsem_spin_on_owner(sem) = OWNER_SPINNABLE) {
 		/*
 		 * Try to acquire the lock
 		 */
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index d54b5db..1de6f1e 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -200,6 +200,11 @@ static inline bool is_rwsem_owner_spinnable(struct task_struct *owner)
 	return !((unsigned long)owner & RWSEM_ANONYMOUSLY_OWNED);
 }
 
+static inline bool is_rwsem_owner_reader(struct task_struct *owner)
+{
+	return (unsigned long)owner & RWSEM_READER_OWNED;
+}
+
 /*
  * Return true if the rwsem is owned by a reader.
  */
-- 
1.8.3.1
