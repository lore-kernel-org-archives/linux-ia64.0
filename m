From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Thu, 06 Nov 2008 16:53:54 +0000
Subject: [patch v2] ia64: reorder Kconfig options to match x86
Message-Id: <200811060953.54739.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No functional change, just reorder some config options and update
the "Power management and ACPI" label to match the defacto x86
standard.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 27eec71..aec2b93 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -585,7 +585,7 @@ source "fs/Kconfig.binfmt"
 
 endmenu
 
-menu "Power management and ACPI"
+menu "Power management and ACPI options"
 
 source "kernel/power/Kconfig"
 
@@ -641,6 +641,8 @@ source "net/Kconfig"
 
 source "drivers/Kconfig"
 
+source "arch/ia64/hp/sim/Kconfig"
+
 config MSPEC
 	tristate "Memory special operations driver"
 	depends on IA64
@@ -652,6 +654,12 @@ config MSPEC
 
 source "fs/Kconfig"
 
+source "arch/ia64/Kconfig.debug"
+
+source "security/Kconfig"
+
+source "crypto/Kconfig"
+
 source "arch/ia64/kvm/Kconfig"
 
 source "lib/Kconfig"
@@ -678,11 +686,3 @@ config IRQ_PER_CPU
 
 config IOMMU_HELPER
 	def_bool (IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_GENERIC || SWIOTLB)
-
-source "arch/ia64/hp/sim/Kconfig"
-
-source "arch/ia64/Kconfig.debug"
-
-source "security/Kconfig"
-
-source "crypto/Kconfig"
