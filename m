From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Fri, 29 Sep 2017 16:05:56 +0000
Subject: [PATCH REBASED 1/6] alpha: Add __down_read_killable()
Message-Id: <150670115677.23930.5711263025537758463.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
In-Reply-To: <150670038738.23930.7190484711222807884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net, rientjes@google.com, viro@zeniv.linux.org.uk

Similar to __down_write_killable(), and read killable primitive.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 arch/alpha/include/asm/rwsem.h |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/asm/rwsem.h b/arch/alpha/include/asm/rwsem.h
index 77873d0ad293..7118bd090085 100644
--- a/arch/alpha/include/asm/rwsem.h
+++ b/arch/alpha/include/asm/rwsem.h
@@ -21,7 +21,7 @@
 #define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
 #define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
-static inline void __down_read(struct rw_semaphore *sem)
+static inline int ___down_read(struct rw_semaphore *sem)
 {
 	long oldcount;
 #ifndef	CONFIG_SMP
@@ -41,10 +41,24 @@ static inline void __down_read(struct rw_semaphore *sem)
 	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
 	:"Ir" (RWSEM_ACTIVE_READ_BIAS), "m" (sem->count) : "memory");
 #endif
-	if (unlikely(oldcount < 0))
+	return (oldcount < 0);
+}
+
+static inline void __down_read(struct rw_semaphore *sem)
+{
+	if (unlikely(___down_read(sem)))
 		rwsem_down_read_failed(sem);
 }
 
+static inline int __down_read_killable(struct rw_semaphore *sem)
+{
+	if (unlikely(___down_read(sem)))
+		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
+			return -EINTR;
+
+	return 0;
+}
+
 /*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */

