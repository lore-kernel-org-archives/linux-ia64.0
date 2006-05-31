From: John Keller <jpk@sgi.com>
Date: Wed, 31 May 2006 21:23:20 +0000
Subject: [PATCH 1/2] - Altix: Add initial ACPI support
Message-Id: <20060531212320.32044.49013.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, gregkh@suse.de, John Keller <jpk@sgi.com>, pcihpd-discuss@lists.sourceforge.net

This is part 1 of a two patch set.
The patches are dependent on each other.

First phase in introducing ACPI support to SN.
In this phase, when running with an ACPI capable PROM,
the DSDT will define the root busses and all SN nodes
(SGIHUB, SGITIO). An acpi bus driver will be registered
for the node devices, with the acpi_pci_root_driver being
used for the root busses. Platform specific info is passed
via vendor descriptors, eliminating the corresponding SAL
calls. SN fixup code no longer needs to initiate the
pci bus scans, as the acpi_pci_root_driver takes care of that
now.

To maintain backward compatibility with non-ACPI capable PROMs,
none of the current 'fixup' code has been deleted, though some
restructuring has been done of common code.

A new pci bus fixup platform vector has been created to provide
a hook for invoking platform specific fixup from pcibios_fixup_bus().


Signed-off-by: John Keller <jpk@sgi.com>


Index: acpi-support/arch/ia64/pci/pci.c
=================================--- acpi-support.orig/arch/ia64/pci/pci.c	2006-05-31 12:37:50.539921986 -0500
+++ acpi-support/arch/ia64/pci/pci.c	2006-05-31 14:10:50.889146925 -0500
@@ -470,10 +470,11 @@ pcibios_fixup_resources(struct pci_dev *
 	}
 }
 
-static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
+void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
 {
 	pcibios_fixup_resources(dev, 0, PCI_BRIDGE_RESOURCES);
 }
+EXPORT_SYMBOL(pcibios_fixup_device_resources);
 
 static void __devinit pcibios_fixup_bridge_resources(struct pci_dev *dev)
 {
@@ -494,6 +495,7 @@ pcibios_fixup_bus (struct pci_bus *b)
 	}
 	list_for_each_entry(dev, &b->devices, bus_list)
 		pcibios_fixup_device_resources(dev);
+	platform_pci_fixup_bus(b);
 
 	return;
 }
Index: acpi-support/arch/ia64/sn/kernel/io_init.c
=================================--- acpi-support.orig/arch/ia64/sn/kernel/io_init.c	2006-05-31 12:37:50.555920405 -0500
+++ acpi-support/arch/ia64/sn/kernel/io_init.c	2006-05-31 14:10:50.901145782 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/bootmem.h>
@@ -24,6 +24,11 @@
 #include <asm/sn/tioce_provider.h>
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
+#include <linux/acpi.h>
+#include <asm/sn/sn2/sn_hwperf.h>
+#include <asm/sn/acpi.h>
+
+static void sn_acpi_setup(void);
 
 
 extern void sn_init_cpei_timer(void);
@@ -37,15 +42,6 @@ struct sysdata_el {
 	void *sysdata;
 };
 
-struct slab_info {
-	struct hubdev_info hubdev;
-};
-
-struct brick {
-	moduleid_t id;		/* Module ID of this module        */
-	struct slab_info slab_info[MAX_SLABS + 1];
-};
-
 int sn_ioif_inited;		/* SN I/O infrastructure initialized? */
 
 struct sn_pcibus_provider *sn_pci_provider[PCIIO_ASIC_MAX_TYPES];	/* indexed by asic type */
@@ -117,6 +113,20 @@ static inline u64 sal_get_hubdev_info(u6
 }
 
 /*
+ * Perform the early IO init in PROM.
+ */
+static s64
+sal_ioif_init(u64 *result)
+{
+	struct ia64_sal_retval isrv = {0,0,0,0};
+
+	SAL_CALL_NOLOCK(isrv,
+			SN_SAL_IOIF_INIT, 0, 0, 0, 0, 0, 0, 0);
+	*result = isrv.v0;
+	return isrv.status;
+}
+
+/*
  * Retrieve the pci bus information given the bus number.
  */
 static inline u64 sal_get_pcibus_info(u64 segment, u64 busnum, u64 address)
@@ -160,10 +170,9 @@ sn_pcidev_info_get(struct pci_dev *dev)
 	struct pcidev_info *pcidev;
 
 	list_for_each_entry(pcidev,
-			    &(SN_PCI_CONTROLLER(dev)->pcidev_info), pdi_list) {
-		if (pcidev->pdi_linux_pcidev = dev) {
+			    &(SN_PLATFORM_DATA(dev)->pcidev_info), pdi_list) {
+		if (pcidev->pdi_linux_pcidev = dev)
 			return pcidev;
-		}
 	}
 	return NULL;
 }
@@ -207,17 +216,84 @@ static s64 sn_device_fixup_war(u64 nasid
 }
 
 /*
- * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for
- *	each node in the system.
+ * sn_hubdev_init() - This routine is called to initialize the HUB data
+ *		      structure for each node in the system.
  */
