From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Fri, 29 Apr 2005 09:02:19 +0000
Subject: [patch] fix unwind directive in memset()
Message-Id: <200504290902.j3T92J6u001342@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[IA64] Fix misplaced unwind-directive in memset()

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

Index: arch/ia64/lib/memset.S
=================================--- a63eb89df905efd86a58940286a63c5f670b1c05/arch/ia64/lib/memset.S  (mode:100644 sha1:bd8cf907fe227d60e488f4817f302da0335e508b)
+++ uncommitted/arch/ia64/lib/memset.S  (mode:100644)
@@ -57,10 +57,10 @@
 { .mmi
 	.prologue
 	alloc	tmp = ar.pfs, 3, 0, 0, 0
-	.body
 	lfetch.nt1 [dest]			//
 	.save   ar.lc, save_lc
 	mov.i	save_lc = ar.lc
+	.body
 } { .mmi
 	mov	ret0 = dest			// return value
 	cmp.ne	p_nz, p_zr = value, r0		// use stf.spill if value is zero
