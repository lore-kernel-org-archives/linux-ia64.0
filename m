From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 09 Apr 2005 05:09:54 +0000
Subject: Re: [mpm@selenic.com: Re: buggy ia64_fls() ? (was Re: /dev/random
Message-Id: <16983.25506.695831.90589@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050408103324.6c5231df.akpm@osdl.org>
In-Reply-To: <20050408103324.6c5231df.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Andrew,

Please apply the attached patch.

>>>>> On Fri, 8 Apr 2005 11:02:47 -0700, Andrew Morton <akpm@osdl.org> said:

  Andrew> I'd be more inclined to make ia64 use generic_fls() until
  Andrew> someone can get in there and fix it for real.

OK, here is a patch which should be good for inclusion.

I was curious to find out how this bug came about and went undetected
so long.  As far as I can see, fls() was introduced around Mar 2002.
Initially, the only use was in get_bitmask_order() which, in turn, was
used only by kernel/suspend.c --- a file which isn't used on ia64 (so
far).  Furthermore, none of the original fls() versions spelled out
what results they were expecting (same is true for ia64_fls(), which
is my fault ;-( ).  Of course, it would have been easy to detect the
discrepancy by testing the code but given that fls() wasn't being used
on ia64 at the time, that probably just fell through the cracks.  Even
as new uses of fls() were added later on, none of them seem to be
triggered for a normal ia64 kernel (e.g., some of them required
turning on a DEBUG option), so I guess it's not really surprising that
this hasn't shown up before.

Of course, this isn't an excuse, but perhaps understanding how this
happened will avoid repeating similar mistakes in the future.

Thanks,

	--david

[IA64] fix fls()

The ia64-version of fls() never worked as intended (the bitnumbering
was off by 1 and fls(0) was undefined).  This patch fixes the problem
by using a popcnt-based fls(), which on McKinley-derived cores is
slightly faster than both ia64_fls() and generic_fls().  The resulting
code, however, is bigger (7-8 bundles instead of about 3 bundles).
Also switch ia64_popcnt() to __builtin_popcountl() for GCC v3.4 or
newer since the compiler can predicate that and schedule it better.

Thanks to Simon Derr and Matt Mackall for tracking down this bug.

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

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
