From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Date: Tue, 03 May 2005 19:07:09 +0000
Subject: [PATCH] ia64: Recognize HP sx2000 chipset
Message-Id: <200505031307.09144.bjorn.helgaas@hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

No functional change, just identify the device nicely:

  -IOC: Unknown (103c:12ec) 0.1 HPA 0xf8020002000 IOVA space 1024Mb at 0x40000000
  +IOC: sx2000 0.1 HPA 0xf8020002000 IOVA space 1024Mb at 0x40000000

We used to create fake PCI devices for these chips, but we no longer do that.
So I don't think there's any reason to touch pci_ids.h now.

Signed-off-by: Bjorn Helgaas <bjorn.helgaas@hp.com>

Index: arch/ia64/hp/common/sba_iommu.c
=================================--- 59c7aae8cab7c4e1e557dd3a4fff6afbffab38e2/arch/ia64/hp/common/sba_iommu.c  (mode:100644 sha1:6a8fcba7a853177996bfcf18213a84fbd3dee9e4)
+++ uncommitted/arch/ia64/hp/common/sba_iommu.c  (mode:100644)
@@ -156,10 +156,13 @@
 */
 #define DELAYED_RESOURCE_CNT	64
 
+#define PCI_DEVICE_ID_HP_SX2000_IOC	0x12ec
+
 #define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
 #define ZX2_IOC_ID	((PCI_DEVICE_ID_HP_ZX2_IOC << 16) | PCI_VENDOR_ID_HP)
 #define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
 #define SX1000_IOC_ID	((PCI_DEVICE_ID_HP_SX1000_IOC << 16) | PCI_VENDOR_ID_HP)
+#define SX2000_IOC_ID	((PCI_DEVICE_ID_HP_SX2000_IOC << 16) | PCI_VENDOR_ID_HP)
 
 #define ZX1_IOC_OFFSET	0x1000	/* ACPI reports SBA, we want IOC */
 
@@ -1726,6 +1729,7 @@
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
 	{ ZX2_IOC_ID, "zx2", NULL },
 	{ SX1000_IOC_ID, "sx1000", NULL },
+	{ SX2000_IOC_ID, "sx2000", NULL },
 };
 
 static struct ioc * __init
