From: Pat Gefre <pfg@sgi.com>
Date: Tue, 26 Oct 2004 16:00:51 +0000
Subject: [PATCH] 2.6.10 Altix : only allocate irq if the device can interrupt
Message-Id: <200410261600.i9QG0pDr100827@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org



Altix patch for 2.6.10.

Signed-off-by: Patrick Gefre <pfg@sgi.com>
Acked-by: Mike Habeck <habeck@sgi.com>




# This is a BitKeeper generated diff -Nru style patch.
#
# arch/ia64/sn/kernel/io_init.c
#   Only reserve an irq if the device pulls an interrupt 
#   line (i.e. sn_irq_info->irq_irq is set).  Also clear 
#   the pcidev_info and sn_irq_info structs after alloc.
# 
diff -Nru a/arch/ia64/sn/kernel/io_init.c b/arch/ia64/sn/kernel/io_init.c
--- a/arch/ia64/sn/kernel/io_init.c	2004-10-26 10:47:30 -05:00
+++ b/arch/ia64/sn/kernel/io_init.c	2004-10-26 10:47:30 -05:00
@@ -204,10 +204,12 @@
 	SN_PCIDEV_INFO(dev) = kmalloc(sizeof(struct pcidev_info), GFP_KERNEL);
 	if (SN_PCIDEV_INFO(dev) <= 0)
 		BUG();		/* Cannot afford to run out of memory */
+	memset(SN_PCIDEV_INFO(dev), 0, sizeof(struct pcidev_info));
 
 	sn_irq_info = kmalloc(sizeof(struct sn_irq_info), GFP_KERNEL);
 	if (sn_irq_info <= 0)
 		BUG();		/* Cannot afford to run out of memory */
+	memset(sn_irq_info, 0, sizeof(struct sn_irq_info));
 
 	/* Call to retrieve pci device information needed by kernel. */
 	status = sal_get_pcidev_info((u64) segment, (u64) dev->bus->number, 
@@ -248,7 +250,7 @@
 	SN_PCIDEV_INFO(dev)->pdi_pcibus_info = SN_PCIBUS_BUSSOFT(dev->bus);
 
 	/* Only set up IRQ stuff if this device has a host bus context */
-	if (SN_PCIDEV_BUSSOFT(dev)) {
+	if (SN_PCIDEV_BUSSOFT(dev) && sn_irq_info->irq_irq) {
 		SN_PCIDEV_INFO(dev)->pdi_sn_irq_info = sn_irq_info;
 		dev->irq = SN_PCIDEV_INFO(dev)->pdi_sn_irq_info->irq_irq;
 		sn_irq_fixup(dev, sn_irq_info);
