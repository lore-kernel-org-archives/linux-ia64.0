From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Thu, 04 Apr 2013 12:59:04 +0000
Subject: [PATCH 12/18] cpufreq: ia64: move cpufreq driver to drivers/cpufreq
Message-Id: <00f0f8aa0af6d40d0a8730033a0e0fe221604c7c.1365079581.git.viresh.kumar@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1365079581.git.viresh.kumar@linaro.org>
In-Reply-To: <cover.1365079581.git.viresh.kumar@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: rjw@sisk.pl
Cc: robin.randhawa@arm.com, Steve.Bannister@arm.com, Liviu.Dudau@arm.com, charles.garcia-tobin@arm.com, arvind.chauhan@arm.com, cpufreq@vger.kernel.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, Viresh Kumar <viresh.kumar@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This patch moves cpufreq driver of IA64 architecture to drivers/cpufreq.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
Acked-by: Tony Luck <tony.luck@intel.com>
---
 arch/ia64/Kconfig                                  |  6 ++---
 arch/ia64/kernel/Makefile                          |  1 -
 arch/ia64/kernel/cpufreq/Kconfig                   | 29 ----------------------
 arch/ia64/kernel/cpufreq/Makefile                  |  2 --
 drivers/cpufreq/Kconfig                            | 17 +++++++++++++
 drivers/cpufreq/Makefile                           |  1 +
 .../cpufreq/ia64-acpi-cpufreq.c                    |  1 -
 7 files changed, 21 insertions(+), 36 deletions(-)
 delete mode 100644 arch/ia64/kernel/cpufreq/Kconfig
 delete mode 100644 arch/ia64/kernel/cpufreq/Makefile
 rename arch/ia64/kernel/cpufreq/acpi-cpufreq.c => drivers/cpufreq/ia64-acpi-cpufreq.c (99%)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 9a02f71..152b5f2 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -591,9 +591,9 @@ source "kernel/power/Kconfig"
 source "drivers/acpi/Kconfig"
 
 if PM
-
-source "arch/ia64/kernel/cpufreq/Kconfig"
-
+menu "CPU Frequency scaling"
+source "drivers/cpufreq/Kconfig"
+endmenu
 endif
 
 endmenu
diff --git a/arch/ia64/kernel/Makefile b/arch/ia64/kernel/Makefile
index d959c84..20678a9 100644
--- a/arch/ia64/kernel/Makefile
+++ b/arch/ia64/kernel/Makefile
@@ -23,7 +23,6 @@ obj-$(CONFIG_SMP)		+= smp.o smpboot.o
 obj-$(CONFIG_NUMA)		+= numa.o
 obj-$(CONFIG_PERFMON)		+= perfmon_default_smpl.o
 obj-$(CONFIG_IA64_CYCLONE)	+= cyclone.o
-obj-$(CONFIG_CPU_FREQ)		+= cpufreq/
 obj-$(CONFIG_IA64_MCA_RECOVERY)	+= mca_recovery.o
 obj-$(CONFIG_KPROBES)		+= kprobes.o jprobes.o
 obj-$(CONFIG_DYNAMIC_FTRACE)	+= ftrace.o
diff --git a/arch/ia64/kernel/cpufreq/Kconfig b/arch/ia64/kernel/cpufreq/Kconfig
deleted file mode 100644
index 2d9d527..0000000
--- a/arch/ia64/kernel/cpufreq/Kconfig
+++ /dev/null
@@ -1,29 +0,0 @@
-
-#
-# CPU Frequency scaling
-#
-
-menu "CPU Frequency scaling"
-
-source "drivers/cpufreq/Kconfig"
-
-if CPU_FREQ
-
-comment "CPUFreq processor drivers"
-
-config IA64_ACPI_CPUFREQ
-	tristate "ACPI Processor P-States driver"
-	select CPU_FREQ_TABLE
-	depends on ACPI_PROCESSOR
-	help
-	This driver adds a CPUFreq driver which utilizes the ACPI
-	Processor Performance States.
-
-	For details, take a look at <file:Documentation/cpu-freq/>.
-
-	If in doubt, say N.
-
-endif   # CPU_FREQ
-
-endmenu
-
diff --git a/arch/ia64/kernel/cpufreq/Makefile b/arch/ia64/kernel/cpufreq/Makefile
deleted file mode 100644
index 4838f2a..0000000
--- a/arch/ia64/kernel/cpufreq/Makefile
+++ /dev/null
@@ -1,2 +0,0 @@
-obj-$(CONFIG_IA64_ACPI_CPUFREQ)		+= acpi-cpufreq.o
-
diff --git a/drivers/cpufreq/Kconfig b/drivers/cpufreq/Kconfig
index d7ce6cc..a2f1600 100644
--- a/drivers/cpufreq/Kconfig
+++ b/drivers/cpufreq/Kconfig
@@ -218,6 +218,23 @@ config AVR32_AT32AP_CPUFREQ
 
 endmenu
 
+menu "CPUFreq processor drivers"
+depends on IA64
+
+config IA64_ACPI_CPUFREQ
+	tristate "ACPI Processor P-States driver"
+	select CPU_FREQ_TABLE
+	depends on ACPI_PROCESSOR
+	help
+	This driver adds a CPUFreq driver which utilizes the ACPI
+	Processor Performance States.
+
+	For details, take a look at <file:Documentation/cpu-freq/>.
+
+	If in doubt, say N.
+
+endmenu
+
 menu "PowerPC CPU frequency scaling drivers"
 depends on PPC32 || PPC64
 source "drivers/cpufreq/Kconfig.powerpc"
diff --git a/drivers/cpufreq/Makefile b/drivers/cpufreq/Makefile
index 751815d..aaa018c 100644
--- a/drivers/cpufreq/Makefile
+++ b/drivers/cpufreq/Makefile
@@ -86,3 +86,4 @@ obj-$(CONFIG_AVR32_AT32AP_CPUFREQ)	+= at32ap-cpufreq.o
 obj-$(CONFIG_BLACKFIN)			+= blackfin-cpufreq.o
 obj-$(CONFIG_CRIS_MACH_ARTPEC3)		+= cris-artpec3-cpufreq.o
 obj-$(CONFIG_ETRAXFS)			+= cris-etraxfs-cpufreq.o
+obj-$(CONFIG_IA64_ACPI_CPUFREQ)		+= ia64-acpi-cpufreq.o
diff --git a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c b/drivers/cpufreq/ia64-acpi-cpufreq.c
similarity index 99%
rename from arch/ia64/kernel/cpufreq/acpi-cpufreq.c
rename to drivers/cpufreq/ia64-acpi-cpufreq.c
index 4700fef..c0075db 100644
--- a/arch/ia64/kernel/cpufreq/acpi-cpufreq.c
+++ b/drivers/cpufreq/ia64-acpi-cpufreq.c
@@ -1,5 +1,4 @@
 /*
- * arch/ia64/kernel/cpufreq/acpi-cpufreq.c
  * This file provides the ACPI based P-state support. This
  * module works with generic cpufreq infrastructure. Most of
  * the code is based on i386 version
-- 
1.7.12.rc2.18.g61b472e

