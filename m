From: Keith Owens <kaos@sgi.com>
Date: Mon, 22 Mar 2004 03:11:35 +0000
Subject: [patch] 2.6.5-rc2 salinfo oemdata race fix
Message-Id: <5785.1079925095@kao2.melbourne.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sn_oemdata_* variables must only be used under the sn_oemdata_mutex.

--- linux-2.6.5-rc2.orig/arch/ia64/sn/kernel/mca.c
+++ linux-2.6.5-rc2/arch/ia64/sn/kernel/mca.c
@@ -108,6 +108,7 @@
 	down(&sn_oemdata_mutex);
 	sn_oemdata = oemdata;
 	sn_oemdata_size = oemdata_size;
+	sn_oemdata_bufsize = 0;
 	ia64_sn_plat_specific_err_print(print_hook, (char *)psei);
 	up(&sn_oemdata_mutex);
 	return 0;
@@ -120,7 +121,6 @@
 {
 	efi_guid_t guid = *(efi_guid_t *)sect_header;
 	*oemdata_size = 0;
-	sn_oemdata_bufsize = 0;
 	vfree(*oemdata);
 	*oemdata = NULL;
 	if (efi_guidcmp(guid, SAL_PLAT_SPECIFIC_ERR_SECT_GUID) = 0)


