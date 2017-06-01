From: Waiman Long <longman@redhat.com>
Date: Thu, 01 Jun 2017 17:39:04 +0000
Subject: [PATCH v5 6/9] locking/rwsem: Use bit in owner to stop spinning
Message-Id: <1496338747-20398-7-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1496338747-20398-1-git-send-email-longman@redhat.com>
In-Reply-To: <1496338747-20398-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

To prepare for reader optimistic spinning, bit 1 of the owner field
in the rw_semaphore structure is now used for stopping optimistic
spinning on a reader-owned rwsem to reduce the possibility of writer
livelocking due to constant incoming stream of readers.  That bit
can be set by both sleeping or spinning writers.

This patch provides the helper functions to facilitate the use of
that bit.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem.h | 66 ++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 56 insertions(+), 10 deletions(-)

diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
index a699f40..3f01888 100644
--- a/kernel/locking/rwsem.h
+++ b/kernel/locking/rwsem.h
@@ -1,19 +1,27 @@
 /*
- * The owner field of the rw_semaphore structure will be set to
- * RWSEM_READ_OWNED when a reader grabs the lock. A writer will clear
- * the owner field when it unlocks. A reader, on the other hand, will
- * not touch the owner field when it unlocks.
+ * The lower 2 bits of the owner field in the rw_semaphore structure are
+ * used for the following special purposes on a reader-owned lock:
+ * 1) Bit 0 - Mark the semaphore as being owned by readers.
+ * 2) Bit 1 - The optimistic spinning disable bit set by a writer to disable
+ *	      spinning on a reader-owned lock after failing to acquire the
+ *	      lock for a certain period of time. It will be reset only when a
+ *	      new writer acquires the lock.
+ *
+ * A writer will clear the owner field when it unlocks. A reader, on the other
+ * hand, will not touch the owner field when it unlocks.
  *
  * In essence, the owner field now has the following 3 states:
  *  1) 0
  *     - lock is free or the owner hasn't set the field yet
- *  2) RWSEM_READER_OWNED
+ *  2) RWSEM_READER_OWNED [| RWSEM_SPIN_DISABLE_BIT]
  *     - lock is currently or previously owned by readers (lock is free
  *       or not set by owner yet)
  *  3) Other non-zero value
  *     - a writer owns the lock
  */
-#define RWSEM_READER_OWNED	((struct task_struct *)1UL)
+#define RWSEM_READER_OWNED_BIT	1UL
+#define RWSEM_SPIN_DISABLE_BIT	2UL
+#define RWSEM_READER_OWNED	((struct task_struct *)RWSEM_READER_OWNED_BIT)
 
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
@@ -33,6 +41,11 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 	WRITE_ONCE(sem->owner, NULL);
 }
 
+static inline bool rwsem_owner_is_reader(struct task_struct *owner)
+{
+	return (unsigned long)owner & RWSEM_READER_OWNED_BIT;
+}
+
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
 	/*
@@ -40,19 +53,48 @@ static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 	 * do a write to the rwsem cacheline when it is really necessary
 	 * to minimize cacheline contention.
 	 */
-	if (sem->owner != RWSEM_READER_OWNED)
+	if (!rwsem_owner_is_reader(READ_ONCE(sem->owner)))
 		WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
 }
 
 static inline bool rwsem_owner_is_writer(struct task_struct *owner)
 {
-	return owner && owner != RWSEM_READER_OWNED;
+	return ((unsigned long)owner & ~RWSEM_SPIN_DISABLE_BIT) &&
+		!rwsem_owner_is_reader(owner);
 }
 
-static inline bool rwsem_owner_is_reader(struct task_struct *owner)
+static inline bool rwsem_owner_is_spin_disabled(struct task_struct *owner)
+{
+	return (unsigned long)owner & RWSEM_SPIN_DISABLE_BIT;
+}
+
+/*
+ * Try to set an optimistic spinning disable bit while it is reader-owned.
+ */
+static inline void rwsem_set_spin_disable(struct rw_semaphore *sem)
+{
+	struct task_struct *new;
+
+	if (READ_ONCE(sem->owner) != RWSEM_READER_OWNED)
+		return;
+	new = (struct task_struct *)(RWSEM_READER_OWNED_BIT|
+				     RWSEM_SPIN_DISABLE_BIT);
+
+	/*
+	 * Failure in cmpxchg() will be ignored, and the caller is expected
+	 * to retry later.
+	 */
+	(void)cmpxchg(&sem->owner, RWSEM_READER_OWNED, new);
+}
+
+/*
+ * Is reader-owned rwsem optimistic spinning disabled?
+ */
+static inline bool rwsem_is_spin_disabled(struct rw_semaphore *sem)
 {
-	return owner = RWSEM_READER_OWNED;
+	return rwsem_owner_is_spin_disabled(READ_ONCE(sem->owner));
 }
+
 #else
 static inline void rwsem_set_owner(struct rw_semaphore *sem)
 {
@@ -65,4 +107,8 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
 {
 }
+
+static inline void rwsem_set_spin_disable(struct rw_semaphore *sem)
+{
+}
 #endif
-- 
1.8.3.1

