From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 30 Jun 2017 00:01:23 +0000
Subject: [PATCH RFC 15/26] ia64: Remove spin_unlock_wait() arch-specific definitions
Message-Id: <1498780894-8253-15-git-send-email-paulmck@linux.vnet.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170629235918.GA6445@linux.vnet.ibm.com>
In-Reply-To: <20170629235918.GA6445@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org, oleg@redhat.com, akpm@linux-foundation.org, mingo@redhat.com, dave@stgolabs.net, manfred@colorfullife.com, tj@kernel.org, arnd@arndb.de, linux-arch@vger.kernel.org, will.deacon@arm.com, peterz@infradead.org, stern@rowland.harvard.edu, parri.andrea@gmail.com, torvalds@linux-foundation.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

There is no agreed-upon definition of spin_unlock_wait()'s semantics,
and it appears that all callers could do just as well with a lock/unlock
pair.  This commit therefore removes the underlying arch-specific
arch_spin_unlock_wait().

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: <linux-ia64@vger.kernel.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrea Parri <parri.andrea@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 arch/ia64/include/asm/spinlock.h | 21 ---------------------
 1 file changed, 21 deletions(-)

diff --git a/arch/ia64/include/asm/spinlock.h b/arch/ia64/include/asm/spinlock.h
index ca9e76149a4a..df2c121164b8 100644
--- a/arch/ia64/include/asm/spinlock.h
+++ b/arch/ia64/include/asm/spinlock.h
@@ -76,22 +76,6 @@ static __always_inline void __ticket_spin_unlock(arch_spinlock_t *lock)
 	ACCESS_ONCE(*p) = (tmp + 2) & ~1;
 }
 
-static __always_inline void __ticket_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	int	*p = (int *)&lock->lock, ticket;
-
-	ia64_invala();
-
-	for (;;) {
-		asm volatile ("ld4.c.nc %0=[%1]" : "=r"(ticket) : "r"(p) : "memory");
-		if (!(((ticket >> TICKET_SHIFT) ^ ticket) & TICKET_MASK))
-			return;
-		cpu_relax();
-	}
-
-	smp_acquire__after_ctrl_dep();
-}
-
 static inline int __ticket_spin_is_locked(arch_spinlock_t *lock)
 {
 	long tmp = ACCESS_ONCE(lock->lock);
@@ -143,11 +127,6 @@ static __always_inline void arch_spin_lock_flags(arch_spinlock_t *lock,
 	arch_spin_lock(lock);
 }
 
-static inline void arch_spin_unlock_wait(arch_spinlock_t *lock)
-{
-	__ticket_spin_unlock_wait(lock);
-}
-
 #define arch_read_can_lock(rw)		(*(volatile int *)(rw) >= 0)
 #define arch_write_can_lock(rw)	(*(volatile int *)(rw) = 0)
 
-- 
2.5.2

