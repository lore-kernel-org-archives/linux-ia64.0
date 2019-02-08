From: Waiman Long <longman@redhat.com>
Date: Fri, 08 Feb 2019 14:19:44 +0000
Subject: Re: [PATCH-tip 15/22] locking/rwsem: Merge owner into count on x86-64
Message-Id: <71f2a774-4ae7-2f8f-cb99-3c722a23323f@redhat.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------044906BC29EDC2231BFC9A7F"
List-Id: <linux-ia64.vger.kernel.org>
References: <1549566446-27967-1-git-send-email-longman@redhat.com>
 <1549566446-27967-16-git-send-email-longman@redhat.com>
 <20190207200848.GH32477@hirez.programming.kicks-ass.net>
 <d157be4f-fbbe-4541-439b-7f6ab3b1dbdc@redhat.com>
In-Reply-To: <d157be4f-fbbe-4541-439b-7f6ab3b1dbdc@redhat.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Davidlohr Bueso <dave@stgolabs.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>

This is a multi-part message in MIME format.
--------------044906BC29EDC2231BFC9A7F
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

On 02/07/2019 03:54 PM, Waiman Long wrote:
> On 02/07/2019 03:08 PM, Peter Zijlstra wrote:
>> On Thu, Feb 07, 2019 at 02:07:19PM -0500, Waiman Long wrote:
>>> On 32-bit architectures, there aren't enough bits to hold both.
>>> 64-bit architectures, however, can have enough bits to do that. For
>>> x86-64, the physical address can use up to 52 bits. That is 4PB of
>>> memory. That leaves 12 bits available for other use. The task structure
>>> pointer is also aligned to the L1 cache size. That means another 6 bits
>>> (64 bytes cacheline) will be available. Reserving 2 bits for status
>>> flags, we will have 16 bits for the reader count.  That can supports
>>> up to (64k-1) readers.
>> 64k readers sounds like a number that is fairly 'easy' to reach, esp. on
>> 64bit. These are preemptible locks after all, all we need to do is get
>> 64k tasks nested on enough CPUs.
>>
>> I'm sure there's some willing Java proglet around that spawns more than
>> 64k threads just because it can. Run it on a big enough machine (ISTR
>> there's a number of >1k CPU systems out there) and voila.
> Yes, that can be a problem.
>
> One possible solution is to check if the count goes negative. If so,
> fail the read lock and make the readers wait in the wait queue until the
> count is in positive territory. That effectively reduces the reader
> count to 15 bits, but it will avoid the overflow situation. I will try
> to add that support into the next version.
>
> Cheers,
> Longman

Something like the attached patch.

Cheers,
Longman

--------------044906BC29EDC2231BFC9A7F
Content-Type: text/x-patch;
 name="0023-locking-rwsem-Make-MSbit-of-count-as-guard-bit-to-fa.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0023-locking-rwsem-Make-MSbit-of-count-as-guard-bit-to-fa.pa";
 filename*1="tch"

From 746913e7d14e874eeace1e146e63bdaea4dfd4a5 Mon Sep 17 00:00:00 2001
From: Waiman Long <longman@redhat.com>
Date: Fri, 8 Feb 2019 08:58:10 -0500
Subject: [PATCH 23/23] locking/rwsem: Make MSbit of count as guard bit to fail
 readlock

With the merging of owner into count for x86-64, there is only 16 bits
left for reader count. It is theoretically possible for an application to
cause more than 64k readers to acquire a rwsem leading to count overflow.

To prevent this dire situation, the most significant bit of the count
is now treated as a guard bit (RWSEM_FLAG_READFAIL). Read-lock will now
fails for both the fast and optimistic spinning paths whenever this bit
is set. So all those extra readers will be put to sleep in the wait
queue. Wakeup will not happen until the reader count reaches 0.

A limit of 256 is also imposed on the number of readers that can be woken
up in one wakeup function call. This will eliminate the possibility of
waking up more than 64k readers and overflowing the count.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 kernel/locking/lock_events_list.h |  1 +
 kernel/locking/rwsem-xadd.c       | 40 ++++++++++++++++++++++++++++++++------
 kernel/locking/rwsem-xadd.h       | 41 ++++++++++++++++++++++++++-------------
 3 files changed, 62 insertions(+), 20 deletions(-)

diff --git a/kernel/locking/lock_events_list.h b/kernel/locking/lock_events_list.h
index 0052534..9ecdeac 100644
--- a/kernel/locking/lock_events_list.h
+++ b/kernel/locking/lock_events_list.h
@@ -60,6 +60,7 @@
 LOCK_EVENT(rwsem_opt_rlock)	/* # of read locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_wlock)	/* # of write locks opt-spin acquired	*/
 LOCK_EVENT(rwsem_opt_fail)	/* # of failed opt-spinnings		*/
+LOCK_EVENT(rwsem_opt_rfail)	/* # of failed reader-owned readlocks	*/
 LOCK_EVENT(rwsem_opt_nospin)	/* # of disabled reader opt-spinnings	*/
 LOCK_EVENT(rwsem_rlock)		/* # of read locks acquired		*/
 LOCK_EVENT(rwsem_rlock_fast)	/* # of fast read locks acquired	*/
diff --git a/kernel/locking/rwsem-xadd.c b/kernel/locking/rwsem-xadd.c
index 213c2aa..a993055 100644
--- a/kernel/locking/rwsem-xadd.c
+++ b/kernel/locking/rwsem-xadd.c
@@ -110,6 +110,8 @@ enum rwsem_wake_type {
 # define RWSEM_RSPIN_MAX	(1 << 12)
 #endif
 
+#define MAX_READERS_WAKEUP	0x100
+
 /*
  * handle the lock release when processes blocked on it that can now run
  * - if we come here from up_xxxx(), then the RWSEM_FLAG_WAITERS bit must
@@ -208,6 +210,12 @@ static void __rwsem_mark_wake(struct rw_semaphore *sem,
 		 * after setting the reader waiter to nil.
 		 */
 		wake_q_add_safe(wake_q, tsk);
+
+		/*
+		 * Limit # of readers that can be woken up per wakeup call.
+		 */
+		if (woken >= MAX_READERS_WAKEUP)
+			break;
 	}
 
 	adjustment = woken * RWSEM_READER_BIAS - adjustment;
@@ -445,6 +453,16 @@ static bool rwsem_optimistic_spin(struct rw_semaphore *sem, const long wlock)
 			break;
 
 		/*
+		 * If a reader cannot acquire a reader-owned lock, we
+		 * have to quit. It is either the handoff bit just got
+		 * set or (unlikely) readfail bit is somehow set.
+		 */
+		if (unlikely(!wlock && (owner_state == OWNER_READER))) {
+			lockevent_inc(rwsem_opt_rfail);
+			break;
+		}
+
+		/*
 		 * An RT task cannot do optimistic spinning if it cannot
 		 * be sure the lock holder is running. When there's no owner
 		 * or is reader-owned, an RT task has to stop spinning or
@@ -526,12 +544,22 @@ static inline bool rwsem_optimistic_spin(struct rw_semaphore *sem,
  * Wait for the read lock to be granted
  */
 static inline struct rw_semaphore __sched *
-__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state)
+__rwsem_down_read_failed_common(struct rw_semaphore *sem, int state, long count)
 {
-	long count, adjustment = -RWSEM_READER_BIAS;
+	long adjustment = -RWSEM_READER_BIAS;
 	struct rwsem_waiter waiter;
 	DEFINE_WAKE_Q(wake_q);
 
+	if (unlikely(count < 0)) {
+		/*
+		 * Too many active readers, decrement count &
+		 * enter the wait queue.
+		 */
+		atomic_long_add(-RWSEM_READER_BIAS, &sem->count);
+		adjustment = 0;
+		goto queue;
+	}
+
 	if (!rwsem_can_spin_on_owner(sem))
 		goto queue;
 
@@ -635,16 +663,16 @@ static inline bool rwsem_optimistic_spin(struct rw_semaphore *sem,
 }
 
 __visible struct rw_semaphore * __sched
-rwsem_down_read_failed(struct rw_semaphore *sem)
+rwsem_down_read_failed(struct rw_semaphore *sem, long cnt)
 {
-	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE);
+	return __rwsem_down_read_failed_common(sem, TASK_UNINTERRUPTIBLE, cnt);
 }
 EXPORT_SYMBOL(rwsem_down_read_failed);
 
 __visible struct rw_semaphore * __sched
