From: Michal Hocko <mhocko@kernel.org>
Date: Wed, 13 Apr 2016 12:49:43 +0000
Subject: Re: [PATCH 10/11] x86, rwsem: provide __down_write_killable
Message-Id: <20160413124943.GH14351@dhcp22.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <1460041951-22347-1-git-send-email-mhocko@kernel.org>
 <1460041951-22347-11-git-send-email-mhocko@kernel.org>
 <20160413090829.GB29579@gmail.com>
 <20160413091625.GF14351@dhcp22.suse.cz>
 <20160413091943.GA17858@gmail.com>
 <20160413102731.GA29896@gmail.com>
In-Reply-To: <20160413102731.GA29896@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On Wed 13-04-16 12:27:31, Ingo Molnar wrote:
> 
> * Ingo Molnar <mingo@kernel.org> wrote:
> 
> > I'm testing your patches today, if they are otherwise OK [...]
> 
> got this build failure:
> 
>   ./arch/x86/include/asm/rwsem.h:106:2: error: ‘asm’ operand has impossible constraints

Hmm, I have no idea why 64b didn't have problem with the asm but 32b
complains. Anyway, the following makes both happy. I have checked the
generated code for 64b and it hasn't changed after the patch. 32b also
seems to be generating a proper code. My gcc asm()-foo is rather weak so
I would feel better if somebody double checked after me.
---
From d23f4e6994670bf2c5d864f2190f21022b4499b2 Mon Sep 17 00:00:00 2001
From: Michal Hocko <mhocko@suse.com>
Date: Wed, 13 Apr 2016 14:21:25 +0200
Subject: [PATCH] x86: __down_read_trylock fix 32b build failure
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Ingo has noticed the following compilation error with CONFIG_X86_32=y
./arch/x86/include/asm/rwsem.h:106:2: error: ‘asm’ operand has impossible constraints

The reason seems to be that 32b doesn't like ret being input and output
argument sharing the same register with sem which is only the input. Fix
this by making ret output only and use %3 (aka sem) for xadd.

ret initialization is not needed now because this is done implicitly
by the asm even for the fast path as both sem and ret share the same
register.

Reported-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 arch/x86/include/asm/rwsem.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index d759c5f70f49..453744c1d347 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -102,9 +102,9 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 #define ____down_write(sem, slow_path)			\
 ({							\
 	long tmp;					\
-	struct rw_semaphore* ret = sem;			\
+	struct rw_semaphore* ret;			\
 	asm volatile("# beginning down_write\n\t"	\
-		     LOCK_PREFIX "  xadd      %1,(%2)\n\t"	\
+		     LOCK_PREFIX "  xadd      %1,(%3)\n\t"	\
 		     /* adds 0xffff0001, returns the old value */ \
 		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t" \
 		     /* was the active mask 0 before? */\
@@ -112,7 +112,7 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 		     "  call " slow_path "\n"		\
 		     "1:\n"				\
 		     "# ending down_write"		\
-		     : "+m" (sem->count), "=d" (tmp), "+a" (ret)	\
+		     : "+m" (sem->count), "=d" (tmp), "=a" (ret)	\
 		     : "a" (sem), "1" (RWSEM_ACTIVE_WRITE_BIAS) \
 		     : "memory", "cc");			\
 	ret;						\
-- 
2.8.0.rc3

-- 
Michal Hocko
SUSE Labs
