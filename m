From: Matthew Wilcox <matthew@wil.cx>
Date: Thu, 28 Oct 2004 19:41:16 +0000
Subject: [PATCH] pci_bus_to_resource
Message-Id: <20041028194116.GA388@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


Since some ia64 platforms have non-identity-mapped PCI busses, we need
to implement pcibios_resource_to_bus and pcibios_bus_to_resource.
Also clean up some >80 column comments and delete an unnecessary parameter
to pcibios_fixup_device_resources().

Index: linux-2.6/arch/ia64/pci/pci.c
=================================RCS file: /var/cvs/linux-2.6/arch/ia64/pci/pci.c,v
retrieving revision 1.16
diff -u -p -r1.16 pci.c
--- linux-2.6/arch/ia64/pci/pci.c	21 Oct 2004 18:58:08 -0000	1.16
+++ linux-2.6/arch/ia64/pci/pci.c	28 Oct 2004 19:33:33 -0000
@@ -328,33 +328,65 @@ out1:
 	return NULL;
 }
 
-void __init
-pcibios_fixup_device_resources (struct pci_dev *dev, struct pci_bus *bus)
+void pcibios_resource_to_bus(struct pci_dev *dev,
+		struct pci_bus_region *region, struct resource *res)
 {
 	struct pci_controller *controller = PCI_CONTROLLER(dev);
-	struct pci_window *window;
-	int i, j;
+	unsigned long offset = 0;
+	int i;
+
+	for (i = 0; i < controller->windows; i++) {
+		struct pci_window *window = &controller->window[i];
+		if (!(window->resource.flags & res->flags))
+			continue;
+		if (window->resource.start > res->start - window->offset)
+			continue;
+		if (window->resource.end < res->end - window->offset)
+			continue;
+		offset = window->offset;
+		break;
+	}
+
+	region->start = res->start - offset;
+	region->end = res->end - offset;
+}
+
+void pcibios_bus_to_resource(struct pci_dev *dev,
+		struct resource *res, struct pci_bus_region *region)
+{
+	struct pci_controller *controller = PCI_CONTROLLER(dev);
+	unsigned long offset = 0;
+	int i;
+
+	for (i = 0; i < controller->windows; i++) {
+		struct pci_window *window = &controller->window[i];
+		if (!(window->resource.flags & res->flags))
+			continue;
+		if (window->resource.start > region->start)
+			continue;
+		if (window->resource.end < region->end)
+			continue;
+		offset = window->offset;
+		break;
+	}
+
+	res->start = region->start + offset;
+	res->end = region->end + offset;
+}
+
+static void __devinit pcibios_fixup_device_resources(struct pci_dev *dev)
+{
+	struct pci_bus_region region;
+	int i;
 	int limit = (dev->hdr_type = PCI_HEADER_TYPE_NORMAL) ? \
 		PCI_BRIDGE_RESOURCES : PCI_NUM_RESOURCES;
 
 	for (i = 0; i < limit; i++) {
-		if (!dev->resource[i].start)
+		if (!dev->resource[i].flags)
 			continue;
-
-#define contains(win, res)	((res)->start >= (win)->start && \
-				 (res)->end   <= (win)->end)
-
-		for (j = 0; j < controller->windows; j++) {
-			window = &controller->window[j];
-			if (((dev->resource[i].flags & IORESOURCE_MEM &&
-			      window->resource.flags & IORESOURCE_MEM) ||
-			     (dev->resource[i].flags & IORESOURCE_IO &&
-			      window->resource.flags & IORESOURCE_IO)) &&
-			    contains(&window->resource, &dev->resource[i])) {
-				dev->resource[i].start += window->offset;
-				dev->resource[i].end   += window->offset;
-			}
-		}
+		region.start = dev->resource[i].start;
+		region.end = dev->resource[i].end;
+		pcibios_bus_to_resource(dev, &dev->resource[i], &region);
 		pci_claim_resource(dev, i);
 	}
 }
@@ -368,7 +400,7 @@ pcibios_fixup_bus (struct pci_bus *b)
 	struct pci_dev *dev;
 
 	list_for_each_entry(dev, &b->devices, bus_list)
-		pcibios_fixup_device_resources(dev, b);
+		pcibios_fixup_device_resources(dev);
 
 	return;
 }
@@ -451,21 +483,21 @@ pci_mmap_page_range (struct pci_dev *dev
 		     enum pci_mmap_state mmap_state, int write_combine)
 {
 	/*
-	 * I/O space cannot be accessed via normal processor loads and stores on this
-	 * platform.
+	 * I/O space cannot be accessed via normal processor loads and
+	 * stores on this platform.
 	 */
 	if (mmap_state = pci_mmap_io)
 		/*
-		 * XXX we could relax this for I/O spaces for which ACPI indicates that
-		 * the space is 1-to-1 mapped.  But at the moment, we don't support
-		 * multiple PCI address spaces and the legacy I/O space is not 1-to-1
-		 * mapped, so this is moot.
+		 * XXX we could relax this for I/O spaces for which ACPI
+		 * indicates that the space is 1-to-1 mapped.  But at the
+		 * moment, we don't support multiple PCI address spaces and
+		 * the legacy I/O space is not 1-to-1 mapped, so this is moot.
 		 */
 		return -EINVAL;
 
 	/*
-	 * Leave vm_pgoff as-is, the PCI space address is the physical address on this
-	 * platform.
+	 * Leave vm_pgoff as-is, the PCI space address is the physical
+	 * address on this platform.
 	 */
 	vma->vm_flags |= (VM_SHM | VM_LOCKED | VM_IO);
 
Index: linux-2.6/include/asm-ia64/pci.h
=================================RCS file: /var/cvs/linux-2.6/include/asm-ia64/pci.h,v
retrieving revision 1.7
diff -u -p -r1.7 pci.h
--- linux-2.6/include/asm-ia64/pci.h	21 Oct 2004 18:59:54 -0000	1.7
+++ linux-2.6/include/asm-ia64/pci.h	28 Oct 2004 19:33:44 -0000
@@ -121,7 +121,12 @@ static inline void pcibios_add_platform_
 {
 }
 
-/* generic pci stuff */
-#include <asm-generic/pci.h>
+extern void pcibios_resource_to_bus(struct pci_dev *dev,
+		struct pci_bus_region *region, struct resource *res);
+
+extern void pcibios_bus_to_resource(struct pci_dev *dev,
+		struct resource *res, struct pci_bus_region *region);
+
+#define pcibios_scan_all_fns(a, b)	0
 
 #endif /* _ASM_IA64_PCI_H */

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
