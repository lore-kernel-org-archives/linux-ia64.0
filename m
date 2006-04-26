From: Jes Sorensen <jes@sgi.com>
Date: Wed, 26 Apr 2006 09:12:48 +0000
Subject: Re: [PATCH] change gen_pool allocator to not touch managed memory
Message-Id: <444F3990.5030100@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <444D1A7E.mailx85W11DZZU@aqua.americas.sgi.com> <20060424181626.09966912.akpm@osdl.org> <20060425155051.GA19248@sgi.com>
In-Reply-To: <20060425155051.GA19248@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Dean Nelson <dcn@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, tony.luck@intel.com, avolkov@varma-el.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org

Dean Nelson wrote:
>>> Both Andrey Volkov and Jes Sorensen have expressed a desire that the
>>> gen_pool allocator not write to the memory being managed. See the
>>> following:
>>>
>>>   http://marc.theaimsgroup.com/?l=linux-kernel&m3518602713125&w=2
>>>   http://marc.theaimsgroup.com/?l=linux-kernel&m3533568827916&w=2
>> hm, fair enough.
>>
>> The patch is fairly large+intrusive.  I trust it's been broadly tested?
> 
> Yes, it was thoroughly tested. I even pulled the bitmap manipulation code
> into a user app with which I could pre-set bits of a bitmap in order to
> test boundary conditions with various contiguous bit lengths.

I haven't been directly involved in this work, but I am very confident
in Dean's work in this.

Just a few minor nits below:

> -unsigned long gen_pool_alloc(struct gen_pool *poolp, int size)
> +int gen_pool_add(struct gen_pool *pool, unsigned long addr, size_t size,
> +		 int nid)
>  {
> -	int j, i, s, max_chunk_size;
> -	unsigned long a, flags;
> -	struct gen_pool_link *h = poolp->h;
> +	struct gen_pool_chunk *chunk;
> +	int nbits = size >> pool->min_alloc_order;
> +	int nbytes = sizeof(struct gen_pool_chunk) +
> +				(nbits + BITS_PER_BYTE - 1) / BITS_PER_BYTE;
> +
> +	if (nbytes > PAGE_SIZE) {
> +		chunk = vmalloc_node(nbytes, nid);
> +	} else {
> +		chunk = kmalloc_node(nbytes, GFP_KERNEL, nid);
> +	}

Any patch that adds vmalloc() calls to code always makes the little
hairs on the back of my neck stand up. Any chance we could get away with
alloc_pages_node() for this?

>  	ia64_pal_mc_drain();
> -	status = smp_call_function(uncached_ipi_mc_drain, NULL, 0, 1);
> -	if (status)
> -		printk(KERN_WARNING "smp_call_function failed for "
> -		       "uncached_ipi_mc_drain! (%i)\n", status);
> +	(void) smp_call_function(uncached_ipi_mc_drain, NULL, 0, 1);

This thing could in theory fail so having the error check there seems
the right thing to me. In either case, please don't (void) the function
return (this is a style issue, I know).

> Index: linux-2.6/arch/ia64/sn/kernel/sn2/cache.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/sn2/cache.c	2006-04-24 12:25:36.234717101 -0500
> +++ linux-2.6/arch/ia64/sn/kernel/sn2/cache.c	2006-04-24 12:27:56.012899026 -0500

This part we should maybe do in a seperate patch? It seems valid on it's
own?

Cheers,
Jes
