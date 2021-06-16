From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 16 Jun 2021 14:23:32 +0000
Subject: Re: + mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t.patch
Message-Id: <87zgvpnbl7.fsf@linux.ibm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210615233808.hzjGO1gF2%akpm@linux-foundation.org>
 <202106162159.MurvDMy6-lkp@intel.com>
In-Reply-To: <202106162159.MurvDMy6-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <lkp@intel.com>, akpm@linux-foundation.org, linux-alpha@vger.kernel.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linux-riscv@lists.infradead.org
Cc: kbuild-all@lists.01.org

kernel test robot <lkp@intel.com> writes:

> Hi,
>
> I love your patch! Perhaps something to improve:
>
> [auto build test WARNING on powerpc/next]
> [also build test WARNING on tip/x86/mm asm-generic/master linus/master sparc/master v5.13-rc6 next-20210615]
> [cannot apply to sparc-next/master]
> [If your patch is applied to the wrong git tree, kindly drop us a note.
> And when submitting patch, we suggest to use '--base' as documented in
> https://git-scm.com/docs/git-format-patch]
>
> url:    https://github.com/0day-ci/linux/commits/akpm-linux-foundation-org/mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t-patch-added-to-mm-tree/20210616-161816
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/powerpc/linux.git next
> config: m68k-allmodconfig (attached as .config)
> compiler: m68k-linux-gcc (GCC) 9.3.0
> reproduce (this is a W=1 build):
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # https://github.com/0day-ci/linux/commit/2ccec57c1def84dab91722c14fd5907ed7423426
>         git remote add linux-review https://github.com/0day-ci/linux
>         git fetch --no-tags linux-review akpm-linux-foundation-org/mm-rename-pud_page_vaddr-to-pud_pgtable-and-make-it-return-pmd_t-patch-added-to-mm-tree/20210616-161816
>         git checkout 2ccec57c1def84dab91722c14fd5907ed7423426
>         # save the attached .config to linux build tree
>         COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-9.3.0 make.cross ARCH=m68k 
>
> If you fix the issue, kindly add following tag as appropriate
> Reported-by: kernel test robot <lkp@intel.com>
>
> All warnings (new ones prefixed by >>):
>
>    arch/m68k/mm/motorola.c: In function 'kernel_ptr_table':
>>> arch/m68k/mm/motorola.c:265:8: warning: assignment to 'long unsigned int' from 'pmd_t *' {aka 'struct <anonymous> *'} makes integer from pointer without a cast [-Wint-conversion]
>      265 |    pmd = pgd_page_vaddr(kernel_pg_dir[i]);
>          |        ^
>    arch/m68k/mm/motorola.c: At top level:
>    arch/m68k/mm/motorola.c:390:13: warning: no previous prototype for 'paging_init' [-Wmissing-prototypes]
>      390 | void __init paging_init(void)
>          |             ^~~~~~~~~~~
>
>
> vim +265 arch/m68k/mm/motorola.c
>
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  248  
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  249  static pmd_t * __init kernel_ptr_table(void)
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  250  {
> ef9285f69f0efb Peter Zijlstra     2020-01-31  251  	if (!last_pmd_table) {
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  252  		unsigned long pmd, last;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  253  		int i;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  254  
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  255  		/* Find the last ptr table that was used in head.S and
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  256  		 * reuse the remaining space in that page for further
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  257  		 * ptr tables.
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  258  		 */
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  259  		last = (unsigned long)kernel_pg_dir;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  260  		for (i = 0; i < PTRS_PER_PGD; i++) {
> 60e50f34b13e9e Mike Rapoport      2019-12-04  261  			pud_t *pud = (pud_t *)(&kernel_pg_dir[i]);
> 60e50f34b13e9e Mike Rapoport      2019-12-04  262  
> 60e50f34b13e9e Mike Rapoport      2019-12-04  263  			if (!pud_present(*pud))
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  264  				continue;
> 60e50f34b13e9e Mike Rapoport      2019-12-04 @265  			pmd = pgd_page_vaddr(kernel_pg_dir[i]);
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  266  			if (pmd > last)
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  267  				last = pmd;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  268  		}
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  269  
> ef9285f69f0efb Peter Zijlstra     2020-01-31  270  		last_pmd_table = (pmd_t *)last;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  271  #ifdef DEBUG
> ef9285f69f0efb Peter Zijlstra     2020-01-31  272  		printk("kernel_ptr_init: %p\n", last_pmd_table);
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  273  #endif
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  274  	}
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  275  
> ef9285f69f0efb Peter Zijlstra     2020-01-31  276  	last_pmd_table += PTRS_PER_PMD;
> 41f1bf37a63ecd Geert Uytterhoeven 2020-08-26  277  	if (PAGE_ALIGNED(last_pmd_table)) {
> 7e158826564fbb Geert Uytterhoeven 2020-08-26  278  		last_pmd_table = memblock_alloc_low(PAGE_SIZE, PAGE_SIZE);
> ef9285f69f0efb Peter Zijlstra     2020-01-31  279  		if (!last_pmd_table)
> 8a7f97b902f4fb Mike Rapoport      2019-03-11  280  			panic("%s: Failed to allocate %lu bytes align=%lx\n",
> 8a7f97b902f4fb Mike Rapoport      2019-03-11  281  			      __func__, PAGE_SIZE, PAGE_SIZE);
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  282  
> ef9285f69f0efb Peter Zijlstra     2020-01-31  283  		clear_page(last_pmd_table);
> ef9285f69f0efb Peter Zijlstra     2020-01-31  284  		mmu_page_ctor(last_pmd_table);
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  285  	}
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  286  
> ef9285f69f0efb Peter Zijlstra     2020-01-31  287  	return last_pmd_table;
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  288  }
> ^1da177e4c3f41 Linus Torvalds     2005-04-16  289  
>

We may want to fixup pgd_page_vaddr correctly later. pgd_page_vaddr() gets
cast to different pointer types based on architecture. But for now this
should work? This ensure we keep the pgd_page_vaddr() same as before. 

diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
index 982de5102fc1..2f1d0aad645c 100644
--- a/include/asm-generic/pgtable-nop4d.h
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -42,7 +42,7 @@ static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)
 #define __p4d(x)				((p4d_t) { __pgd(x) })
 
 #define pgd_page(pgd)				(p4d_page((p4d_t){ pgd }))
-#define pgd_page_vaddr(pgd)			(p4d_pgtable((p4d_t){ pgd }))
+#define pgd_page_vaddr(pgd)			((unsigned long)(p4d_pgtable((p4d_t){ pgd })))
 
 /*
  * allocating and freeing a p4d is trivial: the 1-entry p4d is
