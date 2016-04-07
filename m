From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Apr 2016 15:12:23 +0000
Subject: [PATCH 03/11] xtensa, rwsem: drop superfluous arch specific implementation
Message-Id: <1460041951-22347-4-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

since "locking, rwsem: drop explicit memory barriers" the arch specific
code is basically same as the the generic one so we can drop the
superfluous code.

Suggested-by: Davidlohr Bueso <dave@stgolabs.net>
Acked-by: Max Filippov <jcmvbkbc@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/xtensa/include/asm/Kbuild  |   1 +
 arch/xtensa/include/asm/rwsem.h | 121 ----------------------------------------
 2 files changed, 1 insertion(+), 121 deletions(-)
 delete mode 100644 arch/xtensa/include/asm/rwsem.h

diff --git a/arch/xtensa/include/asm/Kbuild b/arch/xtensa/include/asm/Kbuild
index b56855a1382a..28cf4c5d65ef 100644
--- a/arch/xtensa/include/asm/Kbuild
+++ b/arch/xtensa/include/asm/Kbuild
@@ -22,6 +22,7 @@ generic-y += mm-arch-hooks.h
 generic-y += percpu.h
 generic-y += preempt.h
 generic-y += resource.h
+generic-y += rwsem.h
 generic-y += sections.h
 generic-y += siginfo.h
 generic-y += statfs.h
diff --git a/arch/xtensa/include/asm/rwsem.h b/arch/xtensa/include/asm/rwsem.h
deleted file mode 100644
index 593483f6e1ff..000000000000
--- a/arch/xtensa/include/asm/rwsem.h
+++ /dev/null
@@ -1,121 +0,0 @@
-/*
- * include/asm-xtensa/rwsem.h
- *
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Largely copied from include/asm-ppc/rwsem.h
- *
- * Copyright (C) 2001 - 2005 Tensilica Inc.
- */
-
-#ifndef _XTENSA_RWSEM_H
-#define _XTENSA_RWSEM_H
-
-#ifndef _LINUX_RWSEM_H
-#error "Please don't include <asm/rwsem.h> directly, use <linux/rwsem.h> instead."
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000
-#define RWSEM_ACTIVE_BIAS		0x00000001
-#define RWSEM_ACTIVE_MASK		0x0000ffff
-#define RWSEM_WAITING_BIAS		(-0x00010000)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
-
-/*
- * lock for reading
- */
-static inline void __down_read(struct rw_semaphore *sem)
-{
-	if (atomic_add_return(1,(atomic_t *)(&sem->count)) <= 0)
-		rwsem_down_read_failed(sem);
-}
-
-static inline int __down_read_trylock(struct rw_semaphore *sem)
-{
-	int tmp;
-
-	while ((tmp = sem->count) >= 0) {
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
-	int tmp;
-
-	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
-				(atomic_t *)(&sem->count));
-	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
-		rwsem_down_write_failed(sem);
-}
-
-static inline int __down_write_trylock(struct rw_semaphore *sem)
-{
-	int tmp;
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
-	int tmp;
-
-	tmp = atomic_sub_return(1,(atomic_t *)(&sem->count));
-	if (tmp < -1 && (tmp & RWSEM_ACTIVE_MASK) = 0)
-		rwsem_wake(sem);
-}
-
-/*
- * unlock after writing
- */
-static inline void __up_write(struct rw_semaphore *sem)
-{
-	if (atomic_sub_return(RWSEM_ACTIVE_WRITE_BIAS,
-			      (atomic_t *)(&sem->count)) < 0)
-		rwsem_wake(sem);
-}
-
-/*
- * implement atomic add functionality
- */
-static inline void rwsem_atomic_add(int delta, struct rw_semaphore *sem)
-{
-	atomic_add(delta, (atomic_t *)(&sem->count));
-}
-
-/*
- * downgrade write lock to read lock
- */
-static inline void __downgrade_write(struct rw_semaphore *sem)
-{
-	int tmp;
-
-	tmp = atomic_add_return(-RWSEM_WAITING_BIAS, (atomic_t *)(&sem->count));
-	if (tmp < 0)
-		rwsem_downgrade_wake(sem);
-}
-
-/*
- * implement exchange and add functionality
- */
-static inline int rwsem_atomic_update(int delta, struct rw_semaphore *sem)
-{
-	return atomic_add_return(delta, (atomic_t *)(&sem->count));
-}
-
-#endif	/* _XTENSA_RWSEM_H */
-- 
2.8.0.rc3

