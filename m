From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 02 Feb 2016 20:19:18 +0000
Subject: [RFC 01/12] locking, rwsem: get rid of __down_write_nested
Message-Id: <1454444369-2146-2-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

This is no longer used anywhere and all callers (__down_write) use
0 as a subclass. Ditch __down_write_nested to make the code easier
to follow.

This shouldn't introduce any functional change.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/s390/include/asm/rwsem.h   | 7 +------
 arch/sh/include/asm/rwsem.h     | 5 -----
 arch/sparc/include/asm/rwsem.h  | 7 +------
 arch/x86/include/asm/rwsem.h    | 7 +------
 include/asm-generic/rwsem.h     | 7 +------
 include/linux/rwsem-spinlock.h  | 1 -
 kernel/locking/rwsem-spinlock.c | 7 +------
 7 files changed, 5 insertions(+), 36 deletions(-)

diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h
index 4b43ee7e6776..8e52e72f3efc 100644
--- a/arch/s390/include/asm/rwsem.h
+++ b/arch/s390/include/asm/rwsem.h
@@ -90,7 +90,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
+static inline void __down_write(struct rw_semaphore *sem)
 {
 	signed long old, new, tmp;
 
@@ -108,11 +108,6 @@ static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
 		rwsem_down_write_failed(sem);
 }
 
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	__down_write_nested(sem, 0);
-}
-
 /*
  * trylock for writing -- returns 1 if successful, 0 if contention
  */
diff --git a/arch/sh/include/asm/rwsem.h b/arch/sh/include/asm/rwsem.h
index edab57265293..a5104bebd1eb 100644
--- a/arch/sh/include/asm/rwsem.h
+++ b/arch/sh/include/asm/rwsem.h
@@ -114,11 +114,6 @@ static inline void __downgrade_write(struct rw_semaphore *sem)
 		rwsem_downgrade_wake(sem);
 }
 
-static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
-{
-	__down_write(sem);
-}
-
 /*
  * implement exchange and add functionality
  */
diff --git a/arch/sparc/include/asm/rwsem.h b/arch/sparc/include/asm/rwsem.h
index 069bf4d663a1..e5a0d575bc7f 100644
--- a/arch/sparc/include/asm/rwsem.h
+++ b/arch/sparc/include/asm/rwsem.h
@@ -45,7 +45,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
+static inline void __down_write(struct rw_semaphore *sem)
 {
 	long tmp;
 
@@ -55,11 +55,6 @@ static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
 		rwsem_down_write_failed(sem);
 }
 
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	__down_write_nested(sem, 0);
-}
-
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
 	long tmp;
diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index cad82c9c2fde..d79a218675bc 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -99,7 +99,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
+static inline void __down_write(struct rw_semaphore *sem)
 {
 	long tmp;
 	asm volatile("# beginning down_write\n\t"
@@ -116,11 +116,6 @@ static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
 		     : "memory", "cc");
 }
 
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	__down_write_nested(sem, 0);
-}
-
 /*
  * trylock for writing -- returns 1 if successful, 0 if contention
  */
diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index d6d5dc98d7da..b8d8a6cf4ca8 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -53,7 +53,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
+static inline void __down_write(struct rw_semaphore *sem)
 {
 	long tmp;
 
@@ -63,11 +63,6 @@ static inline void __down_write_nested(struct rw_semaphore *sem, int subclass)
 		rwsem_down_write_failed(sem);
 }
 
-static inline void __down_write(struct rw_semaphore *sem)
-{
-	__down_write_nested(sem, 0);
-}
-
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
 	long tmp;
diff --git a/include/linux/rwsem-spinlock.h b/include/linux/rwsem-spinlock.h
index 561e8615528d..a733a5467e6c 100644
--- a/include/linux/rwsem-spinlock.h
+++ b/include/linux/rwsem-spinlock.h
@@ -34,7 +34,6 @@ struct rw_semaphore {
 extern void __down_read(struct rw_semaphore *sem);
 extern int __down_read_trylock(struct rw_semaphore *sem);
 extern void __down_write(struct rw_semaphore *sem);
-extern void __down_write_nested(struct rw_semaphore *sem, int subclass);
 extern int __down_write_trylock(struct rw_semaphore *sem);
 extern void __up_read(struct rw_semaphore *sem);
 extern void __up_write(struct rw_semaphore *sem);
diff --git a/kernel/locking/rwsem-spinlock.c b/kernel/locking/rwsem-spinlock.c
index 3a5048572065..bab26104a5d0 100644
--- a/kernel/locking/rwsem-spinlock.c
+++ b/kernel/locking/rwsem-spinlock.c
@@ -191,7 +191,7 @@ int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * get a write lock on the semaphore
  */
-void __sched __down_write_nested(struct rw_semaphore *sem, int subclass)
+void __sched __down_write(struct rw_semaphore *sem)
 {
 	struct rwsem_waiter waiter;
 	struct task_struct *tsk;
@@ -227,11 +227,6 @@ void __sched __down_write_nested(struct rw_semaphore *sem, int subclass)
 	raw_spin_unlock_irqrestore(&sem->wait_lock, flags);
 }
 
-void __sched __down_write(struct rw_semaphore *sem)
-{
-	__down_write_nested(sem, 0);
-}
-
 /*
  * trylock for writing -- returns 1 if successful, 0 if contention
  */
-- 
2.7.0

