From: Mark Maule <maule@sgi.com>
Date: Fri, 04 Feb 2005 21:32:08 +0000
Subject: [PATCH 2.6.11-rc2 2/3] altix: move pci headers
Message-Id: <20050204213208.16671.47540.48258@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sn2-move-pci-headers.patch:

Move a couple of headers out of arch/ia64/sn/include/pci and into
include/asm-ia64/sn.

 arch/ia64/sn/include/pci/pcibus_provider_defs.h |   51 ---------------------
 arch/ia64/sn/include/pci/pcidev.h               |   58 ------------------------
 b/arch/ia64/sn/kernel/io_init.c                 |    4 -
 b/arch/ia64/sn/kernel/irq.c                     |    4 -
 b/arch/ia64/sn/pci/pci_dma.c                    |    4 -
 b/arch/ia64/sn/pci/pcibr/pcibr_ate.c            |    4 -
 b/arch/ia64/sn/pci/pcibr/pcibr_dma.c            |    4 -
 b/arch/ia64/sn/pci/pcibr/pcibr_provider.c       |    4 -
 b/arch/ia64/sn/pci/pcibr/pcibr_reg.c            |    4 -
 b/include/asm-ia64/sn/pcibus_provider_defs.h    |   51 +++++++++++++++++++++
 b/include/asm-ia64/sn/pcidev.h                  |   53 +++++++++++++++++++++
 11 files changed, 118 insertions(+), 123 deletions(-)

Signed-off-by: Mark Maule <maule@sgi.com>

