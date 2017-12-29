From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:18:49 +0000
Subject: [PATCH 45/67] swiotlb: rename swiotlb_free to swiotlb_exit
Message-Id: <20171229081911.2802-46-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/kernel/dma-swiotlb.c | 2 +-
 arch/x86/kernel/pci-swiotlb.c     | 2 +-
 include/linux/swiotlb.h           | 4 ++--
 lib/swiotlb.c                     | 2 +-
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/dma-swiotlb.c b/arch/powerpc/kernel/dma-swiotlb.c
index 506ac4fafac5..88f3963ca30f 100644
--- a/arch/powerpc/kernel/dma-swiotlb.c
+++ b/arch/powerpc/kernel/dma-swiotlb.c
@@ -121,7 +121,7 @@ static int __init check_swiotlb_enabled(void)
 	if (ppc_swiotlb_enable)
 		swiotlb_print_info();
 	else
-		swiotlb_free();
+		swiotlb_exit();
 
 	return 0;
 }
diff --git a/arch/x86/kernel/pci-swiotlb.c b/arch/x86/kernel/pci-swiotlb.c
index 7a11a3e4f697..57dea60c2473 100644
--- a/arch/x86/kernel/pci-swiotlb.c
+++ b/arch/x86/kernel/pci-swiotlb.c
@@ -119,7 +119,7 @@ void __init pci_swiotlb_late_init(void)
 {
 	/* An IOMMU turned us off. */
 	if (!swiotlb)
-		swiotlb_free();
+		swiotlb_exit();
 	else {
 		printk(KERN_INFO "PCI-DMA: "
 		       "Using software bounce buffering for IO (SWIOTLB)\n");
diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 24ed817082ee..606375e35d87 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -115,10 +115,10 @@ extern int
 swiotlb_dma_supported(struct device *hwdev, u64 mask);
 
 #ifdef CONFIG_SWIOTLB
-extern void __init swiotlb_free(void);
+extern void __init swiotlb_exit(void);
 unsigned int swiotlb_max_segment(void);
 #else
-static inline void swiotlb_free(void) { }
+static inline void swiotlb_exit(void) { }
 static inline unsigned int swiotlb_max_segment(void) { return 0; }
 #endif
 
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 6583f3512386..c1fcd3a32d07 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -417,7 +417,7 @@ swiotlb_late_init_with_tbl(char *tlb, unsigned long nslabs)
 	return -ENOMEM;
 }
 
-void __init swiotlb_free(void)
+void __init swiotlb_exit(void)
 {
 	if (!io_tlb_orig_addr)
 		return;
-- 
2.14.2

