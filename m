From: John Keller <jpk@sgi.com>
Date: Thu, 02 Mar 2006 16:29:16 +0000
Subject: [PATCH] - SN: Fix cleanup on hotplug removal of PPB
Message-Id: <20060302162916.14657.21703.sendpatchset@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

When doing a hotplug removal of a PPB, sn_bus_store_sysdata()
needs to be called for the PPB and all of its children.

Acked-by: Prarit Bhargava <prarit@sgi.com>
Signed-off-by: John Keller <jpk@sgi.com>


Index: hotplug-fix/drivers/pci/hotplug/sgi_hotplug.c
=================================--- hotplug-fix.orig/drivers/pci/hotplug/sgi_hotplug.c	2006-03-01 13:10:14.389044930 -0600
+++ hotplug-fix/drivers/pci/hotplug/sgi_hotplug.c	2006-03-01 14:30:05.982125135 -0600
@@ -3,7 +3,7 @@
  * License.  See the file "COPYING" in the main directory of this archive
  * for more details.
  *
- * Copyright (C) 2005 Silicon Graphics, Inc. All rights reserved.
+ * Copyright (C) 2005-2006 Silicon Graphics, Inc. All rights reserved.
  *
  * This work was based on the 2.4/2.6 kernel development by Dick Reigner.
  * Work to add BIOS PROM support was completed by Mike Habeck.
@@ -230,6 +230,13 @@ static void sn_bus_free_data(struct pci_
 		list_for_each_entry(child, &subordinate_bus->devices, bus_list)
 			sn_bus_free_data(child);
 	}
+	/*
+	 * Some drivers may use dma accesses during the
+	 * driver remove function. We release the sysdata
+	 * areas after the driver remove functions have
+	 * been called.
+	 */
+	sn_bus_store_sysdata(dev);
 	sn_pci_unfixup_slot(dev);
 }
 
@@ -429,13 +436,6 @@ static int disable_slot(struct hotplug_s
 				   PCI_DEVFN(slot->device_num + 1,
 				   	     PCI_FUNC(func)));
 		if (dev) {
-			/*
-			 * Some drivers may use dma accesses during the
-			 * driver remove function. We release the sysdata
-			 * areas after the driver remove functions have
-			 * been called.
-			 */
-			sn_bus_store_sysdata(dev);
 			sn_bus_free_data(dev);
 			pci_remove_bus_device(dev);
 			pci_dev_put(dev);
