From: Christoph Hellwig <hch@lst.de>
Date: Fri, 29 Dec 2017 08:19:02 +0000
Subject: [PATCH 58/67] ia64: remove an ifdef around the content of pci-dma.c
Message-Id: <20171229081911.2802-59-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171229081911.2802-1-hch@lst.de>
In-Reply-To: <20171229081911.2802-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-c6x-dev@linux-c6x.org, linux-cris-kernel@axis.com, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-metag@vger.kernel.org, Michal Simek <monstr@monstr.eu>, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, patches@groups.riscv.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Guan Xuetao <gxt@mprc.pku.edu.cn>, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

The file is only compiled if CONFIG_INTEL_IOMMU is set to start with.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/ia64/kernel/pci-dma.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/arch/ia64/kernel/pci-dma.c b/arch/ia64/kernel/pci-dma.c
index 35e0cad33b7d..b5df084c0af4 100644
--- a/arch/ia64/kernel/pci-dma.c
+++ b/arch/ia64/kernel/pci-dma.c
@@ -12,12 +12,7 @@
 #include <asm/iommu.h>
 #include <asm/machvec.h>
 #include <linux/dma-mapping.h>
-
-
-#ifdef CONFIG_INTEL_IOMMU
-
 #include <linux/kernel.h>
-
 #include <asm/page.h>
 
 dma_addr_t bad_dma_address __read_mostly;
@@ -115,5 +110,3 @@ void __init pci_iommu_alloc(void)
 	}
 #endif /* CONFIG_SWIOTLB */
 }
-
-#endif
-- 
2.14.2

