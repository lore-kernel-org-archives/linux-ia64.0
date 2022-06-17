From: kernel test robot <lkp@intel.com>
Date: Fri, 17 Jun 2022 11:26:21 +0000
Subject: Re: [PATCH 1/4] hugetlb: skip to end of PT page mapping when pte not present
Message-Id: <202206171929.ZIUrNg6p-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220616210518.125287-2-mike.kravetz@oracle.com>
In-Reply-To: <20220616210518.125287-2-mike.kravetz@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Kravetz <mike.kravetz@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
Cc: llvm@lists.linux.dev, kbuild-all@lists.01.org, Muchun Song <songmuchun@bytedance.com>, Baolin Wang <baolin.wang@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Peter Xu <peterx@redhat.com>, Naoya Horiguchi <naoya.horiguchi@linux.dev>, James Houghton <jthoughton@google.com>, Mina Almasry <almasrymina@google.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Paul Walmsley <paul.walmsley@sifive.com>, Christian Borntraeger <borntraeger@linux.ibm.com>, catalin.marinas@arm.com, will@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

Hi Mike,

I love your patch! Yet something to improve:

[auto build test ERROR on soc/for-next]
[also build test ERROR on linus/master v5.19-rc2 next-20220617]
[cannot apply to arm64/for-next/core arm/for-next kvmarm/next xilinx-xlnx/master]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/intel-lab-lkp/linux/commits/Mike-Kravetz/hugetlb-speed-up-linear-address-scanning/20220617-050726
base:   https://git.kernel.org/pub/scm/linux/kernel/git/soc/soc.git for-next
config: i386-randconfig-a002 (https://download.01.org/0day-ci/archive/20220617/202206171929.ZIUrNg6p-lkp@intel.com/config)
compiler: clang version 15.0.0 (https://github.com/llvm/llvm-project f0e608de27b3d568000046eebf3712ab542979d6)
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/4c647687607f10fece04967b8180c0dadaf765e6
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Mike-Kravetz/hugetlb-speed-up-linear-address-scanning/20220617-050726
        git checkout 4c647687607f10fece04967b8180c0dadaf765e6
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=clang make.cross W=1 O=build_dir ARCH=i386 SHELL=/bin/bash

If you fix the issue, kindly add following tag where applicable
Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

>> mm/hugetlb.c:6901:7: error: duplicate case value '4194304'
           case PUD_SIZE:
                ^
   include/asm-generic/pgtable-nopud.h:20:20: note: expanded from macro 'PUD_SIZE'
   #define PUD_SIZE        (1UL << PUD_SHIFT)
                           ^
   mm/hugetlb.c:6899:7: note: previous case defined here
           case P4D_SIZE:
                ^
   include/asm-generic/pgtable-nop4d.h:13:19: note: expanded from macro 'P4D_SIZE'
   #define P4D_SIZE                (1UL << P4D_SHIFT)
                                   ^
   mm/hugetlb.c:6903:7: error: duplicate case value '4194304'
           case PMD_SIZE:
                ^
   include/asm-generic/pgtable-nopmd.h:22:20: note: expanded from macro 'PMD_SIZE'
   #define PMD_SIZE        (1UL << PMD_SHIFT)
                           ^
   mm/hugetlb.c:6901:7: note: previous case defined here
           case PUD_SIZE:
                ^
   include/asm-generic/pgtable-nopud.h:20:20: note: expanded from macro 'PUD_SIZE'
   #define PUD_SIZE        (1UL << PUD_SHIFT)
                           ^
   2 errors generated.


vim +/4194304 +6901 mm/hugetlb.c

  6886	
  6887	/*
  6888	 * Return a mask that can be used to update an address to the last huge
  6889	 * page in a page table page mapping size.  Used to skip non-present
  6890	 * page table entries when linearly scanning address ranges.  Architectures
  6891	 * with unique huge page to page table relationships can define their own
  6892	 * version of this routine.
  6893	 */
  6894	unsigned long hugetlb_mask_last_page(struct hstate *h)
  6895	{
  6896		unsigned long hp_size = huge_page_size(h);
  6897	
  6898		switch (hp_size) {
  6899		case P4D_SIZE:
  6900			return PGDIR_SIZE - P4D_SIZE;
> 6901		case PUD_SIZE:
  6902			return P4D_SIZE - PUD_SIZE;
  6903		case PMD_SIZE:
  6904			return PUD_SIZE - PMD_SIZE;
  6905		default:
  6906			break; /* Should never happen */
  6907		}
  6908	
  6909		return ~(0UL);
  6910	}
  6911	

-- 
0-DAY CI Kernel Test Service
https://01.org/lkp
