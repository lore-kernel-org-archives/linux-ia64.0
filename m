From: "Jan Beulich" <jbeulich@novell.com>
Date: Wed, 03 Jan 2007 09:26:21 +0000
Subject: [PATCH] ia64: Enable SWIOTLB only when needed
Message-Id: <459B84CD.76E4.0078.0@novell.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Don't force CONFIG_SWIOTLB on when not actually needed (i.e. HP_ZX1 and
SGI_SN2).

Signed-off-by: Jan Beulich <jbeulich@novell.com>

--- linux-2.6.20-rc3/arch/ia64/Kconfig	2007-01-02 15:41:38.000000000 +0100
+++ 2.6.20-rc3-ia64-swiotlb-opt/arch/ia64/Kconfig	2006-12-22 16:44:57.000000000 +0100
@@ -28,7 +28,6 @@ config MMU
 
 config SWIOTLB
        bool
-       default y
 
 config RWSEM_XCHGADD_ALGORITHM
 	bool
@@ -88,6 +87,7 @@ config IA64_GENERIC
 	select PCI
 	select NUMA
 	select ACPI_NUMA
+	select SWIOTLB
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -104,6 +104,7 @@ config IA64_GENERIC
 
 config IA64_DIG
 	bool "DIG-compliant"
+	select SWIOTLB
 
 config IA64_HP_ZX1
 	bool "HP-zx1/sx1000"
@@ -113,6 +114,7 @@ config IA64_HP_ZX1
 
 config IA64_HP_ZX1_SWIOTLB
 	bool "HP-zx1/sx1000 with software I/O TLB"
+	select SWIOTLB
 	help
 	  Build a kernel that runs on HP zx1 and sx1000 systems even when they
 	  have broken PCI devices which cannot DMA to full 32 bits.  Apart
@@ -131,6 +133,7 @@ config IA64_SGI_SN2
 
 config IA64_HP_SIM
 	bool "Ski-simulator"
+	select SWIOTLB
 
 endchoice
 

