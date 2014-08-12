From: Yijing Wang <wangyijing@huawei.com>
Date: Tue, 12 Aug 2014 07:26:01 +0000
Subject: [RFC PATCH 08/20] x86/xen/MSI: Use msi_chip instead of arch func to configure MSI/MSI-X
Message-Id: <1407828373-24322-9-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1407828373-24322-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-kernel@vger.kernel.org, Xinwei Hu <huxinwei@huawei.com>, Wuyun <wuyun.wu@huawei.com>, linux-pci@vger.kernel.org, Marc Zyngier <marc.zyngier@arm.com>, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, arnab.basu@freescale.com, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, xen-devel@lists.xenproject.org, Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Sebastian Ott <sebott@linux.vnet.ibm.com>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, sparclinux@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Yijing Wang <wangyijing@huawei.com>

Introduce a new struct msi_chip xen_msi_chip instead of weak arch
functions to configure MSI/MSI-X.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 arch/x86/pci/xen.c |  128 +++++++++++++++++++++++++++++----------------------
 1 files changed, 73 insertions(+), 55 deletions(-)

diff --git a/arch/x86/pci/xen.c b/arch/x86/pci/xen.c
index 55c7858..0c4ed47 100644
--- a/arch/x86/pci/xen.c
+++ b/arch/x86/pci/xen.c
@@ -156,11 +156,12 @@ static int acpi_register_gsi_xen(struct device *dev, u32 gsi,
 struct xen_pci_frontend_ops *xen_pci_frontend;
 EXPORT_SYMBOL_GPL(xen_pci_frontend);
 
-static int xen_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int xen_setup_msi_irqs(struct device *dev, int nvec, int type)
 {
 	int irq, ret, i;
 	struct msi_desc *msidesc;
 	int *v;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (type = PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
@@ -170,14 +171,14 @@ static int xen_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 		return -ENOMEM;
 
 	if (type = PCI_CAP_ID_MSIX)
-		ret = xen_pci_frontend_enable_msix(dev, v, nvec);
+		ret = xen_pci_frontend_enable_msix(pdev, v, nvec);
 	else
-		ret = xen_pci_frontend_enable_msi(dev, v);
+		ret = xen_pci_frontend_enable_msi(pdev, v);
 	if (ret)
 		goto error;
 	i = 0;
-	list_for_each_entry(msidesc, &dev->msi_list, list) {
-		irq = xen_bind_pirq_msi_to_irq(dev, msidesc, v[i],
+	list_for_each_entry(msidesc, &pdev->msi_list, list) {
+		irq = xen_bind_pirq_msi_to_irq(pdev, msidesc, v[i],
 					       (type = PCI_CAP_ID_MSI) ? nvec : 1,
 					       (type = PCI_CAP_ID_MSIX) ?
 					       "pcifront-msi-x" :
@@ -193,7 +194,7 @@ static int xen_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 	return 0;
 
 error:
-	dev_err(&dev->dev, "Xen PCI frontend has not registered MSI/MSI-X support!\n");
+	dev_err(dev, "Xen PCI frontend has not registered MSI/MSI-X support!\n");
 free:
 	kfree(v);
 	return ret;
@@ -218,47 +219,48 @@ static void xen_msi_compose_msg(struct pci_dev *pdev, unsigned int pirq,
 	msg->data = XEN_PIRQ_MSI_DATA;
 }
 
-static int xen_hvm_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int xen_hvm_setup_msi_irqs(struct device *dev, int nvec, int type)
 {
 	int irq, pirq;
 	struct msi_desc *msidesc;
 	struct msi_msg msg;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (type = PCI_CAP_ID_MSI && nvec > 1)
 		return 1;
 
-	list_for_each_entry(msidesc, &dev->msi_list, list) {
+	list_for_each_entry(msidesc, &pdev->msi_list, list) {
 		__read_msi_msg(msidesc, &msg);
 		pirq = MSI_ADDR_EXT_DEST_ID(msg.address_hi) |
 			((msg.address_lo >> MSI_ADDR_DEST_ID_SHIFT) & 0xff);
 		if (msg.data != XEN_PIRQ_MSI_DATA ||
 		    xen_irq_from_pirq(pirq) < 0) {
-			pirq = xen_allocate_pirq_msi(dev, msidesc);
+			pirq = xen_allocate_pirq_msi(pdev, msidesc);
 			if (pirq < 0) {
 				irq = -ENODEV;
 				goto error;
 			}
-			xen_msi_compose_msg(dev, pirq, &msg);
+			xen_msi_compose_msg(pdev, pirq, &msg);
 			__write_msi_msg(msidesc, &msg);
-			dev_dbg(&dev->dev, "xen: msi bound to pirq=%d\n", pirq);
+			dev_dbg(dev, "xen: msi bound to pirq=%d\n", pirq);
 		} else {
-			dev_dbg(&dev->dev,
+			dev_dbg(dev,
 				"xen: msi already bound to pirq=%d\n", pirq);
 		}
-		irq = xen_bind_pirq_msi_to_irq(dev, msidesc, pirq,
+		irq = xen_bind_pirq_msi_to_irq(pdev, msidesc, pirq,
 					       (type = PCI_CAP_ID_MSI) ? nvec : 1,
 					       (type = PCI_CAP_ID_MSIX) ?
 					       "msi-x" : "msi",
 					       DOMID_SELF);
 		if (irq < 0)
 			goto error;
-		dev_dbg(&dev->dev,
+		dev_dbg(dev,
 			"xen: msi --> pirq=%d --> irq=%d\n", pirq, irq);
 	}
 	return 0;
 
 error:
-	dev_err(&dev->dev,
+	dev_err(dev,
 		"Xen PCI frontend has not registered MSI/MSI-X support!\n");
 	return irq;
 }
@@ -266,16 +268,17 @@ error:
 #ifdef CONFIG_XEN_DOM0
 static bool __read_mostly pci_seg_supported = true;
 
-static int xen_initdom_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
+static int xen_initdom_setup_msi_irqs(struct device *dev, int nvec, int type)
 {
 	int ret = 0;
 	struct msi_desc *msidesc;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
-	list_for_each_entry(msidesc, &dev->msi_list, list) {
+	list_for_each_entry(msidesc, &pdev->msi_list, list) {
 		struct physdev_map_pirq map_irq;
 		domid_t domid;
 
-		domid = ret = xen_find_device_domain_owner(dev);
+		domid = ret = xen_find_device_domain_owner(pdev);
 		/* N.B. Casting int's -ENODEV to uint16_t results in 0xFFED,
 		 * hence check ret value for < 0. */
 		if (ret < 0)
@@ -286,9 +289,9 @@ static int xen_initdom_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 		map_irq.type = MAP_PIRQ_TYPE_MSI_SEG;
 		map_irq.index = -1;
 		map_irq.pirq = -1;
-		map_irq.bus = dev->bus->number |
-			      (pci_domain_nr(dev->bus) << 16);
-		map_irq.devfn = dev->devfn;
+		map_irq.bus = pdev->bus->number |
+			      (pci_domain_nr(pdev->bus) << 16);
+		map_irq.devfn = pdev->devfn;
 
 		if (type = PCI_CAP_ID_MSI && nvec > 1) {
 			map_irq.type = MAP_PIRQ_TYPE_MULTI_MSI;
@@ -297,12 +300,12 @@ static int xen_initdom_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 			int pos;
 			u32 table_offset, bir;
 
-			pos = dev->msix_cap;
-			pci_read_config_dword(dev, pos + PCI_MSIX_TABLE,
+			pos = pdev->msix_cap;
+			pci_read_config_dword(pdev, pos + PCI_MSIX_TABLE,
 					      &table_offset);
 			bir = (u8)(table_offset & PCI_MSIX_TABLE_BIR);
 
-			map_irq.table_base = pci_resource_start(dev, bir);
+			map_irq.table_base = pci_resource_start(pdev, bir);
 			map_irq.entry_nr = msidesc->msi_attrib.entry_nr;
 		}
 
@@ -320,23 +323,23 @@ static int xen_initdom_setup_msi_irqs(struct pci_dev *dev, int nvec, int type)
 			ret = 1;
 			goto out;
 		}
-		if (ret = -EINVAL && !pci_domain_nr(dev->bus)) {
+		if (ret = -EINVAL && !pci_domain_nr(pdev->bus)) {
 			map_irq.type = MAP_PIRQ_TYPE_MSI;
 			map_irq.index = -1;
 			map_irq.pirq = -1;
-			map_irq.bus = dev->bus->number;
+			map_irq.bus = pdev->bus->number;
 			ret = HYPERVISOR_physdev_op(PHYSDEVOP_map_pirq,
 						    &map_irq);
 			if (ret != -EINVAL)
 				pci_seg_supported = false;
 		}
 		if (ret) {
-			dev_warn(&dev->dev, "xen map irq failed %d for %d domain\n",
+			dev_warn(dev, "xen map irq failed %d for %d domain\n",
 				 ret, domid);
 			goto out;
 		}
 
-		ret = xen_bind_pirq_msi_to_irq(dev, msidesc, map_irq.pirq,
+		ret = xen_bind_pirq_msi_to_irq(pdev, msidesc, map_irq.pirq,
 		                               (type = PCI_CAP_ID_MSI) ? nvec : 1,
 		                               (type = PCI_CAP_ID_MSIX) ? "msi-x" : "msi",
 		                               domid);
@@ -348,16 +351,17 @@ out:
 	return ret;
 }
 
-static void xen_initdom_restore_msi_irqs(struct pci_dev *dev)
+static void xen_initdom_restore_msi_irqs(struct device *dev)
 {
 	int ret = 0;
+	struct pci_dev *pdev = to_pci_dev(dev);
 
 	if (pci_seg_supported) {
 		struct physdev_pci_device restore_ext;
 
-		restore_ext.seg = pci_domain_nr(dev->bus);
-		restore_ext.bus = dev->bus->number;
-		restore_ext.devfn = dev->devfn;
+		restore_ext.seg = pci_domain_nr(pdev->bus);
+		restore_ext.bus = pdev->bus->number;
+		restore_ext.devfn = pdev->devfn;
 		ret = HYPERVISOR_physdev_op(PHYSDEVOP_restore_msi_ext,
 					&restore_ext);
 		if (ret = -ENOSYS)
@@ -367,33 +371,45 @@ static void xen_initdom_restore_msi_irqs(struct pci_dev *dev)
 	if (!pci_seg_supported) {
 		struct physdev_restore_msi restore;
 
-		restore.bus = dev->bus->number;
-		restore.devfn = dev->devfn;
+		restore.bus = pdev->bus->number;
+		restore.devfn = pdev->devfn;
 		ret = HYPERVISOR_physdev_op(PHYSDEVOP_restore_msi, &restore);
 		WARN(ret && ret != -ENOSYS, "restore_msi -> %d\n", ret);
 	}
 }
 #endif
 
-static void xen_teardown_msi_irqs(struct pci_dev *dev)
+static void xen_teardown_msi_irq(unsigned int irq)
 {
-	struct msi_desc *msidesc;
-
-	msidesc = list_entry(dev->msi_list.next, struct msi_desc, list);
-	if (msidesc->msi_attrib.is_msix)
-		xen_pci_frontend_disable_msix(dev);
-	else
-		xen_pci_frontend_disable_msi(dev);
-
-	/* Free the IRQ's and the msidesc using the generic code. */
-	default_teardown_msi_irqs(dev);
+	xen_destroy_irq(irq);
 }
 
-static void xen_teardown_msi_irq(unsigned int irq)
+static void xen_teardown_msi_irqs(struct device *dev)
 {
-	xen_destroy_irq(irq);
+	struct msi_desc *entry;
+	struct pci_dev *pdev = to_pci_dev(dev);
+
+	entry = list_entry(pdev->msi_list.next, struct msi_desc, list);
+	if (entry->msi_attrib.is_msix)
+		xen_pci_frontend_disable_msix(pdev);
+	else
+		xen_pci_frontend_disable_msi(pdev);
+
+	list_for_each_entry(entry, &pdev->msi_list, list) {
+		int i, nvec;
+		if (entry->irq = 0)
+			continue;
+		if (entry->nvec_used)
+			nvec = entry->nvec_used;
+		else
+			nvec = 1 << entry->msi_attrib.multiple;
+		for (i = 0; i < nvec; i++)
+			xen_teardown_msi_irq(entry->irq + i);
+	}
 }
 
+struct msi_chip xen_msi_chip;
+
 #endif
 
 int __init pci_xen_init(void)
@@ -414,9 +430,9 @@ int __init pci_xen_init(void)
 #endif
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
-	x86_msi.teardown_msi_irqs = xen_teardown_msi_irqs;
+	xen_msi_chip.setup_irqs = xen_setup_msi_irqs;
+	xen_msi_chip.teardown_irqs = xen_teardown_msi_irqs;
+	x86_msi_chip = &xen_msi_chip;
 #endif
 	return 0;
 }
@@ -435,8 +451,9 @@ int __init pci_xen_hvm_init(void)
 #endif
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_hvm_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
+	xen_msi_chip.setup_irqs = xen_hvm_setup_msi_irqs;
+	xen_msi_chip.teardown_irq = xen_teardown_msi_irq;
+	x86_msi_chip = &xen_msi_chip;
 #endif
 	return 0;
 }
@@ -493,9 +510,10 @@ int __init pci_xen_initial_domain(void)
 	int irq;
 
 #ifdef CONFIG_PCI_MSI
-	x86_msi.setup_msi_irqs = xen_initdom_setup_msi_irqs;
-	x86_msi.teardown_msi_irq = xen_teardown_msi_irq;
-	x86_msi.restore_msi_irqs = xen_initdom_restore_msi_irqs;
+	xen_msi_chip.setup_irqs = xen_initdom_setup_msi_irqs;
+	xen_msi_chip.teardown_irq = xen_teardown_msi_irq;
+	xen_msi_chip.restore_irqs = xen_initdom_restore_msi_irqs;
+	x86_msi_chip = &xen_msi_chip;
 #endif
 	xen_setup_acpi_sci();
 	__acpi_register_gsi = acpi_register_gsi_xen;
-- 
1.7.1

