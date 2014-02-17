From: Jiang Liu <jiang.liu@linux.intel.com>
Date: Mon, 17 Feb 2014 05:59:30 +0000
Subject: [PATCH] IA64: fix warning in make defconfig
Message-Id: <1392616774-8620-1-git-send-email-jiang.liu@linux.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Now the ACPI container and ACPI PCI hotplug driver has been converted
as built-in modules, so reflect these changes in IA64 defconfig file.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 arch/ia64/configs/generic_defconfig |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index efbd292..6404acb 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -30,9 +30,9 @@ CONFIG_ACPI_BUTTON=m
 CONFIG_ACPI_FAN=m
 CONFIG_ACPI_DOCK=y
 CONFIG_ACPI_PROCESSOR=m
-CONFIG_ACPI_CONTAINER=m
+CONFIG_ACPI_CONTAINER=y
 CONFIG_HOTPLUG_PCI=y
-CONFIG_HOTPLUG_PCI_ACPI=m
+CONFIG_HOTPLUG_PCI_ACPI=y
 CONFIG_PACKET=y
 CONFIG_UNIX=y
 CONFIG_INET=y
-- 
1.7.10.4

