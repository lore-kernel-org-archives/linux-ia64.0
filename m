From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 20 Jan 2005 16:08:39 +0000
Subject: [patch 1/3] spinlock fix #1, *_can_lock() primitives
Message-Id: <20050120160839.GA13067@elte.hu>
List-Id: <linux-ia64.vger.kernel.org>
References: <16877.42598.336096.561224@wombat.chubb.wattle.id.au> <20050119080403.GB29037@elte.hu> <16878.9678.73202.771962@wombat.chubb.wattle.id.au> <20050119092013.GA2045@elte.hu> <16878.54402.344079.528038@cargo.ozlabs.ibm.com> <20050120023445.GA3475@taniwha.stupidest.org> <20050119190104.71f0a76f.akpm@osdl.org> <20050120031854.GA8538@taniwha.stupidest.org> <16879.29449.734172.893834@wombat.chubb.wattle.id.au> <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0501200747230.8178@ppc970.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@osdl.org>
Cc: Peter Chubb <peterc@gelato.unsw.edu.au>, Chris Wedgwood <cw@f00f.org>, Andrew Morton <akpm@osdl.org>, paulus@samba.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, dsw@gelato.unsw.edu.au, benh@kernel.crashing.org, linux-ia64@vger.kernel.org, hch@infradead.org, wli@holomorphy.com, jbarnes@sgi.com


* Linus Torvalds <torvalds@osdl.org> wrote:

> We have a sense problem with the "trylock()" cases - some return "it
> was locked" (semaphores), and some return "I succeeded" (spinlocks),
> so not only is the sense not immediately obvious from the usage, it's
> actually _different_ for semaphores and for spinlocks.

well, this is primarily a problem of the semaphore primitives. 

anyway, here's my first patch again, with s/trylock_test/can_lock/.

	Ingo

--
it fixes the BUILD_LOCK_OPS() bug by introducing the following 3 new
locking primitives:

  spin_can_lock(lock)
  read_can_lock(lock)
  write_can_lock(lock)

this is what is needed by BUILD_LOCK_OPS(): a nonintrusive test to check
whether the real (intrusive) trylock op would succeed or not. Semantics
and naming is completely symmetric to the trylock counterpart. No
changes to exit.c.

build/boot-tested on x86. Architectures that want to support PREEMPT
need to add these definitions.

Signed-off-by: Ingo Molnar <mingo@elte.hu>

--- linux/kernel/spinlock.c.orig
+++ linux/kernel/spinlock.c
@@ -173,8 +173,8 @@ EXPORT_SYMBOL(_write_lock);
  * (We do this in a function because inlining it would be excessive.)
  */
 
-#define BUILD_LOCK_OPS(op, locktype, is_locked_fn)			\
-void __lockfunc _##op##_lock(locktype *lock)				\
+#define BUILD_LOCK_OPS(op, locktype)					\
+void __lockfunc _##op##_lock(locktype##_t *lock)			\
 {									\
 	preempt_disable();						\
 	for (;;) {							\
@@ -183,7 +183,7 @@ void __lockfunc _##op##_lock(locktype *l
 		preempt_enable();					\
 		if (!(lock)->break_lock)				\
 			(lock)->break_lock = 1;				\
-		while (is_locked_fn(lock) && (lock)->break_lock)	\
+		while (!op##_can_lock(lock) && (lock)->break_lock)	\
 			cpu_relax();					\
 		preempt_disable();					\
 	}								\
@@ -191,7 +191,7 @@ void __lockfunc _##op##_lock(locktype *l
 									\
 EXPORT_SYMBOL(_##op##_lock);						\
 									\
-unsigned long __lockfunc _##op##_lock_irqsave(locktype *lock)		\
+unsigned long __lockfunc _##op##_lock_irqsave(locktype##_t *lock)	\
 {									\
 	unsigned long flags;						\
 									\
@@ -205,7 +205,7 @@ unsigned long __lockfunc _##op##_lock_ir
 		preempt_enable();					\
 		if (!(lock)->break_lock)				\
 			(lock)->break_lock = 1;				\
-		while (is_locked_fn(lock) && (lock)->break_lock)	\
+		while (!op##_can_lock(lock) && (lock)->break_lock)	\
 			cpu_relax();					\
 		preempt_disable();					\
 	}								\
@@ -214,14 +214,14 @@ unsigned long __lockfunc _##op##_lock_ir
 									\
 EXPORT_SYMBOL(_##op##_lock_irqsave);					\
 									\
-void __lockfunc _##op##_lock_irq(locktype *lock)			\
+void __lockfunc _##op##_lock_irq(locktype##_t *lock)			\
 {									\
 	_##op##_lock_irqsave(lock);					\
 }									\
 									\
 EXPORT_SYMBOL(_##op##_lock_irq);					\
 									\
-void __lockfunc _##op##_lock_bh(locktype *lock)				\
+void __lockfunc _##op##_lock_bh(locktype##_t *lock)			\
 {									\
 	unsigned long flags;						\
 									\
@@ -246,9 +246,9 @@ EXPORT_SYMBOL(_##op##_lock_bh)
  *         _[spin|read|write]_lock_irqsave()
  *         _[spin|read|write]_lock_bh()
  */
-BUILD_LOCK_OPS(spin, spinlock_t, spin_is_locked);
-BUILD_LOCK_OPS(read, rwlock_t, rwlock_is_locked);
-BUILD_LOCK_OPS(write, rwlock_t, spin_is_locked);
+BUILD_LOCK_OPS(spin, spinlock);
+BUILD_LOCK_OPS(read, rwlock);
+BUILD_LOCK_OPS(write, rwlock);
 
 #endif /* CONFIG_PREEMPT */
 
--- linux/include/linux/spinlock.h.orig
+++ linux/include/linux/spinlock.h
@@ -584,4 +584,10 @@ static inline int bit_spin_is_locked(int
 #define DEFINE_SPINLOCK(x) spinlock_t x = SPIN_LOCK_UNLOCKED
 #define DEFINE_RWLOCK(x) rwlock_t x = RW_LOCK_UNLOCKED
 
+/**
+ * spin_can_lock - would spin_trylock() succeed?
+ * @lock: the spinlock in question.
+ */
+#define spin_can_lock(lock)		(!spin_is_locked(lock))
+
 #endif /* __LINUX_SPINLOCK_H */
--- linux/include/asm-i386/spinlock.h.orig
+++ linux/include/asm-i386/spinlock.h
@@ -188,6 +188,18 @@ typedef struct {
 
 #define rwlock_is_locked(x) ((x)->lock != RW_LOCK_BIAS)
 
+/**
+ * read_can_lock - would read_trylock() succeed?
+ * @lock: the rwlock in question.
+ */
+#define read_can_lock(x) (atomic_read((atomic_t *)&(x)->lock) > 0)
+
+/**
+ * write_can_lock - would write_trylock() succeed?
+ * @lock: the rwlock in question.
+ */
+#define write_can_lock(x) ((x)->lock = RW_LOCK_BIAS)
+
 /*
  * On x86, we implement read-write locks as a 32-bit counter
  * with the high bit (sign) being the "contended" bit.
