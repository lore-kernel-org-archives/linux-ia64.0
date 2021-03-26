From: John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>
Date: Fri, 26 Mar 2021 07:39:32 +0000
Subject: Re: [PATCH] ia64: simplify code flow around swiotlb init
Message-Id: <d0f37f22-1d2a-50f5-886b-5e4b9892b921@physik.fu-berlin.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210325233530.1397011-1-slyfox@gentoo.org>
In-Reply-To: <20210325233530.1397011-1-slyfox@gentoo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sergei Trofimovich <slyfox@gentoo.org>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org
Cc: linux-kernel@vger.kernel.org

Hi Sergei!

On 3/26/21 12:35 AM, Sergei Trofimovich wrote:
> Before the change CONFIG_INTEL_IOMMU && !CONFIG_SWIOTLB && !CONFIG_FLATMEM
> 
> could skip `set_max_mapnr(max_low_pfn);` is iommu is not present on system.
                                           ^^
                                       typo s/is/if/

I will test this patch to make sure it doesn't break on the BL870c i4.

Adrian

> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-ia64@vger.kernel.org
> Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
> ---
>  arch/ia64/mm/init.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 16d0d7d22657..a63585db94fe 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -644,13 +644,16 @@ mem_init (void)
>  	 * _before_ any drivers that may need the PCI DMA interface are
>  	 * initialized or bootmem has been freed.
>  	 */
> +	do {
>  #ifdef CONFIG_INTEL_IOMMU
> -	detect_intel_iommu();
> -	if (!iommu_detected)
> +		detect_intel_iommu();
> +		if (iommu_detected)
> +			break;
>  #endif
>  #ifdef CONFIG_SWIOTLB
>  		swiotlb_init(1);
>  #endif
> +	} while (0);
>  
>  #ifdef CONFIG_FLATMEM
>  	BUG_ON(!mem_map);
> 
-- 
 .''`.  John Paul Adrian Glaubitz
: :' :  Debian Developer - glaubitz@debian.org
`. `'   Freie Universitaet Berlin - glaubitz@physik.fu-berlin.de
  `-    GPG: 62FF 8A75 84E0 2956 9546  0006 7426 3B37 F5B5 F913
