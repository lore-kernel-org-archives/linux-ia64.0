From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:03 +0000
Subject: [PATCH 05/17] x86/PCI: Drop return value of pcibios_scan_root()
Message-Id: <20140129181803.15476.65726.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Nobody really uses the return value of pcibios_scan_root() (one place uses
it to control a printk, but the printk is not very useful).  This converts
pcibios_scan_root() to a void function.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/include/asm/pci.h |    2 +-
 arch/x86/pci/common.c      |    6 ++----
 arch/x86/pci/irq.c         |    4 +---
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index b52f9c0ec5fb..96ae4f4040bb 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -65,7 +65,7 @@ extern unsigned long pci_mem_start;
 
 extern int pcibios_enabled;
 void pcibios_config_init(void);
-struct pci_bus *pcibios_scan_root(int bus);
+void pcibios_scan_root(int bus);
 
 void pcibios_set_master(struct pci_dev *dev);
 void pcibios_penalize_isa_irq(int irq, int active);
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 52ad00c2e198..600e5925f1a4 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -456,7 +456,7 @@ void __init dmi_check_pciprobe(void)
 	dmi_check_system(pciprobe_dmi_table);
 }
 
-struct pci_bus *pcibios_scan_root(int busnum)
+void pcibios_scan_root(int busnum)
 {
 	struct pci_bus *bus;
 	struct pci_sysdata *sd;
@@ -465,7 +465,7 @@ struct pci_bus *pcibios_scan_root(int busnum)
 	sd = kzalloc(sizeof(*sd), GFP_KERNEL);
 	if (!sd) {
 		printk(KERN_ERR "PCI: OOM, skipping PCI bus %02x\n", busnum);
-		return NULL;
+		return;
 	}
 	sd->node = get_mp_bus_to_node(busnum);
 	x86_pci_root_bus_resources(busnum, &resources);
@@ -475,8 +475,6 @@ struct pci_bus *pcibios_scan_root(int busnum)
 		pci_free_resource_list(&resources);
 		kfree(sd);
 	}
-
-	return bus;
 }
 
 void __init pcibios_set_cache_line_size(void)
diff --git a/arch/x86/pci/irq.c b/arch/x86/pci/irq.c
index 8658874165c2..84112f55dd7a 100644
--- a/arch/x86/pci/irq.c
+++ b/arch/x86/pci/irq.c
@@ -138,9 +138,7 @@ static void __init pirq_peer_trick(void)
 	for (i = 1; i < 256; i++) {
 		if (!busmap[i] || pci_find_bus(0, i))
 			continue;
-		if (pcibios_scan_root(i))
-			printk(KERN_INFO "PCI: Discovered primary peer "
-			       "bus %02x [IRQ]\n", i);
+		pcibios_scan_root(i);
 	}
 	pcibios_last_bus = -1;
 }

