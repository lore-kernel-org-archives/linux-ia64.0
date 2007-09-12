From: Christoph Lameter <clameter@sgi.com>
Date: Wed, 12 Sep 2007 22:28:10 +0000
Subject: Re: [PATCH] slub - Use local_t protection
Message-Id: <Pine.LNX.4.64.0709121522280.3835@schroedinger.engr.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20070827203913.GA7416@Krystal> <Pine.LNX.4.64.0708271401070.6435@schroedinger.engr.sgi.com>
 <20070827211003.GA10627@Krystal> <Pine.LNX.4.64.0708271421130.6566@schroedinger.engr.sgi.com>
 <20070827213845.GB9748@Krystal> <Pine.LNX.4.64.0708271510020.8783@schroedinger.engr.sgi.com>
 <20070827222715.GA16982@Krystal> <Pine.LNX.4.64.0708271811200.10344@schroedinger.engr.sgi.com>
 <20070904200429.GD8157@Krystal> <Pine.LNX.4.64.0709041344040.6376@schroedinger.engr.sgi.com>
 <20070905130612.GC11880@Krystal>
In-Reply-To: <20070905130612.GC11880@Krystal>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: Peter Zijlstra <peterz@infradead.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, mingo@redhat.com, linux-ia64@vger.kernel.org

On Wed, 5 Sep 2007, Mathieu Desnoyers wrote:

> Use local_enter/local_exit for protection in the fast path.

Sorry that it took some time to get back to this issue. KS interfered.

> @@ -1494,8 +1487,16 @@ new_slab:
>  		c->page = new;
>  		goto load_freelist;
>  	}
> -
> +	if (gfpflags & __GFP_WAIT) {
> +		local_nest_irq_enable();
> +		local_exit();
> +	}
>  	new = new_slab(s, gfpflags, node);
> +	if (gfpflags & __GFP_WAIT) {
> +		local_enter();
> +		local_nest_irq_disable();
> +	}
> +
>  	if (new) {
>  		c = get_cpu_slab(s, smp_processor_id());
>  		if (c->page) {

Hmmmm... Definitely an interesting change to move the interrupt 
enable/disable to __slab_alloc. But it looks like it is getting a bit 
messy. All my attempts ended also like this. Sigh.

> @@ -2026,8 +2032,11 @@ static struct kmem_cache_node *early_kme
>  
>  	BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
>  
> +	if (gfpflags & __GFP_WAIT)
> +		local_irq_enable();
>  	page = new_slab(kmalloc_caches, gfpflags, node);
> -
> +	if (gfpflags & __GFP_WAIT)
> +		local_irq_disable();
>  	BUG_ON(!page);
>  	if (page_to_nid(page) != node) {
>  		printk(KERN_ERR "SLUB: Unable to allocate memory from "

Hmmmm... Actually we could drop the irq disable / enable here since this 
is boot code. That would also allow the removal of the later 
local_irq_enable.

Good idea. I think I will do the moving of the interrupt enable/disable 
independently.

