From: Waiman Long <longman@redhat.com>
Date: Wed, 18 Oct 2017 18:30:22 +0000
Subject: [PATCH-tip v7 06/15] locking/rwsem: Remove arch specific rwsem files
Message-Id: <1508351431-22375-7-git-send-email-longman@redhat.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1508351431-22375-1-git-send-email-longman@redhat.com>
In-Reply-To: <1508351431-22375-1-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Dave Chinner <david@fromorbit.com>, Waiman Long <longman@redhat.com>

As the generic rwsem-xadd code is using the appropriate acquire and
release versions of the atomic operations, the arch specific rwsem.h
files will not that much faster than the generic code. So we can
remove those arch specific rwsem.h and stop building asm/rwsem.h to
reduce maintenance effort.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 arch/alpha/include/asm/rwsem.h  | 210 -----------------------------------
 arch/arm/include/asm/Kbuild     |   1 -
 arch/arm64/include/asm/Kbuild   |   1 -
 arch/hexagon/include/asm/Kbuild |   1 -
 arch/ia64/include/asm/rwsem.h   | 171 -----------------------------
 arch/powerpc/include/asm/Kbuild |   1 -
 arch/s390/include/asm/rwsem.h   | 225 --------------------------------------
 arch/sh/include/asm/Kbuild      |   1 -
 arch/sparc/include/asm/Kbuild   |   1 -
 arch/x86/include/asm/rwsem.h    | 236 ----------------------------------------
 arch/x86/lib/Makefile           |   1 -
 arch/x86/lib/rwsem.S            | 156 --------------------------
 arch/xtensa/include/asm/Kbuild  |   1 -
 13 files changed, 1006 deletions(-)
 delete mode 100644 arch/alpha/include/asm/rwsem.h
 delete mode 100644 arch/ia64/include/asm/rwsem.h
 delete mode 100644 arch/s390/include/asm/rwsem.h
 delete mode 100644 arch/x86/include/asm/rwsem.h
 delete mode 100644 arch/x86/lib/rwsem.S

