From: Alex Williamson <alex.williamson@hp.com>
Date: Tue, 31 Aug 2004 22:05:29 +0000
Subject: [PATCH] sba_iommu NUMA locality
Message-Id: <1093989930.4620.43.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This patch adds NUMA locality info to sba_iommu, allowing coherent
DMA mappings to be allocated from the node nearest to the I/O.  This
patch isn't dependent on the previous pxm_to_nid_map fixup, but may be
sub-optimal in some cases without it.  Thanks

Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/hp/common/sba_iommu.c 1.43 vs edited ==--- 1.43/arch/ia64/hp/common/sba_iommu.c	2004-08-03 17:26:10 -06:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2004-08-31 15:56:21 -06:00
@@ -203,6 +203,9 @@
 					/* clearing pdir to prevent races with allocations. */
 	unsigned int	res_bitshift;	/* from the RIGHT! */
 	unsigned int	res_size;	/* size of resource map in bytes */
+#ifdef CONFIG_NUMA
+	unsigned int	node;		/* node where this IOC lives */
+#endif
 #if DELAYED_RESOURCE_CNT > 0
 	spinlock_t	saved_lock;	/* may want to try to get this on a separate cacheline */
 					/* than res_lock for bigger systems. */
@@ -1057,7 +1060,24 @@
 	struct ioc *ioc;
 	void *addr;
 
+	ioc = GET_IOC(dev);
+	ASSERT(ioc);
+
+#ifdef CONFIG_NUMA
+	{
+		struct page *page;
+		page = alloc_pages_node(ioc->node = MAX_NUMNODES ?
+		                        numa_node_id() : ioc->node, flags,
+		                        get_order(size));
+
+		if (unlikely(!page))
+			return NULL;
+
+		addr = page_address(page);
+	}
+#else
 	addr = (void *) __get_free_pages(flags, get_order(size));
+#endif
 	if (unlikely(!addr))
 		return NULL;
 
@@ -1081,8 +1101,6 @@
 	 * If device can't bypass or bypass is disabled, pass the 32bit fake
 	 * device to map single to get an iova mapping.
 	 */
-	ioc = GET_IOC(dev);
-	ASSERT(ioc);
 	*dma_handle = sba_map_single(&ioc->sac_only_dev->dev, addr, size, 0);
 
 	return addr;
@@ -1799,6 +1817,10 @@
 
 	seq_printf(s, "Hewlett Packard %s IOC rev %d.%d\n",
 		ioc->name, ((ioc->rev >> 4) & 0xF), (ioc->rev & 0xF));
+#ifdef CONFIG_NUMA
+	if (ioc->node != MAX_NUMNODES)
+		seq_printf(s, "NUMA node       : %d\n", ioc->node);
+#endif
 	seq_printf(s, "IOVA size       : %ld MB\n", ((ioc->pdir_size >> 3) * iovp_size)/(1024*1024));
 	seq_printf(s, "IOVA page size  : %ld kb\n", iovp_size/1024);
 
@@ -1899,6 +1921,57 @@
 	printk(KERN_WARNING "No IOC for PCI Bus %04x:%02x in ACPI\n", pci_domain_nr(bus), bus->number);
 }
 
+#ifdef CONFIG_NUMA
+static void __init
+sba_map_ioc_to_node(struct ioc *ioc, acpi_handle handle)
+{
+	struct acpi_buffer buffer = {ACPI_ALLOCATE_BUFFER, NULL};
+	union acpi_object *obj;
+	acpi_handle phandle;
+	unsigned int node;
+
+	ioc->node = MAX_NUMNODES;
+
+	/*
+	 * Check for a _PXM on this node first.  We don't typically see
+	 * one here, so we'll end up getting it from the parent.
+	 */
+	if (ACPI_FAILURE(acpi_evaluate_object(handle, "_PXM", NULL, &buffer))) {
+		if (ACPI_FAILURE(acpi_get_parent(handle, &phandle)))
+			return;
+
+		/* Reset the acpi buffer */
+		buffer.length = ACPI_ALLOCATE_BUFFER;
+		buffer.pointer = NULL;
+
+		if (ACPI_FAILURE(acpi_evaluate_object(phandle, "_PXM", NULL,
+		                                      &buffer)))
+			return;
+	}
+
+	if (!buffer.length || !buffer.pointer)
+		return;
+
+	obj = buffer.pointer;
+
+	if (obj->type != ACPI_TYPE_INTEGER) {
+		acpi_os_free(buffer.pointer);
+		return;
+	}
+
+	node = pxm_to_nid_map[obj->integer.value];
+	acpi_os_free(buffer.pointer);
+
+	if (node >= MAX_NUMNODES || !node_online(node))
+		return;
+
+	ioc->node = node;
+	return;
+}
+#else
+#define sba_map_ioc_to_node(ioc, handle)
+#endif
+
 static int __init
 acpi_sba_ioc_add(struct acpi_device *device)
 {
@@ -1941,6 +2014,8 @@
 	if (!ioc)
 		return 1;
 
+	/* setup NUMA node association */
+	sba_map_ioc_to_node(ioc, device->handle);
 	return 0;
 }
 


