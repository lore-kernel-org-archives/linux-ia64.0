From: Petr Tesarik <ptesarik@suse.cz>
Date: Thu, 23 Oct 2008 16:06:09 +0000
Subject: [PATCH V2 2/3] Allow rwlocks to re-enable interrupts
Message-Id: <1224777969.11530.67.camel@elijah.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1224777451.11530.52.camel@elijah.suse.cz>
In-Reply-To: <1224777451.11530.52.camel@elijah.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
Cc: tee@sgi.com, Robin Holt <holt@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>

Pass the original flags to rwlock arch-code, so that it can re-enable
interrupts if implemented for that architecture.

Initially, make __raw_read_lock_flags and __raw_write_lock_flags
stubs which just do the same thing as non-flags variants.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
---
 arch/alpha/include/asm/spinlock.h    |    3 +++
 arch/arm/include/asm/spinlock.h      |    3 +++
 arch/ia64/include/asm/spinlock.h     |    3 +++
 arch/mips/include/asm/spinlock.h     |    2 ++
 arch/powerpc/include/asm/spinlock.h  |    3 +++
 arch/s390/include/asm/spinlock.h     |    3 +++
 arch/sh/include/asm/spinlock.h       |    3 +++
 arch/sparc/include/asm/spinlock_32.h |    2 ++
 arch/sparc/include/asm/spinlock_64.h |    2 ++
 include/asm-cris/arch-v32/spinlock.h |    2 ++
 include/asm-m32r/spinlock.h          |    3 +++
 include/asm-parisc/spinlock.h        |    3 +++
 include/asm-x86/spinlock.h           |    3 +++
 include/linux/spinlock.h             |    6 ++++++
 kernel/spinlock.c                    |    6 ++++--
 15 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/asm/spinlock.h b/arch/alpha/include/asm/spinlock.h
index aeeb125..e38fb95 100644
--- a/arch/alpha/include/asm/spinlock.h
+++ b/arch/alpha/include/asm/spinlock.h
@@ -166,6 +166,9 @@ static inline void __raw_write_unlock(raw_rwlock_t * lock)
 	lock->lock = 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/arch/arm/include/asm/spinlock.h b/arch/arm/include/asm/spinlock.h
index 2b41ebb..c13681a 100644
--- a/arch/arm/include/asm/spinlock.h
+++ b/arch/arm/include/asm/spinlock.h
@@ -217,6 +217,9 @@ static inline int __raw_read_trylock(raw_rwlock_t *rw)
 /* read_can_lock - would read_trylock() succeed? */
 #define __raw_read_can_lock(x)		((x)->lock < 0x80000000)
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index 0229fb9..0a61961 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -213,6 +213,9 @@ static inline int __raw_read_trylock(raw_rwlock_t *x)
 	return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word, old.word) = old.word;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/arch/mips/include/asm/spinlock.h b/arch/mips/include/asm/spinlock.h
index 1a1f320..de03e47 100644
--- a/arch/mips/include/asm/spinlock.h
+++ b/arch/mips/include/asm/spinlock.h
@@ -479,6 +479,8 @@ static inline int __raw_write_trylock(raw_rwlock_t *rw)
 	return ret;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
diff --git a/arch/powerpc/include/asm/spinlock.h b/arch/powerpc/include/asm/spinlock.h
index f56a843..f6491ae 100644
--- a/arch/powerpc/include/asm/spinlock.h
+++ b/arch/powerpc/include/asm/spinlock.h
@@ -287,6 +287,9 @@ static inline void __raw_write_unlock(raw_rwlock_t *rw)
 	rw->lock = 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	__spin_yield(lock)
 #define _raw_read_relax(lock)	__rw_yield(lock)
 #define _raw_write_relax(lock)	__rw_yield(lock)
diff --git a/arch/s390/include/asm/spinlock.h b/arch/s390/include/asm/spinlock.h
index df84ae9..f3861b0 100644
--- a/arch/s390/include/asm/spinlock.h
+++ b/arch/s390/include/asm/spinlock.h
@@ -172,6 +172,9 @@ static inline int __raw_write_trylock(raw_rwlock_t *rw)
 	return _raw_write_trylock_retry(rw);
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
 
diff --git a/arch/sh/include/asm/spinlock.h b/arch/sh/include/asm/spinlock.h
index e793181..6028356 100644
--- a/arch/sh/include/asm/spinlock.h
+++ b/arch/sh/include/asm/spinlock.h
@@ -216,6 +216,9 @@ static inline int __raw_write_trylock(raw_rwlock_t *rw)
 	return (oldval > (RW_LOCK_BIAS - 1));
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/arch/sparc/include/asm/spinlock_32.h b/arch/sparc/include/asm/spinlock_32.h
index bf2d532..46f91ab 100644
--- a/arch/sparc/include/asm/spinlock_32.h
+++ b/arch/sparc/include/asm/spinlock_32.h
@@ -177,6 +177,8 @@ static inline int __read_trylock(raw_rwlock_t *rw)
 #define __raw_write_unlock(rw)	do { (rw)->lock = 0; } while(0)
 
 #define __raw_spin_lock_flags(lock, flags) __raw_spin_lock(lock)
