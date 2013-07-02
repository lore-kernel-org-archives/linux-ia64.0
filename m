From: Bjorn Helgaas <bhelgaas@google.com>
Date: Tue, 02 Jul 2013 18:10:19 +0000
Subject: [PATCH] [IA64] Change CONFIG_HOTPLUG_PCI_ACPI=m to =y
Message-Id: <20130702181019.27983.48289.stgit@bhelgaas-glaptop>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

After 6037a803b0, CONFIG_HOTPLUG_PCI_ACPI is a bool (it's no longer
possible to configure acpiphp as a module).  These defconfig changes
fix some build warnings.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/configs/generic_defconfig   |    2 +-
 arch/ia64/configs/gensparse_defconfig |    2 +-
 arch/ia64/configs/tiger_defconfig     |    2 +-
 arch/ia64/configs/xen_domu_defconfig  |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 7913695..a4bd0ef 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -32,7 +32,7 @@ CONFIG_ACPI_DOCK=y
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
 CONFIG_HOTPLUG_PCI=m
-CONFIG_HOTPLUG_PCI_ACPI=m
+CONFIG_HOTPLUG_PCI_ACPI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index f8e9133..5e5f074 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -26,7 +26,7 @@ CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
 CONFIG_HOTPLUG_PCI=m
-CONFIG_HOTPLUG_PCI_ACPI=m
+CONFIG_HOTPLUG_PCI_ACPI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index a5a9e02..7049c3d 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -32,7 +32,7 @@ CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
 CONFIG_HOTPLUG_PCI=m
-CONFIG_HOTPLUG_PCI_ACPI=m
+CONFIG_HOTPLUG_PCI_ACPI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y
diff --git a/arch/ia64/configs/xen_domu_defconfig b/arch/ia64/configs/xen_domu_defconfig
index 37b9b42..7dc6ed7 100644
--- a/arch/ia64/configs/xen_domu_defconfig
+++ b/arch/ia64/configs/xen_domu_defconfig
@@ -33,7 +33,7 @@ CONFIG_ACPI_FAN=m
 CONFIG_ACPI_PROCESSOR=m
 CONFIG_ACPI_CONTAINER=m
 CONFIG_HOTPLUG_PCI=m
-CONFIG_HOTPLUG_PCI_ACPI=m
+CONFIG_HOTPLUG_PCI_ACPI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y

