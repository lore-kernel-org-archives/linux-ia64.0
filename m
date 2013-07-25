From: Bjorn Helgaas <bhelgaas@google.com>
Date: Thu, 25 Jul 2013 17:57:20 +0000
Subject: [PATCH 1/2] PCI: hotplug: Convert to be builtin only, not modular
Message-Id: <20130725175720.6006.96448.stgit@bhelgaas-glaptop>
List-Id: <linux-ia64.vger.kernel.org>
References: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
In-Reply-To: <20130725175242.6006.56007.stgit@bhelgaas-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: Fenghua Yu <fenghua.yu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Paul Mundt <lethal@linux-sh.org>, Paul Mackerras <paulus@samba.org>, Yinghai Lu <yinghai@kernel.org>, linuxppc-dev@lists.ozlabs.org

Convert CONFIG_HOTPLUG_PCI from tristate to bool.  This only affects
the hotplug core; several of the hotplug drivers can still be modules.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/configs/generic_defconfig    |    2 +-
 arch/ia64/configs/gensparse_defconfig  |    2 +-
 arch/ia64/configs/tiger_defconfig      |    2 +-
 arch/ia64/configs/xen_domu_defconfig   |    2 +-
 arch/powerpc/configs/ppc64_defconfig   |    2 +-
 arch/powerpc/configs/ppc64e_defconfig  |    2 +-
 arch/powerpc/configs/pseries_defconfig |    2 +-
 arch/sh/configs/sh03_defconfig         |    2 +-
 drivers/pci/hotplug/Kconfig            |    5 +----
 9 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 7913695..efbd292 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -31,7 +31,7 @@ CONFIG_ACPI_FAN=m
 CONFIG_ACPI_DOCK=y
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_ACPI=m
 CONFIG_PACKET=y
 CONFIG_UNIX=y
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index f8e9133..f64980d 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -25,7 +25,7 @@ CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_ACPI=m
 CONFIG_PACKET=y
 CONFIG_UNIX=y
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index a5a9e02..0f4e9e4 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -31,7 +31,7 @@ CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_ACPI=m
 CONFIG_PACKET=y
 CONFIG_UNIX=y
diff --git a/arch/ia64/configs/xen_domu_defconfig b/arch/ia64/configs/xen_domu_defconfig
index 37b9b42..b025acf 100644
--- a/arch/ia64/configs/xen_domu_defconfig
+++ b/arch/ia64/configs/xen_domu_defconfig
@@ -32,7 +32,7 @@ CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_ACPI=m
 CONFIG_PACKET=y
 CONFIG_UNIX=y
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index c86fcb9..0e8cfd0 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -58,7 +58,7 @@ CONFIG_SCHED_SMT=y
 CONFIG_PPC_DENORMALISATION=y
 CONFIG_PCCARD=y
 CONFIG_ELECTRA_CF=y
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_RPA=m
 CONFIG_HOTPLUG_PCI_RPA_DLPAR=m
 CONFIG_PACKET=y
diff --git a/arch/powerpc/configs/ppc64e_defconfig b/arch/powerpc/configs/ppc64e_defconfig
index 4b20f76..0085dc4 100644
--- a/arch/powerpc/configs/ppc64e_defconfig
+++ b/arch/powerpc/configs/ppc64e_defconfig
@@ -32,7 +32,7 @@ CONFIG_IRQ_ALL_CPUS=y
 CONFIG_SPARSEMEM_MANUAL=y
 CONFIG_PCI_MSI=y
 CONFIG_PCCARD=y
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_XFRM_USER=m
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index bea8587..1d4b976 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -53,7 +53,7 @@ CONFIG_PPC_64K_PAGES=y
 CONFIG_PPC_SUBPAGE_PROT=y
 CONFIG_SCHED_SMT=y
 CONFIG_PPC_DENORMALISATION=y
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_HOTPLUG_PCI_RPA=m
 CONFIG_HOTPLUG_PCI_RPA_DLPAR=m
 CONFIG_PACKET=y
diff --git a/arch/sh/configs/sh03_defconfig b/arch/sh/configs/sh03_defconfig
index 2051821..0cf4097 100644
--- a/arch/sh/configs/sh03_defconfig
+++ b/arch/sh/configs/sh03_defconfig
@@ -22,7 +22,7 @@ CONFIG_PREEMPT=y
 CONFIG_CMDLINE_OVERWRITE=y
 CONFIG_CMDLINE="console=ttySC1,115200 memdM root=/dev/nfs"
 CONFIG_PCI=y
-CONFIG_HOTPLUG_PCI=m
+CONFIG_HOTPLUG_PCI=y
 CONFIG_BINFMT_MISC=y
 CONFIG_NET=y
 CONFIG_PACKET=y
diff --git a/drivers/pci/hotplug/Kconfig b/drivers/pci/hotplug/Kconfig
index bb7ebb2..d85009d 100644
--- a/drivers/pci/hotplug/Kconfig
+++ b/drivers/pci/hotplug/Kconfig
@@ -3,16 +3,13 @@
 #
 
 menuconfig HOTPLUG_PCI
-	tristate "Support for PCI Hotplug"
+	bool "Support for PCI Hotplug"
 	depends on PCI && SYSFS
 	---help---
 	  Say Y here if you have a motherboard with a PCI Hotplug controller.
 	  This allows you to add and remove PCI cards while the machine is
 	  powered up and running.
 
-	  To compile this driver as a module, choose M here: the
-	  module will be called pci_hotplug.
-
 	  When in doubt, say N.
 
 if HOTPLUG_PCI

