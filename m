From: Christoph Lameter <clameter@engr.sgi.com>
Date: Mon, 22 Aug 2005 19:20:13 +0000
Subject: [PATCH] Remove rwsem limitation of 32k waiters
Message-Id: <Pine.LNX.4.62.0508221215370.7633@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

We ran into the limit with the maximum number of waiters at one of our sites.

This patch increases the number of possible waiters from 2^15 to 2^31 by using
a long for the counter in struct rw_semaphore.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc6/include/asm-ia64/rwsem.h
=================================--- linux-2.6.13-rc6.orig/include/asm-ia64/rwsem.h	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/include/asm-ia64/rwsem.h	2005-08-22 12:17:13.000000000 -0700
@@ -3,6 +3,7 @@
  *
  * Copyright (C) 2003 Ken Chen <kenneth.w.chen@intel.com>
  * Copyright (C) 2003 Asit Mallick <asit.k.mallick@intel.com>
+ * Copyright (C) 2005 Christoph Lameter <clameter@sgi.com>
  *
  * Based on asm-i386/rwsem.h and other architecture implementation.
  *
@@ -11,9 +12,9 @@
  *
  * The lock count is initialized to 0 (no active and no waiting lockers).
  *
- * When a writer subtracts WRITE_BIAS, it'll get 0xffff0001 for the case
- * of an uncontended lock. Readers increment by 1 and see a positive value
- * when uncontended, negative if there are writers (and maybe) readers
+ * When a writer subtracts WRITE_BIAS, it'll get 0xffffffff00000001 for
+ * the case of an uncontended lock. Readers increment by 1 and see a positive
+ * value when uncontended, negative if there are writers (and maybe) readers
  * waiting (in which case it goes to sleep).
  */
 
@@ -29,7 +30,7 @@
  * the semaphore definition
  */
 struct rw_semaphore {
-	signed int		count;
+	signed long		count;
 	spinlock_t		wait_lock;
 	struct list_head	wait_list;
 #if RWSEM_DEBUG
@@ -37,10 +38,10 @@ struct rw_semaphore {
 #endif
 };
 
-#define RWSEM_UNLOCKED_VALUE		0x00000000
-#define RWSEM_ACTIVE_BIAS		0x00000001
-#define RWSEM_ACTIVE_MASK		0x0000ffff
-#define RWSEM_WAITING_BIAS		(-0x00010000)
+#define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
+#define RWSEM_ACTIVE_BIAS		__IA64_UL_CONST(0x0000000000000001)
+#define RWSEM_ACTIVE_MASK		__IA64_UL_CONST(0x00000000ffffffff)
+#define RWSEM_WAITING_BIAS		-__IA64_UL_CONST(0x0000000100000000)
 #define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
@@ -83,7 +84,7 @@ init_rwsem (struct rw_semaphore *sem)
 static inline void
 __down_read (struct rw_semaphore *sem)
 {
-	int result = ia64_fetchadd4_acq((unsigned int *)&sem->count, 1);
+	long result = ia64_fetchadd8_acq((unsigned long *)&sem->count, 1);
 
 	if (result < 0)
 		rwsem_down_read_failed(sem);
@@ -95,7 +96,7 @@ __down_read (struct rw_semaphore *sem)
 static inline void
 __down_write (struct rw_semaphore *sem)
 {
-	int old, new;
+	long old, new;
 
 	do {
 		old = sem->count;
@@ -112,7 +113,7 @@ __down_write (struct rw_semaphore *sem)
 static inline void
 __up_read (struct rw_semaphore *sem)
 {
-	int result = ia64_fetchadd4_rel((unsigned int *)&sem->count, -1);
+	long result = ia64_fetchadd8_rel((unsigned long *)&sem->count, -1);
 
 	if (result < 0 && (--result & RWSEM_ACTIVE_MASK) = 0)
 		rwsem_wake(sem);
@@ -124,7 +125,7 @@ __up_read (struct rw_semaphore *sem)
 static inline void
 __up_write (struct rw_semaphore *sem)
 {
-	int old, new;
+	long old, new;
 
 	do {
 		old = sem->count;
@@ -141,7 +142,7 @@ __up_write (struct rw_semaphore *sem)
 static inline int
 __down_read_trylock (struct rw_semaphore *sem)
 {
-	int tmp;
+	long tmp;
 	while ((tmp = sem->count) >= 0) {
 		if (tmp = cmpxchg_acq(&sem->count, tmp, tmp+1)) {
 			return 1;
@@ -156,7 +157,7 @@ __down_read_trylock (struct rw_semaphore
 static inline int
 __down_write_trylock (struct rw_semaphore *sem)
 {
-	int tmp = cmpxchg_acq(&sem->count, RWSEM_UNLOCKED_VALUE,
+	long tmp = cmpxchg_acq(&sem->count, RWSEM_UNLOCKED_VALUE,
 			      RWSEM_ACTIVE_WRITE_BIAS);
 	return tmp = RWSEM_UNLOCKED_VALUE;
 }
@@ -167,7 +168,7 @@ __down_write_trylock (struct rw_semaphor
 static inline void
 __downgrade_write (struct rw_semaphore *sem)
 {
-	int old, new;
+	long old, new;
 
 	do {
 		old = sem->count;
@@ -182,7 +183,7 @@ __downgrade_write (struct rw_semaphore *
  * Implement atomic add functionality.  These used to be "inline" functions, but GCC v3.1
  * doesn't quite optimize this stuff right and ends up with bad calls to fetchandadd.
  */
-#define rwsem_atomic_add(delta, sem)	atomic_add(delta, (atomic_t *)(&(sem)->count))
-#define rwsem_atomic_update(delta, sem)	atomic_add_return(delta, (atomic_t *)(&(sem)->count))
+#define rwsem_atomic_add(delta, sem)	atomic64_add(delta, (atomic64_t *)(&(sem)->count))
+#define rwsem_atomic_update(delta, sem)	atomic64_add_return(delta, (atomic64_t *)(&(sem)->count))
 
 #endif /* _ASM_IA64_RWSEM_H */
