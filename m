From: "H. J. Lu" <hjl@lucon.org>
Date: Thu, 03 Feb 2005 23:38:54 +0000
Subject: PATCH: Fix unwind info in arch/ia64/lib/memset.S
Message-Id: <20050203233854.GA30223@lucon.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I got

arch/ia64/lib/memset.S:62: Warning: .save outside of prologue


H.J.
--- linux/arch/ia64/lib/memset.S.unwind	2005-02-03 10:46:27.000000000 -0800
+++ linux/arch/ia64/lib/memset.S	2005-02-03 15:35:36.000000000 -0800
@@ -57,10 +57,10 @@ GLOBAL_ENTRY(memset)
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
