From: Alex Williamson <alex.williamson@hp.com>
Date: Mon, 07 Mar 2005 16:40:04 +0000
Subject: [PATCH] zx2 chipset identifier
Message-Id: <1110213604.7735.28.camel@tdi>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Tony,

   Here's a little patch that adds the chipset identifier for the
upcoming successor to the zx1 chipset.  Please apply.  Thanks,

Alex

-- 
Signed-off-by: Alex Williamson <alex.williamson@hp.com>

=== arch/ia64/hp/common/sba_iommu.c 1.50 vs edited ==--- 1.50/arch/ia64/hp/common/sba_iommu.c	2005-01-11 17:10:37 -07:00
+++ edited/arch/ia64/hp/common/sba_iommu.c	2005-03-04 09:39:31 -07:00
@@ -157,6 +157,7 @@
 #define DELAYED_RESOURCE_CNT	64
 
 #define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
+#define ZX2_IOC_ID	((PCI_DEVICE_ID_HP_ZX2_IOC << 16) | PCI_VENDOR_ID_HP)
 #define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
 #define SX1000_IOC_ID	((PCI_DEVICE_ID_HP_SX1000_IOC << 16) | PCI_VENDOR_ID_HP)
 
@@ -1707,6 +1708,7 @@
 
 static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
+	{ ZX2_IOC_ID, "zx2", NULL },
 	{ SX1000_IOC_ID, "sx1000", NULL },
 };
 
=== include/linux/pci_ids.h 1.201 vs edited ==--- 1.201/include/linux/pci_ids.h	2005-02-11 16:18:13 -07:00
+++ edited/include/linux/pci_ids.h	2005-03-04 09:39:03 -07:00
@@ -696,6 +696,7 @@
 #define PCI_DEVICE_ID_HP_DIVA_EVEREST	0x1282
 #define PCI_DEVICE_ID_HP_DIVA_AUX	0x1290
 #define PCI_DEVICE_ID_HP_CISSA		0x3220
+#define PCI_DEVICE_ID_HP_ZX2_IOC	0x4031
 
 #define PCI_VENDOR_ID_PCTECH		0x1042
 #define PCI_DEVICE_ID_PCTECH_RZ1000	0x1000


