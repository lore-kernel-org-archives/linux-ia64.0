From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 19 Jan 2005 05:04:38 +0000
Subject: [patch] minor entry.S cleanups
Message-Id: <16877.60006.277547.862953@napali.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Update copyright year & fix a comment in entry.S.

	--david

Signed-off-by: David Mosberger-Tang <davidm@hpl.hp.com>

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/18 18:22:47-08:00 davidm@tiger.hpl.hp.com 
#   ia64: Update copyright year in entry.S.
# 
# arch/ia64/kernel/entry.S
#   2005/01/18 18:22:31-08:00 davidm@tiger.hpl.hp.com +2 -2
#   Don't forget to update the copyright year.
# 
diff -Nru a/arch/ia64/kernel/entry.S b/arch/ia64/kernel/entry.S
--- a/arch/ia64/kernel/entry.S	2005-01-18 21:03:49 -08:00
+++ b/arch/ia64/kernel/entry.S	2005-01-18 21:03:49 -08:00
@@ -3,7 +3,7 @@
  *
  * Kernel entry points.
  *
- * Copyright (C) 1998-2003 Hewlett-Packard Co
+ * Copyright (C) 1998-2003, 2005 Hewlett-Packard Co
  *	David Mosberger-Tang <davidm@hpl.hp.com>
  * Copyright (C) 1999, 2002-2003
  *	Asit Mallick <Asit.K.Mallick@intel.com>
@@ -904,7 +904,7 @@
 	cmp.eq p9,p0=r0,r0	// set p9 to indicate that we should restore cr.ifs
 	;;
 	ld8 r24=[r16],16	// load ar.rnat (may be garbage)
-	ld8 r23=[r17],16// load ar.bspstore (may be garbage)
+	ld8 r23=[r17],16	// load ar.bspstore (may be garbage)
 	;;
 	ld8 r31=[r16],16	// load predicates
 	ld8 r21=[r17],16	// load b0
