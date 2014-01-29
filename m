From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:19 +0000
Subject: [PATCH 07/17] x86/PCI: Use x86_pci_root_bus_node() instead of get_mp_bus_to_node()
Message-Id: <20140129181819.15476.16563.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

This replaces all uses of get_mp_bus_to_node() with x86_pci_root_bus_node().

I think these uses are all on root buses, except possibly for blind
probing, where NUMA node information is unimportant.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/pci/acpi.c   |    2 +-
 arch/x86/pci/common.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/x86/pci/acpi.c b/arch/x86/pci/acpi.c
index 4f25ec077552..3f42c5c05bf6 100644
--- a/arch/x86/pci/acpi.c
+++ b/arch/x86/pci/acpi.c
@@ -503,7 +503,7 @@ struct pci_bus *pci_acpi_scan_root(struct acpi_pci_root *root)
 		set_mp_bus_to_node(busnum, node);
 	else
 #endif
-		node = get_mp_bus_to_node(busnum);
+		node = x86_pci_root_bus_node(busnum);
 
 	if (node != -1 && !node_online(node))
 		node = -1;
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 600e5925f1a4..f7d6800f10d1 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -467,7 +467,7 @@ void pcibios_scan_root(int busnum)
 		printk(KERN_ERR "PCI: OOM, skipping PCI bus %02x\n", busnum);
 		return;
 	}
-	sd->node = get_mp_bus_to_node(busnum);
+	sd->node = x86_pci_root_bus_node(busnum);
 	x86_pci_root_bus_resources(busnum, &resources);
 	printk(KERN_DEBUG "PCI: Probing PCI hardware (bus %02x)\n", busnum);
 	bus = pci_scan_root_bus(NULL, busnum, &pci_root_ops, sd, &resources);