diff --git a/arch/alpha/include/asm/rwsem.h b/arch/alpha/include/asm/rwsem.h
deleted file mode 100644
index 9624cb4..0000000
--- a/arch/alpha/include/asm/rwsem.h
+++ /dev/null
@@ -1,210 +0,0 @@
-#ifndef _ALPHA_RWSEM_H
-#define _ALPHA_RWSEM_H
-
-/*
- * Written by Ivan Kokshaysky <ink@jurassic.park.msu.ru>, 2001.
- * Based on asm-alpha/semaphore.h and asm-i386/rwsem.h
- */
-
-#ifndef _LINUX_RWSEM_H
-#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
-#endif
-
-#ifdef __KERNEL__
-
-#include <linux/compiler.h>
-
-#define RWSEM_UNLOCKED_VALUE		0x0000000000000000L
-#define RWSEM_ACTIVE_BIAS		0x0000000000000001L
-#define RWSEM_ACTIVE_MASK		0x00000000ffffffffL
-#define RWSEM_WAITING_BIAS		(-0x0000000100000000L)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-static inline int ___down_read(struct rw_semaphore *sem)
-{
-	long oldcount;
-#ifndef	CONFIG_SMP
-	oldcount = sem->count.counter;
-	sem->count.counter += RWSEM_ACTIVE_READ_BIAS;
-#else
-	long temp;
-	__asm__ __volatile__(
-	"1:	ldq_l	%0,%1\n"
-	"	addq	%0,%3,%2\n"
-	"	stq_c	%2,%1\n"
-	"	beq	%2,2f\n"
-	"	mb\n"
-	".subsection 2\n"
-	"2:	br	1b\n"
-	".previous"
-	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
-	:"Ir" (RWSEM_ACTIVE_READ_BIAS), "m" (sem->count) : "memory");
-#endif
-	return (oldcount < 0);
-}
-
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	if (unlikely(___down_read(sem)))
-		rwsem_down_read_failed(sem);
-}
-
-static inline int __down_read_killable(struct rw_semaphore *sem)
-{
-	if (unlikely(___down_read(sem)))
-		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
-			return -EINTR;
-
-	return 0;
-}
-
-/*
- * trylock for reading -- returns 1 if successful, 0 if contention
- */
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	long old, new, res;
-
-	res = atomic_long_read(&sem->count);
-	do {
-		new = res + RWSEM_ACTIVE_READ_BIAS;
-		if (new <= 0)
-			break;
-		old = res;
-		res = atomic_long_cmpxchg(&sem->count, old, new);
-	} while (res != old);
-	return res >= 0 ? 1 : 0;
-}
-
-static inline long ___down_write(struct rw_semaphore *sem)
-{
-	long oldcount;
-#ifndef	CONFIG_SMP
-	oldcount = sem->count.counter;
-	sem->count.counter += RWSEM_ACTIVE_WRITE_BIAS;
-#else
-	long temp;
-	__asm__ __volatile__(
-	"1:	ldq_l	%0,%1\n"
-	"	addq	%0,%3,%2\n"
-	"	stq_c	%2,%1\n"
-	"	beq	%2,2f\n"
-	"	mb\n"
-	".subsection 2\n"
-	"2:	br	1b\n"
-	".previous"
-	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
-	:"Ir" (RWSEM_ACTIVE_WRITE_BIAS), "m" (sem->count) : "memory");
-#endif
-	return oldcount;
-}
-
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	if (unlikely(___down_write(sem)))
-		rwsem_down_write_failed(sem);
-}
-
-static inline int __down_write_killable(struct rw_semaphore *sem)
-{
-	if (unlikely(___down_write(sem))) {
-		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
-			return -EINTR;
-	}
-
-	return 0;
-}
-
-/*
- * trylock for writing -- returns 1 if successful, 0 if contention
- */
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	long ret = atomic_long_cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
-			   RWSEM_ACTIVE_WRITE_BIAS);
-	if (ret = RWSEM_UNLOCKED_VALUE)
-		return 1;
-	return 0;
-}
-
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	long oldcount;
-#ifndef	CONFIG_SMP
-	oldcount = sem->count.counter;
-	sem->count.counter -= RWSEM_ACTIVE_READ_BIAS;
-#else
-	long temp;
-	__asm__ __volatile__(
-	"	mb\n"
-	"1:	ldq_l	%0,%1\n"
-	"	subq	%0,%3,%2\n"
-	"	stq_c	%2,%1\n"
-	"	beq	%2,2f\n"
-	".subsection 2\n"
-	"2:	br	1b\n"
-	".previous"
-	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
-	:"Ir" (RWSEM_ACTIVE_READ_BIAS), "m" (sem->count) : "memory");
-#endif
-	if (unlikely(oldcount < 0))
-		if ((int)oldcount - RWSEM_ACTIVE_READ_BIAS = 0)
-			rwsem_wake(sem);
-}
-
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	long count;
-#ifndef	CONFIG_SMP
-	sem->count.counter -= RWSEM_ACTIVE_WRITE_BIAS;
-	count = sem->count.counter;
-#else
-	long temp;
-	__asm__ __volatile__(
-	"	mb\n"
-	"1:	ldq_l	%0,%1\n"
-	"	subq	%0,%3,%2\n"
-	"	stq_c	%2,%1\n"
-	"	beq	%2,2f\n"
-	"	subq	%0,%3,%0\n"
-	".subsection 2\n"
-	"2:	br	1b\n"
-	".previous"
-	:"=&r" (count), "=m" (sem->count), "=&r" (temp)
-	:"Ir" (RWSEM_ACTIVE_WRITE_BIAS), "m" (sem->count) : "memory");
-#endif
-	if (unlikely(count))
-		if ((int)count = 0)
-			rwsem_wake(sem);
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	long oldcount;
-#ifndef	CONFIG_SMP
-	oldcount = sem->count.counter;
-	sem->count.counter -= RWSEM_WAITING_BIAS;
-#else
-	long temp;
-	__asm__ __volatile__(
-	"1:	ldq_l	%0,%1\n"
-	"	addq	%0,%3,%2\n"
-	"	stq_c	%2,%1\n"
-	"	beq	%2,2f\n"
-	"	mb\n"
-	".subsection 2\n"
-	"2:	br	1b\n"
-	".previous"
-	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
-	:"Ir" (-RWSEM_WAITING_BIAS), "m" (sem->count) : "memory");
-#endif
-	if (unlikely(oldcount < 0))
-		rwsem_downgrade_wake(sem);
-}
-
-#endif /* __KERNEL__ */
-#endif /* _ALPHA_RWSEM_H */
diff --git a/arch/arm/include/asm/Kbuild b/arch/arm/include/asm/Kbuild
index 721ab5e..58337ef 100644
--- a/arch/arm/include/asm/Kbuild
+++ b/arch/arm/include/asm/Kbuild
@@ -12,7 +12,6 @@ generic-y += mm-arch-hooks.h
 generic-y += msi.h
 generic-y += parport.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += seccomp.h
 generic-y += segment.h
 generic-y += serial.h
