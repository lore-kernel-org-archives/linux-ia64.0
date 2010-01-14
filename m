From: Alex Chiang <achiang@hp.com>
Date: Thu, 14 Jan 2010 21:29:33 +0000
Subject: Re: SLUB ia64 linux-next crash bisected to 756dee75
Message-Id: <20100114212933.GK4545@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20100113002923.GF2985@ldl.fc.hp.com> <alpine.DEB.2.00.1001140917110.14164@router.home> <20100114182214.GB4545@ldl.fc.hp.com> <84144f021001141117o6271244cmbe9ba790f9616b2c@mail.gmail.com> <20100114203221.GI4545@ldl.fc.hp.com> <alpine.DEB.2.00.1001141457250.19915@router.home>
In-Reply-To: <alpine.DEB.2.00.1001141457250.19915@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-ia64@vger.kernel.org, linux-mm@kvack.org

* Christoph Lameter <cl@linux-foundation.org>:
> On Thu, 14 Jan 2010, Alex Chiang wrote:
> 
> > coffee0:/usr/src/linux-2.6 # addr2line 0xa0000001001add60 -e vmlinux
> > /usr/src/linux-2.6/include/linux/mm.h:543
> >
> >  538 #ifdef NODE_NOT_IN_PAGE_FLAGS
> >  539 extern int page_to_nid(struct page *page);
> >  540 #else
> >  541 static inline int page_to_nid(struct page *page)
> >  542 {
> >  543         return (page->flags >> NODES_PGSHIFT) & NODES_MASK;
> >  544 }
> >  545 #endif
> 
> That may mean that early_kmem_node_alloc gets a screwy page number from
> the page allocator? ????
> 
> Can you print the address of page returned from new_slab() in
> early_kmem_cache_node_alloc()?

diff --git a/mm/slub.c b/mm/slub.c
index 9e86e6b..2909cc4 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2062,7 +2062,7 @@ init_kmem_cache_node(struct kmem_cache_node *n, struct kme
m_cache *s)
 #endif
 }
 
-static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[SLUB_PAGE_SHIFT]);
+static DEFINE_PER_CPU(struct kmem_cache_cpu, kmalloc_percpu[KMALLOC_CACHES]);
 
 static inline int alloc_kmem_cache_cpus(struct kmem_cache *s, gfp_t flags)
 {
@@ -2100,6 +2100,7 @@ static void early_kmem_cache_node_alloc(gfp_t gfpflags, in
t node)
        BUG_ON(kmalloc_caches->size < sizeof(struct kmem_cache_node));
 
        page = new_slab(kmalloc_caches, gfpflags, node);
+       printk("page from new_slab() %#llx\n", page);
 
        BUG_ON(!page);
        if (page_to_nid(page) != node) {

Memory: 66849344k/66910528k available (8033k code, 110720k reserved, 10805k data, 1984k init)
page from new_slab() 0xa07fffffff900000
page from new_slab() 0xa07fffffe39000e0
SLUB: Unable to allocate memory from node 2
SLUB: Allocating a useless per node structure in order to be able to continue
SLUB: Genslabs, HWalign8, Order=0-3, MinObjects=0, CPUs, Nodes24

[...]

Unable to handle kernel paging request at virtual address a07ffffe5a7838a8
modprobe[6043]: Oops 8813272891392 [1]
Modules linked in: sr_mod(+) sg container(+) button usbhid ohci_hcd ehci_hcd usbcore fan thermal processor thermal_sys

Pid: 6043, CPU 9, comm:             modprobe
psr : 0000101008526010 ifs : 8000000000000b1d ip  : [<a0000001001add60>]    Not tainted (2.6.33-rc3-next-20100111-dirty)
ip is at kmem_cache_open+0x420/0xb40

