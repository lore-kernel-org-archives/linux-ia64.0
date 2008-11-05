From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Wed, 05 Nov 2008 19:32:43 +0000
Subject: [patch] ia64: reorder Kconfig options to match x86
Message-Id: <200811051232.43598.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No functional change, just reorder some config options to match
the defacto x86 standard.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
---
 arch/ia64/Kconfig |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 27eec71..08559ee 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
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
