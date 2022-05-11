From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 11 May 2022 02:04:48 +0000
Subject: Re: [PATCH v3 2/3] mm: rmap: Fix CONT-PTE/PMD size hugetlb issue when migration
Message-Id: <20220510190448.5e352897a147622ffa87175f@linux-foundation.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <ea5abf529f0997b5430961012bfda6166c1efc8c.1652147571.git.baolin.wang@linux.alibaba.com>
        <202205110919.CWIcIqYE-lkp@intel.com>
In-Reply-To: <202205110919.CWIcIqYE-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <lkp@intel.com>
Cc: Baolin Wang <baolin.wang@linux.alibaba.com>, mike.kravetz@oracle.com, catalin.marinas@arm.com, will@kernel.org, kbuild-all@lists.01.org, songmuchun@bytedance.com, tsbogend@alpha.franken.de, James.Bottomley@hansenpartnership.com, deller@gmx.de, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, hca@linux.ibm.com, gor@linux.ibm.com, agordeev@linux.ibm.com, borntraeger@linux.ibm.com, svens@linux.ibm.com, ysato@users.osdn.me, dalias@libc.org, davem@davemloft.net, arnd@arndb.de, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On Wed, 11 May 2022 09:19:17 +0800 kernel test robot <lkp@intel.com> wrote:

> Hi Baolin,
> 
> I love your patch! Yet something to improve:
> 
> [auto build test ERROR on akpm-mm/mm-everything]
> [cannot apply to hnaz-mm/master arm64/for-next/core linus/master v5.18-rc6]
> [If your patch is applied to the wrong git tree, kindly drop us a note.
> And when submitting patch, we suggest to use '--base' as documented in
> https://git-scm.com/docs/git-format-patch]
> 
> url:    https://github.com/intel-lab-lkp/linux/commits/Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220510-114753
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/akpm/mm.git mm-everything
> config: h8300-buildonly-randconfig-r001-20220509 (https://download.01.org/0day-ci/archive/20220511/202205110919.CWIcIqYE-lkp@intel.com/config)
> compiler: h8300-linux-gcc (GCC) 11.3.0
> reproduce (this is a W=1 build):
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # https://github.com/intel-lab-lkp/linux/commit/b666792b4c5f9774c350977ff88837bafc36365a
>         git remote add linux-review https://github.com/intel-lab-lkp/linux
>         git fetch --no-tags linux-review Baolin-Wang/Fix-CONT-PTE-PMD-size-hugetlb-issue-when-unmapping-or-migrating/20220510-114753
>         git checkout b666792b4c5f9774c350977ff88837bafc36365a
>         # save the config file
>         mkdir build_dir && cp config build_dir/.config
>         COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-11.3.0 make.cross W=1 O=build_dir ARCH=h8300 SHELL=/bin/bash
> 
> ...

Thanks. 
https://git.kernel.org/pub/scm/linux/kernel/git/akpm/25-new.git/tree/patches/mm-rmap-fix-cont-pte-pmd-size-hugetlb-issue-when-migration-fix.patch
(which is in current mm-everything) fixes this up.
