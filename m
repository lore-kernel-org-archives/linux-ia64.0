From: William Lee Irwin III <wli@holomorphy.com>
Date: Thu, 02 Sep 2004 06:10:30 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902061030.GX5492@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Sep 01, 2004 at 08:15:10PM -0700, William Lee Irwin III wrote:
>> Okay, you're diving into node_alloc_mem_map() when you shouldn't be.

On Thu, Sep 02, 2004 at 03:36:59PM +1000, Ian Wienand wrote:
> OK, how about a patch like below for a start? node_alloc_mem_map()
> calls alloc_bootmem_node() unconditionally, whereas we have already
> setup a vmem map in arch/ia64/mm/contig.c:paging_init()

You don't thave CONFIG_DISCONTIGMEM set? Why are you bothering with
virtual mem_map if not? If the core helpers are insufficiently
lightweight in the CONFIG_DISCONTIGMEM=n case we are very well going
to have whatever sanction we need to repair it, as this is the common
case among end users of the most predominant hardware and architectures.


> === mm/page_alloc.c 1.234 vs edited ==> --- 1.234/mm/page_alloc.c       2004-08-27 16:59:59 +10:00
> +++ edited/mm/page_alloc.c      2004-09-02 15:21:27 +10:00
> @@ -1582,8 +1582,11 @@ void __init node_alloc_mem_map(struct pg
>  {
>         unsigned long size;
> 
> -       size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
> -       pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
> +       if (!pgdat->node_mem_map)
> +       {
> +               size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
> +               pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
> +       }
>  #ifndef CONFIG_DISCONTIGMEM
>         mem_map = contig_page_data.node_mem_map;
>  #endif
> === arch/ia64/mm/contig.c 1.6 vs edited ==> --- 1.6/arch/ia64/mm/contig.c   2004-08-24 19:08:33 +10:00
> +++ edited/arch/ia64/mm/contig.c        2004-09-02 15:33:35 +10:00
> @@ -284,7 +284,6 @@ paging_init (void)
>                 free_area_init_node(0, &contig_page_data, zones_size,
>                                     0, zholes_size);
> 
> -               mem_map = contig_page_data.node_mem_map;
>                 printk("Virtual mem_map starts at 0x%p\n", mem_map);
>         }
>  #else /* !CONFIG_VIRTUAL_MEM_MAP */

Only the second of these changes should be necessary; the first is to
all appearances lunacy; bootmem.c would panic() before returning NULL.
The big question here, is, of course, why on earth anyone thought it
was a good idea to set vmem_map to NULL immediately before calling
free_area_init_node() and thereby completely hose the pfn macros in so
doing right before callers are about to use them. Whoever's responsible
for this mess in arch/ia64/mm/contig.c deserves at least a token LART.


On Thu, Sep 02, 2004 at 03:36:59PM +1000, Ian Wienand wrote:
> It's either that, or in arch/ia64/mm/contig.c:paging_init() finding
> some way to set node_page_start_pfn (which will shortcut the test in
> node_alloc_mem_map()) by walking the vmem_map?
> With this applied, I no longer get the wrong address for the vmem_map
> e.g. I get
> Virtual mem_map starts at 0xa0007fffc7900000
> on boot which is what I expect.  But it still stops with the same
> problem :(
> Bad page state at free_hot_cold_page (in process 'swapper', page a0007fffc7918d08)
> flags:0x0000000000000000 mapping:0000000000000000 mapcount:1 count:0
> Backtrace:

Something is going wrong besides merely clobbbering the virtual mem_map,
as the changes above at least refer it to the correct virtual addresses
for the page structures. What you really have to address is making
pfn_to_page() produce correct results at this phase of bootstrapping.
Clobbering vmem_map immediately prior to calling free_area_init_node()
is now incorrect.


-- wli
