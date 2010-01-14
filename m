From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 14 Jan 2010 20:58:52 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001141457250.19915@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com>
In-Reply-To: <20100114203221.GI4545@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Jan 2010, Alex Chiang wrote:

> coffee0:/usr/src/linux-2.6 # addr2line 0xa0000001001add60 -e vmlinux
> /usr/src/linux-2.6/include/linux/mm.h:543
>
>  538 #ifdef NODE_NOT_IN_PAGE_FLAGS
>  539 extern int page_to_nid(struct page *page);
>  540 #else
>  541 static inline int page_to_nid(struct page *page)
>  542 {
>  543         return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
>  544 }
>  545 #endif

That may mean that early_kmem_node_alloc gets a screwy page number from
the page allocator? ????

Can you print the address of page returned from new_slab() in
early_kmem_cache_node_alloc()?


