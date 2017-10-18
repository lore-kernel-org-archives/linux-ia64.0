From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:20 +0000
Subject: [PATCH-tip v7 04/15] locking/rwsem: Remove kernel/locking/rwsem.h
Message-Id: <1508351431-22375-5-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

The content of kernel/locking/rwsem.h is now specific to rwsem-xadd. So
we can just move the its content into rwsem-xadd.h and remove it.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/percpu-rwsem.c |  4 ++-
 kernel/locking/rwsem-xadd.c   |  2 +-
 kernel/locking/rwsem-xadd.h   | 66 +++++++++++++++++++++++++++++++++++++++++
 kernel/locking/rwsem.c        |  4 ++-
 kernel/locking/rwsem.h        | 69 -------------------------------------------
 5 files changed, 73 insertions(+), 72 deletions(-)
 delete mode 100644 kernel/locking/rwsem.h

diff --git a/kernel/locking/percpu-rwsem.c b/kernel/locking/percpu-rwsem.c
index f17dad9..d06f7c3 100644
--- a/kernel/locking/percpu-rwsem.c
+++ b/kernel/locking/percpu-rwsem.c
@@ -7,7 +7,9 @@
 #include <linux/sched.h>
 #include <linux/errno.h>
 
-#include "rwsem.h"
+#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
+#include "rwsem-xadd.h"
+#endif
 
 int __percpu_init_rwsem(struct percpu_rw_semaphore *sem,
 			const char *name, struct lock_class_key *rwsem_key)
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 8df0b51..9ca3b64 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -18,7 +18,7 @@
 #include <linux/sched/debug.h>
 #include <linux/osq_lock.h>
 
-#include "rwsem.h"
+#include "rwsem-xadd.h"
 
 /*
  * Guide to the rw_semaphore's count field.
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index f727b6c..64afa35 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -4,6 +4,72 @@
 #include <linux/rwsem.h>
 
 /*
+ * The owner field of the rw_semaphore structure will be set to
+ * RWSEM_READ_OWNED when a reader grabs the lock. A writer will clear
+ * the owner field when it unlocks. A reader, on the other hand, will
+ * not touch the owner field when it unlocks.
+ *
+ * In essence, the owner field now has the following 3 states:
+ *  1) 0
+ *     - lock is free or the owner hasn't set the field yet
+ *  2) RWSEM_READER_OWNED
+ *     - lock is currently or previously owned by readers (lock is free
+ *       or not set by owner yet)
+ *  3) Other non-zero value
+ *     - a writer owns the lock
+ */
+#define RWSEM_READER_OWNED	((struct task_struct *)1UL)
+
+#ifdef CONFIG_RWSEM_SPIN_ON_OWNER
+/*
+ * All writes to owner are protected by WRITE_ONCE() to make sure that
+ * store tearing can't happen as optimistic spinners may read and use
+ * the owner value concurrently without lock. Read from owner, however,
+ * may not need READ_ONCE() as long as the pointer value is only used
+ * for comparison and isn't being dereferenced.
+ */
+static inline void rwsem_set_owner(struct rw_semaphore *sem)
+{
+	WRITE_ONCE(sem->owner, current);
+}
+
+static inline void rwsem_clear_owner(struct rw_semaphore *sem)
+{
+	WRITE_ONCE(sem->owner, NULL);
+}
+
+/*
+ * This should only be called by the first reader that acquires the read lock.
+ */
+static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
+{
+	WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
+}
+
+static inline bool rwsem_owner_is_writer(struct task_struct *owner)
+{
+	return owner && (owner != RWSEM_READER_OWNED);
+}
+
+static inline bool rwsem_owner_is_reader(struct task_struct *owner)
+{
+	return owner = RWSEM_READER_OWNED;
+}
+#else
+static inline void rwsem_set_owner(struct rw_semaphore *sem)
+{
+}
+
+static inline void rwsem_clear_owner(struct rw_semaphore *sem)
+{
+}
+
+static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
+{
+}
+#endif
+
+/*
  * The definition of the atomic counter in the semaphore:
  *
  * Bit  0    - writer locked bit
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index a1451d8..530567e 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -12,7 +12,9 @@
 #include <linux/rwsem.h>
 #include <linux/atomic.h>
 
-#include "rwsem.h"
+#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
+#include "rwsem-xadd.h"
+#endif
 
 /*
  * lock for reading
diff --git a/kernel/locking/rwsem.h b/kernel/locking/rwsem.h
deleted file mode 100644
index 612109f..0000000
--- a/kernel/locking/rwsem.h
+++ /dev/null
@@ -1,69 +0,0 @@
-/*
- * The owner field of the rw_semaphore structure will be set to
- * RWSEM_READ_OWNED when a reader grabs the lock. A writer will clear
- * the owner field when it unlocks. A reader, on the other hand, will
- * not touch the owner field when it unlocks.
- *
- * In essence, the owner field now has the following 3 states:
- *  1) 0
- *     - lock is free or the owner hasn't set the field yet
- *  2) RWSEM_READER_OWNED
- *     - lock is currently or previously owned by readers (lock is free
- *       or not set by owner yet)
- *  3) Other non-zero value
- *     - a writer owns the lock
- */
-#define RWSEM_READER_OWNED	((struct task_struct *)1UL)
-
-#ifdef CONFIG_RWSEM_SPIN_ON_OWNER
-/*
- * All writes to owner are protected by WRITE_ONCE() to make sure that
- * store tearing can't happen as optimistic spinners may read and use
- * the owner value concurrently without lock. Read from owner, however,
- * may not need READ_ONCE() as long as the pointer value is only used
- * for comparison and isn't being dereferenced.
- */
-static inline void rwsem_set_owner(struct rw_semaphore *sem)
-{
-	WRITE_ONCE(sem->owner, current);
-}
-
-static inline void rwsem_clear_owner(struct rw_semaphore *sem)
-{
-	WRITE_ONCE(sem->owner, NULL);
-}
-
-/*
- * This should only be called by the first reader that acquires the read lock.
- */
-static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
-{
-	WRITE_ONCE(sem->owner, RWSEM_READER_OWNED);
-}
-
-static inline bool rwsem_owner_is_writer(struct task_struct *owner)
-{
-	return owner && owner != RWSEM_READER_OWNED;
-}
-
-static inline bool rwsem_owner_is_reader(struct task_struct *owner)
-{
-	return owner = RWSEM_READER_OWNED;
-}
-#else
-static inline void rwsem_set_owner(struct rw_semaphore *sem)
-{
-}
-
-static inline void rwsem_clear_owner(struct rw_semaphore *sem)
-{
-}
-
-static inline void rwsem_set_reader_owned(struct rw_semaphore *sem)
-{
-}
-#endif
-
-#ifdef CONFIG_RWSEM_XCHGADD_ALGORITHM
-#include "rwsem-xadd.h"
-#endif
-- 
1.8.3.1

