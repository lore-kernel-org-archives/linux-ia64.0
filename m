From: Rajesh Shah <rajesh.shah@intel.com>
Date: Fri, 18 Mar 2005 22:07:06 +0000
Subject: [patch 05/12] Take the PCI lock when modifying pci bus or device lists
Message-Id: <20050318140706.E1145@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20050318133856.A878@unix-os.sc.intel.com>
In-Reply-To: <20050318133856.A878-39QZ/XbsZ5/mO6KZMuUCQVaTQe2KTcn/@public.gmane.org>; from rajesh.shah-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org on Fri, Mar 18, 2005 at 01:38:57PM -0800
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: gregkh-l3A5Bk7waGM@public.gmane.org, tony.luck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, len.brown-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Cc: linux-pci-jyMamyUUXNJG4ohzP4jBZS1Fcj925eT/@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, pcihpd-discuss-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-ia64-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, acpi-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org

With root bridge and pci bridge hot-plug, new buses and devices
can be added or removed at run time. Protect the pci bus and
device lists with the pci lock when doing so.

Signed-off-by: Rajesh Shah <rajesh.shah@intel.com>
---

 linux-2.6.11-mm4-iohp-rshah1/drivers/pci/probe.c |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletion(-)

diff -puN drivers/pci/probe.c~lock-pci-root-bus-add drivers/pci/probe.c
--- linux-2.6.11-mm4-iohp/drivers/pci/probe.c~lock-pci-root-bus-add	2005-03-16 13:07:14.694663612 -0800
+++ linux-2.6.11-mm4-iohp-rshah1/drivers/pci/probe.c	2005-03-16 13:07:14.802085486 -0800
@@ -8,6 +8,7 @@
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <linux/cpumask.h>
+#include "pci.h"
 
 #undef DEBUG
 
@@ -380,8 +381,11 @@ struct pci_bus * __devinit pci_add_new_b
 	struct pci_bus *child;
 
 	child = pci_alloc_child_bus(parent, dev, busnr);
-	if (child)
+	if (child) {
+		spin_lock(&pci_bus_lock);
 		list_add_tail(&child->node, &parent->children);
+		spin_unlock(&pci_bus_lock);
+	}
 	return child;
 }
 
@@ -771,7 +775,9 @@ pci_scan_single_device(struct pci_bus *b
 	 * and the bus list for fixup functions, etc.
 	 */
 	INIT_LIST_HEAD(&dev->global_list);
+	spin_lock(&pci_bus_lock);
 	list_add_tail(&dev->bus_list, &bus->devices);
+	spin_unlock(&pci_bus_lock);
 
 	return dev;
 }
@@ -891,7 +897,9 @@ struct pci_bus * __devinit pci_scan_bus_
 		DBG("PCI: Bus %04x:%02x already known\n", pci_domain_nr(b), bus);
 		goto err_out;
 	}
+	spin_lock(&pci_bus_lock);
 	list_add_tail(&b->node, &pci_root_buses);
+	spin_unlock(&pci_bus_lock);
 
 	memset(dev, 0, sizeof(*dev));
 	dev->parent = parent;
@@ -933,7 +941,9 @@ class_dev_create_file_err:
 class_dev_reg_err:
 	device_unregister(dev);
 dev_reg_err:
+	spin_lock(&pci_bus_lock);
 	list_del(&b->node);
+	spin_unlock(&pci_bus_lock);
 err_out:
 	kfree(dev);
 	kfree(b);
_
