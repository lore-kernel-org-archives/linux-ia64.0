From: Mark Maule <maule@sgi.com>
Date: Thu, 10 Mar 2005 21:55:53 +0000
Subject: [PATCH 2.6.11-rc2 3/3] altix: tioca chip driver (agp)
Message-Id: <20050310215553.16305.80438.34368@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
In-Reply-To: <20050204213213.16671.77171.95362@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

sn2-tioca-driver.patch:

Provide a driver for the altix TIOCA AGP chipset.  An agpgart backend will
be provided as a separate patch.

Signed-off-by: Mark Maule <maule@sgi.com>

diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2005-02-07 15:50:04 -06:00
+++ b/arch/ia64/sn/kernel/io_init.c	2005-02-07 15:50:04 -06:00
@@ -19,6 +19,7 @@
 #include "xtalk/hubdev.h"
 #include <asm/sn/io.h>
 #include <asm/sn/simulator.h>
+#include <asm/sn/tioca_provider.h>
 
 char master_baseio_wid;
 nasid_t master_nasid = INVALID_NASID;	/* Partition Master */
@@ -393,6 +394,7 @@
 		sn_pci_provider[i] = &sn_pci_default_provider;
 
 	pcibr_init_provider();
+	tioca_init_provider();
 
 	/*
 	 * This is needed to avoid bounce limit checks in the blk layer
diff -Nru a/arch/ia64/sn/pci/Makefile b/arch/ia64/sn/pci/Makefile
--- a/arch/ia64/sn/pci/Makefile	2005-02-07 15:50:04 -06:00
+++ b/arch/ia64/sn/pci/Makefile	2005-02-07 15:50:04 -06:00
@@ -7,4 +7,4 @@
 #
 # Makefile for the sn pci general routines.
 
-obj-y := pci_dma.o pcibr/ 
+obj-y := pci_dma.o tioca_provider.o pcibr/ 
diff -Nru a/arch/ia64/sn/pci/tioca_provider.c b/arch/ia64/sn/pci/tioca_provider.c
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/arch/ia64/sn/pci/tioca_provider.c	2005-02-07 15:50:04 -06:00
@@ -0,0 +1,668 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (C) 2003-2005 Silicon Graphics, Inc.  All Rights Reserved.
+ */
+
+#include <linux/types.h>
+#include <linux/interrupt.h>
+#include <linux/pci.h>
+#include <asm/sn/sn_sal.h>
+#include <asm/sn/addrs.h>
+#include <asm/sn/pcidev.h>
+#include <asm/sn/pcibus_provider_defs.h>
+#include <asm/sn/tioca_provider.h>
+
+uint32_t tioca_gart_found;
+EXPORT_SYMBOL(tioca_gart_found);	/* used by agp-sgi */
+
+LIST_HEAD(tioca_list);
+EXPORT_SYMBOL(tioca_list);	/* used by agp-sgi */
+
+static int tioca_gart_init(struct tioca_kernel *);
+
+/**
+ * tioca_gart_init - Initialize SGI TIOCA GART
+ * @tioca_common: ptr to common prom/kernel struct identifying the 
+ *
+ * If the indicated tioca has devices present, initialize its associated
+ * GART MMR's and kernel memory.
+ */
+static int
+tioca_gart_init(struct tioca_kernel *tioca_kern)
+{
+	uint64_t ap_reg;
+	uint64_t offset;
+	struct page *tmp;
+	struct tioca_common *tioca_common;
+	volatile struct tioca *ca_base;
+
+	tioca_common = tioca_kern->ca_common;
+	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
+
+	if (list_empty(tioca_kern->ca_devices))
+		return 0;
+
+	ap_reg = 0;
+
+	/*
+	 * Validate aperature size
+	 */
+
+	switch (CA_APERATURE_SIZE >> 20) {
+	case 4:
+		ap_reg |= (0x3ff << CA_GART_AP_SIZE_SHFT);	/* 4MB */
+		break;
+	case 8:
+		ap_reg |= (0x3fe << CA_GART_AP_SIZE_SHFT);	/* 8MB */
+		break;
+	case 16:
+		ap_reg |= (0x3fc << CA_GART_AP_SIZE_SHFT);	/* 16MB */
+		break;
+	case 32:
+		ap_reg |= (0x3f8 << CA_GART_AP_SIZE_SHFT);	/* 32 MB */
+		break;
+	case 64:
+		ap_reg |= (0x3f0 << CA_GART_AP_SIZE_SHFT);	/* 64 MB */
+		break;
+	case 128:
+		ap_reg |= (0x3e0 << CA_GART_AP_SIZE_SHFT);	/* 128 MB */
+		break;
+	case 256:
+		ap_reg |= (0x3c0 << CA_GART_AP_SIZE_SHFT);	/* 256 MB */
+		break;
+	case 512:
+		ap_reg |= (0x380 << CA_GART_AP_SIZE_SHFT);	/* 512 MB */
+		break;
+	case 1024:
+		ap_reg |= (0x300 << CA_GART_AP_SIZE_SHFT);	/* 1GB */
+		break;
+	case 2048:
+		ap_reg |= (0x200 << CA_GART_AP_SIZE_SHFT);	/* 2GB */
+		break;
+	case 4096:
+		ap_reg |= (0x000 << CA_GART_AP_SIZE_SHFT);	/* 4 GB */
+		break;
+	default:
+		printk(KERN_ERR "%s:  Invalid CA_APERATURE_SIZE "
+		       "0x%lx\n", __FUNCTION__, (ulong) CA_APERATURE_SIZE);
+		return -1;
+	}
+
+	/*
+	 * Set up other aperature parameters
+	 */
+
+	if (PAGE_SIZE >= 16384) {
+		tioca_kern->ca_ap_pagesize = 16384;
+		ap_reg |= CA_GART_PAGE_SIZE;
+	} else {
+		tioca_kern->ca_ap_pagesize = 4096;
+	}
+
+	tioca_kern->ca_ap_size = CA_APERATURE_SIZE;
+	tioca_kern->ca_ap_bus_base = CA_APERATURE_BASE;
+	tioca_kern->ca_gart_entries +	    tioca_kern->ca_ap_size / tioca_kern->ca_ap_pagesize;
+
+	ap_reg |= (CA_GART_AP_ENB_AGP | CA_GART_AP_ENB_PCI);
+	ap_reg |= tioca_kern->ca_ap_bus_base;
+
+	/*
+	 * Allocate and set up the GART
+	 */
+
+	tioca_kern->ca_gart_size = tioca_kern->ca_gart_entries * sizeof(u64);
+	tmp +	    alloc_pages_node(tioca_kern->ca_closest_node,
+			     GFP_KERNEL | __GFP_ZERO,
+			     get_order(tioca_kern->ca_gart_size));
+
+	if (!tmp) {
+		printk(KERN_ERR "%s:  Could not allocate "
+		       "%lu bytes (order %d) for GART\n",
+		       __FUNCTION__,
+		       tioca_kern->ca_gart_size,
+		       get_order(tioca_kern->ca_gart_size));
+		return -ENOMEM;
+	}
+
+	tioca_kern->ca_gart = page_address(tmp);
+	tioca_kern->ca_gart_coretalk_addr +	    PHYS_TO_TIODMA(virt_to_phys(tioca_kern->ca_gart));
+
+	/*
+	 * Compute PCI/AGP convenience fields 
+	 */
+
+	offset = CA_PCI32_MAPPED_BASE - CA_APERATURE_BASE;
+	tioca_kern->ca_pciap_base = CA_PCI32_MAPPED_BASE;
+	tioca_kern->ca_pciap_size = CA_PCI32_MAPPED_SIZE;
+	tioca_kern->ca_pcigart_start = offset / tioca_kern->ca_ap_pagesize;
+	tioca_kern->ca_pcigart_base +	    tioca_kern->ca_gart_coretalk_addr + offset;
+	tioca_kern->ca_pcigart +	    &tioca_kern->ca_gart[tioca_kern->ca_pcigart_start];
+	tioca_kern->ca_pcigart_entries +	    tioca_kern->ca_pciap_size / tioca_kern->ca_ap_pagesize;
+	tioca_kern->ca_pcigart_pagemap +	    kcalloc(1, tioca_kern->ca_pcigart_entries / 8, GFP_KERNEL);
+	if (!tioca_kern->ca_pcigart_pagemap) {
+		free_pages((unsigned long)tioca_kern->ca_gart,
+			   get_order(tioca_kern->ca_gart_size));
+		return -1;
+	}
+
+	offset = CA_AGP_MAPPED_BASE - CA_APERATURE_BASE;
+	tioca_kern->ca_gfxap_base = CA_AGP_MAPPED_BASE;
+	tioca_kern->ca_gfxap_size = CA_AGP_MAPPED_SIZE;
+	tioca_kern->ca_gfxgart_start = offset / tioca_kern->ca_ap_pagesize;
+	tioca_kern->ca_gfxgart_base +	    tioca_kern->ca_gart_coretalk_addr + offset;
+	tioca_kern->ca_gfxgart +	    &tioca_kern->ca_gart[tioca_kern->ca_gfxgart_start];
+	tioca_kern->ca_gfxgart_entries +	    tioca_kern->ca_gfxap_size / tioca_kern->ca_ap_pagesize;
+
+	/*
+	 * various control settings:
+	 *      use agp op-combining
+	 *      use GET semantics to fetch memory
+	 *      participate in coherency domain
+	 *      prefetch TLB entries
+	 */
+
+	ca_base->ca_control1 |= CA_AGPDMA_OP_ENB_COMBDELAY;	/* PV895469 ? */
+	ca_base->ca_control2 &= ~(CA_GART_MEM_PARAM);
+	ca_base->ca_control2 |= (0x2ull << CA_GART_MEM_PARAM_SHFT);
+	tioca_kern->ca_gart_iscoherent = 1;
+	ca_base->ca_control2 |+	    (CA_GART_WR_PREFETCH_ENB | CA_GART_RD_PREFETCH_ENB);
+
+	/*
+	 * Unmask GART fetch error interrupts.  Clear residual errors first.
+	 */
+
+	ca_base->ca_int_status_alias = CA_GART_FETCH_ERR;
+	ca_base->ca_mult_error_alias = CA_GART_FETCH_ERR;
+	ca_base->ca_int_mask &= ~CA_GART_FETCH_ERR;
+
+	/*
+	 * Program the aperature and gart registers in TIOCA
+	 */
+
+	ca_base->ca_gart_aperature = ap_reg;
+	ca_base->ca_gart_ptr_table = tioca_kern->ca_gart_coretalk_addr | 1;
+
+	return 0;
+}
+
+/**
+ * tioca_fastwrite_enable - enable AGP FW for a tioca and its functions
+ * @tioca_kernel: structure representing the CA
+ *
+ * Given a CA, scan all attached functions making sure they all support
+ * FastWrite.  If so, enable FastWrite for all functions and the CA itself.
+ */
+
+void
+tioca_fastwrite_enable(struct tioca_kernel *tioca_kern)
+{
+	int cap_ptr;
+	uint64_t ca_control1;
+	uint32_t reg;
+	struct tioca *tioca_base;
+	struct pci_dev *pdev;
+	struct tioca_common *common;
+
+	common = tioca_kern->ca_common;
+
+	/*
+	 * Scan all vga controllers on this bus making sure they all
+	 * suport FW.  If not, return.
+	 */
+
+	list_for_each_entry(pdev, tioca_kern->ca_devices, bus_list) {
+		if (pdev->class != (PCI_CLASS_DISPLAY_VGA << 8))
+			continue;
+
+		cap_ptr = pci_find_capability(pdev, PCI_CAP_ID_AGP);
+		if (!cap_ptr)
+			return;	/* no AGP CAP means no FW */
+
+		pci_read_config_dword(pdev, cap_ptr + PCI_AGP_STATUS, &reg);
+		if (!(reg & PCI_AGP_STATUS_FW))
+			return;	/* function doesn't support FW */
+	}
+
+	/*
+	 * Set fw for all vga fn's
+	 */
+
+	list_for_each_entry(pdev, tioca_kern->ca_devices, bus_list) {
+		if (pdev->class != (PCI_CLASS_DISPLAY_VGA << 8))
+			continue;
+
+		cap_ptr = pci_find_capability(pdev, PCI_CAP_ID_AGP);
+		pci_read_config_dword(pdev, cap_ptr + PCI_AGP_COMMAND, &reg);
+		reg |= PCI_AGP_COMMAND_FW;
+		pci_write_config_dword(pdev, cap_ptr + PCI_AGP_COMMAND, reg);
+	}
+
+	/*
+	 * Set ca's fw to match
+	 */
+
+	tioca_base = (struct tioca *)common->ca_common.bs_base;
+	ca_control1 = tioca_base->ca_control1;
+	ca_control1 |= CA_AGP_FW_ENABLE;
+	tioca_base->ca_control1 = ca_control1;
+}
+
+EXPORT_SYMBOL(tioca_fastwrite_enable);	/* used by agp-sgi */
+
+/**
+ * tioca_dma_d64 - create a DMA mapping using 64-bit direct mode
+ * @paddr: system physical address
+ *
+ * Map @paddr into 64-bit CA bus space.  No device context is necessary.
+ * Bits 53:0 come from the coretalk address.  We just need to mask in the
+ * following optional bits of the 64-bit pci address:
+ *
+ * 63:60 - Coretalk Packet Type -  0x1 for Mem Get/Put (coherent)
+ *                                 0x2 for PIO (non-coherent)
+ *                                 We will always use 0x1
+ * 55:55 - Swap bytes		   Currently unused
+ */
+static uint64_t
+tioca_dma_d64(unsigned long paddr)
+{
+	dma_addr_t bus_addr;
+
+	bus_addr = PHYS_TO_TIODMA(paddr);
+
+	BUG_ON(!bus_addr);
+	BUG_ON(bus_addr >> 54);
+
+	/* Set upper nibble to Cache Coherent Memory op */
+	bus_addr |= (1UL << 60);
+
+	return bus_addr;
+}
+
+/**
+ * tioca_dma_d48 - create a DMA mapping using 48-bit direct mode
+ * @pdev: linux pci_dev representing the function
+ * @paddr: system physical address
+ *
+ * Map @paddr into 64-bit bus space of the CA associated with @pcidev_info.
+ *
+ * The CA agp 48 bit direct address falls out as follows:
+ *
+ * When direct mapping AGP addresses, the 48 bit AGP address is
+ * constructed as follows:
+ *
+ * [47:40] - Low 8 bits of the page Node ID extracted from coretalk
+ *              address [47:40].  The upper 8 node bits are fixed
+ *              and come from the xxx register bits [5:0]
+ * [39:38] - Chiplet ID extracted from coretalk address [39:38]
+ * [37:00] - node offset extracted from coretalk address [37:00]
+ * 
+ * Since the node id in general will be non-zero, and the chiplet id
+ * will always be non-zero, it follows that the device must support
+ * a dma mask of at least 0xffffffffff (40 bits) to target node 0
+ * and in general should be 0xffffffffffff (48 bits) to target nodes
+ * up to 255.  Nodes above 255 need the support of the xxx register,
+ * and so a given CA can only directly target nodes in the range
+ * xxx - xxx+255.
+ */
+static uint64_t
+tioca_dma_d48(struct pci_dev *pdev, uint64_t paddr)
+{
+	struct tioca_common *tioca_common;
+	struct tioca *ca_base;
+	uint64_t ct_addr;
+	dma_addr_t bus_addr;
+	uint32_t node_upper;
+	uint64_t agp_dma_extn;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(pdev);
+
+	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
+	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
+
+	ct_addr = PHYS_TO_TIODMA(paddr);
+	if (!ct_addr)
+		return 0;
+
+	bus_addr = (dma_addr_t) (ct_addr & 0xffffffffffff);
+	node_upper = ct_addr >> 48;
+
+	if (node_upper > 64) {
+		printk(KERN_ERR "%s:  coretalk addr 0x%p node id out "
+		       "of range\n", __FUNCTION__, (void *)ct_addr);
+		return 0;
+	}
+
+	agp_dma_extn = ca_base->ca_agp_dma_addr_extn;
+	if (node_upper != (agp_dma_extn >> CA_AGP_DMA_NODE_ID_SHFT)) {
+		printk(KERN_ERR "%s:  coretalk upper node (%u) "
+		       "mismatch with ca_agp_dma_addr_extn (%lu)\n",
+		       __FUNCTION__,
+		       node_upper, (agp_dma_extn >> CA_AGP_DMA_NODE_ID_SHFT));
+		return 0;
+	}
+
+	return bus_addr;
+}
+
+/**
+ * tioca_dma_mapped - create a DMA mapping using a CA GART 
+ * @pdev: linux pci_dev representing the function
+ * @paddr: host physical address to map
+ * @req_size: len (bytes) to map
+ *
+ * Map @paddr into CA address space using the GART mechanism.  The mapped
+ * dma_addr_t is guarenteed to be contiguous in CA bus space.
+ */
+static dma_addr_t
+tioca_dma_mapped(struct pci_dev *pdev, uint64_t paddr, size_t req_size)
+{
+	int i, ps, ps_shift, entry, entries, mapsize, last_entry;
+	uint64_t xio_addr, end_xio_addr;
+	struct tioca_common *tioca_common;
+	struct tioca_kernel *tioca_kern;
+	dma_addr_t bus_addr = 0;
+	struct tioca_dmamap *ca_dmamap;
+	void *map;
+	unsigned long flags;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(pdev);;
+
+	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
+	tioca_kern = (struct tioca_kernel *)tioca_common->ca_kernel_private;
+
+	xio_addr = PHYS_TO_TIODMA(paddr);
+	if (!xio_addr)
+		return 0;
+
+	spin_lock_irqsave(&tioca_kern->ca_lock, flags);
+
+	/*
+	 * allocate a map struct
+	 */
+
+	ca_dmamap = kcalloc(1, sizeof(struct tioca_dmamap), GFP_ATOMIC);
+	if (!ca_dmamap)
+		goto map_return;
+
+	/*
+	 * Locate free entries that can hold req_size.  Account for
+	 * unaligned start/length when allocating.
+	 */
+
+	ps = tioca_kern->ca_ap_pagesize;	/* will be power of 2 */
+	ps_shift = ffs(ps) - 1;
+	end_xio_addr = xio_addr + req_size - 1;
+
+	entries = (end_xio_addr >> ps_shift) - (xio_addr >> ps_shift) + 1;
+
+	map = tioca_kern->ca_pcigart_pagemap;
+	mapsize = tioca_kern->ca_pcigart_entries;
+
+	entry = find_first_zero_bit(map, mapsize);
+	while (entry < mapsize) {
+		last_entry = find_next_bit(map, mapsize, entry);
+
+		if (last_entry - entry >= entries)
+			break;
+
+		entry = find_next_zero_bit(map, mapsize, last_entry);
+	}
+
+	if (entry > mapsize)
+		goto map_return;
+
+	for (i = 0; i < entries; i++)
+		set_bit(entry + i, map);
+
+	bus_addr = tioca_kern->ca_pciap_base + (entry * ps);
+
+	ca_dmamap->cad_dma_addr = bus_addr;
+	ca_dmamap->cad_gart_size = entries;
+	ca_dmamap->cad_gart_entry = entry;
+	list_add(&ca_dmamap->cad_list, &tioca_kern->ca_list);
+
+	if (xio_addr % ps) {
+		tioca_kern->ca_pcigart[entry] = tioca_paddr_to_gart(xio_addr);
+		bus_addr += xio_addr & (ps - 1);
+		xio_addr &= ~(ps - 1);
+		xio_addr += ps;
+		entry++;
+	}
+
+	while (xio_addr < end_xio_addr) {
+		tioca_kern->ca_pcigart[entry] = tioca_paddr_to_gart(xio_addr);
+		xio_addr += ps;
+		entry++;
+	}
+
+	tioca_tlbflush(tioca_kern);
+
+map_return:
+	spin_unlock_irqrestore(&tioca_kern->ca_lock, flags);
+	return bus_addr;
+}
+
+/**
+ * tioca_dma_unmap - release CA mapping resources
+ * @pdev: linux pci_dev representing the function
+ * @bus_addr: bus address returned by an earlier tioca_dma_map
+ * @dir: mapping direction (unused)
+ *
+ * Locate mapping resources associated with @bus_addr and release them.
+ * For mappings created using the direct modes (64 or 48) there are no
+ * resources to release.
+ */
+void
+tioca_dma_unmap(struct pci_dev *pdev, dma_addr_t bus_addr, int dir)
+{
+	int i, entry;
+	struct tioca_common *tioca_common;
+	struct tioca_kernel *tioca_kern;
+	struct tioca_dmamap *map;
+	struct pcidev_info *pcidev_info = SN_PCIDEV_INFO(pdev);
+	unsigned long flags;
+
+	tioca_common = (struct tioca_common *)pcidev_info->pdi_pcibus_info;
+	tioca_kern = (struct tioca_kernel *)tioca_common->ca_kernel_private;
+
+	/* return straight away if this isn't be a mapped address */
+
+	if (bus_addr < tioca_kern->ca_pciap_base ||
+	    bus_addr >= (tioca_kern->ca_pciap_base + tioca_kern->ca_pciap_size))
+		return;
+
+	spin_lock_irqsave(&tioca_kern->ca_lock, flags);
+
+	list_for_each_entry(map, &tioca_kern->ca_dmamaps, cad_list)
+	    if (map->cad_dma_addr = bus_addr)
+		break;
+
+	BUG_ON(map = NULL);
+
+	entry = map->cad_gart_entry;
+
+	for (i = 0; i < map->cad_gart_size; i++, entry++) {
+		clear_bit(entry, tioca_kern->ca_pcigart_pagemap);
+		tioca_kern->ca_pcigart[entry] = 0;
+	}
+	tioca_tlbflush(tioca_kern);
+
+	list_del(&map->cad_list);
+	spin_unlock_irqrestore(&tioca_kern->ca_lock, flags);
+	kfree(map);
+}
+
+/**
+ * tioca_dma_map - map pages for PCI DMA
+ * @pdev: linux pci_dev representing the function
+ * @paddr: host physical address to map
+ * @byte_count: bytes to map
+ *
+ * This is the main wrapper for mapping host physical pages to CA PCI space.
+ * The mapping mode used is based on the devices dma_mask.  As a last resort
+ * use the GART mapped mode.
+ */
+uint64_t
+tioca_dma_map(struct pci_dev *pdev, uint64_t paddr, size_t byte_count)
+{
+	uint64_t mapaddr;
+
+	/*
+	 * If card is 64 or 48 bit addresable, use a direct mapping.  32
+	 * bit direct is so restrictive w.r.t. where the memory resides that
+	 * we don't use it even though CA has some support.
+	 */
+
+	if (pdev->dma_mask = ~0UL)
+		mapaddr = tioca_dma_d64(paddr);
+	else if (pdev->dma_mask = 0xffffffffffffUL)
+		mapaddr = tioca_dma_d48(pdev, paddr);
+	else
+		mapaddr = 0;
+
+	/* Last resort ... use PCI portion of CA GART */
+
+	if (mapaddr = 0)
+		mapaddr = tioca_dma_mapped(pdev, paddr, byte_count);
+
+	return mapaddr;
+}
+
+/**
+ * tioca_error_intr_handler - SGI TIO CA error interrupt handler
+ * @irq: unused
+ * @arg: pointer to tioca_common struct for the given CA
+ * @pt: unused
+ *
+ * Handle a CA error interrupt.  Simply a wrapper around a SAL call which
+ * defers processing to the SGI prom.
+ */
+static irqreturn_t
+tioca_error_intr_handler(int irq, void *arg, struct pt_regs *pt)
+{
+	struct tioca_common *soft = arg;
+	struct ia64_sal_retval ret_stuff;
+	uint64_t segment;
+	uint64_t busnum;
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	segment = 0;
+	busnum = soft->ca_common.bs_persist_busnum;
+
+	SAL_CALL_NOLOCK(ret_stuff,
+			(u64) SN_SAL_IOIF_ERROR_INTERRUPT,
+			segment, busnum, 0, 0, 0, 0, 0);
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * tioca_bus_fixup - perform final PCI fixup for a TIO CA bus
+ * @prom_bussoft: Common prom/kernel struct representing the bus
+ *
+ * Replicates the tioca_common pointed to by @prom_bussoft in kernel
+ * space.  Allocates and initializes a kernel-only area for a given CA,
+ * and sets up an irq for handling CA error interrupts.
+ *
+ * On successful setup, returns the kernel version of tioca_common back to
+ * the caller.
+ */
+void *
+tioca_bus_fixup(struct pcibus_bussoft *prom_bussoft)
+{
+	struct tioca_common *tioca_common;
+	struct tioca_kernel *tioca_kern;
+	struct pci_bus *bus;
+
+	/* sanity check prom rev */
+
+	if (sn_sal_rev_major() < 4 ||
+	    (sn_sal_rev_major() = 4 && sn_sal_rev_minor() < 6)) {
+		printk
+		    (KERN_ERR "%s:  SGI prom rev 4.06 or greater required "
+		     "for tioca support\n", __FUNCTION__);
+		return NULL;
+	}
+
+	/*
+	 * Allocate kernel bus soft and copy from prom.
+	 */
+
+	tioca_common = kcalloc(1, sizeof(struct tioca_common), GFP_KERNEL);
+	if (!tioca_common)
+		return NULL;
+
+	memcpy(tioca_common, prom_bussoft, sizeof(struct tioca_common));
+	tioca_common->ca_common.bs_base |= __IA64_UNCACHED_OFFSET;
+
+	/* init kernel-private area */
+
+	tioca_kern = kcalloc(1, sizeof(struct tioca_kernel), GFP_KERNEL);
+	if (!tioca_kern) {
+		kfree(tioca_common);
+		return NULL;
+	}
+
+	tioca_kern->ca_common = tioca_common;
+	spin_lock_init(&tioca_kern->ca_lock);
+	INIT_LIST_HEAD(&tioca_kern->ca_dmamaps);
+	tioca_kern->ca_closest_node +	    nasid_to_cnodeid(tioca_common->ca_closest_nasid);
+	tioca_common->ca_kernel_private = (uint64_t) tioca_kern;
+
+	bus = pci_find_bus(0, tioca_common->ca_common.bs_persist_busnum);
+	BUG_ON(!bus);
+	tioca_kern->ca_devices = &bus->devices;
+
+	/* init GART */
+
+	if (tioca_gart_init(tioca_kern) < 0) {
+		kfree(tioca_kern);
+		kfree(tioca_common);
+		return NULL;
+	}
+
+	tioca_gart_found++;
+	list_add(&tioca_kern->ca_list, &tioca_list);
+
+	if (request_irq(SGI_TIOCA_ERROR,
+			tioca_error_intr_handler,
+			SA_SHIRQ, "TIOCA error", (void *)tioca_common))
+		printk(KERN_WARNING
+		       "%s:  Unable to get irq %d.  "
+		       "Error interrupts won't be routed for TIOCA bus %d\n",
+		       __FUNCTION__, SGI_TIOCA_ERROR,
+		       (int)tioca_common->ca_common.bs_persist_busnum);
+
+	return tioca_common;
+}
+
+static struct sn_pcibus_provider tioca_pci_interfaces = {
+	.dma_map = tioca_dma_map,
+	.dma_map_consistent = tioca_dma_map,
+	.dma_unmap = tioca_dma_unmap,
+	.bus_fixup = tioca_bus_fixup,
+};
+
+/**
+ * tioca_init_provider - init SN PCI provider ops for TIO CA
+ */
+int
+tioca_init_provider(void)
+{
+	sn_pci_provider[PCIIO_ASIC_TYPE_TIOCA] = &tioca_pci_interfaces;
+	return 0;
+}
diff -Nru a/include/asm-ia64/sn/pcibus_provider_defs.h b/include/asm-ia64/sn/pcibus_provider_defs.h
--- a/include/asm-ia64/sn/pcibus_provider_defs.h	2005-02-07 15:50:04 -06:00
+++ b/include/asm-ia64/sn/pcibus_provider_defs.h	2005-02-07 15:50:04 -06:00
@@ -17,8 +17,9 @@
 #define PCIIO_ASIC_TYPE_PPB	1
 #define PCIIO_ASIC_TYPE_PIC	2
 #define PCIIO_ASIC_TYPE_TIOCP	3
+#define PCIIO_ASIC_TYPE_TIOCA	4
 
-#define PCIIO_ASIC_MAX_TYPES	4
+#define PCIIO_ASIC_MAX_TYPES	5
 
 /*
  * Common pciio bus provider data.  There should be one of these as the
diff -Nru a/include/asm-ia64/sn/tioca.h b/include/asm-ia64/sn/tioca.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/tioca.h	2005-02-07 15:50:04 -06:00
@@ -0,0 +1,596 @@
+#ifndef _ASM_IA64_SN_TIO_TIOCA_H
+#define _ASM_IA64_SN_TIO_TIOCA_H
+
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2003-2005 Silicon Graphics, Inc. All rights reserved.
+ */
+
+
+#define TIOCA_PART_NUM	0xE020
+#define TIOCA_MFGR_NUM	0x24
+#define TIOCA_REV_A	0x1
+
+/*
+ * Register layout for TIO:CA.  See below for bitmasks for each register.
+ */
+
+struct tioca {
+	uint64_t	ca_id;				/* 0x000000 */
+	uint64_t	ca_control1;			/* 0x000008 */
+	uint64_t	ca_control2;			/* 0x000010 */
+	uint64_t	ca_status1;			/* 0x000018 */
+	uint64_t	ca_status2;			/* 0x000020 */
+	uint64_t	ca_gart_aperature;		/* 0x000028 */
+	uint64_t	ca_gfx_detach;			/* 0x000030 */
+	uint64_t	ca_inta_dest_addr;		/* 0x000038 */
+	uint64_t	ca_intb_dest_addr;		/* 0x000040 */
+	uint64_t	ca_err_int_dest_addr;		/* 0x000048 */
+	uint64_t	ca_int_status;			/* 0x000050 */
+	uint64_t	ca_int_status_alias;		/* 0x000058 */
+	uint64_t	ca_mult_error;			/* 0x000060 */
+	uint64_t	ca_mult_error_alias;		/* 0x000068 */
+	uint64_t	ca_first_error;			/* 0x000070 */
+	uint64_t	ca_int_mask;			/* 0x000078 */
+	uint64_t	ca_crm_pkterr_type;		/* 0x000080 */
+	uint64_t	ca_crm_pkterr_type_alias;	/* 0x000088 */
+	uint64_t	ca_crm_ct_error_detail_1;	/* 0x000090 */
+	uint64_t	ca_crm_ct_error_detail_2;	/* 0x000098 */
+	uint64_t	ca_crm_tnumto;			/* 0x0000A0 */
+	uint64_t	ca_gart_err;			/* 0x0000A8 */
+	uint64_t	ca_pcierr_type;			/* 0x0000B0 */
+	uint64_t	ca_pcierr_addr;			/* 0x0000B8 */
+
+	uint64_t	ca_pad_0000C0[3];		/* 0x0000{C0..D0} */
+
+	uint64_t	ca_pci_rd_buf_flush;		/* 0x0000D8 */
+	uint64_t	ca_pci_dma_addr_extn;		/* 0x0000E0 */
+	uint64_t	ca_agp_dma_addr_extn;		/* 0x0000E8 */
+	uint64_t	ca_force_inta;			/* 0x0000F0 */
+	uint64_t	ca_force_intb;			/* 0x0000F8 */
+	uint64_t	ca_debug_vector_sel;		/* 0x000100 */
+	uint64_t	ca_debug_mux_core_sel;		/* 0x000108 */
+	uint64_t	ca_debug_mux_pci_sel;		/* 0x000110 */
+	uint64_t	ca_debug_domain_sel;		/* 0x000118 */
+
+	uint64_t	ca_pad_000120[28];		/* 0x0001{20..F8} */
+
+	uint64_t	ca_gart_ptr_table;		/* 0x200 */
+	uint64_t	ca_gart_tlb_addr[8];		/* 0x2{08..40} */
+};
+
+/*
+ * Mask/shift definitions for TIO:CA registers.  The convention here is
+ * to mainly use the names as they appear in the "TIO AEGIS Programmers'
+ * Reference" with a CA_ prefix added.  Some exceptions were made to fix
+ * duplicate field names or to generalize fields that are common to
+ * different registers (ca_debug_mux_core_sel and ca_debug_mux_pci_sel for
+ * example).
+ *
+ * Fields consisting of a single bit have a single #define have a single
+ * macro declaration to mask the bit.  Fields consisting of multiple bits
+ * have two declarations: one to mask the proper bits in a register, and 
+ * a second with the suffix "_SHFT" to identify how far the mask needs to
+ * be shifted right to get its base value.
+ */
+
+/* == ca_control1 */
+#define CA_SYS_BIG_END			(1ull << 0)
+#define CA_DMA_AGP_SWAP			(1ull << 1)
+#define CA_DMA_PCI_SWAP			(1ull << 2)
+#define CA_PIO_IO_SWAP			(1ull << 3)
+#define CA_PIO_MEM_SWAP			(1ull << 4)
+#define CA_GFX_WR_SWAP			(1ull << 5)
+#define CA_AGP_FW_ENABLE		(1ull << 6)
+#define CA_AGP_CAL_CYCLE		(0x7ull << 7)
+#define CA_AGP_CAL_CYCLE_SHFT		7
+#define CA_AGP_CAL_PRSCL_BYP		(1ull << 10)
+#define CA_AGP_INIT_CAL_ENB		(1ull << 11)
+#define CA_INJ_ADDR_PERR		(1ull << 12)
+#define CA_INJ_DATA_PERR		(1ull << 13)
+	/* bits 15:14 unused */
+#define CA_PCIM_IO_NBE_AD		(0x7ull << 16)
+#define CA_PCIM_IO_NBE_AD_SHFT		16
+#define CA_PCIM_FAST_BTB_ENB		(1ull << 19)
+	/* bits 23:20 unused */
+#define CA_PIO_ADDR_OFFSET		(0xffull << 24)
+#define CA_PIO_ADDR_OFFSET_SHFT		24
+	/* bits 35:32 unused */
+#define CA_AGPDMA_OP_COMBDELAY		(0x1full << 36)
+#define CA_AGPDMA_OP_COMBDELAY_SHFT	36
+	/* bit 41 unused */
+#define CA_AGPDMA_OP_ENB_COMBDELAY	(1ull << 42)
+#define	CA_PCI_INT_LPCNT		(0xffull << 44)
+#define CA_PCI_INT_LPCNT_SHFT		44
+	/* bits 63:52 unused */
+
+/* == ca_control2 */
+#define CA_AGP_LATENCY_TO		(0xffull << 0)
+#define CA_AGP_LATENCY_TO_SHFT		0
+#define CA_PCI_LATENCY_TO		(0xffull << 8)
+#define CA_PCI_LATENCY_TO_SHFT		8
+#define CA_PCI_MAX_RETRY		(0x3ffull << 16)
+#define CA_PCI_MAX_RETRY_SHFT		16
+	/* bits 27:26 unused */
+#define CA_RT_INT_EN			(0x3ull << 28)
+#define CA_RT_INT_EN_SHFT			28
+#define CA_MSI_INT_ENB			(1ull << 30)
+#define CA_PCI_ARB_ERR_ENB		(1ull << 31)
+#define CA_GART_MEM_PARAM		(0x3ull << 32)
+#define CA_GART_MEM_PARAM_SHFT		32
+#define CA_GART_RD_PREFETCH_ENB		(1ull << 34)
+#define CA_GART_WR_PREFETCH_ENB		(1ull << 35)
+#define CA_GART_FLUSH_TLB		(1ull << 36)
+	/* bits 39:37 unused */
+#define CA_CRM_TNUMTO_PERIOD		(0x1fffull << 40)
+#define CA_CRM_TNUMTO_PERIOD_SHFT	40
+	/* bits 55:53 unused */
+#define CA_CRM_TNUMTO_ENB		(1ull << 56)
+#define CA_CRM_PRESCALER_BYP		(1ull << 57)
+	/* bits 59:58 unused */
+#define CA_CRM_MAX_CREDIT		(0x7ull << 60)
+#define CA_CRM_MAX_CREDIT_SHFT		60
+	/* bit 63 unused */
+
+/* == ca_status1 */
+#define CA_CORELET_ID			(0x3ull << 0)
+#define CA_CORELET_ID_SHFT		0
+#define CA_INTA_N			(1ull << 2)
+#define CA_INTB_N			(1ull << 3)
+#define CA_CRM_CREDIT_AVAIL		(0x7ull << 4)
+#define CA_CRM_CREDIT_AVAIL_SHFT	4
+	/* bit 7 unused */
+#define CA_CRM_SPACE_AVAIL		(0x7full << 8)
+#define CA_CRM_SPACE_AVAIL_SHFT		8
+	/* bit 15 unused */
+#define CA_GART_TLB_VAL			(0xffull << 16)
+#define CA_GART_TLB_VAL_SHFT		16
+	/* bits 63:24 unused */
+
+/* == ca_status2 */
+#define CA_GFX_CREDIT_AVAIL		(0xffull << 0)
+#define CA_GFX_CREDIT_AVAIL_SHFT	0
+#define CA_GFX_OPQ_AVAIL		(0xffull << 8)
+#define CA_GFX_OPQ_AVAIL_SHFT		8
+#define CA_GFX_WRBUFF_AVAIL		(0xffull << 16)
+#define CA_GFX_WRBUFF_AVAIL_SHFT	16
+#define CA_ADMA_OPQ_AVAIL		(0xffull << 24)
+#define CA_ADMA_OPQ_AVAIL_SHFT		24
+#define CA_ADMA_WRBUFF_AVAIL		(0xffull << 32)
+#define CA_ADMA_WRBUFF_AVAIL_SHFT	32
+#define CA_ADMA_RDBUFF_AVAIL		(0x7full << 40)
+#define CA_ADMA_RDBUFF_AVAIL_SHFT	40
+#define CA_PCI_PIO_OP_STAT		(1ull << 47)
+#define CA_PDMA_OPQ_AVAIL		(0xfull << 48)
+#define CA_PDMA_OPQ_AVAIL_SHFT		48
+#define CA_PDMA_WRBUFF_AVAIL		(0xfull << 52)
+#define CA_PDMA_WRBUFF_AVAIL_SHFT	52
+#define CA_PDMA_RDBUFF_AVAIL		(0x3ull << 56)
+#define CA_PDMA_RDBUFF_AVAIL_SHFT	56
+	/* bits 63:58 unused */
+
+/* == ca_gart_aperature */
+#define CA_GART_AP_ENB_AGP		(1ull << 0)
+#define CA_GART_PAGE_SIZE		(1ull << 1)
+#define CA_GART_AP_ENB_PCI		(1ull << 2)
+	/* bits 11:3 unused */
+#define CA_GART_AP_SIZE			(0x3ffull << 12)
+#define CA_GART_AP_SIZE_SHFT		12
+#define CA_GART_AP_BASE			(0x3ffffffffffull << 22)
+#define CA_GART_AP_BASE_SHFT		22
+
+/* == ca_inta_dest_addr
+   == ca_intb_dest_addr 
+   == ca_err_int_dest_addr */
+	/* bits 2:0 unused */
+#define CA_INT_DEST_ADDR		(0x7ffffffffffffull << 3)
+#define CA_INT_DEST_ADDR_SHFT		3
+	/* bits 55:54 unused */
+#define CA_INT_DEST_VECT		(0xffull << 56)
+#define CA_INT_DEST_VECT_SHFT		56
+
+/* == ca_int_status */
+/* == ca_int_status_alias */
+/* == ca_mult_error */
+/* == ca_mult_error_alias */
+/* == ca_first_error */
+/* == ca_int_mask */
+#define CA_PCI_ERR			(1ull << 0)
+	/* bits 3:1 unused */
+#define CA_GART_FETCH_ERR		(1ull << 4)
+#define CA_GFX_WR_OVFLW			(1ull << 5)
+#define CA_PIO_REQ_OVFLW		(1ull << 6)
+#define CA_CRM_PKTERR			(1ull << 7)
+#define CA_CRM_DVERR			(1ull << 8)
+#define CA_TNUMTO			(1ull << 9)
+#define CA_CXM_RSP_CRED_OVFLW		(1ull << 10)
+#define CA_CXM_REQ_CRED_OVFLW		(1ull << 11)
+#define CA_PIO_INVALID_ADDR		(1ull << 12)
+#define CA_PCI_ARB_TO			(1ull << 13)
+#define CA_AGP_REQ_OFLOW		(1ull << 14)
+#define CA_SBA_TYPE1_ERR		(1ull << 15)
+	/* bit 16 unused */
+#define CA_INTA				(1ull << 17)
+#define CA_INTB				(1ull << 18)
+#define CA_MULT_INTA			(1ull << 19)
+#define CA_MULT_INTB			(1ull << 20)
+#define CA_GFX_CREDIT_OVFLW		(1ull << 21)
+	/* bits 63:22 unused */
+
+/* == ca_crm_pkterr_type */
+/* == ca_crm_pkterr_type_alias */
+#define CA_CRM_PKTERR_SBERR_HDR		(1ull << 0)
+#define CA_CRM_PKTERR_DIDN		(1ull << 1)
+#define CA_CRM_PKTERR_PACTYPE		(1ull << 2)
+#define CA_CRM_PKTERR_INV_TNUM		(1ull << 3)
+#define CA_CRM_PKTERR_ADDR_RNG		(1ull << 4)
+#define CA_CRM_PKTERR_ADDR_ALGN		(1ull << 5)
+#define CA_CRM_PKTERR_HDR_PARAM		(1ull << 6)
+#define CA_CRM_PKTERR_CW_ERR		(1ull << 7)
+#define CA_CRM_PKTERR_SBERR_NH		(1ull << 8)
+#define CA_CRM_PKTERR_EARLY_TERM	(1ull << 9)
+#define CA_CRM_PKTERR_EARLY_TAIL	(1ull << 10)
+#define CA_CRM_PKTERR_MSSNG_TAIL	(1ull << 11)
+#define CA_CRM_PKTERR_MSSNG_HDR		(1ull << 12)
+	/* bits 15:13 unused */
+#define CA_FIRST_CRM_PKTERR_SBERR_HDR	(1ull << 16)
+#define CA_FIRST_CRM_PKTERR_DIDN	(1ull << 17)
+#define CA_FIRST_CRM_PKTERR_PACTYPE	(1ull << 18)
+#define CA_FIRST_CRM_PKTERR_INV_TNUM	(1ull << 19)
+#define CA_FIRST_CRM_PKTERR_ADDR_RNG	(1ull << 20)
+#define CA_FIRST_CRM_PKTERR_ADDR_ALGN	(1ull << 21)
+#define CA_FIRST_CRM_PKTERR_HDR_PARAM	(1ull << 22)
+#define CA_FIRST_CRM_PKTERR_CW_ERR	(1ull << 23)
+#define CA_FIRST_CRM_PKTERR_SBERR_NH	(1ull << 24)
+#define CA_FIRST_CRM_PKTERR_EARLY_TERM	(1ull << 25)
+#define CA_FIRST_CRM_PKTERR_EARLY_TAIL	(1ull << 26)
+#define CA_FIRST_CRM_PKTERR_MSSNG_TAIL	(1ull << 27)
+#define CA_FIRST_CRM_PKTERR_MSSNG_HDR	(1ull << 28)
+	/* bits 63:29 unused */
+
+/* == ca_crm_ct_error_detail_1 */
+#define CA_PKT_TYPE			(0xfull << 0)
+#define CA_PKT_TYPE_SHFT		0
+#define CA_SRC_ID			(0x3ull << 4)
+#define CA_SRC_ID_SHFT			4
+#define CA_DATA_SZ			(0x3ull << 6)
+#define CA_DATA_SZ_SHFT			6
+#define CA_TNUM				(0xffull << 8)
+#define CA_TNUM_SHFT			8
+#define CA_DW_DATA_EN			(0xffull << 16)
+#define CA_DW_DATA_EN_SHFT		16
+#define CA_GFX_CRED			(0xffull << 24)
+#define CA_GFX_CRED_SHFT		24
+#define CA_MEM_RD_PARAM			(0x3ull << 32)
+#define CA_MEM_RD_PARAM_SHFT		32
+#define CA_PIO_OP			(1ull << 34)
+#define CA_CW_ERR			(1ull << 35)
+	/* bits 62:36 unused */
+#define CA_VALID			(1ull << 63)
+
+/* == ca_crm_ct_error_detail_2 */
+	/* bits 2:0 unused */
+#define CA_PKT_ADDR			(0x1fffffffffffffull << 3)
+#define CA_PKT_ADDR_SHFT		3
+	/* bits 63:56 unused */
+
+/* == ca_crm_tnumto */
+#define CA_CRM_TNUMTO_VAL		(0xffull << 0)
+#define CA_CRM_TNUMTO_VAL_SHFT		0
+#define CA_CRM_TNUMTO_WR		(1ull << 8)
+	/* bits 63:9 unused */
+
+/* == ca_gart_err */
+#define CA_GART_ERR_SOURCE		(0x3ull << 0)
+#define CA_GART_ERR_SOURCE_SHFT		0
+	/* bits 3:2 unused */
+#define CA_GART_ERR_ADDR		(0xfffffffffull << 4)
+#define CA_GART_ERR_ADDR_SHFT		4
+	/* bits 63:40 unused */
+
+/* == ca_pcierr_type */
+#define CA_PCIERR_DATA			(0xffffffffull << 0)
+#define CA_PCIERR_DATA_SHFT		0
+#define CA_PCIERR_ENB			(0xfull << 32)
+#define CA_PCIERR_ENB_SHFT		32
+#define CA_PCIERR_CMD			(0xfull << 36)
+#define CA_PCIERR_CMD_SHFT		36
+#define CA_PCIERR_A64			(1ull << 40)
+#define CA_PCIERR_SLV_SERR		(1ull << 41)
+#define CA_PCIERR_SLV_WR_PERR		(1ull << 42)
+#define CA_PCIERR_SLV_RD_PERR		(1ull << 43)
+#define CA_PCIERR_MST_SERR		(1ull << 44)
+#define CA_PCIERR_MST_WR_PERR		(1ull << 45)
+#define CA_PCIERR_MST_RD_PERR		(1ull << 46)
+#define CA_PCIERR_MST_MABT		(1ull << 47)
+#define CA_PCIERR_MST_TABT		(1ull << 48)
+#define CA_PCIERR_MST_RETRY_TOUT	(1ull << 49)
+
+#define CA_PCIERR_TYPES \
+	(CA_PCIERR_A64|CA_PCIERR_SLV_SERR| \
+	 CA_PCIERR_SLV_WR_PERR|CA_PCIERR_SLV_RD_PERR| \
+	 CA_PCIERR_MST_SERR|CA_PCIERR_MST_WR_PERR|CA_PCIERR_MST_RD_PERR| \
+	 CA_PCIERR_MST_MABT|CA_PCIERR_MST_TABT|CA_PCIERR_MST_RETRY_TOUT)
+
+	/* bits 63:50 unused */
+
+/* == ca_pci_dma_addr_extn */
+#define CA_UPPER_NODE_OFFSET		(0x3full << 0)
+#define CA_UPPER_NODE_OFFSET_SHFT	0
+	/* bits 7:6 unused */
+#define CA_CHIPLET_ID			(0x3ull << 8)
+#define CA_CHIPLET_ID_SHFT		8
+	/* bits 11:10 unused */
+#define CA_PCI_DMA_NODE_ID		(0xffffull << 12)
+#define CA_PCI_DMA_NODE_ID_SHFT		12
+	/* bits 27:26 unused */
+#define CA_PCI_DMA_PIO_MEM_TYPE		(1ull << 28)
+	/* bits 63:29 unused */
+
+
+/* == ca_agp_dma_addr_extn */
+	/* bits 19:0 unused */
+#define CA_AGP_DMA_NODE_ID		(0xffffull << 20)
+#define CA_AGP_DMA_NODE_ID_SHFT		20
+	/* bits 27:26 unused */
+#define CA_AGP_DMA_PIO_MEM_TYPE		(1ull << 28)
+	/* bits 63:29 unused */
+
+/* == ca_debug_vector_sel */
+#define CA_DEBUG_MN_VSEL		(0xfull << 0)
+#define CA_DEBUG_MN_VSEL_SHFT		0
+#define CA_DEBUG_PP_VSEL		(0xfull << 4)
+#define CA_DEBUG_PP_VSEL_SHFT		4
+#define CA_DEBUG_GW_VSEL		(0xfull << 8)
+#define CA_DEBUG_GW_VSEL_SHFT		8
+#define CA_DEBUG_GT_VSEL		(0xfull << 12)
+#define CA_DEBUG_GT_VSEL_SHFT		12
+#define CA_DEBUG_PD_VSEL		(0xfull << 16)
+#define CA_DEBUG_PD_VSEL_SHFT		16
+#define CA_DEBUG_AD_VSEL		(0xfull << 20)
+#define CA_DEBUG_AD_VSEL_SHFT		20
+#define CA_DEBUG_CX_VSEL		(0xfull << 24)
+#define CA_DEBUG_CX_VSEL_SHFT		24
+#define CA_DEBUG_CR_VSEL		(0xfull << 28)
+#define CA_DEBUG_CR_VSEL_SHFT		28
+#define CA_DEBUG_BA_VSEL		(0xfull << 32)
+#define CA_DEBUG_BA_VSEL_SHFT		32
+#define CA_DEBUG_PE_VSEL		(0xfull << 36)
+#define CA_DEBUG_PE_VSEL_SHFT		36
+#define CA_DEBUG_BO_VSEL		(0xfull << 40)
+#define CA_DEBUG_BO_VSEL_SHFT		40
+#define CA_DEBUG_BI_VSEL		(0xfull << 44)
+#define CA_DEBUG_BI_VSEL_SHFT		44
+#define CA_DEBUG_AS_VSEL		(0xfull << 48)
+#define CA_DEBUG_AS_VSEL_SHFT		48
+#define CA_DEBUG_PS_VSEL		(0xfull << 52)
+#define CA_DEBUG_PS_VSEL_SHFT		52
+#define CA_DEBUG_PM_VSEL		(0xfull << 56)
+#define CA_DEBUG_PM_VSEL_SHFT		56
+	/* bits 63:60 unused */
+
+/* == ca_debug_mux_core_sel */
+/* == ca_debug_mux_pci_sel */
+#define CA_DEBUG_MSEL0			(0x7ull << 0)
+#define CA_DEBUG_MSEL0_SHFT		0
+	/* bit 3 unused */
+#define CA_DEBUG_NSEL0			(0x7ull << 4)
+#define CA_DEBUG_NSEL0_SHFT		4
+	/* bit 7 unused */
+#define CA_DEBUG_MSEL1			(0x7ull << 8)
+#define CA_DEBUG_MSEL1_SHFT		8
+	/* bit 11 unused */
+#define CA_DEBUG_NSEL1			(0x7ull << 12)
+#define CA_DEBUG_NSEL1_SHFT		12
+	/* bit 15 unused */
+#define CA_DEBUG_MSEL2			(0x7ull << 16)
+#define CA_DEBUG_MSEL2_SHFT		16
+	/* bit 19 unused */
+#define CA_DEBUG_NSEL2			(0x7ull << 20)
+#define CA_DEBUG_NSEL2_SHFT		20
+	/* bit 23 unused */
+#define CA_DEBUG_MSEL3			(0x7ull << 24)
+#define CA_DEBUG_MSEL3_SHFT		24
+	/* bit 27 unused */
+#define CA_DEBUG_NSEL3			(0x7ull << 28)
+#define CA_DEBUG_NSEL3_SHFT		28
+	/* bit 31 unused */
+#define CA_DEBUG_MSEL4			(0x7ull << 32)
+#define CA_DEBUG_MSEL4_SHFT		32
+	/* bit 35 unused */
+#define CA_DEBUG_NSEL4			(0x7ull << 36)
+#define CA_DEBUG_NSEL4_SHFT		36
+	/* bit 39 unused */
+#define CA_DEBUG_MSEL5			(0x7ull << 40)
+#define CA_DEBUG_MSEL5_SHFT		40
+	/* bit 43 unused */
+#define CA_DEBUG_NSEL5			(0x7ull << 44)
+#define CA_DEBUG_NSEL5_SHFT		44
+	/* bit 47 unused */
+#define CA_DEBUG_MSEL6			(0x7ull << 48)
+#define CA_DEBUG_MSEL6_SHFT		48
+	/* bit 51 unused */
+#define CA_DEBUG_NSEL6			(0x7ull << 52)
+#define CA_DEBUG_NSEL6_SHFT		52
+	/* bit 55 unused */
+#define CA_DEBUG_MSEL7			(0x7ull << 56)
+#define CA_DEBUG_MSEL7_SHFT		56
+	/* bit 59 unused */
+#define CA_DEBUG_NSEL7			(0x7ull << 60)
+#define CA_DEBUG_NSEL7_SHFT		60
+	/* bit 63 unused */
+
+
+/* == ca_debug_domain_sel */
+#define CA_DEBUG_DOMAIN_L		(1ull << 0)
+#define CA_DEBUG_DOMAIN_H		(1ull << 1)
+	/* bits 63:2 unused */
+
+/* == ca_gart_ptr_table */
+#define CA_GART_PTR_VAL			(1ull << 0)
+	/* bits 11:1 unused */
+#define CA_GART_PTR_ADDR		(0xfffffffffffull << 12)
+#define CA_GART_PTR_ADDR_SHFT		12
+	/* bits 63:56 unused */
+
+/* == ca_gart_tlb_addr[0-7] */
+#define CA_GART_TLB_ADDR		(0xffffffffffffffull << 0)
+#define CA_GART_TLB_ADDR_SHFT		0
+	/* bits 62:56 unused */
+#define CA_GART_TLB_ENTRY_VAL		(1ull << 63)
+
+/*
+ * PIO address space ranges for TIO:CA
+ */
+
+/* CA internal registers */
+#define CA_PIO_ADMIN			0x00000000
+#define CA_PIO_ADMIN_LEN		0x00010000
+
+/* GFX Write Buffer - Diagnostics */
+#define CA_PIO_GFX			0x00010000
+#define CA_PIO_GFX_LEN			0x00010000
+
+/* AGP DMA Write Buffer - Diagnostics */
+#define CA_PIO_AGP_DMAWRITE		0x00020000
+#define CA_PIO_AGP_DMAWRITE_LEN		0x00010000
+
+/* AGP DMA READ Buffer - Diagnostics */
+#define CA_PIO_AGP_DMAREAD		0x00030000
+#define CA_PIO_AGP_DMAREAD_LEN		0x00010000
+
+/* PCI Config Type 0 */
+#define CA_PIO_PCI_TYPE0_CONFIG		0x01000000
+#define CA_PIO_PCI_TYPE0_CONFIG_LEN	0x01000000
+
+/* PCI Config Type 1 */
+#define CA_PIO_PCI_TYPE1_CONFIG		0x02000000
+#define CA_PIO_PCI_TYPE1_CONFIG_LEN	0x01000000
+
+/* PCI I/O Cycles - mapped to PCI Address 0x00000000-0x04ffffff */
+#define CA_PIO_PCI_IO			0x03000000
+#define CA_PIO_PCI_IO_LEN		0x05000000
+
+/* PCI MEM Cycles - mapped to PCI with CA_PIO_ADDR_OFFSET of ca_control1 */
+/*	use Fast Write if enabled and coretalk packet type is a GFX request */
+#define CA_PIO_PCI_MEM_OFFSET		0x08000000
+#define CA_PIO_PCI_MEM_OFFSET_LEN	0x08000000
+
+/* PCI MEM Cycles - mapped to PCI Address 0x00000000-0xbfffffff */
+/*	use Fast Write if enabled and coretalk packet type is a GFX request */
+#define CA_PIO_PCI_MEM			0x40000000
+#define CA_PIO_PCI_MEM_LEN		0xc0000000
+
+/*
+ * DMA space
+ *
+ * The CA aperature (ie. bus address range) mapped by the GART is segmented into
+ * two parts.  The lower portion of the aperature is used for mapping 32 bit
+ * PCI addresses which are managed by the dma interfaces in this file.  The
+ * upper poprtion of the aperature is used for mapping 48 bit AGP addresses.
+ * The AGP portion of the aperature is managed by the agpgart_be.c driver
+ * in drivers/linux/agp.  There are ca-specific hooks in that driver to
+ * manipulate the gart, but management of the AGP portion of the aperature
+ * is the responsibility of that driver.
+ *
+ * CA allows three main types of DMA mapping:
+ *
+ * PCI 64-bit	Managed by this driver
+ * PCI 32-bit 	Managed by this driver
+ * AGP 48-bit	Managed by hooks in the /dev/agpgart driver
+ *
+ * All of the above can optionally be remapped through the GART.  The following
+ * table lists the combinations of addressing types and GART remapping that
+ * is currently supported by the driver (h/w supports all, s/w limits this):
+ *
+ *		PCI64		PCI32		AGP48
+ * GART		no		yes		yes
+ * Direct	yes		yes		no
+ *
+ * GART remapping of PCI64 is not done because there is no need to.  The
+ * 64 bit PCI address holds all of the information necessary to target any
+ * memory in the system.
+ *
+ * AGP48 is always mapped through the GART.  Management of the AGP48 portion
+ * of the aperature is the responsibility of code in the agpgart_be driver.
+ *
+ * The non-64 bit bus address space will currently be partitioned like this:
+ *
+ *	0xffff_ffff_ffff	+--------
+ *				| AGP48 direct
+ *				| Space managed by this driver
+ *	CA_AGP_DIRECT_BASE	+--------
+ *				| AGP GART mapped (gfx aperature)
+ *				| Space managed by /dev/agpgart driver
+ *				| This range is exposed to the agpgart
+ * 				| driver as the "graphics aperature"
+ *	CA_AGP_MAPPED_BASE	+-----
+ *				| PCI GART mapped
+ *				| Space managed by this driver		
+ *	CA_PCI32_MAPPED_BASE	+----
+ *				| PCI32 direct
+ *				| Space managed by this driver
+ *	0xC000_0000		+--------
+ *	(CA_PCI32_DIRECT_BASE)
+ *
+ * The bus address range CA_PCI32_MAPPED_BASE through CA_AGP_DIRECT_BASE
+ * is what we call the CA aperature.  Addresses falling in this range will
+ * be remapped using the GART.
+ *
+ * The bus address range CA_AGP_MAPPED_BASE through CA_AGP_DIRECT_BASE
+ * is what we call the graphics aperature.  This is a subset of the CA
+ * aperature and is under the control of the agpgart_be driver.
+ *
+ * CA_PCI32_MAPPED_BASE, CA_AGP_MAPPED_BASE, and CA_AGP_DIRECT_BASE are
+ * somewhat arbitrary values.  The known constraints on choosing these is:
+ *
+ * 1)  CA_AGP_DIRECT_BASE-CA_PCI32_MAPPED_BASE+1 (the CA aperature size)
+ *     must be one of the values supported by the ca_gart_aperature register.
+ *     Currently valid values are: 4MB through 4096MB in powers of 2 increments
+ *
+ * 2)  CA_AGP_DIRECT_BASE-CA_AGP_MAPPED_BASE+1 (the gfx aperature size)
+ *     must be in MB units since that's what the agpgart driver assumes.
+ */
+
+/*
+ * Define Bus DMA ranges.  These are configurable (see constraints above)
+ * and will probably need tuning based on experience.
+ */
+
+
+/*
+ * 11/24/03
+ * CA has an addressing glitch w.r.t. PCI direct 32 bit DMA that makes it
+ * generally unusable.  The problem is that for PCI direct 32 
+ * DMA's, all 32 bits of the bus address are used to form the lower 32 bits
+ * of the coretalk address, and coretalk bits 38:32 come from a register.
+ * Since only PCI bus addresses 0xC0000000-0xFFFFFFFF (1GB) are available
+ * for DMA (the rest is allocated to PIO), host node addresses need to be
+ * such that their lower 32 bits fall in the 0xC0000000-0xffffffff range
+ * as well.  So there can be no PCI32 direct DMA below 3GB!!  For this
+ * reason we set the CA_PCI32_DIRECT_SIZE to 0 which essentially makes
+ * tioca_dma_direct32() a noop but preserves the code flow should this issue
+ * be fixed in a respin.
+ *
+ * For now, all PCI32 DMA's must be mapped through the GART.
+ */
+
+#define CA_PCI32_DIRECT_BASE	0xC0000000UL	/* BASE not configurable */
+#define CA_PCI32_DIRECT_SIZE	0x00000000UL	/* 0 MB */
+
+#define CA_PCI32_MAPPED_BASE	0xC0000000UL
+#define CA_PCI32_MAPPED_SIZE	0x40000000UL	/* 2GB */
+
+#define CA_AGP_MAPPED_BASE	0x80000000UL
+#define CA_AGP_MAPPED_SIZE	0x40000000UL	/* 2GB */
+
+#define CA_AGP_DIRECT_BASE	0x40000000UL	/* 2GB */
+#define CA_AGP_DIRECT_SIZE	0x40000000UL
+
+#define CA_APERATURE_BASE	(CA_AGP_MAPPED_BASE)
+#define CA_APERATURE_SIZE	(CA_AGP_MAPPED_SIZE+CA_PCI32_MAPPED_SIZE)
+
+#endif  /* _ASM_IA64_SN_TIO_TIOCA_H */
diff -Nru a/include/asm-ia64/sn/tioca_provider.h b/include/asm-ia64/sn/tioca_provider.h
--- /dev/null	Wed Dec 31 16:00:00 196900
+++ b/include/asm-ia64/sn/tioca_provider.h	2005-02-07 15:50:04 -06:00
@@ -0,0 +1,206 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * Copyright (c) 2003-2005 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef _ASM_IA64_SN_TIO_CA_AGP_PROVIDER_H
+#define _ASM_IA64_SN_TIO_CA_AGP_PROVIDER_H
+
+#include <asm/sn/tioca.h>
+
+/*
+ * WAR enables
+ * Defines for individual WARs. Each is a bitmask of applicable
+ * part revision numbers. (1 << 1) = rev A, (1 << 2) = rev B,
+ * (3 << 1) = (rev A or rev B), etc
+ */
+
+#define TIOCA_WAR_ENABLED(pv, tioca_common) \
+	((1 << tioca_common->ca_rev) & pv)
+
+  /* TIO:ICE:FRZ:Freezer loses a PIO data ucred on PIO RD RSP with CW error */
+#define PV907908 (1 << 1)
+  /* ATI config space problems after BIOS execution starts */
+#define PV908234 (1 << 1)
+  /* CA:AGPDMA write request data mismatch with ABC1CL merge */
+#define PV895469 (1 << 1)
+  /* TIO:CA TLB invalidate of written GART entries possibly not occuring in CA*/
+#define PV910244 (1 << 1)
+
+struct tioca_dmamap{
+	struct list_head	cad_list;	/* headed by ca_list */
+
+	dma_addr_t		cad_dma_addr;	/* Linux dma handle */
+	uint			cad_gart_entry; /* start entry in ca_gart_pagemap */
+	uint			cad_gart_size;	/* #entries for this map */
+};
+
+/*
+ * Kernel only fields.  Prom may look at this stuff for debugging only.
+ * Access this structure through the ca_kernel_private ptr.
+ */
+
+struct tioca_common ;
+
+struct tioca_kernel {
+	struct tioca_common	*ca_common;	/* tioca this belongs to */
+	struct list_head	ca_list;	/* list of all ca's */
+	struct list_head	ca_dmamaps;
+	spinlock_t		ca_lock;	/* Kernel lock */
+	cnodeid_t		ca_closest_node;
+	struct list_head	*ca_devices;	/* bus->devices */
+
+	/*
+	 * General GART stuff
+	 */
+	uint64_t	ca_ap_size;		/* size of aperature in bytes */
+	uint32_t	ca_gart_entries;	/* # uint64_t entries in gart */
+	uint32_t	ca_ap_pagesize; 	/* aperature page size in bytes */
+	uint64_t	ca_ap_bus_base; 	/* bus address of CA aperature */
+	uint64_t	ca_gart_size;		/* gart size in bytes */
+	uint64_t	*ca_gart;		/* gart table vaddr */
+	uint64_t	ca_gart_coretalk_addr;	/* gart coretalk addr */
+	uint8_t		ca_gart_iscoherent;	/* used in tioca_tlbflush */
+
+	/* PCI GART convenience values */
+	uint64_t	ca_pciap_base;		/* pci aperature bus base address */
+	uint64_t	ca_pciap_size;		/* pci aperature size (bytes) */
+	uint64_t	ca_pcigart_base;	/* gfx GART bus base address */
+	uint64_t	*ca_pcigart;		/* gfx GART vm address */
+	uint32_t	ca_pcigart_entries;
+	uint32_t	ca_pcigart_start;	/* PCI start index in ca_gart */
+	void		*ca_pcigart_pagemap;
+
+	/* AGP GART convenience values */
+	uint64_t	ca_gfxap_base;		/* gfx aperature bus base address */
+	uint64_t	ca_gfxap_size;		/* gfx aperature size (bytes) */
+	uint64_t	ca_gfxgart_base;	/* gfx GART bus base address */
+	uint64_t	*ca_gfxgart;		/* gfx GART vm address */
+	uint32_t	ca_gfxgart_entries;
+	uint32_t	ca_gfxgart_start;	/* agpgart start index in ca_gart */
+};
+
+/*
+ * Common tioca info shared between kernel and prom
+ *
+ * DO NOT CHANGE THIS STRUCT WITHOUT MAKING CORRESPONDING CHANGES
+ * TO THE PROM VERSION.
+ */
+
+struct tioca_common {
+	struct pcibus_bussoft	ca_common;	/* common pciio header */
+
+	uint32_t		ca_rev;
+	uint32_t		ca_closest_nasid;
+
+	uint64_t		ca_prom_private;
+	uint64_t		ca_kernel_private;
+};
+
+/**
+ * tioca_paddr_to_gart - Convert an SGI coretalk address to a CA GART entry
+ * @paddr: page address to convert
+ *
+ * Convert a system [coretalk] address to a GART entry.  GART entries are
+ * formed using the following:
+ *
+ *     data = ( (1<<63) |  ( (REMAP_NODE_ID << 40) | (MD_CHIPLET_ID << 38) | 
+ * (REMAP_SYS_ADDR) ) >> 12 )
+ *
+ * DATA written to 1 GART TABLE Entry in system memory is remapped system
+ * addr for 1 page 
+ *
+ * The data is for coretalk address format right shifted 12 bits with a
+ * valid bit.
+ *
+ *	GART_TABLE_ENTRY [ 25:0 ]  -- REMAP_SYS_ADDRESS[37:12].
+ *	GART_TABLE_ENTRY [ 27:26 ] -- SHUB MD chiplet id.
+ *	GART_TABLE_ENTRY [ 41:28 ] -- REMAP_NODE_ID.
+ *	GART_TABLE_ENTRY [ 63 ]    -- Valid Bit 
+ */
+static inline u64
+tioca_paddr_to_gart(unsigned long paddr)
+{
+	/*
+	 * We are assuming right now that paddr already has the correct
+	 * format since the address from xtalk_dmaXXX should already have
+	 * NODE_ID, CHIPLET_ID, and SYS_ADDR in the correct locations.
+	 */
+
+	return ((paddr) >> 12) | (1UL << 63);
+}
+
+/**
+ * tioca_physpage_to_gart - Map a host physical page for SGI CA based DMA
+ * @page_addr: system page address to map
+ */
+
+static inline unsigned long
+tioca_physpage_to_gart(uint64_t page_addr)
+{
+	uint64_t coretalk_addr;
+
+	coretalk_addr = PHYS_TO_TIODMA(page_addr);
+	if (!coretalk_addr) {
+		return 0;
+	}
+
+	return tioca_paddr_to_gart(coretalk_addr);
+}
+
+/**
+ * tioca_tlbflush - invalidate cached SGI CA GART TLB entries
+ * @tioca_kernel: CA context 
+ *
+ * Invalidate tlb entries for a given CA GART.  Main complexity is to account
+ * for revA bug.
+ */
+static inline void
+tioca_tlbflush(struct tioca_kernel *tioca_kernel)
+{
+	volatile uint64_t tmp;
+	volatile struct tioca *ca_base;
+	struct tioca_common *tioca_common;
+
+	tioca_common = tioca_kernel->ca_common;
+	ca_base = (struct tioca *)tioca_common->ca_common.bs_base;
+
+	/*
+	 * Explicit flushes not needed if GART is in cached mode
+	 */
+	if (tioca_kernel->ca_gart_iscoherent) {
+		if (TIOCA_WAR_ENABLED(PV910244, tioca_common)) {
+			/*
+			 * PV910244:  RevA CA needs explicit flushes.
+			 * Need to put GART into uncached mode before
+			 * flushing otherwise the explicit flush is ignored.
+			 *
+			 * Alternate WAR would be to leave GART cached and
+			 * touch every CL aligned GART entry.
+			 */
+
+			ca_base->ca_control2 &= ~(CA_GART_MEM_PARAM);
+			ca_base->ca_control2 |= CA_GART_FLUSH_TLB;
+			ca_base->ca_control2 |+			    (0x2ull << CA_GART_MEM_PARAM_SHFT);
+			tmp = ca_base->ca_control2;
+		}
+
+		return;
+	}
+
+	/*
+	 * Gart in uncached mode ... need an explicit flush.
+	 */
+
+	ca_base->ca_control2 |= CA_GART_FLUSH_TLB;
+	tmp = ca_base->ca_control2;
+}
+
+extern uint32_t	tioca_gart_found;
+extern int tioca_init_provider(void);
+extern void tioca_fastwrite_enable(struct tioca_kernel *tioca_kern);
+#endif /* _ASM_IA64_SN_TIO_CA_AGP_PROVIDER_H */
