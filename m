From: jbarnes@sgi.com (Jesse Barnes)
Date: Fri, 25 Jul 2003 20:41:34 +0000
Subject: [PATCH] ia64 Kconfig cleanup
Message-Id: <marc-linux-ia64-105916572315991@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Here are some small updates to the ia64 Kconfig file.  I think it's safe
to apply (i.e. it won't break anything than the already broken sn2
compile), and gets rid of some obsolete options.

Thanks,
Jesse

diff -Nru a/arch/ia64/Kconfig b/arch/ia64/Kconfig
--- a/arch/ia64/Kconfig	Thu Jul 17 16:59:05 2003
+++ b/arch/ia64/Kconfig	Thu Jul 17 16:59:05 2003
@@ -211,7 +211,7 @@
 
 config NUMA
 	bool "Enable NUMA support" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN2
+	default y if IA64_SGI_SN2 || IA64_GENERIC
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
@@ -234,9 +234,8 @@
 endchoice
 
 config DISCONTIGMEM
-	bool
-	depends on IA64_SGI_SN2 || (IA64_GENERIC || IA64_DIG || IA64_HP_ZX1) && NUMA
-	default y
+	bool "Discontiguous memory support" if (IA64_DIG && NUMA)
+	default y if IA64_SGI_SN2 || IA64_GENERIC
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
@@ -245,8 +244,7 @@
 
 config VIRTUAL_MEM_MAP
 	bool "Enable Virtual Mem Map"
-	depends on !NUMA
-	default y if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
+	default y if !IA64_HP_SIM
 	help
 	  Say Y to compile the kernel with support for a virtual mem map.
 	  This is an alternate method of supporting large holes in the
@@ -259,8 +257,8 @@
 	  are unsure, say Y.
 
 config IA64_MCA
-	bool "Enable IA-64 Machine Check Abort" if IA64_GENERIC || IA64_DIG || IA64_HP_ZX1
-	default y if IA64_SGI_SN2
+	bool "Enable IA-64 Machine Check Abort"
+	default y if !IA64_HP_SIM
 	help
 	  Say Y here to enable machine check support for IA-64.  If you're
 	  unsure, answer Y.
@@ -292,43 +290,12 @@
 	depends on IA64_GENERIC || IA64_DIG || IA64_HP_ZX1 || IA64_SGI_SN2
 	default y
 
-config IA64_SGI_SN_DEBUG
-	bool "Enable extra debugging code"
-	depends on IA64_SGI_SN2
-	help
-	  Turns on extra debugging code in the SGI SN (Scalable NUMA) platform
-	  for IA-64.  Unless you are debugging problems on an SGI SN IA-64 box,
-	  say N.
-
 config IA64_SGI_SN_SIM
 	bool "Enable SGI Medusa Simulator Support"
 	depends on IA64_SGI_SN2
 	help
 	  If you are compiling a kernel that will run under SGI's IA-64
 	  simulator (Medusa) then say Y, otherwise say N.
-
-config IA64_SGI_AUTOTEST
-	bool "Enable autotest (llsc). Option to run cache test instead of booting"
-	depends on IA64_SGI_SN2
-	help
-	  Build a kernel used for hardware validation. If you include the
-	  keyword "autotest" on the boot command line, the kernel does NOT boot.
-	  Instead, it starts all cpus and runs cache coherency tests instead.
-
-	  If unsure, say N.
-
-config SERIAL_SGI_L1_PROTOCOL
-	bool "Enable protocol mode for the L1 console"
-	depends on IA64_SGI_SN2
-	help
-	  Uses protocol mode instead of raw mode for the level 1 console on the
-	  SGI SN (Scalable NUMA) platform for IA-64.  If you are compiling for
-	  an SGI SN box then Y is the recommended value, otherwise say N.
-
-config PERCPU_IRQ
-	bool
-	depends on IA64_SGI_SN2
-	default y
 
 # On IA-64, we always want an ELF /proc/kcore.
 config KCORE_ELF
