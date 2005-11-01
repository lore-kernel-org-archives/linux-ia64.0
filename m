From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Tue, 01 Nov 2005 00:31:57 +0000
Subject: RE: Recent SPARSEMEM and DISCONTIG changes break some builds
Message-Id: <17254.46973.747146.188361@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
In-Reply-To: <17253.37207.664571.236714@wombat.chubb.wattle.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Tony" = Tony Luck <Luck> writes:

Tony> Peter Chubb wrote:
>> Is it intended that CONFIG_SPARSEMEM and CONFIG_DISCONTIGMEM be
>> usable without CONFIG_NUMA?
>> 
>> Currently (2.6.14+GIT as of 31 October) -- compiling with
>> CONFIG_SPARSEMEM gives undefined ref to pfn_to_node().  --
>> compiling with CONFIG_DISCONTIGMEM gives many errors
>> linux-2.6-import/arch/ia64/mm/discontig.c:326: error: dereferencing
>> pointer to incomplete type when referencing struct ia64_node_data

Tony> All of my standard configs build ... the only one that fails is
Tony> arch/ia64/configs/gensparse_defconfig which gets a link error
Tony> for an undefined reference to pfn_to_kaddr in
Tony> sparse_add_one_section.

I see many other problems when compiling for a large-memory ZX1
configuration:  I do:
		make zx1_defconfig
then edit .config to turn SMP OFF  and DISCONTIG ON
then
		make oldconfig
		make


Here's the sparsemem fix, BTWL:

Index: linux-2.6-import/include/asm-ia64/page.h
=================================--- linux-2.6-import.orig/include/asm-ia64/page.h	2005-10-31 13:34:33.864315350 +1100
+++ linux-2.6-import/include/asm-ia64/page.h	2005-11-01 10:49:47.817687789 +1100
@@ -110,20 +110,21 @@ extern int ia64_pfn_valid (unsigned long
 # define pfn_valid(pfn)		(((pfn) < max_mapnr) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - mem_map))
 # define pfn_to_page(pfn)	(mem_map + (pfn))
 #elif defined(CONFIG_DISCONTIGMEM)
 extern struct page *vmem_map;
 extern unsigned long max_low_pfn;
 # define pfn_valid(pfn)		(((pfn) < max_low_pfn) && ia64_pfn_valid(pfn))
 # define page_to_pfn(page)	((unsigned long) (page - vmem_map))
 # define pfn_to_page(pfn)	(vmem_map + (pfn))
 #endif
+#define pfn_to_kaddr(pfn) 	__va((pfn) << PAGE_SHIFT)
 
 #define page_to_phys(page)	(page_to_pfn(page) << PAGE_SHIFT)
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
 
 typedef union ia64_va {
 	struct {
 		unsigned long off : 61;		/* intra-region offset */
 		unsigned long reg :  3;		/* region number */
 	} f;
 	unsigned long l;



-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
