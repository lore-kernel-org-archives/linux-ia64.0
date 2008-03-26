From: Dean Nelson <dcn@sgi.com>
Date: Wed, 26 Mar 2008 22:02:29 +0000
Subject: [Patch 2/5] move XP and XPC to drivers/misc/xp -v3
Message-Id: <20080326220229.GB31138@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080326215807.GF31340@sgi.com>
In-Reply-To: <20080326215807.GF31340@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: jes@sgi.com, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Move XPC and XPNET from arch/ia64/sn to drivers/misc/xp.

Signed-off-by: Dean Nelson <dcn@sgi.com>

---

 arch/ia64/Kconfig                                  |   11 -----------
 arch/ia64/sn/kernel/Makefile                       |    5 -----
 drivers/misc/Kconfig                               |   12 ++++++++++++
 drivers/misc/Makefile                              |    1 +
 drivers/misc/xp/Makefile                           |    9 +++++++++
 {include/asm-ia64/sn => drivers/misc/xp}/xp.h      |    0 
 {arch/ia64/sn/kernel => drivers/misc/xp}/xp_main.c |    0 
 .../sn/kernel => drivers/misc/xp}/xp_nofault.S     |    0 
 {include/asm-ia64/sn => drivers/misc/xp}/xpc.h     |    0 
 .../sn/kernel => drivers/misc/xp}/xpc_channel.c    |    0 
 .../ia64/sn/kernel => drivers/misc/xp}/xpc_main.c  |    0 
 .../sn/kernel => drivers/misc/xp}/xpc_partition.c  |    0 
 {arch/ia64/sn/kernel => drivers/misc/xp}/xpnet.c   |    0 
 13 files changed, 22 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8fa3faf..c6adc39 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -266,17 +266,6 @@ config IOSAPIC
 	depends on !IA64_HP_SIM
 	default y
 
-config IA64_SGI_SN_XP
-	tristate "Support communication between SGI SSIs"
-	depends on IA64_GENERIC || IA64_SGI_SN2
-	select IA64_UNCACHED_ALLOCATOR
-	help
-	  An SGI machine can be divided into multiple Single System
-	  Images which act independently of each other and have
-	  hardware based memory protection from the others.  Enabling
-	  this feature will allow for direct communication between SSIs
-	  based on a network adapter and DMA messaging.
-
 config FORCE_MAX_ZONEORDER
 	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
 	range 11 17  if !HUGETLB_PAGE
diff --git a/arch/ia64/sn/kernel/Makefile b/arch/ia64/sn/kernel/Makefile
index 688a3c2..2cc8ea6 100644
--- a/arch/ia64/sn/kernel/Makefile
+++ b/arch/ia64/sn/kernel/Makefile
@@ -15,9 +15,4 @@ obj-y				+= setup.o bte.o bte_error.o irq.o mca.o idle.o \
 				   sn2/
 obj-$(CONFIG_IA64_GENERIC)      += machvec.o
 obj-$(CONFIG_SGI_TIOCX)		+= tiocx.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xp.o
-xp-y				:= xp_main.o xp_nofault.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xpc.o
-xpc-y				:= xpc_main.o xpc_channel.o xpc_partition.o
-obj-$(CONFIG_IA64_SGI_SN_XP)	+= xpnet.o
 obj-$(CONFIG_PCI_MSI)		+= msi_sn.o
diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 962817e..9f45772 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -327,4 +327,16 @@ config ENCLOSURE_SERVICES
 	  driver (SCSI/ATA) which supports enclosures
 	  or a SCSI enclosure device (SES) to use these services.
 
+config SGI_XP
+	tristate "Support communication between SGI SSIs"
+	depends on IA64_GENERIC || IA64_SGI_SN2
+	select IA64_UNCACHED_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
+	select GENERIC_ALLOCATOR if IA64_GENERIC || IA64_SGI_SN2
+	---help---
+	  An SGI machine can be divided into multiple Single System
+	  Images which act independently of each other and have
+	  hardware based memory protection from the others.  Enabling
+	  this feature will allow for direct communication between SSIs
+	  based on a network adapter and DMA messaging.
+
 endif # MISC_DEVICES
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index 3b12f5d..743b245 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -22,3 +22,4 @@ obj-$(CONFIG_FUJITSU_LAPTOP)	+= fujitsu-laptop.o
 obj-$(CONFIG_EEPROM_93CX6)	+= eeprom_93cx6.o
 obj-$(CONFIG_INTEL_MENLOW)	+= intel_menlow.o
 obj-$(CONFIG_ENCLOSURE_SERVICES) += enclosure.o
+obj-$(CONFIG_SGI_XP)		+= xp/
diff --git a/drivers/misc/xp/Makefile b/drivers/misc/xp/Makefile
new file mode 100644
index 0000000..70dfdd3
--- /dev/null
+++ b/drivers/misc/xp/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for XP devices.
+#
+
+obj-$(CONFIG_SGI_XP)		+= xp.o
+xp-y				:= xp_main.o xp_nofault.o
+obj-$(CONFIG_SGI_XP)		+= xpc.o
+xpc-y				:= xpc_main.o xpc_channel.o xpc_partition.o
+obj-$(CONFIG_SGI_XP)		+= xpnet.o
diff --git a/include/asm-ia64/sn/xp.h b/drivers/misc/xp/xp.h
similarity index 100%
rename from include/asm-ia64/sn/xp.h
rename to drivers/misc/xp/xp.h
diff --git a/arch/ia64/sn/kernel/xp_main.c b/drivers/misc/xp/xp_main.c
similarity index 100%
rename from arch/ia64/sn/kernel/xp_main.c
rename to drivers/misc/xp/xp_main.c
diff --git a/arch/ia64/sn/kernel/xp_nofault.S b/drivers/misc/xp/xp_nofault.S
similarity index 100%
rename from arch/ia64/sn/kernel/xp_nofault.S
rename to drivers/misc/xp/xp_nofault.S
diff --git a/include/asm-ia64/sn/xpc.h b/drivers/misc/xp/xpc.h
similarity index 100%
rename from include/asm-ia64/sn/xpc.h
rename to drivers/misc/xp/xpc.h
diff --git a/arch/ia64/sn/kernel/xpc_channel.c b/drivers/misc/xp/xpc_channel.c
similarity index 100%
rename from arch/ia64/sn/kernel/xpc_channel.c
rename to drivers/misc/xp/xpc_channel.c
diff --git a/arch/ia64/sn/kernel/xpc_main.c b/drivers/misc/xp/xpc_main.c
similarity index 100%
rename from arch/ia64/sn/kernel/xpc_main.c
rename to drivers/misc/xp/xpc_main.c
diff --git a/arch/ia64/sn/kernel/xpc_partition.c b/drivers/misc/xp/xpc_partition.c
similarity index 100%
rename from arch/ia64/sn/kernel/xpc_partition.c
rename to drivers/misc/xp/xpc_partition.c
diff --git a/arch/ia64/sn/kernel/xpnet.c b/drivers/misc/xp/xpnet.c
similarity index 100%
rename from arch/ia64/sn/kernel/xpnet.c
rename to drivers/misc/xp/xpnet.c
