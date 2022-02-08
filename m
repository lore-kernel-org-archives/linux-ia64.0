From: kernel test robot <lkp@intel.com>
Date: Tue, 08 Feb 2022 23:10:39 +0000
Subject: Re: [PATCH v2] include: linux: Reorganize timekeeping and ktime headers
Message-Id: <202202090656.Bx5FpSa7-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220208161049.865402-1-carlos.bilbao@amd.com>
In-Reply-To: <20220208161049.865402-1-carlos.bilbao@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Carlos Bilbao <carlos.bilbao@amd.com>, john.stultz@linaro.org, tglx@linutronix.de, sboyd@kernel.org, alexandre.belloni@bootlin.com, gregkh@linuxfoundation.org
Cc: kbuild-all@lists.01.org, linux-kernel@vger.kernel.org, bilbao@vt.edu, geert@linux-m68k.org, linux-arm-kernel@lists.infradead.org, rostedt@goodmis.org, boon.leong.ong@intel.com, mhiramat@kernel.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-rtc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-stm32@st-md-mailman.stormreply.com, jgross@suse.com, Carlos Bilbao <carlos.bilbao@amd.com>, kernel test robot <lkp@intel.com>

Hi Carlos,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on geert-m68k/for-next]
[also build test ERROR on tip/timers/core tip/x86/core linus/master v5.17-rc3]
[cannot apply to next-20220208]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch]

url:    https://github.com/0day-ci/linux/commits/Carlos-Bilbao/include-linux-Reorganize-timekeeping-and-ktime-headers/20220209-001309
base:   https://git.kernel.org/pub/scm/linux/kernel/git/geert/linux-m68k.git for-next
config: alpha-randconfig-r001-20220208 (https://download.01.org/0day-ci/archive/20220209/202202090656.Bx5FpSa7-lkp@intel.com/config)
compiler: alpha-linux-gcc (GCC) 11.2.0
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/0day-ci/linux/commit/5ed7d76f2d6aabedc437bc0b99020dc655ab5719
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Carlos-Bilbao/include-linux-Reorganize-timekeeping-and-ktime-headers/20220209-001309
        git checkout 5ed7d76f2d6aabedc437bc0b99020dc655ab5719
        # save the config file to linux build tree
        mkdir build_dir
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-11.2.0 make.cross O=build_dir ARCH=alpha SHELL=/bin/bash arch/alpha/kernel/

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   arch/alpha/kernel/osf_sys.c: In function '__do_sys_osf_settimeofday':
>> arch/alpha/kernel/osf_sys.c:1013:16: error: implicit declaration of function 'do_sys_settimeofday64'; did you mean 'sys_settimeofday'? [-Werror=implicit-function-declaration]
    1013 |         return do_sys_settimeofday64(tv ? &kts : NULL, tz ? &ktz : NULL);
         |                ^~~~~~~~~~~~~~~~~~~~~
         |                sys_settimeofday
   cc1: some warnings being treated as errors


vim +1013 arch/alpha/kernel/osf_sys.c

^1da177e4c3f415 Linus Torvalds  2005-04-16   997  
e5d9a90c36e05dd Ivan Kokshaysky 2009-01-29   998  SYSCALL_DEFINE2(osf_settimeofday, struct timeval32 __user *, tv,
e5d9a90c36e05dd Ivan Kokshaysky 2009-01-29   999  		struct timezone __user *, tz)
^1da177e4c3f415 Linus Torvalds  2005-04-16  1000  {
ce4c253573ad184 Arnd Bergmann   2017-11-08  1001  	struct timespec64 kts;
^1da177e4c3f415 Linus Torvalds  2005-04-16  1002  	struct timezone ktz;
^1da177e4c3f415 Linus Torvalds  2005-04-16  1003  
^1da177e4c3f415 Linus Torvalds  2005-04-16  1004   	if (tv) {
ce4c253573ad184 Arnd Bergmann   2017-11-08  1005  		if (get_tv32(&kts, tv))
^1da177e4c3f415 Linus Torvalds  2005-04-16  1006  			return -EFAULT;
^1da177e4c3f415 Linus Torvalds  2005-04-16  1007  	}
^1da177e4c3f415 Linus Torvalds  2005-04-16  1008  	if (tz) {
^1da177e4c3f415 Linus Torvalds  2005-04-16  1009  		if (copy_from_user(&ktz, tz, sizeof(*tz)))
^1da177e4c3f415 Linus Torvalds  2005-04-16  1010  			return -EFAULT;
^1da177e4c3f415 Linus Torvalds  2005-04-16  1011  	}
^1da177e4c3f415 Linus Torvalds  2005-04-16  1012  
ce4c253573ad184 Arnd Bergmann   2017-11-08 @1013  	return do_sys_settimeofday64(tv ? &kts : NULL, tz ? &ktz : NULL);
^1da177e4c3f415 Linus Torvalds  2005-04-16  1014  }
^1da177e4c3f415 Linus Torvalds  2005-04-16  1015  

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
