From: Kirill Tkhai <ktkhai@virtuozzo.com>
Date: Mon, 19 Jun 2017 18:03:03 +0000
Subject: [PATCH 5/7] s390: Add __down_read_killable()
Message-Id: <149789538333.9059.572530926643846106.stgit@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
In-Reply-To: <149789463636.9059.16943955939303454611.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, avagin@virtuozzo.com, peterz@infradead.org, heiko.carstens@de.ibm.com, hpa@zytor.com, gorcunov@virtuozzo.com, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, x86@kernel.org, mingo@redhat.com, mattst88@gmail.com, fenghua.yu@intel.com, arnd@arndb.de, ktkhai@virtuozzo.com, ink@jurassic.park.msu.ru, tglx@linutronix.de, rth@twiddle.net, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, schwidefsky@de.ibm.com, davem@davemloft.net

Similar to __down_write_killable(), and read killable primitive.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 arch/s390/include/asm/rwsem.h |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h
index 597e7e96b59e..6bef7d5fbf1c 100644
--- a/arch/s390/include/asm/rwsem.h
+++ b/arch/s390/include/asm/rwsem.h
@@ -49,7 +49,7 @@
 /*
  * lock for reading
  */
-static inline void __down_read(struct rw_semaphore *sem)
+static inline int ___down_read(struct rw_semaphore *sem)
 {
 	signed long old, new;
 
@@ -62,10 +62,24 @@ static inline void __down_read(struct rw_semaphore *sem)
 		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
 		: "Q" (sem->count), "i" (RWSEM_ACTIVE_READ_BIAS)
 		: "cc", "memory");
-	if (old < 0)
+	return (old < 0);
+}
+
+static inline void __down_read(struct rw_semaphore *sem)
+{
+	if (___down_read(sem))
 		rwsem_down_read_failed(sem);
 }
 
+static inline int __down_read_killable(struct rw_semaphore *sem)
+{
+	if (___down_read(sem))
+		if (IS_ERR(rwsem_down_read_failed_killable(sem)))
+			return -EINTR;
+
+	return 0;
+}
+
 /*
  * trylock for reading -- returns 1 if successful, 0 if contention
  */

