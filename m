From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 25 Jun 2020 13:08:27 +0000
Subject: [PATCH 04/13] iommu/omap: Use dev_iommu_priv_get/set()
Message-Id: <20200625130836.1916-5-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200625130836.1916-1-joro@8bytes.org>
In-Reply-To: <20200625130836.1916-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, x86@kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Marek Szyprowski <m.szyprowski@samsung.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Matthias Brugger <matthias.bgg@gmail.com>, Heiko Stuebner <heiko@sntech.de>, Thierry Reding <thierry.reding@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, intel-gfx@lists.freedesktop.org, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

Remove the use of dev->archdata.iommu and use the private per-device
pointer provided by IOMMU core code instead.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 drivers/iommu/omap-iommu.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/iommu/omap-iommu.c b/drivers/iommu/omap-iommu.c
index c8282cc212cb..e84ead6fb234 100644
--- a/drivers/iommu/omap-iommu.c
+++ b/drivers/iommu/omap-iommu.c
@@ -71,7 +71,7 @@ static struct omap_iommu_domain *to_omap_domain(struct iommu_domain *dom)
  **/
 void omap_iommu_save_ctx(struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	struct omap_iommu *obj;
 	u32 *p;
 	int i;
@@ -101,7 +101,7 @@ EXPORT_SYMBOL_GPL(omap_iommu_save_ctx);
  **/
 void omap_iommu_restore_ctx(struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	struct omap_iommu *obj;
 	u32 *p;
 	int i;
@@ -1398,7 +1398,7 @@ static size_t omap_iommu_unmap(struct iommu_domain *domain, unsigned long da,
 
 static int omap_iommu_count(struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	int count = 0;
 
 	while (arch_data->iommu_dev) {
@@ -1459,8 +1459,8 @@ static void omap_iommu_detach_fini(struct omap_iommu_domain *odomain)
 static int
 omap_iommu_attach_dev(struct iommu_domain *domain, struct device *dev)
 {
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	struct omap_iommu_domain *omap_domain = to_omap_domain(domain);
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
 	struct omap_iommu_device *iommu;
 	struct omap_iommu *oiommu;
 	int ret = 0;
@@ -1524,7 +1524,7 @@ omap_iommu_attach_dev(struct iommu_domain *domain, struct device *dev)
 static void _omap_iommu_detach_dev(struct omap_iommu_domain *omap_domain,
 				   struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	struct omap_iommu_device *iommu = omap_domain->iommus;
 	struct omap_iommu *oiommu;
 	int i;
@@ -1650,7 +1650,7 @@ static struct iommu_device *omap_iommu_probe_device(struct device *dev)
 	int num_iommus, i;
 
 	/*
-	 * Allocate the archdata iommu structure for DT-based devices.
+	 * Allocate the per-device iommu structure for DT-based devices.
 	 *
 	 * TODO: Simplify this when removing non-DT support completely from the
 	 * IOMMU users.
@@ -1698,7 +1698,7 @@ static struct iommu_device *omap_iommu_probe_device(struct device *dev)
 		of_node_put(np);
 	}
 
-	dev->archdata.iommu = arch_data;
+	dev_iommu_priv_set(dev, arch_data);
 
 	/*
 	 * use the first IOMMU alone for the sysfs device linking.
@@ -1712,19 +1712,19 @@ static struct iommu_device *omap_iommu_probe_device(struct device *dev)
 
 static void omap_iommu_release_device(struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 
 	if (!dev->of_node || !arch_data)
 		return;
 
-	dev->archdata.iommu = NULL;
+	dev_iommu_priv_set(dev, NULL);
 	kfree(arch_data);
 
 }
 
 static struct iommu_group *omap_iommu_device_group(struct device *dev)
 {
-	struct omap_iommu_arch_data *arch_data = dev->archdata.iommu;
+	struct omap_iommu_arch_data *arch_data = dev_iommu_priv_get(dev);
 	struct iommu_group *group = ERR_PTR(-EINVAL);
 
 	if (!arch_data)
-- 
2.27.0
