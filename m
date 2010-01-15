From: Christoph Lameter <cl@linux-foundation.org>
Date: Fri, 15 Jan 2010 23:32:45 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001151730350.10558@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com>  <alpine.DEB.2.00.1001151358110.6590@router.home> <1263587721.20615.255.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1263587721.20615.255.camel@useless.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Alex Chiang <achiang@hp.com>, penberg@cs.helsinki.fi, linux-ia64@vger.kernel.org, linux-mm@kvack.org


On Fri, 15 Jan 2010, Lee Schermerhorn wrote:

> > The following patch makes init_kmem_cache_nodes assume 0
> > for statically allocated kmem_cache structures even after
> > boot is complete.
>
> I believe that on Alex's platform, the kernel will get loaded into "node
> 2", the hardware interleaved pseudo-node, because it's located at phys
> 0..., and has sufficient space.  So, this might not work here.

Hmm. thats gets us into some strange issues.

> > Index: linux-2.6/mm/slub.c
> > =================================> > --- linux-2.6.orig/mm/slub.c	2010-01-15 14:02:54.000000000 -0600
> > +++ linux-2.6/mm/slub.c	2010-01-15 14:04:47.000000000 -0600
> > @@ -2176,7 +2176,8 @@ static int init_kmem_cache_nodes(struct
> >  	int node;
> >  	int local_node;
> >
> > -	if (slab_state >= UP)
> > +	if (slab_state >= UP &&
>
>
> >  s < kmalloc_caches &&
> > +			s > kmalloc_caches + KMALLOC_CACHES)
>
> ??? can this ever be so?  for positive KMALLOC_CACHES, I mean...

An allocated kmem_cache structure is definitely not in the range of the
kmalloc_caches array. This is basically checking if s is pointing to the
static kmalloc array.
