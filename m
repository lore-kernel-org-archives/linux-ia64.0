From: Russ Anderson <rja@sgi.com>
Date: Tue, 19 Dec 2006 17:05:40 +0000
Subject: [patch] Cache error recovery
Message-Id: <200612191705.kBJH5e0s69613196@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Cache error recovery

Similar to memory error recovery, when a cache error is consumed
by a user process terminate the user instead of crashing the system.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca_drv.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-12-19 10:28:36.000000000 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2006-12-19 10:33:32.393195202 -0600
@@ -602,6 +602,8 @@ recover_from_platform_error(slidx_table_
 		default:
 			break;
 		}
+	} else if (psp->cc && !psp->bc) { /* Cache error */
+		status = recover_from_read_error(slidx, peidx, pbci, sos);
 	}
 
 	return status;
@@ -688,11 +690,11 @@ recover_from_processor_error(int platfor
 	 * The cache check and bus check bits have four possible states
 	 *   cc bc
 	 *    0  0	Weird record, not recovered
-	 *    1  0	Cache error, not recovered
+	 *    1  0	Cache error, attempt recovered
 	 *    0  1	I/O error, attempt recovery
 	 *    1  1	Memory error, attempt recovery
 	 */
-	if (psp->bc = 0 || pbci = NULL)
+	if (psp->cc = 0 && (psp->bc = 0 || pbci = NULL))
 		return fatal_mca("No bus check");
 
 	/*
@@ -705,8 +707,6 @@ recover_from_processor_error(int platfor
 	 */
 	if (pbci->ib)
 		return fatal_mca("Internal Bus error");
-	if (pbci->cc)
-		return fatal_mca("Cache-cache error");
 	if (pbci->eb && pbci->bsi > 0)
 		return fatal_mca("External bus check fatal status");
 
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
