From: Pat Gefre <pfg@sgi.com>
Date: Wed, 20 Oct 2004 00:35:34 +0000
Subject: [PATCH] 2.6.10 Altix : export sn_dma_mapping_error for libata
Message-Id: <200410200035.i9K0ZY4u145701@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mod to export sn_dma_mapping_error - needed by libata



Signed-off-by: Patrick Gefre <pfg@sgi.com>
Acked-by: Patrick Gefre <pfg@sgi.com>


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 19:23:42-05:00 pfg@sgi.com 
#   arch/ia64/sn/pci/pci_dma.c
#       Export for drivers/scsi/libata.ko
# 
# arch/ia64/sn/pci/pci_dma.c
#   2004/10/19 19:23:32-05:00 pfg@sgi.com +1 -0
#   Export for drivers/scsi/libata.ko
# 
diff -Nru a/arch/ia64/sn/pci/pci_dma.c b/arch/ia64/sn/pci/pci_dma.c
--- a/arch/ia64/sn/pci/pci_dma.c	2004-10-19 19:25:32 -05:00
+++ b/arch/ia64/sn/pci/pci_dma.c	2004-10-19 19:25:32 -05:00
@@ -474,3 +474,4 @@
 EXPORT_SYMBOL(sn_pci_alloc_consistent);
 EXPORT_SYMBOL(sn_pci_free_consistent);
 EXPORT_SYMBOL(sn_pci_dma_supported);
+EXPORT_SYMBOL(sn_dma_mapping_error);
