From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 29 Jan 2014 18:17:41 +0000
Subject: [PATCH 02/17] x86/PCI: Use pcibios_scan_root() instead of pci_scan_bus_with_sysdata()
Message-Id: <20140129181741.15476.52860.stgit@bhelgaas-glaptop.roam.corp.google.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
In-Reply-To: <20140129174106.15476.7075.stgit@bhelgaas-glaptop.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-pci@vger.kernel.org
Cc: linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

pci_scan_bus_with_sysdata() and pcibios_scan_root() are quite similar:

  pci_scan_bus_with_sysdata
    pci_scan_bus_on_node(..., &pci_root_ops, -1)

  pcibios_scan_root
    pci_scan_bus_on_node(..., &pci_root_ops, get_mp_bus_to_node(busnum))

get_mp_bus_to_node() returns -1 if it couldn't find the node number, so
this removes pci_scan_bus_with_sysdata() and uses pcibios_scan_root()
instead.

Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/x86/include/asm/pci.h |    1 -
 arch/x86/pci/common.c      |    5 -----
 arch/x86/pci/fixup.c       |    6 +++---
 arch/x86/pci/numaq_32.c    |    6 +++---
 arch/x86/pci/visws.c       |    4 ++--
 5 files changed, 8 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/pci.h b/arch/x86/include/asm/pci.h
index 1ac6114c9ea5..4e891abf8b48 100644
--- a/arch/x86/include/asm/pci.h
+++ b/arch/x86/include/asm/pci.h
@@ -29,7 +29,6 @@ extern int noioapicreroute;
 /* scan a bus after allocating a pci_sysdata for it */
 extern struct pci_bus *pci_scan_bus_on_node(int busno, struct pci_ops *ops,
 					    int node);
-extern struct pci_bus *pci_scan_bus_with_sysdata(int busno);
 
 #ifdef CONFIG_PCI
 
diff --git a/arch/x86/pci/common.c b/arch/x86/pci/common.c
index c47bb2288bb9..f530c7e93250 100644
--- a/arch/x86/pci/common.c
+++ b/arch/x86/pci/common.c
@@ -697,11 +697,6 @@ struct pci_bus *pci_scan_bus_on_node(int busno, struct pci_ops *ops, int node)
 	return bus;
 }
 
-struct pci_bus *pci_scan_bus_with_sysdata(int busno)
-{
-	return pci_scan_bus_on_node(busno, &pci_root_ops, -1);
-}
-
 /*
  * NUMA info for PCI busses
  *
diff --git a/arch/x86/pci/fixup.c b/arch/x86/pci/fixup.c
index bca9e85daaa5..201833f5f1bc 100644
--- a/arch/x86/pci/fixup.c
+++ b/arch/x86/pci/fixup.c
@@ -25,9 +25,9 @@ static void pci_fixup_i450nx(struct pci_dev *d)
 		dev_dbg(&d->dev, "i450NX PXB %d: %02x/%02x/%02x\n", pxb, busno,
 			suba, subb);
 		if (busno)
-			pci_scan_bus_with_sysdata(busno);	/* Bus A */
+			pcibios_scan_root(busno);	/* Bus A */
 		if (suba < subb)
-			pci_scan_bus_with_sysdata(suba+1);	/* Bus B */
+			pcibios_scan_root(suba+1);	/* Bus B */
 	}
 	pcibios_last_bus = -1;
 }
@@ -42,7 +42,7 @@ static void pci_fixup_i450gx(struct pci_dev *d)
 	u8 busno;
 	pci_read_config_byte(d, 0x4a, &busno);
 	dev_info(&d->dev, "i440KX/GX host bridge; secondary bus %02x\n", busno);
-	pci_scan_bus_with_sysdata(busno);
+	pcibios_scan_root(busno);
 	pcibios_last_bus = -1;
 }
 DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82454GX, pci_fixup_i450gx);
diff --git a/arch/x86/pci/numaq_32.c b/arch/x86/pci/numaq_32.c
index 72c229f9ebcf..080eb0374fff 100644
--- a/arch/x86/pci/numaq_32.c
+++ b/arch/x86/pci/numaq_32.c
@@ -135,11 +135,11 @@ static void pci_fixup_i450nx(struct pci_dev *d)
 			pxb, busno, suba, subb);
 		if (busno) {
 			/* Bus A */
-			pci_scan_bus_with_sysdata(QUADLOCAL2BUS(quad, busno));
+			pcibios_scan_root(QUADLOCAL2BUS(quad, busno));
 		}
 		if (suba < subb) {
 			/* Bus B */
-			pci_scan_bus_with_sysdata(QUADLOCAL2BUS(quad, suba+1));
+			pcibios_scan_root(QUADLOCAL2BUS(quad, suba+1));
 		}
 	}
 	pcibios_last_bus = -1;
@@ -159,7 +159,7 @@ int __init pci_numaq_init(void)
 				continue;
 			printk("Scanning PCI bus %d for quad %d\n", 
 				QUADLOCAL2BUS(quad,0), quad);
-			pci_scan_bus_with_sysdata(QUADLOCAL2BUS(quad, 0));
+			pcibios_scan_root(QUADLOCAL2BUS(quad, 0));
 		}
 	return 0;
 }
diff --git a/arch/x86/pci/visws.c b/arch/x86/pci/visws.c
index 3e6d2a6db866..cd9d4d1681d2 100644
--- a/arch/x86/pci/visws.c
+++ b/arch/x86/pci/visws.c
@@ -78,8 +78,8 @@ int __init pci_visws_init(void)
 		"bridge B (PIIX4) bus: %u\n", pci_bus1, pci_bus0);
 
 	raw_pci_ops = &pci_direct_conf1;
-	pci_scan_bus_with_sysdata(pci_bus0);
-	pci_scan_bus_with_sysdata(pci_bus1);
+	pcibios_scan_root(pci_bus0);
+	pcibios_scan_root(pci_bus1);
 	pci_fixup_irqs(pci_common_swizzle, visws_map_irq);
 	pcibios_resource_survey();
 	/* Request bus scan */

