From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 25 Jun 2020 13:08:29 +0000
Subject: [PATCH 06/13] iommu/tegra: Use dev_iommu_priv_get/set()
Message-Id: <20200625130836.1916-7-joro@8bytes.org>
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
 drivers/iommu/tegra-gart.c | 8 ++++----
 drivers/iommu/tegra-smmu.c | 8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/iommu/tegra-gart.c b/drivers/iommu/tegra-gart.c
index 5fbdff6ff41a..fac720273889 100644
--- a/drivers/iommu/tegra-gart.c
+++ b/drivers/iommu/tegra-gart.c
@@ -113,8 +113,8 @@ static int gart_iommu_attach_dev(struct iommu_domain *domain,
 
 	if (gart->active_domain && gart->active_domain != domain) {
 		ret = -EBUSY;
-	} else if (dev->archdata.iommu != domain) {
-		dev->archdata.iommu = domain;
+	} else if (dev_iommu_priv_get(dev) != domain) {
+		dev_iommu_priv_set(dev, domain);
 		gart->active_domain = domain;
 		gart->active_devices++;
 	}
@@ -131,8 +131,8 @@ static void gart_iommu_detach_dev(struct iommu_domain *domain,
 
 	spin_lock(&gart->dom_lock);
 
-	if (dev->archdata.iommu = domain) {
-		dev->archdata.iommu = NULL;
+	if (dev_iommu_priv_get(dev) = domain) {
+		dev_iommu_priv_set(dev, NULL);
 
 		if (--gart->active_devices = 0)
 			gart->active_domain = NULL;
diff --git a/drivers/iommu/tegra-smmu.c b/drivers/iommu/tegra-smmu.c
index 7426b7666e2b..124c8848ab7e 100644
--- a/drivers/iommu/tegra-smmu.c
+++ b/drivers/iommu/tegra-smmu.c
@@ -465,7 +465,7 @@ static void tegra_smmu_as_unprepare(struct tegra_smmu *smmu,
 static int tegra_smmu_attach_dev(struct iommu_domain *domain,
 				 struct device *dev)
 {
-	struct tegra_smmu *smmu = dev->archdata.iommu;
+	struct tegra_smmu *smmu = dev_iommu_priv_get(dev);
 	struct tegra_smmu_as *as = to_smmu_as(domain);
 	struct device_node *np = dev->of_node;
 	struct of_phandle_args args;
@@ -780,7 +780,7 @@ static struct iommu_device *tegra_smmu_probe_device(struct device *dev)
 			 * supported by the Linux kernel, so abort after the
 			 * first match.
 			 */
-			dev->archdata.iommu = smmu;
+			dev_iommu_priv_set(dev, smmu);
 
 			break;
 		}
@@ -797,7 +797,7 @@ static struct iommu_device *tegra_smmu_probe_device(struct device *dev)
 
 static void tegra_smmu_release_device(struct device *dev)
 {
-	dev->archdata.iommu = NULL;
+	dev_iommu_priv_set(dev, NULL);
 }
 
 static const struct tegra_smmu_group_soc *
@@ -856,7 +856,7 @@ static struct iommu_group *tegra_smmu_group_get(struct tegra_smmu *smmu,
 static struct iommu_group *tegra_smmu_device_group(struct device *dev)
 {
 	struct iommu_fwspec *fwspec = dev_iommu_fwspec_get(dev);
-	struct tegra_smmu *smmu = dev->archdata.iommu;
+	struct tegra_smmu *smmu = dev_iommu_priv_get(dev);
 	struct iommu_group *group;
 
 	group = tegra_smmu_group_get(smmu, fwspec->ids[0]);
-- 
2.27.0
