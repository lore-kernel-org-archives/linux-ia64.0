From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 26 Jan 2006 03:34:15 +0000
Subject: [PATCH 6/12] generic sched_find_first_bit()
Message-Id: <20060126033415.GE11138@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com>
In-Reply-To: <20060126032713.GA9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

This patch introduces the C-language equivalent of the function:
int sched_find_first_bit(const unsigned long *b);

HAVE_ARCH_SCHED_BITOPS is defined when the architecture has its own
version of these functions.

This code largely copied from:
include/asm-powerpc/bitops.h

Index: 2.6-git/include/asm-generic/bitops.h
=================================--- 2.6-git.orig/include/asm-generic/bitops.h	2006-01-25 19:14:10.000000000 +0900
+++ 2.6-git/include/asm-generic/bitops.h	2006-01-25 19:14:10.000000000 +0900
@@ -383,6 +383,41 @@
 
 #ifdef __KERNEL__
 
+#ifndef HAVE_ARCH_SCHED_BITOPS
+
+#include <linux/compiler.h>	/* unlikely() */
+
+/*
+ * Every architecture must define this function. It's the fastest
+ * way of searching a 140-bit bitmap where the first 100 bits are
+ * unlikely to be set. It's guaranteed that at least one of the 140
+ * bits is cleared.
+ */
+static inline int sched_find_first_bit(const unsigned long *b)
+{
+#if BITS_PER_LONG = 64
+	if (unlikely(b[0]))
+		return __ffs(b[0]);
+	if (unlikely(b[1]))
+		return __ffs(b[1]) + 64;
+	return __ffs(b[2]) + 128;
+#elif BITS_PER_LONG = 32
+	if (unlikely(b[0]))
+		return __ffs(b[0]);
+	if (unlikely(b[1]))
+		return __ffs(b[1]) + 32;
+	if (unlikely(b[2]))
+		return __ffs(b[2]) + 64;
+	if (b[3])
+		return __ffs(b[3]) + 96;
+	return __ffs(b[4]) + 128;
+#else
+#error BITS_PER_LONG not defined
+#endif
+}
+
+#endif /* HAVE_ARCH_SCHED_BITOPS */
+
 /*
  * ffs: find first bit set. This is defined the same way as
  * the libc and compiler builtin ffs routines, therefore
