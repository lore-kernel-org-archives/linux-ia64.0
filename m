From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 29 Oct 2007 18:27:31 +0000
Subject: RE: [IA64] Effective __clear_bit_unlock V2
Message-Id: <617E1C2C70743745A92448908E030B2A02CE2F71@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0710191050520.31589@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Is this the final take on this ...  or was there a newer better faster cleaner
version?

-Tony 

-----Original Message-----
From: Christoph Lameter [mailto:clameter@sgi.com] 
Sent: Friday, October 19, 2007 10:54 AM
To: Luck, Tony
Cc: linux-ia64@vger.kernel.org; Zoltan Menyhart
Subject: [IA64] Effective __clear_bit_unlock V2

Avoid the use of cmpxchg in __clear_bit_unlock by calling __clear_bit.
__clear_bit uses a volatile pointer and will generate a store with
release semantics as shown by Zoltan. Add a barrier to make sure that
the compiler does not reorder instructions around it.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nick Piggin <npiggin@suse.de>

---
 include/asm-ia64/bitops.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

Index: linux-2.6/include/asm-ia64/bitops.h
=================================--- linux-2.6.orig/include/asm-ia64/bitops.h	2007-10-19 04:05:38.000000000 -0700
+++ linux-2.6/include/asm-ia64/bitops.h	2007-10-19 10:50:34.000000000 -0700
@@ -118,14 +118,6 @@ clear_bit_unlock (int nr, volatile void 
 }
 
 /**
- * __clear_bit_unlock - Non-atomically clear a bit with release
- *
- * This is like clear_bit_unlock, but the implementation may use a non-atomic
- * store (this one uses an atomic, however).
- */
-#define __clear_bit_unlock clear_bit_unlock
-
-/**
  * __clear_bit - Clears a bit in memory (non-atomic version)
  */
 static __inline__ void
@@ -137,6 +129,16 @@ __clear_bit (int nr, volatile void *addr
 }
 
 /**
+ * __clear_bit_unlock - Non-atomically clear a bit with release
+ */
+static __inline__ void
+__clear_bit_unlock (int nr, volatile void *addr)
+{
+	barrier();
+	__clear_bit(nr, addr);
+}
+
+/**
  * change_bit - Toggle a bit in memory
  * @nr: Bit to clear
  * @addr: Address to start counting from
