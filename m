From: Christoph Hellwig <hch@infradead.org>
Date: Mon, 12 Sep 2005 19:25:24 +0000
Subject: Re: [patch 2.6.13] ia64: add EXPORT_SYMBOL_GPL for ia64_max_cacheline_size
Message-Id: <20050912192524.GA14360@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104852.31327@bilbo.tuxdriver.com>
In-Reply-To: <09122005104852.31327@bilbo.tuxdriver.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Mon, Sep 12, 2005 at 10:48:52AM -0400, John W. Linville wrote:
> The implementation of dma_get_cache_alignment for ia64 makes reference
> to ia64_max_cacheline_size inside of a static inline. For this to
> work for modules, this needs to be EXPORT_SYMBOL{,_GPL}.

This is not supposed to be a _GPL api.  best just move
dma_get_cache_alignment out of line.

