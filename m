From: Zhen Lei <thunder.leizhen@huawei.com>
Date: Sun, 07 Apr 2019 12:41:44 +0000
Subject: [PATCH v4 3/6] iommu: add iommu_default_dma_mode_get() helper
Message-Id: <20190407124147.13576-4-thunder.leizhen@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190407124147.13576-1-thunder.leizhen@huawei.com>
In-Reply-To: <20190407124147.13576-1-thunder.leizhen@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>, John Garry <john.garry@huawei.com>, Robin Murphy <robin.murphy@arm.com>, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>, Jonathan Corbet <corbet@lwn.net>, linux-doc <linux-doc@vger.kernel.org>, Sebastian Ott <sebott@linux.ibm.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, David Woodhouse <dwmw2@infradead.org>, iommu <iommu@lists.linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, x86 <x86@kernel.org>, linux-ia64 <linux-ia64@vger.kernel.org>
Cc: Zhen Lei <thunder.leizhen@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

Add IOMMU_DMA_MODE_IS_LAZY() and IOMMU_DMA_MODE_IS_PASSTHROUGH() to make
the code looks cleaner.

There is no functional change, just prepare for the following patches.

Signed-off-by: Zhen Lei <thunder.leizhen@huawei.com>
---
 drivers/iommu/iommu.c | 12 ++++++++----
 include/linux/iommu.h | 11 +++++++++++
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index b75e23a2ea08da8..876c0966db2481a 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -168,6 +168,11 @@ static int __init iommu_dma_mode_setup(char *str)
 }
 early_param("iommu.dma_mode", iommu_dma_mode_setup);
 
+int iommu_default_dma_mode_get(void)
+{
+	return iommu_default_dma_mode;
+}
+
 static ssize_t iommu_group_attr_show(struct kobject *kobj,
 				     struct attribute *__attr, char *buf)
 {
@@ -1109,9 +1114,8 @@ struct iommu_group *iommu_group_get_for_dev(struct device *dev)
 	 */
 	if (!group->default_domain) {
 		struct iommu_domain *dom;
-		int def_domain_type -			(iommu_default_dma_mode = IOMMU_DMA_MODE_PASSTHROUGH)
-			? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
+		int def_domain_type = IOMMU_DMA_MODE_IS_PASSTHROUGH() \
+				? IOMMU_DOMAIN_IDENTITY : IOMMU_DOMAIN_DMA;
 
 		dom = __iommu_domain_alloc(dev->bus, def_domain_type);
 		if (!dom && def_domain_type != IOMMU_DOMAIN_DMA) {
@@ -1127,7 +1131,7 @@ struct iommu_group *iommu_group_get_for_dev(struct device *dev)
 		if (!group->domain)
 			group->domain = dom;
 
-		if (dom && (iommu_default_dma_mode = IOMMU_DMA_MODE_LAZY)) {
+		if (dom && IOMMU_DMA_MODE_IS_LAZY()) {
 			int attr = 1;
 			iommu_domain_set_attr(dom,
 					      DOMAIN_ATTR_DMA_USE_FLUSH_QUEUE,
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index c3f4e3416176496..1b35ae3f6382e4a 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -46,6 +46,10 @@
 #define IOMMU_DMA_MODE_STRICT		0x0
 #define IOMMU_DMA_MODE_LAZY		0x1
 #define IOMMU_DMA_MODE_PASSTHROUGH	0x2
+#define IOMMU_DMA_MODE_IS_LAZY() \
+		(iommu_default_dma_mode_get() = IOMMU_DMA_MODE_LAZY)
+#define IOMMU_DMA_MODE_IS_PASSTHROUGH() \
+		(iommu_default_dma_mode_get() = IOMMU_DMA_MODE_PASSTHROUGH)
 
 struct iommu_ops;
 struct iommu_group;
@@ -421,6 +425,8 @@ static inline void dev_iommu_fwspec_set(struct device *dev,
 int iommu_probe_device(struct device *dev);
 void iommu_release_device(struct device *dev);
 
+extern int iommu_default_dma_mode_get(void);
+
 #else /* CONFIG_IOMMU_API */
 
 struct iommu_ops {};
@@ -705,6 +711,11 @@ const struct iommu_ops *iommu_ops_from_fwnode(struct fwnode_handle *fwnode)
 	return NULL;
 }
 
+static inline int iommu_default_dma_mode_get(void)
+{
+	return IOMMU_DMA_MODE_PASSTHROUGH;
+}
+
 #endif /* CONFIG_IOMMU_API */
 
 #ifdef CONFIG_IOMMU_DEBUGFS
-- 
1.8.3

