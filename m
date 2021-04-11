From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 11 Apr 2021 02:02:55 +0000
Subject: [PATCH RESENDbis] ia64: remove duplicate entries in generic_defconfig
Message-Id: <20210411020255.18052-1-rdunlap@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org

Fix ia64 generic_defconfig duplicate entries, as warned by:

  + arch/ia64/configs/generic_defconfig: warning: override: reassigning to symbol ATA:  => 58
  + arch/ia64/configs/generic_defconfig: warning: override: reassigning to symbol ATA_PIIX:  => 59

These 2 symbols still have the same value as in the removed lines.

Fixes: c331649e6371 ("ia64: Use libata instead of the legacy ide driver in defconfigs")
Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Tony Luck <tony.luck@intel.com>
Cc: linux-ia64@vger.kernel.org
Reviewed-by: Christoph Hellwig <hch@lst.de>
#Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 arch/ia64/configs/generic_defconfig |    2 --
 1 file changed, 2 deletions(-)

--- lnx-511-rc1.orig/arch/ia64/configs/generic_defconfig
+++ lnx-511-rc1/arch/ia64/configs/generic_defconfig
@@ -55,8 +55,6 @@ CONFIG_CHR_DEV_SG=m
 CONFIG_SCSI_FC_ATTRS=y
 CONFIG_SCSI_SYM53C8XX_2=y
 CONFIG_SCSI_QLOGIC_1280=y
-CONFIG_ATA=y
-CONFIG_ATA_PIIX=y
 CONFIG_SATA_VITESSE=y
 CONFIG_MD=y
 CONFIG_BLK_DEV_MD=m
