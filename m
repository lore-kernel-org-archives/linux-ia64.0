From: Russ Anderson <rja@sgi.com>
Date: Thu, 20 Dec 2007 23:46:52 +0000
Subject: [patch] Update Altix BTE error return status patch
Message-Id: <20071220234652.GE18816@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Update Altix BTE error return status patch

I neglected to send Tony the most recent version of the 
patch ("Fix Altix BTE error return status").

This patch gets it up to date.  Without this patch 
on shub2, if there is no error xpcBteUnmappedError is 
returned instead of xpcSuccess.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 include/asm-ia64/sn/xpc.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: test/include/asm-ia64/sn/xpc.h
=================================--- test.orig/include/asm-ia64/sn/xpc.h	2007-12-20 10:20:44.000000000 -0600
+++ test/include/asm-ia64/sn/xpc.h	2007-12-20 16:41:23.283386520 -0600
@@ -1211,11 +1211,13 @@ xpc_IPI_init(int index)
 static inline enum xpc_retval
 xpc_map_bte_errors(bte_result_t error)
 {
+	if (error = BTE_SUCCESS)
+		return xpcSuccess;
+
 	if (is_shub2()) {
 		if (BTE_VALID_SH2_ERROR(error))
 			return xpcBteSh2Start + error;
-		else
-			return xpcBteUnmappedError;
+		return xpcBteUnmappedError;
 	}
 	switch (error) {
 	case BTE_SUCCESS:	return xpcSuccess;
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
