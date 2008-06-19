From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 12:17:13 +0000
Subject: Re: [PATCH 26/27] ia64/pv_ops: update Kconfig for paravirtualized guest and xen.
Message-Id: <20080619121713.GR11378%yamahata@valinux.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1213084044647-git-send-email-yamahata@valinux.co.jp>
In-Reply-To: <1213084044647-git-send-email-yamahata@valinux.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Jun 18, 2008 at 03:13:13PM -0700, Luck, Tony wrote:
> > introduce CONFIG_PARAVIRT_GUEST, CONFIG_PARAVIRT for
> > paravirtualized guest.
> > introduce CONFING_XEN, CONFIG_IA64_XEN for xen.
> 
> s/CONFING_XEN/CONFIG_XEN/
> 
> Would it make sense to rename CONFIG_IA64_XEN to be
> CONFIG_IA64_XEN_GUEST?  The comments you add to
> arch/ia64/Kconfig say that this is what it means.

Sounds reasonable.

From 0ab56a68e392c4d0fcf244cb91538e9645af5929 Mon Sep 17 00:00:00 2001
From: Isaku Yamahata <yamahata@valinux.co.jp>
Date: Thu, 19 Jun 2008 20:01:33 +0900
Subject: [PATCH] ia64/pv_ops: update Kconfig for paravirtualized guest and xen.

introduce CONFIG_PARAVIRT_GUEST, CONFIG_PARAVIRT for
paravirtualized guest.
introduce CONFIG_XEN, CONFIG_IA64_XEN_GUEST for xen.

Signed-off-by: Alex Williamson <alex.williamson@hp.com>
Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>
Cc: "Luck, Tony" <tony.luck@intel.com>
---
 arch/ia64/Kconfig     |   32 ++++++++++++++++++++++++++++++++
 arch/ia64/xen/Kconfig |   26 ++++++++++++++++++++++++++
 2 files changed, 58 insertions(+), 0 deletions(-)
 create mode 100644 arch/ia64/xen/Kconfig

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 16be414..91d8c1b 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -116,6 +116,33 @@ config AUDIT_ARCH
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
@@ -137,6 +164,7 @@ config IA64_GENERIC
 	  SGI-SN2		For SGI Altix systems
 	  SGI-UV		For SGI UV systems
 	  Ski-simulator		For the HP simulator <http://www.hpl.hp.com/research/linux/ski/>
+	  Xen-domU		For xen domU system
 
 	  If you don't know what to do, choose "generic".
 
@@ -187,6 +215,10 @@ config IA64_HP_SIM
 	bool "Ski-simulator"
 	select SWIOTLB
 
+config IA64_XEN_GUEST
+	bool "Xen guest"
+	depends on XEN
+
 endchoice
 
 choice
diff --git a/arch/ia64/xen/Kconfig b/arch/ia64/xen/Kconfig
new file mode 100644
index 0000000..f1683a2
--- /dev/null
+++ b/arch/ia64/xen/Kconfig
@@ -0,0 +1,26 @@
+#
+# This Kconfig describes xen/ia64 options
+#
+
+config XEN
+	bool "Xen hypervisor support"
+	default y
+	depends on PARAVIRT && MCKINLEY && IA64_PAGE_SIZE_16KB && EXPERIMENTAL
+	select XEN_XENCOMM
+	select NO_IDLE_HZ
+
+	# those are required to save/restore.
+	select ARCH_SUSPEND_POSSIBLE
+	select SUSPEND
+	select PM_SLEEP
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



-- 
yamahata
