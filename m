From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Wed, 09 Apr 2008 04:50:30 +0000
Subject: [PATCH 23/23] ia64/pv_ops: update Kconfig for paravirtualized guest and xen.
Message-Id: <1207716631167-git-send-email-yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

introduce CONFIG_PARAVIRT_GUEST, CONFIG_PARAVIRT for
paravirtualized guest.
introduce CONFING_XEN, CONFIG_IA64_XEN for xen.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
---
 arch/ia64/Kconfig     |   31 +++++++++++++++++++++++++++++++
 arch/ia64/xen/Kconfig |   21 +++++++++++++++++++++
 2 files changed, 52 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/Kconfig

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8fa3faf..ca4d559 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -111,6 +111,33 @@ config AUDIT_ARCH
 	bool
 	default y
 
+menuconfig PARAVIRT_GUEST
+	bool "Paravirtualized guest support"
+	help
+	  Say Y here to get to see options related to running Linux under
+	  various hypervisors.  This option alone does not add any kernel code.
+
+	  If you say N, all options in this submenu will be skipped and disabled.
+
+if PARAVIRT_GUEST
+
+config PARAVIRT
+	bool "Enable paravirtualization code"
+	depends on PARAVIRT_GUEST
+	default y
+	bool
+	default y
+	help
+	  This changes the kernel so it can modify itself when it is run
+	  under a hypervisor, potentially improving performance significantly
+	  over full virtualization.  However, when run without a hypervisor
+	  the kernel is theoretically slower and slightly larger.
+
+
+source "arch/ia64/xen/Kconfig"
+
+endif
+
 choice
 	prompt "System type"
 	default IA64_GENERIC
@@ -169,6 +196,10 @@ config IA64_HP_SIM
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
index 0000000..829b85c
--- /dev/null
+++ b/arch/ia64/xen/Kconfig
@@ -0,0 +1,21 @@
+#
+# This Kconfig describes xen/ia64 options
+#
+
+config XEN
+	bool "Xen hypervisor support"
+	default y
+	depends on PARAVIRT && !(IA64_DIG || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB || IA64_SGI_SN2 || IA64_HP_SIM) && MCKINLEY && IA64_PAGE_SIZE_16KB && EXPERIMENTAL
+	select XEN_XENCOMM
+	select NO_IDLE_HZ
+	help
+	  Enable Xen hypervisor support.  Resulting kernel runs
+	  both as a guest OS on Xen and natively on hardware.
+
+config XEN_XENCOMM
+	depends on XEN
+	bool
+
+config NO_IDLE_HZ
+	depends on XEN
+	bool
-- 
1.5.3

