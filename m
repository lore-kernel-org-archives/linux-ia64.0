From: Russ Anderson <rja@sgi.com>
Date: Wed, 25 Oct 2006 19:18:27 +0000
Subject: [patch] Add dp bit to cache and bus check structs
Message-Id: <200610251918.k9PJIR5R21666745@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Add dp bit to cache and bus check structs

Rev 2.2 of Volume 2 of "Intel Itanium Architecture Software Developer's
Manual" (January 2006) adds a dp bit to the cache_check and bus_check
fields (pages 2:401-2:404).  This patch gets the structs back in sync 
with the spec.


Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/pal.h |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-10-18 17:17:52.000000000 -0500
+++ test/include/asm-ia64/pal.h	2006-10-25 11:47:15.056564673 -0500
@@ -487,10 +487,12 @@ typedef struct pal_cache_check_info_s {
 						 * error occurred
 						 */
 			wiv		: 1,	/* Way field valid */
-			reserved2	: 10,
+			reserved2	: 1,
+			dp		: 1,	/* Data poisoned on MBE */
+			reserved3	: 8,
 
 			index		: 20,	/* Cache line index */
-			reserved3	: 2,
+			reserved4	: 2,
 
 			is		: 1,	/* instruction set (1 = ia32) */
 			iv		: 1,	/* instruction set field valid */
@@ -557,7 +559,7 @@ typedef struct pal_bus_check_info_s {
 			type		: 8,	/* Bus xaction type*/
 			sev		: 5,	/* Bus error severity*/
 			hier		: 2,	/* Bus hierarchy level */
-			reserved1	: 1,
+			dp		: 1,	/* Data poisoned on MBE */
 			bsi		: 8,	/* Bus error status
 						 * info
 						 */
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
