From: Marek Szyprowski <m.szyprowski@samsung.com>
Date: Mon, 29 Jun 2020 07:51:41 +0000
Subject: Re: [PATCH 01/13] iommu/exynos: Use dev_iommu_priv_get/set()
Message-Id: <f69cc934-1fcc-c311-7bc0-22472befa796@samsung.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200625130836.1916-1-joro@8bytes.org>
        <CGME20200625130845eucas1p2e7715cbd0b8ad95d5f5bc86728c3aabe@eucas1p2.samsung.com>
        <20200625130836.1916-2-joro@8bytes.org>
In-Reply-To: <20200625130836.1916-2-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, x86@kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Matthias Brugger <matthias.bgg@gmail.com>, Heiko Stuebner <heiko@sntech.de>, Thierry Reding <thierry.reding@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, intel-gfx@lists.freedesktop.org, Joerg Roedel <jroedel@suse.de>

On 25.06.2020 15:08, Joerg Roedel wrote:
> From: Joerg Roedel <jroedel@suse.de>
>
> Remove the use of dev->archdata.iommu and use the private per-device
> pointer provided by IOMMU core code instead.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
Acked-by: Marek Szyprowski <m.szyprowski@samsung.com>
> ---
>   drivers/iommu/exynos-iommu.c                  | 20 +++++++++----------
>   .../media/platform/s5p-mfc/s5p_mfc_iommu.h    |  4 +++-
>   2 files changed, 13 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/iommu/exynos-iommu.c b/drivers/iommu/exynos-iommu.c
> index 60c8a56e4a3f..6a9b67302369 100644
> --- a/drivers/iommu/exynos-iommu.c
> +++ b/drivers/iommu/exynos-iommu.c
> @@ -173,7 +173,7 @@ static u32 lv2ent_offset(sysmmu_iova_t iova)
>   #define REG_V5_FAULT_AR_VA	0x070
>   #define REG_V5_FAULT_AW_VA	0x080
>   
> -#define has_sysmmu(dev)		(dev->archdata.iommu != NULL)
> +#define has_sysmmu(dev)		(dev_iommu_priv_get(dev) != NULL)
>   
>   static struct device *dma_dev;
>   static struct kmem_cache *lv2table_kmem_cache;
> @@ -226,7 +226,7 @@ static const struct sysmmu_fault_info sysmmu_v5_faults[] = {
>   };
>   
>   /*
> - * This structure is attached to dev.archdata.iommu of the master device
> + * This structure is attached to dev->iommu->priv of the master device
>    * on device add, contains a list of SYSMMU controllers defined by device tree,
>    * which are bound to given master device. It is usually referenced by 'owner'
>    * pointer.
> @@ -670,7 +670,7 @@ static int __maybe_unused exynos_sysmmu_suspend(struct device *dev)
>   	struct device *master = data->master;
>   
>   	if (master) {
> -		struct exynos_iommu_owner *owner = master->archdata.iommu;
> +		struct exynos_iommu_owner *owner = dev_iommu_priv_get(master);
>   
>   		mutex_lock(&owner->rpm_lock);
>   		if (data->domain) {
> @@ -688,7 +688,7 @@ static int __maybe_unused exynos_sysmmu_resume(struct device *dev)
>   	struct device *master = data->master;
>   
>   	if (master) {
> -		struct exynos_iommu_owner *owner = master->archdata.iommu;
> +		struct exynos_iommu_owner *owner = dev_iommu_priv_get(master);
>   
>   		mutex_lock(&owner->rpm_lock);
>   		if (data->domain) {
> @@ -837,8 +837,8 @@ static void exynos_iommu_domain_free(struct iommu_domain *iommu_domain)
>   static void exynos_iommu_detach_device(struct iommu_domain *iommu_domain,
>   				    struct device *dev)
>   {
> -	struct exynos_iommu_owner *owner = dev->archdata.iommu;
>   	struct exynos_iommu_domain *domain = to_exynos_domain(iommu_domain);
> +	struct exynos_iommu_owner *owner = dev_iommu_priv_get(dev);
>   	phys_addr_t pagetable = virt_to_phys(domain->pgtable);
>   	struct sysmmu_drvdata *data, *next;
>   	unsigned long flags;
> @@ -875,8 +875,8 @@ static void exynos_iommu_detach_device(struct iommu_domain *iommu_domain,
>   static int exynos_iommu_attach_device(struct iommu_domain *iommu_domain,
>   				   struct device *dev)
>   {
> -	struct exynos_iommu_owner *owner = dev->archdata.iommu;
>   	struct exynos_iommu_domain *domain = to_exynos_domain(iommu_domain);
> +	struct exynos_iommu_owner *owner = dev_iommu_priv_get(dev);
>   	struct sysmmu_drvdata *data;
>   	phys_addr_t pagetable = virt_to_phys(domain->pgtable);
>   	unsigned long flags;
> @@ -1237,7 +1237,7 @@ static phys_addr_t exynos_iommu_iova_to_phys(struct iommu_domain *iommu_domain,
>   
>   static struct iommu_device *exynos_iommu_probe_device(struct device *dev)
>   {
> -	struct exynos_iommu_owner *owner = dev->archdata.iommu;
> +	struct exynos_iommu_owner *owner = dev_iommu_priv_get(dev);
>   	struct sysmmu_drvdata *data;
>   
>   	if (!has_sysmmu(dev))
> @@ -1263,7 +1263,7 @@ static struct iommu_device *exynos_iommu_probe_device(struct device *dev)
>   
>   static void exynos_iommu_release_device(struct device *dev)
>   {
> -	struct exynos_iommu_owner *owner = dev->archdata.iommu;
> +	struct exynos_iommu_owner *owner = dev_iommu_priv_get(dev);
>   	struct sysmmu_drvdata *data;
>   
>   	if (!has_sysmmu(dev))
> @@ -1287,8 +1287,8 @@ static void exynos_iommu_release_device(struct device *dev)
>   static int exynos_iommu_of_xlate(struct device *dev,
>   				 struct of_phandle_args *spec)
>   {
> -	struct exynos_iommu_owner *owner = dev->archdata.iommu;
>   	struct platform_device *sysmmu = of_find_device_by_node(spec->np);
> +	struct exynos_iommu_owner *owner = dev_iommu_priv_get(dev);
>   	struct sysmmu_drvdata *data, *entry;
>   
>   	if (!sysmmu)
> @@ -1305,7 +1305,7 @@ static int exynos_iommu_of_xlate(struct device *dev,
>   
>   		INIT_LIST_HEAD(&owner->controllers);
>   		mutex_init(&owner->rpm_lock);
> -		dev->archdata.iommu = owner;
> +		dev_iommu_priv_set(dev, owner);
>   	}
>   
>   	list_for_each_entry(entry, &owner->controllers, owner_node)
> diff --git a/drivers/media/platform/s5p-mfc/s5p_mfc_iommu.h b/drivers/media/platform/s5p-mfc/s5p_mfc_iommu.h
> index 152a713fff78..1a32266b7ddc 100644
> --- a/drivers/media/platform/s5p-mfc/s5p_mfc_iommu.h
> +++ b/drivers/media/platform/s5p-mfc/s5p_mfc_iommu.h
> @@ -9,9 +9,11 @@
>   
>   #if defined(CONFIG_EXYNOS_IOMMU)
>   
> +#include <linux/iommu.h>
> +
>   static inline bool exynos_is_iommu_available(struct device *dev)
>   {
> -	return dev->archdata.iommu != NULL;
> +	return dev_iommu_priv_get(dev) != NULL;
>   }
>   
>   #else

Best regards
-- 
Marek Szyprowski, PhD
Samsung R&D Institute Poland
