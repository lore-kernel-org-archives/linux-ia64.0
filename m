From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 17 Sep 2004 21:00:41 +0000
Subject: [PATCH] sn2_defconfig update take 2
Message-Id: <200409171400.41405.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_5B1SBB0Bibg1LhF"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--Boundary-00=_5B1SBB0Bibg1LhF
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Please apply this one instead.  It turns on mmtimer and increases the number 
of sg entries for the LSI driver.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse



--Boundary-00=_5B1SBB0Bibg1LhF
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-defconfig-update-6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update-6.patch"

===== arch/ia64/configs/sn2_defconfig 1.12 vs edited =====
--- 1.12/arch/ia64/configs/sn2_defconfig	2004-09-02 22:46:36 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-09-17 13:58:53 -07:00
@@ -1,7 +1,7 @@
 #
 # Automatically generated make config: don't edit
-# Linux kernel version: 2.6.9-rc1
-# Fri Aug 27 22:00:00 2004
+# Linux kernel version: 2.6.9-rc2
+# Fri Sep 17 13:58:32 2004
 #
 
 #
@@ -13,6 +13,7 @@
 #
 # General setup
 #
+CONFIG_LOCALVERSION=""
 CONFIG_SWAP=y
 CONFIG_SYSVIPC=y
 CONFIG_POSIX_MQUEUE=y
@@ -33,6 +34,8 @@
 CONFIG_IOSCHED_DEADLINE=y
 CONFIG_IOSCHED_CFQ=y
 # CONFIG_CC_OPTIMIZE_FOR_SIZE is not set
+CONFIG_SHMEM=y
+# CONFIG_TINY_SHMEM is not set
 
 #
 # Loadable module support
@@ -54,6 +57,7 @@
 CONFIG_RWSEM_XCHGADD_ALGORITHM=y
 CONFIG_TIME_INTERPOLATION=y
 CONFIG_EFI=y
+CONFIG_GENERIC_IOMAP=y
 # CONFIG_IA64_GENERIC is not set
 # CONFIG_IA64_DIG is not set
 # CONFIG_IA64_HP_ZX1 is not set
@@ -210,7 +214,6 @@
 # CONFIG_BLK_DEV_IDEDMA_FORCED is not set
 CONFIG_IDEDMA_PCI_AUTO=y
 # CONFIG_IDEDMA_ONLYDISK is not set
-CONFIG_BLK_DEV_ADMA=y
 # CONFIG_BLK_DEV_AEC62XX is not set
 # CONFIG_BLK_DEV_ALI15X3 is not set
 # CONFIG_BLK_DEV_AMD74XX is not set
@@ -277,7 +280,8 @@
 # CONFIG_SCSI_AIC7XXX is not set
 # CONFIG_SCSI_AIC7XXX_OLD is not set
 # CONFIG_SCSI_AIC79XX is not set
-# CONFIG_SCSI_MEGARAID is not set
+# CONFIG_MEGARAID_NEWGEN is not set
+# CONFIG_MEGARAID_LEGACY is not set
 CONFIG_SCSI_SATA=y
 # CONFIG_SCSI_SATA_SVW is not set
 # CONFIG_SCSI_ATA_PIIX is not set
@@ -334,8 +338,7 @@
 # Fusion MPT device support
 #
 CONFIG_FUSION=y
-CONFIG_FUSION_MAX_SGE=40
-CONFIG_FUSION_ISENSE=m
+CONFIG_FUSION_MAX_SGE=128
 CONFIG_FUSION_CTL=m
 
 #
@@ -550,7 +553,6 @@
 CONFIG_UNIX98_PTYS=y
 CONFIG_LEGACY_PTYS=y
 CONFIG_LEGACY_PTY_COUNT=256
-# CONFIG_QIC02_TAPE is not set
 
 #
 # IPMI
@@ -575,6 +577,7 @@
 CONFIG_RAW_DRIVER=m
 # CONFIG_HPET is not set
 CONFIG_MAX_RAW_DEVS=256
+CONFIG_MMTIMER=y
 
 #
 # I2C support

--Boundary-00=_5B1SBB0Bibg1LhF--
