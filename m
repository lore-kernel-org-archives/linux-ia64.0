From: Frank Scheiner <frank.scheiner@web.de>
Date: Mon, 05 Aug 2019 08:16:12 +0000
Subject: Re: Regression in 543cea9a - was: Re: Kernel problem on rx2800 i2
Message-Id: <a837ce98-3357-65b5-17aa-86acdb0e92a4@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
In-Reply-To: <1d62aadd-67b6-da13-53cc-4b5213de8937@physik.fu-berlin.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 8/5/19 09:10, Christoph Hellwig wrote:
> Seems like we dropped the ball on this..

I still need to test the possible "disable CONFIG_NUMA" workaround. If
that works for my single processor rx2800 i2 it could be a good
workaround for now, as I assume the older Itanium systems (<= Montvale)
won't be affected by such a config change unless they're using those
ccNUMA sx1000/sx2000 chipsets.

>
> Did I give you a patch like this (for 5.2 and probably earlier, won't
> apply to 5.3-rc) to test before as that is anther idea?
>
> diff --git a/kernel/dma/direct.c b/kernel/dma/direct.c
> index 2c2772e9702a..e471158c7c6e 100644
> --- a/kernel/dma/direct.c
> +++ b/kernel/dma/direct.c
> @@ -119,7 +119,8 @@ struct page *__dma_direct_alloc_pages(struct device *dev, size_t size,
>   		}
>   	}
>   	if (!page)
> -		page = alloc_pages_node(dev_to_node(dev), gfp, page_order);
> +		page = alloc_pages_node(local_memory_node(dev_to_node(dev)),
> +				gfp, page_order);
>
>   	if (page && !dma_coherent_ok(dev, page_to_phys(page), size)) {
>   		__free_pages(page, page_order);
>

It's not the exact same patch as from [1], but the resulting code is
identical if I didn't make an error.

Cheers,
Frank

[1]: https://marc.info/?l=linux-ia64&m=156147364328197&w=2
