From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 03 Mar 2006 22:42:26 +0000
Subject: [patch] mca recovery return value when no bus check
Message-Id: <200603032242.k23MgQrO1552614@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] mca recovery return value when no bus check.

When there is no bus check, the return code should be failure, not success.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/kernel/mca_drv.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2006-03-02 20:02:28.000000000 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2006-03-02 21:40:56.915601996 -0600
@@ -567,10 +567,15 @@ recover_from_processor_error(int platfor
 		return 0;
 
 	/*
-	 * If there is no bus error, record is weird but we need not to recover.
+	 * The cache check and bus check bits have four possible states
+	 *   cc bc
+	 *    0  0	Weird record, not recovered
+	 *    1  0	Cache error, not recovered
+	 *    0  1	I/O error, attempt recovery
+	 *    1  1	Memory error, attempt recovery
 	 */
 	if (psp->bc = 0 || pbci = NULL)
-		return 1;
+		return 0;
 
 	/*
 	 * Sorry, we cannot handle so many.
