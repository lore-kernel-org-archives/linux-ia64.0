From: Christoph Hellwig <hch@infradead.org>
Date: Tue, 13 Sep 2005 09:24:24 +0000
Subject: Re: [patch 2.6.13] ia64: re-implement dma_get_cache_alignment to avoid EXPORT_SYMBOL
Message-Id: <20050913092424.GB29552@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104852.31327@bilbo.tuxdriver.com> <20050912192524.GA14360@infradead.org> <20050913000611.GI19644@tuxdriver.com> <20050913001429.GJ19644@tuxdriver.com>
In-Reply-To: <20050913001429.GJ19644@tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Mon, Sep 12, 2005 at 08:14:29PM -0400, John W. Linville wrote:
> The current ia64 implementation of dma_get_cache_alignment does not
> work for modules because it relies on a symbol which is not exported.
> Direct access to a global is a little ugly anyway, so this patch
> re-implements dma_get_cache_alignment in a manner similar to what is
> currently used for x86_64.

looks good to me.

