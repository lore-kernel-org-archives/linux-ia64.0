From: Alex Chiang <achiang@hp.com>
Date: Fri, 22 Jan 2010 00:15:34 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <20100122001534.GB30417@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <alpine.DEB.2.00.1001151730350.10558@router.home> <alpine.DEB.2.00.1001191252370.25101@router.home> <20100119200228.GE11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191427370.26683@router.home> <20100119212935.GG11010@ldl.fc.hp.com> <alpine.DEB.2.00.1001191545170.26683@router.home> <20100121214749.GJ17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211643020.20071@router.home> <20100121230551.GO17684@ldl.fc.hp.com> <alpine.DEB.2.00.1001211737360.20719@router.home>
In-Reply-To: <alpine.DEB.2.00.1001211737360.20719@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

* Christoph Lameter <cl@linux-foundation.org>:
> On Thu, 21 Jan 2010, Alex Chiang wrote:
> 
> > > Looks like percpu data is corrupted. One of my earlier fixes dimensioned
> > > the kmem_cache_cpu array correctly. That is missing here.
> >
> > Ah, that was pilot error on my part. I didn't realize that the
> > second patch you sent was to be in combination with the first.
> > Sorry about that.
> 
> Difficult since I also did not track how this belonged together. Sorry.

No prob.

Replying and cc'ing so akpm sees this as our final answer. :)

/ac

> 
> 
> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: [SLUB] dma kmalloc handling fixes
> 
> 1. We need kmalloc_percpu for all of the now extended kmalloc caches
>    array not just for each shift value.
> 
> 2. init_kmem_cache_nodes() must assume node 0 locality for statically
>    allocated dma kmem_cache structures even after boot is complete.
> 
> Reported-and-tested-by: Alex Chiang <achiang@hp.com>
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
> 
> ---
>  mm/slub.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/mm/slub.c
> =================================> --- linux-2.6.orig/mm/slub.c	2010-01-21 16:39:26.000000000 -0600
> +++ linux-2.6/mm/slub.c	2010-01-21 16:40:35.000000000 -0600
> @@ -2086,7 +2086,7 @@ init_kmem_cache_node(struct kmem_cache_n
>  #endif
>  }
> 
> -static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
> +static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
> 
>  static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
>  {
> @@ -2176,7 +2176,8 @@ static int init_kmem_cache_nodes(struct
>  	int node;
>  	int local_node;
> 
> -	if (slab_state >= UP)
> +	if (slab_state >= UP && (s < kmalloc_caches ||
> +			s > kmalloc_caches + KMALLOC_CACHES))
>  		local_node = page_to_nid(virt_to_page(s));
>  	else
>  		local_node = 0;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
