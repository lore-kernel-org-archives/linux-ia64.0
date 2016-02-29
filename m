From: Michal Hocko <mhocko@kernel.org>
Date: Mon, 29 Feb 2016 12:58:24 +0000
Subject: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <1456750705-7141-11-git-send-email-mhocko@kernel.org>
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
call_rwsem_down_write_failed_killable slow path and return -EINTR if
killed. To prevent from code duplication extract the skeleton of
__down_write into a helper macro which just takes the semaphore
and the slow path function to be called.

Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/include/asm/rwsem.h | 41 ++++++++++++++++++++++++++++-------------
 arch/x86/lib/rwsem.S         |  8 ++++++++
 2 files changed, 36 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index 4a8292a0d6e1..d759c5f70f49 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -99,21 +99,36 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
+#define ____down_write(sem, slow_path)			\
+({							\
+	long tmp;					\
+	struct rw_semaphore* ret = sem;			\
+	asm volatile("# beginning down_write\n\t"	\
+		     LOCK_PREFIX "  xadd      %1,(%2)\n\t"	\
+		     /* adds 0xffff0001, returns the old value */ \
+		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t" \
+		     /* was the active mask 0 before? */\
+		     "  jz        1f\n"			\
+		     "  call " slow_path "\n"		\
+		     "1:\n"				\
+		     "# ending down_write"		\
+		     : "+m" (sem->count), "=d" (tmp), "+a" (ret)	\
+		     : "a" (sem), "1" (RWSEM_ACTIVE_WRITE_BIAS) \
+		     : "memory", "cc");			\
+	ret;						\
+})
+
 static inline void __down_write(struct rw_semaphore *sem)
 {
-	long tmp;
-	asm volatile("# beginning down_write\n\t"
-		     LOCK_PREFIX "  xadd      %1,(%2)\n\t"
-		     /* adds 0xffff0001, returns the old value */
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t"
-		     /* was the active mask 0 before? */
-		     "  jz        1f\n"
-		     "  call call_rwsem_down_write_failed\n"
-		     "1:\n"
-		     "# ending down_write"
-		     : "+m" (sem->count), "=d" (tmp)
-		     : "a" (sem), "1" (RWSEM_ACTIVE_WRITE_BIAS)
-		     : "memory", "cc");
+	____down_write(sem, "call_rwsem_down_write_failed");
+}
+
+static inline int __down_write_killable(struct rw_semaphore *sem)
+{
+	if (IS_ERR(____down_write(sem, "call_rwsem_down_write_failed_killable")))
+		return -EINTR;
+
+	return 0;
 }
 
 /*
diff --git a/arch/x86/lib/rwsem.S b/arch/x86/lib/rwsem.S
index be110efa0096..4534a7e912f3 100644
--- a/arch/x86/lib/rwsem.S
+++ b/arch/x86/lib/rwsem.S
@@ -106,6 +106,14 @@ ENTRY(call_rwsem_down_write_failed)
 	ret
 ENDPROC(call_rwsem_down_write_failed)
 
+ENTRY(call_rwsem_down_write_failed_killable)
+	save_common_regs
+	movq %rax,%rdi
+	call rwsem_down_write_failed_killable
+	restore_common_regs
+	ret
+ENDPROC(call_rwsem_down_write_failed_killable)
+
 ENTRY(call_rwsem_wake)
 	FRAME_BEGIN
 	/* do nothing if still outstanding active readers */
-- 
2.7.0

