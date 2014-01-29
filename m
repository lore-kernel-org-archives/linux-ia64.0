From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:17:33 +0000
Subject: [PATCH 01/17] x86/PCI: Drop pcibios_scan_root() check for bus already scanned
Message-Id: <20140129181732.15476.79292.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

The PCI core checks to see whether we've already scanned a bus, so we don't
need to do it in pcibios_scan_root().  Here's where it happens in the core:

  pcibios_scan_root
    pci_scan_bus_on_node
      pci_scan_root_bus
        pci_create_root_bus
	  b2 = pci_find_bus(pci_domain_nr(b), bus)
	  if (b2)
	    goto err_out;    # already scanned this bus

This removes the check from pcibios_scan_root().

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/pci/common.c |    9 ---------
 1 file changed, 9 deletions(-)

diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index 981c2dbd72cc..c47bb2288bb9 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -458,15 +458,6 @@ void __init dmi_check_pciprobe(void)
 
 struct pci_bus *pcibios_scan_root(int busnum)
 {
-	struct pci_bus *bus = NULL;
-
-	while ((bus = pci_find_next_bus(bus)) != NULL) {
-		if (bus->number = busnum) {
-			/* Already scanned */
-			return bus;
-		}
-	}
-
 	return pci_scan_bus_on_node(busnum, &pci_root_ops,
 					get_mp_bus_to_node(busnum));
 }

