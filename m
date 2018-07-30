From: Christoph Hellwig <hch@lst.de>
Date: Mon, 30 Jul 2018 16:38:12 +0000
Subject: [PATCH 08/20] powerpc/dma: remove the unused dma_nommu_ops export
Message-Id: <20180730163824.10064-9-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20180730163824.10064-1-hch@lst.de>
In-Reply-To: <20180730163824.10064-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Robin Murphy <robin.murphy@arm.com>, linuxppc-dev@lists.ozlabs.org, iommu@lists.linux-foundation.org, linux-ia64@vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/kernel/dma.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/arch/powerpc/kernel/dma.c b/arch/powerpc/kernel/dma.c
index dbfc7056d7df..3939589aab04 100644
--- a/arch/powerpc/kernel/dma.c
+++ b/arch/powerpc/kernel/dma.c
@@ -286,7 +286,6 @@ const struct dma_map_ops dma_nommu_ops = {
 	.sync_sg_for_device 		= dma_nommu_sync_sg,
 #endif
 };
-EXPORT_SYMBOL(dma_nommu_ops);
 
 int dma_set_coherent_mask(struct device *dev, u64 mask)
 {
-- 
2.18.0

