From: Ian Wienand <ianw@gelato.unsw.edu.au>
Date: Thu, 02 Sep 2004 05:36:59 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="SNIs70sCzqvszXB4"
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org


--SNIs70sCzqvszXB4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Sep 01, 2004 at 08:15:10PM -0700, William Lee Irwin III wrote:
> Okay, you're diving into node_alloc_mem_map() when you shouldn't be.

OK, how about a patch like below for a start? node_alloc_mem_map()
calls alloc_bootmem_node() unconditionally, whereas we have already
setup a vmem map in arch/ia64/mm/contig.c:paging_init()

===== mm/page_alloc.c 1.234 vs edited =====
--- 1.234/mm/page_alloc.c       2004-08-27 16:59:59 +10:00
+++ edited/mm/page_alloc.c      2004-09-02 15:21:27 +10:00
@@ -1582,8 +1582,11 @@ void __init node_alloc_mem_map(struct pg
 {
        unsigned long size;

-       size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
-       pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
+       if (!pgdat->node_mem_map)
+       {
+               size = (pgdat->node_spanned_pages + 1) * sizeof(struct page);
+               pgdat->node_mem_map = alloc_bootmem_node(pgdat, size);
+       }
 #ifndef CONFIG_DISCONTIGMEM
        mem_map = contig_page_data.node_mem_map;
 #endif
===== arch/ia64/mm/contig.c 1.6 vs edited =====
--- 1.6/arch/ia64/mm/contig.c   2004-08-24 19:08:33 +10:00
+++ edited/arch/ia64/mm/contig.c        2004-09-02 15:33:35 +10:00
@@ -284,7 +284,6 @@ paging_init (void)
                free_area_init_node(0, &contig_page_data, zones_size,
                                    0, zholes_size);

-               mem_map = contig_page_data.node_mem_map;
                printk("Virtual mem_map starts at 0x%p\n", mem_map);
        }
 #else /* !CONFIG_VIRTUAL_MEM_MAP */

It's either that, or in arch/ia64/mm/contig.c:paging_init() finding
some way to set node_page_start_pfn (which will shortcut the test in
node_alloc_mem_map()) by walking the vmem_map?

With this applied, I no longer get the wrong address for the vmem_map
e.g. I get

Virtual mem_map starts at 0xa0007fffc7900000

on boot which is what I expect.  But it still stops with the same
problem :(

Bad page state at free_hot_cold_page (in process 'swapper', page a0007fffc7918d08)
flags:0x0000000000000000 mapping:0000000000000000 mapcount:1 count:0
Backtrace:

-i


--SNIs70sCzqvszXB4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBNrF6WDlSU/gp6ecRAtJnAKCSYWRiKSOePAhouHK5hoE4ddVmqgCfctzD
25bWmbI9KG9mc7jmrDV/bOc=
=b5s5
-----END PGP SIGNATURE-----

--SNIs70sCzqvszXB4--
