From: holt@sgi.com
Date: Tue, 04 Nov 2008 12:24:06 +0000
Subject: [Patch V3 1/3] Factor out #ifdefs from kernel/spinlock.c to LOCK_CONTENDED_FLAGS
Message-Id: <20081104122418.842777026@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Petr Tesarik <ptesarik@suse.cz>, Tony Ernst <tee@sgi.com>, Robin Holt <holt@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>

The new macro LOCK_CONTENDED_FLAGS expands to the correct implementation
depending on the config options, so that IRQ's are re-enabled when
possible, but they remain disabled if CONFIG_LOCKDEP is set.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
Signed-off-by: Robin Holt <holt@sgi.com>
---
 include/linux/lockdep.h |   17 +++++++++++++++++
 kernel/spinlock.c       |   12 ++----------
 2 files changed, 19 insertions(+), 10 deletions(-)

Index: rwlock/include/linux/lockdep.h
=================================--- rwlock.orig/include/linux/lockdep.h	2008-11-04 05:54:18.456411408 -0600
+++ rwlock/include/linux/lockdep.h	2008-11-04 05:55:43.335302610 -0600
@@ -376,6 +376,23 @@ do {								\
 
 #endif /* CONFIG_LOCK_STAT */
 
+#ifdef CONFIG_LOCKDEP
+
+/*
+ * On lockdep we dont want the hand-coded irq-enable of
+ * _raw_*_lock_flags() code, because lockdep assumes
+ * that interrupts are not re-enabled during lock-acquire:
+ */
+#define LOCK_CONTENDED_FLAGS(_lock, try, lock, lockfl, flags) \
+	LOCK_CONTENDED((_lock), (try), (lock))
+
+#else /* CONFIG_LOCKDEP */
+
+#define LOCK_CONTENDED_FLAGS(_lock, try, lock, lockfl, flags) \
+	lockfl((_lock), (flags))
+
+#endif /* CONFIG_LOCKDEP */
+
 #if defined(CONFIG_TRACE_IRQFLAGS) && defined(CONFIG_GENERIC_HARDIRQS)
 extern void early_init_irq_lock_class(void);
 #else
Index: rwlock/kernel/spinlock.c
=================================--- rwlock.orig/kernel/spinlock.c	2008-11-04 05:54:18.456411408 -0600
+++ rwlock/kernel/spinlock.c	2008-11-04 06:00:35.504744806 -0600
@@ -299,16 +299,8 @@ unsigned long __lockfunc _spin_lock_irqs
 	local_irq_save(flags);
 	preempt_disable();
 	spin_acquire(&lock->dep_map, subclass, 0, _RET_IP_);
-	/*
-	 * On lockdep we dont want the hand-coded irq-enable of
-	 * _raw_spin_lock_flags() code, because lockdep assumes
-	 * that interrupts are not re-enabled during lock-acquire:
-	 */
-#ifdef CONFIG_LOCKDEP
-	LOCK_CONTENDED(lock, _raw_spin_trylock, _raw_spin_lock);
-#else
-	_raw_spin_lock_flags(lock, &flags);
-#endif
+	LOCK_CONTENDED_FLAGS(lock, _raw_spin_trylock, _raw_spin_lock,
+				_raw_spin_lock_flags, &flags);
 	return flags;
 }
 EXPORT_SYMBOL(_spin_lock_irqsave_nested);

