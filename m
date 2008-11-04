From: holt@sgi.com
Date: Tue, 04 Nov 2008 12:24:07 +0000
Subject: [Patch V3 2/3] Allow rwlocks to re-enable interrupts
Message-Id: <20081104122419.070913678@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: Petr Tesarik <ptesarik@suse.cz>, Tony Ernst <tee@sgi.com>, Robin Holt <holt@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>

Pass the original flags to rwlock arch-code, so that it can re-enable
interrupts if implemented for that architecture.

Initially, make __raw_read_lock_flags and __raw_write_lock_flags
stubs which just do the same thing as non-flags variants.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
Signed-off-by: Robin Holt <holt@sgi.com>
---
 arch/alpha/include/asm/spinlock.h          |    3 +++
 arch/arm/include/asm/spinlock.h            |    3 +++
 arch/cris/include/arch-v32/arch/spinlock.h |    2 ++
 arch/ia64/include/asm/spinlock.h           |    3 +++
 arch/mips/include/asm/spinlock.h           |    2 ++
 arch/parisc/include/asm/spinlock.h         |    3 +++
 arch/powerpc/include/asm/spinlock.h        |    3 +++
 arch/s390/include/asm/spinlock.h           |    3 +++
 arch/sh/include/asm/spinlock.h             |    3 +++
 arch/sparc/include/asm/spinlock_32.h       |    2 ++
 arch/sparc/include/asm/spinlock_64.h       |    2 ++
 arch/x86/include/asm/spinlock.h            |    3 +++
 include/asm-m32r/spinlock.h                |    3 +++
 include/linux/spinlock.h                   |    6 ++++++
 kernel/spinlock.c                          |    6 ++++--
 15 files changed, 45 insertions(+), 2 deletions(-)

