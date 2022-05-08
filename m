From: Baolin Wang <baolin.wang@linux.alibaba.com>
Date: Sun, 08 May 2022 13:13:44 +0000
Subject: Re: [PATCH v2 2/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
Message-Id: <474b8548-4e17-a6e7-a0f7-8f248aabe462@linux.alibaba.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1ec8a987be1a5400e077260a300d0079564b1472.1652002221.git.baolin.wang@linux.alibaba.com>
 <202205081910.mStoC5rj-lkp@intel.com>
In-Reply-To: <202205081910.mStoC5rj-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <lkp@intel.com>, akpm@linux-foundation.org, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org
Cc: kbuild-all@lists.01.org, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org

Hi,

On 5/8/2022 8:01 PM, kernel test robot wrote:
> Hi Baolin,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on akpm-mm/mm-everything]
> [also build test ERROR on next-20220506]
> [cannot apply to hnaz-mm/master arm64/for-next/core linus/master v5.18-rc5]
> [If your patch is applied to the wrong git tree, kindly drop us a note.
> And when submitting patch, we suggest to use '--base' as documented in
> https://git-scm.com/docs/git-format-patch]
> 
> url:    https://github.com/intel-lab-lkp/linux/commits/Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220508-174036
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git mm-everything
> config: x86_64-randconfig-a013 (https://download.01.org/0day-ci/archive/20220508/202205081910.mStoC5rj-lkp@intel.com/config)
> compiler: gcc-11 (Debian 11.2.0-20) 11.2.0
> reproduce (this is a W=1 build):
>          # https://github.com/intel-lab-lkp/linux/commit/907981b27213707fdb2f8a24c107d6752a09a773
>          git remote add linux-review https://github.com/intel-lab-lkp/linux
>          git fetch --no-tags linux-review Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220508-174036
>          git checkout 907981b27213707fdb2f8a24c107d6752a09a773
>          # save the config file
>          mkdir build_dir && cp config build_dir/.config
>          make W=1 O=build_dir ARCH=x86_64 SHELL=/bin/bash
> 
> If you fix the issue, kindly add following tag as appropriate
> Reported-by: kernel test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>     mm/rmap.c: In function 'try_to_migrate_one':
>>> mm/rmap.c:1931:34: error: implicit declaration of function 'huge_ptep_clear_flush'; did you mean 'ptep_clear_flush'? [-Werror=implicit-function-declaration]
>      1931 |                         pteval = huge_ptep_clear_flush(vma, address, pvmw.pte);
>           |                                  ^~~~~~~~~~~~~~~~~~~~~
>           |                                  ptep_clear_flush
>>> mm/rmap.c:1931:34: error: incompatible types when assigning to type 'pte_t' from type 'int'
>>> mm/rmap.c:2023:41: error: implicit declaration of function 'set_huge_pte_at'; did you mean 'set_huge_swap_pte_at'? [-Werror=implicit-function-declaration]
>      2023 |                                         set_huge_pte_at(mm, address, pvmw.pte, pteval);
>           |                                         ^~~~~~~~~~~~~~~
>           |                                         set_huge_swap_pte_at
>     cc1: some warnings being treated as errors

Thanks for reporting. I think I should add some dummy functions in 
hugetlb.h file if the CONFIG_HUGETLB_PAGE is not selected. I can pass 
the building with below changes and your config file.

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 306d6ef..9f71043 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -1093,6 +1093,17 @@ static inline void set_huge_swap_pte_at(struct 
mm_struct *mm, unsigned long addr
                                         pte_t *ptep, pte_t pte, 
unsigned long sz)
  {
  }
+
+static inline pte_t huge_ptep_clear_flush(struct vm_area_struct *vma,
+                                         unsigned long addr, pte_t *ptep)
+{
+       return ptep_get(ptep);
+}
+
+static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long 
addr,
+                                  pte_t *ptep, pte_t pte)
+{
+}
  #endif /* CONFIG_HUGETLB_PAGE */
