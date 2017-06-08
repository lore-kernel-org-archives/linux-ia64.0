From: Christoph Hellwig <hch@lst.de>
Date: Thu, 08 Jun 2017 13:25:47 +0000
Subject: [PATCH 22/44] x86/pci-nommu: implement ->mapping_error
Message-Id: <20170608132609.32662-23-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20170608132609.32662-1-hch@lst.de>
In-Reply-To: <20170608132609.32662-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: x86@kernel.org, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, openrisc@lists.librecores.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dmaengine@vger.kernel.org, linux-tegra@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org, netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

DMA_ERROR_CODE is going to go away, so don't rely on it.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/x86/kernel/pci-nommu.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/pci-nommu.c b/arch/x86/kernel/pci-nommu.c
index a88952ef371c..085fe6ce4049 100644
--- a/arch/x86/kernel/pci-nommu.c
+++ b/arch/x86/kernel/pci-nommu.c
@@ -11,6 +11,8 @@
 #include <asm/iommu.h>
 #include <asm/dma.h>
 
+#define NOMMU_MAPPING_ERROR		0
+
 static int
 check_addr(char *name, struct device *hwdev, dma_addr_t bus, size_t size)
 {
@@ -33,7 +35,7 @@ static dma_addr_t nommu_map_page(struct device *dev, struct page *page,
 	dma_addr_t bus = page_to_phys(page) + offset;
 	WARN_ON(size = 0);
 	if (!check_addr("map_single", dev, bus, size))
-		return DMA_ERROR_CODE;
+		return NOMMU_MAPPING_ERROR;
 	flush_write_buffers();
 	return bus;
 }
@@ -88,6 +90,11 @@ static void nommu_sync_sg_for_device(struct device *dev,
 	flush_write_buffers();
 }
 
+static int nommu_mapping_error(struct device *dev, dma_addr_t dma_addr)
+{
+	return dma_addr = NOMMU_MAPPING_ERROR;
+}
+
 const struct dma_map_ops nommu_dma_ops = {
 	.alloc			= dma_generic_alloc_coherent,
 	.free			= dma_generic_free_coherent,
@@ -96,4 +103,5 @@ const struct dma_map_ops nommu_dma_ops = {
 	.sync_single_for_device = nommu_sync_single_for_device,
 	.sync_sg_for_device	= nommu_sync_sg_for_device,
 	.is_phys		= 1,
+	.mapping_error		= nommu_mapping_error,
 };
-- 
2.11.0

