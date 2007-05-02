From: Simon Horman <horms@verge.net.au>
Date: Wed, 02 May 2007 08:27:19 +0000
Subject: [PATCH] IA64: Sparse and Discontig Mem need NUMA
Message-Id: <20070502082716.GA6689@verge.net.au>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

It was pointed out to me by my colleague Yamahata-san that
neither sparse nor discontig mem compile without NUMA support.

Cc: Alex Williamson <alex.williamson@hp.com>
Cc: Isaku Yamahata <yamahata@valinux.co.jp>
Signed-off-by: Simon Horman <horms@verge.net.au>

--- 
This seems line an issue best solved by prohibiting such settings through
Kconfig. But if it is desirable for sparse and discontig memory to work
without CONFIG_NUMA let me know and I'll have a stab at it. It does seem
possible code-wise. I'm just not sure if its useful.

Index: linux-2.6/arch/ia64/Kconfig
=================================--- linux-2.6.orig/arch/ia64/Kconfig	2007-05-02 16:42:22.000000000 +0900
+++ linux-2.6/arch/ia64/Kconfig	2007-05-02 16:42:26.000000000 +0900
@@ -337,6 +337,7 @@ config ARCH_SELECT_MEMORY_MODEL
 
 config ARCH_DISCONTIGMEM_ENABLE
 	def_bool y
+	depends on NUMA
 	help
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
@@ -345,6 +346,7 @@ config ARCH_DISCONTIGMEM_ENABLE
 
 config ARCH_FLATMEM_ENABLE
 	def_bool y
+	depends on !NUMA
 
 config ARCH_SPARSEMEM_ENABLE
 	def_bool y
@@ -356,7 +358,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
 
 config NUMA
 	bool "NUMA support"
-	depends on !IA64_HP_SIM && !FLATMEM
+	depends on !IA64_HP_SIM
 	default y if IA64_SGI_SN2
 	select ACPI_NUMA if ACPI
 	help
