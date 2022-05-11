From: kernel test robot <lkp@intel.com>
Date: Wed, 11 May 2022 01:19:17 +0000
Subject: Re: [PATCH v3 2/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
Message-Id: <202205110919.CWIcIqYE-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <ea5abf529f0997b5430961012bfda6166c1efc8c.1652147571.git.baolin.wang@linux.alibaba.com>
In-Reply-To: <ea5abf529f0997b5430961012bfda6166c1efc8c.1652147571.git.baolin.wang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Baolin Wang <baolin.wang@linux.alibaba.com>, akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org
Cc: kbuild-all@lists.01.org, songmuchun@bytedance.com, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, baolin.wang@linux.alibaba.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

Hi Baolin,

I love your patch! Yet something to improve:

[auto build test ERROR on akpm-mm/mm-everything]
[cannot apply to hnaz-mm/master arm64/for-next/core linus/master v5.18-rc6]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/intel-lab-lkp/linux/commits/Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220510-114753
base:   https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git mm-everything
config: h8300-buildonly-randconfig-r001-20220509 (https://download.01.org/0day-ci/archive/20220511/202205110919.CWIcIqYE-lkp@intel.com/config)
compiler: h8300-linux-gcc (GCC) 11.3.0
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/b666792b4c5f9774c350977ff88837bafc36365a
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220510-114753
        git checkout b666792b4c5f9774c350977ff88837bafc36365a
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-11.3.0 make.cross W=1 O=build_dir ARCH=h8300 SHELL=/bin/bash

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   In file included from kernel/fork.c:51:
   include/linux/hugetlb.h: In function 'huge_ptep_clear_flush':
>> include/linux/hugetlb.h:1100:16: error: implicit declaration of function 'ptep_get' [-Werror=implicit-function-declaration]
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~
>> include/linux/hugetlb.h:1100:16: error: incompatible types when returning type 'int' but 'pte_t' was expected
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~~~~~~~
   kernel/fork.c: At top level:
   kernel/fork.c:162:13: warning: no previous prototype for 'arch_release_task_struct' [-Wmissing-prototypes]
     162 | void __weak arch_release_task_struct(struct task_struct *tsk)
         |             ^~~~~~~~~~~~~~~~~~~~~~~~
   kernel/fork.c:847:20: warning: no previous prototype for 'arch_task_cache_init' [-Wmissing-prototypes]
     847 | void __init __weak arch_task_cache_init(void) { }
         |                    ^~~~~~~~~~~~~~~~~~~~
   kernel/fork.c:942:12: warning: no previous prototype for 'arch_dup_task_struct' [-Wmissing-prototypes]
     942 | int __weak arch_dup_task_struct(struct task_struct *dst,
         |            ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors
--
   In file included from kernel/sysctl.c:46:
   include/linux/hugetlb.h: In function 'huge_ptep_clear_flush':
>> include/linux/hugetlb.h:1100:16: error: implicit declaration of function 'ptep_get' [-Werror=implicit-function-declaration]
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~
>> include/linux/hugetlb.h:1100:16: error: incompatible types when returning type 'int' but 'pte_t' was expected
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~~~~~~~
   cc1: some warnings being treated as errors
--
   In file included from include/linux/migrate.h:8,
                    from mm/page_alloc.c:62:
   include/linux/hugetlb.h: In function 'huge_ptep_clear_flush':
>> include/linux/hugetlb.h:1100:16: error: implicit declaration of function 'ptep_get' [-Werror=implicit-function-declaration]
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~
>> include/linux/hugetlb.h:1100:16: error: incompatible types when returning type 'int' but 'pte_t' was expected
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~~~~~~~
   In file included from include/asm-generic/bug.h:5,
                    from arch/h8300/include/asm/bug.h:8,
                    from include/linux/bug.h:5,
                    from include/linux/mmdebug.h:5,
                    from include/linux/mm.h:6,
                    from mm/page_alloc.c:19:
   mm/page_alloc.c: In function 'free_pages':
   include/asm-generic/page.h:89:51: warning: ordered comparison of pointer with null pointer [-Wextra]
      89 | #define virt_addr_valid(kaddr)  (((void *)(kaddr) >= (void *)PAGE_OFFSET) && \
         |                                                   ^~
   include/linux/compiler.h:78:45: note: in definition of macro 'unlikely'
      78 | # define unlikely(x)    __builtin_expect(!!(x), 0)
         |                                             ^
   include/linux/mmdebug.h:17:25: note: in expansion of macro 'BUG_ON'
      17 | #define VM_BUG_ON(cond) BUG_ON(cond)
         |                         ^~~~~~
   mm/page_alloc.c:5489:17: note: in expansion of macro 'VM_BUG_ON'
    5489 |                 VM_BUG_ON(!virt_addr_valid((void *)addr));
         |                 ^~~~~~~~~
   mm/page_alloc.c:5489:28: note: in expansion of macro 'virt_addr_valid'
    5489 |                 VM_BUG_ON(!virt_addr_valid((void *)addr));
         |                            ^~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors
--
   In file included from fs/io_uring.c:71:
   include/linux/hugetlb.h: In function 'huge_ptep_clear_flush':
>> include/linux/hugetlb.h:1100:16: error: implicit declaration of function 'ptep_get' [-Werror=implicit-function-declaration]
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~
>> include/linux/hugetlb.h:1100:16: error: incompatible types when returning type 'int' but 'pte_t' was expected
    1100 |         return ptep_get(ptep);
         |                ^~~~~~~~~~~~~~
   fs/io_uring.c: In function '__io_submit_flush_completions':
   fs/io_uring.c:2660:40: warning: variable 'prev' set but not used [-Wunused-but-set-variable]
    2660 |         struct io_wq_work_node *node, *prev;
         |                                        ^~~~
   cc1: some warnings being treated as errors


vim +/ptep_get +1100 include/linux/hugetlb.h

  1096	
  1097	static inline pte_t huge_ptep_clear_flush(struct vm_area_struct *vma,
  1098						  unsigned long addr, pte_t *ptep)
  1099	{
> 1100		return ptep_get(ptep);
  1101	}
  1102	

-- 
0-DAY CI Kernel Test Service
https://01.org/lkp