diff --git a/arch/arm64/include/asm/Kbuild b/arch/arm64/include/asm/Kbuild
index 2326e39..38366a6 100644
--- a/arch/arm64/include/asm/Kbuild
+++ b/arch/arm64/include/asm/Kbuild
@@ -16,7 +16,6 @@ generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += msi.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += segment.h
 generic-y += serial.h
 generic-y += set_memory.h
diff --git a/arch/hexagon/include/asm/Kbuild b/arch/hexagon/include/asm/Kbuild
index 3401368..002eb1f 100644
--- a/arch/hexagon/include/asm/Kbuild
+++ b/arch/hexagon/include/asm/Kbuild
@@ -24,7 +24,6 @@ generic-y += mm-arch-hooks.h
 generic-y += pci.h
 generic-y += percpu.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += sections.h
 generic-y += segment.h
 generic-y += serial.h
diff --git a/arch/ia64/include/asm/rwsem.h b/arch/ia64/include/asm/rwsem.h
deleted file mode 100644
index 49f7db0..0000000
--- a/arch/ia64/include/asm/rwsem.h
+++ /dev/null
@@ -1,171 +0,0 @@
-/*
- * R/W semaphores for ia64
- *
- * Copyright (C) 2003 Ken Chen <kenneth.w.chen@intel.com>
- * Copyright (C) 2003 Asit Mallick <asit.k.mallick@intel.com>
- * Copyright (C) 2005 Christoph Lameter <cl@linux.com>
- *
- * Based on asm-i386/rwsem.h and other architecture implementation.
- *
- * The MSW of the count is the negated number of active writers and
- * waiting lockers, and the LSW is the total number of active locks.
- *
- * The lock count is initialized to 0 (no active and no waiting lockers).
- *
- * When a writer subtracts WRITE_BIAS, it'll get 0xffffffff00000001 for
- * the case of an uncontended lock. Readers increment by 1 and see a positive
- * value when uncontended, negative if there are writers (and maybe) readers
- * waiting (in which case it goes to sleep).
- */
-
-#ifndef _ASM_IA64_RWSEM_H
-#define _ASM_IA64_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "Please don't include <asm/rwsem.h> directly, use <linux/rwsem.h> instead."
-#endif
-
-#include <asm/intrinsics.h>
-
-#define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
-#define RWSEM_ACTIVE_BIAS		(1L)
-#define RWSEM_ACTIVE_MASK		(0xffffffffL)
-#define RWSEM_WAITING_BIAS		(-0x100000000L)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline int
-___down_read (struct rw_semaphore *sem)
-{
-	long result = ia64_fetchadd8_acq((unsigned long *)&sem->count.counter, 1);
-
-	return (result < 0);
-}
-
-static inline void
-__down_read (struct rw_semaphore *sem)
-{
-	if (___down_read(sem))
-		rwsem_down_read_failed(sem);
-}
-
-static inline int
-__down_read_killable (struct rw_semaphore *sem)
-{
-	if (___down_read(sem))
-		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
-			return -EINTR;
-
-	return 0;
-}
-
-/*
- * lock for writing
- */
-static inline long
-___down_write (struct rw_semaphore *sem)
-{
-	long old, new;
-
-	do {
-		old = atomic_long_read(&sem->count);
-		new = old + RWSEM_ACTIVE_WRITE_BIAS;
-	} while (atomic_long_cmpxchg_acquire(&sem->count, old, new) != old);
-
-	return old;
-}
-
-static inline void
-__down_write (struct rw_semaphore *sem)
-{
-	if (___down_write(sem))
-		rwsem_down_write_failed(sem);
-}
-
-static inline int
-__down_write_killable (struct rw_semaphore *sem)
-{
-	if (___down_write(sem)) {
-		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
-			return -EINTR;
-	}
-
-	return 0;
-}
-
-/*
- * unlock after reading
- */
-static inline void
-__up_read (struct rw_semaphore *sem)
-{
-	long result = ia64_fetchadd8_rel((unsigned long *)&sem->count.counter, -1);
-
-	if (result < 0 && (--result & RWSEM_ACTIVE_MASK) = 0)
-		rwsem_wake(sem);
-}
-
-/*
- * unlock after writing
- */
-static inline void
-__up_write (struct rw_semaphore *sem)
-{
-	long old, new;
-
-	do {
-		old = atomic_long_read(&sem->count);
-		new = old - RWSEM_ACTIVE_WRITE_BIAS;
-	} while (atomic_long_cmpxchg_release(&sem->count, old, new) != old);
-
-	if (new < 0 && (new & RWSEM_ACTIVE_MASK) = 0)
-		rwsem_wake(sem);
-}
-
-/*
- * trylock for reading -- returns 1 if successful, 0 if contention
- */
-static inline int
-__down_read_trylock (struct rw_semaphore *sem)
-{
-	long tmp;
-	while ((tmp = atomic_long_read(&sem->count)) >= 0) {
-		if (tmp = atomic_long_cmpxchg_acquire(&sem->count, tmp, tmp+1)) {
-			return 1;
-		}
-	}
-	return 0;
-}
-
-/*
- * trylock for writing -- returns 1 if successful, 0 if contention
- */
-static inline int
-__down_write_trylock (struct rw_semaphore *sem)
-{
-	long tmp = atomic_long_cmpxchg_acquire(&sem->count,
-			RWSEM_UNLOCKED_VALUE, RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp = RWSEM_UNLOCKED_VALUE;
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void
-__downgrade_write (struct rw_semaphore *sem)
-{
-	long old, new;
-
-	do {
-		old = atomic_long_read(&sem->count);
-		new = old - RWSEM_WAITING_BIAS;
-	} while (atomic_long_cmpxchg_release(&sem->count, old, new) != old);
-
-	if (old < 0)
-		rwsem_downgrade_wake(sem);
-}
-
-#endif /* _ASM_IA64_RWSEM_H */
diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
index 2542ea1..e25807a 100644
--- a/arch/powerpc/include/asm/Kbuild
+++ b/arch/powerpc/include/asm/Kbuild
@@ -6,6 +6,5 @@ generic-y += irq_work.h
 generic-y += local64.h
 generic-y += mcs_spinlock.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += vtime.h
 generic-y += msi.h
diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h
deleted file mode 100644
index fda9481..0000000
--- a/arch/s390/include/asm/rwsem.h
+++ /dev/null
@@ -1,225 +0,0 @@
-#ifndef _S390_RWSEM_H
-#define _S390_RWSEM_H
-
-/*
- *  S390 version
- *    Copyright IBM Corp. 2002
- *    Author(s): Martin Schwidefsky (schwidefsky@de.ibm.com)
- *
- *  Based on asm-alpha/semaphore.h and asm-i386/rwsem.h
- */
-
-/*
- *
- * The MSW of the count is the negated number of active writers and waiting
- * lockers, and the LSW is the total number of active locks
- *
- * The lock count is initialized to 0 (no active and no waiting lockers).
- *
- * When a writer subtracts WRITE_BIAS, it'll get 0xffff0001 for the case of an
- * uncontended lock. This can be determined because XADD returns the old value.
- * Readers increment by 1 and see a positive value when uncontended, negative
- * if there are writers (and maybe) readers waiting (in which case it goes to
- * sleep).
- *
- * The value of WAITING_BIAS supports up to 32766 waiting processes. This can
- * be extended to 65534 by manually checking the whole MSW rather than relying
- * on the S flag.
- *
- * The value of ACTIVE_BIAS supports up to 65535 active processes.
- *
- * This should be totally fair - if anything is waiting, a process that wants a
- * lock will go to the back of the queue. When the currently active lock is
- * released, if there's a writer at the front of the queue, then that and only
- * that will be woken up; if there's a bunch of consecutive readers at the
- * front, then they'll all be woken up, but no other readers will be.
- */
-
-#ifndef _LINUX_RWSEM_H
-#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
-#endif
-
-#define RWSEM_UNLOCKED_VALUE	0x0000000000000000L
-#define RWSEM_ACTIVE_BIAS	0x0000000000000001L
-#define RWSEM_ACTIVE_MASK	0x00000000ffffffffL
-#define RWSEM_WAITING_BIAS	(-0x0000000100000000L)
-#define RWSEM_ACTIVE_READ_BIAS	RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS	(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline int ___down_read(struct rw_semaphore *sem)
-{
-	signed long old, new;
-
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	lgr	%1,%0\n"
-		"	aghi	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "i" (RWSEM_ACTIVE_READ_BIAS)
-		: "cc", "memory");
-	return (old < 0);
-}
-
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	if (___down_read(sem))
-		rwsem_down_read_failed(sem);
-}
-
-static inline int __down_read_killable(struct rw_semaphore *sem)
-{
-	if (___down_read(sem)) {
-		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
-			return -EINTR;
-	}
-
-	return 0;
-}
-
-/*
- * trylock for reading -- returns 1 if successful, 0 if contention
- */
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	signed long old, new;
-
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	ltgr	%1,%0\n"
-		"	jm	1f\n"
-		"	aghi	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b\n"
-		"1:"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "i" (RWSEM_ACTIVE_READ_BIAS)
-		: "cc", "memory");
-	return old >= 0 ? 1 : 0;
-}
-
-/*
- * lock for writing
- */
-static inline long ___down_write(struct rw_semaphore *sem)
-{
-	signed long old, new, tmp;
-
-	tmp = RWSEM_ACTIVE_WRITE_BIAS;
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	lgr	%1,%0\n"
-		"	ag	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "m" (tmp)
-		: "cc", "memory");
-
-	return old;
-}
-
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	if (___down_write(sem))
-		rwsem_down_write_failed(sem);
-}
-
-static inline int __down_write_killable(struct rw_semaphore *sem)
-{
-	if (___down_write(sem))
-		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
-			return -EINTR;
-
-	return 0;
-}
-
-/*
- * trylock for writing -- returns 1 if successful, 0 if contention
- */
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	signed long old;
-
-	asm volatile(
-		"	lg	%0,%1\n"
-		"0:	ltgr	%0,%0\n"
-		"	jnz	1f\n"
-		"	csg	%0,%3,%1\n"
-		"	jl	0b\n"
-		"1:"
-		: "=&d" (old), "=Q" (sem->count)
-		: "Q" (sem->count), "d" (RWSEM_ACTIVE_WRITE_BIAS)
-		: "cc", "memory");
-	return (old = RWSEM_UNLOCKED_VALUE) ? 1 : 0;
-}
-
-/*
- * unlock after reading
- */
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	signed long old, new;
-
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	lgr	%1,%0\n"
-		"	aghi	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "i" (-RWSEM_ACTIVE_READ_BIAS)
-		: "cc", "memory");
-	if (new < 0)
-		if ((new & RWSEM_ACTIVE_MASK) = 0)
-			rwsem_wake(sem);
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	signed long old, new, tmp;
-
-	tmp = -RWSEM_ACTIVE_WRITE_BIAS;
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	lgr	%1,%0\n"
-		"	ag	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "m" (tmp)
-		: "cc", "memory");
-	if (new < 0)
-		if ((new & RWSEM_ACTIVE_MASK) = 0)
-			rwsem_wake(sem);
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	signed long old, new, tmp;
-
-	tmp = -RWSEM_WAITING_BIAS;
-	asm volatile(
-		"	lg	%0,%2\n"
-		"0:	lgr	%1,%0\n"
-		"	ag	%1,%4\n"
-		"	csg	%0,%1,%2\n"
-		"	jl	0b"
-		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
-		: "Q" (sem->count), "m" (tmp)
-		: "cc", "memory");
-	if (new > 1)
-		rwsem_downgrade_wake(sem);
-}
-
-#endif /* _S390_RWSEM_H */
diff --git a/arch/sh/include/asm/Kbuild b/arch/sh/include/asm/Kbuild
index 1a6f9c3..24af7e6 100644
--- a/arch/sh/include/asm/Kbuild
+++ b/arch/sh/include/asm/Kbuild
@@ -13,7 +13,6 @@ generic-y += mm-arch-hooks.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += serial.h
 generic-y += sizes.h
 generic-y += trace_clock.h
diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index 80ddc01..2c6d988 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -15,7 +15,6 @@ generic-y += mcs_spinlock.h
 generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += serial.h
 generic-y += trace_clock.h
 generic-y += word-at-a-time.h
diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
deleted file mode 100644
index 1e51195..0000000
--- a/arch/x86/include/asm/rwsem.h
+++ /dev/null
@@ -1,236 +0,0 @@
-/* rwsem.h: R/W semaphores implemented using XADD/CMPXCHG for i486+
- *
- * Written by David Howells (dhowells@redhat.com).
- *
- * Derived from asm-x86/semaphore.h
- *
- *
- * The MSW of the count is the negated number of active writers and waiting
- * lockers, and the LSW is the total number of active locks
- *
- * The lock count is initialized to 0 (no active and no waiting lockers).
- *
- * When a writer subtracts WRITE_BIAS, it'll get 0xffff0001 for the case of an
- * uncontended lock. This can be determined because XADD returns the old value.
- * Readers increment by 1 and see a positive value when uncontended, negative
- * if there are writers (and maybe) readers waiting (in which case it goes to
- * sleep).
- *
- * The value of WAITING_BIAS supports up to 32766 waiting processes. This can
- * be extended to 65534 by manually checking the whole MSW rather than relying
- * on the S flag.
- *
- * The value of ACTIVE_BIAS supports up to 65535 active processes.
- *
- * This should be totally fair - if anything is waiting, a process that wants a
- * lock will go to the back of the queue. When the currently active lock is
- * released, if there's a writer at the front of the queue, then that and only
- * that will be woken up; if there's a bunch of consecutive readers at the
- * front, then they'll all be woken up, but no other readers will be.
- */
-
-#ifndef _ASM_X86_RWSEM_H
-#define _ASM_X86_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
-#endif
-
-#ifdef __KERNEL__
-#include <asm/asm.h>
-
-/*
- * The bias values and the counter type limits the number of
- * potential readers/writers to 32767 for 32 bits and 2147483647
- * for 64 bits.
- */
-
-#ifdef CONFIG_X86_64
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-#define ____down_read(sem, slow_path)					\
-({									\
-	struct rw_semaphore* ret;					\
-	asm volatile("# beginning down_read\n\t"			\
-		     LOCK_PREFIX _ASM_INC "(%[sem])\n\t"		\
-		     /* adds 0x00000001 */				\
-		     "  jns        1f\n"				\
-		     "  call " slow_path "\n"				\
-		     "1:\n\t"						\
-		     "# ending down_read\n\t"				\
-		     : "+m" (sem->count), "=a" (ret),			\
-			ASM_CALL_CONSTRAINT				\
-		     : [sem] "a" (sem)					\
-		     : "memory", "cc");					\
-	ret;								\
-})
-
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	____down_read(sem, "call_rwsem_down_read_failed");
-}
-
-static inline int __down_read_killable(struct rw_semaphore *sem)
-{
-	if (IS_ERR(____down_read(sem, "call_rwsem_down_read_failed_killable")))
-		return -EINTR;
-	return 0;
-}
-
-/*
- * trylock for reading -- returns 1 if successful, 0 if contention
- */
-static inline bool __down_read_trylock(struct rw_semaphore *sem)
-{
-	long result, tmp;
-	asm volatile("# beginning __down_read_trylock\n\t"
-		     "  mov          %[count],%[result]\n\t"
-		     "1:\n\t"
-		     "  mov          %[result],%[tmp]\n\t"
-		     "  add          %[inc],%[tmp]\n\t"
-		     "  jle	     2f\n\t"
-		     LOCK_PREFIX "  cmpxchg  %[tmp],%[count]\n\t"
-		     "  jnz	     1b\n\t"
-		     "2:\n\t"
-		     "# ending __down_read_trylock\n\t"
-		     : [count] "+m" (sem->count), [result] "=&a" (result),
-		       [tmp] "=&r" (tmp)
-		     : [inc] "i" (RWSEM_ACTIVE_READ_BIAS)
-		     : "memory", "cc");
-	return result >= 0;
-}
-
-/*
- * lock for writing
- */
-#define ____down_write(sem, slow_path)			\
-({							\
-	long tmp;					\
-	struct rw_semaphore* ret;			\
-							\
-	asm volatile("# beginning down_write\n\t"	\
-		     LOCK_PREFIX "  xadd      %[tmp],(%[sem])\n\t"	\
-		     /* adds 0xffff0001, returns the old value */ \
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t" \
-		     /* was the active mask 0 before? */\
-		     "  jz        1f\n"			\
-		     "  call " slow_path "\n"		\
-		     "1:\n"				\
-		     "# ending down_write"		\
-		     : "+m" (sem->count), [tmp] "=d" (tmp),	\
-		       "=a" (ret), ASM_CALL_CONSTRAINT	\
-		     : [sem] "a" (sem), "[tmp]" (RWSEM_ACTIVE_WRITE_BIAS) \
-		     : "memory", "cc");			\
-	ret;						\
-})
-
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	____down_write(sem, "call_rwsem_down_write_failed");
-}
-
-static inline int __down_write_killable(struct rw_semaphore *sem)
-{
-	if (IS_ERR(____down_write(sem, "call_rwsem_down_write_failed_killable")))
-		return -EINTR;
-
-	return 0;
-}
-
-/*
- * trylock for writing -- returns 1 if successful, 0 if contention
- */
-static inline bool __down_write_trylock(struct rw_semaphore *sem)
-{
-	bool result;
-	long tmp0, tmp1;
-	asm volatile("# beginning __down_write_trylock\n\t"
-		     "  mov          %[count],%[tmp0]\n\t"
-		     "1:\n\t"
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t"
-		     /* was the active mask 0 before? */
-		     "  jnz          2f\n\t"
-		     "  mov          %[tmp0],%[tmp1]\n\t"
-		     "  add          %[inc],%[tmp1]\n\t"
-		     LOCK_PREFIX "  cmpxchg  %[tmp1],%[count]\n\t"
-		     "  jnz	     1b\n\t"
-		     "2:\n\t"
-		     CC_SET(e)
-		     "# ending __down_write_trylock\n\t"
-		     : [count] "+m" (sem->count), [tmp0] "=&a" (tmp0),
-		       [tmp1] "=&r" (tmp1), CC_OUT(e) (result)
-		     : [inc] "er" (RWSEM_ACTIVE_WRITE_BIAS)
-		     : "memory");
-	return result;
-}
-
-/*
- * unlock after reading
- */
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	long tmp;
-	asm volatile("# beginning __up_read\n\t"
-		     LOCK_PREFIX "  xadd      %[tmp],(%[sem])\n\t"
-		     /* subtracts 1, returns the old value */
-		     "  jns        1f\n\t"
-		     "  call call_rwsem_wake\n" /* expects old value in %edx */
-		     "1:\n"
-		     "# ending __up_read\n"
-		     : "+m" (sem->count), [tmp] "=d" (tmp)
-		     : [sem] "a" (sem), "[tmp]" (-RWSEM_ACTIVE_READ_BIAS)
-		     : "memory", "cc");
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	long tmp;
-	asm volatile("# beginning __up_write\n\t"
-		     LOCK_PREFIX "  xadd      %[tmp],(%[sem])\n\t"
-		     /* subtracts 0xffff0001, returns the old value */
-		     "  jns        1f\n\t"
-		     "  call call_rwsem_wake\n" /* expects old value in %edx */
-		     "1:\n\t"
-		     "# ending __up_write\n"
-		     : "+m" (sem->count), [tmp] "=d" (tmp)
-		     : [sem] "a" (sem), "[tmp]" (-RWSEM_ACTIVE_WRITE_BIAS)
-		     : "memory", "cc");
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	asm volatile("# beginning __downgrade_write\n\t"
-		     LOCK_PREFIX _ASM_ADD "%[inc],(%[sem])\n\t"
-		     /*
-		      * transitions 0xZZZZ0001 -> 0xYYYY0001 (i386)
-		      *     0xZZZZZZZZ00000001 -> 0xYYYYYYYY00000001 (x86_64)
-		      */
-		     "  jns       1f\n\t"
-		     "  call call_rwsem_downgrade_wake\n"
-		     "1:\n\t"
-		     "# ending __downgrade_write\n"
-		     : "+m" (sem->count)
-		     : [sem] "a" (sem), [inc] "er" (-RWSEM_WAITING_BIAS)
-		     : "memory", "cc");
-}
-
-#endif /* __KERNEL__ */
-#endif /* _ASM_X86_RWSEM_H */
diff --git a/arch/x86/lib/Makefile b/arch/x86/lib/Makefile
index 34a7413..b4e8c8e 100644
--- a/arch/x86/lib/Makefile
+++ b/arch/x86/lib/Makefile
@@ -22,7 +22,6 @@ obj-$(CONFIG_SMP) += msr-smp.o cache-smp.o
 lib-y := delay.o misc.o cmdline.o cpu.o
 lib-y += usercopy_$(BITS).o usercopy.o getuser.o putuser.o
 lib-y += memcpy_$(BITS).o
