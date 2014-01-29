From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:18:11 +0000
Subject: [PATCH 06/17] x86/PCI: Add x86_pci_root_bus_node() to look up NUMA node from PCI bus
Message-Id: <20140129181811.15476.19897.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The AMD early_fill_mp_bus_info() already allocates a struct pci_root_info
for each PCI host bridge it finds, and that structure contains the NUMA
node number.  We don't need to keep the same information in the
mp_bus_to_node[] table.

This adds x86_pci_root_bus_node(), which returns the NUMA node number, or
NUMA_NO_NODE if the node is unknown.

Note that unlike get_mp_bus_to_node(), x86_pci_root_bus_node() only works
for root buses.  For example, if amd_bus.c finds a host bridge on node 1 to
[bus 00-0f], get_mp_bus_to_node() returns 1 for any bus between 00 and 0f,
but x86_pci_root_bus_node() returns 1 for bus 00 and NUMA_NO_NODE for buses
01-0f.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/include/asm/topology.h |    1 +
 arch/x86/pci/bus_numa.c         |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/arch/x86/include/asm/topology.h b/arch/x86/include/asm/topology.h
index d35f24e231cd..09046a1a6c35 100644
--- a/arch/x86/include/asm/topology.h
+++ b/arch/x86/include/asm/topology.h
@@ -131,6 +131,7 @@ static inline void arch_fix_phys_package_id(int num, u32 slot)
 }
 
 struct pci_bus;
+int x86_pci_root_bus_node(int bus);
 void x86_pci_root_bus_resources(int bus, struct list_head *resources);
 
 #ifdef CONFIG_SMP
diff --git a/arch/x86/pci/bus_numa.c b/arch/x86/pci/bus_numa.c
index c2735feb2508..2e36a4469549 100644
--- a/arch/x86/pci/bus_numa.c
+++ b/arch/x86/pci/bus_numa.c
@@ -20,6 +20,16 @@ static struct pci_root_info *x86_find_pci_root_info(int bus)
 	return NULL;
 }
 
+int x86_pci_root_bus_node(int bus)
+{
+	struct pci_root_info *info = x86_find_pci_root_info(bus);
+
+	if (!info)
+		return NUMA_NO_NODE;
+
+	return info->node;
+}
+
 void x86_pci_root_bus_resources(int bus, struct list_head *resources)
 {
 	struct pci_root_info *info = x86_find_pci_root_info(bus);

