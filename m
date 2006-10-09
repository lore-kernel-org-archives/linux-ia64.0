From: Judith Lebzelter <judith@osdl.org>
Date: Mon, 09 Oct 2006 22:11:35 +0000
Subject: [PATCH] IA64 export symbols empty_zero_page, ia64_ssc
Message-Id: <20061009221135.GB9096@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

From: Judith Lebzelter <judith@osdl.org>

These warnings occur during modpost for ia64/allmodconfig in 2.6.19-rc1
WARNING: "empty_zero_page" [arch/ia64/hp/sim/simscsi.ko] undefined!
WARNING: "ia64_ssc" [arch/ia64/hp/sim/simscsi.ko] undefined!

This patch exports those variables and stops the warnings.

Signed-off-by: Judith Lebzelter <judith@osdl.org>

---

Index: linux/arch/ia64/kernel/ia64_ksyms.c
=================================--- linux.orig/arch/ia64/kernel/ia64_ksyms.c	2006-10-09 10:11:47.000000000 -0700
+++ linux/arch/ia64/kernel/ia64_ksyms.c	2006-10-09 10:15:18.000000000 -0700
@@ -111,3 +111,9 @@
 #endif
 extern char ia64_ivt[];
 EXPORT_SYMBOL(ia64_ivt);
+
+#include "../hp/sim/hpsim_ssc.h"
+EXPORT_SYMBOL(ia64_ssc);
+#include <asm/pgtable.h>
+EXPORT_SYMBOL(empty_zero_page);
+
