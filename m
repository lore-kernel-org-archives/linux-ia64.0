From: Jack Steiner <steiner@sgi.com>
Date: Wed, 31 Aug 2005 15:05:02 +0000
Subject: [PATCH 1/1] - Add support for PROM feature sets
Message-Id: <20050831150502.GA23543@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Several years ago, we added "PROM versioning" to the SN code to check if the version 
of the PROM that is installed on a system is new enough to support the actual OS
that is booting. Early in boot, the OS checks the PROM version against an OS
hard coded "min PROM version" and panics if the PROM is too old.

This is useful for detecting attempts to boot with downrev PROMs.

This check worked ok (barely) when we were able to update the minimum version
in the OS just prior to a release.

This is no longer true. The new release methodology requires that we push code
to the community many months before a release This makes it impossible to keep
the hardcoded minimum PROM version correct. 

Shub2 has added another complication. Shub2 will have it's own version numbers 
that are independent of shub1 PROMS. (We could define a min-version for each 
of the PROMs, but that fixes only part of the problem).

We need a new method for determining the features that are supported by the
running PROM.

I'm proposing adding a "feature set" bit array to the PROM. As new features are
added to the PROM, a bit is added to the feature set to indicate that the PROM
supports the feature. Early in boot, the OS fetches the feature set and saves
it.

OS code can test for the presence of a feature with:

        if (sn_prom_feature_available(feature)) ...

This function will always return FALSE on old PROMs that do not support a
feature.

This will allow us to add new code to the OS to support features that are not
supported in all versions the PROM that the OS will run on.

In addition, the older version check will be deleted.

-----------

Add new vendor-specific SAL calls for:

	- notifying the PROM of specific features that are supported by the OS.
	  This is used to enable PROM feature if and only if the corresponding
	  feature is implemented in the OS

	- fetch feature sets that are supported by the current PROM. This allows
	  the OS to selectively enable features when the PROM support is available.


Signed-off-by: Jack Steiner <steiner@sgi.com>


 arch/ia64/sn/kernel/setup.c           |   31 +++++++++++-------
 include/asm-ia64/sn/sn_feature_sets.h |   57 ++++++++++++++++++++++++++++++++++
 include/asm-ia64/sn/sn_sal.h          |   36 ++++++++++++++++-----
 3 files changed, 104 insertions(+), 20 deletions(-)



Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	2005-08-30 11:40:31.656592649 -0500
+++ linux/arch/ia64/sn/kernel/setup.c	2005-08-30 15:46:55.214243783 -0500
@@ -49,6 +49,7 @@
 #include <asm/sn/clksupport.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/geo.h>
+#include <asm/sn/sn_feature_sets.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
 #include <asm/sn/klconfig.h>
@@ -97,6 +98,7 @@ EXPORT_SYMBOL(sn_region_size);
 int sn_prom_type;	/* 0=hardware, 1=medusa/realprom, 2=medusa/fakeprom */
 
 short physical_node_map[MAX_PHYSNODE_ID];
+static unsigned long sn_prom_features[MAX_PROM_FEATURE_SETS];
 
 EXPORT_SYMBOL(physical_node_map);
 
@@ -271,7 +273,10 @@ void __init sn_setup(char **cmdline_p)
 	u32 version = sn_sal_rev();
 	extern void sn_cpu_init(void);
 
-	ia64_sn_plat_set_error_handling_features();
+	ia64_sn_plat_set_error_handling_features();	// obsolete
+	ia64_sn_set_os_feature(OSF_MCA_SLV_TO_OS_INIT_SLV);
+	ia64_sn_set_os_feature(OSF_FEAT_LOG_SBES);
+
 
 #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
 	/*
@@ -314,16 +319,6 @@ void __init sn_setup(char **cmdline_p)
 
 	printk("SGI SAL version %x.%02x\n", version >> 8, version & 0x00FF);
 
-	/*
-	 * Confirm the SAL we're running on is recent enough...
-	 */
-	if (version < SN_SAL_MIN_VERSION) {
-		printk(KERN_ERR "This kernel needs SGI SAL version >= "
-		       "%x.%02x\n", SN_SAL_MIN_VERSION >> 8,
-		        SN_SAL_MIN_VERSION & 0x00FF);
-		panic("PROM version too old\n");
-	}
-
 	master_nasid = boot_get_nasid();
 
 	status @@ -480,6 +475,10 @@ void __init sn_cpu_init(void)
 	if (nodepdaindr[0] = NULL)
 		return;
 
+	for (i = 0; i < MAX_PROM_FEATURE_SETS; i++)
+		if (ia64_sn_get_prom_feature_set(i, &sn_prom_features[i]) != 0)
+			break;
+
 	cpuid = smp_processor_id();
 	cpuphyid = get_sapicid();
 
@@ -651,3 +650,12 @@ nasid_slice_to_cpuid(int nasid, int slic
 
 	return -1;
 }
