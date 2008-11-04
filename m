From: holt@sgi.com
Date: Tue, 04 Nov 2008 12:24:08 +0000
Subject: [Patch V3 3/3] ia64: implement interrupt-enabling rwlocks
Message-Id: <20081104122419.300137718@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20081104122405.046233722@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com
Cc: Petr Tesarik <ptesarik@suse.cz>, Tony Ernst <tee@sgi.com>, Robin Holt <holt@sgi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>

Implement __raw_read_lock_flags and __raw_write_lock_flags for the
ia64 architecture.

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
Signed-off-by: Robin Holt <holt@sgi.com>
---
 spinlock.h |   80 ++++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 63 insertions(+), 17 deletions(-)

Index: rwlock/arch/ia64/include/asm/spinlock.h
=================================--- rwlock.orig/arch/ia64/include/asm/spinlock.h	2008-11-04 06:01:29.251624869 -0600
+++ rwlock/arch/ia64/include/asm/spinlock.h	2008-11-04 06:01:32.500040620 -0600
@@ -120,6 +120,38 @@ do {											\
 #define __raw_read_can_lock(rw)		(*(volatile int *)(rw) >= 0)
 #define __raw_write_can_lock(rw)	(*(volatile int *)(rw) = 0)
 
+#ifdef ASM_SUPPORTED
+
+static __always_inline void
+__raw_read_lock_flags(raw_spinlock_t *lock, unsigned long flags)
+{
+	__asm__ __volatile__ (
+		"tbit.nz p6, p0 = %1,%2\n"
+		"br.few 3f\n"
+		"1:\n"
+		"fetchadd4.rel r2 = [%0], -1;;\n"
+		"(p6) ssm psr.i\n"
+		"2:\n"
+		"hint @pause\n"
+		"ld4 r2 = [%0];;\n"
+		"cmp4.lt p7,p0 = r2, r0\n"
+		"(p7) br.cond.spnt.few 2b\n"
+		"(p6) rsm psr.i\n"
+		";;\n"
+		"3:\n"
+		"fetchadd4.acq r2 = [%0], 1;;\n"
+		"cmp4.lt p7,p0 = r2, r0\n"
+		"(p7) br.cond.spnt.few 1b\n"
+		: : "r"(lock), "r"(flags), "i"(IA64_PSR_I_BIT)
+		: "p6", "p7", "r2", "memory");
+}
+
+#define __raw_read_lock(lock) __raw_read_lock_flags(lock, 0)
+
+#else /* !ASM_SUPPORTED */
+
+#define __raw_read_lock_flags(rw, flags) __raw_read_lock(rw)
+
 #define __raw_read_lock(rw)								\
 do {											\
 	raw_rwlock_t *__read_lock_ptr = (rw);						\
@@ -131,6 +163,8 @@ do {											\
 	}										\
 } while (0)
 
+#endif /* !ASM_SUPPORTED */
+
 #define __raw_read_unlock(rw)					\
 do {								\
 	raw_rwlock_t *__read_lock_ptr = (rw);			\
@@ -138,20 +172,33 @@ do {								\
 } while (0)
 
 #ifdef ASM_SUPPORTED
-#define __raw_write_lock(rw)							\
-do {										\
- 	__asm__ __volatile__ (							\
-		"mov ar.ccv = r0\n"						\
-		"dep r29 = -1, r0, 31, 1;;\n"					\
-		"1:\n"								\
-		"ld4 r2 = [%0];;\n"						\
-		"cmp4.eq p0,p7 = r0,r2\n"					\
-		"(p7) br.cond.spnt.few 1b \n"					\
-		"cmpxchg4.acq r2 = [%0], r29, ar.ccv;;\n"			\
-		"cmp4.eq p0,p7 = r0, r2\n"					\
-		"(p7) br.cond.spnt.few 1b;;\n"					\
-		:: "r"(rw) : "ar.ccv", "p7", "r2", "r29", "memory");		\
-} while(0)
+
+static __always_inline void
+__raw_write_lock_flags(raw_spinlock_t *lock, unsigned long flags)
+{
+	__asm__ __volatile__ (
+		"tbit.nz p6, p0 = %1, %2\n"
+		"mov ar.ccv = r0\n"
+		"dep r29 = -1, r0, 31, 1\n"
+		"br.few 3f;;\n"
+		"1:\n"
+		"(p6) ssm psr.i\n"
+		"2:\n"
+		"hint @pause\n"
+		"ld4 r2 = [%0];;\n"
+		"cmp4.eq p0,p7 = r0, r2\n"
+		"(p7) br.cond.spnt.few 2b\n"
+		"(p6) rsm psr.i\n"
+		";;\n"
+		"3:\n"
+		"cmpxchg4.acq r2 = [%0], r29, ar.ccv;;\n"
+		"cmp4.eq p0,p7 = r0, r2\n"
+		"(p7) br.cond.spnt.few 1b;;\n"
+		: : "r"(lock), "r"(flags), "i"(IA64_PSR_I_BIT)
+		: "ar.ccv", "p6", "p7", "r2", "r29", "memory");
+}
+
+#define __raw_write_lock(rw) __raw_write_lock_flags(rw, 0)
 
 #define __raw_write_trylock(rw)							\
 ({										\
@@ -174,6 +221,8 @@ static inline void __raw_write_unlock(ra
 
 #else /* !ASM_SUPPORTED */
 
+#define __raw_write_lock_flags(l, flags) __raw_write_lock(l)
+
 #define __raw_write_lock(l)								\
 ({											\
 	__u64 ia64_val, ia64_set_val = ia64_dep_mi(-1, 0, 31, 1);			\
@@ -213,9 +262,6 @@ static inline int __raw_read_trylock(raw
 	return (u32)ia64_cmpxchg4_acq((__u32 *)(x), new.word, old.word) = old.word;
 }
 
-#define __raw_read_lock_flags(lock, flags) __raw_read_lock(lock)
-#define __raw_write_lock_flags(lock, flags) __raw_write_lock(lock)
-
 #define _raw_spin_relax(lock)	cpu_relax()
 #define _raw_read_relax(lock)	cpu_relax()
 #define _raw_write_relax(lock)	cpu_relax()

