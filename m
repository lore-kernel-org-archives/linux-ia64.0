From: Albert Herranz <albert_herranz@yahoo.es>
Date: Fri, 12 Mar 2010 19:12:39 +0000
Subject: [PATCH v4 04/11] swiotlb: support NOT_COHERENT_CACHE PowerPC platforms
Message-Id: <1268421166-4791-5-git-send-email-albert_herranz@yahoo.es>
List-Id: <linux-ia64.vger.kernel.org>
References: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
In-Reply-To: <1268421166-4791-1-git-send-email-albert_herranz@yahoo.es>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-usb@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: Albert Herranz <albert_herranz@yahoo.es>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org

The current SWIOTLB code does not support NOT_COHERENT_CACHE platforms.
This patch adds support for NOT_COHERENT_CACHE platforms to SWIOTLB by
adding two platform specific functions swiotlb_dma_sync_page() and
swiotlb_dma_sync() which can be used to explicitly manage cache coherency.

On PowerPC these functions are mapped to their corresponding
__dma_sync_page() and __dma_sync() functions.
On other architectures using SWIOTLB these functions are optimized out.

This will be used later to support SWIOTLB on the Nintendo Wii video game
console.

CC: linuxppc-dev@lists.ozlabs.org
CC: linux-kernel@vger.kernel.org
CC: x86@kernel.org
CC: linux-ia64@vger.kernel.org
Signed-off-by: Albert Herranz <albert_herranz@yahoo.es>
---
 arch/ia64/include/asm/swiotlb.h    |   10 ++++++++++
 arch/powerpc/include/asm/swiotlb.h |    3 +++
 arch/x86/include/asm/swiotlb.h     |   10 ++++++++++
 lib/swiotlb.c                      |   30 ++++++++++++++++++++++++------
 4 files changed, 47 insertions(+), 6 deletions(-)

diff --git a/arch/ia64/include/asm/swiotlb.h b/arch/ia64/include/asm/swiotlb.h
index f0acde6..6722090 100644
--- a/arch/ia64/include/asm/swiotlb.h
+++ b/arch/ia64/include/asm/swiotlb.h
@@ -14,4 +14,14 @@ static inline void pci_swiotlb_init(void)
 }
 #endif
 
+static inline void swiotlb_dma_sync_page(struct page *page,
+					 unsigned long offset,
+					 size_t size, int direction)
+{
+}
+
+static inline void swiotlb_dma_sync(void *vaddr, size_t size, int direction)
+{
+}
+
 #endif /* ASM_IA64__SWIOTLB_H */
diff --git a/arch/powerpc/include/asm/swiotlb.h b/arch/powerpc/include/asm/swiotlb.h
index 8979d4c..603b343 100644
--- a/arch/powerpc/include/asm/swiotlb.h
+++ b/arch/powerpc/include/asm/swiotlb.h
@@ -22,4 +22,7 @@ int __init swiotlb_setup_bus_notifier(void);
 
 extern void pci_dma_dev_setup_swiotlb(struct pci_dev *pdev);
 
+#define swiotlb_dma_sync_page __dma_sync_page
+#define swiotlb_dma_sync __dma_sync
+
 #endif /* __ASM_SWIOTLB_H */
diff --git a/arch/x86/include/asm/swiotlb.h b/arch/x86/include/asm/swiotlb.h
index 8085277..e5f6d9c 100644
--- a/arch/x86/include/asm/swiotlb.h
+++ b/arch/x86/include/asm/swiotlb.h
@@ -20,4 +20,14 @@ static inline void pci_swiotlb_init(void)
 
 static inline void dma_mark_clean(void *addr, size_t size) {}
 
+static inline void swiotlb_dma_sync_page(struct page *page,
+					 unsigned long offset,
+					 size_t size, int direction)
+{
+}
+
+static inline void swiotlb_dma_sync(void *vaddr, size_t size, int direction)
+{
+}
+
 #endif /* _ASM_X86_SWIOTLB_H */
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 94db5df..8f2dad9 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -346,10 +346,13 @@ static void swiotlb_bounce(phys_addr_t phys, char *dma_addr, size_t size,
 			local_irq_save(flags);
 			buffer = kmap_atomic(pfn_to_page(pfn),
 					     KM_BOUNCE_READ);
-			if (dir = DMA_TO_DEVICE)
+			if (dir = DMA_TO_DEVICE) {
 				memcpy(dma_addr, buffer + offset, sz);
-			else
+				swiotlb_dma_sync(dma_addr, sz, dir);
+			} else {
+				swiotlb_dma_sync(dma_addr, sz, dir);
 				memcpy(buffer + offset, dma_addr, sz);
+			}
 			kunmap_atomic(buffer, KM_BOUNCE_READ);
 			local_irq_restore(flags);
 
@@ -359,10 +362,14 @@ static void swiotlb_bounce(phys_addr_t phys, char *dma_addr, size_t size,
 			offset = 0;
 		}
 	} else {
-		if (dir = DMA_TO_DEVICE)
+		if (dir = DMA_TO_DEVICE) {
 			memcpy(dma_addr, phys_to_virt(phys), size);
-		else
+			swiotlb_dma_sync(dma_addr, size, dir);
+
+		} else {
+			swiotlb_dma_sync(dma_addr, size, dir);
 			memcpy(phys_to_virt(phys), dma_addr, size);
+		}
 	}
 }
 
@@ -542,6 +549,8 @@ sync_single(struct device *hwdev, char *dma_addr, size_t size,
 	}
 }
 
+#ifndef CONFIG_NOT_COHERENT_CACHE
+
 void *
 swiotlb_alloc_coherent(struct device *hwdev, size_t size,
 		       dma_addr_t *dma_handle, gfp_t flags)
@@ -606,6 +615,8 @@ swiotlb_free_coherent(struct device *hwdev, size_t size, void *vaddr,
 }
 EXPORT_SYMBOL(swiotlb_free_coherent);
 
+#endif /* !CONFIG_NOT_COHERENT_CACHE */
+
 static void
 swiotlb_full(struct device *dev, size_t size, int dir, int do_panic)
 {
@@ -652,8 +663,10 @@ dma_addr_t swiotlb_map_page(struct device *dev, struct page *page,
 	 * we can safely return the device addr and not worry about bounce
 	 * buffering it.
 	 */
-	if (dma_capable(dev, dev_addr, size) && !swiotlb_force)
+	if (dma_capable(dev, dev_addr, size) && !swiotlb_force) {
+		swiotlb_dma_sync_page(page, offset, size, dir);
 		return dev_addr;
+	}
 
 	/*
 	 * Oh well, have to allocate and map a bounce buffer.
@@ -739,6 +752,8 @@ swiotlb_sync_single(struct device *hwdev, dma_addr_t dev_addr,
 		return;
 	}
 
+	swiotlb_dma_sync(phys_to_virt(paddr), size, dir);
+
 	if (dir != DMA_FROM_DEVICE)
 		return;
 
@@ -835,8 +850,11 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 				return 0;
 			}
 			sg->dma_address = swiotlb_virt_to_bus(hwdev, map);
-		} else
+		} else {
+			swiotlb_dma_sync_page(sg_page(sg), sg->offset,
+					      sg->length, dir);
 			sg->dma_address = dev_addr;
+		}
 		sg->dma_length = sg->length;
 	}
 	return nelems;
-- 
1.6.3.3

