From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Fri, 25 Apr 2003 16:43:04 +0000
Subject: [Linux-ia64] [PATCH] 2.5 new IOC recognition
Message-Id: <marc-linux-ia64-105590723705608@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

This is a trivial patch that makes sba_iommu recognize a new IOC.
Only change is that it will print

    IOC: sx1000 0.1 HPA 0xf8120002000 IOVA space 1024Mb at 0x80000000

instead of

    IOC: Unknown (103c:127c) 0.1 HPA 0xf8120002000 IOVA space 1024Mb at 0x80000000

Bjorn


diff -u -ur linux-2.5.67-ia64-030416-io4/arch/ia64/hp/common/sba_iommu.c linux-2.5.67-ia64-030416-io5/arch/ia64/hp/common/sba_iommu.c
--- linux-2.5.67-ia64-030416-io4/arch/ia64/hp/common/sba_iommu.c	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io5/arch/ia64/hp/common/sba_iommu.c	2003-04-24 16:29:11.000000000 -0600
@@ -134,6 +134,7 @@
 
 #define ZX1_IOC_ID	((PCI_DEVICE_ID_HP_ZX1_IOC << 16) | PCI_VENDOR_ID_HP)
 #define REO_IOC_ID	((PCI_DEVICE_ID_HP_REO_IOC << 16) | PCI_VENDOR_ID_HP)
+#define SX1000_IOC_ID	((PCI_DEVICE_ID_HP_SX1000_IOC << 16) | PCI_VENDOR_ID_HP)
 
 #define ZX1_IOC_OFFSET	0x1000	/* ACPI reports SBA, we want IOC */
 
@@ -1651,6 +1652,7 @@
 static struct ioc_iommu ioc_iommu_info[] __initdata = {
 	{ ZX1_IOC_ID, "zx1", ioc_zx1_init },
 	{ REO_IOC_ID, "REO" },
+	{ SX1000_IOC_ID, "sx1000" },
 };
 
 static struct ioc * __init
diff -u -ur linux-2.5.67-ia64-030416-io4/include/linux/pci_ids.h linux-2.5.67-ia64-030416-io5/include/linux/pci_ids.h
--- linux-2.5.67-ia64-030416-io4/include/linux/pci_ids.h	2003-04-24 10:10:58.000000000 -0600
+++ linux-2.5.67-ia64-030416-io5/include/linux/pci_ids.h	2003-04-24 16:30:23.000000000 -0600
@@ -606,6 +606,7 @@
 #define PCI_DEVICE_ID_HP_ZX1_SBA	0x1229
 #define PCI_DEVICE_ID_HP_ZX1_IOC	0x122a
 #define PCI_DEVICE_ID_HP_ZX1_LBA	0x122e
+#define PCI_DEVICE_ID_HP_SX1000_IOC	0x127c
 #define PCI_DEVICE_ID_HP_DIVA_EVEREST	0x1282
 #define PCI_DEVICE_ID_HP_DIVA_AUX	0x1290
 


