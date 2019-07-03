From: Fuqian Huang <huangfq.daxian@gmail.com>
Date: Wed, 03 Jul 2019 13:12:34 +0000
Subject: [PATCH 01/30] ia64/sn: Use kmemdup rather than duplicating its implementation
Message-Id: <20190703131234.24533-1-huangfq.daxian@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 
Cc: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Fuqian Huang <huangfq.daxian@gmail.com>

kmemdup is introduced to duplicate a region of memory in a neat way.
Rather than kmalloc/kzalloc + memset, which the programmer needs to
write the size twice (sometimes lead to mistakes), kmemdup improves
readability, leads to smaller code and also reduce the chances of mistakes.
Suggestion to use kmemdup rather than using kmalloc/kzalloc + memset.

Signed-off-by: Fuqian Huang <huangfq.daxian@gmail.com>
---
 arch/ia64/sn/kernel/io_acpi_init.c | 8 +++-----
 arch/ia64/sn/pci/tioce_provider.c  | 3 +--
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/arch/ia64/sn/kernel/io_acpi_init.c b/arch/ia64/sn/kernel/io_acpi_init.c
index c31fe637b0b4..7f305a468b69 100644
--- a/arch/ia64/sn/kernel/io_acpi_init.c
+++ b/arch/ia64/sn/kernel/io_acpi_init.c
@@ -210,13 +210,11 @@ sn_extract_device_info(acpi_handle handle, struct pcidev_info **pcidev_info,
 		goto exit;
 	}
 
-	pcidev_ptr = kzalloc(sizeof(struct pcidev_info), GFP_KERNEL);
-	if (!pcidev_ptr)
-		panic("%s: Unable to alloc memory for pcidev_info", __func__);
-
 	memcpy(&addr, vendor->byte_data, sizeof(struct pcidev_info *));
 	pcidev_prom_ptr = __va(addr);
-	memcpy(pcidev_ptr, pcidev_prom_ptr, sizeof(struct pcidev_info));
+	pcidev_ptr = kmemdup(pcidev_prom_ptr, sizeof(struct pcidev_info), GFP_KERNEL);
+	if (!pcidev_ptr)
+		panic("%s: Unable to alloc memory for pcidev_info", __func__);
 
 	/* Get the IRQ info */
 	irq_info = kzalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
diff --git a/arch/ia64/sn/pci/tioce_provider.c b/arch/ia64/sn/pci/tioce_provider.c
index 3bd9abc35485..20360a52ab4d 100644
--- a/arch/ia64/sn/pci/tioce_provider.c
+++ b/arch/ia64/sn/pci/tioce_provider.c
@@ -1000,11 +1000,10 @@ tioce_bus_fixup(struct pcibus_bussoft *prom_bussoft, struct pci_controller *cont
 	 * Allocate kernel bus soft and copy from prom.
 	 */
 
-	tioce_common = kzalloc(sizeof(struct tioce_common), GFP_KERNEL);
+	tioce_common = kmemdup(prom_bussoft, sizeof(struct tioce_common), GFP_KERNEL);
 	if (!tioce_common)
 		return NULL;
 
-	memcpy(tioce_common, prom_bussoft, sizeof(struct tioce_common));
 	tioce_common->ce_pcibus.bs_base = (unsigned long)
 		ioremap(REGION_OFFSET(tioce_common->ce_pcibus.bs_base),
 			sizeof(struct tioce_common));
-- 
2.11.0
