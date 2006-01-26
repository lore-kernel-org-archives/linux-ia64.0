From: Grant Grundler <iod00d@hp.com>
Date: Thu, 26 Jan 2006 05:59:17 +0000
Subject: [PATCH] enable ACPI/NUMA for HP ZX1 config
Message-Id: <20060126055917.GA12615@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org

Tony,

Bjorn/Alex cleaned up IA64_HP_ZX1 to also support SX1000 as well.
I suspect NUMA was introduced later and HP forgot to update
the ZX1/SX1000 config to also support NUMA. ACPI support
just seems to have been overlooked since it's required for
HP platforms.

How would you prefer to handle ACPI_NUMA?
Instead of adding more machines to change the default,
I suggest the default be "Y" with no coniditions (as proposed below).
Given the "depends NUMA", it means the user already said Y to NUMA,
this only applies if ia64 or x86_64, and I don't expect any
performance impact in the ACPI code path.

thanks,
grant

Signed-off-by: Grant Grundler <iod00d@hp.com>

--- a/arch/ia64/Kconfig	19 Dec 2005 12:42:13 -0000
+++ b/arch/ia64/Kconfig	25 Jan 2006 21:08:04 -0000
@@ -90,12 +90,14 @@ config IA64_DIG
 
 config IA64_HP_ZX1
 	bool "HP-zx1/sx1000"
+	select ACPI
 	help
 	  Build a kernel that runs on HP zx1 and sx1000 systems.  This adds
 	  support for the HP I/O MMU.
 
 config IA64_HP_ZX1_SWIOTLB
 	bool "HP-zx1/sx1000 with software I/O TLB"
+	select ACPI
 	help
 	  Build a kernel that runs on HP zx1 and sx1000 systems even when they
 	  have broken PCI devices which cannot DMA to full 32 bits.  Apart
@@ -311,7 +313,7 @@ config ARCH_DISCONTIGMEM_DEFAULT
 config NUMA
 	bool "NUMA support"
 	depends on !IA64_HP_SIM && !FLATMEM
-	default y if IA64_SGI_SN2
+	default y if IA64_SGI_SN2 || IA64_HP_ZX1 || IA64_HP_ZX1_SWIOTLB
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor
--- a/drivers/acpi/Kconfig	17 Jan 2006 14:51:01 -0000
+++ b/drivers/acpi/Kconfig	25 Jan 2006 21:08:06 -0000
@@ -163,7 +163,7 @@ config ACPI_NUMA
 	bool "NUMA support"
 	depends on NUMA
 	depends on (IA64 || X86_64)
-	default y if IA64_GENERIC || IA64_SGI_SN2
+	default y
 
 config ACPI_ASUS
         tristate "ASUS/Medion Laptop Extras"
