From: Christoph Lameter <cl@linux-foundation.org>
Date: Thu, 14 Jan 2010 22:01:36 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <alpine.DEB.2.00.1001141600040.20895@router.home>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com>
 <alpine.DEB.2.00.1001141457250.19915@router.home> <20100114212933.GK4545@ldl.fc.hp.com>
In-Reply-To: <20100114212933.GK4545@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

On Thu, 14 Jan 2010, Alex Chiang wrote:

> @@ -2100,6 +2100,7 @@ static void early_kmem_cache_node_alloc(gfp_t gfpflags, in
> t node)
>         BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
>
>         page = new_slab(kmalloc_caches, gfpflags, node);
> +       printk("page from new_slab() %#llx\n", page);
>
>         BUG_ON(!page);
>         if (page_to_nid(page) != node) {
>
> Memory: 66849344k/66910528k available (8033k code, 110720k reserved, 10805k data, 1984k init)
> page from new_slab() 0xa07fffffff900000
> page from new_slab() 0xa07fffffe39000e0
> SLUB: Unable to allocate memory from node 2
> SLUB: Allocating a useless per node structure in order to be able to continue
> SLUB: Genslabs, HWalign8, Order=0-3, MinObjects=0, CPUs, Nodes24
>
> [...]
>
> Unable to handle kernel paging request at virtual address a07ffffe5a7838a8

Garg. We did not hit the point before the crash.

Must be an insipient page_to_nid somewhere.

