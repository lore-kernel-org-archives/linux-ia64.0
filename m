From: Russ Anderson <rja@sgi.com>
Date: Thu, 14 Jun 2007 21:01:24 +0000
Subject: [patch] Force error to surface in nofault code
Message-Id: <200706142101.l5EL1OGV102821379@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Force error to surface in nofault code

Montecito behaves slightly differently than previous processors,
resulting in the MCA due to a failed PIO read to sometimes surfacing
outside the nofault code.  Adding an additional or and stop bits
ensures the MCA surfaces in the nofault code.


Signed-off-by: Russ Anderson <rja@sgi.com>

---
 arch/ia64/sn/kernel/xp_nofault.S |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: test/arch/ia64/sn/kernel/xp_nofault.S
=================================--- test.orig/arch/ia64/sn/kernel/xp_nofault.S	2007-06-11 14:18:47.089395741 -0500
+++ test/arch/ia64/sn/kernel/xp_nofault.S	2007-06-14 15:30:23.572078520 -0500
@@ -21,7 +21,8 @@
 xp_nofault_PIOR:
 	mov	r8=r0			// Stage a success return value
 	ld8.acq	r9=[r32];;		// PIO Read the specified register
-	adds	r9=1,r9			// Add to force a consume
+	adds	r9=1,r9;;		// Add to force consumption
+	or	r9=r9,r9;;		// Or to force consumption
 	br.ret.sptk.many b0;;		// Return success
 
 	.global xp_error_PIOR
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
