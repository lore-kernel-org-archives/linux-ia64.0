From: Hugh Dickins <hugh@veritas.com>
Date: Sat, 08 Jan 2005 21:12:10 +0000
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
Message-Id: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>

On Tue, 4 Jan 2005, Christoph Lameter wrote:
> This patch introduces __GFP_ZERO as an additional gfp_mask element to allow
> to request zeroed pages from the page allocator.
> ...
> --- linux-2.6.10.orig/mm/memory.c	2005-01-04 12:16:41.000000000 -0800
> +++ linux-2.6.10/mm/memory.c	2005-01-04 12:16:49.000000000 -0800
> @@ -1650,10 +1650,9 @@
> 
>  		if (unlikely(anon_vma_prepare(vma)))
>  			goto no_mem;
> -		page = alloc_page_vma(GFP_HIGHUSER, vma, addr);
> +		page = alloc_page_vma(GFP_HIGHZERO, vma, addr);
>  		if (!page)
>  			goto no_mem;
> -		clear_user_highpage(page, addr);
> 
>  		spin_lock(&mm->page_table_lock);
>  		page_table = pte_offset_map(pmd, addr);

Christoph, a late comment: doesn't this effectively replace
do_anonymous_page's clear_user_highpage by clear_highpage, which would
be a bad idea (inefficient? or corrupting?) on those few architectures
which actually do something with that user addr?

Hugh

