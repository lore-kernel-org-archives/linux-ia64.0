From: Waiman Long <Waiman.Long@hpe.com>
Date: Thu, 18 Aug 2016 21:11:08 +0000
Subject: [RFC PATCH-tip v4 06/10] locking/rwsem: Move common rwsem macros to asm-generic/rwsem_types.h
Message-Id: <1471554672-38662-7-git-send-email-Waiman.Long@hpe.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
In-Reply-To: <1471554672-38662-1-git-send-email-Waiman.Long@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, Davidlohr Bueso <dave@stgolabs.net>, Jason Low <jason.low2@hp.com>, Dave Chinner <david@fromorbit.com>, Jonathan Corbet <corbet@lwn.net>, Scott J Norton <scott.norton@hpe.com>, Douglas Hatch <doug.hatch@hpe.com>, Waiman Long <Waiman.Long@hpe.com>

Almost all the macro definitions in the various architecture specific
rwsem.h header files are essentially the same. This patch moves all
of them into a common header asm-generic/rwsem_types.h to eliminate
the duplication.

Suggested-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Signed-off-by: Waiman Long <Waiman.Long@hpe.com>
---
 arch/alpha/include/asm/rwsem.h    |    8 +-------
 arch/ia64/include/asm/rwsem.h     |    7 ++-----
 arch/s390/include/asm/rwsem.h     |    7 +------
 arch/x86/include/asm/rwsem.h      |   19 +------------------
 include/asm-generic/rwsem.h       |   16 +---------------
 include/asm-generic/rwsem_types.h |   26 ++++++++++++++++++++++++++
 6 files changed, 32 insertions(+), 51 deletions(-)
 create mode 100644 include/asm-generic/rwsem_types.h

diff --git a/arch/alpha/include/asm/rwsem.h b/arch/alpha/include/asm/rwsem.h
index 77873d0..f99e39a 100644
--- a/arch/alpha/include/asm/rwsem.h
+++ b/arch/alpha/include/asm/rwsem.h
@@ -13,13 +13,7 @@
 #ifdef __KERNEL__
 
 #include <linux/compiler.h>
-
-#define RWSEM_UNLOCKED_VALUE		0x0000000000000000L
-#define RWSEM_ACTIVE_BIAS		0x0000000000000001L
-#define RWSEM_ACTIVE_MASK		0x00000000ffffffffL
-#define RWSEM_WAITING_BIAS		(-0x0000000100000000L)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+#include <asm-generic/rwsem_types.h>
 
 static inline void __down_read(struct rw_semaphore *sem)
 {
diff --git a/arch/ia64/include/asm/rwsem.h b/arch/ia64/include/asm/rwsem.h
index 8fa98dd..21a9066 100644
--- a/arch/ia64/include/asm/rwsem.h
+++ b/arch/ia64/include/asm/rwsem.h
@@ -26,13 +26,10 @@
 #endif
 
 #include <asm/intrinsics.h>
+#include <asm-generic/rwsem_types.h>
 
+#undef  RWSEM_UNLOCKED_VALUE
 #define RWSEM_UNLOCKED_VALUE		__IA64_UL_CONST(0x0000000000000000)
-#define RWSEM_ACTIVE_BIAS		(1L)
-#define RWSEM_ACTIVE_MASK		(0xffffffffL)
-#define RWSEM_WAITING_BIAS		(-0x100000000L)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
 
 /*
  * lock for reading
diff --git a/arch/s390/include/asm/rwsem.h b/arch/s390/include/asm/rwsem.h
index 597e7e9..13dedc8 100644
--- a/arch/s390/include/asm/rwsem.h
+++ b/arch/s390/include/asm/rwsem.h
@@ -39,12 +39,7 @@
 #error "please don't include asm/rwsem.h directly, use linux/rwsem.h instead"
 #endif
 
-#define RWSEM_UNLOCKED_VALUE	0x0000000000000000L
-#define RWSEM_ACTIVE_BIAS	0x0000000000000001L
-#define RWSEM_ACTIVE_MASK	0x00000000ffffffffL
-#define RWSEM_WAITING_BIAS	(-0x0000000100000000L)
-#define RWSEM_ACTIVE_READ_BIAS	RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS	(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+#include <asm-generic/rwsem_types.h>
 
 /*
  * lock for reading
diff --git a/arch/x86/include/asm/rwsem.h b/arch/x86/include/asm/rwsem.h
index 8dbc762..da84726 100644
--- a/arch/x86/include/asm/rwsem.h
+++ b/arch/x86/include/asm/rwsem.h
@@ -38,24 +38,7 @@
 
 #ifdef __KERNEL__
 #include <asm/asm.h>
-
-/*
- * The bias values and the counter type limits the number of
- * potential readers/writers to 32767 for 32 bits and 2147483647
- * for 64 bits.
- */
-
-#ifdef CONFIG_X86_64
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+#include <asm-generic/rwsem_types.h>
 
 /*
  * lock for reading
diff --git a/include/asm-generic/rwsem.h b/include/asm-generic/rwsem.h
index 5be122e..3cb8d98 100644
--- a/include/asm-generic/rwsem.h
+++ b/include/asm-generic/rwsem.h
@@ -12,21 +12,7 @@
  * Adapted largely from include/asm-i386/rwsem.h
  * by Paul Mackerras <paulus@samba.org>.
  */
-
-/*
- * the semaphore definition
- */
-#ifdef CONFIG_64BIT
-# define RWSEM_ACTIVE_MASK		0xffffffffL
-#else
-# define RWSEM_ACTIVE_MASK		0x0000ffffL
-#endif
-
-#define RWSEM_UNLOCKED_VALUE		0x00000000L
-#define RWSEM_ACTIVE_BIAS		0x00000001L
-#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
-#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
-#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+#include <asm-generic/rwsem_types.h>
 
 /*
  * lock for reading
diff --git a/include/asm-generic/rwsem_types.h b/include/asm-generic/rwsem_types.h
new file mode 100644
index 0000000..093ef6a
--- /dev/null
+++ b/include/asm-generic/rwsem_types.h
@@ -0,0 +1,26 @@
+#ifndef _ASM_GENERIC_RWSEM_TYPES_H
+#define _ASM_GENERIC_RWSEM_TYPES_H
+
+#ifdef __KERNEL__
+
+/*
+ * the semaphore definition
+ *
+ * The bias values and the counter type limits the number of
+ * potential readers/writers to 32767 for 32 bits and 2147483647
+ * for 64 bits.
+ */
+#ifdef CONFIG_64BIT
+# define RWSEM_ACTIVE_MASK		0xffffffffL
+#else
+# define RWSEM_ACTIVE_MASK		0x0000ffffL
+#endif
+
+#define RWSEM_UNLOCKED_VALUE		0x00000000L
+#define RWSEM_ACTIVE_BIAS		0x00000001L
+#define RWSEM_WAITING_BIAS		(-RWSEM_ACTIVE_MASK-1)
+#define RWSEM_ACTIVE_READ_BIAS		RWSEM_ACTIVE_BIAS
+#define RWSEM_ACTIVE_WRITE_BIAS		(RWSEM_WAITING_BIAS + RWSEM_ACTIVE_BIAS)
+
+#endif	/* __KERNEL__ */
+#endif	/* _ASM_GENERIC_RWSEM_TYPES_H */
-- 
1.7.1

