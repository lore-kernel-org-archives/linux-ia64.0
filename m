From: Len Brown <lenb@kernel.org>
Date: Sat, 27 Jan 2007 06:57:43 +0000
Subject: [PATCH 1/3] - ACPICA: reduce conflicts with Altix patch series
Message-Id: <200701270157.43631.lenb@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061115152454.6047.64973.sendpatchset@attica.americas.sgi.com> <20070126171048.5f0bf293.akpm@osdl.org> <200701270155.18596.lenb@kernel.org>
In-Reply-To: <200701270155.18596.lenb@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Andrew Morton <akpm@osdl.org>
Cc: John Keller <jpk@sgi.com>, linux-acpi@vger.kernel.org, tony.luck@intel.com, linux-ia64@vger.kernel.org, pcihpd-discuss@lists.sourceforge.net, gregkh@suse.de, linux-kernel@vger.kernel.org, ayoung@sgi.com, jes@sgi.com, "Starikovskiy, Alexey" <alexey.y.starikovskiy@linux.intel.com>

Syntax only -- no functional changes.

Signed-off-by: Len Brown <len.brown@intel.com
---
 arch/ia64/sn/kernel/io_common.c |   10 ++++++----
 arch/ia64/sn/kernel/iomv.c      |    5 ++---
 include/asm-ia64/sn/acpi.h      |   18 ++++++++++++++++++
 3 files changed, 26 insertions(+), 7 deletions(-)

Index: acpi/arch/ia64/sn/kernel/io_common.c
=================================--- acpi.orig/arch/ia64/sn/kernel/io_common.c
+++ acpi/arch/ia64/sn/kernel/io_common.c
@@ -25,6 +25,7 @@
 #include "xtalk/xwidgetdev.h"
 #include <linux/acpi.h>
 #include <asm/sn/sn2/sn_hwperf.h>
+#include <asm/sn/acpi.h>
 
 extern void sn_init_cpei_timer(void);
 extern void register_sn_procfs(void);
@@ -36,6 +37,7 @@ extern void sn_legacy_pci_window_fixup(s
 extern void sn_io_acpi_init(void);
 extern void sn_io_init(void);
 
+
 static struct list_head sn_sysdata_list;
 
 /* sysdata list struct */
@@ -48,7 +50,7 @@ int sn_ioif_inited;		/* SN I/O infrastru
 
 struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
 
-int sn_acpi_base_support()
+int sn_acpi_base_support(void)
 {
 	struct acpi_table_header *header;
 	(void)acpi_get_table_by_index(ACPI_TABLE_INDEX_DSDT, &header);
@@ -293,7 +295,7 @@ void sn_pci_fixup_slot(struct pci_dev *d
 	list_add_tail(&pcidev_info->pdi_list,
 		      &(SN_PLATFORM_DATA(dev->bus)->pcidev_info));
 
-	if (sn_acpi_base_support())
+	if (SN_ACPI_BASE_SUPPORT())
 		sn_acpi_slot_fixup(dev, pcidev_info);
 	else
 		sn_more_slot_fixup(dev, pcidev_info);
@@ -505,7 +507,7 @@ void __devinit
 sn_pci_fixup_bus(struct pci_bus *bus)
 {
 
-	if (sn_acpi_base_support())
+	if (SN_ACPI_BASE_SUPPORT())
 		sn_acpi_bus_fixup(bus);
 	else
 		sn_bus_fixup(bus);
@@ -557,7 +559,7 @@ sn_io_early_init(void)
 		printk(KERN_INFO "ACPI  DSDT OEM Rev 0x%x\n",
 			header->oem_revision);
 	}
-	if (sn_acpi_base_support())
+	if (SN_ACPI_BASE_SUPPORT())
 		sn_io_acpi_init();
 	else
 		sn_io_init();
Index: acpi/arch/ia64/sn/kernel/iomv.c
=================================--- acpi.orig/arch/ia64/sn/kernel/iomv.c
+++ acpi/arch/ia64/sn/kernel/iomv.c
@@ -16,6 +16,7 @@
 #include <asm/sn/pda.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/shub_mmr.h>
+#include <asm/sn/acpi.h>
 
 #define IS_LEGACY_VGA_IOPORT(p) \
 	(((p) >= 0x3b0 && (p) <= 0x3bb) || ((p) >= 0x3c0 && (p) <= 0x3df))
@@ -29,8 +30,6 @@
  * SN i/o address.  Used by sn_in*() and sn_out*().
  */
 
-extern int sn_acpi_base_support();
-
 void *sn_io_addr(unsigned long port)
 {
 	if (!IS_RUNNING_ON_SIMULATOR()) {
@@ -39,7 +38,7 @@ void *sn_io_addr(unsigned long port)
 		/* On sn2, legacy I/O ports don't point at anything */
 		if (port < (64 * 1024))
 			return NULL;
-		if (sn_acpi_base_support())
+		if (SN_ACPI_BASE_SUPPORT())
 			return (__ia64_mk_io_addr(port));
 		else
 			return ((void *)(port | __IA64_UNCACHED_OFFSET));
Index: acpi/include/asm-ia64/sn/acpi.h
=================================--- /dev/null
+++ acpi/include/asm-ia64/sn/acpi.h
@@ -0,0 +1,18 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2006 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_IA64_SN_ACPI_H
+#define _ASM_IA64_SN_ACPI_H
+
+#include "acpi/acglobal.h"
+
+#define SN_ACPI_BASE_SUPPORT()   sn_acpi_base_support()
+
+extern int sn_acpi_base_support(void);
+
+#endif /* _ASM_IA64_SN_ACPI_H */
