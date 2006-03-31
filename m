From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 31 Mar 2006 19:31:05 +0000
Subject: Fix ia64 bitops: Full barrier on smp_mb__after_clear_bit()
Message-Id: <Pine.LNX.4.64.0603311124380.7426@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The Linux kernel works based on barriers and not on acquire and release 
semantics. We cannot expect an acquire or release of clear_bit() to 
provide the synchronization behavior expected by core kernel developers. 

Not having the proper barriers may introduce subtle breakage.
So change IA64 to provide full barriers for smp_mb__after_clear_bit.

This is also the way that powerpc (which faces similar issues) implements 
these macros.


include/asm-powerpc/bitops.h:

/*
 * clear_bit doesn't imply a memory barrier
 */
#define smp_mb__before_clear_bit()      smp_mb()
#define smp_mb__after_clear_bit()       smp_mb()

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-mm2/include/asm-ia64/bitops.h
=================================--- linux-2.6.16-mm2.orig/include/asm-ia64/bitops.h	2006-03-30 21:21:04.000000000 -0800
+++ linux-2.6.16-mm2/include/asm-ia64/bitops.h	2006-03-31 11:17:53.000000000 -0800
@@ -63,10 +63,13 @@ __set_bit (int nr, volatile void *addr)
 }
 
 /*
- * clear_bit() has "acquire" semantics.
+ * The current linux locking paradigm is oriented towards
+ * barriers. We cannot utilize acquire or relase behaviors
+ * to synchronize but must implement full barriers in order
+ * to avoid potential subtle breakage.
  */
 #define smp_mb__before_clear_bit()	smp_mb()
-#define smp_mb__after_clear_bit()	do { /* skip */; } while (0)
+#define smp_mb__after_clear_bit()	smp_mb()
 
 /**
  * clear_bit - Clears a bit in memory
