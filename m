From: Matt Fleming <matt.fleming@intel.com>
Date: Wed, 13 Feb 2013 10:07:08 +0000
Subject: Re: [PATCH V3] ia64/mm: fix a bad_page bug when crash kernel booting
Message-Id: <1360750028.24917.28.camel@mfleming-mobl1.ger.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <51074786.5030007@huawei.com>
	 <1359995565.7515.178.camel@mfleming-mobl1.ger.corp.intel.com>
	 <51131248.3080203@huawei.com> <5113450C.1080109@huawei.com>
In-Reply-To: <5113450C.1080109@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, fenghua.yu@intel.com, Liujiang <jiang.liu@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-efi@vger.kernel.org, linux-mm@kvack.org, Hanjun Guo <guohanjun@huawei.com>, WuJianguo <wujianguo@huawei.com>

On Thu, 2013-02-07 at 14:09 +0800, Xishi Qiu wrote:
> > Sorry, this bug will be happen when use Sparse-Memory(section is valid, but last
> 
> > several pages are invalid). If use Flat-Memory, crash kernel will boot successfully.
> > I think the following patch would be better.
> > 
> > Hi Andrew, will you just ignore the earlier patch and consider the following one? :>
> > 
> > Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> > ---
> >  arch/ia64/mm/init.c |    2 ++
> >  1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> > index 082e383..23f2ee3 100644
> > --- a/arch/ia64/mm/init.c
> > +++ b/arch/ia64/mm/init.c
> > @@ -213,6 +213,8 @@ free_initrd_mem (unsigned long start, unsigned long end)
> >  	for (; start < end; start += PAGE_SIZE) {
> >  		if (!virt_addr_valid(start))
> >  			continue;
> > +		if ((start >> PAGE_SHIFT) >= max_low_pfn)
> 
> I confused the vaddr and paddr, really sorry for it.
> 
> In efi_init() memory aligns in IA64_GRANULE_SIZE(16M). If set "crashkernel24M-:600M"
> and use sparse memory model, when crash kernel booting it changes [128M-728M] to [128M-720M].
> But initrd memory is in [709M-727M], and virt_addr_valid() *can not* check the invalid pages
> when freeing initrd memory. There are some pages missed at the end of the seciton.
> 
> ChangeLog V3:
> 	fixed vaddr mistake
> ChangeLog V2:
> 	add invalid pages check when freeing initrd memory
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  arch/ia64/mm/init.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
> index 082e383..8a269f8 100644
> --- a/arch/ia64/mm/init.c
> +++ b/arch/ia64/mm/init.c
> @@ -173,6 +173,7 @@ void __init
>  free_initrd_mem (unsigned long start, unsigned long end)
>  {
>  	struct page *page;
> +	unsigned long pfn;
>  	/*
>  	 * EFI uses 4KB pages while the kernel can use 4KB or bigger.
>  	 * Thus EFI and the kernel may have different page sizes. It is
> @@ -213,6 +214,9 @@ free_initrd_mem (unsigned long start, unsigned long end)
>  	for (; start < end; start += PAGE_SIZE) {
>  		if (!virt_addr_valid(start))
>  			continue;
> +		pfn = __pa(start) >> PAGE_SHIFT;
> +		if (pfn >= max_low_pfn)
> +			continue;
>  		page = virt_to_page(start);
>  		ClearPageReserved(page);
>  		init_page_count(page);

I would have presumed that fixing this bug would involve modifying the
ia64-specific kexec code?

Tony, Fenghua? Any thoughts?

