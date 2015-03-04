From: Yijing Wang <wangyijing@huawei.com>
Date: Wed, 04 Mar 2015 06:16:44 +0000
Subject: [PATCH] ia64/PCI: Fix the build warning of pci_domain_nr()
Message-Id: <1425449804-28887-1-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: bhelgaas@google.com, tony.luck@intel.com
Cc: linux-pci@vger.kernel.org, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, Yijing Wang <wangyijing@huawei.com>, stable@vger.kernel.org

We should pass pci_bus * instead of pci_dev * to pci_domain_nr().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
CC: stable@vger.kernel.org
Signed-off-by: Bjorn Helgaas <bhelgaas@google.com>
---
 arch/ia64/sn/kernel/io_acpi_init.c |    6 +++---
 arch/ia64/sn/kernel/io_init.c      |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_acpi_init.c b/arch/ia64/sn/kernel/io_acpi_init.c
index 0640739..2fd7414 100644
--- a/arch/ia64/sn/kernel/io_acpi_init.c
+++ b/arch/ia64/sn/kernel/io_acpi_init.c
@@ -364,12 +364,12 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
         status = acpi_evaluate_integer(rootbus_handle, METHOD_NAME__SEG, NULL,
                                        &segment);
         if (ACPI_SUCCESS(status)) {
-		if (segment != pci_domain_nr(dev)) {
+		if (segment != pci_domain_nr(dev->bus)) {
 			acpi_get_name(rootbus_handle, ACPI_FULL_PATHNAME,
 				&name_buffer);
 			printk(KERN_ERR
 			       "%s: Segment number mismatch, 0x%llx vs 0x%x for: %s\n",
-			       __func__, segment, pci_domain_nr(dev),
+			       __func__, segment, pci_domain_nr(dev->bus),
 			       (char *)name_buffer.pointer);
 			kfree(name_buffer.pointer);
 			return 1;
@@ -407,7 +407,7 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
 	/* Build up the pcidev_info.pdi_slot_host_handle */
 	host_devfn = get_host_devfn(pcidev_match.handle, rootbus_handle);
 	(*pcidev_info)->pdi_slot_host_handle -			((unsigned long) pci_domain_nr(dev) << 40) |
+			((unsigned long) pci_domain_nr(dev->bus) << 40) |
 					/* bus = 0 */
 					host_devfn;
 	return 0;
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 55776df..19506a5 100644
--- a/arch/ia64/sn/kernel/io_init.c
+++ b/arch/ia64/sn/kernel/io_init.c
@@ -164,7 +164,7 @@ sn_io_slot_fixup(struct pci_dev *dev)
 		panic("%s: Unable to alloc memory for sn_irq_info", __func__);
 
 	/* Call to retrieve pci device information needed by kernel. */
-	status = sal_get_pcidev_info((u64) pci_domain_nr(dev),
+	status = sal_get_pcidev_info((u64) pci_domain_nr(dev->bus),
 		(u64) dev->bus->number,
 		dev->devfn,
 		(u64) __pa(pcidev_info),
-- 
1.7.1

