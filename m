From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 16 Sep 2005 21:10:53 +0000
Subject: [patch] MCA recovery when Cache Check bit set
Message-Id: <200509162110.j8GLAr092680262@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Memory ECC errors on Montecito often result in the Cache Check bit
in the Processor State Parameter being set.  The current code will
not attempt to recover if the Cache Check bit is set.  

Signed-off-by: Russ Anderson (rja@sgi.com)

---------------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

Index: linux-2.6.git#test/arch/ia64/kernel/mca_drv.c
=================================--- linux-2.6.git#test.orig/arch/ia64/kernel/mca_drv.c	2005-09-15 11:49:53.938504337 -0500
+++ linux-2.6.git#test/arch/ia64/kernel/mca_drv.c	2005-09-16 15:32:47.922041606 -0500
@@ -515,13 +515,14 @@ recover_from_processor_error(int platfor
 	pal_processor_state_info_t *psp = (pal_processor_state_info_t*)peidx_psp(peidx);
 
 	/* 
-	 * We cannot recover errors with other than bus_check.
+	 * We cannot recover from internal processor errors.
 	 */
-	if (psp->cc || psp->rc || psp->uc) 
+	if (psp->rc || psp->uc)
 		return 0;
 
 	/*
-	 * If there is no bus error, record is weird but we need not to recover.
+	 * The bus check bit indicates the error is external, not an internal
+	 * processor error.  If there is no bus check, don't try to recover.
 	 */
 	if (psp->bc = 0 || pbci = NULL)
 		return 1;
