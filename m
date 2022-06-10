From: Alexander Lobakin <alexandr.lobakin@intel.com>
Date: Fri, 10 Jun 2022 11:34:23 +0000
Subject: [PATCH v2 2/6] bitops: always define asm-generic non-atomic bitops
Message-Id: <20220610113427.908751-3-alexandr.lobakin@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220610113427.908751-1-alexandr.lobakin@intel.com>
In-Reply-To: <20220610113427.908751-1-alexandr.lobakin@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Arnd Bergmann <arnd@arndb.de>, Yury Norov <yury.norov@gmail.com>
Cc: Alexander Lobakin <alexandr.lobakin@intel.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, Matt Turner <mattst88@gmail.com>, Brian Cain <bcain@quicinc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Kees Cook <keescook@chromium.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Marco Elver <elver@google.com>, Borislav Petkov <bp@suse.de>, Tony Luck <tony.luck@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-alpha@vger.kernel.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Move generic non-atomic bitops from the asm-generic header which
gets included only when there are no architecture-specific
alternatives, to a separate independent file to make them always
available.

Signed-off-by: Alexander Lobakin <alexandr.lobakin@intel.com>
---
 .../asm-generic/bitops/generic-non-atomic.h   | 124 ++++++++++++++++++
 include/asm-generic/bitops/non-atomic.h       | 109 ++-------------
 2 files changed, 132 insertions(+), 101 deletions(-)
 create mode 100644 include/asm-generic/bitops/generic-non-atomic.h

diff --git a/include/asm-generic/bitops/generic-non-atomic.h b/include/asm-generic/bitops/generic-non-atomic.h
new file mode 100644
index 000000000000..808bc4469886
--- /dev/null
+++ b/include/asm-generic/bitops/generic-non-atomic.h
@@ -0,0 +1,124 @@
+/* SPDX-License-Identifier: GPL-2.0-only */
+#ifndef __ASM_GENERIC_BITOPS_GENERIC_NON_ATOMIC_H
+#define __ASM_GENERIC_BITOPS_GENERIC_NON_ATOMIC_H
+
+#include <linux/bits.h>
+
+#ifndef _LINUX_BITOPS_H
+#error only <linux/bitops.h> can be included directly
+#endif
+
+/*
+ * Generic definitions for bit operations, should not be used in regular code
+ * directly.
+ */
+
+/**
+ * generic___set_bit - Set a bit in memory
+ * @nr: the bit to set
+ * @addr: the address to start counting from
+ *
+ * Unlike set_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static __always_inline void
+generic___set_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p  |= mask;
+}
+
+static __always_inline void
+generic___clear_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p &= ~mask;
+}
+
+/**
+ * generic___change_bit - Toggle a bit in memory
+ * @nr: the bit to change
+ * @addr: the address to start counting from
+ *
+ * Unlike change_bit(), this function is non-atomic and may be reordered.
+ * If it's called on the same region of memory simultaneously, the effect
+ * may be that only one operation succeeds.
+ */
+static __always_inline
+void generic___change_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+
+	*p ^= mask;
+}
+
+/**
+ * generic___test_and_set_bit - Set a bit and return its old value
+ * @nr: Bit to set
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static __always_inline int
+generic___test_and_set_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old | mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * generic___test_and_clear_bit - Clear a bit and return its old value
+ * @nr: Bit to clear
+ * @addr: Address to count from
+ *
+ * This operation is non-atomic and can be reordered.
+ * If two examples of this operation race, one can appear to succeed
+ * but actually fail.  You must protect multiple accesses with a lock.
+ */
+static __always_inline int
+generic___test_and_clear_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old & ~mask;
+	return (old & mask) != 0;
+}
+
+/* WARNING: non atomic and it can be reordered! */
+static __always_inline int
+generic___test_and_change_bit(unsigned int nr, volatile unsigned long *addr)
+{
+	unsigned long mask = BIT_MASK(nr);
+	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
+	unsigned long old = *p;
+
+	*p = old ^ mask;
+	return (old & mask) != 0;
+}
+
+/**
+ * generic_test_bit - Determine whether a bit is set
+ * @nr: bit number to test
+ * @addr: Address to start counting from
+ */
+static __always_inline int
+generic_test_bit(unsigned int nr, const volatile unsigned long *addr)
+{
+	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
+}
+
+#endif /* __ASM_GENERIC_BITOPS_GENERIC_NON_ATOMIC_H */
diff --git a/include/asm-generic/bitops/non-atomic.h b/include/asm-generic/bitops/non-atomic.h
index 078cc68be2f1..a05bc090a6a3 100644
--- a/include/asm-generic/bitops/non-atomic.h
+++ b/include/asm-generic/bitops/non-atomic.h
@@ -2,121 +2,28 @@
 #ifndef _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
 #define _ASM_GENERIC_BITOPS_NON_ATOMIC_H_
 
