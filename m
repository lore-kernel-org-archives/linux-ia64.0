From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Thu, 05 Aug 2004 23:27:13 +0000
Subject: [PATCH] sn2_defconfig update
Message-Id: <200408051627.13034.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_RJsEBmKQ2dBs051"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_RJsEBmKQ2dBs051
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Update a few things in sn2_defconfig, including enabling preemption (Andrew 
asked for more testing of this feature) and CPU hotplug support (which 
appears to work enough for me to up and down CPUs at least).

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_RJsEBmKQ2dBs051
Content-Type: text/plain;
  charset="us-ascii";
  name="sn2-defconfig-update-3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn2-defconfig-update-3.patch"

===== arch/ia64/configs/sn2_defconfig 1.9 vs edited =====
--- 1.9/arch/ia64/configs/sn2_defconfig	2004-07-18 13:14:30 -07:00
+++ edited/arch/ia64/configs/sn2_defconfig	2004-08-05 15:35:56 -07:00
@@ -7,7 +7,6 @@
 #
 CONFIG_EXPERIMENTAL=y
 CONFIG_CLEAN_COMPILE=y
-CONFIG_STANDALONE=y
 
 #
 # General setup
@@ -74,8 +73,8 @@
 CONFIG_FORCE_MAX_ZONEORDER=18
 CONFIG_SMP=y
 CONFIG_NR_CPUS=512
-# CONFIG_HOTPLUG_CPU is not set
-# CONFIG_PREEMPT is not set
+CONFIG_HOTPLUG_CPU=y
+CONFIG_PREEMPT=y
 CONFIG_HAVE_DEC_LOCK=y
 CONFIG_IA32_SUPPORT=y
 CONFIG_COMPAT=y
@@ -88,7 +87,7 @@
 CONFIG_EFI_VARS=y
 # CONFIG_EFI_PCDP is not set
 CONFIG_BINFMT_ELF=y
-# CONFIG_BINFMT_MISC is not set
+CONFIG_BINFMT_MISC=m
 
 #
 # Power management and ACPI
@@ -115,7 +114,7 @@
 #
 CONFIG_PCI=y
 CONFIG_PCI_DOMAINS=y
-# CONFIG_PCI_USE_VECTOR is not set
+# CONFIG_PCI_MSI is not set
 CONFIG_PCI_LEGACY_PROC=y
 CONFIG_PCI_NAMES=y
 
@@ -142,6 +141,7 @@
 #
 # Generic Driver Options
 #
+CONFIG_STANDALONE=y
 CONFIG_PREVENT_FIRMWARE_BUILD=y
 CONFIG_FW_LOADER=m
 # CONFIG_DEBUG_DRIVER is not set
@@ -317,13 +317,13 @@
 CONFIG_MD_RAID0=y
 CONFIG_MD_RAID1=y
 CONFIG_MD_RAID5=y
-# CONFIG_MD_RAID6 is not set
+CONFIG_MD_RAID6=y
 CONFIG_MD_MULTIPATH=y
 CONFIG_BLK_DEV_DM=y
 CONFIG_DM_CRYPT=m
-CONFIG_DM_SNAPSHOT=m
-CONFIG_DM_MIRROR=m
-CONFIG_DM_ZERO=m
+CONFIG_DM_SNAPSHOT=y
+CONFIG_DM_MIRROR=y
+CONFIG_DM_ZERO=y
 
 #
 # Fusion MPT device support
@@ -765,8 +765,6 @@
 CONFIG_FAT_FS=y
 # CONFIG_MSDOS_FS is not set
 CONFIG_VFAT_FS=y
-CONFIG_FAT_DEFAULT_CODEPAGE=437
-CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 # CONFIG_NTFS_FS is not set
 
 #
@@ -821,6 +819,7 @@
 # CONFIG_SMB_NLS_DEFAULT is not set
 CONFIG_CIFS=m
 # CONFIG_CIFS_STATS is not set
+# CONFIG_CIFS_XATTR is not set
 # CONFIG_CIFS_POSIX is not set
 # CONFIG_NCP_FS is not set
 # CONFIG_CODA_FS is not set

--Boundary-00=_RJsEBmKQ2dBs051--
