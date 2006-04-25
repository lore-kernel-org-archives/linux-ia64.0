From: Andrew Morton <akpm@osdl.org>
Date: Tue, 25 Apr 2006 01:16:26 +0000
Subject: Re: [PATCH] change gen_pool allocator to not touch managed memory
Message-Id: <20060424181626.09966912.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com>
In-Reply-To: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: tony.luck@intel.com, jes@sgi.com, avolkov@varma-el.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

dcn@sgi.com (Dean Nelson) wrote:
>
> 
> The following patch modifies the gen_pool allocator (lib/genalloc.c) to
> utilize a bitmap scheme instead of the buddy scheme. The purpose of this
> change is to eliminate the touching of the actual memory being allocated.
> 
> Since the change modifies the interface, a change to the uncached
> allocator (arch/ia64/kernel/uncached.c) is also required.
> 
> Signed-off-by: Dean Nelson <dcn@sgi.com>
> 
> ---
> 
> Andrew,
> 
> Both Andrey Volkov and Jes Sorenson have expressed a desire that the
> gen_pool allocator not write to the memory being managed. See the
> following:
> 
>   http://marc.theaimsgroup.com/?l=linux-kernel&m3518602713125&w=2
>   http://marc.theaimsgroup.com/?l=linux-kernel&m3533568827916&w=2

hm, fair enough.

The patch is fairly large+intrusive.  I trust it's been broadly tested?

> -unsigned long gen_pool_alloc(struct gen_pool *poolp, int size)
> +int gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size,
> +		 int nid)
>  {
> -	int j, i, s, max_chunk_size;
> -	unsigned long a, flags;
> -	struct gen_pool_link *h = poolp->h;
> +	struct gen_pool_chunk *chunk;
> +	int nbits = size >> pool->min_alloc_order;
> +	int nbytes = sizeof(struct gen_pool_chunk) + nbits / 8;

We can use BITS_PER_BYTE rather than "8".

I have a suspicion that `nbytes' here needs to be rounded up.

> +	if (nbytes > PAGE_SIZE) {
> +		if (nid = GENALLOC_NID_NONE)
> +			chunk = vmalloc(nbytes);
> +		else
> +			chunk = vmalloc_node(nbytes, nid);
> +	} else {
> +		if (nid = GENALLOC_NID_NONE)
> +			chunk = kmalloc(nbytes, GFP_KERNEL);
> +		else
> +			chunk = kmalloc_node(nbytes, GFP_KERNEL, nid);
> +	}

I don't think GENALLOC_NID_NONE needs to exist.  If the caller passes in
`nid=-1', kmalloc_node() will do what you want.

Which is an apparently-undocumented feature...


