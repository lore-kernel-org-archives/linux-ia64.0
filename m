From: Keith Owens <kaos@sgi.com>
Date: Thu, 21 Oct 2004 00:16:15 +0000
Subject: [patch 2.6.9] SN: Correct bit test for salinfo oem decode
Message-Id: <13178.1098317775@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

The valid.oem_data bit is in different positions in each section.  Make
the test for valid oem data a section specific test.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/sn/kernel/mca.c
=================================--- linux.orig/arch/ia64/sn/kernel/mca.c	Thu Oct 21 09:55:13 2004
+++ linux/arch/ia64/sn/kernel/mca.c	Thu Oct 21 10:10:14 2004
@@ -102,14 +102,11 @@ sn_init_cpei_timer(void)
 static int
 sn_platform_plat_specific_err_print(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size)
 {
-	sal_log_plat_specific_err_info_t *psei = (sal_log_plat_specific_err_info_t *)sect_header;
-	if (!psei->valid.oem_data)
-		return 0;
 	down(&sn_oemdata_mutex);
 	sn_oemdata = oemdata;
 	sn_oemdata_size = oemdata_size;
 	sn_oemdata_bufsize = 0;
-	ia64_sn_plat_specific_err_print(print_hook, (char *)psei);
+	ia64_sn_plat_specific_err_print(print_hook, (char *)sect_header);
 	up(&sn_oemdata_mutex);
 	return 0;
 }
@@ -120,13 +117,21 @@ sn_platform_plat_specific_err_print(cons
 int sn_salinfo_platform_oemdata(const u8 *sect_header, u8 **oemdata, u64 *oemdata_size)
 {
 	efi_guid_t guid = *(efi_guid_t *)sect_header;
+	int valid = 0;
 	*oemdata_size = 0;
 	vfree(*oemdata);
 	*oemdata = NULL;
-	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0 ||
-	    efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0)
+	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0) {
+		sal_log_plat_specific_err_info_t *psei = (sal_log_plat_specific_err_info_t *)sect_header;
+		valid = psei->valid.oem_data;
+	} else if (efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0) {
+		sal_log_mem_dev_err_info_t *mdei = (sal_log_mem_dev_err_info_t *)sect_header;
+		valid = mdei->valid.oem_data;
+	}
+	if (valid)
 		return sn_platform_plat_specific_err_print(sect_header, oemdata, oemdata_size);
-	return 0;
+	else
+		return 0;
 }
 
 static int __init sn_salinfo_init(void)

