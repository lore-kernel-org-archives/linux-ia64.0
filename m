From: Keith Owens <kaos@sgi.com>
Date: Mon, 24 May 2004 07:15:09 +0000
Subject: Linux/prom notification of platform error handling features
Message-Id: <15657.1085382909@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Patch for discussion.  Is this acceptable as a platform specific tweak?
Or do we want a generic IA64 mechanism for this type of OS/prom
interaction?

The SGI prom needs to know how the OS wants to handle certain error
conditions, by definition this is platform specific.

* The SGI prom supports concurrent arrival of MCAs, and so do some of
  our diagnostic programs.  Linux does not cope with concurrent MCAs,
  so tell the prom to hold the second MCA event and use rendezvous
  and/or INIT on all but the monarch cpu.

* A TLB MCA error that can be recovered does not require all cpus to
  rendezvous, the error is isolated to a single cpu.

* PIO reads to I/O space do not require all cpus to rendezvous, the
  error is isolated to a single cpu.

To handle these and future OS/prom interactions, add a platform
specific SAL call to pass a bitmap of OS supported features so the prom
how the OS wants to proceed.


BTW, do other platforms support delivery of concurrent MCAs to the OS,
or do they only deliver the first one?  Tony Luck's TLB MCA recovery
has a lock on the MCA stack which implies that at least one platform
does concurrent MCA delivery.  However Linux will single thread
multiple MCAs, which could confuse the rendezvous algorithms.


Index: linux/include/asm-ia64/sn/sn_sal.h
=================================--- linux.orig/include/asm-ia64/sn/sn_sal.h	Sat May 22 13:02:12 2004
+++ linux/include/asm-ia64/sn/sn_sal.h	Sat May 22 13:02:42 2004
@@ -34,6 +34,7 @@
 #define  SN_SAL_NO_FAULT_ZONE_VIRTUAL		   0x02000010
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
+#define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_CONSOLE_PUTC                       0x02000021
 #define  SN_SAL_CONSOLE_GETC                       0x02000022
 #define  SN_SAL_CONSOLE_PUTS                       0x02000023
@@ -93,6 +94,20 @@
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
+
 
 /**
  * sn_sal_rev_major - get the major SGI SAL revision number
@@ -669,6 +684,28 @@ ia64_sn_sysctl_iobrick_pci_op(nasid_t n,
 	if (rv.status)
 	    	return rv.v0;
 	return 0;
+}
+
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
+	if (rv.status)
+	    	return rv.v0;
+	return 0;
 }
 
 #endif /* _ASM_IA64_SN_SN_SAL_H */

Index: linux/arch/ia64/sn/kernel/setup.c
=================================--- linux.orig/arch/ia64/sn/kernel/setup.c	Sat May 22 13:02:12 2004
+++ linux/arch/ia64/sn/kernel/setup.c	Sat May 22 13:02:42 2004
@@ -232,7 +232,27 @@ sn_check_for_wars(void)
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
+	u64 feature_bits[7];	/* see ia64_sn_set_error_handling_features */
+	u64 ret;
+	memset(feature_bits, 0, sizeof(feature_bits));
+#define EHF(x) __set_bit(SN_SAL_EHF_ ## x, feature_bits)
+	EHF(MCA_SLV_TO_OS_INIT_SLV);
+	EHF(NO_RZ_TLBC);
+	// Uncomment once Jesse's code goes in - EHF(NO_RZ_IO_READ); 
+#undef	EHF
+	ret = ia64_sn_set_error_handling_features(feature_bits);
+#if 0	/* Uncomment when the new prom has been out for a while */
+	if (ret)
+		printk(KERN_ERR "%s: failed, return code %lx\n", __FUNCTION__, ret);
+#endif
+}
 
 /**
  * sn_setup - SN platform setup routine
@@ -324,6 +344,9 @@ sn_setup(char **cmdline_p)
 		       master_node_bedrock_address);
 	}
 
+	/* Tell the prom how to handle certain error types */
+	sn_set_error_handling_features();
+
 	/*
 	 * we set the default root device to /dev/hda
 	 * to make simulation easy

