From: "Luck, Tony" <tony.luck@intel.com>
Date: Sat, 24 Oct 2009 00:56:07 +0000
Subject: [PATCH] Squeeze spin locks back into 4 bytes
Message-Id: <4ae250a72822257ba9@agluck-desktop.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Linus pointed out that other people have spent large amounts of time
and effort to optimize the layout of frequently used structures. Often
these have embedded locks, and the assumption is that a lock takes
4 bytes.  Linus also pointed out how to work with the limited options
for atomic instructions on Itanium.

Signed-off-by: Tony Luck <tony.luck@intel.com>

---

diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index 30bb930..239ecdc 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -25,61 +25,82 @@
  * by atomically noting the tail and incrementing it by one (thus adding
  * ourself to the queue and noting our position), then waiting until the head
  * becomes equal to the the initial value of the tail.
+ * The pad bits in the middle are used to prevent the next_ticket number
+ * overflowing into the now_serving number.
  *
- *   63                     32  31                      0
+ *   31             17  16    15  14                    0
  *  +----------------------------------------------------+
- *  |  next_ticket_number      |     now_serving         |
+ *  |  now_serving     | padding |   next_ticket         |
  *  +----------------------------------------------------+
  */
 
-#define TICKET_SHIFT	32
+#define TICKET_SHIFT	17
+#define TICKET_BITS	15
+#define	TICKET_MASK	((1 << TICKET_BITS) - 1)
 
 static __always_inline void __ticket_spin_lock(raw_spinlock_t *lock)
 {
-	int	*p = (int *)&lock->lock, turn, now_serving;
+	int	*p = (int *)&lock->lock, ticket, serve;
 
-	now_serving = *p;
-	turn = ia64_fetchadd(1, p+1, acq);
+	ticket = ia64_fetchadd(1, p, acq);
 
-	if (turn = now_serving)
+	if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
 		return;
 
-	do {
+	ia64_invala();
+
+	for (;;) {
+		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(serve) : "r"(p) : "memory");
+
+		if (!(((serve >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
+			return;
 		cpu_relax();
-	} while (ACCESS_ONCE(*p) != turn);
+	}
 }
 
 static __always_inline int __ticket_spin_trylock(raw_spinlock_t *lock)
 {
-	long tmp = ACCESS_ONCE(lock->lock), try;
-
-	if (!(((tmp >> TICKET_SHIFT) ^ tmp) & ((1L << TICKET_SHIFT) - 1))) {
-		try = tmp + (1L << TICKET_SHIFT);
+	int tmp = ACCESS_ONCE(lock->lock);
 
-		return ia64_cmpxchg(acq, &lock->lock, tmp, try, sizeof (tmp)) = tmp;
-	}
+	if (!(((tmp >> TICKET_SHIFT) ^ tmp) & TICKET_MASK))
+		return ia64_cmpxchg(acq, &lock->lock, tmp, tmp + 1, sizeof (tmp)) = tmp;
 	return 0;
 }
 
 static __always_inline void __ticket_spin_unlock(raw_spinlock_t *lock)
 {
-	int	*p = (int *)&lock->lock;
+	unsigned short	*p = (unsigned short *)&lock->lock + 1, tmp;
 
-	(void)ia64_fetchadd(1, p, rel);
+	asm volatile ("ld2.bias %0=[%1]" : "=r"(tmp) : "r"(p));
+	ACCESS_ONCE(*p) = (tmp + 2) & ~1;
+}
+
+static __always_inline void __ticket_spin_unlock_wait(raw_spinlock_t *lock)
+{
+	int	*p = (int *)&lock->lock, ticket;
+
+	ia64_invala();
+
+	for (;;) {
+		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(ticket) : "r"(p) : "memory");
+		if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
+			return;
+		cpu_relax();
+	}
 }
 
 static inline int __ticket_spin_is_locked(raw_spinlock_t *lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
 
-	return !!(((tmp >> TICKET_SHIFT) ^ tmp) & ((1L << TICKET_SHIFT) - 1));
+	return !!(((tmp >> TICKET_SHIFT) ^ tmp) & TICKET_MASK);
 }
 
 static inline int __ticket_spin_is_contended(raw_spinlock_t *lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
 
-	return (((tmp >> TICKET_SHIFT) - tmp) & ((1L << TICKET_SHIFT) - 1)) > 1;
+	return ((tmp - (tmp >> TICKET_SHIFT)) & TICKET_MASK) > 1;
 }
 
 static inline int __raw_spin_is_locked(raw_spinlock_t *lock)
@@ -116,8 +137,7 @@ static __always_inline void __raw_spin_lock_flags(raw_spinlock_t *lock,
 
 static inline void __raw_spin_unlock_wait(raw_spinlock_t *lock)
 {
-	while (__raw_spin_is_locked(lock))
-		cpu_relax();
+	__ticket_spin_unlock_wait(lock);
 }
 
 #define __raw_read_can_lock(rw)		(*(volatile int *)(rw) >= 0)
diff --git a/arch/ia64/include/asm/spinlock_types.h b/arch/ia64/include/asm/spinlock_types.h
index b61d136..474e46f 100644
--- a/arch/ia64/include/asm/spinlock_types.h
+++ b/arch/ia64/include/asm/spinlock_types.h
@@ -6,7 +6,7 @@
 #endif
 
 typedef struct {
-	volatile unsigned long lock;
+	volatile unsigned int lock;
 } raw_spinlock_t;
 
 #define __RAW_SPIN_LOCK_UNLOCKED	{ 0 }
