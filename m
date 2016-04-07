From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Apr 2016 15:12:25 +0000
Subject: [PATCH 05/11] sparc, rwsem: drop superfluous arch specific implementation
Message-Id: <1460041951-22347-6-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

sparc basically reuses generic implementation of rwsem so we can
reuse the code rather than duplicate it.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/sparc/include/asm/Kbuild  |   1 +
 arch/sparc/include/asm/rwsem.h | 119 -----------------------------------------
 2 files changed, 1 insertion(+), 119 deletions(-)
 delete mode 100644 arch/sparc/include/asm/rwsem.h

diff --git a/arch/sparc/include/asm/Kbuild b/arch/sparc/include/asm/Kbuild
index e928618838bc..6024c26c0585 100644
--- a/arch/sparc/include/asm/Kbuild
+++ b/arch/sparc/include/asm/Kbuild
@@ -16,6 +16,7 @@ generic-y += mm-arch-hooks.h
 generic-y += module.h
 generic-y += mutex.h
 generic-y += preempt.h
+generic-y += rwsem.h
 generic-y += serial.h
 generic-y += trace_clock.h
 generic-y += types.h
diff --git a/arch/sparc/include/asm/rwsem.h b/arch/sparc/include/asm/rwsem.h
deleted file mode 100644
index e5a0d575bc7f..000000000000
--- a/arch/sparc/include/asm/rwsem.h
+++ /dev/null
@@ -1,119 +0,0 @@
-/*
- * rwsem.h: R/W semaphores implemented using CAS
- *
- * Written by David S. Miller (davem@redhat.com), 2001.
- * Derived from asm-i386/rwsem.h
- */
-#ifndef _SPARC64_RWSEM_H
-#define _SPARC64_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
-#endif
-
-#ifdef __KERNEL__
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_ACTIVE_MASK		0xffffffffL
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	if (unlikely(atomic64_inc_return((atomic64_t *)(&sem->count)) <= 0L))
-		rwsem_down_read_failed(sem);
-}
-
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	while ((tmp = sem->count) >= 0L) {
-		if (tmp = cmpxchg(&sem->count, tmp,
-				   tmp + RWSEM_ACTIVE_READ_BIAS)) {
-			return 1;
-		}
-	}
-	return 0;
-}
-
-/*
- * lock for writing
- */
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic64_add_return(RWSEM_ACTIVE_WRITE_BIAS,
-				  (atomic64_t *)(&sem->count));
-	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
-		rwsem_down_write_failed(sem);
-}
-
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = cmpxchg(&sem->count, RWSEM_UNLOCKED_VALUE,
-		      RWSEM_ACTIVE_WRITE_BIAS);
-	return tmp = RWSEM_UNLOCKED_VALUE;
-}
-
-/*
- * unlock after reading
- */
-static inline void __up_read(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic64_dec_return((atomic64_t *)(&sem->count));
-	if (unlikely(tmp < -1L && (tmp & RWSEM_ACTIVE_MASK) = 0L))
-		rwsem_wake(sem);
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	if (unlikely(atomic64_sub_return(RWSEM_ACTIVE_WRITE_BIAS,
-					 (atomic64_t *)(&sem->count)) < 0L))
-		rwsem_wake(sem);
-}
-
-/*
- * implement atomic add functionality
- */
-static inline void rwsem_atomic_add(long delta, struct rw_semaphore *sem)
-{
-	atomic64_add(delta, (atomic64_t *)(&sem->count));
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	long tmp;
-
-	tmp = atomic64_add_return(-RWSEM_WAITING_BIAS, (atomic64_t *)(&sem->count));
-	if (tmp < 0L)
-		rwsem_downgrade_wake(sem);
-}
-
-/*
- * implement exchange and add functionality
- */
-static inline long rwsem_atomic_update(long delta, struct rw_semaphore *sem)
-{
-	return atomic64_add_return(delta, (atomic64_t *)(&sem->count));
-}
-
-#endif /* __KERNEL__ */
-
-#endif /* _SPARC64_RWSEM_H */
-- 
2.8.0.rc3

