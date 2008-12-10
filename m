From: Brent Casavant <bcasavan@sgi.com>
Date: Wed, 10 Dec 2008 15:46:16 +0000
Subject: [PATCH] generic_defconfig: Enable SATA_VITESSE
Message-Id: <alpine.BSF.1.10.0812100942580.16859@pkunk.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

CONFIG_SATA_VITESSE=y was not added to generic_defconfig when
sn2_defconfig was removed.  SGI Altix systems that use an IO10
base IO card to drive the root device are unable to boot without
the Vitesse controller.

Signed-off-by: Brent Casavant <bcasavan@sgi.com>
Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Jes Sorensen <jes@sgi.com>
---
 generic_defconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index e05f9e1..c7384b2 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -580,7 +580,7 @@ CONFIG_ATA_PIIX=y
 # CONFIG_SATA_SIS is not set
 # CONFIG_SATA_ULI is not set
 # CONFIG_SATA_VIA is not set
-# CONFIG_SATA_VITESSE is not set
+CONFIG_SATA_VITESSE=y
 # CONFIG_SATA_INIC162X is not set
 # CONFIG_PATA_ACPI is not set
 # CONFIG_PATA_ALI is not set

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
