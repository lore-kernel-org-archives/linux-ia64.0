From: dcn@sgi.com (Dean Nelson)
Date: Wed, 11 Jul 2007 15:22:16 +0000
Subject: [PATCH] add sn_register_pmi_handler oemcall
Message-Id: <4694F5A8.mailx6DG1UFFYX@aqua.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Add wrapper function to make SN_SAL_REGISTER_PMI_HANDLER ia64_sal_oemcall.

Signed-off-by: Dean Nelson <dcn@sgi.com>


Index: linux-2.6/include/asm-ia64/sn/sn_sal.h
=================================--- linux-2.6.orig/include/asm-ia64/sn/sn_sal.h	2007-06-20 09:32:32.001968418 -0500
+++ linux-2.6/include/asm-ia64/sn/sn_sal.h	2007-06-20 09:32:39.646908636 -0500
@@ -32,6 +32,7 @@
 #define  SN_SAL_NO_FAULT_ZONE_VIRTUAL		   0x02000010
 #define  SN_SAL_NO_FAULT_ZONE_PHYSICAL		   0x02000011
 #define  SN_SAL_PRINT_ERROR			   0x02000012
+#define  SN_SAL_REGISTER_PMI_HANDLER		   0x02000014
 #define  SN_SAL_SET_ERROR_HANDLING_FEATURES	   0x0200001a	// reentrant
 #define  SN_SAL_GET_FIT_COMPT			   0x0200001b	// reentrant
 #define  SN_SAL_GET_SAPIC_INFO                     0x0200001d
@@ -680,6 +681,25 @@
 }
 
 /*
+ * Register or unregister a function to handle a PMI received by a CPU.
+ * Before calling the registered handler, SAL sets r1 to the value that
+ * was passed in as the global_pointer.
+ *
+ * If the handler pointer is NULL, then the currently registered handler
+ * will be unregistered.
+ *
+ * Returns 0 on success, or a negative value if an error occurred.
+ */
+static inline int
+sn_register_pmi_handler(u64 handler, u64 global_pointer)
+{
+	struct ia64_sal_retval ret_stuff;
+	ia64_sal_oemcall(&ret_stuff, SN_SAL_REGISTER_PMI_HANDLER, handler,
+			 global_pointer, 0, 0, 0, 0, 0);
+	return ret_stuff.status;
+}
+
+/*
  * Change or query the coherence domain for this partition. Each cpu-based
  * nasid is represented by a bit in an array of 64-bit words:
  *      0 = not in this partition's coherency domain