-static void __init sn_fixup_ionodes(void)
+static void __init
+sn_hubdev_init(struct hubdev_info *hubdev)
 {
+
 	struct sn_flush_device_kernel *sn_flush_device_kernel;
 	struct sn_flush_device_kernel *dev_entry;
+	s64 status;
+	int widget, device, size;
+
+	/* Attach the error interrupt handlers */
+	if (hubdev->hdi_nasid & 1)	/* If TIO */
+		ice_error_init(hubdev);
+	else
+		hub_error_init(hubdev);
+
+	for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++)
+		hubdev->hdi_xwidget_info[widget].xwi_hubinfo = hubdev;
+
+	if (!hubdev->hdi_flush_nasid_list.widget_p)
+		return;
+
+	size = (HUB_WIDGET_ID_MAX + 1) *
+		sizeof(struct sn_flush_device_kernel *);
+	hubdev->hdi_flush_nasid_list.widget_p +		kzalloc(size, GFP_KERNEL);
+	if (!hubdev->hdi_flush_nasid_list.widget_p)
+		BUG();
+
+	for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
+		size = DEV_PER_WIDGET *
+			sizeof(struct sn_flush_device_kernel);
+		sn_flush_device_kernel = kzalloc(size, GFP_KERNEL);
+		if (!sn_flush_device_kernel)
+			BUG();
+
+		dev_entry = sn_flush_device_kernel;
+		for (device = 0; device < DEV_PER_WIDGET;
+		     device++, dev_entry++) {
+			size = sizeof(struct sn_flush_device_common);
+			dev_entry->common = kzalloc(size, GFP_KERNEL);
+			if (!dev_entry->common)
+				BUG();
+			if (sn_prom_feature_available(PRF_DEVICE_FLUSH_LIST))
+				status = sal_get_device_dmaflush_list(
+					     hubdev->hdi_nasid, widget, device,
+					     (u64)(dev_entry->common));
+			else
+				status = sn_device_fixup_war(hubdev->hdi_nasid,
+							     widget, device,
+							     dev_entry->common);
+			if (status != SALRET_OK)
+				panic("SAL call failed: %s\n",
+				      ia64_sal_strerror(status));
+
+			spin_lock_init(&dev_entry->sfdl_flush_lock);
+		}
+
+		if (sn_flush_device_kernel)
+			hubdev->hdi_flush_nasid_list.widget_p[widget] +							 sn_flush_device_kernel;
+	}
+}
+
+/*
+ * sn_fixup_ionodes() - This routine initializes the HUB data structure for
+ *			each node in the system. (Only called when running
+ *			with a non-ACPI capable PROM.)
+ */
+static void __init sn_fixup_ionodes(void)
+{
+
 	struct hubdev_info *hubdev;
 	u64 status;
 	u64 nasid;
-	int i, widget, device, size;
+	int i;
 
 	/*
 	 * Get SGI Specific HUB chipset information.
@@ -240,68 +316,14 @@ static void __init sn_fixup_ionodes(void
 			max_segment_number = hubdev->max_segment_number;
 			max_pcibus_number = hubdev->max_pcibus_number;
 		}
-
-		/* Attach the error interrupt handlers */
-		if (nasid & 1)
-			ice_error_init(hubdev);
-		else
-			hub_error_init(hubdev);
-
-		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++)
-			hubdev->hdi_xwidget_info[widget].xwi_hubinfo = hubdev;
-
-		if (!hubdev->hdi_flush_nasid_list.widget_p)
-			continue;
-
-		size = (HUB_WIDGET_ID_MAX + 1) *
-			sizeof(struct sn_flush_device_kernel *);
-		hubdev->hdi_flush_nasid_list.widget_p -			kzalloc(size, GFP_KERNEL);
-		if (!hubdev->hdi_flush_nasid_list.widget_p)
-			BUG();
-
-		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
-			size = DEV_PER_WIDGET *
-				sizeof(struct sn_flush_device_kernel);
-			sn_flush_device_kernel = kzalloc(size, GFP_KERNEL);
-			if (!sn_flush_device_kernel)
-				BUG();
-
-			dev_entry = sn_flush_device_kernel;
-			for (device = 0; device < DEV_PER_WIDGET;
-			     device++,dev_entry++) {
-				size = sizeof(struct sn_flush_device_common);
-				dev_entry->common = kzalloc(size, GFP_KERNEL);
-				if (!dev_entry->common)
-					BUG();
-
-				if (sn_prom_feature_available(
-						       PRF_DEVICE_FLUSH_LIST))
-					status = sal_get_device_dmaflush_list(
-						     nasid, widget, device,
-						     (u64)(dev_entry->common));
-				else
-					status = sn_device_fixup_war(nasid,
-						     widget, device,
-						     dev_entry->common);
-				if (status != SALRET_OK)
-					panic("SAL call failed: %s\n",
-					      ia64_sal_strerror(status));
-
-				spin_lock_init(&dev_entry->sfdl_flush_lock);
-			}
-
-			if (sn_flush_device_kernel)
-				hubdev->hdi_flush_nasid_list.widget_p[widget] -						       sn_flush_device_kernel;
-	        }
+		sn_hubdev_init(hubdev);
 	}
 }
 
 /*
  * sn_pci_window_fixup() - Create a pci_window for each device resource.
- *			   Until ACPI support is added, we need this code
- *			   to setup pci_windows for use by
+ *			   If running with a non-ACPI capable PROM, this
+ *			   routine will setup pci_windows for use by
  *			   pcibios_bus_to_resource(),
  *			   pcibios_resource_to_bus(), etc.
  */
@@ -382,49 +404,57 @@ void sn_pci_fixup_slot(struct pci_dev *d
 		BUG();		/* Cannot afford to run out of memory */
 
 	/* Call to retrieve pci device information needed by kernel. */
-	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number, 
+	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number,
 				     dev->devfn,
 				     (u64) __pa(pcidev_info),
 				     (u64) __pa(sn_irq_info));
 	if (status)
 		BUG(); /* Cannot get platform pci device information */
 
-	/* Add pcidev_info to list in sn_pci_controller struct */
+	/* Add pcidev_info to list in pci_controller.platform_data */
 	list_add_tail(&pcidev_info->pdi_list,
-		      &(SN_PCI_CONTROLLER(dev->bus)->pcidev_info));
+		      &(SN_PLATFORM_DATA(dev->bus)->pcidev_info));
 
