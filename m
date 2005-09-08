From: Martin Hicks <mort@sgi.com>
Date: Thu, 08 Sep 2005 15:28:11 +0000
Subject: [PATCH] defconfig: turn off QLOGIC_FC
Message-Id: <20050908152811.GD13449@localhost>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Turn off the QLOGIC_FC driver.  Supposedly qla2xxx should support
these devices.  Do any ia64 machines have one of these devices as
the boot device?

Signed-off-by: Martin Hicks <mort@sgi.com>

---
commit f110e050ed0b477d1cb142cc3b5fd058192264a3
tree 9bb2e8e5af5860c171bc72ee6c8c6554ff532fa0
parent 903e959b898dbd8d89b66a30d4399df27e4549d7
author Martin Hicks <mort@sgi.com> Mon, 29 Aug 2005 08:05:10 -0700
committer Martin Hicks <mort@sgi.com> Mon, 29 Aug 2005 08:05:10 -0700

 arch/ia64/defconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/arch/ia64/defconfig b/arch/ia64/defconfig
--- a/arch/ia64/defconfig
+++ b/arch/ia64/defconfig
@@ -341,7 +341,7 @@ CONFIG_SCSI_SYM53C8XX_DEFAULT_TAGS
 CONFIG_SCSI_SYM53C8XX_MAX_TAGSd
 # CONFIG_SCSI_SYM53C8XX_IOMAPPED is not set
 # CONFIG_SCSI_IPR is not set
-CONFIG_SCSI_QLOGIC_FC=y
+# CONFIG_SCSI_QLOGIC_FC is not set
 # CONFIG_SCSI_QLOGIC_FC_FIRMWARE is not set
 CONFIG_SCSI_QLOGIC_1280=y
 # CONFIG_SCSI_QLOGIC_1280_1040 is not set
