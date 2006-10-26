From: Russ Anderson <rja@sgi.com>
Date: Thu, 26 Oct 2006 16:53:17 +0000
Subject: [patch] Add se bit to Processor State Parameter structure
Message-Id: <200610261653.k9QGrHKf21926673@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Add se bit to Processor State Parameter structure

Rev 2.2 of Volume 2 of "Intel Itanium Architecture Software Developer's
Manual" (January 2006) adds a se bit to the Processor State Parameter
fields (pages 2:299).  This patch gets the structs back in sync
with the spec.


Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/pal.h |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-10-25 11:47:15.000000000 -0500
+++ test/include/asm-ia64/pal.h	2006-10-26 11:38:52.097984744 -0500
@@ -456,7 +456,9 @@ typedef struct pal_process_state_info_s 
 						 * by the processor
 						 */
 
-			reserved2	: 11,
+			se		: 1,	/* Shared error.  MCA in a
+						   shared structure */
+			reserved2	: 10,
 			cc		: 1,	/* Cache check */
 			tc		: 1,	/* TLB check */
 			bc		: 1,	/* Bus check */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
