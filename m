From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 22 Mar 2004 18:49:37 +0000
Subject: [PATCH] lost sx1000 naming in sba_iommu
Message-Id: <1079981377.2121.53.camel@patsy.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


   Mainly cosmetic, but Bjorn noticed I got a little over zealous in
cleaning out the sx1000 specific init routines in sba_iommu.  This adds
back in the ID->name mapping so it doesn't show up as "Unknown".  Patch
against latest 2.6.

	Alex

--- 1.39/arch/ia64/hp/common/sba_iommu.c	Mon Mar 15 07:51:33 2004
+++ edited/arch/ia64/hp/common/sba_iommu.c	Mon Mar 22 10:52:38 2004
@@ -1678,6 +1678,7 @@
 
 static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
+	{ SX1000_IOC_ID, "sx1000", NULL },
 };
 
 static struct ioc * __init


