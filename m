From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 04:58:23 +0000
Subject: [patch] ia64: Align rse_clear_invalid to double-bundle boundary.
Message-Id: <16877.59631.914927.689418@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Trivial patch: align rse_clear_invalid to 32-byte boundary.  Good for
a 9 cycle speed up.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 17:38:56-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Align rse_clear_invalid to double-bundle boundary.  Improves (normal)
#   	getpid() from 284 to 275 cycles.
# 
# arch/ia64/kernel/entry.S
#   2005/01/18 17:38:40-08:00 davidm@tiger.hpl.hp.com +1 -0
#   (rse_clear_invalid): Align it to 32 bytes.
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 20:57:18 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 20:57:18 -08:00
@@ -971,6 +971,7 @@
 	shladd in0=loc1,3,r17
 	mov in1=0
 	;;
+	.align 32
 rse_clear_invalid:
 #ifdef CONFIG_ITANIUM
 	// cycle 0
