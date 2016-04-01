From: Michal Hocko <mhocko@kernel.org>
Date: Fri, 01 Apr 2016 11:04:49 +0000
Subject: [PATCH 05/11] ia64, rwsem: provide __down_write_killable
Message-Id: <1459508695-14915-6-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459508695-14915-1-git-send-email-mhocko@kernel.org>
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
 arch/ia64/include/asm/rwsem.h | 22 +++++++++++++++++++---
 1 file changed, 19 insertions(+), 3 deletions(-)

diff --git a/arch/ia64/include/asm/rwsem.h b/arch/ia64/include/asm/rwsem.h
index 3027e7516d85..5e78cb40d9df 100644
--- a/arch/ia64/include/asm/rwsem.h
+++ b/arch/ia64/include/asm/rwsem.h
@@ -49,8 +49,8 @@ __down_read (struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-static inline void
-__down_write (struct rw_semaphore *sem)
+static inline long
+___down_write (struct rw_semaphore *sem)
 {
 	long old, new;
 
@@ -59,10 +59,26 @@ __down_write (struct rw_semaphore *sem)
 		new = old + RWSEM_ACTIVE_WRITE_BIAS;
 	} while (cmpxchg_acq(&sem->count, old, new) != old);
 
-	if (old != 0)
+	return old;
+}
+
+static inline void
+__down_write (struct rw_semaphore *sem)
+{
+	if (___down_write(sem))
 		rwsem_down_write_failed(sem);
 }
 
+static inline int
+__down_write_killable (struct rw_semaphore *sem)
+{
+	if (___down_write(sem))
+		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
+			return -EINTR;
+
+	return 0;
+}
+
 /*
  * unlock after reading
  */
-- 
2.8.0.rc3

