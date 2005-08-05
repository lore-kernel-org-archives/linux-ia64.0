From: Mark Maule <maule@sgi.com>
Date: Fri, 05 Aug 2005 21:13:28 +0000
Subject: [PATCH 2.6.13 6/6] altix: enable TIOCE pci express chip provider
Message-Id: <20050805211328.5173.59058.20604@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Altix patch to enable pci provider for TIOCE, SGI's PCI Express chip.

Correct a build warning in io_init.c.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: ce-submit2/arch/ia64/sn/pci/Makefile
=================================--- ce-submit2.orig/arch/ia64/sn/pci/Makefile	2005-08-05 15:47:01.123312425 -0500
+++ ce-submit2/arch/ia64/sn/pci/Makefile	2005-08-05 15:54:27.401924836 -0500
@@ -7,4 +7,4 @@
 #
 # Makefile for the sn pci general routines.
 
-obj-y := pci_dma.o tioca_provider.o pcibr/ 
+obj-y := pci_dma.o tioca_provider.o tioce_provider.o pcibr/
Index: ce-submit2/include/asm-ia64/sn/pcibus_provider_defs.h
=================================--- ce-submit2.orig/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-05 15:47:01.124288890 -0500
+++ ce-submit2/include/asm-ia64/sn/pcibus_provider_defs.h	2005-08-05 15:54:27.413642414 -0500
@@ -18,8 +18,9 @@
 #define PCIIO_ASIC_TYPE_PIC	2
 #define PCIIO_ASIC_TYPE_TIOCP	3
 #define PCIIO_ASIC_TYPE_TIOCA	4
+#define PCIIO_ASIC_TYPE_TIOCE	5
 
-#define PCIIO_ASIC_MAX_TYPES	5
+#define PCIIO_ASIC_MAX_TYPES	6
 
 /*
  * Common pciio bus provider data.  There should be one of these as the
Index: ce-submit2/arch/ia64/sn/kernel/io_init.c
=================================--- ce-submit2.orig/arch/ia64/sn/kernel/io_init.c	2005-08-05 15:47:01.123312425 -0500
+++ ce-submit2/arch/ia64/sn/kernel/io_init.c	2005-08-05 16:11:56.277336017 -0500
@@ -18,6 +18,7 @@
 #include <asm/sn/simulator.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/tioca_provider.h>
+#include <asm/sn/tioce_provider.h>
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
 
@@ -406,9 +407,11 @@
 	if (controller->node >= num_online_nodes()) {
 		struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
 
-		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%lu"
+		printk(KERN_WARNING "Device ASIC=%u XID=%u "
+				    "PSEGNUM=%x PBUSNUM=%x "
 				    "L_IO=%lx L_MEM=%lx BASE=%lx\n",
-			b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
+			b->bs_asic_type, b->bs_xid,
+			b->bs_persist_segment, b->bs_persist_busnum,
 			b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
 		printk(KERN_WARNING "on node %d but only %d nodes online."
 			"Association set to undetermined.\n",
@@ -481,6 +484,7 @@
 
 	pcibr_init_provider();
 	tioca_init_provider();
+	tioce_init_provider();
 
 	/*
 	 * This is needed to avoid bounce limit checks in the blk layer
