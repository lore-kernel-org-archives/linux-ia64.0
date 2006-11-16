From: akpm@osdl.org
Date: Thu, 16 Nov 2006 08:43:12 +0000
Subject: [patch 4/4] ia64: fix allmodconfig build
Message-Id: <200611160843.kAG8hCf3017752@shell0.pdx.osdl.net>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

From: "Luck, Tony" <tony.luck@intel.com>

The HP_SIMSCSI driver can't be built as a module (unhealthy dependencies on
things that shouldn't really be exported).

AMD and nVidia IDE support doesn't sound too useful for ia64 either :-)

With these two patches allmodconfig builds (but takes 11m24s, ouch!)

Signed-off-by: Tony Luck <tony.luck@intel.com>
Cc: Judith Lebzelter <judith@osdl.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 arch/ia64/hp/sim/Kconfig |    4 ++--
 drivers/ide/Kconfig      |    1 +
 2 files changed, 3 insertions(+), 2 deletions(-)

diff -puN arch/ia64/hp/sim/Kconfig~ia64-fix-allmodconfig-build arch/ia64/hp/sim/Kconfig
--- a/arch/ia64/hp/sim/Kconfig~ia64-fix-allmodconfig-build
+++ a/arch/ia64/hp/sim/Kconfig
@@ -13,8 +13,8 @@ config HP_SIMSERIAL_CONSOLE
 	depends on HP_SIMSERIAL
 
 config HP_SIMSCSI
-	tristate "Simulated SCSI disk"
-	depends on SCSI
+	bool "Simulated SCSI disk"
+	depends on SCSI=y
 
 endmenu
 
diff -puN drivers/ide/Kconfig~ia64-fix-allmodconfig-build drivers/ide/Kconfig
--- a/drivers/ide/Kconfig~ia64-fix-allmodconfig-build
+++ a/drivers/ide/Kconfig
@@ -486,6 +486,7 @@ config WDC_ALI15X3
 
 config BLK_DEV_AMD74XX
 	tristate "AMD and nVidia IDE support"
+	depends on X86
 	help
 	  This driver adds explicit support for AMD-7xx and AMD-8111 chips
 	  and also for the nVidia nForce chip.  This allows the kernel to
_
