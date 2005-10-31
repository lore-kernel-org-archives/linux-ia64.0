From: Bob Picco <bob.picco@hp.com>
Date: Mon, 31 Oct 2005 18:25:25 +0000
Subject: Re: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <20051031182525.GH6019@localhost.localdomain>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

luck wrote:	[Mon Oct 31 2005, 12:45:42PM EST]
> Peter Chubb wrote:
> >Is it intended that CONFIG_SPARSEMEM and CONFIG_DISCONTIGMEM be usable
> >without CONFIG_NUMA?
> >
> >Currently (2.6.14+GIT as of 31 October) 
> >	  -- compiling with CONFIG_SPARSEMEM gives undefined ref to
> >	     pfn_to_node().
> >	  -- compiling with CONFIG_DISCONTIGMEM gives many errors
> >	     linux-2.6-import/arch/ia64/mm/discontig.c:326: error: dereferencing
> >	     pointer to incomplete type when referencing struct
> >	     ia64_node_data 
> 
> All of my standard configs build ... the only one that
> fails is arch/ia64/configs/gensparse_defconfig which gets
> a link error for an undefined reference to pfn_to_kaddr in
> sparse_add_one_section.
> 
> -Tonh
> -
Tony,

Your build must be against -mm because pfn_to_kaddr shouldn't be required
in 2.6.14.  The patch below will fix this.

My only objection to pfn_to_kaddr, which was introduced for HotPlug memory,
is that all arches have an identical implementation. I haven't had a chance
to pursue why yet.  There is probably some arch issue I'm unaware of.

bob


Signed-off-by: Bob Picco <bob.picco@hp.com>

 include/asm-ia64/page.h |    1 +
 1 files changed, 1 insertion(+)

Index: linux-2.6.14-rc5-mm1/include/asm-ia64/page.h
=================================--- linux-2.6.14-rc5-mm1.orig/include/asm-ia64/page.h	2005-10-24 14:38:36.000000000 -0400
+++ linux-2.6.14-rc5-mm1/include/asm-ia64/page.h	2005-10-31 13:03:40.000000000 -0500
@@ -120,6 +120,7 @@ extern unsigned long max_low_pfn;
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
+#define pfn_to_kaddr(pfn)	__va((pfn) << PAGE_SHIFT)
 
 typedef union ia64_va {
 	struct {

