From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Mon, 31 Mar 2003 10:17:46 +0000
Subject: [Linux-ia64] sba_iommu status?
Message-Id: <marc-linux-ia64-105590723705362@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,
	What is the status of the IOMMU support?  I'm finding that
with CONFIG_ZX1 turned on, that PCI cards that can do only 32-bit DMA
cause system hangs.

I enabled all the debug options in sba_iommu.c, and note that the
normal case bypasses the IOMMU.  It's only when a 32-bit DMA to high
memory happens that the hang happens.

Here's a sample trace from my driver:  I've added a printout of what's
in the scatterlist when pci_map_sg() returns.  The driver is mapping
user-mode virtual addresses by doing essentially in this instance:
	  get_user_pages(current, current->mm, vaddr, 1,
	  0, pages, NULL);
	  sg[0].page = pages[0];
	  sg[0].offset = (unsigned long)vaddr & (PAGE_SIZE - 1);
	  sg[0].length = 1024;
	  n = pci_map_sg(devp, sg, 1, DMA_FROM_DEVICE);

	  (setup and do DMA via sg_dma_address(&sg[0]) and sg_dma_len(&sg[0]))
	  pci_unmap_sg(devp, sg, 1, DMA_FROM_DEVICE);

The code works when I build the kernel as CONFIG_DIG; but not
otherwise.
The trace below is typical of what I see.
All DMA mappings except my driver bypass the IOMMU (they're mostly for
the SCSI card, which is a 64-bit card, and can do 64-bit DMA)
...
sba_map_sg() START 1 entries, 0xe00000003cb74000,0x400
sba_search_bitmap() o 1 e0000000040d0000    e0000000040d0000 1 1
    e0000000040d0000 2 1
sba_alloc_range(4000) 1 -> 1 hint 0/2
sba_map_single() 0x0000000000000000 -> 0x4000
     pdir 0xe00000003eb80008 a0000000000000ff
sba_map_sg() DONE 1 mapping

sglist[0] dmaaddr = 40004000, len = 1024

sba_unmap_sg() START 1 entries, 0xe00000003cb74000,0x400
sba_unmap_single() iovp 0x40004000/400
sba_unmap_sg() DONE (nents 0)

sba_map_sg() START 1 entries, 0xe00000003cb74400,0x400
sba_search_bitmap() o 1 e0000000040d0000    e0000000040d0000 4 3
sba_alloc_range(4000) 1 -> 2 hint 0/3
sba_map_single() 0x0000000000000000 -> 0x8000
     pdir 0xe00000003eb80010 a0000000000000ff
sba_map_sg() DONE 1 mapping


sba_unmap_sg() START 1 entries, 0xe00000003cb74400,0x400
sba_unmap_single() iovp 0x40008000/400
sba_unmap_sg() DONE (nents 0)

sba_map_sg() START 1 entries, 0xe00000003cb74800,0x400
sba_search_bitmap() o 1 e0000000040d0000    e0000000040d0000 8 7
sba_alloc_range(4000) 1 -> 3 hint 0/4
sba_map_single() 0x0000000040008000 -> 0xc000
     pdir 0xe00000003eb80018 a0000000400080ff
sba_map_sg() DONE 1 mapping

+BEGIN HARDWARE ERROR STATE AT MCA
+Err Record ID: 16    SAL Rev:  0.02
+Time: 03/31/2003 06:22:22    Severity 1
+Processor Device Error Info Section
 Processor Error Map: 0x201004000
 Processor State Param: 0xa8000000fff21330
 Processor LID: 0x0
+ Cache check info[0]
+  Level: L0, Index: 8388608, Operation: Unknown,
+ BUS Check Info [0]
+ Status Info: 2 ,Severity: 0 ,Transaction Type: 0 ,Transaction Size: 0 ,Error : Internal
e000000004007308 01 00 00 00 00 00 00 00 01 30 00 00 00 00 80 00 
e000000004007318 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
e000000004007328 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 
 CPUID Regs: 0x49656e69756e6547 0x6c65746e 0x0 0x1f000704
...

