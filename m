From: Waiman Long <longman@redhat.com>
Date: Thu, 07 Feb 2019 19:07:19 +0000
Subject: [PATCH-tip 15/22] locking/rwsem: Merge owner into count on x86-64
Message-Id: <1549566446-27967-16-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
In-Reply-To: <1549566446-27967-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, Waiman Long <longman@redhat.com>

With separate count and owner, there are timing windows where the two
values are inconsistent. That can cause problem when trying to figure
out the exact state of the rwsem. For instance, a RT task will stop
optimistic spinning if the lock is acquired by a writer but the owner
field isn't set yet. That can be solved by combining the count and
owner together in a single atomic value.

On 32-bit architectures, there aren't enough bits to hold both.
64-bit architectures, however, can have enough bits to do that. For
x86-64, the physical address can use up to 52 bits. That is 4PB of
memory. That leaves 12 bits available for other use. The task structure
pointer is also aligned to the L1 cache size. That means another 6 bits
(64 bytes cacheline) will be available. Reserving 2 bits for status
flags, we will have 16 bits for the reader count.  That can supports
up to (64k-1) readers.

The owner value will still be duplicated in the owner field for the
purpose of signalling that the task is in the process of acquiring or
releasing a rwsem.

This change is currently for x86-64 only. Other 64-bit architectures may
be enabled in the future if the need arises.

With a locking microbenchmark running on 5.0 based kernel, the total
locking rates (in kops/s) of the benchmark on a 4-socket 56-core
x86-64 system before and after the patch were as follows:

                  Before Patch      After Patch
   # of Threads  wlock    rlock    wlock    rlock
   ------------  -----    -----    -----    -----
        1        29,085   30,179   27,892   29,514
        2         7,341   14,084    6,240   14,304
        4         7,393   14,246    5,216   11,754
        8         7,139   13,860    5,400   11,308
       16         6,650   15,773    5,744   15,405

This change does have an impact on both read and write lock performance.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/rwsem-xadd.c |  20 +++++++--
 kernel/locking/rwsem-xadd.h | 105 +++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 110 insertions(+), 15 deletions(-)

diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 719d390..0869fbf 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -27,11 +27,11 @@
 /*
  * Guide to the rw_semaphore's count field.
  *
- * When the RWSEM_WRITER_LOCKED bit in count is set, the lock is owned
- * by a writer.
+ * When any of the RWSEM_WRITER_MASK bits in count is set, the lock is
+ * owned by a writer.
  *
  * The lock is owned by readers when
- * (1) the RWSEM_WRITER_LOCKED isn't set in count,
+ * (1) none of the RWSEM_WRITER_MASK bits is set in count,
  * (2) some of the reader bits are set in count, and
  * (3) the owner field has RWSEM_READ_OWNED bit set.
  *
@@ -47,6 +47,11 @@
 void __init_rwsem(struct rw_semaphore *sem, const char *name,
 		  struct lock_class_key *key)
 {
+	/*
+	 * We should support at least (4k-1) concurrent readers
+	 */
+	BUILD_BUG_ON(sizeof(long) * 8 - RWSEM_READER_SHIFT < 12);
+
 #ifdef CONFIG_DEBUG_LOCK_ALLOC
 	/*
 	 * Make sure we are not reinitializing a held semaphore:
@@ -297,7 +302,14 @@ static noinline bool rwsem_spin_on_owner(struct rw_semaphore *sem)
 		return false;
 
 	rcu_read_lock();
-	while (owner && (rwsem_get_owner(sem) = owner)) {
+	/*
+	 * In case the owner task pointer is also stored in the count,
+	 * checking the sem->owner value alone will give an early indication
+	 * if the owner is about to release the lock (sem->owner cleared).
+	 * This enables the spinner to move forward and do a trylock
+	 * earlier.
+	 */
+	while (owner && (READ_ONCE(sem->owner) = owner)) {
 		/*
 		 * Ensure we emit the owner->on_cpu, dereference _after_
 		 * checking sem->owner still matches owner, if that fails,
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index 277a134..d54b5db 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -37,25 +37,73 @@
 #endif
 
 /*
- * The definition of the atomic counter in the semaphore:
+ * With separate count and owner, there are timing windows where the two
+ * values are inconsistent. That can cause problem when trying to figure
+ * out the exact state of the rwsem. That can be solved by combining
+ * the count and owner together in a single atomic value.
  *
- * Bit  0   - writer locked bit
- * Bit  1   - waiters present bit
- * Bit  2   - lock handoff bit
- * Bits 3-7 - reserved
- * Bits 8-X - 24-bit (32-bit) or 56-bit reader count
+ * On 64-bit architectures, the owner task structure pointer can be
+ * compressed and combined with reader count and other status flags.
+ * A simple compression method is to map the virtual address back to
+ * the physical address by subtracting PAGE_OFFSET. On 32-bit
+ * architectures, the long integer value just isn't big enough for
+ * combining owner and count. So they remain separate.
+ *
+ * For x86-64, the physical address can use up to 52 bits. That is 4PB
+ * of memory. That leaves 12 bits available for other use. The task
+ * structure pointer is also aligned to the L1 cache size. That means
+ * another 6 bits (64 bytes cacheline) will be available. Reserving
+ * 2 bits for status flags, we will have 16 bits for the reader count.
+ * That can supports up to (64k-1) readers.
+ *
+ * On x86-64, the bit definitions of the count are:
+ *
+ * Bit   0    - waiters present bit
+ * Bit   1    - lock handoff bit
+ * Bits  2-47 - compressed task structure pointer
+ * Bits 48-63 - 16-bit reader counts
+ *
+ * On other 64-bit architectures, the bit definitions are:
+ *
+ * Bit  0    - waiters present bit
+ * Bit  1    - lock handoff bit
+ * Bits 2-6  - reserved
+ * Bit  7    - writer lock bit
+ * Bits 8-63 - 56-bit reader counts
+ *
+ * On 32-bit architectures, the bit definitions of the count are:
+ *
+ * Bit  0    - waiters present bit
+ * Bit  1    - lock handoff bit
+ * Bits 2-6  - reserved
+ * Bit  7    - writer lock bit
+ * Bits 8-31 - 24-bit reader counts
  *
  * atomic_long_fetch_add() is used to obtain reader lock, whereas
  * atomic_long_cmpxchg() will be used to obtain writer lock.
  */
-#define RWSEM_WRITER_LOCKED	(1UL << 0)
-#define RWSEM_FLAG_WAITERS	(1UL << 1)
-#define RWSEM_FLAG_HANDOFF	(1UL << 2)
+#define RWSEM_FLAG_WAITERS	(1UL << 0)
+#define RWSEM_FLAG_HANDOFF	(1UL << 1)
 
+#ifdef CONFIG_X86_64
+
+#ifdef __PHYSICAL_MASK_SHIFT
+#define RWSEM_PA_MASK_SHIFT	__PHYSICAL_MASK_SHIFT
+#else
+#define RWSEM_PA_MASK_SHIFT	52
+#endif
+#define RWSEM_READER_SHIFT	(RWSEM_PA_MASK_SHIFT - L1_CACHE_SHIFT + 2)
+#define RWSEM_WRITER_MASK	((1UL << RWSEM_READER_SHIFT) - 4)
+#define RWSEM_WRITER_LOCKED	rwsem_owner_count(current)
+
+#else /* CONFIG_X86_64 */
+#define RWSEM_WRITER_MASK	(1UL << 7)
 #define RWSEM_READER_SHIFT	8
+#define RWSEM_WRITER_LOCKED	RWSEM_WRITER_MASK
+#endif /* CONFIG_X86_64 */
+
 #define RWSEM_READER_BIAS	(1UL << RWSEM_READER_SHIFT)
 #define RWSEM_READER_MASK	(~(RWSEM_READER_BIAS - 1))
-#define RWSEM_WRITER_MASK	RWSEM_WRITER_LOCKED
 #define RWSEM_LOCK_MASK		(RWSEM_WRITER_MASK|RWSEM_READER_MASK)
 #define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_MASK|RWSEM_FLAG_WAITERS|\
 				 RWSEM_FLAG_HANDOFF)
