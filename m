From: Liviu Dudau <Liviu.Dudau@arm.com>
Date: Thu, 13 Nov 2014 18:39:43 +0000
Subject: [PATCH] ia64: Be consistent in the type of the PCI_CONTROLLER() macro argument.
Message-Id: <1415903983-32588-1-git-send-email-Liviu.Dudau@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>, Aaron Lu <aaron.lu@intel.com>, Jiang Liu <jiang.liu@linux.intel.com>, Mika Westerberg <mika.westerberg@linux.intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

PCI_CONTROLLER() macro in include/asm/pci.h expects an argument "busdev"
which implies a 'struct pci_bus *' type of variable (or at least that
is the type of most of the invocations). Correct the cases where the
macro is called with a 'struct pci_dev *' variable as argument.

Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
---
 arch/ia64/hp/common/sba_iommu.c    | 2 +-
 arch/ia64/sn/kernel/io_acpi_init.c | 9 +++++----
 arch/ia64/sn/kernel/io_common.c    | 2 +-
 arch/ia64/sn/kernel/io_init.c      | 2 +-
 4 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
index 344387a..fb5b085 100644
--- a/arch/ia64/hp/common/sba_iommu.c
+++ b/arch/ia64/hp/common/sba_iommu.c
@@ -256,7 +256,7 @@ static u64 prefetch_spill_page;
 
 #ifdef CONFIG_PCI
 # define GET_IOC(dev)	((dev_is_pci(dev))						\
-			 ? ((struct ioc *) PCI_CONTROLLER(to_pci_dev(dev))->iommu) : NULL)
+			 ? ((struct ioc *) PCI_CONTROLLER((to_pci_dev(dev))->bus)->iommu) : NULL)
 #else
 # define GET_IOC(dev)	NULL
 #endif
diff --git a/arch/ia64/sn/kernel/io_acpi_init.c b/arch/ia64/sn/kernel/io_acpi_init.c
index 0640739..426ea8e 100644
--- a/arch/ia64/sn/kernel/io_acpi_init.c
+++ b/arch/ia64/sn/kernel/io_acpi_init.c
@@ -358,18 +358,19 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
 	acpi_handle rootbus_handle;
 	unsigned long long segment;
 	acpi_status status;
+	struct pci_bus *bus = dev->bus;
 	struct acpi_buffer name_buffer = { ACPI_ALLOCATE_BUFFER, NULL };
 
-	rootbus_handle = acpi_device_handle(PCI_CONTROLLER(dev)->companion);
+	rootbus_handle = acpi_device_handle(PCI_CONTROLLER(bus)->companion);
         status = acpi_evaluate_integer(rootbus_handle, METHOD_NAME__SEG, NULL,
                                        &segment);
         if (ACPI_SUCCESS(status)) {
-		if (segment != pci_domain_nr(dev)) {
+		if (segment != pci_domain_nr(bus)) {
 			acpi_get_name(rootbus_handle, ACPI_FULL_PATHNAME,
 				&name_buffer);
 			printk(KERN_ERR
 			       "%s: Segment number mismatch, 0x%llx vs 0x%x for: %s\n",
-			       __func__, segment, pci_domain_nr(dev),
+			       __func__, segment, pci_domain_nr(bus),
 			       (char *)name_buffer.pointer);
 			kfree(name_buffer.pointer);
 			return 1;
@@ -407,7 +408,7 @@ sn_acpi_get_pcidev_info(struct pci_dev *dev, struct pcidev_info **pcidev_info,
 	/* Build up the pcidev_info.pdi_slot_host_handle */
 	host_devfn = get_host_devfn(pcidev_match.handle, rootbus_handle);
 	(*pcidev_info)->pdi_slot_host_handle -			((unsigned long) pci_domain_nr(dev) << 40) |
+			((unsigned long) pci_domain_nr(bus) << 40) |
 					/* bus = 0 */
 					host_devfn;
 	return 0;
diff --git a/arch/ia64/sn/kernel/io_common.c b/arch/ia64/sn/kernel/io_common.c
index 11f2275..e7d5d07 100644
--- a/arch/ia64/sn/kernel/io_common.c
+++ b/arch/ia64/sn/kernel/io_common.c
@@ -108,7 +108,7 @@ sn_pcidev_info_get(struct pci_dev *dev)
 	struct pcidev_info *pcidev;
 
 	list_for_each_entry(pcidev,
-			    &(SN_PLATFORM_DATA(dev)->pcidev_info), pdi_list) {
+			    &(SN_PLATFORM_DATA(dev->bus)->pcidev_info), pdi_list) {
 		if (pcidev->pdi_linux_pcidev = dev)
 			return pcidev;
 	}
diff --git a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
index 0b5ce82..eaff214 100644
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
2.1.3

