From: Rajesh Shah <rajesh.shah@intel.com>
Date: Fri, 18 Mar 2005 22:11:44 +0000
Subject: [patch 07/12] Make the PCI remove routines safe for failed hot-plug
Message-Id: <20050318141143.G1145@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318133856.A878@unix-os.sc.intel.com>
In-Reply-To: <20050318133856.A878-39QZ/XbsZ5/mO6KZMuUCQVaTQe2KTcn/@public.gmane.org>; from rajesh.shah-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org on Fri, Mar 18, 2005 at 01:38:57PM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh-l3A5Bk7waGM@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: linux-pci-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

When a root bridge hierarchy is hot-plugged, resource requirements
for the new devices may be greater than what the root bridge is
decoding. In this case, we want to remove devices that did not
get needed resources. These devices have been scanned into bus
specific lists but not yet added to the global device list.
Make sure the pci remove functions can handle this case.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-mm4-iohp-rshah1/drivers/pci/remove.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff -puN drivers/pci/remove.c~pci-remove-device-hotplug-safe drivers/pci/remove.c
--- linux-2.6.11-mm4-iohp/drivers/pci/remove.c~pci-remove-device-hotplug-safe	2005-03-16 13:07:22.667319764 -0800
+++ linux-2.6.11-mm4-iohp-rshah1/drivers/pci/remove.c	2005-03-16 13:07:22.775718200 -0800
@@ -26,17 +26,21 @@ static void pci_free_resources(struct pc
 
 static void pci_destroy_dev(struct pci_dev *dev)
 {
-	pci_proc_detach_device(dev);
-	pci_remove_sysfs_dev_files(dev);
-	device_unregister(&dev->dev);
+	if (!list_empty(&dev->global_list)) {
+		pci_proc_detach_device(dev);
+		pci_remove_sysfs_dev_files(dev);
+		device_unregister(&dev->dev);
+		spin_lock(&pci_bus_lock);
+		list_del(&dev->global_list);
+		dev->global_list.next = dev->global_list.prev = NULL;
+		spin_unlock(&pci_bus_lock);
+	}
 
 	/* Remove the device from the device lists, and prevent any further
 	 * list accesses from this device */
 	spin_lock(&pci_bus_lock);
 	list_del(&dev->bus_list);
-	list_del(&dev->global_list);
 	dev->bus_list.next = dev->bus_list.prev = NULL;
-	dev->global_list.next = dev->global_list.prev = NULL;
 	spin_unlock(&pci_bus_lock);
 
 	pci_free_resources(dev);
_
