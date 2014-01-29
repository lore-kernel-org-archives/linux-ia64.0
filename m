From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:48 +0000
Subject: [PATCH 11/17] x86/PCI: Remove acpi_get_pxm() usage
Message-Id: <20140129181848.15476.265.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The PCI host bridge code doesn't care about _PXM values directly; it only
needs to know what NUMA node the hardware is on.

This uses acpi_get_node() directly and removes the _PXM stuff.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/pci/acpi.c |   19 ++-----------------
 1 file changed, 2 insertions(+), 17 deletions(-)

diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 6304ea0f426d..f44a64c74e37 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -480,9 +480,6 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 	struct pci_bus *bus = NULL;
 	struct pci_sysdata *sd;
 	int node;
-#ifdef CONFIG_ACPI_NUMA
-	int pxm;
-#endif
 
 	if (pci_ignore_seg)
 		domain = 0;
@@ -494,12 +491,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		return NULL;
 	}
 
-	node = NUMA_NO_NODE;
-#ifdef CONFIG_ACPI_NUMA
-	pxm = acpi_get_pxm(device->handle);
-	if (pxm >= 0)
-		node = pxm_to_node(pxm);
-#endif
+	node = acpi_get_node(device->handle);
 	if (node = NUMA_NO_NODE)
 		node = x86_pci_root_bus_node(busnum);
 
@@ -570,15 +562,8 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 			pcie_bus_configure_settings(child);
 	}
 
-	if (bus && node != NUMA_NO_NODE) {
-#ifdef CONFIG_ACPI_NUMA
-		if (pxm >= 0)
-			dev_printk(KERN_DEBUG, &bus->dev,
-				   "on NUMA node %d (pxm %d)\n", node, pxm);
-#else
+	if (bus && node != NUMA_NO_NODE)
 		dev_printk(KERN_DEBUG, &bus->dev, "on NUMA node %d\n", node);
-#endif
-	}
 
 	return bus;
 }

