From: Nicolin Chen <nicoleotsuka@gmail.com>
Date: Mon, 31 Aug 2020 20:38:09 +0000
Subject: [RESEND][PATCH 5/7] sparc: Avoid overflow at boundary_size
Message-Id: <20200831203811.8494-6-nicoleotsuka@gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200831203811.8494-1-nicoleotsuka@gmail.com>
In-Reply-To: <20200831203811.8494-1-nicoleotsuka@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, tony.luck@intel.com, fenghua.yu@intel.com, schnelle@linux.ibm.com, gerald.schaefer@linux.ibm.com, hca@linux.ibm.com, gor@linux.ibm.com, borntraeger@de.ibm.com, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, x86@kernel.org, hpa@zytor.com, James.Bottomley@HansenPartnership.com, deller@gmx.de
Cc: sfr@canb.auug.org.au, hch@lst.de, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, sparclinux@vger.kernel.org, linux-parisc@vger.kernel.org

The boundary_size might be as large as ULONG_MAX, which means
that a device has no specific boundary limit. So either "+ 1"
or passing it to ALIGN() would potentially overflow.

According to kernel defines:
    #define ALIGN_MASK(x, mask) (((x) + (mask)) & ~(mask))
    #define ALIGN(x, a)	ALIGN_MASK(x, (typeof(x))(a) - 1)

We can simplify the logic here:
  ALIGN(boundary + 1, 1 << shift) >> shift
= ALIGN_MASK(b + 1, (1 << s) - 1) >> s
= {[b + 1 + (1 << s) - 1] & ~[(1 << s) - 1]} >> s
= [b + 1 + (1 << s) - 1] >> s
= [b + (1 << s)] >> s
= (b >> s) + 1

So fixing a potential overflow with the safer shortcut.

Signed-off-by: Nicolin Chen <nicoleotsuka@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>
---
 arch/sparc/kernel/iommu-common.c | 9 +++------
 arch/sparc/kernel/iommu.c        | 4 ++--
 arch/sparc/kernel/pci_sun4v.c    | 4 ++--
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/arch/sparc/kernel/iommu-common.c b/arch/sparc/kernel/iommu-common.c
index 59cb16691322..843e71894d04 100644
--- a/arch/sparc/kernel/iommu-common.c
+++ b/arch/sparc/kernel/iommu-common.c
@@ -166,13 +166,10 @@ unsigned long iommu_tbl_range_alloc(struct device *dev,
 		}
 	}
 
-	if (dev)
-		boundary_size = ALIGN(dma_get_seg_boundary(dev) + 1,
-				      1 << iommu->table_shift);
-	else
-		boundary_size = ALIGN(1ULL << 32, 1 << iommu->table_shift);
+	boundary_size = dev ? dma_get_seg_boundary(dev) : U32_MAX;
 
-	boundary_size = boundary_size >> iommu->table_shift;
+	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
+	boundary_size = (boundary_size >> iommu->table_shift) + 1;
 	/*
 	 * if the skip_span_boundary_check had been set during init, we set
 	 * things up so that iommu_is_span_boundary() merely checks if the
diff --git a/arch/sparc/kernel/iommu.c b/arch/sparc/kernel/iommu.c
index 4ae7388b1bff..d981c37305ae 100644
--- a/arch/sparc/kernel/iommu.c
+++ b/arch/sparc/kernel/iommu.c
@@ -472,8 +472,8 @@ static int dma_4u_map_sg(struct device *dev, struct scatterlist *sglist,
 	outs->dma_length = 0;
 
 	max_seg_size = dma_get_max_seg_size(dev);
-	seg_boundary_size = ALIGN(dma_get_seg_boundary(dev) + 1,
-				  IO_PAGE_SIZE) >> IO_PAGE_SHIFT;
+	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
+	seg_boundary_size = (dma_get_seg_boundary(dev) >> IO_PAGE_SHIFT) + 1;
 	base_shift = iommu->tbl.table_map_base >> IO_PAGE_SHIFT;
 	for_each_sg(sglist, s, nelems, i) {
 		unsigned long paddr, npages, entry, out_entry = 0, slen;
diff --git a/arch/sparc/kernel/pci_sun4v.c b/arch/sparc/kernel/pci_sun4v.c
index 14b93c5564e3..233fe8a20cec 100644
--- a/arch/sparc/kernel/pci_sun4v.c
+++ b/arch/sparc/kernel/pci_sun4v.c
@@ -508,8 +508,8 @@ static int dma_4v_map_sg(struct device *dev, struct scatterlist *sglist,
 	iommu_batch_start(dev, prot, ~0UL);
 
 	max_seg_size = dma_get_max_seg_size(dev);
-	seg_boundary_size = ALIGN(dma_get_seg_boundary(dev) + 1,
-				  IO_PAGE_SIZE) >> IO_PAGE_SHIFT;
+	/* Overflow-free shortcut for: ALIGN(b + 1, 1 << s) >> s */
+	seg_boundary_size = (dma_get_seg_boundary(dev) >> IO_PAGE_SHIFT) + 1;
 
 	mask = *dev->dma_mask;
 	if (!iommu_use_atu(iommu, mask))
-- 
2.17.1
