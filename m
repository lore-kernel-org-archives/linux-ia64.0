From: Grant Grundler <iod00d@hp.com>
Date: Fri, 23 Jan 2004 02:43:02 +0000
Subject: [PATCH] 2.6.1 enable PIOW/DMAR relaxed ordering on ZX1
Message-Id: <20040123024302.GD24857@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony, David,
I lied. Apologies. I thought I had sent this patch before
but was just confused by the change in my local bk tree.
I had the patch sitting there since September. :^(

This enables DMA Reads to bypass PIO Writes for all PCI/PCI-X devices.
On older RHAS (2.1 orig), this improved netperf UDP Stream by ~10%.
Testing on kernel.org 2.4 kernels showed only ~3-5% improvement.
I suspect because of improvements to tg3 driver.

diff is against http://lia64.bkbits.net/linux-ia64-2.6/

thanks,
grant


=== arch/ia64/hp/common/sba_iommu.c 1.33 vs edited ==--- 1.33/arch/ia64/hp/common/sba_iommu.c	Fri Sep 19 08:03:40 2003
+++ edited/arch/ia64/hp/common/sba_iommu.c	Thu Jan 22 13:25:17 2004
@@ -156,6 +156,10 @@
 #define IOC_TCNFG	0x318
 #define IOC_PDIR_BASE	0x320
 
+#define IOC_ROPE0_CFG	0x500
+#define   IOC_ROPE_AO	  0x10	/* Allow "Relaxed Ordering" */
+
+
 /* AGP GART driver looks for this */
 #define ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
 
@@ -1421,6 +1425,7 @@
 #ifdef FULL_VALID_PDIR
 	unsigned long index;
 #endif
+	unsigned int i;
 
 	/*
 	** Firmware programs the base and size of a "safe IOVA space"
@@ -1475,6 +1480,18 @@
 	** can't reprogram them the way drivers want.
 	*/
 	WRITE_REG(ioc->imask, ioc->ioc_hpa + IOC_IMASK);
+
+	/* Clear ROPE(N)_CONFIG AO bit.
+	** Disables "NT Ordering" (~= !"Relaxed Ordering")
+	** Overrides bit 1 in DMA Hint Sets.
+	** Improves netperf UDP_STREAM by ~10% for tg3 on bcm5701.
+	*/
+	for (i=0; i<(8*8); i+=8) {
+		unsigned long rope_config;
+		rope_config = READ_REG(ioc->ioc_hpa + IOC_ROPE0_CFG + i);
+		rope_config &= ~IOC_ROPE_AO;
+		WRITE_REG(rope_config, ioc->ioc_hpa + IOC_ROPE0_CFG + i);
+	}
 
 	/*
 	** Setting the upper bits makes checking for bypass addresses
