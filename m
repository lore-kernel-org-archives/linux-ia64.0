From: Michal Hocko <mhocko@kernel.org>
Date: Thu, 07 Apr 2016 15:12:29 +0000
Subject: [PATCH 09/11] s390, rwsem: provide __down_write_killable
Message-Id: <1460041951-22347-10-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
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
 arch/s390/include/asm/rwsem.h | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h
index 8e52e72f3efc..8e7b2b7e10f3 100644
--- a/arch/s390/include/asm/rwsem.h
+++ b/arch/s390/include/asm/rwsem.h
@@ -90,7 +90,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void __down_write(struct rw_semaphore *sem)
+static inline long ___down_write(struct rw_semaphore *sem)
 {
 	signed long old, new, tmp;
 
@@ -104,10 +104,25 @@ static inline void __down_write(struct rw_semaphore *sem)
 		: "=&d" (old), "=&d" (new), "=Q" (sem->count)
 		: "Q" (sem->count), "m" (tmp)
 		: "cc", "memory");
-	if (old != 0)
+
+	return old;
+}
+
+static inline void __down_write(struct rw_semaphore *sem)
+{
+	if (___down_write(sem))
 		rwsem_down_write_failed(sem);
 }
 
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	if (___down_write(sem))
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
2.8.0.rc3

