From: William Lee Irwin III <wli@holomorphy.com>
Date: Fri, 03 Sep 2004 02:31:06 +0000
Subject: Re: Problem with no mem_map arg to init functions change?
Message-Id: <20040903023106.GA3106@holomorphy.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040902053659.GG21873@cse.unsw.EDU.AU>
In-Reply-To: <20040902053659.GG21873@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Fri, Sep 03, 2004 at 12:19:04PM +1000, Ian Wienand wrote:
> Thanks to all the explanations I think I'm starting to understand all
> these options; I'll try to document things a little more fully in our
> WiKi soon (http://www.gelato.unsw.edu.au/IA64wiki if you've never seen
> it).
> I applied the following trivial patch and things seem to work now.
> This way, pfn_to_page(0) returns 0xa0007fff... (the virtual mem map)
> which I belive to be correct.

Okay, this is a clear regression caused by a core patch breaking arches.
I think we should push for rapid merging with arch maintainer approval.
The following patch, which I took no part in writing, but only advised
Ian Wienand about what could be going wrong, is under consideration. His
announcement is included verbatim following my signature.

As I participated in the arch sweeps for the mem_map initialization
patches and participated in the review of the patch and so on, please
add Signed-off-by: William Irwin <wli@holomorphy.com>


-- wli

On Thu, Sep 02, 2004 at 11:42:43AM -0700, William Lee Irwin III wrote:
> This usage is valid too, of course. In this case we either need to adjust
> include/asm-ia64/page.h for virtual mem_map

Thanks to all the explanations I think I'm starting to understand all
these options; I'll try to document things a little more fully in our
WiKi soon (http://www.gelato.unsw.edu.au/IA64wiki if you've never seen
it).

I applied the following trivial patch and things seem to work now.
This way, pfn_to_page(0) returns 0xa0007fff... (the virtual mem map)
which I belive to be correct.

=== include/asm-ia64/page.h 1.26 vs edited ==--- 1.26/include/asm-ia64/page.h        2004-07-27 15:26:50 +10:00
+++ edited/include/asm-ia64/page.h      2004-09-03 12:04:37 +10:00
@@ -84,6 +84,13 @@
 #endif

 #ifndef CONFIG_DISCONTIGMEM
+# ifdef CONFIG_VIRTUAL_MEM_MAP
+extern struct page *vmem_map;
+#  define pfn_valid(pfn)       (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+#  define page_to_pfn(page)    ((unsigned long) (page - vmem_map))
+#  define pfn_to_page(pfn)     (vmem_map + (pfn))
+# endif
+#else /* !CONFIG_VIRTUAL_MEM_MAP */
 #define pfn_valid(pfn)         (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 #define page_to_pfn(page)      ((unsigned long) (page - mem_map))
 #define pfn_to_page(pfn)       (mem_map + (pfn))

-i
