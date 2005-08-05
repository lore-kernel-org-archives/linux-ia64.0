From: Christoph Lameter <clameter@engr.sgi.com>
Date: Fri, 05 Aug 2005 03:33:33 +0000
Subject: IA64 Spinlock optimizations
Message-Id: <Pine.LNX.4.62.0508042031300.3346@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Spinlock optimizations for IA64

1. Nontemporal store for spin unlock.

A nontemporal store will not update the LRU setting for the cacheline. The
cacheline with the lock may therefore be evicted faster from the cpu
caches. Doing so may be useful since it increases the chance that the
exclusive cache line has been evicted when another cpu is trying to
acquire the lock.

The time between dropping and reacquiring a lock on the same cpu is
typically very small so the danger of the cacheline being
evicted is negligible.

2. Avoid semaphore operation in write_unlock and use nontemporal store

write_lock uses a cmpxchg like the regular spin_lock but write_unlock uses
clear_bit which requires a load and then a loop over a cmpxchg. The
following patch makes write_unlock simply use a nontemporal store to clear
the highest 8 bits. We will then still have the lower 3 bytes (24 bits)
left to count the readers.

Doing the byte store will reduce the number of possible readers from 2^31
to 2^24 = 16 million.

These patches were discussed already:

http://marc.theaimsgroup.com/?t1472054400001&r=1&w=2
http://marc.theaimsgroup.com/?l=linux-ia64&m1401837707849&w=2

The nontemporal stores will only work using GCC. If a compiler is used
that does not support inline asm then fallback C code is used. This
will preserve the byte store but not be able to do the nontemporal stores.

This means that kernels compiled with Intel C Compiler will be slightly
less efficient since they do not support inline asm. The patch has been
out there reviewed since April. I have been promised repeatedly
that the patch will be in soon. There is a certain connection between
the IA64 maintainer and Intel. Am I paranoid?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc5/include/asm-ia64/spinlock.h
=================================--- linux-2.6.13-rc5.orig/include/asm-ia64/spinlock.h	2005-08-01 21:45:48.000000000 -0700
+++ linux-2.6.13-rc5/include/asm-ia64/spinlock.h	2005-08-04 20:09:59.000000000 -0700
@@ -93,7 +93,15 @@ _raw_spin_lock_flags (spinlock_t *lock, 
 # endif /* CONFIG_MCKINLEY */
 #endif
 }
+
 #define _raw_spin_lock(lock) _raw_spin_lock_flags(lock, 0)
+
+/* Unlock by doing an ordered store and releasing the cacheline with nta */
+static inline void _raw_spin_unlock(spinlock_t *x) {
+	barrier();
+	asm volatile ("st4.rel.nta [%0] = r0\n\t" :: "r"(x));
+}
+
 #else /* !ASM_SUPPORTED */
 #define _raw_spin_lock_flags(lock, flags) _raw_spin_lock(lock)
 # define _raw_spin_lock(x)								\
@@ -109,16 +117,16 @@ do {											\
 		} while (ia64_spinlock_val);						\
 	}										\
 } while (0)
+#define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock = 0; } while (0)
 #endif /* !ASM_SUPPORTED */
 
 #define spin_is_locked(x)	((x)->lock != 0)
-#define _raw_spin_unlock(x)	do { barrier(); ((spinlock_t *) x)->lock = 0; } while (0)
 #define _raw_spin_trylock(x)	(cmpxchg_acq(&(x)->lock, 0, 1) = 0)
 #define spin_unlock_wait(x)	do { barrier(); } while ((x)->lock)
 
 typedef struct {
-	volatile unsigned int read_counter	: 31;
-	volatile unsigned int write_lock	:  1;
+	volatile unsigned int read_counter	: 24;
+	volatile unsigned int write_lock	:  8;
 #ifdef CONFIG_PREEMPT
 	unsigned int break_lock;
 #endif
@@ -174,6 +182,13 @@ do {										\
 	(result = 0);								\
 })
 
+static inline void _raw_write_unlock(rwlock_t *x)
+{
+	u8 *y = (u8 *)x;
+	barrier();
+	asm volatile ("st1.rel.nta [%0] = r0\n\t" :: "r"(y+3) : "memory" );
+}
+
 #else /* !ASM_SUPPORTED */
 
 #define _raw_write_lock(l)								\
@@ -195,14 +210,14 @@ do {										\
 	(ia64_val = 0);						\
 })
 
+static inline void _raw_write_unlock(rwlock_t *x)
+{
+	barrier();
+	x-&gt;write_lock = 0;
+}
+
 #endif /* !ASM_SUPPORTED */
 
 #define _raw_read_trylock(lock) generic_raw_read_trylock(lock)
 
-#define _raw_write_unlock(x)								\
-({											\
-	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
-	clear_bit(31, (x));								\
-})
-
 #endif /*  _ASM_IA64_SPINLOCK_H */
