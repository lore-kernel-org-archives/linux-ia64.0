From: Russ Anderson <rja@sgi.com>
Date: Fri, 16 May 2008 20:20:21 +0000
Subject: [patch] Fix Altix boot breakage in ACPI
Message-Id: <20080516202020.GA21250@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

A recent ACPI change (commit 5dc90c0b2d4bd0127624bab67cec159b2c6c4daf)
inadvertently broke Altix boot.  This patch allow Altix to boot.


Signed-off-by: Russ Anderson <rja@sgi.com>
Acked-by: Ingo Molnar <mingo@elte.hu>

---
 arch/ia64/Kconfig    |    4 ++++
 include/linux/acpi.h |    2 +-
 2 files changed, 5 insertions(+), 1 deletion(-)

Index: 2.6.26-rc2/arch/ia64/Kconfig
=================================--- 2.6.26-rc2.orig/arch/ia64/Kconfig	2008-05-16 09:36:37.285558037 -0500
+++ 2.6.26-rc2/arch/ia64/Kconfig	2008-05-16 09:37:39.149204580 -0500
@@ -60,6 +60,10 @@ config RWSEM_XCHGADD_ALGORITHM
 	bool
 	default y
 
+config HAVE_ARCH_PARSE_SRAT
+	bool
+	default y
+
 config ARCH_HAS_ILOG2_U32
 	bool
 	default n
Index: 2.6.26-rc2/include/linux/acpi.h
=================================--- 2.6.26-rc2.orig/include/linux/acpi.h	2008-05-16 09:37:12.989971159 -0500
+++ 2.6.26-rc2/include/linux/acpi.h	2008-05-16 09:50:17.082906375 -0500
@@ -93,7 +93,7 @@ int acpi_parse_mcfg (struct acpi_table_h
 void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
 
 /* the following four functions are architecture-dependent */
-#ifdef CONFIG_HAVE_ARCH_PARSE_SRAT
+#if defined(CONFIG_HAVE_ARCH_PARSE_SRAT) && !defined(NR_NODE_MEMBLKS)
 #define NR_NODE_MEMBLKS MAX_NUMNODES
 #define acpi_numa_slit_init(slit) do {} while (0)
 #define acpi_numa_processor_affinity_init(pa) do {} while (0)
-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
