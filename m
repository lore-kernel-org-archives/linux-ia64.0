From: Fenghua Yu <fenghua.yu@intel.com>
Date: Sat, 09 Dec 2006 00:06:01 +0000
Subject: [PATCH 1/5] Itanium MC Error Injection Tool: Kernel configuration
Message-Id: <20061208160601.A1098@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This patch has kenrel configuration changes for the MC Error Injection
Tool.

Signed-off-by: Fenghua Yu <fenghua.yu@intel.com>


--- a/arch/ia64/Kconfig	2006-12-05 18:10:23.000000000 -0800
+++ b/arch/ia64/Kconfig	2006-12-05 18:10:55.000000000 -0800
@@ -421,6 +421,16 @@ config IA64_PALINFO
 	  To use this option, you have to ensure that the "/proc file system
 	  support" (CONFIG_PROC_FS) is enabled, too.
 
+config IA64_MC_ERR_INJECT
+	tristate "MC error injection support"
+	help
+	  Selets whether support for MC error injection. By enabling the
+	  support, kernel provide sysfs interface for user application to
+	  call MC error injection PAL procedure to inject various errors.
+	  This is a useful tool for MCA testing.
+
+	  If you're unsure, do not select this option.
+
 config SGI_SN
 	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC)
 
--- a/arch/ia64/defconfig	2006-12-05 18:10:23.000000000 -0800
+++ b/arch/ia64/defconfig	2006-12-05 18:10:55.000000000 -0800
@@ -144,6 +144,7 @@ CONFIG_COMPAT=y
 CONFIG_IA64_MCA_RECOVERY=y
 CONFIG_PERFMON=y
 CONFIG_IA64_PALINFO=y
+# CONFIG_MC_ERR_INJECT is not set
 CONFIG_SGI_SN=y
 
 #
