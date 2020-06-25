From: Joerg Roedel <joro@8bytes.org>
Date: Thu, 25 Jun 2020 13:08:30 +0000
Subject: [PATCH 07/13] iommu/pamu: Use dev_iommu_priv_get/set()
Message-Id: <20200625130836.1916-8-joro@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200625130836.1916-1-joro@8bytes.org>
In-Reply-To: <20200625130836.1916-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, x86@kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Marek Szyprowski <m.szyprowski@samsung.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Matthias Brugger <matthias.bgg@gmail.com>, Heiko Stuebner <heiko@sntech.de>, Thierry Reding <thierry.reding@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, intel-gfx@lists.freedesktop.org, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

Remove the use of dev->archdata.iommu_domain and use the private
per-device pointer provided by IOMMU core code instead.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 drivers/iommu/fsl_pamu_domain.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/iommu/fsl_pamu_domain.c b/drivers/iommu/fsl_pamu_domain.c
index 928d37771ece..b2110767caf4 100644
--- a/drivers/iommu/fsl_pamu_domain.c
+++ b/drivers/iommu/fsl_pamu_domain.c
@@ -323,7 +323,7 @@ static void remove_device_ref(struct device_domain_info *info, u32 win_cnt)
 	pamu_disable_liodn(info->liodn);
 	spin_unlock_irqrestore(&iommu_lock, flags);
 	spin_lock_irqsave(&device_domain_lock, flags);
-	info->dev->archdata.iommu_domain = NULL;
+	dev_iommu_priv_set(info->dev, NULL);
 	kmem_cache_free(iommu_devinfo_cache, info);
 	spin_unlock_irqrestore(&device_domain_lock, flags);
 }
@@ -352,7 +352,7 @@ static void attach_device(struct fsl_dma_domain *dma_domain, int liodn, struct d
 	 * Check here if the device is already attached to domain or not.
 	 * If the device is already attached to a domain detach it.
 	 */
-	old_domain_info = dev->archdata.iommu_domain;
+	old_domain_info = dev_iommu_priv_get(dev);
 	if (old_domain_info && old_domain_info->domain != dma_domain) {
 		spin_unlock_irqrestore(&device_domain_lock, flags);
 		detach_device(dev, old_domain_info->domain);
@@ -371,8 +371,8 @@ static void attach_device(struct fsl_dma_domain *dma_domain, int liodn, struct d
 	 * the info for the first LIODN as all
 	 * LIODNs share the same domain
 	 */
-	if (!dev->archdata.iommu_domain)
-		dev->archdata.iommu_domain = info;
+	if (!dev_iommu_priv_get(dev))
+		dev_iommu_priv_set(dev, info);
 	spin_unlock_irqrestore(&device_domain_lock, flags);
 }
 
-- 
2.27.0
