From: "John W. Linville" <linville@tuxdriver.com>
Date: Tue, 13 Sep 2005 00:06:13 +0000
Subject: Re: [patch 2.6.13] ia64: add EXPORT_SYMBOL_GPL for ia64_max_cacheline_size
Message-Id: <20050913000611.GI19644@tuxdriver.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <09122005104852.31327@bilbo.tuxdriver.com> <20050912192524.GA14360@infradead.org>
In-Reply-To: <20050912192524.GA14360@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, tony.luck@intel.com

On Mon, Sep 12, 2005 at 08:25:24PM +0100, Christoph Hellwig wrote:
> On Mon, Sep 12, 2005 at 10:48:52AM -0400, John W. Linville wrote:
> > The implementation of dma_get_cache_alignment for ia64 makes reference
> > to ia64_max_cacheline_size inside of a static inline. For this to
> > work for modules, this needs to be EXPORT_SYMBOL{,_GPL}.
> 
> This is not supposed to be a _GPL api.  best just move
> dma_get_cache_alignment out of line.

You are thinking of something like the x86_64 implementation?
That seems reasonable to me.  Patch to follow...

John
-- 
John W. Linville
linville@tuxdriver.com
