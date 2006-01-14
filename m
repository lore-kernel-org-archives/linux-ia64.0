From: John Keller <jpk@sgi.com>
Date: Sat, 14 Jan 2006 17:37:47 +0000
Subject: [PATCH] SN: Add initial ACPI support
Message-Id: <20060114173747.12715.63396.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, John Keller <jpk@sgi.com>

First phase in introducing ACPI support to SN.
In this phase, when running with an ACPI capable PROM,
the DSDT will define the root busses and all SN nodes
(SGIHUB, SGITIO). An acpi bus driver will be registered
for the node devices, with the acpi_pci_root_driver being
used for the root busses. Platform specific info is passed
via vendor descriptors, eliminating the corresponding SAL
calls. SN fixup code no longer needs to initiate the
pci bus scans, as the acpi_pci_root_driver takes care of that
for us now.

To maintain backward compatibility with non-ACPI capable PROMs,
none of the current 'fixup' code has been deleted.


Signed-off-by: John Keller <jpk@sgi.com>

Index: acpi_support/arch/ia64/kernel/Makefile
=================================--- acpi_support.orig/arch/ia64/kernel/Makefile	2006-01-14 09:26:29.657192101 -0600
+++ acpi_support/arch/ia64/kernel/Makefile	2006-01-14 09:33:17.118439248 -0600
@@ -11,6 +11,7 @@
 
 obj-$(CONFIG_IA64_BRL_EMU)	+= brl_emu.o
 obj-$(CONFIG_IA64_GENERIC)	+= acpi-ext.o
+obj-$(CONFIG_IA64_SGI_SN2)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1)	+= acpi-ext.o
 obj-$(CONFIG_IA64_HP_ZX1_SWIOTLB) += acpi-ext.o
 obj-$(CONFIG_IA64_PALINFO)	+= palinfo.o
Index: acpi_support/arch/ia64/sn/kernel/io_init.c
=================================--- acpi_support.orig/arch/ia64/sn/kernel/io_init.c	2006-01-14 09:26:29.761674100 -0600
+++ acpi_support/arch/ia64/sn/kernel/io_init.c	2006-01-14 09:45:06.418505048 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1992 - 1997, 2000-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1992 - 1997, 2000-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/bootmem.h>
@@ -21,6 +21,11 @@
 #include <asm/sn/tioce_provider.h>
 #include "xtalk/hubdev.h"
 #include "xtalk/xwidgetdev.h"
+#include <linux/acpi.h>
+
+#define SN_ACPI_BASE_SUPPORT (acpi_gbl_DSDT->oem_revision >= 0x20101)
+
+static void __init sn_acpi_setup(void);
 
 static struct list_head sn_sysdata_list;
 