-lib-$(CONFIG_RWSEM_XCHGADD_ALGORITHM) += rwsem.o
 lib-$(CONFIG_INSTRUCTION_DECODER) += insn.o inat.o
 lib-$(CONFIG_RANDOMIZE_BASE) += kaslr.o
 
diff --git a/arch/x86/lib/rwsem.S b/arch/x86/lib/rwsem.S
deleted file mode 100644
index dc2ab6e..0000000
--- a/arch/x86/lib/rwsem.S
+++ /dev/null
@@ -1,156 +0,0 @@
-/*
- * x86 semaphore implementation.
- *
- * (C) Copyright 1999 Linus Torvalds
- *
- * Portions Copyright 1999 Red Hat, Inc.
- *
- *	This program is free software; you can redistribute it and/or
- *	modify it under the terms of the GNU General Public License
- *	as published by the Free Software Foundation; either version
- *	2 of the License, or (at your option) any later version.
- *
- * rw semaphores implemented November 1999 by Benjamin LaHaise <bcrl@kvack.org>
- */
-
-#include <linux/linkage.h>
-#include <asm/alternative-asm.h>
-#include <asm/frame.h>
-
-#define __ASM_HALF_REG(reg)	__ASM_SEL(reg, e##reg)
-#define __ASM_HALF_SIZE(inst)	__ASM_SEL(inst##w, inst##l)
-
-#ifdef CONFIG_X86_32
-
-/*
- * The semaphore operations have a special calling sequence that
- * allow us to do a simpler in-line version of them. These routines
- * need to convert that sequence back into the C sequence when
- * there is contention on the semaphore.
- *
- * %eax contains the semaphore pointer on entry. Save the C-clobbered
- * registers (%eax, %edx and %ecx) except %eax which is either a return
- * value or just gets clobbered. Same is true for %edx so make sure GCC
- * reloads it after the slow path, by making it hold a temporary, for
- * example see ____down_write().
- */
-
-#define save_common_regs \
-	pushl %ecx
-
-#define restore_common_regs \
-	popl %ecx
-
-	/* Avoid uglifying the argument copying x86-64 needs to do. */
-	.macro movq src, dst
-	.endm
-
-#else
-
-/*
- * x86-64 rwsem wrappers
- *
- * This interfaces the inline asm code to the slow-path
- * C routines. We need to save the call-clobbered regs
- * that the asm does not mark as clobbered, and move the
- * argument from %rax to %rdi.
- *
- * NOTE! We don't need to save %rax, because the functions
- * will always return the semaphore pointer in %rax (which
- * is also the input argument to these helpers)
- *
- * The following can clobber %rdx because the asm clobbers it:
- *   call_rwsem_down_write_failed
- *   call_rwsem_wake
- * but %rdi, %rsi, %rcx, %r8-r11 always need saving.
- */
-
-#define save_common_regs \
-	pushq %rdi; \
-	pushq %rsi; \
-	pushq %rcx; \
-	pushq %r8;  \
-	pushq %r9;  \
-	pushq %r10; \
-	pushq %r11
-
-#define restore_common_regs \
-	popq %r11; \
-	popq %r10; \
-	popq %r9; \
-	popq %r8; \
-	popq %rcx; \
-	popq %rsi; \
-	popq %rdi
-
-#endif
-
-/* Fix up special calling conventions */
-ENTRY(call_rwsem_down_read_failed)
-	FRAME_BEGIN
-	save_common_regs
-	__ASM_SIZE(push,) %__ASM_REG(dx)
-	movq %rax,%rdi
-	call rwsem_down_read_failed
-	__ASM_SIZE(pop,) %__ASM_REG(dx)
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_read_failed)
-
-ENTRY(call_rwsem_down_read_failed_killable)
-	FRAME_BEGIN
-	save_common_regs
-	__ASM_SIZE(push,) %__ASM_REG(dx)
-	movq %rax,%rdi
-	call rwsem_down_read_failed_killable
-	__ASM_SIZE(pop,) %__ASM_REG(dx)
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_read_failed_killable)
-
-ENTRY(call_rwsem_down_write_failed)
-	FRAME_BEGIN
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_down_write_failed
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_write_failed)
-
-ENTRY(call_rwsem_down_write_failed_killable)
-	FRAME_BEGIN
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_down_write_failed_killable
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_down_write_failed_killable)
-
-ENTRY(call_rwsem_wake)
-	FRAME_BEGIN
-	/* do nothing if still outstanding active readers */
-	__ASM_HALF_SIZE(dec) %__ASM_HALF_REG(dx)
-	jnz 1f
-	save_common_regs
-	movq %rax,%rdi
-	call rwsem_wake
-	restore_common_regs
-1:	FRAME_END
-	ret
-ENDPROC(call_rwsem_wake)
-
-ENTRY(call_rwsem_downgrade_wake)
-	FRAME_BEGIN
-	save_common_regs
-	__ASM_SIZE(push,) %__ASM_REG(dx)
-	movq %rax,%rdi
-	call rwsem_downgrade_wake
-	__ASM_SIZE(pop,) %__ASM_REG(dx)
-	restore_common_regs
-	FRAME_END
-	ret
-ENDPROC(call_rwsem_downgrade_wake)
diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index dff7cc3..199523e 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -21,7 +21,6 @@ generic-y += mm-arch-hooks.h
 generic-y += param.h
 generic-y += percpu.h
 generic-y += preempt.h
-generic-y += rwsem.h
 generic-y += sections.h
 generic-y += topology.h
 generic-y += trace_clock.h
-- 
1.8.3.1

