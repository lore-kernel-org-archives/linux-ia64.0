From: Keith Owens <kaos@sgi.com>
Date: Wed, 16 Jun 2004 03:31:46 +0000
Subject: [patch 2.6.7-rc3] Support SN platform specific error features
Message-Id: <8330.1087356706@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The SN prom supports fine grained error handling features, the OS needs
to tell the prom if the OS expects to use these platform specific
features.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: 2.6.7-rc3-pristine/arch/ia64/sn/kernel/setup.c
=================================--- 2.6.7-rc3-pristine.orig/arch/ia64/sn/kernel/setup.c	Tue Jun  8 11:46:30 2004
+++ 2.6.7-rc3-pristine/arch/ia64/sn/kernel/setup.c	Wed Jun 16 13:14:42 2004
@@ -226,7 +226,25 @@ sn_check_for_wars(void)
 			shub_1_1_found = 1;
 }
 
-
+/**
+ * sn_set_error_handling_features - Tell the SN prom how to handle certain
+ * error types.
+ */
+static void __init
+sn_set_error_handling_features(void)
+{
+	u64 ret;
+	u64 sn_ehf_bits[7];	/* see ia64_sn_set_error_handling_features */
+	memset(sn_ehf_bits, 0, sizeof(sn_ehf_bits));
+#define EHF(x) __set_bit(SN_SAL_EHF_ ## x, sn_ehf_bits)
+	EHF(MCA_SLV_TO_OS_INIT_SLV);
+	EHF(NO_RZ_TLBC);
+	// Uncomment once Jesse's code goes in - EHF(NO_RZ_IO_READ); 
+#undef	EHF
+	ret = ia64_sn_set_error_handling_features(sn_ehf_bits);
+	if (ret)
+		printk(KERN_ERR "%s: failed, return code %ld\n", __FUNCTION__, ret);
+}
 
 /**
  * sn_setup - SN platform setup routine
@@ -318,6 +336,9 @@ sn_setup(char **cmdline_p)
 		       master_node_bedrock_address);
 	}
 
+	/* Tell the prom how to handle certain error types */
+	sn_set_error_handling_features();
+
 	/*
 	 * we set the default root device to /dev/hda
 	 * to make simulation easy
Index: 2.6.7-rc3-pristine/include/asm-ia64/sn/sn_sal.h
=================================--- 2.6.7-rc3-pristine.orig/include/asm-ia64/sn/sn_sal.h	Mon May 10 13:38:15 2004
+++ 2.6.7-rc3-pristine/include/asm-ia64/sn/sn_sal.h	Wed Jun 16 13:14:42 2004
@@ -33,6 +33,7 @@
 #define  SN_SAL_NO_FAULT_ZONE_VIRTUAL		   0x02000010
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
+#define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
 #define  SN_SAL_CONSOLE_PUTS                       0x02000023
@@ -92,6 +93,19 @@
 #define SALRET_INVALID_ARG	-2
 #define SALRET_ERROR		-3
 
+/*
+ * SN_SAL_SET_ERROR_HANDLING_FEATURES bit settings
+ */
+enum 
+{
+	/* if "rz always" is set, have the mca slaves call os_init_slave */
+	SN_SAL_EHF_MCA_SLV_TO_OS_INIT_SLV=0,
+	/* do not rz on tlb checks, even if "rz always" is set */
+	SN_SAL_EHF_NO_RZ_TLBC,
+	/* do not rz on PIO reads to I/O space, even if "rz always" is set */
+	SN_SAL_EHF_NO_RZ_IO_READ,
+};
+
 
 /**
  * sn_sal_rev_major - get the major SGI SAL revision number
@@ -670,4 +684,24 @@ ia64_sn_sysctl_iobrick_pci_op(nasid_t n,
 	return 0;
 }
 
+/*
+ * Tell the prom how the OS wants to handle specific error features.
+ * It takes an array of 7 u64.
+ */
+static inline u64
+ia64_sn_set_error_handling_features(const u64 *feature_bits)
+{
+	struct ia64_sal_retval rv = {0, 0, 0, 0};
+
+	SAL_CALL_REENTRANT(rv, SN_SAL_SET_ERROR_HANDLING_FEATURES,
+			feature_bits[0],
+			feature_bits[1],
+			feature_bits[2],
+			feature_bits[3],
+			feature_bits[4],
+			feature_bits[5],
+			feature_bits[6]);
+	return rv.status;
+}
+
 #endif /* _ASM_IA64_SN_SN_SAL_H */

