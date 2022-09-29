From: Lukas Bulwahn <lukas.bulwahn@gmail.com>
Date: Thu, 29 Sep 2022 10:14:41 +0000
Subject: [PATCH] ia64: update config files
Message-Id: <20220929101441.32009-1-lukas.bulwahn@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org
Cc: Lukas Bulwahn <lukas.bulwahn@gmail.com>

Clean up config files by:
  - removing configs that were deleted in the past
  - removing configs not in tree and without recently pending patches
  - adding new configs that are replacements for old configs in the file

For some detailed information, see Link.

Link: https://lore.kernel.org/kernel-janitors/20220929090645.1389-1-lukas.bulwahn@gmail.com/

Signed-off-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
---
 arch/ia64/configs/bigsur_defconfig    | 2 --
 arch/ia64/configs/generic_defconfig   | 2 --
 arch/ia64/configs/gensparse_defconfig | 3 ---
 arch/ia64/configs/tiger_defconfig     | 2 --
 arch/ia64/configs/zx1_defconfig       | 1 -
 5 files changed, 10 deletions(-)

diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index a3724882295c..3e1337aceb37 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -20,7 +20,6 @@ CONFIG_UNIX=y
 CONFIG_INET=y
 # CONFIG_IPV6 is not set
 CONFIG_BLK_DEV_LOOP=m
-CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=m
 CONFIG_ATA=m
@@ -91,7 +90,6 @@ CONFIG_NFS_V4=m
 CONFIG_NFSD=m
 CONFIG_NFSD_V4=y
 CONFIG_CIFS=m
-CONFIG_CIFS_STATS=y
 CONFIG_CIFS_XATTR=y
 CONFIG_CIFS_POSIX=y
 CONFIG_NLS_CODEPAGE_437=y
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index a3dff482a3d7..f8033bacea89 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -39,7 +39,6 @@ CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
 CONFIG_CONNECTOR=y
 # CONFIG_PNP_DEBUG_MESSAGES is not set
 CONFIG_BLK_DEV_LOOP=m
-CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
 CONFIG_SGI_XP=m
@@ -91,7 +90,6 @@ CONFIG_SERIAL_8250_SHARE_IRQ=y
 # CONFIG_HW_RANDOM is not set
 CONFIG_RTC_CLASS=y
 CONFIG_RTC_DRV_EFI=y
-CONFIG_RAW_DRIVER=m
 CONFIG_HPET=y
 CONFIG_AGP=m
 CONFIG_AGP_I460=m
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index 4cd46105b020..ffebe6c503f5 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -31,11 +31,9 @@ CONFIG_IP_MULTICAST=y
 CONFIG_SYN_COOKIES=y
 # CONFIG_IPV6 is not set
 CONFIG_BLK_DEV_LOOP=m
-CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
 CONFIG_ATA=y
-CONFIG_BLK_DEV_IDECD=y
 CONFIG_ATA_GENERIC=y
 CONFIG_PATA_CMD64X=y
 CONFIG_ATA_PIIX=y
@@ -81,7 +79,6 @@ CONFIG_SERIAL_8250_SHARE_IRQ=y
 # CONFIG_HW_RANDOM is not set
 CONFIG_RTC_CLASS=y
 CONFIG_RTC_DRV_EFI=y
-CONFIG_RAW_DRIVER=m
 CONFIG_HPET=y
 CONFIG_AGP=m
 CONFIG_AGP_I460=m
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index a2045d73adfa..45f5d6e2da0a 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -36,7 +36,6 @@ CONFIG_IP_MULTICAST=y
 CONFIG_SYN_COOKIES=y
 # CONFIG_IPV6 is not set
 CONFIG_BLK_DEV_LOOP=m
-CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
 CONFIG_ATA=y
@@ -85,7 +84,6 @@ CONFIG_SERIAL_8250_SHARE_IRQ=y
 # CONFIG_HW_RANDOM is not set
 CONFIG_RTC_CLASS=y
 CONFIG_RTC_DRV_EFI=y
-CONFIG_RAW_DRIVER=m
 CONFIG_HPET=y
 CONFIG_AGP=m
 CONFIG_AGP_I460=m
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 99f8b2a0332b..ed104550d0d5 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -30,7 +30,6 @@ CONFIG_PATA_CMD64X=y
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=y
-CONFIG_CHR_DEV_OSST=y
 CONFIG_BLK_DEV_SR=y
 CONFIG_CHR_DEV_SG=y
 CONFIG_SCSI_CONSTANTS=y
-- 
2.17.1
