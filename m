From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 09 Apr 2005 00:21:06 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <16983.8178.342410.690955@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here is a first cut for the patch.  It compiles with gcc 3.3 and 3.4
and boots on Ski.  Assuming nobody finds any issues, I'll make a final
patch tonight.

Thanks,

	--david

=== include/asm-ia64/bitops.h 1.19 vs edited ==--- 1.19/include/asm-ia64/bitops.h	2005-03-13 15:30:06 -08:00
+++ edited/include/asm-ia64/bitops.h	2005-04-08 17:17:09 -07:00
@@ -314,8 +314,8 @@
 #ifdef __KERNEL__
 
 /*
- * find_last_zero_bit - find the last zero bit in a 64 bit quantity
- * @x: The value to search
+ * Return bit number of last (most-significant) bit set.  Undefined
+ * for x=0.  Bits are numbered from 0..63 (e.g., ia64_fls(9) = 3).
  */
 static inline unsigned long
 ia64_fls (unsigned long x)
@@ -327,10 +327,23 @@
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
=== include/asm-ia64/gcc_intrin.h 1.7 vs edited ==--- 1.7/include/asm-ia64/gcc_intrin.h	2004-10-05 11:27:40 -07:00
+++ edited/include/asm-ia64/gcc_intrin.h	2005-04-08 17:16:54 -07:00
@@ -133,13 +133,17 @@
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
