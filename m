From: Joerg Roedel <joro@8bytes.org>
Date: Wed, 14 Aug 2019 13:38:32 +0000
Subject: [PATCH 01/10] iommu: Add helpers to set/get default domain type
Message-Id: <20190814133841.7095-2-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190814133841.7095-1-joro@8bytes.org>
In-Reply-To: <20190814133841.7095-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>
Cc: corbet@lwn.net, tony.luck@intel.com, fenghua.yu@intel.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-ia64@vger.kernel.org, iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Thomas.Lendacky@amd.com, Suravee.Suthikulpanit@amd.com, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

Add a couple of functions to allow changing the default
domain type from architecture code and a function for iommu
drivers to request whether the default domain is
passthrough.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 drivers/iommu/iommu.c | 16 ++++++++++++++++
 include/linux/iommu.h | 16 ++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/iommu/iommu.c b/drivers/iommu/iommu.c
index 0c674d80c37f..f187e85a074b 100644
--- a/drivers/iommu/iommu.c
+++ b/drivers/iommu/iommu.c
@@ -2196,6 +2196,22 @@ int iommu_request_dma_domain_for_dev(struct device *dev)
 	return request_default_domain_for_dev(dev, IOMMU_DOMAIN_DMA);
 }
 
+void iommu_set_default_passthrough(void)
+{
+	iommu_def_domain_type = IOMMU_DOMAIN_IDENTITY;
+}
+
+void iommu_set_default_translated(void)
+{
+	iommu_def_domain_type = IOMMU_DOMAIN_DMA;
+}
+
+bool iommu_default_passthrough(void)
+{
+	return iommu_def_domain_type = IOMMU_DOMAIN_IDENTITY;
+}
+EXPORT_SYMBOL_GPL(iommu_default_passthrough);
+
 const struct iommu_ops *iommu_ops_from_fwnode(struct fwnode_handle *fwnode)
 {
 	const struct iommu_ops *ops = NULL;
diff --git a/include/linux/iommu.h b/include/linux/iommu.h
index fdc355ccc570..58c3e3e5f157 100644
--- a/include/linux/iommu.h
+++ b/include/linux/iommu.h
@@ -413,6 +413,9 @@ extern void iommu_get_resv_regions(struct device *dev, struct list_head *list);
 extern void iommu_put_resv_regions(struct device *dev, struct list_head *list);
 extern int iommu_request_dm_for_dev(struct device *dev);
 extern int iommu_request_dma_domain_for_dev(struct device *dev);
+extern void iommu_set_default_passthrough(void);
+extern void iommu_set_default_translated(void);
+extern bool iommu_default_passthrough(void);
 extern struct iommu_resv_region *
 iommu_alloc_resv_region(phys_addr_t start, size_t length, int prot,
 			enum iommu_resv_type type);
@@ -694,6 +697,19 @@ static inline int iommu_request_dma_domain_for_dev(struct device *dev)
 	return -ENODEV;
 }
 
+static inline void iommu_set_default_passthrough(void)
+{
+}
+
+static inline void iommu_set_default_translated(void)
+{
+}
+
+static inline bool iommu_default_passthrough(void)
+{
+	return true;
+}
+
 static inline int iommu_attach_group(struct iommu_domain *domain,
 				     struct iommu_group *group)
 {
-- 
2.17.1
