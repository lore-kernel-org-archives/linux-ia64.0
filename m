From: Keith Owens <kaos@sgi.com>
Date: Mon, 12 Jul 2004 22:08:48 +0000
Subject: [patch 2.6.8-rc1] Extend oem section types for SN mca records
Message-Id: <22864.1089670128@ocs3.ocs.com.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

SN mca records now contain oem data for platform memory errors.

Signed-off-by: Keith Owens <kaos@sgi.com>

Index: linux/arch/ia64/sn/kernel/mca.c
=================================--- linux.orig/arch/ia64/sn/kernel/mca.c	Wed Jun 16 15:19:01 2004
+++ linux/arch/ia64/sn/kernel/mca.c	Tue Jul 13 08:00:52 2004
@@ -123,7 +123,8 @@ int sn_salinfo_platform_oemdata(const u8
 	*oemdata_size = 0;
 	vfree(*oemdata);
 	*oemdata = NULL;
-	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0)
+	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0 ||
+	    efi_guidcmp(guid, SAL_PLAT_MEM_DEV_ERR_SECT_GUID) = 0)
 		return sn_platform_plat_specific_err_print(sect_header, oemdata, oemdata_size);
 	return 0;
 }

