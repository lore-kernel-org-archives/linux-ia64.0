From: mita@miraclelinux.com (Akinobu Mita)
Date: Thu, 26 Jan 2006 03:30:50 +0000
Subject: [PATCH 2/12] generic __ffs()
Message-Id: <20060126033050.GA11138@miraclelinux.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060125112625.GA18584@miraclelinux.com> <20060125113206.GD18584@miraclelinux.com> <20060125200250.GA26443@flint.arm.linux.org.uk> <20060125205907.GF9995@esmail.cup.hp.com> <20060126032713.GA9984@miraclelinux.com>
In-Reply-To: <20060126032713.GA9984@miraclelinux.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Grant Grundler <iod00d@hp.com>
Cc: Linux Kernel Development <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org

This patch introduces the C-language equivalent of the function:
unsigned long __ffs(unsigned long word);

HAVE_ARCH___FFS_BITOPS is defined when the architecture has its own
version of these functions.

This code largely copied from:
include/asm-sparc64/bitops.h


Index: 2.6-git/include/asm-generic/bitops.h
=================================--- 2.6-git.orig/include/asm-generic/bitops.h	2006-01-25 19:14:08.000000000 +0900
+++ 2.6-git/include/asm-generic/bitops.h	2006-01-25 19:14:09.000000000 +0900
@@ -193,6 +193,43 @@
 
 #endif /* HAVE_ARCH_NON_ATOMIC_BITOPS */
 
+#ifndef HAVE_ARCH___FFS_BITOPS
+
+/**
+ * __ffs - find first bit in word.
+ * @word: The word to search
+ *
+ * Returns 0..BITS_PER_LONG-1
+ * Undefined if no bit exists, so code should check against 0 first.
+ */
+static inline unsigned long __ffs(unsigned long word)
+{
+	int b = 0, s;
+
+#if BITS_PER_LONG = 32
+	s = 16; if (word << 16 != 0) s = 0; b += s; word >>= s;
+	s =  8; if (word << 24 != 0) s = 0; b += s; word >>= s;
+	s =  4; if (word << 28 != 0) s = 0; b += s; word >>= s;
+	s =  2; if (word << 30 != 0) s = 0; b += s; word >>= s;
+	s =  1; if (word << 31 != 0) s = 0; b += s;
+
+	return b;
+#elif BITS_PER_LONG = 64
+	s = 32; if (word << 32 != 0) s = 0; b += s; word >>= s;
+	s = 16; if (word << 48 != 0) s = 0; b += s; word >>= s;
+	s =  8; if (word << 56 != 0) s = 0; b += s; word >>= s;
+	s =  4; if (word << 60 != 0) s = 0; b += s; word >>= s;
+	s =  2; if (word << 62 != 0) s = 0; b += s; word >>= s;
+	s =  1; if (word << 63 != 0) s = 0; b += s;
+
+	return b;
+#else
+#error BITS_PER_LONG not defined
+#endif
+}
+
+#endif /* HAVE_ARCH___FFS_BITOPS */
+
 /*
  * fls: find last bit set.
  */
