From: Dean Roe <roe@sgi.com>
Date: Tue, 24 Jan 2006 14:30:10 +0000
Subject: [PATCH] add sn_feature_sets bit
Message-Id: <20060124143010.GA9167@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SGI's prom has added a new feature which avoids an Altix-specific
MCA that can occur with excessive use of ia64_pal_cache_flush.  This
patch adds the #define to the sn_feature_sets.h to reflect that bit
is taken.


	Signed-off-by: Dean Roe <roe@sgi.com>


Index: linux-ia64-test/include/asm-ia64/sn/sn_feature_sets.h
=================================--- linux-ia64-test.orig/include/asm-ia64/sn/sn_feature_sets.h
+++ linux-ia64-test/include/asm-ia64/sn/sn_feature_sets.h
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2005-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -27,14 +27,10 @@
  * "false" for new features.
  *
  * Use:
- * 		if (sn_prom_feature_available(PRF_FEATURE_XXX))
+ * 		if (sn_prom_feature_available(PRF_XXX))
  * 			...
  */
-
-/*
- * Example: feature XXX
- */
-#define PRF_FEATURE_XXX		0
+#define PRF_PAL_CACHE_FLUSH_SAFE		0
