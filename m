From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 05 Jan 2009 14:36:06 +0000
Subject: [PATCH 01/13] add map/unmap_single_attr and map/unmap_sg_attr to struct dma_mapping_ops
Message-Id: <1231166178-20050-2-git-send-email-fujita.tomonori@lab.ntt.co.jp>
List-Id: <linux-ia64.vger.kernel.org>
References: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <1231166178-20050-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: tony.luck@intel.com
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

This adds map/unmap_single_attr and map/unmap_sg_attr to struct
dma_mapping_ops. This enables us to move the dma operations in struct
ia64_machine_vector to struct dma_mapping_ops.

Note that we will remove map/unmap_sg and map/umap_single.

This is a preparation of struct dma_mapping_ops unification.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 arch/ia64/include/asm/dma-mapping.h |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/arch/ia64/include/asm/dma-mapping.h b/arch/ia64/include/asm/dma-mapping.h
index bbab7e2..eeb2aa3 100644
--- a/arch/ia64/include/asm/dma-mapping.h
+++ b/arch/ia64/include/asm/dma-mapping.h
@@ -20,6 +20,13 @@ struct dma_mapping_ops {
 				size_t size, int direction);
 	void            (*unmap_single)(struct device *dev, dma_addr_t addr,
 				size_t size, int direction);
+	dma_addr_t      (*map_single_attrs)(struct device *dev, void *cpu_addr,
+					    size_t size, int direction,
+					    struct dma_attrs *attrs);
+	void		(*unmap_single_attrs)(struct device *dev,
+					      dma_addr_t dma_addr,
+					      size_t size, int direction,
+					      struct dma_attrs *attrs);
 	void            (*sync_single_for_cpu)(struct device *hwdev,
 				dma_addr_t dma_handle, size_t size,
 				int direction);
@@ -43,6 +50,13 @@ struct dma_mapping_ops {
 	void            (*unmap_sg)(struct device *hwdev,
 				struct scatterlist *sg, int nents,
 				int direction);
+	int             (*map_sg_attrs)(struct device *dev,
+					struct scatterlist *sg, int nents,
+					int direction, struct dma_attrs *attrs);
+	void            (*unmap_sg_attrs)(struct device *dev,
+					  struct scatterlist *sg, int nents,
+					  int direction,
+					  struct dma_attrs *attrs);
 	int             (*dma_supported_op)(struct device *hwdev, u64 mask);
 	int		is_phys;
 };
-- 
1.6.0.6

