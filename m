From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 17 Feb 2016 16:41:56 +0000
Subject: [RFC 11/12 v1] x86, rwsem: provide __down_write_killable
Message-Id: <20160217164156.GU29196@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1454444369-2146-1-git-send-email-mhocko@kernel.org>
 <1454444369-2146-12-git-send-email-mhocko@kernel.org>
In-Reply-To: <1454444369-2146-12-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: LKML <linux-kernel@vger.kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org

OK, so I have dropped patch 10 and reworked the x86 part to use the same
asm as __down_write uses. Does this look any better?

I am not an expert in inline asm so the way I am doing it might be not
optimal but at least the gerenated code looks sane (no changes for the
regular __down_write).
---
From d9a24cd6d6eb48602b11df56ecc3ea4e223ac18d Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Mon, 1 Feb 2016 18:21:51 +0100
Subject: [PATCH] x86, rwsem: provide __down_write_killable

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
index d79a218675bc..4c3d90dbe89a 100644
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
index 40027db99140..d1a1397e1fb3 100644
--- a/arch/x86/lib/rwsem.S
+++ b/arch/x86/lib/rwsem.S
@@ -101,6 +101,14 @@ ENTRY(call_rwsem_down_write_failed)
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
 	/* do nothing if still outstanding active readers */
 	__ASM_HALF_SIZE(dec) %__ASM_HALF_REG(dx)
-- 
2.7.0

-- 
Michal Hocko
SUSE Labs
