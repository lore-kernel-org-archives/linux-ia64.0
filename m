From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Tue, 24 Aug 2004 22:21:47 +0000
Subject: [PATCH] enable common FAT NLS options in generic_defconfig
Message-Id: <200408241521.47602.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_797KB3vYtvnuzoP"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_797KB3vYtvnuzoP
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

VFAT filesystems need to have codepages and iocharsets specified these days, 
so build some into the kernel to make it easier to mount /boot/efi on ia64 
systems.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_797KB3vYtvnuzoP
Content-Type: text/plain;
  charset="us-ascii";
  name="generic-defconfig-update-4.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="generic-defconfig-update-4.patch"

===== arch/ia64/configs/generic_defconfig 1.9 vs edited =====
--- 1.9/arch/ia64/configs/generic_defconfig	2004-08-23 01:15:10 -07:00
+++ edited/arch/ia64/configs/generic_defconfig	2004-08-24 15:08:33 -07:00
@@ -1,5 +1,7 @@
 #
 # Automatically generated make config: don't edit
+# Linux kernel version: 2.6.9-rc1
+# Tue Aug 24 15:08:24 2004
 #
 
 #
@@ -126,6 +128,7 @@
 CONFIG_HOTPLUG_PCI=m
 # CONFIG_HOTPLUG_PCI_FAKE is not set
 CONFIG_HOTPLUG_PCI_ACPI=m
+# CONFIG_HOTPLUG_PCI_ACPI_IBM is not set
 # CONFIG_HOTPLUG_PCI_CPCI is not set
 # CONFIG_HOTPLUG_PCI_PCIE is not set
 # CONFIG_HOTPLUG_PCI_SHPC is not set
@@ -172,6 +175,7 @@
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 # CONFIG_BLK_DEV_SX8 is not set
+# CONFIG_BLK_DEV_UB is not set
 CONFIG_BLK_DEV_RAM=m
 CONFIG_BLK_DEV_RAM_SIZE=4096
 
@@ -313,6 +317,7 @@
 CONFIG_MD_LINEAR=m
 CONFIG_MD_RAID0=m
 CONFIG_MD_RAID1=m
+# CONFIG_MD_RAID10 is not set
 CONFIG_MD_RAID5=m
 CONFIG_MD_RAID6=m
 CONFIG_MD_MULTIPATH=m
@@ -365,6 +370,7 @@
 # CONFIG_INET_AH is not set
 # CONFIG_INET_ESP is not set
 # CONFIG_INET_IPCOMP is not set
+# CONFIG_INET_TUNNEL is not set
 # CONFIG_IPV6 is not set
 # CONFIG_NETFILTER is not set
 
@@ -767,6 +773,7 @@
 CONFIG_USB_DEVICEFS=y
 # CONFIG_USB_BANDWIDTH is not set
 # CONFIG_USB_DYNAMIC_MINORS is not set
+# CONFIG_USB_SUSPEND is not set
 
 #
 # USB Host Controller Drivers
@@ -919,6 +926,8 @@
 CONFIG_FAT_FS=y
 # CONFIG_MSDOS_FS is not set
 CONFIG_VFAT_FS=y
+CONFIG_FAT_DEFAULT_CODEPAGE=437
+CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
 CONFIG_NTFS_FS=m
 # CONFIG_NTFS_DEBUG is not set
 # CONFIG_NTFS_RW is not set
@@ -946,7 +955,6 @@
 # CONFIG_BEFS_FS is not set
 # CONFIG_BFS_FS is not set
 # CONFIG_EFS_FS is not set
-# CONFIG_JFFS2_COMPRESSION_OPTIONS is not set
 # CONFIG_CRAMFS is not set
 # CONFIG_VXFS_FS is not set
 # CONFIG_HPFS_FS is not set
@@ -971,6 +979,7 @@
 CONFIG_SUNRPC=m
 CONFIG_SUNRPC_GSS=m
 CONFIG_RPCSEC_GSS_KRB5=m
+# CONFIG_RPCSEC_GSS_SPKM3 is not set
 CONFIG_SMB_FS=m
 CONFIG_SMB_NLS_DEFAULT=y
 CONFIG_SMB_NLS_REMOTE="cp437"
@@ -1007,7 +1016,7 @@
 #
 CONFIG_NLS=y
 CONFIG_NLS_DEFAULT="iso8859-1"
-CONFIG_NLS_CODEPAGE_437=m
+CONFIG_NLS_CODEPAGE_437=y
 CONFIG_NLS_CODEPAGE_737=m
 CONFIG_NLS_CODEPAGE_775=m
 CONFIG_NLS_CODEPAGE_850=m
@@ -1031,7 +1040,7 @@
 CONFIG_NLS_CODEPAGE_1250=m
 CONFIG_NLS_CODEPAGE_1251=m
 # CONFIG_NLS_ASCII is not set
-CONFIG_NLS_ISO8859_1=m
+CONFIG_NLS_ISO8859_1=y
 CONFIG_NLS_ISO8859_2=m
 CONFIG_NLS_ISO8859_3=m
 CONFIG_NLS_ISO8859_4=m
@@ -1068,18 +1077,18 @@
 #
 # Kernel hacking
 #
-CONFIG_IA64_GRANULE_16MB=y
-# CONFIG_IA64_GRANULE_64MB is not set
 CONFIG_DEBUG_KERNEL=y
-# CONFIG_IA64_PRINT_HAZARDS is not set
-# CONFIG_DISABLE_VHPT is not set
 CONFIG_MAGIC_SYSRQ=y
 # CONFIG_DEBUG_SLAB is not set
 # CONFIG_DEBUG_SPINLOCK is not set
 # CONFIG_DEBUG_SPINLOCK_SLEEP is not set
+# CONFIG_DEBUG_INFO is not set
+CONFIG_IA64_GRANULE_16MB=y
+# CONFIG_IA64_GRANULE_64MB is not set
+# CONFIG_IA64_PRINT_HAZARDS is not set
+# CONFIG_DISABLE_VHPT is not set
 # CONFIG_IA64_DEBUG_CMPXCHG is not set
 # CONFIG_IA64_DEBUG_IRQ is not set
-# CONFIG_DEBUG_INFO is not set
 CONFIG_SYSVIPC_COMPAT=y
 
 #
@@ -1102,11 +1111,12 @@
 # CONFIG_CRYPTO_BLOWFISH is not set
 # CONFIG_CRYPTO_TWOFISH is not set
 # CONFIG_CRYPTO_SERPENT is not set
-# CONFIG_CRYPTO_AES_GENERIC is not set
+# CONFIG_CRYPTO_AES is not set
 # CONFIG_CRYPTO_CAST5 is not set
 # CONFIG_CRYPTO_CAST6 is not set
 # CONFIG_CRYPTO_TEA is not set
 # CONFIG_CRYPTO_ARC4 is not set
+# CONFIG_CRYPTO_KHAZAD is not set
 # CONFIG_CRYPTO_DEFLATE is not set
 # CONFIG_CRYPTO_MICHAEL_MIC is not set
 # CONFIG_CRYPTO_CRC32C is not set

--Boundary-00=_797KB3vYtvnuzoP--