diff -Nru a/arch/ia64/sn/include/pci/pcibus_provider_defs.h b/arch/ia64/sn/include/pci/pcibus_provider_defs.h
--- a/arch/ia64/sn/include/pci/pcibus_provider_defs.h	2005-02-04 15:00:36 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,51 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H
-#define _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H
-
-/*
- * SN pci asic types.  Do not ever renumber these or reuse values.  The
- * values must agree with what prom thinks they are.
- */
-
-#define PCIIO_ASIC_TYPE_UNKNOWN	0
-#define PCIIO_ASIC_TYPE_PPB	1
-#define PCIIO_ASIC_TYPE_PIC	2
-#define PCIIO_ASIC_TYPE_TIOCP	3
-
-#define PCIIO_ASIC_MAX_TYPES	4
-
-/*
- * Common pciio bus provider data.  There should be one of these as the
- * first field in any pciio based provider soft structure (e.g. pcibr_soft
- * tioca_soft, etc).
- */
-
-struct pcibus_bussoft {
-	uint32_t		bs_asic_type;	/* chipset type */
-	uint32_t		bs_xid;		/* xwidget id */
-	uint64_t		bs_persist_busnum; /* Persistent Bus Number */
-	uint64_t		bs_legacy_io;	/* legacy io pio addr */
-	uint64_t		bs_legacy_mem;	/* legacy mem pio addr */
-	uint64_t		bs_base;	/* widget base */
-	struct xwidget_info	*bs_xwidget_info;
-};
-
-/*
- * SN pci bus indirection
- */
-
-struct sn_pcibus_provider {
-	dma_addr_t	(*dma_map)(struct pci_dev *, unsigned long, size_t);
-	dma_addr_t	(*dma_map_consistent)(struct pci_dev *, unsigned long, size_t);
-	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
-	void *		(*bus_fixup)(struct pcibus_bussoft *);
-};
-
-extern struct sn_pcibus_provider *sn_pci_provider[];
-#endif				/* _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H */
diff -Nru a/arch/ia64/sn/include/pci/pcidev.h b/arch/ia64/sn/include/pci/pcidev.h
--- a/arch/ia64/sn/include/pci/pcidev.h	2005-02-04 15:00:36 -06:00
+++ /dev/null	Wed Dec 31 16:00:00 196900
@@ -1,58 +0,0 @@
-/*
- * This file is subject to the terms and conditions of the GNU General Public
- * License.  See the file "COPYING" in the main directory of this archive
- * for more details.
- *
- * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
- */
-#ifndef _ASM_IA64_SN_PCI_PCIDEV_H
-#define _ASM_IA64_SN_PCI_PCIDEV_H
-
-#include <linux/pci.h>
-
-extern struct sn_irq_info **sn_irq;
-
-#define SN_PCIDEV_INFO(pci_dev) \
-        ((struct pcidev_info *)(pci_dev)->sysdata)
-
-/*
- * Given a pci_bus, return the sn pcibus_bussoft struct.  Note that
- * this only works for root busses, not for busses represented by PPB's.
- */
-
-#define SN_PCIBUS_BUSSOFT(pci_bus) \
-        ((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
-
-/*
- * Given a struct pci_dev, return the sn pcibus_bussoft struct.  Note
- * that this is not equivalent to SN_PCIBUS_BUSSOFT(pci_dev->bus) due
- * due to possible PPB's in the path.
- */
-
-#define SN_PCIDEV_BUSSOFT(pci_dev) \
-	(SN_PCIDEV_INFO(pci_dev)->pdi_host_pcidev_info->pdi_pcibus_info)
-
-#define SN_PCIDEV_BUSPROVIDER(pci_dev) \
-	(SN_PCIDEV_INFO(pci_dev)->pdi_provider)
-
-#define PCIIO_BUS_NONE	255      /* bus 255 reserved */
-#define PCIIO_SLOT_NONE 255
-#define PCIIO_FUNC_NONE 255
-#define PCIIO_VENDOR_ID_NONE	(-1)
-
-struct pcidev_info {
-	uint64_t		pdi_pio_mapped_addr[7]; /* 6 BARs PLUS 1 ROM */
-	uint64_t		pdi_slot_host_handle;	/* Bus and devfn Host pci_dev */
-
-	struct pcibus_bussoft	*pdi_pcibus_info;	/* Kernel common bus soft */
-	struct pcidev_info	*pdi_host_pcidev_info;	/* Kernel Host pci_dev */
-	struct pci_dev		*pdi_linux_pcidev;	/* Kernel pci_dev */
-
-	struct sn_irq_info	*pdi_sn_irq_info;
-	struct sn_pcibus_provider *pdi_provider;	/* sn pci ops */
-};
-
-extern void sn_irq_fixup(struct pci_dev *pci_dev,
-			 struct sn_irq_info *sn_irq_info);
-
-#endif				/* _ASM_IA64_SN_PCI_PCIDEV_H */
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-02-04 15:00:36 -06:00
@@ -11,8 +11,8 @@
 #include <asm/sn/types.h>
 #include <asm/sn/sn_sal.h>
 #include <asm/sn/addrs.h>
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/pcibr_provider.h"
 #include "xtalk/xwidgetdev.h"
 #include <asm/sn/geo.h>
diff -Nru a/arch/ia64/sn/kernel/irq.c b/arch/ia64/sn/kernel/irq.c
--- a/arch/ia64/sn/kernel/irq.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/kernel/irq.c	2005-02-04 15:00:36 -06:00
@@ -13,8 +13,8 @@
 #include <asm/sn/addrs.h>
 #include <asm/sn/arch.h>
 #include "xtalk/xwidgetdev.h"
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/pcibr_provider.h"
 #include <asm/sn/shub_mmr.h>
 #include <asm/sn/sn_sal.h>
diff -Nru a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
--- a/arch/ia64/sn/pci/pci_dma.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/pci/pci_dma.c	2005-02-04 15:00:36 -06:00
@@ -12,8 +12,8 @@
 #include <linux/module.h>
 #include <asm/dma.h>
 #include <asm/sn/sn_sal.h>
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 
 #define SG_ENT_VIRT_ADDRESS(sg)	(page_address((sg)->page) + (sg)->offset)
 #define SG_ENT_PHYS_ADDRESS(SG)	virt_to_phys(SG_ENT_VIRT_ADDRESS(SG))
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_ate.c b/arch/ia64/sn/pci/pcibr/pcibr_ate.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_ate.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_ate.c	2005-02-04 15:00:36 -06:00
@@ -8,8 +8,8 @@
 
 #include <linux/types.h>
 #include <asm/sn/sn_sal.h>
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/pcibr_provider.h"
 
 int pcibr_invalidate_ate = 0;	/* by default don't invalidate ATE on free */
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2005-02-04 15:00:36 -06:00
@@ -12,8 +12,8 @@
 #include <asm/sn/geo.h>
 #include "xtalk/xwidgetdev.h"
 #include "xtalk/hubdev.h"
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/tiocp.h"
 #include "pci/pic.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_provider.c b/arch/ia64/sn/pci/pcibr/pcibr_provider.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-02-04 15:00:36 -06:00
@@ -13,8 +13,8 @@
 #include "xtalk/xwidgetdev.h"
 #include <asm/sn/geo.h>
 #include "xtalk/hubdev.h"
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/pcibr_provider.h"
 #include <asm/sn/addrs.h>
 
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_reg.c b/arch/ia64/sn/pci/pcibr/pcibr_reg.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-02-04 15:00:36 -06:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_reg.c	2005-02-04 15:00:36 -06:00
@@ -8,8 +8,8 @@
 
 #include <linux/types.h>
 #include <linux/interrupt.h>
-#include "pci/pcibus_provider_defs.h"
-#include "pci/pcidev.h"
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/pcidev.h>
 #include "pci/tiocp.h"
 #include "pci/pic.h"
 #include "pci/pcibr_provider.h"
diff -Nru a/include/asm-ia64/sn/pcibus_provider_defs.h b/include/asm-ia64/sn/pcibus_provider_defs.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/pcibus_provider_defs.h	2005-02-04 15:00:36 -06:00
@@ -0,0 +1,51 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H
+#define _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H
+
+/*
+ * SN pci asic types.  Do not ever renumber these or reuse values.  The
+ * values must agree with what prom thinks they are.
+ */
+
+#define PCIIO_ASIC_TYPE_UNKNOWN	0
+#define PCIIO_ASIC_TYPE_PPB	1
+#define PCIIO_ASIC_TYPE_PIC	2
+#define PCIIO_ASIC_TYPE_TIOCP	3
+
+#define PCIIO_ASIC_MAX_TYPES	4
+
+/*
+ * Common pciio bus provider data.  There should be one of these as the
+ * first field in any pciio based provider soft structure (e.g. pcibr_soft
+ * tioca_soft, etc).
+ */
+
+struct pcibus_bussoft {
+	uint32_t		bs_asic_type;	/* chipset type */
+	uint32_t		bs_xid;		/* xwidget id */
+	uint64_t		bs_persist_busnum; /* Persistent Bus Number */
+	uint64_t		bs_legacy_io;	/* legacy io pio addr */
+	uint64_t		bs_legacy_mem;	/* legacy mem pio addr */
+	uint64_t		bs_base;	/* widget base */
+	struct xwidget_info	*bs_xwidget_info;
+};
+
+/*
+ * SN pci bus indirection
+ */
+
+struct sn_pcibus_provider {
+	dma_addr_t	(*dma_map)(struct pci_dev *, unsigned long, size_t);
+	dma_addr_t	(*dma_map_consistent)(struct pci_dev *, unsigned long, size_t);
+	void		(*dma_unmap)(struct pci_dev *, dma_addr_t, int);
+	void *		(*bus_fixup)(struct pcibus_bussoft *);
+};
+
+extern struct sn_pcibus_provider *sn_pci_provider[];
+#endif				/* _ASM_IA64_SN_PCI_PCIBUS_PROVIDER_H */
diff -Nru a/include/asm-ia64/sn/pcidev.h b/include/asm-ia64/sn/pcidev.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/pcidev.h	2005-02-04 15:00:36 -06:00
@@ -0,0 +1,53 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 1992 - 1997, 2000-2004 Silicon Graphics, Inc. All rights reserved.
+ */
+#ifndef _ASM_IA64_SN_PCI_PCIDEV_H
+#define _ASM_IA64_SN_PCI_PCIDEV_H
+
+#include <linux/pci.h>
+
+extern struct sn_irq_info **sn_irq;
+
+#define SN_PCIDEV_INFO(pci_dev) \
+        ((struct pcidev_info *)(pci_dev)->sysdata)
+
+/*
+ * Given a pci_bus, return the sn pcibus_bussoft struct.  Note that
+ * this only works for root busses, not for busses represented by PPB's.
+ */
+
+#define SN_PCIBUS_BUSSOFT(pci_bus) \
+        ((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
+
+/*
+ * Given a struct pci_dev, return the sn pcibus_bussoft struct.  Note
+ * that this is not equivalent to SN_PCIBUS_BUSSOFT(pci_dev->bus) due
+ * due to possible PPB's in the path.
+ */
+
+#define SN_PCIDEV_BUSSOFT(pci_dev) \
+	(SN_PCIDEV_INFO(pci_dev)->pdi_host_pcidev_info->pdi_pcibus_info)
+
+#define SN_PCIDEV_BUSPROVIDER(pci_dev) \
+	(SN_PCIDEV_INFO(pci_dev)->pdi_provider)
+
+struct pcidev_info {
+	uint64_t		pdi_pio_mapped_addr[7]; /* 6 BARs PLUS 1 ROM */
+	uint64_t		pdi_slot_host_handle;	/* Bus and devfn Host pci_dev */
+
+	struct pcibus_bussoft	*pdi_pcibus_info;	/* Kernel common bus soft */
+	struct pcidev_info	*pdi_host_pcidev_info;	/* Kernel Host pci_dev */
+	struct pci_dev		*pdi_linux_pcidev;	/* Kernel pci_dev */
+
+	struct sn_irq_info	*pdi_sn_irq_info;
+	struct sn_pcibus_provider *pdi_provider;	/* sn pci ops */
+};
+
+extern void sn_irq_fixup(struct pci_dev *pci_dev,
+			 struct sn_irq_info *sn_irq_info);
+
+#endif				/* _ASM_IA64_SN_PCI_PCIDEV_H */
