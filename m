From: Christoph Hellwig <hch@infradead.org>
Date: Wed, 02 Mar 2005 05:17:42 +0000
Subject: Re: take7: vector sharing (Large I/O system support)
Message-Id: <20050302051742.GC11194@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <42226CCE.6070706@jp.fujitsu.com>
In-Reply-To: <42226CCE.6070706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Mar 02, 2005 at 10:20:38AM +0900, Kenji Kaneshige wrote:
> Christoph Hellwig wrote:
> >>
> >>The problem is naming, I think.  Those aren't "cache entries", they
> >>are statically preallocated entries.  How about changing the config
> >>option name to:
> >
> >
> >Even for early allocations what speaks against alloc_bootmem?
> >
> >
> 
> I didn't use alloc_bootmem because I thought alloc_bootmem was
> very simple allocator and we should not use it to allocate
> arbitrary size (not PAGE_SIZE * n) of memory so frequently.
> But I don't know about it very much and my understanding might
> be incorrect.
> 
> Can I use alloc_bootmem as well as kmalloc to allocate arbitrary
> size of memory?

alloc_bootmem is pretty stupid so, yes you have to be carefull to
avoid too much wastage.

