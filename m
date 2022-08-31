From: Mike Kravetz <mike.kravetz@oracle.com>
Date: Wed, 31 Aug 2022 20:42:08 +0000
Subject: Re: [PATCH] hugetlb: simplify hugetlb handling in follow_page_mask
Message-Id: <Yw/HoERzKsv1mKbY@monkey>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220829234053.159158-1-mike.kravetz@oracle.com>
 <202208311341.ybNgt0Kz-lkp@intel.com>
In-Reply-To: <202208311341.ybNgt0Kz-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <lkp@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, inuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org, kbuild-all@lists.01.org, Baolin Wang <baolin.wang@linux.alibaba.com>, David Hildenbrand <david@redhat.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, Michael Ellerman <mpe@ellerman.id.au>, Muchun Song <songmuchun@bytedance.com>, Andrew Morton <akpm@linux-foundation.org>

On 08/31/22 13:08, kernel test robot wrote:
> Hi Mike,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on akpm-mm/mm-everything]
> [also build test ERROR on linus/master v6.0-rc3 next-20220830]
> [cannot apply to powerpc/next]
> [If your patch is applied to the wrong git tree, kindly drop us a note.
> And when submitting patch, we suggest to use '--base' as documented in
> https://git-scm.com/docs/git-format-patch#_base_tree_information]
> 
> url:    https://github.com/intel-lab-lkp/linux/commits/Mike-Kravetz/hugetlb-simplify-hugetlb-handling-in-follow_page_mask/20220830-074147
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git mm-everything
> config: powerpc-randconfig-r001-20220830 (https://download.01.org/0day-ci/archive/20220831/202208311341.ybNgt0Kz-lkp@intel.com/config)
> compiler: powerpc-linux-gcc (GCC) 12.1.0
> reproduce (this is a W=1 build):
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # https://github.com/intel-lab-lkp/linux/commit/f7dc41c1552ecd1e483a100c8b0921df62980f38
>         git remote add linux-review https://github.com/intel-lab-lkp/linux
>         git fetch --no-tags linux-review Mike-Kravetz/hugetlb-simplify-hugetlb-handling-in-follow_page_mask/20220830-074147
>         git checkout f7dc41c1552ecd1e483a100c8b0921df62980f38
>         # save the config file
>         mkdir build_dir && cp config build_dir/.config
>         COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-12.1.0 make.cross W=1 O=build_dir ARCH=powerpc SHELL=/bin/bash arch/powerpc/kernel/
> 
> If you fix the issue, kindly add following tag where applicable
> Reported-by: kernel test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
>    In file included from arch/powerpc/kernel/setup-common.c:35:
> >> include/linux/hugetlb.h:258:21: error: 'hugetlb_follow_page_mask' defined but not used [-Werror=unused-function]
>      258 | static struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,
>          |                     ^~~~~~~~~~~~~~~~~~~~~~~~
>    cc1: all warnings being treated as errors
> 
> 
> vim +/hugetlb_follow_page_mask +258 include/linux/hugetlb.h
> 
>    257	
>  > 258	static struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,

Thanks! That should be,

		static inline  struct page *hugetlb_follow_page_mask(struct vm_area_struct *vma,

-- 
Mike Kravetz


>    259					unsigned long address, unsigned int flags)
>    260	{
>    261		/* should never happen, but do not want to BUG */
>    262		return ERR_PTR(-EINVAL);
>    263	}
>    264	
> 
> -- 
> 0-DAY CI Kernel Test Service
> https://01.org/lkp
