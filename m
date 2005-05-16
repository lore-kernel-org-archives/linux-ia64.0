From: Russ Anderson <rja@sgi.com>
Date: Mon, 16 May 2005 22:30:26 +0000
Subject: [patch] Set Altix error handling features
Message-Id: <200505162230.j4GMUQRv13867391@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The 2.6 kernel has CPE error thresholding.
This patch lets SAL know of this error handling feature.
The changes are SN specific.

Signed-off-by: Russ Anderson (rja@sgi.com)

----------------------------------------------------------------------
Index: linux-2.6/arch/ia64/sn/kernel/setup.c
=================================--- linux-2.6.orig/arch/ia64/sn/kernel/setup.c	2005-05-16 15:07:53.496366966 -0500
+++ linux-2.6/arch/ia64/sn/kernel/setup.c	2005-05-16 15:21:49.605220098 -0500
@@ -271,6 +271,8 @@
 	int major = sn_sal_rev_major(), minor = sn_sal_rev_minor();
 	extern void sn_cpu_init(void);
 
+	ia64_sn_plat_set_error_handling_features();
+
 	/*
 	 * If the generic code has enabled vga console support - lets
 	 * get rid of it again. This is a kludge for the fact that ACPI
Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2005-05-16 15:07:54.044212418 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2005-05-16 15:23:27.374641062 -0500
@@ -115,6 +115,13 @@
 #define SAL_IROUTER_INTR_XMIT	SAL_CONSOLE_INTR_XMIT
 #define SAL_IROUTER_INTR_RECV	SAL_CONSOLE_INTR_RECV
 
+/*
+ * Error Handling Features
+ */
+#define SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV	0x1
+#define SAL_ERR_FEAT_LOG_SBES			0x2
+#define SAL_ERR_FEAT_MFR_OVERRIDE		0x4
+#define SAL_ERR_FEAT_SBE_THRESHOLD		0xffff0000
 
 /*
  * SAL Error Codes
@@ -342,6 +349,25 @@
 }
 
 /*
+ * Set Error Handling Features
+ */
+static inline u64
+ia64_sn_plat_set_error_handling_features(void)
+{
+	struct ia64_sal_retval ret_stuff;
+
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+	ret_stuff.v1 = 0;
+	ret_stuff.v2 = 0;
+	SAL_CALL_REENTRANT(ret_stuff, SN_SAL_SET_ERROR_HANDLING_FEATURES,
+		(SAL_ERR_FEAT_MCA_SLV_TO_OS_INIT_SLV | SAL_ERR_FEAT_LOG_SBES),
+		0, 0, 0, 0, 0, 0);
+
+	return ret_stuff.status;
+}
+
+/*
  * Checks for console input.
  */
 static inline u64
