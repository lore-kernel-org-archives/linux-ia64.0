From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 30 May 2002 04:56:43 +0000
Subject: Re: [Linux-ia64] Missing files in to-linus-2.5 BK tree; build problems
Message-Id: <marc-linux-ia64-105590701905618@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905608@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905608@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 29 May 2002 12:29:00 -0700, Grant Grundler <grundler@cup.hp.com> said:

Grant> If someone has a tarball of the current to-linus tree I could
Grant> d/l, I could look at this sooner.

Can you take a look at this and see if you think it's sane?
I'm only doing this to get a clean compilation

--- /tmp/geta3892	Thu May 30 14:53:10 2002
+++ sba_iommu.c	Thu May 30 14:53:05 2002
@@ -216,9 +216,10 @@
 static int reserve_sba_gart = 1;
 static struct pci_dev sac_only_dev;
 
-#define sba_sg_iova(sg) (sg->address)
+#define sba_sg_iova(sg) (page_address((sg)->page) + (sg)->offset)
 #define sba_sg_len(sg) (sg->length)
 #define sba_sg_buffer(sg) (sg->orig_address)
+#define sba_sg_clear_iova(sg) (sg->page = NULL,sg->offset = 0)
 
 /* REVISIT - fix me for multiple SBAs/IOCs */
 #define GET_IOC(dev) (sba_list->ioc)
@@ -229,8 +230,8 @@
 ** DMA_CHUNK_SIZE is used by the SCSI mid-layer to break up
 ** (or rather not merge) DMA's into managable chunks.
 ** On parisc, this is more of the software/tuning constraint
-** rather than the HW. I/O MMU allocation alogorithms can be
-** faster with smaller size is (to some degree).
+** rather than the HW. I/O MMU allocation algorithms can be
+** faster with smaller sizes (to some degree).
 */
 #define DMA_CHUNK_SIZE  (BITS_PER_LONG*PAGE_SIZE)
 
@@ -1037,10 +1038,12 @@
 		*/
 		if ((u64)sba_sg_iova(startsg) & PIDE_FLAG) {
 			u32 pide = (u64)sba_sg_iova(startsg) & ~PIDE_FLAG;
+			char *vaddr;
 			dma_offset = (unsigned long) pide & ~IOVP_MASK;
-			sba_sg_iova(startsg) = 0;
 			dma_sg++;
-			sba_sg_iova(dma_sg) = (char *)(pide | ioc->ibase);
+			vaddr = (char *)(pide | ioc->ibase);
+			dma_sg->page = virt_to_page(vaddr);
+			dma_sg->offset = (u64)vaddr * ~PAGE_MASK;
 			pdirp = &(ioc->pdir_base[pide >> IOVP_SHIFT]);
 			n_mappings++;
 		}
