From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Fri, 22 Feb 2008 05:10:46 +0000
Subject: [PATCH 27/28] ia64/xen: update Kconfig to allow xen domU Linux
Message-Id: <12036570484134-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/Kconfig     |    6 +++++-
 arch/ia64/xen/Kconfig |   29 +++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 1 deletions(-)
 create mode 100644 arch/ia64/xen/Kconfig

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index bc84008..31313bc 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -178,7 +178,7 @@ config PARAVIRT_NOP_B_PATCH
 	  "br.cond.sptk.many <native_xxx>" and replace it with 'nop.b 0'
 	  when running on xen.
 
-#source "arch/ia64/xen/Kconfig"
+source "arch/ia64/xen/Kconfig"
 
 endif
 
@@ -238,6 +238,10 @@ config IA64_HP_SIM
 	bool "Ski-simulator"
 	select SWIOTLB
 
+config IA64_XEN
+	bool "Xen guest"
+	depends on XEN
+
 endchoice
 
 choice
diff --git a/arch/ia64/xen/Kconfig b/arch/ia64/xen/Kconfig
new file mode 100644
index 0000000..30f54c3
--- /dev/null
+++ b/arch/ia64/xen/Kconfig
@@ -0,0 +1,29 @@
+#
+# This Kconfig describes xen/ia64 options
+#
+
+config XEN
+	bool "Xen hypervisor support"
+	default y
+	select PARAVIRT
+	select PARAVIRT_ALT
+	select PARAVIRT_ENTRY
+	select PARAVIRT_NOP_B_PATCH
+	select XEN_XENCOMM
+	select IA64_XEN
+	help
+	  Enable Xen hypervisor support.  Resulting kernel runs
+	  both as a guest OS on Xen and natively on hardware.
+
+if XEN
+config XEN_INTERFACE_VERSION
+	hex
+	default 0x00030207
+
+config XEN_XENCOMM
+	def_bool y
+
+config NO_IDLE_HZ
+	def_bool y
+
+endif
-- 
1.5.3

