From: "MAGENHEIMER,DAN (HP-FtCollins,ex1)" <dan_magenheimer@hp.com>
Date: Thu, 16 Jan 2003 22:48:33 +0000
Subject: [Linux-ia64] ia64_fls patch (asm-ia64/bitops.h)
Message-Id: <marc-linux-ia64-105590709805705@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here's a patch for a mistake in ia64_fls in bitops.h.  The result
was incorrect (64) for inputs starting at 0xfffffffffffffc00.
I've also fixed the comment and the return value (which was -65535!)
for a zero input value.  According to davidm, existing calls don't use
any of the "bad" input values so classify it as a bug waiting to happen.

This is on 2.4.20... I haven't looked at 2.5.x but I'd imagine
the patch needs to be put there too.

This is my first post and my first patch... apologies in advance (and
correct protocol pointers welcome) if anything goes wrong!

Dan Magenheimer
HP Laboratories Fort Collins

==

diff -Nur include/asm-ia64/bitops.h include-fix-ia64_ffs/asm-ia64/bitops.h
--- include/asm-ia64/bitops.h	2003-01-02 11:38:26.000000000 -0700
+++ include-fix-ia64_ffs/asm-ia64/bitops.h	2003-01-16
15:36:12.000000000 -0700
@@ -283,17 +283,19 @@
 #ifdef __KERNEL__
 
 /*
- * find_last_zero_bit - find the last zero bit in a 64 bit quantity
+ * find_last_set_bit - find the last set bit in a non-zero 64 bit quantity
  * @x: The value to search
+ * returns -1 if the input is all zeroes, else the bit number of the most
+ * significant one-bit
  */
 static inline unsigned long
 ia64_fls (unsigned long x)
 {
-	double d = x;
+	long double d = x;
 	long exp;
 
 	__asm__ ("getf.exp %0=%1" : "=r"(exp) : "f"(d));
-	return exp - 0xffff;
+	return x ? (exp - 0xffff) : -1L;
 }
 
 /*

