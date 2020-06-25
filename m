From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 25 Jun 2020 13:08:28 +0000
Subject: [PATCH 05/13] iommu/rockchip: Use dev_iommu_priv_get/set()
Message-Id: <20200625130836.1916-6-joro@8bytes.org>
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
 drivers/iommu/rockchip-iommu.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/rockchip-iommu.c b/drivers/iommu/rockchip-iommu.c
index d25c2486ca07..e5d86b7177de 100644
--- a/drivers/iommu/rockchip-iommu.c
+++ b/drivers/iommu/rockchip-iommu.c
@@ -836,7 +836,7 @@ static size_t rk_iommu_unmap(struct iommu_domain *domain, unsigned long _iova,
 
 static struct rk_iommu *rk_iommu_from_dev(struct device *dev)
 {
-	struct rk_iommudata *data = dev->archdata.iommu;
+	struct rk_iommudata *data = dev_iommu_priv_get(dev);
 
 	return data ? data->iommu : NULL;
 }
@@ -1059,7 +1059,7 @@ static struct iommu_device *rk_iommu_probe_device(struct device *dev)
 	struct rk_iommudata *data;
 	struct rk_iommu *iommu;
 
-	data = dev->archdata.iommu;
+	data = dev_iommu_priv_get(dev);
 	if (!data)
 		return ERR_PTR(-ENODEV);
 
@@ -1073,7 +1073,7 @@ static struct iommu_device *rk_iommu_probe_device(struct device *dev)
 
 static void rk_iommu_release_device(struct device *dev)
 {
-	struct rk_iommudata *data = dev->archdata.iommu;
+	struct rk_iommudata *data = dev_iommu_priv_get(dev);
 
 	device_link_del(data->link);
 }
@@ -1100,7 +1100,7 @@ static int rk_iommu_of_xlate(struct device *dev,
 	iommu_dev = of_find_device_by_node(args->np);
 
 	data->iommu = platform_get_drvdata(iommu_dev);
-	dev->archdata.iommu = data;
+	dev_iommu_priv_set(dev, data);
 
 	platform_device_put(iommu_dev);
 
-- 
2.27.0