@@ -1115,7 +1118,8 @@
 	int n_mappings = 0;
 
 	while (nents > 0) {
-		unsigned long vaddr = (unsigned long) (startsg->address); 
+		unsigned long vaddr = (unsigned long) sba_sg_iova(startsg);
+						       
 
 		/*
 		** Prepare for first/next DMA stream
@@ -1127,7 +1131,7 @@
 
 		/* PARANOID: clear entries */
 		sba_sg_buffer(startsg) = sba_sg_iova(startsg);
-		sba_sg_iova(startsg) = 0;
+		sba_sg_clear_iova(startsg);
 		sba_sg_len(startsg) = 0;
 
 		/*
@@ -1162,7 +1166,7 @@
 				vcontig_end += sba_sg_len(startsg);
 				dma_len     += sba_sg_len(startsg);
 				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
+				sba_sg_clear_iova(startsg);
 				sba_sg_len(startsg) = 0;
 				continue;
 			}
@@ -1178,9 +1182,9 @@
 			**
 			** Once we start a new VCONTIG chunk, dma_offset
 			** can't change. And we need the offset from the first
-			** chunk - not the last one. Ergo Successive chunks
-			** must start on page boundaries and dove tail
-			** with it's predecessor.
+			** chunk - not the last one. Ergo each successive chunk
+			** must start on a page boundary and dove-tail
+			** with its predecessor.
 			*/
 			sba_sg_len(vcontig_sg) = vcontig_len;
 
@@ -1196,7 +1200,7 @@
 				vcontig_end = vcontig_len + vaddr;
 				dma_len += vcontig_len;
 				sba_sg_buffer(startsg) = (char *)vaddr;
-				sba_sg_iova(startsg) = 0;
+				sba_sg_clear_iova(startsg);
 				continue;
 			} else {
 				break;
@@ -1211,9 +1215,13 @@
 		sba_sg_len(vcontig_sg) = vcontig_len;
 		dma_len = (dma_len + dma_offset + ~IOVP_MASK) & IOVP_MASK;
 		ASSERT(dma_len <= DMA_CHUNK_SIZE);
-		sba_sg_iova(dma_sg) = (char *) (PIDE_FLAG 
+		{ 
+			u64 vaddr = (PIDE_FLAG 
 			| (sba_alloc_range(ioc, dma_len) << IOVP_SHIFT)
 			| dma_offset);
+			dma_sg->page = virt_to_page(vaddr);
+			dma_sg->offset = vaddr & ~PAGE_MASK;
+		}
 		n_mappings++;
 	}
 
@@ -1248,7 +1256,8 @@
 	if (dev->dma_mask >= ioc->dma_mask) {
 		for (sg = sglist ; filled < nents ; filled++, sg++){
 			sba_sg_buffer(sg) = sba_sg_iova(sg);
-			sba_sg_iova(sg) = (char *)virt_to_phys(sba_sg_buffer(sg));
+			sg->page = virt_to_page(sba_sg_buffer(sg));
+			sg->offset = (u64)sba_sg_buffer(sg) & ~PAGE_MASK;
 		}
 #ifdef CONFIG_PROC_FS
 		spin_lock_irqsave(&ioc->res_lock, flags);
@@ -1260,10 +1269,13 @@
 #endif
 	/* Fast path single entry scatterlists. */
 	if (nents = 1) {
+		dma_addr_t vaddr;
 		sba_sg_buffer(sglist) = sba_sg_iova(sglist);
-		sba_sg_iova(sglist) = (char *)sba_map_single(dev,
+		vaddr = sba_map_single(dev,
 						sba_sg_buffer(sglist),
 						sba_sg_len(sglist), direction);
+		sglist->page = virt_to_page(vaddr);
+		sglist->offset = (u64)vaddr & ~PAGE_MASK;
 #ifdef CONFIG_PROC_FS
 		/*
 		** Should probably do some stats counting, but trying to
@@ -1628,7 +1640,7 @@
 			sba_dev->ioc[i].pdir_base[0] = 0x8000badbadc0ffeeULL;
 
 			for (reserved_iov = 0xA0000 ; reserved_iov < 0xC0000 ; reserved_iov += IOVP_SIZE) {
-				u64 *res_ptr = sba_dev->ioc[i].res_map;
+				u64 *res_ptr = (u64 *)sba_dev->ioc[i].res_map;
 				int index = PDIR_INDEX(reserved_iov);
 				int res_word;
 				u64 mask;
@@ -1759,7 +1771,7 @@
 
 	for (i = 0; i < PCI_NUM_RESOURCES; i++) {
 		if (pci_resource_flags(device, i) = IORESOURCE_MEM) {
-			hpa = ioremap(pci_resource_start(device, i),
+			hpa = (u64)ioremap(pci_resource_start(device, i),
 				pci_resource_len(device, i));
 			break;
 		}


--
Peter Chubb				    peterc@gelato.unsw.edu.au
You are lost in a maze of BitKeeper repositories, all almost the same.

