From: Bill Nottingham <notting@redhat.com>
Date: Fri, 01 Jun 2001 16:12:40 +0000
Subject: [Linux-ia64] [PATCH] fix RAID autodetect on GPT-partitioned drives
MIME-Version: 1
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Message-Id: <marc-linux-ia64-105590693005682@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

The attached fixes RAID autodetection on GPT-partitioned drives;
the code was never actually compiled before because
CONFIG_AUTODETECT_RAID is a dead symbol.

Bill

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="linux-2.4.3-efi-raid.patch"

--- linux/fs/partitions/efi.c.foo	Fri Jun  1 11:13:34 2001
+++ linux/fs/partitions/efi.c	Fri Jun  1 11:13:53 2001
@@ -61,7 +61,7 @@
 #include "check.h"
 #include "efi.h"
 
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 extern void md_autodetect_dev(kdev_t dev);
 #endif
 
@@ -502,7 +502,7 @@
 	u32 i, nummade=0;
 
 	efi_guid_t unusedGuid = UNUSED_ENTRY_GUID;
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 	efi_guid_t raidGuid = PARTITION_LINUX_RAID_GUID;
 #endif
 
@@ -525,7 +525,7 @@
 				 (ptes[i].EndingLBA-ptes[i].StartingLBA + 1));
 
 		/* If there's this is a RAID volume, tell md */
-#if CONFIG_BLK_DEV_MD && CONFIG_AUTODETECT_RAID
+#if CONFIG_BLK_DEV_MD
 		if (!efi_guidcmp(raidGuid, ptes[i].PartitionTypeGuid)) {
 			md_autodetect_dev(MKDEV(MAJOR(dev),nextminor));
 		}

--liOOAslEiF7prFVr--