+
+int sn_prom_feature_available(int id)
+{
+	if (id >= BITS_PER_LONG * MAX_PROM_FEATURE_SETS)
+		return 0;
+	return test_bit(id, sn_prom_features);
+}
+EXPORT_SYMBOL(sn_prom_feature_available);
+
Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	2005-08-30 11:40:38.886336855 -0500
+++ linux/include/asm-ia64/sn/sn_sal.h	2005-08-30 14:16:19.284893529 -0500
@@ -80,6 +80,9 @@
 #define SN_SAL_RESERVED_DO_NOT_USE		   0x02000062
 #define SN_SAL_IOIF_GET_PCI_TOPOLOGY		   0x02000064
 
+#define  SN_SAL_GET_PROM_FEATURE_SET		   0x02000065
+#define  SN_SAL_SET_OS_FEATURE_SET		   0x02000066
+
 /*
  * Service-specific constants
  */
@@ -118,8 +121,8 @@
 /*
  * Error Handling Features
  */
-#define SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV	0x1
-#define SAL_ERR_FEAT_LOG_SBES			0x2
+#define SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV	0x1	// obsolete
+#define SAL_ERR_FEAT_LOG_SBES			0x2	// obsolete
 #define SAL_ERR_FEAT_MFR_OVERRIDE		0x4
 #define SAL_ERR_FEAT_SBE_THRESHOLD		0xffff0000
 
@@ -152,12 +155,6 @@ sn_sal_rev(void)
 }
 
 /*
- * Specify the minimum PROM revsion required for this kernel.
- * Note that they're stored in hex format...
- */
-#define SN_SAL_MIN_VERSION	0x0404
-
-/*
  * Returns the master console nasid, if the call fails, return an illegal
  * value.
  */
@@ -336,7 +333,7 @@ ia64_sn_plat_cpei_handler(void)
 }
 
 /*
- * Set Error Handling Features
+ * Set Error Handling Features	(Obsolete)
  */
 static inline u64
 ia64_sn_plat_set_error_handling_features(void)
@@ -1052,4 +1049,25 @@ ia64_sn_is_fake_prom(void)
 	return (rv.status = 0);
 }
 
+static inline int
+ia64_sn_get_prom_feature_set(int set, unsigned long *feature_set)
+{
+	struct ia64_sal_retval rv;
+
+	SAL_CALL_NOLOCK(rv, SN_SAL_GET_PROM_FEATURE_SET, set, 0, 0, 0, 0, 0, 0);
+	if (rv.status != 0)
+		return rv.status;
+	*val = rv.v0;
+	return 0;
+}
+
+static inline int
+ia64_sn_set_os_feature(int feature)
+{
+	struct ia64_sal_retval rv;
+
+	SAL_CALL_NOLOCK(rv, SN_SAL_SET_OS_FEATURE_SET, feature, 0, 0, 0, 0, 0, 0);
+	return rv.status;
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */
Index: linux/include/asm-ia64/sn/sn_feature_sets.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/include/asm-ia64/sn/sn_feature_sets.h	2005-08-30 14:19:23.237962580 -0500
@@ -0,0 +1,57 @@
+#ifndef _ASM_IA64_SN_FEATURE_SETS_H
+#define _ASM_IA64_SN_FEATURE_SETS_H
+
+/*
+ * SN PROM Features
+ *
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ */
+
+
+#include <asm/types.h>
+#include <asm/bitops.h>
+
+/* --------------------- PROM Features -----------------------------*/
+extern int sn_prom_feature_available(int id);
+
+#define MAX_PROM_FEATURE_SETS			2
+
+/*
+ * The following defines features that may or may not be supported by the
+ * current PROM. The OS uses sn_prom_feature_available(feature) to test for
+ * the presence of a PROM feature. Down rev (old) PROMs will always test
+ * "false" for new features.
+ *
+ * Use:
+ * 		if (sn_prom_feature_available(PRF_FEATURE_XXX))
+ * 			...
+ */
+
+/*
+ * Example: feature XXX
+ */
+#define PRF_FEATURE_XXX		0
+
+
+
+/* --------------------- OS Features -------------------------------*/
+
+/*
+ * The following defines OS features that are optionally present in
+ * the operating system.
+ * During boot, PROM is notified of these features via a series of calls:
+ *
+ * 		ia64_sn_set_os_feature(feature1);
+ *
+ * Once enabled, a feature cannot be disabled.
+ *
+ * By default, features are disabled unless explicitly enabled.
+ */
+#define  OSF_MCA_SLV_TO_OS_INIT_SLV		0
+#define  OSF_FEAT_LOG_SBES			1
+
+#endif /* _ASM_IA64_SN_FEATURE_SETS_H */
-- 
Thanks

Jack Steiner (steiner@sgi.com)          651-683-5302
Principal Engineer                      SGI - Silicon Graphics, Inc.