+#define __raw_read_lock_flags(rw, flags)   __raw_read_lock(rw)
+#define __raw_write_lock_flags(rw, flags)  __raw_write_lock(rw)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
diff --git a/arch/sparc/include/asm/spinlock_64.h b/arch/sparc/include/asm/spinlock_64.h
index 120cfe4..e856cd0 100644
--- a/arch/sparc/include/asm/spinlock_64.h
+++ b/arch/sparc/include/asm/spinlock_64.h
@@ -230,9 +230,11 @@ static int inline __write_trylock(raw_rwlock_t *lock)
 }
 
 #define __raw_read_lock(p)	__read_lock(p)
+#define __raw_read_lock_flags(p, f) __read_lock(p)
 #define __raw_read_trylock(p)	__read_trylock(p)
 #define __raw_read_unlock(p)	__read_unlock(p)
 #define __raw_write_lock(p)	__write_lock(p)
+#define __raw_write_lock_flags(p, f) __write_lock(p)
 #define __raw_write_unlock(p)	__write_unlock(p)
 #define __raw_write_trylock(p)	__write_trylock(p)
 
diff --git a/include/asm-cris/arch-v32/spinlock.h b/include/asm-cris/arch-v32/spinlock.h
index 0d5709b..129756b 100644
--- a/include/asm-cris/arch-v32/spinlock.h
+++ b/include/asm-cris/arch-v32/spinlock.h
@@ -121,6 +121,8 @@ static  inline int __raw_write_trylock(raw_rwlock_t *rw)
 	return 1;
 }
 
+#define _raw_read_lock_flags(lock, flags) _raw_read_lock(lock)
+#define _raw_write_lock_flags(lock, flags) _raw_write_lock(lock)
 
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
diff --git a/include/asm-m32r/spinlock.h b/include/asm-m32r/spinlock.h
index f5cfba8..dded923 100644
--- a/include/asm-m32r/spinlock.h
+++ b/include/asm-m32r/spinlock.h
@@ -316,6 +316,9 @@ static inline int __raw_write_trylock(raw_rwlock_t *lock)
 	return 0;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/include/asm-parisc/spinlock.h b/include/asm-parisc/spinlock.h
index f3d2090..fae03e1 100644
--- a/include/asm-parisc/spinlock.h
+++ b/include/asm-parisc/spinlock.h
@@ -187,6 +187,9 @@ static __inline__ int __raw_write_can_lock(raw_rwlock_t *rw)
 	return !rw->counter;
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/include/asm-x86/spinlock.h b/include/asm-x86/spinlock.h
index 157ff7f..132f5d3 100644
--- a/include/asm-x86/spinlock.h
+++ b/include/asm-x86/spinlock.h
@@ -357,6 +357,9 @@ static inline void __raw_write_unlock(raw_rwlock_t *rw)
 		     : "+m" (rw->lock) : "i" (RW_LOCK_BIAS) : "memory");
 }
 
+#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
+#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
+
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()
diff --git a/include/linux/spinlock.h b/include/linux/spinlock.h
index e0c0fcc..9e3fe36 100644
--- a/include/linux/spinlock.h
+++ b/include/linux/spinlock.h
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
diff --git a/kernel/spinlock.c b/kernel/spinlock.c
index cf41b87..7c2f5b5 100644
--- a/kernel/spinlock.c
+++ b/kernel/spinlock.c
@@ -121,7 +121,8 @@ unsigned long __lockfunc _read_lock_irqsave(rwlock_t *lock)
 	local_irq_save(flags);
 	preempt_disable();
 	rwlock_acquire_read(&lock->dep_map, 0, 0, _RET_IP_);
-	LOCK_CONTENDED(lock, _raw_read_trylock, _raw_read_lock);
+	LOCK_CONTENDED_FLAGS(lock, _raw_read_trylock, _raw_read_lock,
+			     _raw_read_lock_flags, &flags);
 	return flags;
 }
 EXPORT_SYMBOL(_read_lock_irqsave);
@@ -151,7 +152,8 @@ unsigned long __lockfunc _write_lock_irqsave(rwlock_t *lock)
 	local_irq_save(flags);
 	preempt_disable();
 	rwlock_acquire(&lock->dep_map, 0, 0, _RET_IP_);
-	LOCK_CONTENDED(lock, _raw_write_trylock, _raw_write_lock);
+	LOCK_CONTENDED_FLAGS(lock, _raw_write_trylock, _raw_write_lock,
+			     _raw_write_lock_flags, &flags);
 	return flags;
 }
 EXPORT_SYMBOL(_write_lock_irqsave);