-rwsem_down_read_failed_killable(struct rw_semaphore *sem)
+rwsem_down_read_failed_killable(struct rw_semaphore *sem, long cnt)
 {
-	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE);
+	return __rwsem_down_read_failed_common(sem, TASK_KILLABLE, cnt);
 }
 EXPORT_SYMBOL(rwsem_down_read_failed_killable);
 
diff --git a/kernel/locking/rwsem-xadd.h b/kernel/locking/rwsem-xadd.h
index be67dbd..72308b7 100644
--- a/kernel/locking/rwsem-xadd.h
+++ b/kernel/locking/rwsem-xadd.h
@@ -63,7 +63,8 @@
  * Bit   0    - waiters present bit
  * Bit   1    - lock handoff bit
  * Bits  2-47 - compressed task structure pointer
- * Bits 48-63 - 16-bit reader counts
+ * Bits 48-62 - 15-bit reader counts
+ * Bit  63    - read fail bit
  *
  * On other 64-bit architectures, the bit definitions are:
  *
@@ -71,7 +72,8 @@
  * Bit  1    - lock handoff bit
  * Bits 2-6  - reserved
  * Bit  7    - writer lock bit
- * Bits 8-63 - 56-bit reader counts
+ * Bits 8-62 - 55-bit reader counts
+ * Bit  63   - read fail bit
  *
  * On 32-bit architectures, the bit definitions of the count are:
  *
