From: akpm@linux-foundation.org
Date: Wed, 21 Nov 2007 22:58:24 +0000
Subject: [patch 1/3] IA64: Slim down __clear_bit_unlock
Message-Id: <200711212258.lALMwPnR013399@imap1.linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: Christoph Lameter <clameter@sgi.com>

__clear_bit_unlock does not need to perform atomic operations on the
variable.  Avoid a cmpxchg and simply do a store with release semantics. 
Add a barrier to be safe that the compiler does not do funky things.

[akpm@linux-foundation.org: coding-style fixes]
Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: "Luck, Tony" <tony.luck@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/asm-ia64/bitops.h |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff -puN include/asm-ia64/bitops.h~ia64-slim-down-__clear_bit_unlock include/asm-ia64/bitops.h
--- a/include/asm-ia64/bitops.h~ia64-slim-down-__clear_bit_unlock
+++ a/include/asm-ia64/bitops.h
@@ -124,10 +124,21 @@ clear_bit_unlock (int nr, volatile void 
 /**
  * __clear_bit_unlock - Non-atomically clear a bit with release
  *
- * This is like clear_bit_unlock, but the implementation may use a non-atomic
- * store (this one uses an atomic, however).
+ * This is like clear_bit_unlock, but the implementation uses a store
+ * with release semantics. See also __raw_spin_unlock().
  */
-#define __clear_bit_unlock clear_bit_unlock
+static __inline__ void
+__clear_bit_unlock(int nr, volatile void *addr)
+{
+	__u32 mask, new;
+	volatile __u32 *m;
+
+	m = (volatile __u32 *)addr + (nr >> 5);
+	mask = ~(1 << (nr & 31));
+	new = *m & mask;
+	barrier();
+	asm volatile ("st4.rel.nta [%0] = %1\n\t" :: "r"(m), "r"(new));
+}
 
 /**
  * __clear_bit - Clears a bit in memory (non-atomic version)
_
