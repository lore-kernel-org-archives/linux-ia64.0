From: kernel test robot <lkp@intel.com>
Date: Tue, 08 Feb 2022 21:48:36 +0000
Subject: Re: [PATCH v2] include: linux: Reorganize timekeeping and ktime headers
Message-Id: <202202090554.VWOt2B2w-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220208161049.865402-1-carlos.bilbao@amd.com>
In-Reply-To: <20220208161049.865402-1-carlos.bilbao@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Carlos Bilbao <carlos.bilbao@amd.com>, john.stultz@linaro.org, tglx@linutronix.de, sboyd@kernel.org, alexandre.belloni@bootlin.com, gregkh@linuxfoundation.org
Cc: linux-rtc@vger.kernel.org, jgross@suse.com, kbuild-all@lists.01.org, kernel test robot <lkp@intel.com>, linux-kernel@vger.kernel.org, rostedt@goodmis.org, Carlos Bilbao <carlos.bilbao@amd.com>, linux-m68k@lists.linux-m68k.org, geert@linux-m68k.org, bilbao@vt.edu, boon.leong.ong@intel.com, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-stm32@st-md-mailman.stormreply.com, linux-arm-kernel@lists.infradead.org, mhiramat@kernel.org

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
config: m68k-randconfig-r024-20220208 (https://download.01.org/0day-ci/archive/20220209/202202090554.VWOt2B2w-lkp@intel.com/config)
compiler: m68k-linux-gcc (GCC) 11.2.0
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/0day-ci/linux/commit/5ed7d76f2d6aabedc437bc0b99020dc655ab5719
        git remote add linux-review https://github.com/0day-ci/linux
        git fetch --no-tags linux-review Carlos-Bilbao/include-linux-Reorganize-timekeeping-and-ktime-headers/20220209-001309
        git checkout 5ed7d76f2d6aabedc437bc0b99020dc655ab5719
        # save the config file to linux build tree
        mkdir build_dir
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-11.2.0 make.cross O=build_dir ARCH=m68k SHELL=/bin/bash

If you fix the issue, kindly add following tag as appropriate
Reported-by: kernel test robot <lkp@intel.com>

All errors (new ones prefixed by >>):

   arch/m68k/68000/timers.c: In function 'hw_tick':
>> arch/m68k/68000/timers.c:64:9: error: implicit declaration of function 'legacy_timer_tick' [-Werror=implicit-function-declaration]
      64 |         legacy_timer_tick(1);
         |         ^~~~~~~~~~~~~~~~~
   arch/m68k/68000/timers.c: At top level:
   arch/m68k/68000/timers.c:120:5: warning: no previous prototype for 'm68328_hwclk' [-Wmissing-prototypes]
     120 | int m68328_hwclk(int set, struct rtc_time *t)
         |     ^~~~~~~~~~~~
   cc1: some warnings being treated as errors


vim +/legacy_timer_tick +64 arch/m68k/68000/timers.c

36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  57  
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  58  static irqreturn_t hw_tick(int irq, void *dummy)
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  59  {
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  60  	/* Reset Timer1 */
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  61  	TSTAT &= 0;
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  62  
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  63  	m68328_tick_cnt += TICKS_PER_JIFFY;
09323308f63708 arch/m68k/68000/timers.c               Arnd Bergmann 2020-09-24 @64  	legacy_timer_tick(1);
09323308f63708 arch/m68k/68000/timers.c               Arnd Bergmann 2020-09-24  65  	return IRQ_HANDLED;
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  66  }
36a90f26aa24c5 arch/m68knommu/platform/68328/timers.c Greg Ungerer  2008-02-01  67  

---
0-DAY CI Kernel Test Service, Intel Corporation
https://lists.01.org/hyperkitty/list/kbuild-all@lists.01.org
