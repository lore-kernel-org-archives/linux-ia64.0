From: Christoph Hellwig <hch@lst.de>
Date: Fri, 11 Sep 2020 09:49:36 +0000
Subject: [PATCH] ia64: use libata instead of the legacy ide driver in defconfigs
Message-Id: <20200911094936.1175688-1-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com, fenghua.yu@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Switch the ia64 defconfigs to use the modern libata driver instead of
the soon to be removed legacy ide driver.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/configs/bigsur_defconfig    | 7 +++----
 arch/ia64/configs/generic_defconfig   | 9 ++++-----
 arch/ia64/configs/gensparse_defconfig | 9 ++++-----
 arch/ia64/configs/tiger_defconfig     | 9 ++++-----
 arch/ia64/configs/zx1_defconfig       | 7 +++----
 5 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index 2ae6d9a32a8d81..cfed5ed8930114 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -26,10 +26,9 @@ CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=m
-CONFIG_IDE=m
-CONFIG_BLK_DEV_IDECD=m
-CONFIG_BLK_DEV_GENERIC=m
-CONFIG_BLK_DEV_PIIX=m
+CONFIG_ATA=m
+CONFIG_ATA_GENERIC=m
+CONFIG_ATA_PIIX=m
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_SCSI_CONSTANTS=y
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 19a0809cbacca1..ca0d596c800d80 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -44,11 +44,10 @@ CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
 CONFIG_SGI_XP=m
-CONFIG_IDE=y
-CONFIG_BLK_DEV_IDECD=y
-CONFIG_BLK_DEV_GENERIC=y
-CONFIG_BLK_DEV_CMD64X=y
-CONFIG_BLK_DEV_PIIX=y
+CONFIG_ATA=y
+CONFIG_ATA_GENERIC=y
+CONFIG_PATA_CMD64X=y
+CONFIG_ATA_PIIX=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=m
 CONFIG_BLK_DEV_SR=m
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index 69322bf27aa39d..281eb9c544f9ce 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -35,12 +35,11 @@ CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
-CONFIG_IDE=y
+CONFIG_ATA=y
 CONFIG_BLK_DEV_IDECD=y
-CONFIG_IDE_GENERIC=y
-CONFIG_BLK_DEV_GENERIC=y
-CONFIG_BLK_DEV_CMD64X=y
-CONFIG_BLK_DEV_PIIX=y
+CONFIG_ATA_GENERIC=y
+CONFIG_PATA_CMD64X=y
+CONFIG_ATA_PIIX=y
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=m
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index bb510e9cc2f51d..b4f9819a1a45d6 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -40,11 +40,10 @@ CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=y
-CONFIG_IDE=y
-CONFIG_BLK_DEV_IDECD=y
-CONFIG_BLK_DEV_GENERIC=y
-CONFIG_BLK_DEV_CMD64X=y
-CONFIG_BLK_DEV_PIIX=y
+CONFIG_ATA=y
+CONFIG_ATA_GENERIC=y
+CONFIG_PATA_CMD64X=y
+CONFIG_ATA_PIIX=y
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=m
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index b43acc97854148..629cb9cdf723b3 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -25,10 +25,9 @@ CONFIG_IP_MULTICAST=y
 CONFIG_NETFILTER=y
 CONFIG_BLK_DEV_LOOP=y
 CONFIG_BLK_DEV_RAM=y
-CONFIG_IDE=y
-CONFIG_BLK_DEV_IDECD=y
-CONFIG_BLK_DEV_GENERIC=y
-CONFIG_BLK_DEV_CMD64X=y
+CONFIG_ATA=y
+CONFIG_ATA_GENERIC=y
+CONFIG_PATA_CMD64X=y
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=y
-- 
2.28.0
