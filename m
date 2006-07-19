From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 19 Jul 2006 22:30:53 +0000
Subject: [PATCH] sgiioc4: Always share IRQ
Message-Id: <20060719172618.N56117@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: linux-ide@vger.kernel.org, linux-ia64@vger.kernel.org, Jeremy Higdon <jeremy@sgi.com>, Jes Sorensen <jes@sgi.com>, tony.luck@intel.com

The SGI IOC4 IDE device always shares an interrupt with other devices
which are part of IOC4.  As such, IDEPCI_SHARE_IRQ should always be
enabled when BLK_DEV_SGIIOC4 is enabled.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>
---
 arch/ia64/configs/sn2_defconfig |    2 +-
 arch/ia64/defconfig             |    2 +-
 drivers/ide/Kconfig             |    1 +
 3 files changed, 3 insertions(+), 2 deletions(-)
---
diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 9ea3539..0f14a82 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -363,7 +363,7 @@ # IDE chipset support/bugfixes
 #
 CONFIG_IDE_GENERIC=y
 CONFIG_BLK_DEV_IDEPCI=y
-# CONFIG_IDEPCI_SHARE_IRQ is not set
+CONFIG_IDEPCI_SHARE_IRQ=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
 # CONFIG_BLK_DEV_GENERIC is not set
 # CONFIG_BLK_DEV_OPTI621 is not set
diff --git a/arch/ia64/defconfig b/arch/ia64/defconfig
index 6cba55d..9001b3f 100644
--- a/arch/ia64/defconfig
+++ b/arch/ia64/defconfig
@@ -366,7 +366,7 @@ #
 # CONFIG_IDE_GENERIC is not set
 # CONFIG_BLK_DEV_IDEPNP is not set
 CONFIG_BLK_DEV_IDEPCI=y
-# CONFIG_IDEPCI_SHARE_IRQ is not set
+CONFIG_IDEPCI_SHARE_IRQ=y
 # CONFIG_BLK_DEV_OFFBOARD is not set
 CONFIG_BLK_DEV_GENERIC=y
 # CONFIG_BLK_DEV_OPTI621 is not set
diff --git a/drivers/ide/Kconfig b/drivers/ide/Kconfig
index d1266fe..556958e 100644
--- a/drivers/ide/Kconfig
+++ b/drivers/ide/Kconfig
@@ -682,6 +682,7 @@ config BLK_DEV_SVWKS
 config BLK_DEV_SGIIOC4
 	tristate "Silicon Graphics IOC4 chipset ATA/ATAPI support"
 	depends on (IA64_SGI_SN2 || IA64_GENERIC) && SGI_IOC4
+	select IDEPCI_SHARE_IRQ
 	help
 	  This driver adds PIO & MultiMode DMA-2 support for the SGI IOC4
 	  chipset, which has one channel and can support two devices.
