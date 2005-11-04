From: Russ Anderson <rja@efs.americas.sgi.com>
Date: Fri, 04 Nov 2005 19:39:38 +0000
Subject: [patch] MCA recovery based on PSP bits
Message-Id: <200511041939.jA4JdcEk049077@efs.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] MCA recovery based on PSP bits

The determination of whether an MCA is recoverable or not must
be based on the bits set in the PSP (Processor State Parameter).
The specific bits are shown in the Intel IA-64 Architecture Software 
Developer's Manual, Vol 2, Table 11-6 Software Recovery Bits in 
Processor State Parameter.  Those bits should be consitent 
across the entire IA-64 family of processors.

Signed-off-by: Russ Anderson (rja@sgi.com)

--------------------------------------------------------------
 arch/ia64/kernel/mca_drv.c |   17 +++++++++++++----
 1 files changed, 13 insertions(+), 4 deletions(-)

Index: test/arch/ia64/kernel/mca_drv.c
=================================--- test.orig/arch/ia64/kernel/mca_drv.c	2005-11-04 11:09:30.612885192 -0600
+++ test/arch/ia64/kernel/mca_drv.c	2005-11-04 11:09:54.799800234 -0600
@@ -546,9 +546,20 @@ recover_from_processor_error(int platfor
 		(pal_processor_state_info_t*)peidx_psp(peidx);
 
 	/*
-	 * We cannot recover errors with other than bus_check.
+	 * Processor recovery status must key off of the PAL recovery
+	 * status in the Processor State Parameter.
 	 */
-	if (psp->cc || psp->rc || psp->uc)
+
+	/*
+	 * The machine check is corrected.
+	 */
+	if (psp->cm = 1)
+		return 1;
+
+	/*
+	 * The error was not contained.  Software must be reset.
+	 */
+	if (psp->us || psp->ci = 0)
 		return 0;
 
 	/*
@@ -569,8 +580,6 @@ recover_from_processor_error(int platfor
 		return 0;
 	if (pbci->eb && pbci->bsi > 0)
 		return 0;
-	if (psp->ci = 0)
-		return 0;
 
 	/*
 	 * This is a local MCA and estimated as recoverble external bus error.
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