Index: rwlock/arch/alpha/include/asm/spinlock.h
=================================--- rwlock.orig/arch/alpha/include/asm/spinlock.h	2008-11-04 05:54:18.340396518 -0600
+++ rwlock/arch/alpha/include/asm/spinlock.h	2008-11-04 05:58:47.862958623 -0600
@@ -166,6 +166,9 @@ static inline void __raw_write_unlock(ra
 	lock->lock = 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/arm/include/asm/spinlock.h
=================================--- rwlock.orig/arch/arm/include/asm/spinlock.h	2008-11-04 05:54:18.340396518 -0600
+++ rwlock/arch/arm/include/asm/spinlock.h	2008-11-04 05:58:47.874960161 -0600
@@ -217,6 +217,9 @@ static inline int __raw_read_trylock(raw
 /* read_can_lock - would read_trylock() succeed? */
 #define __raw_read_can_lock(x)		((x)->lock < 0x80000000)
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/ia64/include/asm/spinlock.h
=================================--- rwlock.orig/arch/ia64/include/asm/spinlock.h	2008-11-04 05:54:18.340396518 -0600
+++ rwlock/arch/ia64/include/asm/spinlock.h	2008-11-04 05:58:47.894962723 -0600
@@ -213,6 +213,9 @@ static inline int __raw_read_trylock(raw
 	return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word, old.word) = old.word;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/mips/include/asm/spinlock.h
=================================--- rwlock.orig/arch/mips/include/asm/spinlock.h	2008-11-04 05:54:18.340396518 -0600
+++ rwlock/arch/mips/include/asm/spinlock.h	2008-11-04 05:58:47.918965799 -0600
@@ -479,6 +479,8 @@ static inline int __raw_write_trylock(ra
 	return ret;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
Index: rwlock/arch/powerpc/include/asm/spinlock.h
=================================--- rwlock.orig/arch/powerpc/include/asm/spinlock.h	2008-11-04 05:54:18.340396518 -0600
+++ rwlock/arch/powerpc/include/asm/spinlock.h	2008-11-04 05:58:47.942968874 -0600
@@ -287,6 +287,9 @@ static inline void __raw_write_unlock(ra
 	rw->lock = 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	__spin_yield(lock)
 #define _raw_read_relax(lock)	__rw_yield(lock)
 #define _raw_write_relax(lock)	__rw_yield(lock)
Index: rwlock/arch/s390/include/asm/spinlock.h
=================================--- rwlock.orig/arch/s390/include/asm/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/s390/include/asm/spinlock.h	2008-11-04 05:58:47.966971949 -0600
@@ -172,6 +172,9 @@ static inline int __raw_write_trylock(ra
 	return _raw_write_trylock_retry(rw);
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
 
Index: rwlock/arch/sh/include/asm/spinlock.h
=================================--- rwlock.orig/arch/sh/include/asm/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/sh/include/asm/spinlock.h	2008-11-04 05:58:47.990975024 -0600
@@ -216,6 +216,9 @@ static inline int __raw_write_trylock(ra
 	return (oldval > (RW_LOCK_BIAS - 1));
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/sparc/include/asm/spinlock_32.h
=================================--- rwlock.orig/arch/sparc/include/asm/spinlock_32.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/sparc/include/asm/spinlock_32.h	2008-11-04 05:58:48.014978100 -0600
@@ -177,6 +177,8 @@ static inline int __read_trylock(raw_rwl
 #define __raw_write_unlock(rw)	do { (rw)->lock = 0; } while(0)
 
 #define __raw_spin_lock_flags(lock, flags) __raw_spin_lock(lock)
+#define __raw_read_lock_flags(rw, flags)   __raw_read_lock(rw)
+#define __raw_write_lock_flags(rw, flags)  __raw_write_lock(rw)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
Index: rwlock/arch/sparc/include/asm/spinlock_64.h
=================================--- rwlock.orig/arch/sparc/include/asm/spinlock_64.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/sparc/include/asm/spinlock_64.h	2008-11-04 05:58:48.034980662 -0600
@@ -230,9 +230,11 @@ static int inline __write_trylock(raw_rw
 }
 
 #define __raw_read_lock(p)	__read_lock(p)
+#define __raw_read_lock_flags(p, f) __read_lock(p)
 #define __raw_read_trylock(p)	__read_trylock(p)
 #define __raw_read_unlock(p)	__read_unlock(p)
 #define __raw_write_lock(p)	__write_lock(p)
+#define __raw_write_lock_flags(p, f) __write_lock(p)
 #define __raw_write_unlock(p)	__write_unlock(p)
 #define __raw_write_trylock(p)	__write_trylock(p)
 
Index: rwlock/arch/cris/include/arch-v32/arch/spinlock.h
=================================--- rwlock.orig/arch/cris/include/arch-v32/arch/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/cris/include/arch-v32/arch/spinlock.h	2008-11-04 05:58:48.050982713 -0600
@@ -121,6 +121,8 @@ static  inline int __raw_write_trylock(r
 	return 1;
 }
 
+#define _raw_read_lock_flags(lock, flags) _raw_read_lock(lock)
+#define _raw_write_lock_flags(lock, flags) _raw_write_lock(lock)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
Index: rwlock/include/asm-m32r/spinlock.h
=================================--- rwlock.orig/include/asm-m32r/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/include/asm-m32r/spinlock.h	2008-11-04 05:58:48.074985788 -0600
@@ -316,6 +316,9 @@ static inline int __raw_write_trylock(ra
 	return 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/parisc/include/asm/spinlock.h
=================================--- rwlock.orig/arch/parisc/include/asm/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/parisc/include/asm/spinlock.h	2008-11-04 05:58:48.098988863 -0600
@@ -187,6 +187,9 @@ static __inline__ int __raw_write_can_lo
 	return !rw->counter;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/arch/x86/include/asm/spinlock.h
=================================--- rwlock.orig/arch/x86/include/asm/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/arch/x86/include/asm/spinlock.h	2008-11-04 05:58:48.122991938 -0600
@@ -357,6 +357,9 @@ static inline void __raw_write_unlock(ra
 		     : "+m" (rw->lock) : "i" (RW_LOCK_BIAS) : "memory");
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
Index: rwlock/include/linux/spinlock.h
=================================--- rwlock.orig/include/linux/spinlock.h	2008-11-04 05:54:18.344397031 -0600
+++ rwlock/include/linux/spinlock.h	2008-11-04 05:58:48.142994501 -0600
@@ -148,9 +148,11 @@ do {								\
  extern int _raw_spin_trylock(spinlock_t *lock);
  extern void _raw_spin_unlock(spinlock_t *lock);
  extern void _raw_read_lock(rwlock_t *lock);
+#define _raw_read_lock_flags(lock, flags) _raw_read_lock(lock)
  extern int _raw_read_trylock(rwlock_t *lock);
  extern void _raw_read_unlock(rwlock_t *lock);
  extern void _raw_write_lock(rwlock_t *lock);
+#define _raw_write_lock_flags(lock, flags) _raw_write_lock(lock)
  extern int _raw_write_trylock(rwlock_t *lock);
  extern void _raw_write_unlock(rwlock_t *lock);
 #else
@@ -160,9 +162,13 @@ do {								\
 # define _raw_spin_trylock(lock)	__raw_spin_trylock(&(lock)->raw_lock)
 # define _raw_spin_unlock(lock)		__raw_spin_unlock(&(lock)->raw_lock)
 # define _raw_read_lock(rwlock)		__raw_read_lock(&(rwlock)->raw_lock)
+# define _raw_read_lock_flags(lock, flags) \
+		__raw_read_lock_flags(&(lock)->raw_lock, *(flags))
 # define _raw_read_trylock(rwlock)	__raw_read_trylock(&(rwlock)->raw_lock)
 # define _raw_read_unlock(rwlock)	__raw_read_unlock(&(rwlock)->raw_lock)
 # define _raw_write_lock(rwlock)	__raw_write_lock(&(rwlock)->raw_lock)
+# define _raw_write_lock_flags(lock, flags) \
+		__raw_write_lock_flags(&(lock)->raw_lock, *(flags))
 # define _raw_write_trylock(rwlock)	__raw_write_trylock(&(rwlock)->raw_lock)
 # define _raw_write_unlock(rwlock)	__raw_write_unlock(&(rwlock)->raw_lock)
 #endif
Index: rwlock/kernel/spinlock.c
=================================--- rwlock.orig/kernel/spinlock.c	2008-11-04 05:55:43.347304150 -0600
+++ rwlock/kernel/spinlock.c	2008-11-04 05:58:48.166997576 -0600
@@ -121,7 +121,8 @@ unsigned long __lockfunc _read_lock_irqs
 	local_irq_save(flags);
 	preempt_disable();
 	rwlock_acquire_read(&lock->dep_map, 0, 0, _RET_IP_);
-	LOCK_CONTENDED(lock, _raw_read_trylock, _raw_read_lock);
+	LOCK_CONTENDED_FLAGS(lock, _raw_read_trylock, _raw_read_lock,
+			     _raw_read_lock_flags, &flags);
 	return flags;
 }
 EXPORT_SYMBOL(_read_lock_irqsave);
@@ -151,7 +152,8 @@ unsigned long __lockfunc _write_lock_irq
 	local_irq_save(flags);
 	preempt_disable();
 	rwlock_acquire(&lock->dep_map, 0, 0, _RET_IP_);
-	LOCK_CONTENDED(lock, _raw_write_trylock, _raw_write_lock);
+	LOCK_CONTENDED_FLAGS(lock, _raw_write_trylock, _raw_write_lock,
+			     _raw_write_lock_flags, &flags);
 	return flags;
 }
 EXPORT_SYMBOL(_write_lock_irqsave);