-	/* Copy over PIO Mapped Addresses */
-	for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
-		unsigned long start, end, addr;
-
-		if (!pcidev_info->pdi_pio_mapped_addr[idx]) {
-			pci_addrs[idx] = -1;
-			continue;
-		}
+	/*
+	 *If PROM does not have ACPI support for pci windows,
+	 * we need to setup the pci windows in the pci_controller
+	 * struct, and convert the resource 'start' and 'end' addresses
+	 * to mapped addresses.
+	 */
+	if (!SN_ACPI_BASE_SUPPORT()) {
+		/* Copy over PIO Mapped Addresses */
+		for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
+			unsigned long start, end, addr;
+
+			if (!pcidev_info->pdi_pio_mapped_addr[idx]) {
+				pci_addrs[idx] = -1;
+				continue;
+			}
 
-		start = dev->resource[idx].start;
-		end = dev->resource[idx].end;
-		size = end - start;
-		if (size = 0) {
-			pci_addrs[idx] = -1;
-			continue;
+			start = dev->resource[idx].start;
+			end = dev->resource[idx].end;
+			size = end - start;
+			if (size = 0) {
+				pci_addrs[idx] = -1;
+				continue;
+			}
+			pci_addrs[idx] = start;
+			count++;
+			addr = pcidev_info->pdi_pio_mapped_addr[idx];
+			addr = ((addr << 4) >> 4) | __IA64_UNCACHED_OFFSET;
+			dev->resource[idx].start = addr;
+			dev->resource[idx].end = addr + size;
+			if (dev->resource[idx].flags & IORESOURCE_IO)
+				dev->resource[idx].parent = &ioport_resource;
+			else
+				dev->resource[idx].parent = &iomem_resource;
 		}
-		pci_addrs[idx] = start;
-		count++;
-		addr = pcidev_info->pdi_pio_mapped_addr[idx];
-		addr = ((addr << 4) >> 4) | __IA64_UNCACHED_OFFSET;
-		dev->resource[idx].start = addr;
-		dev->resource[idx].end = addr + size;
-		if (dev->resource[idx].flags & IORESOURCE_IO)
-			dev->resource[idx].parent = &ioport_resource;
-		else
-			dev->resource[idx].parent = &iomem_resource;
+		/* Create a pci_window in the pci_controller struct for
+		 * each device resource.
+		 */
+		if (count > 0)
+			sn_pci_window_fixup(dev, count, pci_addrs);
 	}
-	/* Create a pci_window in the pci_controller struct for
-	 * each device resource.
-	 */
-	if (count > 0)
-		sn_pci_window_fixup(dev, count, pci_addrs);
 
 	/*
 	 * Using the PROMs values for the PCI host bus, get the Linux
@@ -466,103 +496,84 @@ void sn_pci_fixup_slot(struct pci_dev *d
 	dev->no_msi = 1;
 }
 
-/*
- * sn_pci_controller_fixup() - This routine sets up a bus's resources
- * consistent with the Linux PCI abstraction layer.
- */
-void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
+static void
+sn_common_bus_fixup(struct pci_bus *bus, struct pcibus_bussoft *prom_bussoft_ptr)
 {
-	int status;
-	int nasid, cnode;
+	int cnode;
 	struct pci_controller *controller;
-	struct sn_pci_controller *sn_controller;
-	struct pcibus_bussoft *prom_bussoft_ptr;
 	struct hubdev_info *hubdev_info;
+	int nasid;
 	void *provider_soft;
 	struct sn_pcibus_provider *provider;
+	struct sn_platform_data *sn_platform_data;
 
- 	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
- 				     (u64) ia64_tpa(&prom_bussoft_ptr));
- 	if (status > 0)
-		return;		/*bus # does not exist */
-	prom_bussoft_ptr = __va(prom_bussoft_ptr);
-
-	/* Allocate a sn_pci_controller, which has a pci_controller struct
-	 * as the first member.
-	 */
-	sn_controller = kzalloc(sizeof(struct sn_pci_controller), GFP_KERNEL);
-	if (!sn_controller)
-		BUG();
-	INIT_LIST_HEAD(&sn_controller->pcidev_info);
-	controller = &sn_controller->pci_controller;
-	controller->segment = segment;
-
-	if (bus = NULL) {
- 		bus = pci_scan_bus(busnum, &pci_root_ops, controller);
- 		if (bus = NULL)
- 			goto error_return; /* error, or bus already scanned */
- 		bus->sysdata = NULL;
-	}
-
-	if (bus->sysdata)
-		goto error_return; /* sysdata already alloc'd */
-
+	controller = PCI_CONTROLLER(bus);
 	/*
-	 * Per-provider fixup.  Copies the contents from prom to local
-	 * area and links SN_PCIBUS_BUSSOFT().
+	 * Per-provider fixup.  Copies the bus soft structure from prom
+	 * to local area and links SN_PCIBUS_BUSSOFT().
 	 */
 
-	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES)
-		goto error_return; /* unsupported asic type */
+	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES) {
+		printk(KERN_WARNING "sn_common_bus_fixup: Unsupported asic type, %d",
+		       prom_bussoft_ptr->bs_asic_type);
+		return;
+	}
 
 	if (prom_bussoft_ptr->bs_asic_type = PCIIO_ASIC_TYPE_PPB)
-		goto error_return; /* no further fixup necessary */
+		return;	/* no further fixup necessary */
 
 	provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
 	if (provider = NULL)
-		goto error_return; /* no provider registerd for this asic */
+		panic("sn_common_bus_fixup: No provider registered for this asic type, %d",
+		      prom_bussoft_ptr->bs_asic_type);
 
-	bus->sysdata = controller;
 	if (provider->bus_fixup)
-		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
+		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr,
+				 controller);
 	else
 		provider_soft = NULL;
 
