From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 29 Sep 2017 16:06:38 +0000
Subject: [PATCH REBASED 5/6] rwsem: Add down_read_killable()
Message-Id: <150670119884.23930.2585570605960763239.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
In-Reply-To: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

Similar to down_read() and down_write_killable(),
add killable version of down_read(), based on
__down_read_killable() function, added in previous
patches.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/asm-generic/rwsem.h |    8 ++++++++
 include/linux/rwsem.h       |    1 +
 kernel/locking/rwsem.c      |   16 ++++++++++++++++
 3 files changed, 25 insertions(+)

diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index 6c6a2141f271..2f71b913b555 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -37,6 +37,14 @@ static inline void __down_read(struct rw_semaphore *sem)
 		rwsem_down_read_failed(sem);
 }
 
+static inline int __down_read_killable(struct rw_semaphore *sem)
+{
+	if (unlikely(atomic_long_inc_return_acquire(&sem->count) <= 0))
+		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
+			return -EINTR;
+	return 0;
+}
+
 static inline int __down_read_trylock(struct rw_semaphore *sem)
 {
 	long tmp;
diff --git a/include/linux/rwsem.h b/include/linux/rwsem.h
index 0ad7318ff299..6ac8ee5f15dd 100644
--- a/include/linux/rwsem.h
+++ b/include/linux/rwsem.h
@@ -111,6 +111,7 @@ static inline int rwsem_is_contended(struct rw_semaphore *sem)
  * lock for reading
  */
 extern void down_read(struct rw_semaphore *sem);
+extern int __must_check down_read_killable(struct rw_semaphore *sem);
 
 /*
  * trylock for reading -- returns 1 if successful, 0 if contention
diff --git a/kernel/locking/rwsem.c b/kernel/locking/rwsem.c
index 4d48b1c4870d..e53f7746d9fd 100644
--- a/kernel/locking/rwsem.c
+++ b/kernel/locking/rwsem.c
@@ -28,6 +28,22 @@ void __sched down_read(struct rw_semaphore *sem)
 
 EXPORT_SYMBOL(down_read);
 
+int __sched down_read_killable(struct rw_semaphore *sem)
+{
+	might_sleep();
+	rwsem_acquire_read(&sem->dep_map, 0, 0, _RET_IP_);
+
+	if (LOCK_CONTENDED_RETURN(sem, __down_read_trylock, __down_read_killable)) {
+		rwsem_release(&sem->dep_map, 1, _RET_IP_);
+		return -EINTR;
+	}
+
+	rwsem_set_reader_owned(sem);
+	return 0;
+}
+
+EXPORT_SYMBOL(down_read_killable);
+
 /*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */

