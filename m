From: Andi Kleen <ak@suse.de>
Date: Fri, 30 Jul 2004 16:59:19 +0000
Subject: [PATCH] Various swiotlb fixes
Message-Id: <20040730185919.1ef1100a.ak@suse.de>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This patch fixes various issues in the IA64 swiotlb code.
I only tested it on x86-64 (which shares this code), but I don't expect problems on 
IA64.

The biggest change is better overflow handling, partly ported from the AMD64 
IOMMU  code.  This is important for some 3d drivers who make use of this and can 
map a lot of memory.

First it increases the default memory usage of swiotlb to 64MB.
This was the value used in production systems in 2.4 (e.g. in SLES8) and the default
was far too small.  Note this is only allocated when the swiotlb is needed.

pci_map_single will not panic anymore on an overflow. Instead it returns
a pointer to a scratch area and allows the caller to check using 
dma_mapping_error(). It still panics when the overflow buffer is exceeded.

dma_mapping_error support is implemented.

pci_map_sg will never panic now, but just return 0. Near all callers 
of it seem to have proper error checking for this (IDE will even handle
it without erroring out) 

The handling of passing a NULL device is improved, previously it would 
never map in this case. i386 and other architectures assume NULL means a 4GB
limit instead.   This code does this now too.

I added support for swiotlb=force for easier testing.

Thanks to Suresh for unbreaking some of my originally broken changes.

diff -urpN -X ../KDIFX linux-2.6.8rc2-mm1/arch/ia64/lib/swiotlb.c linux-2.6.8rc2-mm1-amd64/arch/ia64/lib/swiotlb.c
--- linux-2.6.8rc2-mm1/arch/ia64/lib/swiotlb.c	2004-04-06 13:12:00.000000000 +0200
+++ linux-2.6.8rc2-mm1-amd64/arch/ia64/lib/swiotlb.c	2004-07-30 17:02:49.000000000 +0200
@@ -11,6 +11,7 @@
  * 03/05/07 davidm	Switch from PCI-DMA to generic device DMA API.
  * 00/12/13 davidm	Rename to swiotlb.c and add mark_clean() to avoid
  *			unnecessary i-cache flushing.
+ * 04/07/.. ak          Better overflow handling. Assorted fixes.
  */
 
 #include <linux/cache.h>
@@ -20,6 +21,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/types.h>
+#include <linux/ctype.h>
 
 #include <asm/io.h>
 #include <asm/pci.h>
@@ -46,6 +48,8 @@
  */
 #define IO_TLB_SHIFT 11
 
+int swiotlb_force;
+
 /*
  * Used to do a quick range check in swiotlb_unmap_single and swiotlb_sync_single_*, to see
  * if the memory was in fact allocated by this API.
@@ -55,8 +59,16 @@ static char *io_tlb_start, *io_tlb_end;
 /*
  * The number of IO TLB blocks (in groups of 64) betweeen io_tlb_start and io_tlb_end.
  * This is command line adjustable via setup_io_tlb_npages.
+ * Default to 64MB.
+ */
+static unsigned long io_tlb_nslabs = 32768;
+
+/* 
+ * When the IOMMU overflows we return a fallback buffer. This sets the size.
  */
-static unsigned long io_tlb_nslabs = 1024;
+static unsigned long io_tlb_overflow = 32*1024;
+
+void *io_tlb_overflow_buffer; 
 
 /*
  * This is a free list describing the number of free entries available from each index
@@ -78,15 +90,19 @@ static spinlock_t io_tlb_lock = SPIN_LOC
 static int __init
 setup_io_tlb_npages (char *str)
 {
-	io_tlb_nslabs = simple_strtoul(str, NULL, 0) << (PAGE_SHIFT - IO_TLB_SHIFT);
-
-	/* avoid tail segment of size < IO_TLB_SEGSIZE */
-	io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
-
+	if (isdigit(*str)) { 
+		io_tlb_nslabs = simple_strtoul(str, &str, 0) << (PAGE_SHIFT - IO_TLB_SHIFT);
+		/* avoid tail segment of size < IO_TLB_SEGSIZE */
+		io_tlb_nslabs = ALIGN(io_tlb_nslabs, IO_TLB_SEGSIZE);
+	}
+	if (*str = ',')
+		++str;
+	if (!strcmp(str, "force"))
+		swiotlb_force = 1;
 	return 1;
 }
 __setup("swiotlb=", setup_io_tlb_npages);
-
+/* make io_tlb_overflow tunable too? */
 
 /*
  * Statically reserve bounce buffer space and initialize bounce buffer data structures for
@@ -102,7 +118,7 @@ swiotlb_init (void)
 	 */
 	io_tlb_start = alloc_bootmem_low_pages(io_tlb_nslabs * (1 << IO_TLB_SHIFT));
 	if (!io_tlb_start)
-		BUG();
+		panic("Cannot allocate SWIOTLB buffer");
 	io_tlb_end = io_tlb_start + io_tlb_nslabs * (1 << IO_TLB_SHIFT);
 
 	/*
@@ -115,10 +131,22 @@ swiotlb_init (void)
  		io_tlb_list[i] = IO_TLB_SEGSIZE - OFFSET(i, IO_TLB_SEGSIZE);
 	io_tlb_index = 0;
 	io_tlb_orig_addr = alloc_bootmem(io_tlb_nslabs * sizeof(char *));
-
-	printk(KERN_INFO "Placing software IO TLB between 0x%p - 0x%p\n",
-	       (void *) io_tlb_start, (void *) io_tlb_end);
-}
+	
+	/* 
+	 * Get the overflow emergency buffer 
+	 */
+	io_tlb_overflow_buffer = alloc_bootmem_low(io_tlb_overflow); 
+	printk(KERN_INFO "Placing software IO TLB between 0x%lx - 0x%lx\n",
+	       virt_to_phys(io_tlb_start), virt_to_phys(io_tlb_end));
+}
+
+static inline int address_needs_mapping(struct device *hwdev, dma_addr_t addr)
+{ 
+	dma_addr_t mask = 0xffffffff; 
+	if (hwdev && hwdev->dma_mask) 
+		mask = *hwdev->dma_mask; 
+	return (addr & ~mask) != 0; 		
+} 
 
 /*
  * Allocates bounce buffer and returns its kernel virtual address.
@@ -184,11 +212,8 @@ map_single (struct device *hwdev, char *
 				index = 0;
 		} while (index != wrap);
 
-		/*
-		 * XXX What is a suitable recovery mechanism here?  We cannot
-		 * sleep because we are called from with in interrupts!
-		 */
-		panic("map_single: could not allocate software IO TLB (%ld bytes)", size);
+		spin_unlock_irqrestore(&io_tlb_lock, flags);
+		return NULL;
 	}
   found:
 	spin_unlock_irqrestore(&io_tlb_lock, flags);
@@ -285,7 +310,7 @@ swiotlb_alloc_coherent (struct device *h
 
 	memset(ret, 0, size);
 	dev_addr = virt_to_phys(ret);
-	if (hwdev && hwdev->dma_mask && (dev_addr & ~*hwdev->dma_mask) != 0)
+	if (address_needs_mapping(hwdev,dev_addr))
 		panic("swiotlb_alloc_consistent: allocated memory is out of range for device");
 	*dma_handle = dev_addr;
 	return ret;
@@ -297,6 +322,28 @@ swiotlb_free_coherent (struct device *hw
 	free_pages((unsigned long) vaddr, get_order(size));
 }
 
+static void swiotlb_full(struct device *dev, size_t size, int dir, int do_panic)
+{
+	/* 
+	 * Ran out of IOMMU space for this operation. This is very bad.
+	 * Unfortunately the drivers cannot handle this operation properly.
+	 * unless they check for pci_dma_mapping_error (most don't)
+	 * When the mapping is small enough return a static buffer to limit
+	 * the damage, or panic when the transfer is too big. 
+	 */ 
+	
+	printk(KERN_ERR 
+  "PCI-DMA: Out of SW-IOMMU space for %lu bytes at device %s\n",
+	       size, dev ? dev->bus_id : "?");
+
+	if (size > io_tlb_overflow && do_panic) {
+		if (dir = PCI_DMA_FROMDEVICE || dir = PCI_DMA_BIDIRECTIONAL)
+			panic("PCI-DMA: Memory would be corrupted\n");
+		if (dir = PCI_DMA_TODEVICE || dir = PCI_DMA_BIDIRECTIONAL) 
+			panic("PCI-DMA: Random memory would be DMAed\n"); 
+	} 
+} 
+
 /*
  * Map a single buffer of the indicated size for DMA in streaming mode.  The PCI address
  * to use is returned.
@@ -308,13 +355,14 @@ dma_addr_t
 swiotlb_map_single (struct device *hwdev, void *ptr, size_t size, int dir)
 {
 	unsigned long dev_addr = virt_to_phys(ptr);
+	void *map; 
 
 	if (dir = DMA_NONE)
 		BUG();
 	/*
 	 * Check if the PCI device can DMA to ptr... if so, just return ptr
 	 */
-	if (hwdev && hwdev->dma_mask && (dev_addr & ~*hwdev->dma_mask) = 0)
+	if (!address_needs_mapping(hwdev, dev_addr) && !swiotlb_force) 
 		/*
 		 * Device is bit capable of DMA'ing to the buffer... just return the PCI
 		 * address of ptr
@@ -324,12 +372,18 @@ swiotlb_map_single (struct device *hwdev
 	/*
 	 * get a bounce buffer:
 	 */
-	dev_addr = virt_to_phys(map_single(hwdev, ptr, size, dir));
+	map = map_single(hwdev, ptr, size, dir);
+	if (!map) { 
+		swiotlb_full(hwdev, size, dir, 1);		
+		map = io_tlb_overflow_buffer; 
+	}
+
+	dev_addr = virt_to_phys(map);
 
 	/*
 	 * Ensure that the address returned is DMA'ble:
 	 */
-	if (hwdev && hwdev->dma_mask && (dev_addr & ~*hwdev->dma_mask) != 0)
+	if (address_needs_mapping(hwdev, dev_addr))
 		panic("map_single: bounce buffer is not DMA'ble");
 
 	return dev_addr;
@@ -437,9 +491,17 @@ swiotlb_map_sg (struct device *hwdev, st
 	for (i = 0; i < nelems; i++, sg++) {
 		addr = SG_ENT_VIRT_ADDRESS(sg);
 		dev_addr = virt_to_phys(addr);
-		if (hwdev && hwdev->dma_mask && (dev_addr & ~*hwdev->dma_mask) != 0)
+		if (swiotlb_force || address_needs_mapping(hwdev, dev_addr)) {
 			sg->dma_address = (dma_addr_t) map_single(hwdev, addr, sg->length, dir);
-		else
+			if (!sg->dma_address) {
+				/* Don't panic here, we expect pci_map_sg users
+				   to do proper error handling. */
+				swiotlb_full(hwdev, sg->length, dir, 0); 
+				swiotlb_unmap_sg(hwdev, sg - i, i, dir);
+				sg[0].dma_length = 0;
+				return 0;
+			}
+		} else
 			sg->dma_address = dev_addr;
 		sg->dma_length = sg->length;
 	}
@@ -501,7 +563,7 @@ swiotlb_sync_sg_for_device (struct devic
 int
 swiotlb_dma_mapping_error (dma_addr_t dma_addr)
 {
-	return 0;
+	return (dma_addr = virt_to_phys(io_tlb_overflow_buffer));
 }
 
 /*