-	if (provider_soft = NULL) {
-		/* fixup failed or not applicable */
-		bus->sysdata = NULL;
-		goto error_return;
+	if (!SN_ACPI_BASE_SUPPORT()) {
+		/*
+		 * PROM does not have ACPI support.
+		 * Setup pci windows for legacy IO and MEM space.
+		 */
+		controller->window = kcalloc(2, sizeof(struct pci_window),
+					     GFP_KERNEL);
+		if (controller->window = NULL)
+			BUG();
+		controller->window[0].offset = prom_bussoft_ptr->bs_legacy_io;
+		controller->window[0].resource.name = "legacy_io";
+		controller->window[0].resource.flags = IORESOURCE_IO;
+		controller->window[0].resource.start +						prom_bussoft_ptr->bs_legacy_io;
+		controller->window[0].resource.end +	    			controller->window[0].resource.start + 0xffff;
+		controller->window[0].resource.parent = &ioport_resource;
+		controller->window[1].offset = prom_bussoft_ptr->bs_legacy_mem;
+		controller->window[1].resource.name = "legacy_mem";
+		controller->window[1].resource.flags = IORESOURCE_MEM;
+		controller->window[1].resource.start +						prom_bussoft_ptr->bs_legacy_mem;
+		controller->window[1].resource.end +	    	       controller->window[1].resource.start + (1024 * 1024) - 1;
+		controller->window[1].resource.parent = &iomem_resource;
+		controller->windows = 2;
 	}
 
 	/*
-	 * Setup pci_windows for legacy IO and MEM space.
-	 * (Temporary until ACPI support is in place.)
-	 */
-	controller->window = kcalloc(2, sizeof(struct pci_window), GFP_KERNEL);
-	if (controller->window = NULL)
-		BUG();
-	controller->window[0].offset = prom_bussoft_ptr->bs_legacy_io;
-	controller->window[0].resource.name = "legacy_io";
-	controller->window[0].resource.flags = IORESOURCE_IO;
-	controller->window[0].resource.start = prom_bussoft_ptr->bs_legacy_io;
-	controller->window[0].resource.end -	    controller->window[0].resource.start + 0xffff;
-	controller->window[0].resource.parent = &ioport_resource;
-	controller->window[1].offset = prom_bussoft_ptr->bs_legacy_mem;
-	controller->window[1].resource.name = "legacy_mem";
-	controller->window[1].resource.flags = IORESOURCE_MEM;
-	controller->window[1].resource.start = prom_bussoft_ptr->bs_legacy_mem;
-	controller->window[1].resource.end -	    controller->window[1].resource.start + (1024 * 1024) - 1;
-	controller->window[1].resource.parent = &iomem_resource;
-	controller->windows = 2;
-
-	/*
 	 * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
 	 * after this point.
 	 */
-
-	PCI_CONTROLLER(bus)->platform_data = provider_soft;
+	controller->platform_data = kzalloc(sizeof(struct sn_platform_data),
+					    GFP_KERNEL);
+	if (controller->platform_data = NULL)
+		BUG();
+	sn_platform_data +			(struct sn_platform_data *) controller->platform_data;
+	sn_platform_data->provider_soft = provider_soft;
+	INIT_LIST_HEAD(&((struct sn_platform_data *)
+			 controller->platform_data)->pcidev_info);
 	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
 	cnode = nasid_to_cnodeid(nasid);
 	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
@@ -570,26 +581,68 @@ void sn_pci_controller_fixup(int segment
 	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
 
 	/*
-	 * If the node information we obtained during the fixup phase is invalid
-	 * then set controller->node to -1 (undetermined)
+	 * If the node information we obtained during the fixup phase is
+	 * invalid then set controller->node to -1 (undetermined)
 	 */
 	if (controller->node >= num_online_nodes()) {
 		struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
 
 		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%u"
-				    "L_IO=%lx L_MEM=%lx BASE=%lx\n",
-			b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
-			b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
+		       "L_IO=%lx L_MEM=%lx BASE=%lx\n",
+		       b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
+		       b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
 		printk(KERN_WARNING "on node %d but only %d nodes online."
-			"Association set to undetermined.\n",
-			controller->node, num_online_nodes());
+		       "Association set to undetermined.\n",
+		       controller->node, num_online_nodes());
 		controller->node = -1;
 	}
+}
+
+/*
+ * sn_pci_controller_fixup() - This routine sets up a bus's resources
+ * consistent with the Linux PCI abstraction layer.
+ */
+static void
+sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
+{
+	s64 status = 0;
+	struct pci_controller *controller;
+	struct pcibus_bussoft *prom_bussoft_ptr;
+
+
+ 	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
+ 				     (u64) ia64_tpa(&prom_bussoft_ptr));
+ 	if (status > 0)
+		return;		/*bus # does not exist */
+	prom_bussoft_ptr = __va(prom_bussoft_ptr);
+
+	controller = kzalloc(sizeof(*controller), GFP_KERNEL);
+	if (!controller)
+		BUG();
+	controller->segment = segment;
+
+	/* Temporarily save the prom_bussoft_ptr for use by sn_pci_fixup_bus().
+	 * (platform_data will be overwritten later in sn_common_bus_fixup())
+	 */
+	controller->platform_data = prom_bussoft_ptr;
+
+	if (bus = NULL) {
+ 		bus = pci_scan_bus(busnum, &pci_root_ops, controller);
+ 		if (bus = NULL)
+ 			goto error_return; /* error, or bus already scanned */
+ 		bus->sysdata = NULL;
+	}
+
+	if (bus->sysdata)
+		goto error_return; /* sysdata already alloc'd */
+
+	bus->sysdata = controller;
+
 	return;
 
 error_return:
 
-	kfree(sn_controller);
+	kfree(controller);
 	return;
 }
 
@@ -626,12 +679,11 @@ void sn_bus_free_sysdata(void)
  * Ugly hack to get PCI setup until we have a proper ACPI namespace.
  */
 
