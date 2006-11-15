From: Robin Holt <holt@sgi.com>
Date: Wed, 15 Nov 2006 02:50:59 +0000
Subject: [PATCH] bte_unaligned_copy() transfers one extra cache line.
Message-Id: <20061115025059.GC18881@lnx-holt.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When called to do a transfer that has a start offset within the cache
line which is uneven between source and destination and a length which
terminates the source of the copy exactly on a cache line, one extra
line gets copied into a temporary buffer.  This is normally not an issue
since the buffer is a kernel buffer and only the requested information
gets copied into the user buffer.

The problem arises when the source ends at the very last physical page
of memory.  That last cache line does not exist and results in the SHUB
chip raising an MCA.


Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/arch/ia64/sn/kernel/bte.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/bte.c	2006-09-27 14:06:15.000000000 -0500
+++ linux-2.6/arch/ia64/sn/kernel/bte.c	2006-11-14 20:36:16.779928325 -0600
@@ -381,14 +381,13 @@ bte_result_t bte_unaligned_copy(u64 src,
 		 * bcopy to the destination.
 		 */
 
-		/* Add the leader from source */
-		headBteLen = len + (src & L1_CACHE_MASK);
-		/* Add the trailing bytes from footer. */
-		headBteLen += L1_CACHE_BYTES - (headBteLen & L1_CACHE_MASK);
-		headBteSource = src & ~L1_CACHE_MASK;
 		headBcopySrcOffset = src & L1_CACHE_MASK;
 		headBcopyDest = dest;
 		headBcopyLen = len;
+
+		headBteSource = src - headBcopySrcOffset;
+		/* Add the leading and trailing bytes from source */
+		headBteLen = L1_CACHE_ALIGN(len + headBcopySrcOffset);
 	}
 
 	if (headBcopyLen > 0) {
