From: Lv Zheng <lv.zheng@intel.com>
Date: Mon, 07 Jul 2014 04:17:14 +0000
Subject: [PATCH v2 3/7] ACPICA: Linux: Add configuration item to indicate the architecture specific support.
Message-Id: <fc44916b042694f2c2841444395e15731f5c70c5.1404706299.git.lv.zheng@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <cover.1387336613.git.lv.zheng@intel.com> <cover.1404706298.git.lv.zheng@intel.com>
In-Reply-To: <cover.1404706298.git.lv.zheng@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Len Brown <len.brown@intel.com>
Cc: Lv Zheng <lv.zheng@intel.com>, Lv Zheng <zetalog@gmail.com>, linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

This patch adds a kernel configuration item to indicate the presense of
the architecture specific support for ACPICA, so that <asm/acenv.h>
inclusion can be configured out.

Signed-off-by: Lv Zheng <lv.zheng@intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: linux-ia64@vger.kernel.org
---
 arch/ia64/Kconfig               |    1 +
 arch/x86/Kconfig                |    1 +
 drivers/acpi/Kconfig            |    4 ++++
 include/acpi/platform/aclinux.h |    2 ++
 4 files changed, 8 insertions(+)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 2f3abcf..a822dd1 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -47,6 +47,7 @@ config IA64
 	select MODULES_USE_ELF_RELA
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_AUDITSYSCALL
+	select HAVE_ARCH_ACPICA
 	default y
 	help
 	  The Itanium Processor Family is Intel's 64-bit successor to
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index a8f749e..16f3197 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -131,6 +131,7 @@ config X86
 	select HAVE_CC_STACKPROTECTOR
 	select GENERIC_CPU_AUTOPROBE
 	select HAVE_ARCH_AUDITSYSCALL
+	select HAVE_ARCH_ACPICA
 
 config INSTRUCTION_DECODER
 	def_bool y
diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index a34a228..0cd63af4 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -2,8 +2,12 @@
 # ACPI Configuration
 #
 
+config HAVE_ARCH_ACPICA
+	bool
+
 menuconfig ACPI
 	bool "ACPI (Advanced Configuration and Power Interface) Support"
+	depends on HAVE_ARCH_ACPICA
 	depends on !IA64_HP_SIM
 	depends on IA64 || X86
 	depends on PCI
diff --git a/include/acpi/platform/aclinux.h b/include/acpi/platform/aclinux.h
index cd1f052..d63a54b4 100644
--- a/include/acpi/platform/aclinux.h
+++ b/include/acpi/platform/aclinux.h
@@ -70,7 +70,9 @@
 #ifdef EXPORT_ACPI_INTERFACES
 #include <linux/export.h>
 #endif
+#ifdef CONFIG_HAVE_ARCH_ACPICA
 #include <asm/acenv.h>
+#endif
 
 #ifndef CONFIG_ACPI
 
-- 
1.7.10

