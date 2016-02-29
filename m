From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 29 Feb 2016 12:58:21 +0000
Subject: [PATCH 07/11] sh, rwsem: provide __down_write_killable
Message-Id: <1456750705-7141-8-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1456750705-7141-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

which uses the same fast path as __down_write except it falls back to
rwsem_down_write_failed_killable slow path and return -EINTR if killed.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/sh/include/asm/rwsem.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/sh/include/asm/rwsem.h b/arch/sh/include/asm/rwsem.h
index f6c951c7a875..8a457b83d2a5 100644
--- a/arch/sh/include/asm/rwsem.h
+++ b/arch/sh/include/asm/rwsem.h
@@ -54,6 +54,19 @@ static inline void __down_write(struct rw_semaphore *sem)
 		rwsem_down_write_failed(sem);
 }
 
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	int tmp;
+
+	tmp = atomic_add_return(RWSEM_ACTIVE_WRITE_BIAS,
+				(atomic_t *)(&sem->count));
+	if (tmp != RWSEM_ACTIVE_WRITE_BIAS)
+		if (IS_ERR(rwsem_down_write_failed_killable(sem)))
+			return -EINTR;
+
+	return 0;
+}
+
 static inline int __down_write_trylock(struct rw_semaphore *sem)
 {
 	int tmp;
-- 
2.7.0

