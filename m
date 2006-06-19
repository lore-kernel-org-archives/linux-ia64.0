From: Mike Habeck <habeck@sgi.com>
Date: Mon, 19 Jun 2006 20:38:10 +0000
Subject: [PATCH] fix SGI Altix tioce_bus_fixup() bug
Message-Id: <20060619203810.15993.12349.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The following patch fixes a bug in the SGI Altix tioce_bus_fixup()
code.  ce_dre_comp_err_addr needs to be zero'd out not ~0ULL.  As
a result completion errors weren't being captured.

This patch is based off the aegl/linux-2.6.git tree

Signed-off-by: Mike Habeck <habeck@sgi.com>


Index: linux-2.6/arch/ia64/sn/pci/tioce_provider.c
=================================--- linux-2.6.orig/arch/ia64/sn/pci/tioce_provider.c	2006-06-19 09:48:04.000000000 -0500
+++ linux-2.6/arch/ia64/sn/pci/tioce_provider.c	2006-06-19 10:21:36.677454591 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2003-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ * Copyright (C) 2003-2006 Silicon Graphics, Inc.  All Rights Reserved.
  */
 
 #include <linux/types.h>
@@ -1002,7 +1002,7 @@
 	tioce_mmr_seti(tioce_kern, &tioce_mmr->ce_adm_int_status_alias, ~0ULL);
 	tioce_mmr_seti(tioce_kern, &tioce_mmr->ce_adm_error_summary_alias,
 		       ~0ULL);
-	tioce_mmr_seti(tioce_kern, &tioce_mmr->ce_dre_comp_err_addr, ~0ULL);
+	tioce_mmr_seti(tioce_kern, &tioce_mmr->ce_dre_comp_err_addr, 0ULL);
 
 	if (request_irq(SGI_PCIASIC_ERROR,
 			tioce_error_intr_handler,
