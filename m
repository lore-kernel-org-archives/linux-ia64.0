From: Russ Anderson <rja@sgi.com>
Date: Mon, 08 Jan 2007 22:05:08 +0000
Subject: [patch] Check for TIO errors on shub2 Altix
Message-Id: <200701082205.l08M58g879761582@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

[patch] Check for TIO errors on shub2 Altix

The shub2 error interrupt handler must check for TIO errors.

Signed-off-by: Russ Anderson (rja@sgi.com)

---
 arch/ia64/sn/kernel/huberror.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

Index: test/arch/ia64/sn/kernel/huberror.c
=================================--- test.orig/arch/ia64/sn/kernel/huberror.c	2006-12-10 19:37:14.000000000 -0600
+++ test/arch/ia64/sn/kernel/huberror.c	2007-01-05 16:57:20.000000000 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000,2002-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000,2002-2007 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/types.h>
@@ -38,12 +38,20 @@ static irqreturn_t hub_eint_handler(int 
 			(u64) nasid, 0, 0, 0, 0, 0, 0);
 
 		if ((int)ret_stuff.v0)
-			panic("hubii_eint_handler(): Fatal TIO Error");
+			panic("%s: Fatal %s Error", __FUNCTION__,
+				((nasid & 1) ? "TIO" : "HUBII"));
 
 		if (!(nasid & 1)) /* Not a TIO, handle CRB errors */
 			(void)hubiio_crb_error_handler(hubdev_info);
-	} else 
-		bte_error_handler((unsigned long)NODEPDA(nasid_to_cnodeid(nasid)));
+	} else
+		if (nasid & 1) {	/* TIO errors */
+			SAL_CALL_NOLOCK(ret_stuff, SN_SAL_HUB_ERROR_INTERRUPT,
+				(u64) nasid, 0, 0, 0, 0, 0, 0);
+
+			if ((int)ret_stuff.v0)
+				panic("%s: Fatal TIO Error", __FUNCTION__);
+		} else
+			bte_error_handler((unsigned long)NODEPDA(nasid_to_cnodeid(nasid)));
 
 	return IRQ_HANDLED;
 }
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
