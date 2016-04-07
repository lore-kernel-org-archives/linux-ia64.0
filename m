From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Apr 2016 15:12:31 +0000
Subject: [PATCH 11/11] locking, rwsem: provide down_write_killable
Message-Id: <1460041951-22347-12-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Now that all the architectures implement the necessary glue code
we can introduce down_write_killable. The only difference wrt. regular
down_write is that the slow path waits in TASK_KILLABLE state and the
interruption by the fatal signal is reported as -EINTR to the caller.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/lockdep.h | 15 +++++++++++++++
 include/linux/rwsem.h   |  1 +
 kernel/locking/rwsem.c  | 19 +++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 4dca42fd32f5..13a80779b6da 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -446,6 +446,18 @@ do {								\
 	lock_acquired(&(_lock)->dep_map, _RET_IP_);			\
 } while (0)
 
+#define LOCK_CONTENDED_RETURN(_lock, try, lock)			\
+({								\
+	int ____err = 0;					\
+	if (!try(_lock)) {					\
+		lock_contended(&(_lock)->dep_map, _RET_IP_);	\
+		____err = lock(_lock);				\
+	}							\
+	if (!____err)						\
+		lock_acquired(&(_lock)->dep_map, _RET_IP_);	\
+	____err;						\
+})
+
 #else /* CONFIG_LOCK_STAT */
 
 #define lock_contended(lockdep_map, ip) do {} while (0)
@@ -454,6 +466,9 @@ do {								\
 #define LOCK_CONTENDED(_lock, try, lock) \
 	lock(_lock)
 
+#define LOCK_CONTENDED_RETURN(_lock, try, lock) \
+	lock(_lock)
+
 #endif /* CONFIG_LOCK_STAT */
 
 #ifdef CONFIG_LOCKDEP
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 7d7ae029dac5..d1c12d160ace 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -118,6 +118,7 @@ extern int down_read_trylock(struct rw_semaphore *sem);
  * lock for writing
  */
 extern void down_write(struct rw_semaphore *sem);
+extern int __must_check down_write_killable(struct rw_semaphore *sem);
 
 /*
  * trylock for writing -- returns 1 if successful, 0 if contention
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index 205be0ce34de..c817216c1615 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -55,6 +55,25 @@ void __sched down_write(struct rw_semaphore *sem)
 EXPORT_SYMBOL(down_write);
 
 /*
+ * lock for writing
+ */
+int __sched down_write_killable(struct rw_semaphore *sem)
+{
+	might_sleep();
+	rwsem_acquire(&sem->dep_map, 0, 0, _RET_IP_);
+
+	if (LOCK_CONTENDED_RETURN(sem, __down_write_trylock, __down_write_killable)) {
+		rwsem_release(&sem->dep_map, 1, _RET_IP_);
+		return -EINTR;
+	}
+
+	rwsem_set_owner(sem);
+	return 0;
+}
+
+EXPORT_SYMBOL(down_write_killable);
+
+/*
  * trylock for writing -- returns 1 if successful, 0 if contention
  */
 int down_write_trylock(struct rw_semaphore *sem)
-- 
2.8.0.rc3

