From: Pat Gefre <pfg@sgi.com>
Date: Wed, 20 Oct 2004 00:37:30 +0000
Subject: [PATCH] 2.6.10 Altix : virtual DMA channel mod
Message-Id: <200410200037.i9K0bUOU145797@fsgi900.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Mod to allow functions other than zero to use virtual channel 1.


Signed-off-by: Patrick Gefre <pfg@sgi.com>
Acked-by: Patrick Gefre <pfg@sgi.com>


-- 

Patrick Gefre
Silicon Graphics, Inc.                     (E-Mail)  pfg@sgi.com
2750 Blue Water Rd                         (Voice)   (651) 683-3127
Eagan, MN 55121-1400                       (FAX)     (651) 683-3054



# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/10/19 19:27:10-05:00 pfg@sgi.com 
#   arch/ia64/sn/pci/pcibr/pcibr_dma.c
#       In PCI mode, we want functions other than zero to use virtual DMA channel
#       one so we don't thrash the read-response buffers
# 
# arch/ia64/sn/pci/pcibr/pcibr_dma.c
#   2004/10/19 19:27:00-05:00 pfg@sgi.com +4 -0
#   In PCI mode, we want functions other than zero to use virtual DMA channel
#   one so we don't thrash the read-response buffers
# 
diff -Nru a/arch/ia64/sn/pci/pcibr/pcibr_dma.c b/arch/ia64/sn/pci/pcibr/pcibr_dma.c
--- a/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2004-10-19 19:27:48 -05:00
+++ b/arch/ia64/sn/pci/pcibr/pcibr_dma.c	2004-10-19 19:27:49 -05:00
@@ -133,6 +133,10 @@
 	} else
 		pci_addr |= TIOCP_PCI64_CMDTYPE_MEM;
 
+	/* If PCI mode, func zero uses VCHAN0, every other func uses VCHAN1 */
+	if (!IS_PCIX(pcibus_info) && PCI_FUNC(info->pdi_linux_pcidev->devfn))
+		pci_addr |= PCI64_ATTR_VIRTUAL;
+
 	return pci_addr;
 
 }
