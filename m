From: Arnd Bergmann <arnd@kernel.org>
Date: Wed, 16 Feb 2022 13:13:19 +0000
Subject: [PATCH v2 05/18] x86: remove __range_not_ok()
Message-Id: <20220216131332.1489939-6-arnd@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220216131332.1489939-1-arnd@kernel.org>
In-Reply-To: <20220216131332.1489939-1-arnd@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, arnd@arndb.de, linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Cc: linux@armlinux.org.uk, will@kernel.org, guoren@kernel.org, bcain@codeaurora.org, geert@linux-m68k.org, monstr@monstr.eu, tsbogend@alpha.franken.de, nickhu@andestech.com, green.hu@gmail.com, dinguyen@kernel.org, shorne@gmail.com, deller@gmx.de, mpe@ellerman.id.au, peterz@infradead.org, mingo@redhat.com, mark.rutland@arm.com, hca@linux.ibm.com, dalias@libc.org, davem@davemloft.net, richard@nod.at, x86@kernel.org, jcmvbkbc@gmail.com, ebiederm@xmission.com, akpm@linux-foundation.org, ardb@kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-csky@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, openrisc@lists.librecores.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-um@lists.infradead.org, linux-xtensa@linux-xtensa.org, Christoph Hellwig <hch@infradead.org>

From: Arnd Bergmann <arnd@arndb.de>

The __range_not_ok() helper is an x86 (and sparc64) specific interface
that does roughly the same thing as __access_ok(), but with different
calling conventions.

Change this to use the normal interface in order for consistency as we
clean up all access_ok() implementations.

This changes the limit from TASK_SIZE to TASK_SIZE_MAX, which Al points
out is the right thing do do here anyway.

The callers have to use __access_ok() instead of the normal access_ok()
though, because on x86 that contains a WARN_ON_IN_IRQ() check that cannot
be used inside of NMI context while tracing.

Suggested-by: Al Viro <viro@zeniv.linux.org.uk>
Suggested-by: Christoph Hellwig <hch@infradead.org>
Link: https://lore.kernel.org/lkml/YgsUKcXGR7r4nINj@zeniv-ca.linux.org.uk/
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 arch/x86/events/core.c         |  2 +-
 arch/x86/include/asm/uaccess.h | 10 ++++++----
 arch/x86/kernel/dumpstack.c    |  2 +-
 arch/x86/kernel/stacktrace.c   |  2 +-
 arch/x86/lib/usercopy.c        |  2 +-
 5 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/arch/x86/events/core.c b/arch/x86/events/core.c
index e686c5e0537b..eef816fc216d 100644
--- a/arch/x86/events/core.c
+++ b/arch/x86/events/core.c
@@ -2794,7 +2794,7 @@ perf_callchain_kernel(struct perf_callchain_entry_ctx *entry, struct pt_regs *re
 static inline int
 valid_user_frame(const void __user *fp, unsigned long size)
 {
-	return (__range_not_ok(fp, size, TASK_SIZE) = 0);
+	return __access_ok(fp, size);
 }
 
 static unsigned long get_segment_base(unsigned int segment)
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index ac96f9b2d64b..79c4869ccdd6 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -16,8 +16,10 @@
  * Test whether a block of memory is a valid user space address.
  * Returns 0 if the range is valid, nonzero otherwise.
  */
-static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, unsigned long limit)
+static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size)
 {
+	unsigned long limit = TASK_SIZE_MAX;
+
 	/*
 	 * If we have used "sizeof()" for the size,
 	 * we know it won't overflow the limit (but
@@ -35,10 +37,10 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 	return unlikely(addr > limit);
 }
 
-#define __range_not_ok(addr, size, limit)				\
+#define __access_ok(addr, size)						\
 ({									\
 	__chk_user_ptr(addr);						\
-	__chk_range_not_ok((unsigned long __force)(addr), size, limit); \
+	!__chk_range_not_ok((unsigned long __force)(addr), size);	\
 })
 
 #ifdef CONFIG_DEBUG_ATOMIC_SLEEP
@@ -69,7 +71,7 @@ static inline bool pagefault_disabled(void);
 #define access_ok(addr, size)					\
 ({									\
 	WARN_ON_IN_IRQ();						\
-	likely(!__range_not_ok(addr, size, TASK_SIZE_MAX));		\
+	likely(__access_ok(addr, size));				\
 })
 
 extern int __get_user_1(void);
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index 53de044e5654..da534fb7b5c6 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -85,7 +85,7 @@ static int copy_code(struct pt_regs *regs, u8 *buf, unsigned long src,
 	 * Make sure userspace isn't trying to trick us into dumping kernel
 	 * memory by pointing the userspace instruction pointer at it.
 	 */
-	if (__chk_range_not_ok(src, nbytes, TASK_SIZE_MAX))
+	if (!__access_ok((void __user *)src, nbytes))
 		return -EINVAL;
 
 	/*
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index 15b058eefc4e..ee117fcf46ed 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -90,7 +90,7 @@ copy_stack_frame(const struct stack_frame_user __user *fp,
 {
 	int ret;
 
-	if (__range_not_ok(fp, sizeof(*frame), TASK_SIZE))
+	if (!__access_ok(fp, sizeof(*frame)))
 		return 0;
 
 	ret = 1;
diff --git a/arch/x86/lib/usercopy.c b/arch/x86/lib/usercopy.c
index c3e8a62ca561..ad0139d25401 100644
--- a/arch/x86/lib/usercopy.c
+++ b/arch/x86/lib/usercopy.c
@@ -32,7 +32,7 @@ copy_from_user_nmi(void *to, const void __user *from, unsigned long n)
 {
 	unsigned long ret;
 
-	if (__range_not_ok(from, n, TASK_SIZE))
+	if (!__access_ok(from, n))
 		return n;
 
 	if (!nmi_uaccess_okay())
-- 
2.29.2
