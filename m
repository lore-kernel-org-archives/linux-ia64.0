From: Bob Picco <bob.picco@hp.com>
Date: Fri, 21 Jan 2005 21:50:59 +0000
Subject: [PATCH] bitop warnings
Message-Id: <20050121225808.GC11543@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Tony:

I don't believe this has been submitted.  It removes many compiler warnings.

thanks,

bob

Signed-off-by: Bob Picco <bob.picco@hp.com>

diff -ruNp -X /home/picco/losl/dontdiff linux-2.6.11-rc1-mm1-mhp1-orig/arch/ia64/lib/bitop.c linux-2.6.11-rc1-mm1-mhp1/arch/ia64/lib/bitop.c
--- linux-2.6.11-rc1-mm1-mhp1-orig/arch/ia64/lib/bitop.c	2004-12-24 16:35:24.000000000 -0500
+++ linux-2.6.11-rc1-mm1-mhp1/arch/ia64/lib/bitop.c	2005-01-20 15:49:15.000000000 -0500
@@ -8,7 +8,7 @@
  * Find next zero bit in a bitmap reasonably efficiently..
  */
 
-int __find_next_zero_bit (void *addr, unsigned long size, unsigned long offset)
+int __find_next_zero_bit (const void *addr, unsigned long size, unsigned long offset)
 {
 	unsigned long *p = ((unsigned long *) addr) + (offset >> 6);
 	unsigned long result = offset & ~63UL;
diff -ruNp -X /home/picco/losl/dontdiff linux-2.6.11-rc1-mm1-mhp1-orig/include/asm-ia64/bitops.h linux-2.6.11-rc1-mm1-mhp1/include/asm-ia64/bitops.h
--- linux-2.6.11-rc1-mm1-mhp1-orig/include/asm-ia64/bitops.h	2004-12-24 16:35:28.000000000 -0500
+++ linux-2.6.11-rc1-mm1-mhp1/include/asm-ia64/bitops.h	2005-01-20 15:26:48.000000000 -0500
@@ -359,7 +359,7 @@ hweight64 (unsigned long x)
 
 #endif /* __KERNEL__ */
 
-extern int __find_next_zero_bit (void *addr, unsigned long size,
+extern int __find_next_zero_bit (const void *addr, unsigned long size,
 			unsigned long offset);
 extern int __find_next_bit(const void *addr, unsigned long size,
 			unsigned long offset);
