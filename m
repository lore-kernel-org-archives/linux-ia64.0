From: Christoph Hellwig <hch@lst.de>
Date: Fri, 07 Dec 2018 19:07:11 +0000
Subject: [PATCH 06/15] dma-mapping: simplify the dma_sync_single_range_for_{cpu,device} implementation
Message-Id: <20181207190720.18517-7-hch@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20181207190720.18517-1-hch@lst.de>
In-Reply-To: <20181207190720.18517-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Tariq Toukan <tariqt@mellanox.com>, Ilias Apalodimas <ilias.apalodimas@linaro.org>, =?UTF-8?q?Toke=20H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>, Robin Murphy <robin.murphy@arm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Keith Busch <keith.busch@intel.com>, Jonathan Derrick <jonathan.derrick@intel.com>, linux-pci@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

We can just call the regular calls after adding offset the the address instead
of reimplementing them.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/dma-debug.h   | 27 ------------------------
 include/linux/dma-mapping.h | 34 +++++++++---------------------
 kernel/dma/debug.c          | 42 -------------------------------------
 3 files changed, 10 insertions(+), 93 deletions(-)

diff --git a/include/linux/dma-debug.h b/include/linux/dma-debug.h
index 30213adbb6b9..c85e097a984c 100644
--- a/include/linux/dma-debug.h
+++ b/include/linux/dma-debug.h
@@ -72,17 +72,6 @@ extern void debug_dma_sync_single_for_device(struct device *dev,
 					     dma_addr_t dma_handle,
 					     size_t size, int direction);
 
-extern void debug_dma_sync_single_range_for_cpu(struct device *dev,
-						dma_addr_t dma_handle,
-						unsigned long offset,
-						size_t size,
-						int direction);
-
-extern void debug_dma_sync_single_range_for_device(struct device *dev,
-						   dma_addr_t dma_handle,
-						   unsigned long offset,
-						   size_t size, int direction);
-
 extern void debug_dma_sync_sg_for_cpu(struct device *dev,
 				      struct scatterlist *sg,
 				      int nelems, int direction);
@@ -174,22 +163,6 @@ static inline void debug_dma_sync_single_for_device(struct device *dev,
 {
 }
 
-static inline void debug_dma_sync_single_range_for_cpu(struct device *dev,
-						       dma_addr_t dma_handle,
-						       unsigned long offset,
-						       size_t size,
-						       int direction)
-{
-}
-
-static inline void debug_dma_sync_single_range_for_device(struct device *dev,
-							  dma_addr_t dma_handle,
-							  unsigned long offset,
-							  size_t size,
-							  int direction)
-{
-}
-
 static inline void debug_dma_sync_sg_for_cpu(struct device *dev,
 					     struct scatterlist *sg,
 					     int nelems, int direction)
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 7799c2b27849..8916499d2805 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -360,6 +360,13 @@ static inline void dma_sync_single_for_cpu(struct device *dev, dma_addr_t addr,
 	debug_dma_sync_single_for_cpu(dev, addr, size, dir);
 }
 
+static inline void dma_sync_single_range_for_cpu(struct device *dev,
+		dma_addr_t addr, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
+{
+	return dma_sync_single_for_cpu(dev, addr + offset, size, dir);
+}
+
 static inline void dma_sync_single_for_device(struct device *dev,
 					      dma_addr_t addr, size_t size,
 					      enum dma_data_direction dir)
@@ -372,32 +379,11 @@ static inline void dma_sync_single_for_device(struct device *dev,
 	debug_dma_sync_single_for_device(dev, addr, size, dir);
 }
 
-static inline void dma_sync_single_range_for_cpu(struct device *dev,
-						 dma_addr_t addr,
-						 unsigned long offset,
-						 size_t size,
-						 enum dma_data_direction dir)
-{
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_cpu)
-		ops->sync_single_for_cpu(dev, addr + offset, size, dir);
-	debug_dma_sync_single_range_for_cpu(dev, addr, offset, size, dir);
-}
-
 static inline void dma_sync_single_range_for_device(struct device *dev,
-						    dma_addr_t addr,
-						    unsigned long offset,
-						    size_t size,
-						    enum dma_data_direction dir)
+		dma_addr_t addr, unsigned long offset, size_t size,
+		enum dma_data_direction dir)
 {
-	const struct dma_map_ops *ops = get_dma_ops(dev);
-
-	BUG_ON(!valid_dma_direction(dir));
-	if (ops->sync_single_for_device)
-		ops->sync_single_for_device(dev, addr + offset, size, dir);
-	debug_dma_sync_single_range_for_device(dev, addr, offset, size, dir);
+	return dma_sync_single_for_device(dev, addr + offset, size, dir);
 }
 
 static inline void
diff --git a/kernel/dma/debug.c b/kernel/dma/debug.c
index 231ca4628062..3214833b47e2 100644
--- a/kernel/dma/debug.c
+++ b/kernel/dma/debug.c
@@ -1662,48 +1662,6 @@ void debug_dma_sync_single_for_device(struct device *dev,
 }
 EXPORT_SYMBOL(debug_dma_sync_single_for_device);
 
-void debug_dma_sync_single_range_for_cpu(struct device *dev,
-					 dma_addr_t dma_handle,
-					 unsigned long offset, size_t size,
-					 int direction)
-{
-	struct dma_debug_entry ref;
-
-	if (unlikely(dma_debug_disabled()))
-		return;
-
-	ref.type         = dma_debug_single;
-	ref.dev          = dev;
-	ref.dev_addr     = dma_handle;
-	ref.size         = offset + size;
-	ref.direction    = direction;
-	ref.sg_call_ents = 0;
-
-	check_sync(dev, &ref, true);
-}
-EXPORT_SYMBOL(debug_dma_sync_single_range_for_cpu);
-
-void debug_dma_sync_single_range_for_device(struct device *dev,
-					    dma_addr_t dma_handle,
-					    unsigned long offset,
-					    size_t size, int direction)
-{
-	struct dma_debug_entry ref;
-
-	if (unlikely(dma_debug_disabled()))
-		return;
-
-	ref.type         = dma_debug_single;
-	ref.dev          = dev;
-	ref.dev_addr     = dma_handle;
-	ref.size         = offset + size;
-	ref.direction    = direction;
-	ref.sg_call_ents = 0;
-
-	check_sync(dev, &ref, false);
-}
-EXPORT_SYMBOL(debug_dma_sync_single_range_for_device);
-
 void debug_dma_sync_sg_for_cpu(struct device *dev, struct scatterlist *sg,
 			       int nelems, int direction)
 {
-- 
2.19.1
