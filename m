From: Al Stone <ahs3@fc.hp.com>
Date: Fri, 11 Aug 2006 16:31:44 +0000
Subject: [PATCH] 80-column reformatting for flush.S
Message-Id: <1155313904.19157.37.camel@deimos>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Minor reformatting so that flush.S can be used with 80-column
displays, in accordance with Linux coding style.  No instructions
were changed.

Signed-off-by: Al Stone <ahs3@fc.hp.com>


diff --git a/arch/ia64/lib/flush.S b/arch/ia64/lib/flush.S
index 2a0d27f..0e36a7b 100644
--- a/arch/ia64/lib/flush.S
+++ b/arch/ia64/lib/flush.S
@@ -15,8 +15,9 @@ #include <asm/asmmacro.h>
 	 *
 	 *	Make i-cache(s) coherent with d-caches.
 	 *
-	 *	Must deal with range from start to end-1 but nothing else (need to
-	 *	be careful not to touch addresses that may be unmapped).
+	 *	Must deal with range from start to end-1 but nothing else
+	 *	(need to be careful not to touch addresses that may be 
+	 *	unmapped).
 	 *
 	 *	Note: "in0" and "in1" are preserved for debugging purposes.
 	 */
@@ -37,7 +38,8 @@ GLOBAL_ENTRY(flush_icache_range)
 	;;
 	sub	r8=r22,r23		// number of strides - 1
 	shl	r24=r23,r20		// r24: addresses for "fc.i" -					//	"start" rounded down to stride boundary
+					//	"start" rounded down to stride
+					//	boundary
 	.save	ar.lc,r3
 	mov	r3=ar.lc		// save ar.lc
 	;;
@@ -49,7 +51,8 @@ GLOBAL_ENTRY(flush_icache_range)
 	 * 32 byte aligned loop, even number of (actually 2) bundles
 	 */
 .Loop:	fc.i	r24			// issuable on M0 only
-	add	r24=r21,r24		// we flush "stride size" bytes per iteration
+	add	r24=r21,r24		// we flush "stride size" bytes per
+					//   iteration
 	nop.i	0
 	br.cloop.sptk.few .Loop
 	;;


-- 
Ciao,
al
----------------------------------------------------------------------
Al Stone                                      Alter Ego:
Open Source and Linux R&D                     Debian Developer
Hewlett-Packard Company                       http://www.debian.org
E-mail: ahs3@fc.hp.com                        ahs3@debian.org
----------------------------------------------------------------------

