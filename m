From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Fri, 06 Aug 2004 20:24:51 +0000
Subject: [PATCH] provide PCI resources with a parent
Message-Id: <200408061324.51802.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_Tk+EBiQiyAlhCjI"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_Tk+EBiQiyAlhCjI
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

In working on the patch to export PCI ROM space via sysfs, I found that the 
sn2 PCI code doesn't assign a parent resource to any of the PCI device 
resources as it builds them.  This provides a simple fix for that problem.

Signed-off-by: Jesse Barnes <jbarnes@sgi.com>

Thanks,
Jesse

--Boundary-00=_Tk+EBiQiyAlhCjI
Content-Type: text/plain;
  charset="us-ascii";
  name="pci-res-parent.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="pci-res-parent.patch"

===== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.42 vs edited =====
--- 1.42/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	2004-06-07 08:45:20 -07:00
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	2004-08-06 10:38:58 -07:00
@@ -290,6 +290,7 @@
 			addr |= __IA64_UNCACHED_OFFSET;
 			dev->resource[idx].start = addr;
 			dev->resource[idx].end = addr + size;
+			dev->resource[idx].parent = &ioport_resource;
 		}
 
 		if (dev->resource[idx].flags & IORESOURCE_IO)
@@ -322,6 +323,7 @@
 			addr |= __IA64_UNCACHED_OFFSET;
 			dev->resource[idx].start = addr;
 			dev->resource[idx].end = addr + size;
+			dev->resource[idx].parent = &iomem_resource;
 		}
 
 		if (dev->resource[idx].flags & IORESOURCE_MEM)
@@ -351,6 +353,7 @@
                         addr |= __IA64_UNCACHED_OFFSET;
                         dev->resource[PCI_ROM_RESOURCE].start = addr;
                         dev->resource[PCI_ROM_RESOURCE].end = addr + size;
+			dev->resource[idx].parent = &iomem_resource;
                         if (dev->resource[PCI_ROM_RESOURCE].flags & IORESOURCE_MEM)
                                 cmd |= PCI_COMMAND_MEMORY;
                 }

--Boundary-00=_Tk+EBiQiyAlhCjI--