@@ -79,13 +81,15 @@
  * Bit  1    - lock handoff bit
  * Bits 2-6  - reserved
  * Bit  7    - writer lock bit
- * Bits 8-31 - 24-bit reader counts
+ * Bits 8-30 - 23-bit reader counts
+ * Bit  32   - read fail bit
  *
  * atomic_long_fetch_add() is used to obtain reader lock, whereas
  * atomic_long_cmpxchg() will be used to obtain writer lock.
  */
 #define RWSEM_FLAG_WAITERS	(1UL << 0)
 #define RWSEM_FLAG_HANDOFF	(1UL << 1)
+#define RWSEM_FLAG_READFAIL	(1UL << (BITS_PER_LONG - 1))
 
 #ifdef CONFIG_X86_64
 
@@ -108,7 +112,7 @@
 #define RWSEM_READER_MASK	(~(RWSEM_READER_BIAS - 1))
 #define RWSEM_LOCK_MASK		(RWSEM_WRITER_MASK|RWSEM_READER_MASK)
 #define RWSEM_READ_FAILED_MASK	(RWSEM_WRITER_MASK|RWSEM_FLAG_WAITERS|\
-				 RWSEM_FLAG_HANDOFF)
+				 RWSEM_FLAG_HANDOFF|RWSEM_FLAG_READFAIL)
 
 #define RWSEM_COUNT_LOCKED(c)	((c) & RWSEM_LOCK_MASK)
 #define RWSEM_COUNT_WLOCKED(c)	((c) & RWSEM_WRITER_MASK)
@@ -302,10 +306,15 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
 }
 #endif
 
-extern struct rw_semaphore *rwsem_down_read_failed(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_read_failed_killable(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_write_failed(struct rw_semaphore *sem);
-extern struct rw_semaphore *rwsem_down_write_failed_killable(struct rw_semaphore *sem);
+extern struct rw_semaphore *
+rwsem_down_read_failed(struct rw_semaphore *sem, long count);
+extern struct rw_semaphore *
+rwsem_down_read_failed_killable(struct rw_semaphore *sem, long count);
+extern struct rw_semaphore *
+rwsem_down_write_failed(struct rw_semaphore *sem);
+extern struct rw_semaphore *
+rwsem_down_write_failed_killable(struct rw_semaphore *sem);
+
 extern struct rw_semaphore *rwsem_wake(struct rw_semaphore *sem, long count);
 extern struct rw_semaphore *rwsem_downgrade_wake(struct rw_semaphore *sem);
 
@@ -314,9 +323,11 @@ static inline void rwsem_clear_reader_owned(struct rw_semaphore *sem)
  */
 static inline void __down_read(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
-			&sem->count) & RWSEM_READ_FAILED_MASK)) {
-		rwsem_down_read_failed(sem);
+	long count = atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
+						   &sem->count);
+
+	if (unlikely(count & RWSEM_READ_FAILED_MASK)) {
+		rwsem_down_read_failed(sem, count);
 		DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	} else {
 		rwsem_set_reader_owned(sem);
@@ -325,9 +336,11 @@ static inline void __down_read(struct rw_semaphore *sem)
 
 static inline int __down_read_killable(struct rw_semaphore *sem)
 {
-	if (unlikely(atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
-			&sem->count) & RWSEM_READ_FAILED_MASK)) {
-		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
+	long count = atomic_long_fetch_add_acquire(RWSEM_READER_BIAS,
+						   &sem->count);
+
+	if (unlikely(count & RWSEM_READ_FAILED_MASK)) {
+		if (IS_ERR(rwsem_down_read_failed_killable(sem, count)))
 			return -EINTR;
 		DEBUG_RWSEMS_WARN_ON(!is_rwsem_reader_owned(sem), sem);
 	} else {
-- 
1.8.3.1


--------------044906BC29EDC2231BFC9A7F--
