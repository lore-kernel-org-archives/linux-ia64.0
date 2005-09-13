From: Lion Vollnhals <lion.vollnhals@web.de>
Date: Tue, 13 Sep 2005 12:25:23 +0000
Subject: Re: [patch 2.6.13] ia64: re-implement dma_get_cache_alignment to avoid EXPORT_SYMBOL
Message-Id: <200509131425.23950.lion.vollnhals@web.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104852.31327@bilbo.tuxdriver.com> <20050913000611.GI19644@tuxdriver.com> <20050913001429.GJ19644@tuxdriver.com>
In-Reply-To: <20050913001429.GJ19644@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

>  unsigned long ia64_max_cacheline_size;
> +
> +int dma_get_cache_alignment(void)
> +{
> +        return ia64_max_cacheline_size;
> +}
> +EXPORT_SYMBOL(dma_get_cache_alignment);
> +

Are you intentionally returning an "int" instead of an "unsigned long"?

-- 
Lion Vollnhals
