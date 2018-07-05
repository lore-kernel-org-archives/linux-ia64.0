From: kbuild test robot <lkp@intel.com>
Date: Thu, 05 Jul 2018 09:39:47 +0000
Subject: Re: [PATCH v3 08/11] hugetlb: Introduce generic version of prepare_hugepage_range
Message-Id: <201807051714.BBlsWblH%fengguang.wu@intel.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="BOKacYhQ+x31HxR3"
List-Id: <linux-ia64.vger.kernel.org>
References: <20180705051640.790-9-alex@ghiti.fr>
In-Reply-To: <20180705051640.790-9-alex@ghiti.fr>
To: linux-ia64@vger.kernel.org


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Alexandre,

Thank you for the patch! Perhaps something to improve:

[auto build test WARNING on linus/master]
[also build test WARNING on v4.18-rc3 next-20180704]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Alexandre-Ghiti/hugetlb-Factorize-hugetlb-architecture-primitives/20180705-135909
config: powerpc-mpc8540_ads_defconfig (attached as .config)
compiler: powerpc-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=powerpc 

All warnings (new ones prefixed by >>):

   In file included from arch/powerpc/kernel/setup-common.c:37:0:
   include/linux/hugetlb.h:191:65: error: expected identifier or '(' before '{' token
    #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
                                                                    ^
   include/asm-generic/hugetlb.h:44:20: note: in expansion of macro 'hugetlb_free_pgd_range'
    static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
                       ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/hugetlb.h:187:50: error: expected identifier or '(' before '-' token
    #define prepare_hugepage_range(file, addr, len) (-EINVAL)
                                                     ^
>> include/asm-generic/hugetlb.h:91:19: note: in expansion of macro 'prepare_hugepage_range'
    static inline int prepare_hugepage_range(struct file *file,
                      ^~~~~~~~~~~~~~~~~~~~~~

vim +/prepare_hugepage_range +91 include/asm-generic/hugetlb.h

    42	
    43	#ifndef __HAVE_ARCH_HUGETLB_FREE_PGD_RANGE
  > 44	static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
    45			unsigned long addr, unsigned long end,
    46			unsigned long floor, unsigned long ceiling)
    47	{
    48		free_pgd_range(tlb, addr, end, floor, ceiling);
    49	}
    50	#endif
    51	
    52	#ifndef __HAVE_ARCH_HUGE_SET_HUGE_PTE_AT
    53	static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
    54			pte_t *ptep, pte_t pte)
    55	{
    56		set_pte_at(mm, addr, ptep, pte);
    57	}
    58	#endif
    59	
    60	#ifndef __HAVE_ARCH_HUGE_PTEP_GET_AND_CLEAR
    61	static inline pte_t huge_ptep_get_and_clear(struct mm_struct *mm,
    62			unsigned long addr, pte_t *ptep)
    63	{
    64		return ptep_get_and_clear(mm, addr, ptep);
    65	}
    66	#endif
    67	
    68	#ifndef __HAVE_ARCH_HUGE_PTEP_CLEAR_FLUSH
    69	static inline void huge_ptep_clear_flush(struct vm_area_struct *vma,
    70			unsigned long addr, pte_t *ptep)
    71	{
    72		ptep_clear_flush(vma, addr, ptep);
    73	}
    74	#endif
    75	
    76	#ifndef __HAVE_ARCH_HUGE_PTE_NONE
    77	static inline int huge_pte_none(pte_t pte)
    78	{
    79		return pte_none(pte);
    80	}
    81	#endif
    82	
    83	#ifndef __HAVE_ARCH_HUGE_PTE_WRPROTECT
    84	static inline pte_t huge_pte_wrprotect(pte_t pte)
    85	{
    86		return pte_wrprotect(pte);
    87	}
    88	#endif
    89	
    90	#ifndef __HAVE_ARCH_PREPARE_HUGEPAGE_RANGE
  > 91	static inline int prepare_hugepage_range(struct file *file,
    92			unsigned long addr, unsigned long len)
    93	{
    94		struct hstate *h = hstate_file(file);
    95	
    96		if (len & ~huge_page_mask(h))
    97			return -EINVAL;
    98		if (addr & ~huge_page_mask(h))
    99			return -EINVAL;
   100	
   101		return 0;
   102	}
   103	#endif
   104	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--BOKacYhQ+x31HxR3
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
pBxW4BnkQPk/jjxRWmCmAAA=

--BOKacYhQ+x31HxR3--
