From: Mark Maule <maule@sgi.com>
Date: Fri, 05 Aug 2005 21:13:03 +0000
Subject: [PATCH 2.6.13 1/6] altix: cosmetic rename of SGI_PCIBR_ERROR
Message-Id: <20050805211303.5173.73432.32967@attica.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Cosmetic altix patch to rename SGI_PCIBR_ERROR to something more generic and
remove a duplicate #define.

Signed-off-by: Mark Maule <maule@sgi.com>

Index: ce-devel/arch/ia64/sn/pci/pcibr/pcibr_provider.c
=================================--- ce-devel.orig/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-07-18 13:49:11.646487537 -0500
+++ ce-devel/arch/ia64/sn/pci/pcibr/pcibr_provider.c	2005-07-18 14:03:15.776717561 -0500
@@ -115,7 +115,7 @@
 	/*
 	 * register the bridge's error interrupt handler
 	 */
-	if (request_irq(SGI_PCIBR_ERROR, (void *)pcibr_error_intr_handler,
+	if (request_irq(SGI_PCIASIC_ERROR, (void *)pcibr_error_intr_handler,
 			SA_SHIRQ, "PCIBR error", (void *)(soft))) {
 		printk(KERN_WARNING
 		       "pcibr cannot allocate interrupt for error handler\n");
Index: ce-devel/include/asm-ia64/sn/intr.h
=================================--- ce-devel.orig/include/asm-ia64/sn/intr.h	2005-07-18 13:53:29.656740423 -0500
+++ ce-devel/include/asm-ia64/sn/intr.h	2005-07-18 14:03:15.778670490 -0500
@@ -12,13 +12,12 @@
 #include <linux/rcupdate.h>
 
 #define SGI_UART_VECTOR		(0xe9)
-#define SGI_PCIBR_ERROR		(0x33)
 
 /* Reserved IRQs : Note, not to exceed IA64_SN2_FIRST_DEVICE_VECTOR */
 #define SGI_XPC_ACTIVATE                (0x30)
 #define SGI_II_ERROR                    (0x31)
 #define SGI_XBOW_ERROR                  (0x32)
-#define SGI_PCIBR_ERROR                 (0x33)
+#define SGI_PCIASIC_ERROR               (0x33)
 #define SGI_ACPI_SCI_INT                (0x34)
 #define SGI_TIOCA_ERROR                 (0x35)
 #define SGI_TIO_ERROR                   (0x36)
