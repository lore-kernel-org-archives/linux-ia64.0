From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 29 Jun 2020 10:57:07 +0000
Subject: Re: [PATCH 13/13] powerpc/dma: Remove dev->archdata.iommu_domain
Message-Id: <87bll287i4.fsf@mpe.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200625130836.1916-1-joro@8bytes.org> <20200625130836.1916-14-joro@8bytes.org>
In-Reply-To: <20200625130836.1916-14-joro@8bytes.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Joerg Roedel <joro@8bytes.org>, iommu@lists.linux-foundation.org
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, x86@kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, Daniel Vetter <daniel@ffwll.ch>, Marek Szyprowski <m.szyprowski@samsung.com>, Joerg Roedel <joro@8bytes.org>, David Woodhouse <dwmw2@infradead.org>, Lu Baolu <baolu.lu@linux.intel.com>, Matthias Brugger <matthias.bgg@gmail.com>, Heiko Stuebner <heiko@sntech.de>, Thierry Reding <thierry.reding@gmail.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, intel-gfx@lists.freedesktop.org, Joerg Roedel <jroedel@suse.de>

Joerg Roedel <joro@8bytes.org> writes:
> From: Joerg Roedel <jroedel@suse.de>
>
> There are no users left, so remove the pointer and save some memory.
>
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/powerpc/include/asm/device.h | 3 ---
>  1 file changed, 3 deletions(-)

It's a little hard to confirm there are no users left just with grep,
but I think you've got them all, and the compiler should tell us if
you've missed any.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

> diff --git a/arch/powerpc/include/asm/device.h b/arch/powerpc/include/asm/device.h
> index 266542769e4b..1bc595213338 100644
> --- a/arch/powerpc/include/asm/device.h
> +++ b/arch/powerpc/include/asm/device.h
> @@ -34,9 +34,6 @@ struct dev_archdata {
>  	struct iommu_table	*iommu_table_base;
>  #endif
>  
> -#ifdef CONFIG_IOMMU_API
> -	void			*iommu_domain;
> -#endif
>  #ifdef CONFIG_PPC64
>  	struct pci_dn		*pci_data;
>  #endif
> -- 
> 2.27.0
