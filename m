From: Alex Williamson <alex.williamson@hp.com>
Date: Fri, 27 Feb 2004 20:13:36 +0000
Subject: [PATCH] minor 2.6 sba_iommu update
Message-Id: <1077912815.2497.17.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   This is a minor update to sba_iommu initialization code.  I moved the
relaxed ordering to the zx1 specific init routine, those registers don't
do anything on sx1000.  The iommu page size setup is more generalized on
ACPI ID, so the sx1000 specific init routine goes away.  And the virtual
dma_mask on zx1 was tweaked a little to better reflect the memory
address space.  Thanks,

	Alex

-- 
Alex Williamson                             HP Linux & Open Source Lab

=== arch/ia64/hp/common/sba_iommu.c 1.37 vs edited ==--- 1.37/arch/ia64/hp/common/sba_iommu.c	Mon Feb  2 08:58:46 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Fri Feb 27 10:16:24 2004
@@ -1479,7 +1479,6 @@
 #ifdef FULL_VALID_PDIR
 	unsigned long index;
 #endif
-	unsigned int i;
 
 	/*
 	** Firmware programs the base and size of a "safe IOVA space"
@@ -1574,18 +1573,6 @@
 	/* Enable IOVA translation */
 	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
-
-	/* Clear ROPE(N)_CONFIG AO bit.
-	** Disables "NT Ordering" (~= !"Relaxed Ordering")
-	** Overrides bit 1 in DMA Hint Sets.
-	** Improves netperf UDP_STREAM by ~10% for tg3 on bcm5701.
-	*/
-	for (i=0; i<(8*8); i+=8) {
-		unsigned long rope_config;
-		rope_config = READ_REG(ioc->ioc_hpa + IOC_ROPE0_CFG + i);
-		rope_config &= ~IOC_ROPE_AO;
-		WRITE_REG(rope_config, ioc->ioc_hpa + IOC_ROPE0_CFG + i);
-	}
 }
 
 static void __init
@@ -1659,26 +1646,25 @@
 static void __init
 ioc_zx1_init(struct ioc *ioc)
 {
+	unsigned long rope_config;
+	unsigned int i;
+
 	if (ioc->rev < 0x20)
 		panic(PFX "IOC 2.0 or later required for IOMMU support\n");
 
-	ioc->dma_mask = 0xFFFFFFFFFFUL;
+	/* 38 bit memory controller + extra bit for range displaced by MMIO */
+	ioc->dma_mask = (0x1UL << 39) - 1;
 
-	if (!iovp_shift) {
-		/* 64k is max iommu page size */
-		iovp_shift = min(PAGE_SHIFT, 16);
-		iovp_size = (1 << iovp_shift);
-		iovp_mask = ~(iovp_size - 1);
-	}
-}
-
-static void __init
-ioc_sx1000_init(struct ioc *ioc)
-{
-	if (!iovp_shift) {
-		iovp_shift = 12;	/* 4K for now */
-		iovp_size = (1 << iovp_shift);
-		iovp_mask = ~(iovp_size - 1);
+	/*
+	** Clear ROPE(N)_CONFIG AO bit.
+	** Disables "NT Ordering" (~= !"Relaxed Ordering")
+	** Overrides bit 1 in DMA Hint Sets.
+	** Improves netperf UDP_STREAM by ~10% for tg3 on bcm5701.
+	*/
+	for (i=0; i<(8*8); i+=8) {
+		rope_config = READ_REG(ioc->ioc_hpa + IOC_ROPE0_CFG + i);
+		rope_config &= ~IOC_ROPE_AO;
+		WRITE_REG(rope_config, ioc->ioc_hpa + IOC_ROPE0_CFG + i);
 	}
 }
 
@@ -1692,8 +1678,6 @@
 
 static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
-	{ REO_IOC_ID, "REO", ioc_sx1000_init },
-	{ SX1000_IOC_ID, "sx1000", ioc_sx1000_init },
 };
 
 static struct ioc * __init
@@ -1718,11 +1702,6 @@
 	ioc->rev = READ_REG(ioc->ioc_hpa + IOC_FCLASS) & 0xFFUL;
 	ioc->dma_mask = 0xFFFFFFFFFFFFFFFFUL;	/* conservative */
 
-	if (iovp_shift) {
-		iovp_size = (1 << iovp_shift);
-		iovp_mask = ~(iovp_size - 1);
-	}
-
 	for (info = ioc_iommu_info; info < ioc_iommu_info + ARRAY_SIZE(ioc_iommu_info); info++) {
 		if (ioc->func_id = info->func_id) {
 			ioc->name = info->name;
@@ -1730,6 +1709,10 @@
 				(info->init)(ioc);
 		}
 	}
+
+	iovp_size = (1 << iovp_shift);
+	iovp_mask = ~(iovp_size - 1);
+
 	DBG_INIT("%s: PAGE_SIZE %ldK, iovp_size %ldK\n", __FUNCTION__,
 		PAGE_SIZE >> 10, iovp_size >> 10);
 
@@ -1929,9 +1912,20 @@
 	 * For HWP0001, only SBA appears in ACPI namespace.  It encloses the PCI
 	 * root bridges, and its CSR space includes the IOC function.
 	 */
-	if (strncmp("HWP0001", dev_info->hardware_id.value, 7) = 0)
+	if (strncmp("HWP0001", dev_info->hardware_id.value, 7) = 0) {
 		hpa += ZX1_IOC_OFFSET;
+		/* zx1 based systems default to kernel page size iommu pages */
+		if (!iovp_shift)
+			iovp_shift = min(PAGE_SHIFT, 16);
+	}
 	ACPI_MEM_FREE(dev_info);
+
+	/*
+	 * default anything not caught above or specified on cmdline to 4k
+	 * iommu page size
+	 */
+	if (!iovp_shift)
+		iovp_shift = 12;
 
 	ioc = ioc_init(hpa, device->handle);
 	if (!ioc)


