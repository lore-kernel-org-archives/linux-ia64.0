From: akpm@osdl.org
Date: Fri, 22 Apr 2005 03:51:28 +0000
Subject: [patch 1/1] ia64: fix fls()
Message-Id: <200504220351.j3M3pf0R008990@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


From: David Mosberger <davidm@napali.hpl.hp.com>

The ia64-version of fls() never worked as intended (the bitnumbering was
off by 1 and fls(0) was undefined).  This patch fixes the problem by using
a popcnt-based fls(), which on McKinley-derived cores is slightly faster
than both ia64_fls() and generic_fls().  The resulting code, however, is
bigger (7-8 bundles instead of about 3 bundles).  Also switch ia64_popcnt()
to __builtin_popcountl() for GCC v3.4 or newer since the compiler can
predicate that and schedule it better.

Thanks to Simon Derr and Matt Mackall for tracking down this bug.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>
Cc: <linux-ia64@vger.kernel.org>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 include/asm-ia64/bitops.h     |   21 +++++++++++++++++----
 include/asm-ia64/gcc_intrin.h |   10 +++++++---
 2 files changed, 24 insertions(+), 7 deletions(-)

diff -puN include/asm-ia64/bitops.h~ia64-fix-fls include/asm-ia64/bitops.h
--- 25/include/asm-ia64/bitops.h~ia64-fix-fls	2005-04-22 13:50:19.597354400 +1000
+++ 25-akpm/include/asm-ia64/bitops.h	2005-04-22 13:50:19.613351968 +1000
@@ -314,8 +314,8 @@ __ffs (unsigned long x)
 #ifdef __KERNEL__
 
 /*
- * find_last_zero_bit - find the last zero bit in a 64 bit quantity
- * @x: The value to search
+ * Return bit number of last (most-significant) bit set.  Undefined
+ * for x=0.  Bits are numbered from 0..63 (e.g., ia64_fls(9) = 3).
  */
 static inline unsigned long
 ia64_fls (unsigned long x)
@@ -327,10 +327,23 @@ ia64_fls (unsigned long x)
 	return exp - 0xffff;
 }
 
+/*
+ * Find the last (most significant) bit set.  Returns 0 for x=0 and
+ * bits are numbered from 1..32 (e.g., fls(9) = 4).
+ */
 static inline int
-fls (int x)
+fls (int t)
 {
-	return ia64_fls((unsigned int) x);
+	unsigned long x = t & 0xffffffffu;
+
+	if (!x)
+		return 0;
+	x |= x >> 1;
+	x |= x >> 2;
+	x |= x >> 4;
+	x |= x >> 8;
+	x |= x >> 16;
+	return ia64_popcnt(x);
 }
 
 /*
diff -puN include/asm-ia64/gcc_intrin.h~ia64-fix-fls include/asm-ia64/gcc_intrin.h
--- 25/include/asm-ia64/gcc_intrin.h~ia64-fix-fls	2005-04-22 13:50:19.603353488 +1000
+++ 25-akpm/include/asm-ia64/gcc_intrin.h	2005-04-22 13:50:19.615351664 +1000
@@ -133,13 +133,17 @@ register unsigned long ia64_r13 asm ("r1
 	ia64_intri_res;								\
 })
 
-#define ia64_popcnt(x)						\
-({								\
+#if __GNUC__ >= 4 || (__GNUC__ = 3 && __GNUC_MINOR__ >= 4)
+# define ia64_popcnt(x)		__builtin_popcountl(x)
+#else
+# define ia64_popcnt(x)						\
+  ({								\
 	__u64 ia64_intri_res;					\
 	asm ("popcnt %0=%1" : "=r" (ia64_intri_res) : "r" (x));	\
 								\
 	ia64_intri_res;						\
-})
+  })
+#endif
 
 #define ia64_getf_exp(x)					\
 ({								\
_
