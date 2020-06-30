From: Joerg Roedel <joro@8bytes.org>
Date: Tue, 30 Jun 2020 10:00:14 +0000
Subject: Re: [PATCH 00/13] iommu: Remove usage of dev->archdata.iommu
Message-Id: <20200630100013.GJ28824@8bytes.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200625130836.1916-1-joro@8bytes.org>
In-Reply-To: <20200625130836.1916-1-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, x86@kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Marek Szyprowski <m.szyprowski@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Matthias Brugger <matthias.bgg@gmail.com>, Heiko Stuebner <heiko@sntech.de>, Thierry Reding <thierry.reding@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, intel-gfx@lists.freedesktop.org, Joerg Roedel <jroedel@suse.de>

On Thu, Jun 25, 2020 at 03:08:23PM +0200, Joerg Roedel wrote:
> Joerg Roedel (13):
>   iommu/exynos: Use dev_iommu_priv_get/set()
>   iommu/vt-d: Use dev_iommu_priv_get/set()
>   iommu/msm: Use dev_iommu_priv_get/set()
>   iommu/omap: Use dev_iommu_priv_get/set()
>   iommu/rockchip: Use dev_iommu_priv_get/set()
>   iommu/tegra: Use dev_iommu_priv_get/set()
>   iommu/pamu: Use dev_iommu_priv_get/set()
>   iommu/mediatek: Do no use dev->archdata.iommu
>   x86: Remove dev->archdata.iommu pointer
>   ia64: Remove dev->archdata.iommu pointer
>   arm: Remove dev->archdata.iommu pointer
>   arm64: Remove dev->archdata.iommu pointer
>   powerpc/dma: Remove dev->archdata.iommu_domain

Applied.
