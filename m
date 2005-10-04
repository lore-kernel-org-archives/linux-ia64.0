From: Bob Picco <bob.picco@hp.com>
Date: Tue, 04 Oct 2005 19:13:37 +0000
Subject: [PATCH 1/5] V5 ia64 SPARSEMEM - Kconfig and Makefile
Message-Id: <20051004191337.GQ25483@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


The patch modifies the Kconfig file to introduce the new memory model
options and other related SPARSEMEM changes.  There is also a minor change 
in the Makefile.

Signed-off-by: Bob Picco <bob.picco@hp.com>

 arch/ia64/Kconfig     |   94 +++++++++++++++++++++++++++++---------------------
 arch/ia64/mm/Makefile |    5 +-
 2 files changed, 58 insertions(+), 41 deletions(-)

Index: linux-2.6.14-rc2/arch/ia64/Kconfig
=================================--- linux-2.6.14-rc2.orig/arch/ia64/Kconfig	2005-09-26 19:16:57.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/Kconfig	2005-09-27 14:31:21.000000000 -0400
@@ -63,8 +63,6 @@ config IA64_GENERIC
 	select ACPI
 	select NUMA
 	select ACPI_NUMA
-	select VIRTUAL_MEM_MAP
-	select DISCONTIGMEM
 	help
 	  This selects the system type of your hardware.  A "generic" kernel
 	  will run on any supported IA-64 system.  However, if you configure
@@ -176,40 +174,6 @@ config IA64_L1_CACHE_SHIFT
 	default "6" if ITANIUM
 
 # align cache-sensitive data to 64 bytes
-config NUMA
-	bool "NUMA support"
-	depends on !IA64_HP_SIM
-	default y if IA64_SGI_SN2
-	select ACPI_NUMA
-	help
-	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
-	  Access).  This option is for configuring high-end multiprocessor
-	  server systems.  If in doubt, say N.
-
-config VIRTUAL_MEM_MAP
-	bool "Virtual mem map"
-	default y if !IA64_HP_SIM
-	help
-	  Say Y to compile the kernel with support for a virtual mem map.
-	  This code also only takes effect if a memory hole of greater than
-	  1 Gb is found during boot.  You must turn this option on if you
-	  require the DISCONTIGMEM option for your machine. If you are
-	  unsure, say Y.
-
-config HOLES_IN_ZONE
-	bool
-	default y if VIRTUAL_MEM_MAP
-
-config ARCH_DISCONTIGMEM_ENABLE
-	bool "Discontiguous memory support"
-	depends on (IA64_DIG || IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB) && NUMA && VIRTUAL_MEM_MAP
-	default y if (IA64_SGI_SN2 || IA64_GENERIC) && NUMA
-	help
-	  Say Y to support efficient handling of discontiguous physical memory,
-	  for architectures which are either NUMA (Non-Uniform Memory Access)
-	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
-
 config IA64_CYCLONE
 	bool "Cyclone (EXA) Time Source support"
 	help
@@ -232,8 +196,10 @@ config IA64_SGI_SN_XP
 	  based on a network adapter and DMA messaging.
 
 config FORCE_MAX_ZONEORDER
-	int
-	default "18"
+	int "MAX_ORDER (11 - 17)"  if !HUGETLB_PAGE
+	range 11 17  if !HUGETLB_PAGE
+	default "17" if HUGETLB_PAGE
+	default "11"
 
 config SMP
 	bool "Symmetric multi-processing support"
@@ -298,6 +264,58 @@ config PREEMPT
 
 source "mm/Kconfig"
 
+config ARCH_SELECT_MEMORY_MODEL
+	def_bool y
+
+config ARCH_DISCONTIGMEM_ENABLE
+	def_bool y
+	help
+	  Say Y to support efficient handling of discontiguous physical memory,
+	  for architectures which are either NUMA (Non-Uniform Memory Access)
+	  or have huge holes in the physical address space for other reasons.
+ 	  See <file:Documentation/vm/numa> for more.
+
+config ARCH_FLATMEM_ENABLE
+	def_bool y
+
+config ARCH_SPARSEMEM_ENABLE
+	def_bool y
+	depends on ARCH_DISCONTIGMEM_ENABLE
+
+config ARCH_DISCONTIGMEM_DEFAULT
+	def_bool y if (IA64_SGI_SN2 || IA64_GENERIC || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB)
+	depends on ARCH_DISCONTIGMEM_ENABLE
+
+config NUMA
+	bool "NUMA support"
+	depends on !IA64_HP_SIM && !FLATMEM
+	default y if IA64_SGI_SN2
+	help
+	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
+	  Access).  This option is for configuring high-end multiprocessor
+	  server systems.  If in doubt, say N.
+
+# VIRTUAL_MEM_MAP and FLAT_NODE_MEM_MAP are functionally equivalent.
+# VIRTUAL_MEM_MAP has been retained for historical reasons.
+config VIRTUAL_MEM_MAP
+	bool "Virtual mem map"
+	depends on !SPARSEMEM
+	default y if !IA64_HP_SIM
+	help
+	  Say Y to compile the kernel with support for a virtual mem map.
+	  This code also only takes effect if a memory hole of greater than
+	  1 Gb is found during boot.  You must turn this option on if you
+	  require the DISCONTIGMEM option for your machine. If you are
+	  unsure, say Y.
+
+config HOLES_IN_ZONE
+	bool
+	default y if VIRTUAL_MEM_MAP
+
+config HAVE_ARCH_EARLY_PFN_TO_NID
+	def_bool y
+	depends on NEED_MULTIPLE_NODES
+
 config IA32_SUPPORT
 	bool "Support for Linux/x86 binaries"
 	help
Index: linux-2.6.14-rc2/arch/ia64/mm/Makefile
=================================--- linux-2.6.14-rc2.orig/arch/ia64/mm/Makefile	2005-09-26 19:16:57.000000000 -0400
+++ linux-2.6.14-rc2/arch/ia64/mm/Makefile	2005-09-26 19:49:27.000000000 -0400
@@ -7,6 +7,5 @@ obj-y := init.o fault.o tlb.o extable.o
 obj-$(CONFIG_HUGETLB_PAGE) += hugetlbpage.o
 obj-$(CONFIG_NUMA)	   += numa.o
 obj-$(CONFIG_DISCONTIGMEM) += discontig.o
-ifndef CONFIG_DISCONTIGMEM
-obj-y += contig.o
-endif
+obj-$(CONFIG_SPARSEMEM)	   += discontig.o
+obj-$(CONFIG_FLATMEM)	   += contig.o
