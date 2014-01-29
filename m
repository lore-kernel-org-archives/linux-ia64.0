From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:41 +0000
Subject: [PATCH 10/17] x86/PCI: Use NUMA_NO_NODE, not -1, for unknown node
Message-Id: <20140129181841.15476.36375.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

NUMA_NO_NODE is the usual value for "we don't know what node this is on,"
e.g., it is the error return from acpi_get_node().  This changes uses of -1
to NUMA_NO_NODE.  NUMA_NO_NODE is #defined to be -1 already, so this is not
a functional change.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/pci/acpi.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 78f27efa11e1..6304ea0f426d 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -494,17 +494,17 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		return NULL;
 	}
 
-	node = -1;
+	node = NUMA_NO_NODE;
 #ifdef CONFIG_ACPI_NUMA
 	pxm = acpi_get_pxm(device->handle);
 	if (pxm >= 0)
 		node = pxm_to_node(pxm);
 #endif
-	if (node = -1)
+	if (node = NUMA_NO_NODE)
 		node = x86_pci_root_bus_node(busnum);
 
-	if (node != -1 && !node_online(node))
-		node = -1;
+	if (node != NUMA_NO_NODE && !node_online(node))
+		node = NUMA_NO_NODE;
 
 	info = kzalloc(sizeof(*info), GFP_KERNEL);
 	if (!info) {
@@ -570,7 +570,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 			pcie_bus_configure_settings(child);
 	}
 
-	if (bus && node != -1) {
+	if (bus && node != NUMA_NO_NODE) {
 #ifdef CONFIG_ACPI_NUMA
 		if (pxm >= 0)
 			dev_printk(KERN_DEBUG, &bus->dev,

