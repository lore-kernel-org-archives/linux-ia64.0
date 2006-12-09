From: Fenghua Yu <fenghua.yu@intel.com>
Date: Sat, 09 Dec 2006 00:17:31 +0000
Subject: [PATCH 5/5] Itanium MC Error Injection Tool: pal_mc_error_inject() interface
Message-Id: <20061208161731.A1106@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch implements pal_mc_error_inject() interface in kernel. Both physical
mode and virtual mode are supported.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>

--- a/include/asm-ia64/pal.h	2006-12-05 18:10:35.000000000 -0800
+++ b/include/asm-ia64/pal.h	2006-12-05 18:11:12.000000000 -0800
@@ -80,6 +80,8 @@
 #define PAL_SET_PSTATE		263	/* set the P-state */
 #define PAL_BRAND_INFO		274	/* Processor branding information */
 
+#define PAL_MC_ERROR_INJECT	276	/* Injects processor error or returns injection capabilities */
+
 #ifndef __ASSEMBLY__
 
 #include <linux/types.h>
@@ -1200,6 +1202,37 @@ ia64_pal_mc_error_info (u64 info_index, 
 	return iprv.status;
 }
 
+/* Injects the requested processor error or returns info on
+ * supported injection capabilities for current processor implementation
+ */
+static inline s64
+ia64_pal_mc_error_inject_phys (u64 err_type_info, u64 err_struct_info,
+			u64 err_data_buffer, u64 *capabilities, u64 *resources)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL_PHYS_STK(iprv, PAL_MC_ERROR_INJECT, err_type_info,
+			  err_struct_info, err_data_buffer);
+	if (capabilities)
+		*capabilities= iprv.v0;
+	if (resources)
+		*resources= iprv.v1;
+	return iprv.status;
+}
+
+static inline s64
+ia64_pal_mc_error_inject_virt (u64 err_type_info, u64 err_struct_info,
+			u64 err_data_buffer, u64 *capabilities, u64 *resources)
+{
+	struct ia64_pal_retval iprv;
+	PAL_CALL_STK(iprv, PAL_MC_ERROR_INJECT, err_type_info,
+			  err_struct_info, err_data_buffer);
+	if (capabilities)
+		*capabilities= iprv.v0;
+	if (resources)
+		*resources= iprv.v1;
+	return iprv.status;
+}
+
 /* Inform PALE_CHECK whether a machine check is expected so that PALE_CHECK willnot
  * attempt to correct any expected machine checks.
  */