@@ -157,26 +162,96 @@
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
 
 /*
+ * Perform the early IO init in PROM.
+ */
+inline uint64_t
+sal_ioif_init(void)
+{
+	struct ia64_sal_retval ret_stuff;
+	ret_stuff.status = 0;
+	ret_stuff.v0 = 0;
+
+	SAL_CALL_NOLOCK(ret_stuff,
+			(u64) SN_SAL_IOIF_INIT,
+			0, 0, 0, 0, 0, 0, 0);
+	return ret_stuff.v0;
+}
+
+/*
+ * sn_hubdev_init() - This routine is called to initialize the HUB data
+ *		      structure for each node in the system.
+ */
+static void __init
+sn_hubdev_init(struct hubdev_info *hubdev)
+{
+
+	struct sn_flush_device_list *sn_flush_device_list;
+	u64 status = 0;
+	int widget;
+
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
+	hubdev->hdi_flush_nasid_list.widget_p +	    kmalloc((HUB_WIDGET_ID_MAX + 1) *
+		    sizeof(struct sn_flush_device_list *), GFP_KERNEL);
+
+	memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
+	       (HUB_WIDGET_ID_MAX + 1) *
+	       sizeof(struct sn_flush_device_list *));
+
+	for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
+		sn_flush_device_list = kmalloc(DEV_PER_WIDGET *
+					       sizeof(struct
+						      sn_flush_device_list),
+					       GFP_KERNEL);
+		memset(sn_flush_device_list, 0x0,
+		       DEV_PER_WIDGET *
+		       sizeof(struct sn_flush_device_list));
+
+		status = sal_get_widget_dmaflush_list(hubdev->hdi_nasid, widget,
+						 (uint64_t)
+						 __pa (sn_flush_device_list));
+		if (status) {
+			kfree(sn_flush_device_list);
+			return;
+		}
+
+		spin_lock_init(&sn_flush_device_list->sfdl_flush_lock);
+		hubdev->hdi_flush_nasid_list.widget_p[widget] +		    sn_flush_device_list;
+	}
+}
+
+/*
  * sn_fixup_ionodes() - This routine initializes the HUB data strcuture for 
  *	each node in the system.
  */
 static void sn_fixup_ionodes(void)
 {
-	struct sn_flush_device_kernel *sn_flush_device_kernel;
-	struct sn_flush_device_kernel *dev_entry;
+
 	struct hubdev_info *hubdev;
-	u64 status;
-	u64 nasid;
-	int i, widget, device;
+	uint64_t status;
+	uint64_t nasid;
+	int i;
 
 	/*
 	 * Get SGI Specific HUB chipset information.
@@ -187,7 +262,7 @@
 		nasid = cnodeid_to_nasid(i);
 		hubdev->max_segment_number = 0xffffffff;
 		hubdev->max_pcibus_number = 0xff;
-		status = sal_get_hubdev_info(nasid, (u64) __pa(hubdev));
+		status = sal_get_hubdev_info(nasid, (uint64_t) __pa(hubdev));
 		if (status)
 			continue;
 
@@ -199,64 +274,9 @@
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
-		hubdev->hdi_flush_nasid_list.widget_p -		    kmalloc((HUB_WIDGET_ID_MAX + 1) *
-			    sizeof(struct sn_flush_device_kernel *),
-			    GFP_KERNEL);
-		memset(hubdev->hdi_flush_nasid_list.widget_p, 0x0,
-		       (HUB_WIDGET_ID_MAX + 1) *
-		       sizeof(struct sn_flush_device_kernel *));
-
-		for (widget = 0; widget <= HUB_WIDGET_ID_MAX; widget++) {
-			sn_flush_device_kernel = kmalloc(DEV_PER_WIDGET *
-						         sizeof(struct
-						        sn_flush_device_kernel),
-						        GFP_KERNEL);
-			if (!sn_flush_device_kernel)
-				BUG();
-			memset(sn_flush_device_kernel, 0x0,
-			       DEV_PER_WIDGET *
-			       sizeof(struct sn_flush_device_kernel));
-
-			dev_entry = sn_flush_device_kernel;
-			for (device = 0; device < DEV_PER_WIDGET;
-			     device++,dev_entry++) {
-				dev_entry->common = kmalloc(sizeof(struct
-					      	        sn_flush_device_common),
-					                    GFP_KERNEL);
-				if (!dev_entry->common)
-					BUG();
-				memset(dev_entry->common, 0x0, sizeof(struct
-					     	       sn_flush_device_common));
-
-				status = sal_get_device_dmaflush_list(nasid,
-									widget,
-								       	device,
-						      (u64)(dev_entry->common));
-				if (status)
-					BUG();
-
-				spin_lock_init(&dev_entry->sfdl_flush_lock);
-			}
-
-			if (sn_flush_device_kernel)
-				hubdev->hdi_flush_nasid_list.widget_p[widget] -						       sn_flush_device_kernel;
-	        }
+		sn_hubdev_init(hubdev);
 	}
+
 }
 
 /*
@@ -351,9 +371,9 @@
 	if (status)
 		BUG(); /* Cannot get platform pci device information */
 
-	/* Add pcidev_info to list in sn_pci_controller struct */
+	/* Add pcidev_info to list in pci_controller.platform_data */
 	list_add_tail(&pcidev_info->pdi_list,
-		      &(SN_PCI_CONTROLLER(dev->bus)->pcidev_info));
+		      &(SN_PLATFORM_DATA(dev->bus)->pcidev_info));
 
 	/* Copy over PIO Mapped Addresses */
 	for (idx = 0; idx <= PCI_ROM_RESOURCE; idx++) {
@@ -422,19 +442,116 @@
 }
 
 /*
+ * sn_common_bus_fixup()
+ */
+static int
+sn_common_bus_fixup(struct pci_bus *bus,
+		    struct pcibus_bussoft *prom_bussoft_ptr)
+{
+	int	cnode;
+	struct pci_controller *controller;
+	struct hubdev_info *hubdev_info;
+	int	nasid;
+	void *provider_soft = NULL;
+	struct sn_pcibus_provider *provider;
+	struct sn_platform_data *sn_platform_data;
+
+	controller = PCI_CONTROLLER(bus);
+        /*
+         * Per-provider fixup.  Copies the bus soft structure from prom
+         * to local area and links SN_PCIBUS_BUSSOFT().
+         */
+
+        if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES)
+                return -1;              /* unsupported asic type */
+
+        if (prom_bussoft_ptr->bs_asic_type = PCIIO_ASIC_TYPE_PPB)
+                return -1;              /* no further fixup necessary */
+
+        provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
+        if (provider = NULL)
+                return -1;      /* No provider registered for this asic */
+
+        if (provider->bus_fixup)
+                provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr,
+                                controller);
+
+        if (provider_soft = NULL)
+                return -1;              /* fixup failed or not applicable */
+
+        /*
+         * Setup pci_windows for legacy IO and MEM space.
+         * (Temporary until ACPI support is in place.)
+         */
+        controller->window = kcalloc(2, sizeof(struct pci_window), GFP_KERNEL);
+        if (controller->window = NULL)
+                BUG();
+        controller->window[0].offset = prom_bussoft_ptr->bs_legacy_io;
+        controller->window[0].resource.name = "legacy_io";
+        controller->window[0].resource.flags = IORESOURCE_IO;
+        controller->window[0].resource.start = prom_bussoft_ptr->bs_legacy_io;
+        controller->window[0].resource.end +            controller->window[0].resource.start + 0xffff;
+        controller->window[0].resource.parent = &ioport_resource;
+        controller->window[1].offset = prom_bussoft_ptr->bs_legacy_mem;
+        controller->window[1].resource.name = "legacy_mem";
+        controller->window[1].resource.flags = IORESOURCE_MEM;
+        controller->window[1].resource.start = prom_bussoft_ptr->bs_legacy_mem;
+        controller->window[1].resource.end +            controller->window[1].resource.start + (1024 * 1024) - 1;
+        controller->window[1].resource.parent = &iomem_resource;
+        controller->windows = 2;
+
+        /*
+         * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
+         * after this point.
+         */
+
+
+        controller->platform_data +                kzalloc(sizeof(struct sn_platform_data), GFP_KERNEL);
+	if (controller->platform_data = NULL)
+		BUG();
+        sn_platform_data +                (struct sn_platform_data *) controller->platform_data;
+        sn_platform_data->provider_soft = provider_soft;
+        INIT_LIST_HEAD(&((struct sn_platform_data *)
+                controller->platform_data)->pcidev_info);
+
+        nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
+        cnode = nasid_to_cnodeid(nasid);
+        hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
+        SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info +            &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
+
+        /*
+         * If the node information we obtained during the fixup phase is invalid
+         * then set controller->node to -1 (undetermined)
+         */
+        if (controller->node >= num_online_nodes()) {
+                struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
+
+                printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%u"
+                                    "L_IO=%lx L_MEM=%lx BASE=%lx\n",
+                        b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
+                        b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
+                printk(KERN_WARNING "on node %d but only %d nodes online."
+                        "Association set to undetermined.\n",
+                        controller->node, num_online_nodes());
+                controller->node = -1;
+        }
+	return 0;
+}
+
+/*
  * sn_pci_controller_fixup() - This routine sets up a bus's resources
  * consistent with the Linux PCI abstraction layer.
  */
 void sn_pci_controller_fixup(int segment, int busnum, struct pci_bus *bus)
 {
 	int status = 0;
-	int nasid, cnode;
 	struct pci_controller *controller;
-	struct sn_pci_controller *sn_controller;
 	struct pcibus_bussoft *prom_bussoft_ptr;
-	struct hubdev_info *hubdev_info;
-	void *provider_soft = NULL;
-	struct sn_pcibus_provider *provider;
 
  	status = sal_get_pcibus_info((u64) segment, (u64) busnum,
  				     (u64) ia64_tpa(&prom_bussoft_ptr));
@@ -442,14 +559,9 @@
 		return;		/*bus # does not exist */
 	prom_bussoft_ptr = __va(prom_bussoft_ptr);
 
-	/* Allocate a sn_pci_controller, which has a pci_controller struct
-	 * as the first member.
-	 */
-	sn_controller = kzalloc(sizeof(struct sn_pci_controller), GFP_KERNEL);
-	if (!sn_controller)
+	controller = kzalloc(sizeof(struct pci_controller), GFP_KERNEL);
+	if (!controller)
 		BUG();
-	INIT_LIST_HEAD(&sn_controller->pcidev_info);
-	controller = &sn_controller->pci_controller;
 	controller->segment = segment;
 
 	if (bus = NULL) {
@@ -462,87 +574,16 @@
 	if (bus->sysdata)
 		goto error_return; /* sysdata already alloc'd */
 
-	/*
-	 * Per-provider fixup.  Copies the contents from prom to local
-	 * area and links SN_PCIBUS_BUSSOFT().
-	 */
-
-	if (prom_bussoft_ptr->bs_asic_type >= PCIIO_ASIC_MAX_TYPES)
-		goto error_return; /* unsupported asic type */
-
-	if (prom_bussoft_ptr->bs_asic_type = PCIIO_ASIC_TYPE_PPB)
-		goto error_return; /* no further fixup necessary */
-
-	provider = sn_pci_provider[prom_bussoft_ptr->bs_asic_type];
-	if (provider = NULL)
-		goto error_return; /* no provider registerd for this asic */
-
 	bus->sysdata = controller;
-	if (provider->bus_fixup)
-		provider_soft = (*provider->bus_fixup) (prom_bussoft_ptr, controller);
-
-	if (provider_soft = NULL) {
-		/* fixup failed or not applicable */
+	if (sn_common_bus_fixup(bus, prom_bussoft_ptr)) {
 		bus->sysdata = NULL;
 		goto error_return;
 	}
-
-	/*
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
-	 * Generic bus fixup goes here.  Don't reference prom_bussoft_ptr
-	 * after this point.
-	 */
-
-	PCI_CONTROLLER(bus)->platform_data = provider_soft;
-	nasid = NASID_GET(SN_PCIBUS_BUSSOFT(bus)->bs_base);
-	cnode = nasid_to_cnodeid(nasid);
-	hubdev_info = (struct hubdev_info *)(NODEPDA(cnode)->pdinfo);
-	SN_PCIBUS_BUSSOFT(bus)->bs_xwidget_info -	    &(hubdev_info->hdi_xwidget_info[SN_PCIBUS_BUSSOFT(bus)->bs_xid]);
-
-	/*
-	 * If the node information we obtained during the fixup phase is invalid
-	 * then set controller->node to -1 (undetermined)
-	 */
-	if (controller->node >= num_online_nodes()) {
-		struct pcibus_bussoft *b = SN_PCIBUS_BUSSOFT(bus);
-
-		printk(KERN_WARNING "Device ASIC=%u XID=%u PBUSNUM=%u"
-				    "L_IO=%lx L_MEM=%lx BASE=%lx\n",
-			b->bs_asic_type, b->bs_xid, b->bs_persist_busnum,
-			b->bs_legacy_io, b->bs_legacy_mem, b->bs_base);
-		printk(KERN_WARNING "on node %d but only %d nodes online."
-			"Association set to undetermined.\n",
-			controller->node, num_online_nodes());
-		controller->node = -1;
-	}
 	return;
 
 error_return:
 
-	kfree(sn_controller);
+	kfree(controller);
 	return;
 }
 
@@ -610,6 +651,20 @@
 	 * This is needed to avoid bounce limit checks in the blk layer
 	 */
 	ia64_max_iommu_merge_mask = ~PAGE_MASK;
+
+	/*
+	 * If we're running with an ACPI 2.0 enabled PROM,
+	 * the PROM has generated a ACPI DSDT table, and the Linux
+	 * ACPI code will do the PCI bus scanning. We'll still need
+	 * to do some 'fixup' later on in sn_io_fixup().
+	 */
+	printk("ACPI  DSDT OEM Rev 0x%x\n", acpi_gbl_DSDT->oem_revision);
+	if (SN_ACPI_BASE_SUPPORT) {
+		sn_acpi_setup();
+		sal_ioif_init();
+		return 0;
+	}
+
 	sn_fixup_ionodes();
 	sn_irq_lh_init();
 	INIT_LIST_HEAD(&sn_sysdata_list);
@@ -679,3 +734,174 @@
 EXPORT_SYMBOL(sn_pci_controller_fixup);
 EXPORT_SYMBOL(sn_bus_store_sysdata);
 EXPORT_SYMBOL(sn_bus_free_sysdata);
+
+
+
+/* IO ACPI Support */
+
+/* Copy from arch/ia64/kernel/acpi-ext.c */
+struct acpi_vendor_descriptor {
+        u8		guid_id;
+        efi_guid_t	guid;
+};
+
+/*
+ * Arbitrary GUID taken from internal SGI machine.
+ * This value must match the UUID the PROM uses
+ * (io/acpi/defblk.c) when building a vendor descriptor.
+ */
+struct acpi_vendor_descriptor sn_descriptor = {
+        .guid_id = 0,
+        .guid    = EFI_GUID(0xfea6c62c, 0x449c, 0x11da,
+			    0xa2, 0x7c, 0x08, 0x00, 0x69, 0x13, 0xea, 0x51)
+};
+
+extern acpi_status acpi_find_vendor_resource(acpi_handle,
+	struct acpi_vendor_descriptor *, u8 **, u32 *);
+
+
+/*
+ * sn_hubdev_add() - The 'add' function of the acpi_sn_hubdev_driver.
+ * 		     Called for every "SGIHUB" or "SGITIO" device defined
+ *		     in the ACPI namespace.
+ */
+static int __init
+sn_hubdev_add(struct acpi_device *device)
+{
+	u8		*data;
+	struct hubdev_info *hubdev;
+	struct hubdev_info *hubdev_ptr;
+	int		i;
+	u32		length;
+	u64		nasid;
+	acpi_status     status;
+
+	status = acpi_find_vendor_resource(device->handle, &sn_descriptor,
+					   &data, &length);
+	if (ACPI_FAILURE(status) || (length != 8)) {
+		printk("sn_hubdev_add: Failure %d - Data length=%d\n",
+			status, length);
+		return 1;
+	}
+
+	hubdev_ptr = __va(*(struct hubdev_info **) data);
+
+	nasid = hubdev_ptr->hdi_nasid;
+	i = nasid_to_cnodeid(nasid);
+	hubdev = (struct hubdev_info *)(NODEPDA(i)->pdinfo);
+	*hubdev = *hubdev_ptr;
+	sn_hubdev_init(hubdev);
+
+	acpi_os_free(data);
+	return 0;
+}
+
+
+/*
+ * sn_pci_bus_fixup() - This routine sets up a bus' resources
+ *			consistent with the Linux PCI abstraction layer.
+ */
+static int __init
+sn_pci_bus_fixup(struct pci_bus *bus)
+{
+
+	struct pci_controller *controller;
+	u8		*data;
+	acpi_handle	handle;
+	u32		length;
+	struct pcibus_bussoft *prom_bussoft_ptr;
+	int		ret = 0;
+        acpi_status	status;
+
+	handle = PCI_CONTROLLER(bus)->acpi_handle;
+	controller = PCI_CONTROLLER(bus);
+
+	status = acpi_find_vendor_resource(handle, &sn_descriptor, &data,
+					   &length);
+	if (ACPI_FAILURE(status) || (length != 8)) {
+		printk("sn_pci_bus_fixup: Failure %d - length=%d\n",
+			status, length);
+		return -1;
+	}
+	prom_bussoft_ptr = __va(*(struct pcibus_bussoft **) data);
+
+	if (sn_common_bus_fixup(bus, prom_bussoft_ptr)) {
+		ret = -1;
+	}
+	acpi_os_free(data);
+	return ret;
+}
+
+/*
+ * sn_io_fixup() - Perform platform specific bus and device fixup,
+ *		   if running with an ACPI capable PROM.
+ */
+
+static int __init
+sn_io_fixup(void)
+{
+	struct pci_bus *bus;
+	struct pci_dev *pci_dev = NULL;
+	extern void sn_init_cpei_timer(void);
+#ifdef CONFIG_PROC_FS
+	extern void register_sn_procfs(void);
+#endif
+
+	if (!ia64_platform_is("sn2") || IS_RUNNING_ON_FAKE_PROM())
+		return 0;
+
+	/* Exit if running with old PROM without ACPI support */
+	if (!SN_ACPI_BASE_SUPPORT)
+		return 0;
+
+	sn_irq_lh_init();
+	INIT_LIST_HEAD(&sn_sysdata_list);
+	sn_init_cpei_timer();
+
+#ifdef CONFIG_PROC_FS
+	register_sn_procfs();
+#endif
+
+	/*
+	 * Generic Linux PCI Layer has created the pci_bus and pci_dev
+	 * structures - time for us to add our SN Platform specific
+	 * information.
+	 */
+
+	bus = NULL;
+	while ((bus = pci_find_next_bus(bus)) != NULL)
+		sn_pci_bus_fixup(bus);
+
+	while ((pci_dev +		pci_find_device(PCI_ANY_ID, PCI_ANY_ID, pci_dev)) != NULL) {
+		sn_pci_fixup_slot(pci_dev);
+	}
+
+	sn_ioif_inited = 1;     /* sn I/O infrastructure now initialized */
+
+	return 0;
+}
+
+static struct acpi_driver acpi_sn_hubdev_driver = {
+        .name = "SGI HUBDEV Driver",
+        .ids = "SGIHUB,SGITIO",
+        .ops = {
+                .add    = sn_hubdev_add,
+        	},
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
+fs_initcall(sn_io_fixup);
+
+
Index: acpi_support/include/asm-ia64/sn/sn_sal.h
=================================--- acpi_support.orig/include/asm-ia64/sn/sn_sal.h	2006-01-14 09:26:40.515508222 -0600
+++ acpi_support/include/asm-ia64/sn/sn_sal.h	2006-01-14 09:33:17.128203922 -0600
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2000-2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2000-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -78,6 +78,7 @@
 #define  SN_SAL_IOIF_GET_WIDGET_DMAFLUSH_LIST	   0x02000058	// deprecated
 #define  SN_SAL_IOIF_GET_DEVICE_DMAFLUSH_LIST	   0x0200005a
 
+#define SN_SAL_IOIF_INIT			   0x0200005f
 #define SN_SAL_HUB_ERROR_INTERRUPT		   0x02000060
 #define SN_SAL_BTE_RECOVER			   0x02000061
 #define SN_SAL_RESERVED_DO_NOT_USE		   0x02000062
Index: acpi_support/arch/ia64/sn/kernel/setup.c
=================================--- acpi_support.orig/arch/ia64/sn/kernel/setup.c	2006-01-14 09:26:29.764603502 -0600
+++ acpi_support/arch/ia64/sn/kernel/setup.c	2006-01-14 09:33:17.129180390 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 1999,2001-2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 1999,2001-2006 Silicon Graphics, Inc. All rights reserved.
  */
 
 #include <linux/config.h>
@@ -389,6 +389,14 @@
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
Index: acpi_support/include/asm-ia64/sn/sn_feature_sets.h
=================================--- acpi_support.orig/include/asm-ia64/sn/sn_feature_sets.h	2006-01-14 09:26:40.514531754 -0600
+++ acpi_support/include/asm-ia64/sn/sn_feature_sets.h	2006-01-14 09:33:17.130156857 -0600
@@ -8,7 +8,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2005-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 
@@ -50,8 +50,13 @@
  * Once enabled, a feature cannot be disabled.
  *
  * By default, features are disabled unless explicitly enabled.
+ *
+ * These defines must be kept in sync with the corresponding
+ * PROM definitions in feature_sets.h.
  */
 #define  OSF_MCA_SLV_TO_OS_INIT_SLV		0
 #define  OSF_FEAT_LOG_SBES			1
+#define  OSF_ACPI_ENABLE			2
+#define  OSF_PCISEGMENT_ENABLE			3
 
 #endif /* _ASM_IA64_SN_FEATURE_SETS_H */
Index: acpi_support/include/asm-ia64/sn/pcidev.h
=================================--- acpi_support.orig/include/asm-ia64/sn/pcidev.h	2006-01-14 09:26:40.500861213 -0600
+++ acpi_support/include/asm-ia64/sn/pcidev.h	2006-01-14 09:33:17.131133325 -0600
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
+        ((struct pcibus_bussoft *)(SN_PLATFORM_DATA(pci_bus)->provider_soft))
 
 #define SN_PCIBUS_BUSSOFT_INFO(pci_bus) \
-	(struct pcibus_info *)((struct pcibus_bussoft *)(PCI_CONTROLLER((pci_bus))->platform_data))
+	((struct pcibus_info *)(SN_PLATFORM_DATA(pci_bus)->provider_soft))
 /*
  * Given a struct pci_dev, return the sn pcibus_bussoft struct.  Note
  * that this is not equivalent to SN_PCIBUS_BUSSOFT(pci_dev->bus) due
Index: acpi_support/arch/ia64/sn/kernel/tiocx.c
=================================--- acpi_support.orig/arch/ia64/sn/kernel/tiocx.c	2006-01-14 09:26:29.770462305 -0600
+++ acpi_support/arch/ia64/sn/kernel/tiocx.c	2006-01-14 09:33:17.132109792 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (c) 2005 Silicon Graphics, Inc.  All rights reserved.
+ * Copyright (c) 2005-2006 Silicon Graphics, Inc.  All rights reserved.
  */
 
 #include <linux/module.h>
@@ -548,7 +548,7 @@
 	bus_unregister(&tiocx_bus_type);
 }
 
-subsys_initcall(tiocx_init);
+fs_initcall(tiocx_init);
 module_exit(tiocx_exit);
 
 /************************************************************************
