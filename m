From: Andrew Morton <akpm@osdl.org>
Date: Thu, 23 Sep 2004 06:23:30 +0000
Subject: Re: 2.6.9-rc2-mm2
Message-Id: <20040922232330.2cec2a08.akpm@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <16722.7004.928367.771460@wombat.chubb.wattle.id.au>
	<200409222043.01098.jbarnes@engr.sgi.com>
In-Reply-To: <200409222043.01098.jbarnes@engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jesse Barnes <jbarnes@engr.sgi.com>
Cc: peterc@gelato.unsw.edu.au, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>

Jesse Barnes <jbarnes@engr.sgi.com> wrote:
>
> On Wednesday, September 22, 2004 8:39 pm, Peter Chubb wrote:
> > >>>>> "Jesse" = Jesse Barnes <jbarnes@engr.sgi.com> writes:
> >
> > Jesse> On Wednesday, September 22, 2004 4:12 pm, Andrew Morton wrote:
> > >> - This kernel doesn't work on ia64 (instant reboot).  But neither
> > >> does 2.6.9-rc2, nor current Linus -bk.  Is it just me?
> >
> > Jesse> I certainly hope so.  Current bk works on my 2p Altix, and iirc
> > Jesse> 2.6.9-rc2 worked as well.  I'm trying 2.6.9-rc2-mm2 right now.
> > Jesse> I haven't tried generic_defconfig yet either, maybe that's it?
> >
> > It no longer works on ZX.  Don't know why.
> 
> Maybe this is another, more severe instance of the problem James reported last 
> week that was worked around by enabling CONFIG_DISCONTIGMEM.
> 

It looks like Tony is wearing the BPB.  The below patch from September 8 is
what causes my non-discontigmem virtual-mem-map ia64 box instantly reboot.
Reverting it makes things happy.


--- b/include/asm-ia64/page.h	2004-09-08 10:23:43 -07:00
+++ b/include/asm-ia64/page.h	2004-09-08 16:12:10 -07:00
@@ -86,13 +86,14 @@
 #ifndef CONFIG_DISCONTIGMEM
 # ifdef CONFIG_VIRTUAL_MEM_MAP
 extern struct page *vmem_map;
-#  define pfn_valid(pfn)       (((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#  define page_to_pfn(page)    ((unsigned long) (page - vmem_map))
-#  define pfn_to_page(pfn)     (vmem_map + (pfn))
+#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+#  define page_to_pfn(page)	((unsigned long) (page - vmem_map))
+#  define pfn_to_page(pfn)	(vmem_map + (pfn))
+# else
+#  define pfn_valid(pfn)	(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
+#  define page_to_pfn(page)	((unsigned long) (page - mem_map))
+#  define pfn_to_page(pfn)	(mem_map + (pfn))
 # endif
-#define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
-#define page_to_pfn(page)	((unsigned long) (page - mem_map))
-#define pfn_to_page(pfn)	(mem_map + (pfn))
 #endif /* CONFIG_DISCONTIGMEM */
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)



Process question: how is it possible that the ia64 tree could have been
this dead for this long?
