From: Randy Dunlap <rdunlap@infradead.org>
Date: Wed, 17 Mar 2021 05:09:53 +0000
Subject: Re: [PATCH] ia64: hp: common: A typo fix in the file sba_iommu.c
Message-Id: <41387595-f4d0-40a5-93ff-6f8cc7797dc5@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210317031420.3136958-1-unixbhaskar@gmail.com>
In-Reply-To: <20210317031420.3136958-1-unixbhaskar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Bhaskar Chowdhury <unixbhaskar@gmail.com>, mpe@ellerman.id.au, huawei@kernel.org, schnelle@linux.ibm.com, nicoleotsuka@gmail.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

On 3/16/21 8:14 PM, Bhaskar Chowdhury wrote:
> 
> 
> s/minium/minimum/
> 
> 
> Signed-off-by: Bhaskar Chowdhury <unixbhaskar@gmail.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

> ---
>  arch/ia64/hp/common/sba_iommu.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/ia64/hp/common/sba_iommu.c b/arch/ia64/hp/common/sba_iommu.c
> index 9148ddbf02e5..3dcb8c35faad 100644
> --- a/arch/ia64/hp/common/sba_iommu.c
> +++ b/arch/ia64/hp/common/sba_iommu.c
> @@ -828,7 +828,7 @@ mark_clean (void *addr, size_t size)
>   * corresponding IO TLB entry. The PCOM (Purge Command Register)
>   * is to purge stale entries in the IO TLB when unmapping entries.
>   *
> - * The PCOM register supports purging of multiple pages, with a minium
> + * The PCOM register supports purging of multiple pages, with a minimum
>   * of 1 page and a maximum of 2GB. Hardware requires the address be
>   * aligned to the size of the range being purged. The size of the range
>   * must be a power of 2. The "Cool perf optimization" in the
> --


-- 
~Randy
