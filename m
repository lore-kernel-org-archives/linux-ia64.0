From: "Pat O'Rourke" <orourke@mclinux.com>
Date: Fri, 18 Aug 2000 18:32:46 +0000
Subject: [Linux-ia64] [PATCH] unresolved symbols w/ CONFIG_SWIOTLB turned off
Message-Id: <marc-linux-ia64-105590678205357@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

While debugging a problem booting test6 on a lion, I turned off
CONFIG_SWIOTLB and received a bunch of unresolved symbols.  It
seems that the definitions for several pci_* functions were 
incorporated from pci.h into ia64/kernel/pci-dma.c, but were
left as externs.

Pat

-- 
Patrick O'Rourke
orourke@missioncriticallinux.com

--- linux-2.4.0-test6-ia64/arch/ia64/kernel/pci-dma.c	Thu Aug 17 09:33:38 2000
+++ sbox/ia64/linux-2.4.0-test6/arch/ia64/kernel/pci-dma.c	Fri Aug 18 14:21:40 
2000
@@ -394,7 +394,7 @@
  * Once the device is given the dma address, the device owns this memory
  * until either pci_unmap_single or pci_dma_sync_single is performed.
  */
-extern inline dma_addr_t
+dma_addr_t
 pci_map_single (struct pci_dev *hwdev, void *ptr, size_t size, int direction)
 {
         if (direction = PCI_DMA_NONE)
@@ -410,7 +410,7 @@
  * After this call, reads by the cpu to the buffer are guarenteed to see
  * whatever the device wrote there.
  */
-extern inline void
+void
 pci_unmap_single (struct pci_dev *hwdev, dma_addr_t dma_addr, size_t size, 
int direction)
 {
         if (direction = PCI_DMA_NONE)
@@ -433,7 +433,7 @@
  * Device ownership issues as mentioned above for pci_map_single are
  * the same here.
  */
-extern inline int
+int
 pci_map_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, int 
direction)
 {
         if (direction = PCI_DMA_NONE)
@@ -446,7 +446,7 @@
  * Again, cpu read rules concerning calls here are the same as for
  * pci_unmap_single() above.
  */
-extern inline void
+void
 pci_unmap_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nents, int 
direction)
 {
         if (direction = PCI_DMA_NONE)
@@ -463,7 +463,7 @@
  * next point you give the PCI dma address back to the card, the
  * device again owns the buffer.
  */
-extern inline void
+void
 pci_dma_sync_single (struct pci_dev *hwdev, dma_addr_t dma_handle, size_t 
size, int direction)
 {
         if (direction = PCI_DMA_NONE)
@@ -478,7 +478,7 @@
  * The same as pci_dma_sync_single but for a scatter-gather list,
  * same rules and usage.
  */
-extern inline void
+void
 pci_dma_sync_sg (struct pci_dev *hwdev, struct scatterlist *sg, int nelems, 
int direction)
 {
         if (direction = PCI_DMA_NONE)



