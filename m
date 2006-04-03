From: Christoph Lameter <clameter@sgi.com>
Date: Mon, 03 Apr 2006 18:32:40 +0000
Subject: Fix ia64 bit ops: Full barriers for bit operations returning a value
Message-Id: <Pine.LNX.4.64.0604031129510.21064@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Sat, 1 Apr 2006, Nick Piggin wrote:

> All bitop and atomic test_and_set, inc_return, etc etc (ie. everything
> that modifies the operand and returns something) needs to be a full
> barrier before and after too.

Fix ia64 bitops: full barriers in bitops returning a value

This fixes up bitops so that they provide a full barrier which are 
required according to Documentation/atomic_ops.txt. Bit operations use a 
cmpxchg with a prior load from a volatile pointer. This load is an acquire 
operation. I think we can simply make the cmpxchg have release semantics 
in order to produce a full acquire / release cycle.

Note that this only fixes up the bit operations if used together with the
earlier fix for the clear_bit barriers. We still need a fix for general 
atomic operations.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-mm2/include/asm-ia64/bitops.h
=================================--- linux-2.6.16-mm2.orig/include/asm-ia64/bitops.h	2006-03-31 11:17:53.000000000 -0800
+++ linux-2.6.16-mm2/include/asm-ia64/bitops.h	2006-04-03 11:19:45.000000000 -0700
@@ -163,13 +163,14 @@ test_and_set_bit (int nr, volatile void 
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	/* Volatile load = acquire */
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = 1 << (nr & 31);
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old | bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
@@ -208,13 +209,14 @@ test_and_clear_bit (int nr, volatile voi
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	/* Volatile load = acquire */
 	m = (volatile __u32 *) addr + (nr >> 5);
 	mask = ~(1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old & mask;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & ~mask) != 0;
 }
 
@@ -253,13 +255,14 @@ test_and_change_bit (int nr, volatile vo
 	volatile __u32 *m;
 	CMPXCHG_BUGCHECK_DECL
 
+	/* Volatile load = acquire */
 	m = (volatile __u32 *) addr + (nr >> 5);
 	bit = (1 << (nr & 31));
 	do {
 		CMPXCHG_BUGCHECK(m);
 		old = *m;
 		new = old ^ bit;
-	} while (cmpxchg_acq(m, old, new) != old);
+	} while (cmpxchg_rel(m, old, new) != old);
 	return (old & bit) != 0;
 }
 