+#include <asm-generic/bitops/generic-non-atomic.h>
 #include <asm/types.h>
 
-/**
- * arch___set_bit - Set a bit in memory
- * @nr: the bit to set
- * @addr: the address to start counting from
- *
- * Unlike set_bit(), this function is non-atomic and may be reordered.
- * If it's called on the same region of memory simultaneously, the effect
- * may be that only one operation succeeds.
- */
-static __always_inline void
-arch___set_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-
-	*p  |= mask;
-}
+#define arch___set_bit generic___set_bit
 #define __set_bit arch___set_bit
 
-static __always_inline void
-arch___clear_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-
-	*p &= ~mask;
-}
+#define arch___clear_bit generic___clear_bit
 #define __clear_bit arch___clear_bit
 
-/**
- * arch___change_bit - Toggle a bit in memory
- * @nr: the bit to change
- * @addr: the address to start counting from
- *
- * Unlike change_bit(), this function is non-atomic and may be reordered.
- * If it's called on the same region of memory simultaneously, the effect
- * may be that only one operation succeeds.
- */
-static __always_inline
-void arch___change_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-
-	*p ^= mask;
-}
+#define arch___change_bit generic___change_bit
 #define __change_bit arch___change_bit
 
-/**
- * arch___test_and_set_bit - Set a bit and return its old value
- * @nr: Bit to set
- * @addr: Address to count from
- *
- * This operation is non-atomic and can be reordered.
- * If two examples of this operation race, one can appear to succeed
- * but actually fail.  You must protect multiple accesses with a lock.
- */
-static __always_inline int
-arch___test_and_set_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-	unsigned long old = *p;
-
-	*p = old | mask;
-	return (old & mask) != 0;
-}
+#define arch___test_and_set_bit generic___test_and_set_bit
 #define __test_and_set_bit arch___test_and_set_bit
 
-/**
- * arch___test_and_clear_bit - Clear a bit and return its old value
- * @nr: Bit to clear
- * @addr: Address to count from
- *
- * This operation is non-atomic and can be reordered.
- * If two examples of this operation race, one can appear to succeed
- * but actually fail.  You must protect multiple accesses with a lock.
- */
-static __always_inline int
-arch___test_and_clear_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-	unsigned long old = *p;
-
-	*p = old & ~mask;
-	return (old & mask) != 0;
-}
+#define arch___test_and_clear_bit generic___test_and_clear_bit
 #define __test_and_clear_bit arch___test_and_clear_bit
 
-/* WARNING: non atomic and it can be reordered! */
-static __always_inline int
-arch___test_and_change_bit(unsigned int nr, volatile unsigned long *addr)
-{
-	unsigned long mask = BIT_MASK(nr);
-	unsigned long *p = ((unsigned long *)addr) + BIT_WORD(nr);
-	unsigned long old = *p;
-
-	*p = old ^ mask;
-	return (old & mask) != 0;
-}
+#define arch___test_and_change_bit generic___test_and_change_bit
 #define __test_and_change_bit arch___test_and_change_bit
 
-/**
- * arch_test_bit - Determine whether a bit is set
- * @nr: bit number to test
- * @addr: Address to start counting from
- */
-static __always_inline int
-arch_test_bit(unsigned int nr, const volatile unsigned long *addr)
-{
-	return 1UL & (addr[BIT_WORD(nr)] >> (nr & (BITS_PER_LONG-1)));
-}
+#define arch_test_bit generic_test_bit
 #define test_bit arch_test_bit
 
 #endif /* _ASM_GENERIC_BITOPS_NON_ATOMIC_H_ */
-- 
2.36.1