@@ -65,6 +113,21 @@
 #define RWSEM_COUNT_LOCKED_OR_HANDOFF(c)	\
 	((c) & (RWSEM_LOCK_MASK|RWSEM_FLAG_HANDOFF))
 
+/*
+ * Task structure pointer compression (64-bit only):
+ * (owner - PAGE_OFFSET) >> (L1_CACHE_SHIFT - 2)
+ */
+static inline unsigned long rwsem_owner_count(struct task_struct *owner)
+{
+	return ((unsigned long)owner - PAGE_OFFSET) >> (L1_CACHE_SHIFT - 2);
+}
+
+static inline unsigned long rwsem_count_owner(long count)
+{
+	return (((unsigned long)count & RWSEM_WRITER_MASK)
+			<< (L1_CACHE_SHIFT - 2)) + PAGE_OFFSET;
+}
+
 #ifdef CONFIG_RWSEM_SPIN_ON_OWNER
 /*
  * All writes to owner are protected by WRITE_ONCE() to make sure that
@@ -72,7 +135,12 @@
  * the owner value concurrently without lock. Read from owner, however,
  * may not need READ_ONCE() as long as the pointer value is only used
  * for comparison and isn't being dereferenced.
+ *
+ * On 32-bit architectures, the owner and count are separate. On 64-bit
+ * architectures, however, the writer task structure pointer is written
+ * to the count as well in addition to the owner field.
  */
+
 static inline void rwsem_set_owner(struct rw_semaphore *sem)
 {
 	WRITE_ONCE(sem->owner, current);
@@ -83,10 +151,22 @@ static inline void rwsem_clear_owner(struct rw_semaphore *sem)
 	WRITE_ONCE(sem->owner, NULL);
 }
 
+#ifdef CONFIG_X86_64
+/*
+ * Get the owner value from count to have early access to the task structure.
+ */
+static inline struct task_struct *rwsem_get_owner(struct rw_semaphore *sem)
+{
+	return (struct task_struct *)
+		(rwsem_count_owner(atomic_long_read(&sem->count)) |
+		((unsigned long)READ_ONCE(sem->owner) & 3));
+}
+#else /* !CONFIG_X86_64 */
 static inline struct task_struct *rwsem_get_owner(struct rw_semaphore *sem)
 {
 	return READ_ONCE(sem->owner);
 }
+#endif /* CONFIG_X86_64 */
 
 /*
  * The task_struct pointer of the last owning reader will be left in
@@ -291,8 +371,11 @@ static inline void __up_write(struct rw_semaphore *sem)
 	long tmp;
 
 	DEBUG_RWSEMS_WARN_ON(sem->owner != current, sem);
+#ifdef CONFIG_X86_64
+	DEBUG_RWSEMS_WARN_ON(sem->owner != rwsem_get_owner(sem), sem);
+#endif
 	rwsem_clear_owner(sem);
-	tmp = atomic_long_fetch_add_release(-RWSEM_WRITER_LOCKED, &sem->count);
+	tmp = atomic_long_fetch_and_release(~RWSEM_WRITER_MASK, &sem->count);
 	if (unlikely(tmp & RWSEM_FLAG_WAITERS))
 		rwsem_wake(sem, tmp);
 }
-- 
1.8.3.1
