From: Russ Anderson <rja@sgi.com>
Date: Tue, 26 Sep 2006 19:47:48 +0000
Subject: [patch] PAL calls need physical mode, stacked
Message-Id: <200609261947.k8QJlmLL8824932@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] PAL calls need physical mode, stacked

PAL_CACHE_READ and PAL_CACHE_WRITE need to be called in physical
mode with stacked registers.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/pal.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: test/include/asm-ia64/pal.h
=================================--- test.orig/include/asm-ia64/pal.h	2006-09-08 14:51:13.000000000 -0500
+++ test/include/asm-ia64/pal.h	2006-09-26 14:30:53.130648604 -0500
@@ -963,7 +963,8 @@ static inline s64
 ia64_pal_cache_read (pal_cache_line_id_u_t line_id, u64 physical_addr)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_CACHE_READ, line_id.pclid_data, physical_addr, 0);
+	PAL_CALL_PHYS_STK(iprv, PAL_CACHE_READ, line_id.pclid_data,
+				physical_addr, 0);
 	return iprv.status;
 }
 
@@ -985,7 +986,8 @@ static inline s64
 ia64_pal_cache_write (pal_cache_line_id_u_t line_id, u64 physical_addr, u64 data)
 {
 	struct ia64_pal_retval iprv;
-	PAL_CALL(iprv, PAL_CACHE_WRITE, line_id.pclid_data, physical_addr, data);
+	PAL_CALL_PHYS_STK(iprv, PAL_CACHE_WRITE, line_id.pclid_data,
+				physical_addr, data);
 	return iprv.status;
 }
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
