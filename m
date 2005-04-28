From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 28 Apr 2005 20:32:35 +0000
Subject: write_unlock: replace clear_bit with byte store
Message-Id: <Pine.LNX.4.58.0504281329150.23584@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The rwlocks use IMHO too many semaphore operations.

write_lock uses a cmpxchg like the regular spin_lock but write_unlock uses
clear_bit which requires a load and then a loop over a cmpxchg. The
following patch makes write_unlock simply use a store to clear the highest
8 bits. We will then still have the lower 3 bytes (24 bits) left to count
the readers. I would expect the performance of write_lock and
write_unlock to be the same as regular spinlocks with this patch.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.11/include/asm-ia64/spinlock.h
=================================--- linux-2.6.11.orig/include/asm-ia64/spinlock.h	2005-03-01 23:37:48.000000000 -0800
+++ linux-2.6.11/include/asm-ia64/spinlock.h	2005-04-28 13:15:38.000000000 -0700
@@ -201,8 +201,9 @@ do {										\

 #define _raw_write_unlock(x)								\
 ({											\
-	smp_mb__before_clear_bit();	/* need barrier before releasing lock... */	\
-	clear_bit(31, (x));								\
+	u8 *y = (u8 *)x;								\
+	smp_wmb();			/* need barrier before releasing lock... */	\
+	y[3] = 0;									\
 })

 #endif /*  _ASM_IA64_SPINLOCK_H */
