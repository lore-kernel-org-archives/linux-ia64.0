From: Borislav Petkov <bp@alien8.de>
Date: Wed, 27 Apr 2016 12:02:17 +0000
Subject: [PATCH] x86/locking/rwsem: Cleanup ____down_write()
Message-Id: <20160427120217.GE21011@pd.tnic>
List-Id: <linux-ia64.vger.kernel.org>
References: <20160413091625.GF14351@dhcp22.suse.cz>
 <20160413091943.GA17858@gmail.com>
 <20160413102731.GA29896@gmail.com>
 <20160413124943.GH14351@dhcp22.suse.cz>
 <20160420134019.GX3448@twins.programming.kicks-ass.net>
 <91A11395-ACAA-4043-B770-2DF6CBAED54C@zytor.com>
 <20160420204501.GA6815@pd.tnic>
 <5717EF59.1030709@zytor.com>
 <20160420213637.GA4978@pd.tnic>
 <FB0197A2-6A76-43FC-A30E-BE619D3BC67E@zytor.com>
In-Reply-To: <FB0197A2-6A76-43FC-A30E-BE619D3BC67E@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Tony Luck <tony.luck@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-arch@vger.kernel.org, Josh Poimboeuf <jpoimboe@redhat.com>

On Wed, Apr 20, 2016 at 03:29:30PM -0700, H. Peter Anvin wrote:
> Since it is a fixed register we could just mark edx clobbered, but
> with more flexible register constraints it can permit gcc to allocate
> a temp resister for us.

How about the following?

It boots fine in kvm and the asm changes are only trivial gcc comments
differences:

---
From: Borislav Petkov <bp@suse.de>
Date: Wed, 27 Apr 2016 13:47:32 +0200
Subject: [PATCH] x86/locking/rwsem: Cleanup ____down_write()

Move the RWSEM_ACTIVE_WRITE_BIAS out of the inline asm to reduce the
number of arguments. Also, make it an input argument only (why it was an
output operand, I still don't know...).

For better readability, use symbolic names for the arguments and move
the linebreak backspace to 80 cols.

Resulting asm differs only in the temporary gcc variable names and
locations:

  --- before      2016-04-27 13:39:05.320778458 +0200
  +++ after       2016-04-27 13:52:37.336778994 +0200
  @@ -11,8 +11,8 @@ down_write_killable:
   .LBB84:
   .LBB85:
   .LBB86:
  -        .loc 2 128 0
  -        movabsq $-4294967295, %rdx      #, tmp
  +        .loc 2 130 0
  +        movabsq $-4294967295, %rdx      #, tmp94
           movq    %rdi, %rax      # sem, sem
   .LBE86:
   .LBE85:
  @@ -23,17 +23,17 @@ down_write_killable:
   .LBB89:
   .LBB88:
   .LBB87:
  -        .loc 2 128 0
  +        .loc 2 130 0
   #APP
  -# 128 "./arch/x86/include/asm/rwsem.h" 1
  +# 130 "./arch/x86/include/asm/rwsem.h" 1
           # beginning down_write
           .pushsection .smp_locks,"a"
   .balign 4
   .long 671f - .
   .popsection
   671:
  -        lock;   xadd      %rdx,(%rax)   # tmp, sem
  -          test  %edx , %edx     # tmp
  +        lock;   xadd      %rdx,(%rax)   # tmp94, sem
  +          test  %edx , %edx     # tmp94
             jz        1f
     call call_rwsem_down_write_failed_killable
   1:

Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/include/asm/rwsem.h | 36 +++++++++++++++++++-----------------
 1 file changed, 19 insertions(+), 17 deletions(-)

diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index 453744c1d347..d2f8d10a6d97 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -99,23 +99,25 @@ static inline int __down_read_trylock(struct rw_semaphore *sem)
 /*
  * lock for writing
  */
-#define ____down_write(sem, slow_path)			\
-({							\
-	long tmp;					\
-	struct rw_semaphore* ret;			\
-	asm volatile("# beginning down_write\n\t"	\
-		     LOCK_PREFIX "  xadd      %1,(%3)\n\t"	\
-		     /* adds 0xffff0001, returns the old value */ \
-		     "  test " __ASM_SEL(%w1,%k1) "," __ASM_SEL(%w1,%k1) "\n\t" \
-		     /* was the active mask 0 before? */\
-		     "  jz        1f\n"			\
-		     "  call " slow_path "\n"		\
-		     "1:\n"				\
-		     "# ending down_write"		\
-		     : "+m" (sem->count), "=d" (tmp), "=a" (ret)	\
-		     : "a" (sem), "1" (RWSEM_ACTIVE_WRITE_BIAS) \
-		     : "memory", "cc");			\
-	ret;						\
+#define ____down_write(sem, slow_path)						\
+({										\
+	long tmp = RWSEM_ACTIVE_WRITE_BIAS;					\
+	struct rw_semaphore* ret;						\
+										\
+	asm volatile("# beginning down_write\n\t"				\
+		     LOCK_PREFIX "  xadd      %[tmp],(%[sem])\n\t"		\
+		     /* adds 0xffff0001, returns the old value */		\
+		     "  test " __ASM_SEL(%w[tmp],%k[tmp]) ","			\
+			       __ASM_SEL(%w[tmp],%k[tmp]) "\n\t"		\
+		     /* was the active mask 0 before? */			\
+		     "  jz        1f\n"						\
+		     "  call " slow_path "\n"					\
+		     "1:\n"							\
+		     "# ending down_write"					\
+		     : "+m" (sem->count), "=a" (ret)				\
+		     : [sem] "a" (sem), [tmp] "r" (tmp)				\
+		     : "memory", "cc");						\
+	ret;									\
 })
 
 static inline void __down_write(struct rw_semaphore *sem)
-- 
2.7.3


-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
