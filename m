From: Grant Grundler <iod00d@hp.com>
Date: Mon, 26 Jan 2004 18:23:47 +0000
Subject: Re: [PATCH] 2.6.1 enable PIOW/DMAR relaxed ordering on ZX1
Message-Id: <20040126182347.GA15242@cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040123024302.GD24857@cup.hp.com>
In-Reply-To: <20040123024302.GD24857@cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Jan 23, 2004 at 10:06:58PM -0800, David Mosberger wrote:
> I'm not sure Tony's tree is ready for prime-time yet.  Could you
> please diff against my tree instead (linux-ia64-2.5)?

yes - sorry. Patch appended.

> I'd have merged
> the patch by hand, but the context in the patch you posted doesn't
> look like anything that appears in the current sba_iommu.c.

hrm...they shouldn't be that different.
OIC.  Some of the DMA hint register support was removed.
If you want to finish that job, remove the definition and references
to hint_mask_pdir and hint_shift_pdir. I'll maintain DMA hints
as a seperate patch (2.4 only so far) until I have data it's useful.

thanks,
grant


=== arch/ia64/hp/common/sba_iommu.c 1.35 vs edited ==--- 1.35/arch/ia64/hp/common/sba_iommu.c	Mon Jan 12 08:02:23 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Jan 26 08:47:02 2004
@@ -158,6 +158,10 @@
 #define IOC_TCNFG	0x318
 #define IOC_PDIR_BASE	0x320
 
+#define IOC_ROPE0_CFG	0x500
+#define   IOC_ROPE_AO	  0x10	/* Allow "Relaxed Ordering" */
+
+
 /* AGP GART driver looks for this */
 #define ZX1_SBA_IOMMU_COOKIE	0x0000badbadc0ffeeUL
 
@@ -1361,6 +1365,7 @@
 #ifdef FULL_VALID_PDIR
 	unsigned long index;
 #endif
+	unsigned int i;
 
 	/*
 	** Firmware programs the base and size of a "safe IOVA space"
@@ -1455,6 +1460,18 @@
 	/* Enable IOVA translation */
 	WRITE_REG(ioc->ibase | 1, ioc->ioc_hpa + IOC_IBASE);
 	READ_REG(ioc->ioc_hpa + IOC_IBASE);
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
 }
 
 static void __init
