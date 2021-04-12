From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Mon, 12 Apr 2021 08:18:10 +0000
Subject: Re: [PATCH V2] mm/page_alloc: Ensure that HUGETLB_PAGE_ORDER is less than MAX_ORDER
Message-Id: <09284b9a-cfe1-fc49-e1f6-3cf0c1b74c76@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1618199302-29335-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1618199302-29335-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org, akpm@linux-foundation.org
Cc: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org, "linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>

+ linuxppc-dev@lists.ozlabs.org
+ linux-ia64@vger.kernel.org

On 4/12/21 9:18 AM, Anshuman Khandual wrote:
> pageblock_order must always be less than MAX_ORDER, otherwise it might lead
> to an warning during boot. A similar problem got fixed on arm64 platform
> with the commit 79cc2ed5a716 ("arm64/mm: Drop THP conditionality from
> FORCE_MAX_ZONEORDER"). Assert the above condition before HUGETLB_PAGE_ORDER
> gets assigned as pageblock_order. This will help detect the problem earlier
> on platforms where HUGETLB_PAGE_SIZE_VARIABLE is enabled.
> 
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> Changes in V2:
> 
> - Changed WARN_ON() to BUILD_BUG_ON() per David
> 
> Changes in V1:
> 
> https://patchwork.kernel.org/project/linux-mm/patch/1617947717-2424-1-git-send-email-anshuman.khandual@arm.com/
> 
>  mm/page_alloc.c | 11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index cfc72873961d..19283bff4bec 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6875,10 +6875,17 @@ void __init set_pageblock_order(void)
>  	if (pageblock_order)
>  		return;
>  
> -	if (HPAGE_SHIFT > PAGE_SHIFT)
> +	if (HPAGE_SHIFT > PAGE_SHIFT) {
> +		/*
> +		 * pageblock_order must always be less than
> +		 * MAX_ORDER. So does HUGETLB_PAGE_ORDER if
> +		 * that is being assigned here.
> +		 */
> +		BUILD_BUG_ON(HUGETLB_PAGE_ORDER >= MAX_ORDER);

Unfortunately the build test fails on both the platforms (powerpc and ia64)
which subscribe HUGETLB_PAGE_SIZE_VARIABLE and where this check would make
sense. I some how overlooked the cross compile build failure that actually
detected this problem.

But wondering why this assert is not holding true ? and how these platforms
do not see the warning during boot (or do they ?) at mm/vmscan.c:1092 like
arm64 did.

static int __fragmentation_index(unsigned int order, struct contig_page_info *info)
{
        unsigned long requested = 1UL << order;

        if (WARN_ON_ONCE(order >= MAX_ORDER))
                return 0;
....

Can pageblock_order really exceed MAX_ORDER - 1 ?

>  		order = HUGETLB_PAGE_ORDER;
> -	else
> +	} else {
>  		order = MAX_ORDER - 1;
> +	}
>  
>  	/*
>  	 * Assume the largest contiguous order of interest is a huge page.
> 
