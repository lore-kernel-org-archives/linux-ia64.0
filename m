From: Venki Pallipadi <venkatesh.pallipadi@intel.com>
Date: Tue, 22 May 2007 22:36:57 +0000
Subject: [PATCH] Cleanup acpi header to reuse the generic _PDC defines
Message-Id: <20070522223656.GB14410@linux-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


ia64 _PDC setup is defined similar to i386. So, cleanup the header to use
generic _PDC defines than using specific defines in ia64.

Signed-off-by: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>

Index: linux-2.6.22-rc-mm/include/asm-ia64/acpi.h
=================================--- linux-2.6.22-rc-mm.orig/include/asm-ia64/acpi.h	2007-05-22 13:46:23.000000000 -0700
+++ linux-2.6.22-rc-mm/include/asm-ia64/acpi.h	2007-05-22 13:46:59.000000000 -0700
@@ -30,6 +30,8 @@
 
 #ifdef __KERNEL__
 
+#include <acpi/pdc_intel.h>
+
 #include <linux/init.h>
 #include <linux/numa.h>
 #include <asm/system.h>
@@ -119,11 +121,6 @@
 extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
 #endif
 
-/*
- * Refer Intel ACPI _PDC support document for bit definitions
- */
-#define ACPI_PDC_EST_CAPABILITY_SMP     0x8
-
 #endif /*__KERNEL__*/
 
 #endif /*_ASM_ACPI_H*/