-#define PCI_BUSES_TO_SCAN 256
-
 static int __init sn_pci_init(void)
 {
 	int i, j;
-	struct pci_dev *pci_dev = NULL;
+	u64 result;
+	s64 status;
 
 	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
 		return 0;
@@ -652,7 +704,7 @@ static int __init sn_pci_init(void)
 	 * This is needed to avoid bounce limit checks in the blk layer
 	 */
 	ia64_max_iommu_merge_mask = ~PAGE_MASK;
-	sn_fixup_ionodes();
+
 	sn_irq_lh_init();
 	INIT_LIST_HEAD(&sn_sysdata_list);
 	sn_init_cpei_timer();
@@ -661,23 +713,29 @@ static int __init sn_pci_init(void)
 	register_sn_procfs();
 #endif
 
+	/*
+	 * If we're running with an ACPI enabled PROM,
+	 * the PROM has generated an ACPI DSDT table, and the Linux
+	 * ACPI code will initiate the PCI bus scanning.
+	 */
+	printk(KERN_INFO "ACPI  DSDT OEM Rev 0x%x\n",
+	       acpi_gbl_DSDT->oem_revision);
+	if (SN_ACPI_BASE_SUPPORT()) {
+		sn_acpi_setup();
+		status = sal_ioif_init(&result);
+		if (status || result)
+			panic("sal_ioif_init failed: [%lx] %s\n",
+			      status, ia64_sal_strerror(status));
+		return 0;
+	}
+
+	sn_fixup_ionodes();
+
 	/* busses are not known yet ... */
 	for (i = 0; i <= max_segment_number; i++)
 		for (j = 0; j <= max_pcibus_number; j++)
 			sn_pci_controller_fixup(i, j, NULL);
 
-	/*
-	 * Generic Linux PCI Layer has created the pci_bus and pci_dev 
-	 * structures - time for us to add our SN PLatform specific 
-	 * information.
-	 */
-
-	while ((pci_dev -		pci_get_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL)
-		sn_pci_fixup_slot(pci_dev);
-
-	sn_ioif_inited = 1;	/* sn I/O infrastructure now initialized */
-
 	return 0;
 }
 
@@ -738,10 +796,199 @@ void sn_generate_path(struct pci_bus *pc
 			sprintf(address, "%s^%d", address, geo_slot(geoid));
 }
 
-subsys_initcall(sn_pci_init);
+arch_initcall(sn_pci_init);
 EXPORT_SYMBOL(sn_pci_fixup_slot);
 EXPORT_SYMBOL(sn_pci_unfixup_slot);
-EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
 EXPORT_SYMBOL(sn_generate_path);
+EXPORT_SYMBOL(sn_pcidev_info_get);
+
+/* IO ACPI Support */
+
+/*
+ * This value must match the UUID the PROM uses
+ * (io/acpi/defblk.c) when building a vendor descriptor.
+ */
+struct acpi_vendor_uuid sn_uuid = {
+	.subtype = 0,
+	.data	= { 0x2c, 0xc6, 0xa6, 0xfe, 0x9c, 0x44, 0xda, 0x11,
+		    0xa2, 0x7c, 0x08, 0x00, 0x69, 0x13, 0xea, 0x51 },
+};
+
+
+/*
+ * sn_hubdev_add() - The 'add' function of the acpi_sn_hubdev_driver.
+ *		     Called for every "SGIHUB" or "SGITIO" device defined
+ *		     in the ACPI namespace.
+ */
+static int __init
+sn_hubdev_add(struct acpi_device *device)
+{
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	struct hubdev_info *hubdev;
+	struct hubdev_info *hubdev_ptr;
+	int i;
+	u64 nasid;
+	int ret = 0;
+	struct acpi_resource *resource;
+	acpi_status status;
+	struct acpi_resource_vendor_typed *vendor;
+
+	status = acpi_get_vendor_resource(device->handle, METHOD_NAME__CRS,
+					  &sn_uuid, &buffer);
+	if (ACPI_FAILURE(status)) {
+		printk(KERN_ERR
+		       "sn_hubdev_add: acpi_get_vendor_resource() failed: %d\n",
+		        status);
+		return 1;
+	}
+
+	resource = buffer.pointer;
+	vendor = &resource->data.vendor_typed;
+	if ((vendor->byte_length - sizeof(struct acpi_vendor_uuid)) !+	    sizeof(struct hubdev_info *)) {
+		printk(KERN_ERR
+		       "sn_hubdev_add: Invalid vendor data length: %d\n",
+		        vendor->byte_length);
+		ret = 1;
+		goto exit;
+	}
+
+	hubdev_ptr = __va(*(struct hubdev_info **) vendor->byte_data);
+
+	nasid = hubdev_ptr->hdi_nasid;
+	i = nasid_to_cnodeid(nasid);
+	hubdev = (struct hubdev_info *)(NODEPDA(i)->pdinfo);
+	*hubdev = *hubdev_ptr;
+	sn_hubdev_init(hubdev);
+
+exit:
+	acpi_os_free(buffer.pointer);
+	return ret;
+}
+
+/*
+ * sn_pci_fixup_bus() - Perform SN specific setup of software structs
+ *			(pcibus_bussoft, pcidev_info) and hardware
+ *			registers, for the specified bus and devices under it.
+ */
+void __devinit
+sn_pci_fixup_bus(struct pci_bus *bus)
+{
+
+	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
+	acpi_handle handle;
+	struct pci_dev *pci_dev = NULL;
+	struct pcibus_bussoft *prom_bussoft_ptr;
+	struct acpi_resource *resource;
+	acpi_status status;
+	struct acpi_resource_vendor_typed *vendor;
+
+	if (!bus->parent) {  /* If root bus */
+		if (SN_ACPI_BASE_SUPPORT()) {
+			handle = PCI_CONTROLLER(bus)->acpi_handle;
+
+			status = acpi_get_vendor_resource(handle,
+							  METHOD_NAME__CRS,
+							  &sn_uuid, &buffer);
+			if (ACPI_FAILURE(status)) {
+				printk(KERN_ERR "sn_pci_fixup_bus: "
+				       "acpi_get_vendor_resource() failed: %d\n",
+				       status);
+				return;
+			}
+			resource = buffer.pointer;
+			vendor = &resource->data.vendor_typed;
+
+			if ((vendor->byte_length -
+			     sizeof(struct acpi_vendor_uuid)) !+			     sizeof(struct pcibus_bussoft *)) {
+				printk(KERN_ERR
+				       "sn_pci_fixup_bus: Invalid vendor data "
+				       "length %d\n", vendor->byte_length);
+				acpi_os_free(buffer.pointer);
+				return;
+			}
+			prom_bussoft_ptr = __va(*(struct pcibus_bussoft **)
+							vendor->byte_data);
+			acpi_os_free(buffer.pointer);
+
+		} else {	/* non-ACPI capable PROM */
+			prom_bussoft_ptr = PCI_CONTROLLER(bus)->platform_data;
+		}
+		sn_common_bus_fixup(bus, prom_bussoft_ptr);
+	}
+	list_for_each_entry(pci_dev, &bus->devices, bus_list) {
+		sn_pci_fixup_slot(pci_dev);
+	}
+}
+
+/*
+ * sn_io_init() - Perform any final platform specific IO initialization.
+ */
+
+int __init
+sn_io_init(void)
+{
+	struct pci_bus *bus;
+	struct pcibus_bussoft *bussoft;
+	cnodeid_t cnode;
+	nasid_t nasid;
+	cnodeid_t near_cnode;
+
+	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
+		return 0;
+
+	/*
+	 * Setup closest node in TIO pci_controller->node for
+	 * PIC, TIOCP, TIOCE (TIOCA does it during bus fixup).
+	 */
+	bus = NULL;
+	while ((bus = pci_find_next_bus(bus)) != NULL) {
+		bussoft = SN_PCIBUS_BUSSOFT(bus);
+		nasid = NASID_GET(bussoft->bs_base);
+		cnode = nasid_to_cnodeid(nasid);
+		if ((bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) ||
+		    (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCE)) {
+			/* TIO PCI Bridge: find nearest node with CPUs */
+			int e = sn_hwperf_get_nearest_node(cnode, NULL,
+							   &near_cnode);
+			if (e < 0) {
+				near_cnode = (cnodeid_t)-1; /* use any node */
+				printk(KERN_WARNING "pcibr_bus_fixup: failed "
+				       "to find near node with CPUs to TIO "
+				       "node %d, err=%d\n", cnode, e);
+			}
+			PCI_CONTROLLER(bus)->node = near_cnode;
+		} else if (bussoft->bs_asic_type = PCIIO_ASIC_TYPE_PIC) {
+			PCI_CONTROLLER(bus)->node = cnode;
+		}
+	}
+
+	sn_ioif_inited = 1;	/* SN I/O infrastructure now initialized */
+
+	return 0;
+}
+
+static struct acpi_driver acpi_sn_hubdev_driver = {
+	.name = "SGI HUBDEV Driver",
+	.ids = "SGIHUB,SGITIO",
+	.ops = {
+		.add = sn_hubdev_add,
+		},
+};
+
+
+/*
+ * sn_acpi_setup() - Register the ACPI driver for the SGIHUB device.
+ *		     This function is expected to be called prior to
+ *		     ACPI initialization (acpi_init()).
+ */
+static void __init
+sn_acpi_setup(void)
+{
+	acpi_bus_register_driver(&acpi_sn_hubdev_driver);
+}
+
+fs_initcall(sn_io_init);
Index: acpi-support/arch/ia64/sn/kernel/iomv.c
=================================--- acpi-support.orig/arch/ia64/sn/kernel/iomv.c	2006-05-31 12:37:50.555920405 -0500
+++ acpi-support/arch/ia64/sn/kernel/iomv.c	2006-05-31 14:10:50.909145020 -0500
@@ -3,10 +3,11 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2000-2003 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2000-2003, 2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/module.h>
+#include <linux/acpi.h>
 #include <asm/io.h>
 #include <asm/delay.h>
 #include <asm/vga.h>
@@ -15,6 +16,7 @@
 #include <asm/sn/pda.h>
 #include <asm/sn/sn_cpuid.h>
 #include <asm/sn/shub_mmr.h>
+#include <asm/sn/acpi.h>
 
 #define IS_LEGACY_VGA_IOPORT(p) \
 	(((p) >= 0x3b0 && (p) <= 0x3bb) || ((p) >= 0x3c0 && (p) <= 0x3df))
@@ -31,11 +33,14 @@ void *sn_io_addr(unsigned long port)
 {
 	if (!IS_RUNNING_ON_SIMULATOR()) {
 		if (IS_LEGACY_VGA_IOPORT(port))
-			port += vga_console_iobase;
+			return (__ia64_mk_io_addr(port));
 		/* On sn2, legacy I/O ports don't point at anything */
 		if (port < (64 * 1024))
 			return NULL;
-		return ((void *)(port | __IA64_UNCACHED_OFFSET));
+		if (SN_ACPI_BASE_SUPPORT())
+			return (__ia64_mk_io_addr(port));
+		else
+			return ((void *)(port | __IA64_UNCACHED_OFFSET));
 	} else {
 		/* but the simulator uses them... */
 		unsigned long addr;
Index: acpi-support/arch/ia64/sn/kernel/setup.c
=================================--- acpi-support.orig/arch/ia64/sn/kernel/setup.c	2006-05-31 12:37:50.555920405 -0500
+++ acpi-support/arch/ia64/sn/kernel/setup.c	2006-05-31 14:10:50.917144258 -0500
@@ -390,6 +390,14 @@ void __init sn_setup(char **cmdline_p)
 	ia64_sn_plat_set_error_handling_features();	// obsolete
 	ia64_sn_set_os_feature(OSF_MCA_SLV_TO_OS_INIT_SLV);
 	ia64_sn_set_os_feature(OSF_FEAT_LOG_SBES);
+	/*
+	 * Note: The calls to notify the PROM of ACPI and PCI Segment
+	 *	 support must be done prior to acpi_load_tables(), as
+	 *	 an ACPI capable PROM will rebuild the DSDT as result
+	 *	 of the call.
+	 */
+	ia64_sn_set_os_feature(OSF_PCISEGMENT_ENABLE);
+	ia64_sn_set_os_feature(OSF_ACPI_ENABLE);
 
 
 #if defined(CONFIG_VT) && defined(CONFIG_VGA_CONSOLE)
@@ -414,6 +422,16 @@ void __init sn_setup(char **cmdline_p)
 
 	if (! vga_console_membase)
 		sn_scan_pcdp();
+
+	/*
+	 *	Setup legacy IO space.
+	 *	vga_console_iobase maps to PCI IO Space address 0 on the
+	 * 	bus containing the VGA console.
+	 */
+	if (vga_console_iobase) {
+		io_space[0].mmio_base = vga_console_iobase;
+		io_space[0].sparse = 0;
+	}
 
 	if (vga_console_membase) {
 		/* usable vga ... make tty0 the preferred default console */
Index: acpi-support/arch/ia64/sn/kernel/tiocx.c
=================================--- acpi-support.orig/arch/ia64/sn/kernel/tiocx.c	2006-05-31 12:37:50.555920405 -0500
+++ acpi-support/arch/ia64/sn/kernel/tiocx.c	2006-05-31 14:10:50.925143496 -0500
@@ -552,7 +552,7 @@ static void __exit tiocx_exit(void)
 	bus_unregister(&tiocx_bus_type);
 }
 
-subsys_initcall(tiocx_init);
+fs_initcall(tiocx_init);
 module_exit(tiocx_exit);
 
 /************************************************************************
Index: acpi-support/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- acpi-support.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2006-05-31 12:37:50.571918823 -0500
+++ acpi-support/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2006-05-31 14:10:50.937142353 -0500
@@ -109,7 +109,6 @@ void *
 pcibr_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *controller)
 {
 	int nasid, cnode, j;
-	cnodeid_t near_cnode;
 	struct hubdev_info *hubdev_info;
 	struct pcibus_info *soft;
 	struct sn_flush_device_kernel *sn_flush_device_kernel;
@@ -186,20 +185,6 @@ pcibr_bus_fixup(struct pcibus_bussoft *p
 		return NULL;
 	}
 
-	if (prom_bussoft->bs_asic_type = PCIIO_ASIC_TYPE_TIOCP) {
-		/* TIO PCI Bridge: find nearest node with CPUs */
-		int e = sn_hwperf_get_nearest_node(cnode, NULL, &near_cnode);
-
-		if (e < 0) {
-			near_cnode = (cnodeid_t)-1; /* use any node */
-			printk(KERN_WARNING "pcibr_bus_fixup: failed to find "
-				"near node with CPUs to TIO node %d, err=%d\n",
-				cnode, e);
-		}
-		controller->node = near_cnode;
-	}
-	else
-		controller->node = cnode;
 	return soft;
 }
 
Index: acpi-support/include/asm-ia64/machvec.h
=================================--- acpi-support.orig/include/asm-ia64/machvec.h	2006-05-31 12:37:50.627913287 -0500
+++ acpi-support/include/asm-ia64/machvec.h	2006-05-31 14:10:50.953140829 -0500
@@ -36,6 +36,7 @@ typedef int ia64_mv_pci_legacy_read_t (s
 typedef int ia64_mv_pci_legacy_write_t (struct pci_bus *, u16 port, u32 val,
 					u8 size);
 typedef void ia64_mv_migrate_t(struct task_struct * task);
+typedef void ia64_mv_pci_fixup_bus_t (struct pci_bus *);
 
 /* DMA-mapping interface: */
 typedef void ia64_mv_dma_init (void);
@@ -92,6 +93,11 @@ machvec_noop_task (struct task_struct *t
 {
 }
 
+static inline void
+machvec_noop_bus (struct pci_bus *bus)
+{
+}
+
 extern void machvec_setup (char **);
 extern void machvec_timer_interrupt (int, void *, struct pt_regs *);
 extern void machvec_dma_sync_single (struct device *, dma_addr_t, size_t, int);
@@ -154,6 +160,7 @@ extern void machvec_tlb_migrate_finish (
 #  define platform_readl_relaxed        ia64_mv.readl_relaxed
 #  define platform_readq_relaxed        ia64_mv.readq_relaxed
 #  define platform_migrate		ia64_mv.migrate
+#  define platform_pci_fixup_bus	ia64_mv.pci_fixup_bus
 # endif
 
 /* __attribute__((__aligned__(16))) is required to make size of the
@@ -203,6 +210,7 @@ struct ia64_machine_vector {
 	ia64_mv_readl_relaxed_t *readl_relaxed;
 	ia64_mv_readq_relaxed_t *readq_relaxed;
 	ia64_mv_migrate_t *migrate;
+	ia64_mv_pci_fixup_bus_t *pci_fixup_bus;
 } __attribute__((__aligned__(16))); /* align attrib? see above comment */
 
 #define MACHVEC_INIT(name)			\
@@ -248,6 +256,7 @@ struct ia64_machine_vector {
 	platform_readl_relaxed,			\
 	platform_readq_relaxed,			\
 	platform_migrate,			\
+	platform_pci_fixup_bus,			\
 }
 
 extern struct ia64_machine_vector ia64_mv;
@@ -400,6 +409,9 @@ extern int ia64_pci_legacy_write(struct 
 #endif
 #ifndef platform_migrate
 # define platform_migrate machvec_noop_task
+#endif
+#ifndef platform_pci_fixup_bus
+# define platform_pci_fixup_bus	machvec_noop_bus
 #endif
 
 #endif /* _ASM_IA64_MACHVEC_H */
Index: acpi-support/include/asm-ia64/machvec_sn2.h
=================================--- acpi-support.orig/include/asm-ia64/machvec_sn2.h	2006-05-31 12:37:50.627913287 -0500
+++ acpi-support/include/asm-ia64/machvec_sn2.h	2006-05-31 14:10:50.961140067 -0500
@@ -67,6 +67,7 @@ extern ia64_mv_dma_sync_sg_for_device	sn
 extern ia64_mv_dma_mapping_error	sn_dma_mapping_error;
 extern ia64_mv_dma_supported		sn_dma_supported;
 extern ia64_mv_migrate_t		sn_migrate;
+extern ia64_mv_pci_fixup_bus_t		sn_pci_fixup_bus;
 
 /*
  * This stuff has dual use!
@@ -117,6 +118,7 @@ extern ia64_mv_migrate_t		sn_migrate;
 #define platform_dma_mapping_error		sn_dma_mapping_error
 #define platform_dma_supported		sn_dma_supported
 #define platform_migrate		sn_migrate
+#define platform_pci_fixup_bus		sn_pci_fixup_bus
 
 #include <asm/sn/io.h>
 
Index: acpi-support/include/asm-ia64/sn/acpi.h
=================================--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ acpi-support/include/asm-ia64/sn/acpi.h	2006-05-31 14:10:50.965139686 -0500
@@ -0,0 +1,16 @@
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
+#define SN_ACPI_BASE_SUPPORT()   (acpi_gbl_DSDT->oem_revision >= 0x20101)
+
+#endif /* _ASM_IA64_SN_ACPI_H */
Index: acpi-support/include/asm-ia64/sn/sn_feature_sets.h
=================================--- acpi-support.orig/include/asm-ia64/sn/sn_feature_sets.h	2006-05-31 12:37:50.635912496 -0500
+++ acpi-support/include/asm-ia64/sn/sn_feature_sets.h	2006-05-31 14:10:50.973138924 -0500
@@ -44,8 +44,14 @@ extern int sn_prom_feature_available(int
  * Once enabled, a feature cannot be disabled.
  *
  * By default, features are disabled unless explicitly enabled.
+ *
+ * These defines must be kept in sync with the corresponding
+ * PROM definitions in feature_sets.h.
  */
 #define  OSF_MCA_SLV_TO_OS_INIT_SLV	0
 #define  OSF_FEAT_LOG_SBES		1
+#define  OSF_ACPI_ENABLE		2
+#define  OSF_PCISEGMENT_ENABLE		3
+
 
 #endif /* _ASM_IA64_SN_FEATURE_SETS_H */
Index: acpi-support/include/asm-ia64/sn/sn_sal.h
=================================--- acpi-support.orig/include/asm-ia64/sn/sn_sal.h	2006-05-31 12:37:50.635912496 -0500
+++ acpi-support/include/asm-ia64/sn/sn_sal.h	2006-05-31 14:10:50.981138162 -0500
@@ -78,6 +78,7 @@
 #define  SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST	   0x02000058	// deprecated
 #define  SN_SAL_IOIF_GET_DEVICE_DMAFLUSH_LIST	   0x0200005a
 
+#define SN_SAL_IOIF_INIT			   0x0200005f
 #define SN_SAL_HUB_ERROR_INTERRUPT		   0x02000060
 #define SN_SAL_BTE_RECOVER			   0x02000061
 #define SN_SAL_RESERVED_DO_NOT_USE		   0x02000062
Index: acpi-support/include/linux/pci.h
=================================--- acpi-support.orig/include/linux/pci.h	2006-05-31 12:37:50.647911309 -0500
+++ acpi-support/include/linux/pci.h	2006-05-31 14:10:50.989137400 -0500
@@ -397,6 +397,7 @@ extern struct bus_type pci_bus_type;
 extern struct list_head pci_root_buses;	/* list of all known PCI buses */
 extern struct list_head pci_devices;	/* list of all devices */
 
+void __devinit pcibios_fixup_device_resources(struct pci_dev *);
 void pcibios_fixup_bus(struct pci_bus *);
 int pcibios_enable_device(struct pci_dev *, int mask);
 char *pcibios_setup (char *str);
Index: acpi-support/include/asm-ia64/sn/pcidev.h
=================================--- acpi-support.orig/include/asm-ia64/sn/pcidev.h	2006-05-31 12:37:50.635912496 -0500
+++ acpi-support/include/asm-ia64/sn/pcidev.h	2006-05-31 14:10:50.993137019 -0500
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 #ifndef _ASM_IA64_SN_PCI_PCIDEV_H
 #define _ASM_IA64_SN_PCI_PCIDEV_H
@@ -12,31 +12,29 @@
 
 /*
  * In ia64, pci_dev->sysdata must be a *pci_controller. To provide access to
- * the pcidev_info structs for all devices under a controller, we extend the
- * definition of pci_controller, via sn_pci_controller, to include a list
- * of pcidev_info.
+ * the pcidev_info structs for all devices under a controller, we keep a
+ * list of pcidev_info under pci_controller->platform_data.
  */
-struct sn_pci_controller {
-	struct pci_controller pci_controller;
+struct sn_platform_data {
+	void *provider_soft;
 	struct list_head pcidev_info;
 };
 
-#define SN_PCI_CONTROLLER(dev) ((struct sn_pci_controller *) dev->sysdata)
+#define SN_PLATFORM_DATA(busdev) \
+	((struct sn_platform_data *)(PCI_CONTROLLER(busdev)->platform_data))
 
 #define SN_PCIDEV_INFO(dev)	sn_pcidev_info_get(dev)
 
-#define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
-	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
 /*
  * Given a pci_bus, return the sn pcibus_bussoft struct.  Note that
  * this only works for root busses, not for busses represented by PPB's.
  */
 
 #define SN_PCIBUS_BUSSOFT(pci_bus) \
-        ((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
+	((struct pcibus_bussoft *)(SN_PLATFORM_DATA(pci_bus)->provider_soft))
 
 #define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
-	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
+	((struct pcibus_info *)(SN_PLATFORM_DATA(pci_bus)->provider_soft))
 /*
  * Given a struct pci_dev, return the sn pcibus_bussoft struct.  Note
  * that this is not equivalent to SN_PCIBUS_BUSSOFT(pci_dev->bus) due
@@ -72,8 +70,6 @@ extern void sn_irq_fixup(struct pci_dev 
 			 struct sn_irq_info *sn_irq_info);
 extern void sn_irq_unfixup(struct pci_dev *pci_dev);
 extern struct pcidev_info * sn_pcidev_info_get(struct pci_dev *);
-extern void sn_pci_controller_fixup(int segment, int busnum,
- 				    struct pci_bus *bus);
 extern void sn_bus_store_sysdata(struct pci_dev *dev);
 extern void sn_bus_free_sysdata(void);
 extern void sn_generate_path(struct pci_bus *pci_bus, char *address);
Index: acpi-support/include/asm-ia64/io.h
=================================--- acpi-support.orig/include/asm-ia64/io.h	2006-05-31 12:37:50.635912496 -0500
+++ acpi-support/include/asm-ia64/io.h	2006-05-31 14:10:50.997136638 -0500
@@ -32,7 +32,7 @@
  */
 #define IO_SPACE_LIMIT		0xffffffffffffffffUL
 
-#define MAX_IO_SPACES_BITS		4
+#define MAX_IO_SPACES_BITS		6
 #define MAX_IO_SPACES			(1UL << MAX_IO_SPACES_BITS)
 #define IO_SPACE_BITS			24
 #define IO_SPACE_SIZE			(1UL << IO_SPACE_BITS)
