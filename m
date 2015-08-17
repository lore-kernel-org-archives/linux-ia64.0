From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Date: Mon, 17 Aug 2015 15:46:24 +0000
Subject: [RFT PATCH] ia64: bigsur_defconfig: convert to use libata PATA drivers
Message-Id: <1439826388-31456-1-git-send-email-b.zolnierkie@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, b.zolnierkie@samsung.com

IDE subsystem has been deprecated since 2009 and the majority
(if not all) of Linux distributions have switched to use
libata for ATA support exclusively.  However there are still
some users (mostly old or/and embedded non-x86 systems) that
have not converted from using IDE subsystem to libata PATA
drivers.  This doesn't seem to be good thing in the long-term
for Linux as while there is less and less PATA systems left
in use:

* testing efforts are divided between two subsystems

* having duplicate drivers for same hardware confuses users

This patch converts bigsur_defconfig to use libata PATA
drivers.

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
---
Build tested only.
If you have affected hardware please test.  Thank you.

 arch/ia64/configs/bigsur_defconfig | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/configs/bigsur_defconfig b/arch/ia64/configs/bigsur_defconfig
index b6bda18..5aba1aa 100644
--- a/arch/ia64/configs/bigsur_defconfig
+++ b/arch/ia64/configs/bigsur_defconfig
@@ -28,16 +28,17 @@ CONFIG_BLK_DEV_LOOP=m
 CONFIG_BLK_DEV_CRYPTOLOOP=m
 CONFIG_BLK_DEV_NBD=m
 CONFIG_BLK_DEV_RAM=m
-CONFIG_IDE=m
-CONFIG_BLK_DEV_IDECD=m
-CONFIG_BLK_DEV_GENERIC=m
-CONFIG_BLK_DEV_PIIX=m
 CONFIG_SCSI=y
 CONFIG_BLK_DEV_SD=y
+CONFIG_BLK_DEV_SR=m
 CONFIG_SCSI_CONSTANTS=y
 CONFIG_SCSI_LOGGING=y
 CONFIG_SCSI_SPI_ATTRS=m
 CONFIG_SCSI_QLOGIC_1280=y
+CONFIG_ATA=m
+CONFIG_ATA_PIIX=m
+CONFIG_PATA_MPIIX=m
+CONFIG_ATA_GENERIC=m
 CONFIG_MD=y
 CONFIG_BLK_DEV_MD=m
 CONFIG_MD_LINEAR=m
-- 
1.9.1

