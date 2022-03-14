From: Christoph Hellwig <hch@lst.de>
Date: Mon, 14 Mar 2022 07:31:18 +0000
Subject: [PATCH 04/15] swiotlb: rename swiotlb_late_init_with_default_size
Message-Id: <20220314073129.1862284-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220314073129.1862284-1-hch@lst.de>
In-Reply-To: <20220314073129.1862284-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Juergen Gross <jgross@suse.com>, Tom Lendacky <thomas.lendacky@amd.com>, linux-s390@vger.kernel.org, Stefano Stabellini <sstabellini@kernel.org>, linux-ia64@vger.kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, x86@kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, tboot-devel@lists.sourceforge.net, linux-hyperv@vger.kernel.org, linux-pci@vger.kernel.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Woodhouse <dwmw2@infradead.org>, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org

swiotlb_late_init_with_default_size is an overly verbose name that
doesn't even catch what the function is doing, given that the size is
not just a default but the actual requested size.

Rename it to swiotlb_init_late.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/x86/pci/sta2x11-fixup.c | 2 +-
 include/linux/swiotlb.h      | 2 +-
 kernel/dma/swiotlb.c         | 6 ++----
 3 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/arch/x86/pci/sta2x11-fixup.c b/arch/x86/pci/sta2x11-fixup.c
index 101081ad64b6d..e0c039a75b2db 100644
--- a/arch/x86/pci/sta2x11-fixup.c
+++ b/arch/x86/pci/sta2x11-fixup.c
@@ -57,7 +57,7 @@ static void sta2x11_new_instance(struct pci_dev *pdev)
 		int size = STA2X11_SWIOTLB_SIZE;
 		/* First instance: register your own swiotlb area */
 		dev_info(&pdev->dev, "Using SWIOTLB (size %i)\n", size);
-		if (swiotlb_late_init_with_default_size(size))
+		if (swiotlb_init_late(size))
 			dev_emerg(&pdev->dev, "init swiotlb failed\n");
 	}
 	list_add(&instance->list, &sta2x11_instance_list);
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 9fb3a568f0c51..b48b26bfa0edb 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -40,7 +40,7 @@ extern void swiotlb_init(int verbose);
 int swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose);
 unsigned long swiotlb_size_or_default(void);
 extern int swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs);
-extern int swiotlb_late_init_with_default_size(size_t default_size);
+int swiotlb_init_late(size_t size);
 extern void __init swiotlb_update_mem_attributes(void);
 
 phys_addr_t swiotlb_tbl_map_single(struct device *hwdev, phys_addr_t phys,
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index b75943c2a0a0e..14e08fa9621c2 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -281,11 +281,9 @@ swiotlb_init(int verbose)
  * initialize the swiotlb later using the slab allocator if needed.
  * This should be just like above, but with some error catching.
  */
-int
-swiotlb_late_init_with_default_size(size_t default_size)
+int swiotlb_init_late(size_t size)
 {
-	unsigned long nslabs -		ALIGN(default_size >> IO_TLB_SHIFT, IO_TLB_SEGSIZE);
+	unsigned long nslabs = ALIGN(size >> IO_TLB_SHIFT, IO_TLB_SEGSIZE);
 	unsigned long bytes;
 	unsigned char *vstart = NULL;
 	unsigned int order;
-- 
2.30.2
