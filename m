From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 02 Feb 2016 20:19:21 +0000
Subject: [RFC 04/12] alpha, rwsem: provide __down_write_killable
Message-Id: <1454444369-2146-5-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

Introduce ___down_write for the fast path and reuse it for __down_write
resp. __down_write_killable each using the respective generic slow path
(rwsem_down_write_failed resp. rwsem_down_write_failed_killable).

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/include/asm/rwsem.h | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/arch/alpha/include/asm/rwsem.h b/arch/alpha/include/asm/rwsem.h
index a83bbea62c67..0131a7058778 100644
--- a/arch/alpha/include/asm/rwsem.h
+++ b/arch/alpha/include/asm/rwsem.h
@@ -63,7 +63,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 	return res >= 0 ? 1 : 0;
 }
 
-static inline void __down_write(struct rw_semaphore *sem)
+static inline long ___down_write(struct rw_semaphore *sem)
 {
 	long oldcount;
 #ifndef	CONFIG_SMP
@@ -83,10 +83,24 @@ static inline void __down_write(struct rw_semaphore *sem)
 	:"=&r" (oldcount), "=m" (sem->count), "=&r" (temp)
 	:"Ir" (RWSEM_ACTIVE_WRITE_BIAS), "m" (sem->count) : "memory");
 #endif
-	if (unlikely(oldcount))
+	return oldcount;
+}
+
+static inline void __down_write(struct rw_semaphore *sem)
+{
+	if (unlikely(___down_write(sem)))
 		rwsem_down_write_failed(sem);
 }
 
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	if (unlikely(___down_write(sem)))
+		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
+			return -EINTR;
+
+	return 0;
+}
+
 /*
  * trylock for writing -- returns 1 if successful, 0 if contention
  */
-- 
2.7.0

