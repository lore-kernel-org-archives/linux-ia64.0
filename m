From: Russ Anderson <rja@sgi.com>
Date: Thu, 03 Jan 2008 16:23:49 +0000
Subject: [patch] Update nofault code
Message-Id: <20080103162349.GB30694@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Update nofault code

Montecito and Montvale behaves slightly differently than previous 
Itanium processors, resulting in the MCA due to a failed PIO read
to sometimes surfacing outside the nofault code.  This code is
based on discussions with Intel CPU architects and verified at
customer sites.

Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/sn/kernel/xp_nofault.S |   10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

Index: test/arch/ia64/sn/kernel/xp_nofault.S
=================================--- test.orig/arch/ia64/sn/kernel/xp_nofault.S	2008-01-03 10:00:46.106785444 -0600
+++ test/arch/ia64/sn/kernel/xp_nofault.S	2008-01-03 10:03:28.602998658 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2004-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (c) 2004-2007 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 
@@ -14,6 +14,11 @@
  * PIO read fails, the MCA handler will force the error to look
  * corrected and vector to the xp_error_PIOR which will return an error.
  *
+ * The definition of "consumption" and the time it takes for an MCA
+ * to surface is processor implementation specific.  This code
+ * is sufficient on Itanium through the Montvale processor family.
+ * It may need to be adjusted for future processor implementations.
+ *
  *	extern int xp_nofault_PIOR(void *remote_register);
  */
 
@@ -22,11 +27,10 @@ xp_nofault_PIOR:
 	mov	r8=r0			// Stage a success return value
 	ld8.acq	r9=[r32];;		// PIO Read the specified register
 	adds	r9=1,r9;;		// Add to force consumption
-	or	r9=r9,r9;;		// Or to force consumption
+	srlz.i;;			// Allow time for MCA to surface
 	br.ret.sptk.many b0;;		// Return success
 
 	.global xp_error_PIOR
 xp_error_PIOR:
 	mov	r8=1			// Return value of 1
 	br.ret.sptk.many b0;;		// Return failure
-
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
