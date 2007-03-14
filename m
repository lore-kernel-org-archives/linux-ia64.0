From: Bernhard Walle <bwalle@suse.de>
Date: Wed, 14 Mar 2007 18:07:47 +0000
Subject: Fix wrong /proc/iomem on SGI Altix
Message-Id: <20070314180746.GA22814@strauss.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

In sn_io_slot_fixup(), the parent is re-set from the bus to
io(port|mem)_resource because the address is changed in a way that it's not
child of the bus any more.

However, only the root is set but not the parent/child/sibling relationship in
the resource tree which causes 'cat /proc/iomem' to stop after this memory
area. Depding on the poition in the tree the iomem may be nearly completely
empty.

Signed-off-by: Bernhard Walle <bwalle@suse.de>

---
 arch/ia64/sn/kernel/io_init.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

Index: b/arch/ia64/sn/kernel/io_init.c
=================================--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -247,10 +247,18 @@ sn_io_slot_fixup(struct pci_dev *dev)
 		addr = ((addr << 4) >> 4) | __IA64_UNCACHED_OFFSET;
 		dev->resource[idx].start = addr;
 		dev->resource[idx].end = addr + size;
+
+		/*
+		 * if it's already in the device structure, remove it before
+		 * inserting
+		 */
+		if (dev->resource[idx].parent && dev->resource[idx].parent->child)
+			release_resource(&dev->resource[idx]);
+
 		if (dev->resource[idx].flags & IORESOURCE_IO)
-			dev->resource[idx].parent = &ioport_resource;
+			insert_resource(&ioport_resource, &dev->resource[idx]);
 		else
-			dev->resource[idx].parent = &iomem_resource;
+			insert_resource(&iomem_resource, &dev->resource[idx]);
 		/* If ROM, mark as shadowed in PROM */
 		if (idx = PCI_ROM_RESOURCE)
 			dev->resource[idx].flags |= IORESOURCE_ROM_BIOS_COPY;
