From: Jack Steiner <steiner@sgi.com>
Date: Tue, 29 Jul 2003 23:56:15 +0000
Subject: Re: [PATCH] (2.4.x bk) efi_memmap_walk_uc
Message-Id: <marc-linux-ia64-105952298923313@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105883467032028@msgid-missing>
In-Reply-To: <marc-linux-ia64-105883467032028@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Tue, 29 Jul 2003 15:35:16 -0700, Christopher Wedgwood <cw@sgi.com> said:
> 
>   Christopher> That sounds pretty good.  Even a naive bitmap allocator
>   Christopher> would probably work initially.  Might we ever want to
>   Christopher> allocate 2+ pages?  Forcing all allocations to be a
>   Christopher> single page makes many things easier.
> 
> The allocation granularity should be bytes, in my opinion.  The point
> of the UC allocator is so that we can share a single 64MB UC granule
> across the multiple users (of which there are a grand total of 2, at
> the moment...).
> 
> 	--david
> 

If granularity is bytes, we need to support page-aligned allocations. Fetchop
pages are mmap'ed to user space.

As far as fetchop is concerned, we always allocate 1 page at a time.

-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com

