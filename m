From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:17:56 +0000
Subject: [PATCH 04/17] x86/PCI: Merge pci_scan_bus_on_node() into pcibios_scan_root()
Message-Id: <20140129181756.15476.8169.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

pci_scan_bus_on_node() is only called by pcibios_scan_root().
This merges pci_scan_bus_on_node() into pcibios_scan_root() and removes
pci_scan_bus_on_node().

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/include/asm/pci.h |    4 ----
 arch/x86/pci/common.c      |   49 +++++++++++++++++---------------------------
 2 files changed, 19 insertions(+), 34 deletions(-)

diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 4e891abf8b48..b52f9c0ec5fb 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -26,10 +26,6 @@ extern int pci_routeirq;
 extern int noioapicquirk;
 extern int noioapicreroute;
 
-/* scan a bus after allocating a pci_sysdata for it */
-extern struct pci_bus *pci_scan_bus_on_node(int busno, struct pci_ops *ops,
-					    int node);
-
 #ifdef CONFIG_PCI
 
 #ifdef CONFIG_PCI_DOMAINS
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index f530c7e93250..52ad00c2e198 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -458,8 +458,25 @@ void __init dmi_check_pciprobe(void)
 
 struct pci_bus *pcibios_scan_root(int busnum)
 {
-	return pci_scan_bus_on_node(busnum, &pci_root_ops,
-					get_mp_bus_to_node(busnum));
+	struct pci_bus *bus;
+	struct pci_sysdata *sd;
+	LIST_HEAD(resources);
+
+	sd = kzalloc(sizeof(*sd), GFP_KERNEL);
+	if (!sd) {
+		printk(KERN_ERR "PCI: OOM, skipping PCI bus %02x\n", busnum);
+		return NULL;
+	}
+	sd->node = get_mp_bus_to_node(busnum);
+	x86_pci_root_bus_resources(busnum, &resources);
+	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busnum);
+	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, sd, &resources);
+	if (!bus) {
+		pci_free_resource_list(&resources);
+		kfree(sd);
+	}
+
+	return bus;
 }
 
 void __init pcibios_set_cache_line_size(void)
@@ -669,34 +686,6 @@ int pci_ext_cfg_avail(void)
 		return 0;
 }
 
-struct pci_bus *pci_scan_bus_on_node(int busno, struct pci_ops *ops, int node)
-{
-	LIST_HEAD(resources);
-	struct pci_bus *bus = NULL;
-	struct pci_sysdata *sd;
-
-	/*
-	 * Allocate per-root-bus (not per bus) arch-specific data.
-	 * TODO: leak; this memory is never freed.
-	 * It's arguable whether it's worth the trouble to care.
-	 */
-	sd = kzalloc(sizeof(*sd), GFP_KERNEL);
-	if (!sd) {
-		printk(KERN_ERR "PCI: OOM, skipping PCI bus %02x\n", busno);
-		return NULL;
-	}
-	sd->node = node;
-	x86_pci_root_bus_resources(busno, &resources);
-	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busno);
-	bus = pci_scan_root_bus(NULL, busno, ops, sd, &resources);
-	if (!bus) {
-		pci_free_resource_list(&resources);
-		kfree(sd);
-	}
-
-	return bus;
-}
-
 /*
  * NUMA info for PCI busses
  *

