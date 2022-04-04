From: Christoph Hellwig <hch@lst.de>
Date: Mon, 04 Apr 2022 05:05:59 +0000
Subject: [PATCH 15/15] x86: remove cruft from <asm/dma-mapping.h>
Message-Id: <20220404050559.132378-16-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220404050559.132378-1-hch@lst.de>
In-Reply-To: <20220404050559.132378-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: x86@kernel.org, Anshuman Khandual <anshuman.khandual@arm.com>, Tom Lendacky <thomas.lendacky@amd.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefano Stabellini <sstabellini@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Robin Murphy <robin.murphy@arm.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-hyperv@vger.kernel.org, tboot-devel@lists.sourceforge.net, linux-pci@vger.kernel.org

<asm/dma-mapping.h> gets pulled in by all drivers using the DMA API.
Remove x86 internal variables and unnecessary includes from it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/include/asm/dma-mapping.h | 11 -----------
 arch/x86/include/asm/iommu.h       |  2 ++
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/arch/x86/include/asm/dma-mapping.h b/arch/x86/include/asm/dma-mapping.h
index 256fd8115223d..1c66708e30623 100644
--- a/arch/x86/include/asm/dma-mapping.h
+++ b/arch/x86/include/asm/dma-mapping.h
@@ -2,17 +2,6 @@
 #ifndef _ASM_X86_DMA_MAPPING_H
 #define _ASM_X86_DMA_MAPPING_H
 
-/*
- * IOMMU interface. See Documentation/core-api/dma-api-howto.rst and
- * Documentation/core-api/dma-api.rst for documentation.
- */
-
-#include <linux/scatterlist.h>
-#include <asm/io.h>
-
-extern int iommu_merge;
-extern int panic_on_overflow;
-
 extern const struct dma_map_ops *dma_ops;
 
 static inline const struct dma_map_ops *get_arch_dma_ops(struct bus_type *bus)
diff --git a/arch/x86/include/asm/iommu.h b/arch/x86/include/asm/iommu.h
index dba89ed40d38d..0bef44d30a278 100644
--- a/arch/x86/include/asm/iommu.h
+++ b/arch/x86/include/asm/iommu.h
@@ -8,6 +8,8 @@
 
 extern int force_iommu, no_iommu;
 extern int iommu_detected;
+extern int iommu_merge;
+extern int panic_on_overflow;
 
 #ifdef CONFIG_SWIOTLB
 extern bool x86_swiotlb_enable;
-- 
2.30.2
