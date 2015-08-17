From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Date: Mon, 17 Aug 2015 17:13:26 +0000
Subject: [RFT PATCH v2] ia64: generic_defconfig: convert to use libata PATA drivers
Message-Id: <1439831608-8362-2-git-send-email-b.zolnierkie@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439831608-8362-1-git-send-email-b.zolnierkie@samsung.com>
In-Reply-To: <1439831608-8362-1-git-send-email-b.zolnierkie@samsung.com>
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

This patch converts generic_defconfig to use libata PATA
drivers (sgiioc4 IDE host driver has no corresponding libata
driver yet so it is not converted).

Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
---
v2:
- added missing pata_oldpiix host driver (noticed by Sergei Shtylyov)

Build tested only.
If you have affected hardware please test.  Thank you.

 arch/ia64/configs/generic_defconfig | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 81f686d..dddb6bc 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -48,13 +48,10 @@ CONFIG_SGI_IOC4=y
 CONFIG_SGI_XP=m
 CONFIG_IDE=y
 CONFIG_BLK_DEV_IDECD=y
-CONFIG_BLK_DEV_GENERIC=y
-CONFIG_BLK_DEV_CMD64X=y
-CONFIG_BLK_DEV_PIIX=y
 CONFIG_BLK_DEV_SGIIOC4=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_CHR_DEV_ST=m
-CONFIG_BLK_DEV_SR=m
+CONFIG_BLK_DEV_SR=y
 CONFIG_CHR_DEV_SG=m
 CONFIG_SCSI_FC_ATTRS=y
 CONFIG_SCSI_SYM53C8XX_2=y
@@ -62,6 +59,10 @@ CONFIG_SCSI_QLOGIC_1280=y
 CONFIG_ATA=y
 CONFIG_ATA_PIIX=y
 CONFIG_SATA_VITESSE=y
+CONFIG_PATA_CMD64X=y
+CONFIG_PATA_OLDPIIX=y
+CONFIG_PATA_MPIIX=y
+CONFIG_ATA_GENERIC=y
 CONFIG_MD=y
 CONFIG_BLK_DEV_MD=m
 CONFIG_MD_LINEAR=m
-- 
1.9.1

