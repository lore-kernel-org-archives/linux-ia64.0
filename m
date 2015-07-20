From: Yijing Wang <wangyijing@huawei.com>
Date: Mon, 20 Jul 2015 12:01:18 +0000
Subject: [PATCH part3 v12 10/10] IA64/PCI: Fix build warning found by kbuild test
Message-Id: <1437393678-4077-11-git-send-email-wangyijing@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
In-Reply-To: <1437393678-4077-1-git-send-email-wangyijing@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bjorn Helgaas <bhelgaas@google.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Russell King <linux@arm.linux.org.uk>, dja@axtens.net, linux-xtensa@linux-xtensa.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, linux-mips@linux-mips.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rusty Russell <rusty@rustcorp.com.au>, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@mprc.pku.edu.cn>, linux-alpha@vger.kernel.org, linux-m68k@vger.kernel.org, linux-am33-list@redhat.com, Liviu Dudau <liviu@dudau.co.uk>, Arnd Bergmann <arnd@arndb.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Yijing Wang <wangyijing@huawei.com>

Kbuild test robot found we passed a pci_dev * to
pci_domain_nr(). In old IA64 specific pci_domain_nr()
It was macro defines:

#define PCI_CONTROLLER(busdev) ((struct pci_controller *) busdev->sysdata)
#define pci_domain_nr(busdev)    (PCI_CONTROLLER(busdev)->segment)

Both pci_dev * and pci_bus * have opaque sysdata, so IA64 specific
pci_domain_nr() could get the pci_controller and return the exact
domain number, but now we use common pci_domain_nr() functions, so we
should fix this warning.

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
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
index d528814..0bdab82 100644
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

