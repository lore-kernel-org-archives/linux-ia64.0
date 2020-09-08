From: Christoph Hellwig <hch@lst.de>
Date: Tue, 08 Sep 2020 16:47:50 +0000
Subject: [PATCH 04/12] dma-mapping: fix DMA_OPS dependencies
Message-Id: <20200908164758.3177341-5-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908164758.3177341-1-hch@lst.de>
In-Reply-To: <20200908164758.3177341-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, iommu@lists.linux-foundation.org
Cc: Tomasz Figa <tfiga@chromium.org>, Joerg Roedel <joro@8bytes.org>, Robin Murphy <robin.murphy@arm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org

Driver that select DMA_OPS need to depend on HAS_DMA support to
work.  The vop driver was missing that dependency, so add it, and also
add a nother depends in DMA_OPS itself.  That won't fix the issue due
to how the Kconfig dependencies work, but at least produce a warning
about unmet dependencies.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/misc/mic/Kconfig | 1 +
 kernel/dma/Kconfig       | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/misc/mic/Kconfig b/drivers/misc/mic/Kconfig
index b9bb086785db48..8a7c2c5711d5f4 100644
--- a/drivers/misc/mic/Kconfig
+++ b/drivers/misc/mic/Kconfig
@@ -35,6 +35,7 @@ config SCIF_BUS
 
 config VOP_BUS
 	tristate "VOP Bus Driver"
+	depends on HAS_DMA
 	select DMA_OPS
 	help
 	  This option is selected by any driver which registers a
diff --git a/kernel/dma/Kconfig b/kernel/dma/Kconfig
index 0ddfb5510fe45f..e7b801649f6574 100644
--- a/kernel/dma/Kconfig
+++ b/kernel/dma/Kconfig
@@ -9,6 +9,7 @@ config HAS_DMA
 	default y
 
 config DMA_OPS
+	depends on HAS_DMA
 	bool
 
 #
-- 
2.28.0
