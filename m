From: Juerg Haefliger <juerg.haefliger@canonical.com>
Date: Fri, 20 May 2022 12:00:21 +0000
Subject: [PATCH] ia64: Kconfig: Fix indentation and add comments
Message-Id: <20220520120021.148069-1-juergh@canonical.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Juerg Haefliger <juergh@canonical.com>

The convention for indentation seems to be a single tab. Help text is
further indented by an additional two whitespaces. Fix the lines that
violate these rules.

While add it, add trailing comments to endif and endmenu statements for
better readability.

Signed-off-by: Juerg Haefliger <juergh@canonical.com>
---
 arch/ia64/Kconfig | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index cb93769a9f2a..caf2ace768bc 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -259,19 +259,19 @@ config PERMIT_BSP_REMOVE
 	depends on HOTPLUG_CPU
 	default n
 	help
-	Say Y here if your platform SAL will support removal of BSP with HOTPLUG_CPU
-	support. 
+	  Say Y here if your platform SAL will support removal of BSP with HOTPLUG_CPU
+	  support.
 
 config FORCE_CPEI_RETARGET
 	bool "Force assumption that CPEI can be re-targeted"
 	depends on PERMIT_BSP_REMOVE
 	default n
 	help
-	Say Y if you need to force the assumption that CPEI can be re-targeted to
-	any cpu in the system. This hint is available via ACPI 3.0 specifications.
-	Tiger4 systems are capable of re-directing CPEI to any CPU other than BSP.
-	This option it useful to enable this feature on older BIOS's as well.
-	You can also enable this by using boot command line option force_cpei=1.
+	  Say Y if you need to force the assumption that CPEI can be re-targeted to
+	  any cpu in the system. This hint is available via ACPI 3.0 specifications.
+	  Tiger4 systems are capable of re-directing CPEI to any CPU other than BSP.
+	  This option it useful to enable this feature on older BIOS's as well.
+	  You can also enable this by using boot command line option force_cpei=1.
 
 config ARCH_SELECT_MEMORY_MODEL
 	def_bool y
@@ -335,7 +335,7 @@ config IA64_PALINFO
 config IA64_MC_ERR_INJECT
 	tristate "MC error injection support"
 	help
-	  Adds support for MC error injection. If enabled, the kernel 
+	  Adds support for MC error injection. If enabled, the kernel
 	  will provide a sysfs interface for user applications to
 	  call MC error injection PAL procedures to inject various errors.
 	  This is a useful tool for MCA testing.
@@ -379,12 +379,12 @@ config KEXEC
 	  made.
 
 config CRASH_DUMP
-	  bool "kernel crash dumps"
-	  depends on IA64_MCA_RECOVERY && (!SMP || HOTPLUG_CPU)
-	  help
-	    Generate crash dump after being started by kexec.
+	bool "kernel crash dumps"
+	depends on IA64_MCA_RECOVERY && (!SMP || HOTPLUG_CPU)
+	help
+	  Generate crash dump after being started by kexec.
 
-endmenu
+endmenu # "Processor type and features"
 
 menu "Power management and ACPI options"
 
@@ -395,10 +395,10 @@ source "drivers/acpi/Kconfig"
 if PM
 menu "CPU Frequency scaling"
 source "drivers/cpufreq/Kconfig"
-endmenu
-endif
+endmenu # "CPU Frequency scaling"
+endif # PM
 
-endmenu
+endmenu # "Power management and ACPI options"
 
 config MSPEC
 	tristate "Memory special operations driver"
-- 
2.32.0
