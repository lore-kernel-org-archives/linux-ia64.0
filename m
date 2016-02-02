From: Michal Hocko <mhocko@kernel.org>
Date: Tue, 02 Feb 2016 20:19:28 +0000
Subject: [RFC 11/12] x86, rwsem: provide __down_write_killable
Message-Id: <1454444369-2146-12-git-send-email-mhocko@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

which is uses the same fast path as __down_write except it falls back to
rwsem_down_write_failed_killable slow path and return -EINTR if killed.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/include/asm/rwsem.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index 1b5e89b3643d..64899daa51e2 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -109,6 +109,19 @@ static inline void __down_write(struct rw_semaphore *sem)
 		rwsem_down_write_failed(sem);
 }
 
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	long tmp;
+
+	tmp = atomic_long_add_return(RWSEM_ACTIVE_WRITE_BIAS,
+				     (atomic_long_t *)&sem->count);
+	if (unlikely(tmp != RWSEM_ACTIVE_WRITE_BIAS))
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

