From: John Keller <jpk@sgi.com>
Date: Wed, 31 May 2006 21:23:40 +0000
Subject: [PATCH 2/2] - Altix: Add initial ACPI support
Message-Id: <20060531212340.32077.7712.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, gregkh@suse.de, John Keller <jpk@sgi.com>, pcihpd-discuss@lists.sourceforge.net

This is part 2 of a two patch set.
The patches are dependent on each other.

First phase in introducing ACPI support to SN.
In this phase, when running with an ACPI capable PROM,
the DSDT will define the root busses and all SN nodes
(SGIHUB, SGITIO). An acpi bus driver will be registered
for the node devices, with the acpi_pci_root_driver being
used for the root busses.

Bus to resource ampping will no longer need to be done via
platform specific 'fisxup' code, but by a call to
pcibios_fixup_device_resources().

To maintain backward compatibility with non-ACPI capable PROMs,
none of the current 'fixup' code has been deleted.


Signed-off-by: John Keller <jpk@sgi.com>


Index: acpi-support/drivers/pci/hotplug/sgi_hotplug.c
=================================--- acpi-support.orig/drivers/pci/hotplug/sgi_hotplug.c	2006-05-31 15:17:42.166108287 -0500
+++ acpi-support/drivers/pci/hotplug/sgi_hotplug.c	2006-05-31 15:17:51.045242163 -0500
@@ -205,21 +205,6 @@ static struct hotplug_slot * sn_hp_destr
 	return bss_hotplug_slot;
 }
 
-static void sn_bus_alloc_data(struct pci_dev *dev)
-{
-	struct pci_bus *subordinate_bus;
-	struct pci_dev *child;
-
-	sn_pci_fixup_slot(dev);
-
-	/* Recursively sets up the sn_irq_info structs */
-	if (dev->subordinate) {
-		subordinate_bus = dev->subordinate;
-		list_for_each_entry(child, &subordinate_bus->devices, bus_list)
-			sn_bus_alloc_data(child);
-	}
-}
-
 static void sn_bus_free_data(struct pci_dev *dev)
 {
 	struct pci_bus *subordinate_bus;
@@ -337,6 +322,11 @@ static int sn_slot_disable(struct hotplu
 	return rc;
 }
 
+/*
+ * Power up and configure the slot via a SAL call to PROM.
+ * Scan slot (and any children), do any platform specific fixup,
+ * and find device driver.
+ */
 static int enable_slot(struct hotplug_slot *bss_hotplug_slot)
 {
 	struct slot *slot = bss_hotplug_slot->private;
@@ -367,9 +357,6 @@ static int enable_slot(struct hotplug_sl
 		return -ENODEV;
 	}
 
-	sn_pci_controller_fixup(pci_domain_nr(slot->pci_bus),
-				slot->pci_bus->number,
-				slot->pci_bus);
 	/*
 	 * Map SN resources for all functions on the card
 	 * to the Linux PCI interface and tell the drivers
@@ -380,6 +367,13 @@ static int enable_slot(struct hotplug_sl
 				   PCI_DEVFN(slot->device_num + 1,
 					     PCI_FUNC(func)));
 		if (dev) {
+			/* Need to do slot fixup on PPB before fixup of children
+			 * (PPB's pcidev_info needs to be in pcidev_info list
+			 * before child's SN_PCIDEV_INFO() call to setup
+			 * pdi_host_pcidev_info).
+			 */
+			pcibios_fixup_device_resources(dev);
+			sn_pci_fixup_slot(dev);
 			if (dev->hdr_type = PCI_HEADER_TYPE_BRIDGE) {
 				unsigned char sec_bus;
 				pci_read_config_byte(dev, PCI_SECONDARY_BUS,
@@ -387,12 +381,8 @@ static int enable_slot(struct hotplug_sl
 				new_bus = pci_add_new_bus(dev->bus, dev,
 							  sec_bus);
 				pci_scan_child_bus(new_bus);
-				sn_pci_controller_fixup(pci_domain_nr(new_bus),
-							new_bus->number,
-							new_bus);
 				new_ppb = 1;
 			}
-			sn_bus_alloc_data(dev);
 			pci_dev_put(dev);
 		}
 	}
