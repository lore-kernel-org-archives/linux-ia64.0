From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 12 May 2004 21:43:06 +0000
Subject: [PATCH] map display option ROMs
Message-Id: <200405121443.06388.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_qppoAD3+BQsXJxA"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--Boundary-00=_qppoAD3+BQsXJxA
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

By default, the sn2 PCI init code doesn't map option ROM address ranges since 
PIO address space is limited.  However, we do need to map display option ROMs 
in the event that userland applications want to read and emulate them.  
Here's a patch to do that.  It applies on top of the last cleanup patch I 
sent you.

Thanks,
Jesse

--Boundary-00=_qppoAD3+BQsXJxA
Content-Type: text/plain;
  charset="us-ascii";
  name="sn-map-vga-rom.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sn-map-vga-rom.patch"

===== arch/ia64/sn/io/machvec/pci_bus_cvlink.c 1.38 vs edited =====
--- 1.38/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Wed Apr 28 09:20:53 2004
+++ edited/arch/ia64/sn/io/machvec/pci_bus_cvlink.c	Wed May 12 11:53:18 2004
@@ -328,6 +328,34 @@
 			cmd |= PCI_COMMAND_MEMORY;
 	}
 
+        /*
+	 * Assign addresses to the ROMs, but don't enable them yet
+	 * Also note that we only map display card ROMs due to PIO mapping
+	 * space scarcity.
+	 */
+        if ((dev->class >> 16) == PCI_BASE_CLASS_DISPLAY) {
+                unsigned long addr;
+                size = dev->resource[PCI_ROM_RESOURCE].end -
+                        dev->resource[PCI_ROM_RESOURCE].start;
+
+                if (size) {
+                        addr = (unsigned long) pciio_pio_addr(vhdl, 0,
+					      PCIIO_SPACE_ROM,
+					      0, size, 0, PIOMAP_FIXED);
+                        if (!addr) {
+                                dev->resource[PCI_ROM_RESOURCE].start = 0;
+                                dev->resource[PCI_ROM_RESOURCE].end = 0;
+                                printk("sn_pci_fixup(): ROM pio map failure "
+				       "for %s\n", dev->slot_name);
+                        }
+                        addr |= __IA64_UNCACHED_OFFSET;
+                        dev->resource[PCI_ROM_RESOURCE].start = addr;
+                        dev->resource[PCI_ROM_RESOURCE].end = addr + size;
+                        if (dev->resource[PCI_ROM_RESOURCE].flags & IORESOURCE_MEM)
+                                cmd |= PCI_COMMAND_MEMORY;
+                }
+        }
+
 	/*
 	 * Update the Command Word on the Card.
 	 */

--Boundary-00=_qppoAD3+BQsXJxA--
