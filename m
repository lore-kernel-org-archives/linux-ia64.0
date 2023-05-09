From: kernel test robot <lkp@intel.com>
Date: Tue, 09 May 2023 07:59:42 +0000
Subject: Re: [PATCH v5 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <202305091533.3zBlgYkC-lkp@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230508114830.28182-6-tzimmermann@suse.de>
In-Reply-To: <20230508114830.28182-6-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, deller@gmx.de, geert@linux-m68k.org, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, sam@ravnborg.org, suijingfeng@loongson.cn
Cc: oe-kbuild-all@lists.linux.dev, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>

Hi Thomas,

kernel test robot noticed the following build errors:

[auto build test ERROR on drm-misc/drm-misc-next]
[cannot apply to deller-parisc/for-next arnd-asm-generic/master linus/master v6.4-rc1 next-20230509]
[If your patch is applied to the wrong git tree, kindly drop us a note.
And when submitting patch, we suggest to use '--base' as documented in
https://git-scm.com/docs/git-format-patch#_base_tree_information]

url:    https://github.com/intel-lab-lkp/linux/commits/Thomas-Zimmermann/fbdev-matrox-Remove-trailing-whitespaces/20230508-195052
base:   git://anongit.freedesktop.org/drm/drm-misc drm-misc-next
patch link:    https://lore.kernel.org/r/20230508114830.28182-6-tzimmermann%40suse.de
patch subject: [PATCH v5 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
config: mips-randconfig-r016-20230507 (https://download.01.org/0day-ci/archive/20230509/202305091533.3zBlgYkC-lkp@intel.com/config)
compiler: mips64-linux-gcc (GCC) 12.1.0
reproduce (this is a W=1 build):
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # https://github.com/intel-lab-lkp/linux/commit/c64dc7f407b3faa85d4e81ec762407388c5813c1
        git remote add linux-review https://github.com/intel-lab-lkp/linux
        git fetch --no-tags linux-review Thomas-Zimmermann/fbdev-matrox-Remove-trailing-whitespaces/20230508-195052
        git checkout c64dc7f407b3faa85d4e81ec762407388c5813c1
        # save the config file
        mkdir build_dir && cp config build_dir/.config
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-12.1.0 make.cross W=1 O=build_dir ARCH=mips olddefconfig
        COMPILER_INSTALL_PATH=$HOME/0day COMPILER=gcc-12.1.0 make.cross W=1 O=build_dir ARCH=mips SHELL=/bin/bash drivers/video/fbdev/core/

If you fix the issue, kindly add following tag where applicable
| Reported-by: kernel test robot <lkp@intel.com>
| Link: https://lore.kernel.org/oe-kbuild-all/202305091533.3zBlgYkC-lkp@intel.com/

All errors (new ones prefixed by >>):

   drivers/video/fbdev/core/cfbfillrect.c: In function 'bitfill_aligned':
>> drivers/video/fbdev/core/cfbfillrect.c:26:21: error: implicit declaration of function 'fb_writeq'; did you mean 'fb_writel'? [-Werror=implicit-function-declaration]
      26 | #  define FB_WRITEL fb_writeq
         |                     ^~~~~~~~~
   drivers/video/fbdev/core/cfbfillrect.c:50:17: note: in expansion of macro 'FB_WRITEL'
      50 |                 FB_WRITEL(comp(pat, FB_READL(dst), first), dst);
         |                 ^~~~~~~~~
>> drivers/video/fbdev/core/cfbfillrect.c:27:21: error: implicit declaration of function 'fb_readq'; did you mean 'fb_readl'? [-Werror=implicit-function-declaration]
      27 | #  define FB_READL  fb_readq
         |                     ^~~~~~~~
   drivers/video/fbdev/core/cfbfillrect.c:50:37: note: in expansion of macro 'FB_READL'
      50 |                 FB_WRITEL(comp(pat, FB_READL(dst), first), dst);
         |                                     ^~~~~~~~
   cc1: some warnings being treated as errors
--
   drivers/video/fbdev/core/cfbcopyarea.c: In function 'bitcpy':
>> drivers/video/fbdev/core/cfbcopyarea.c:37:21: error: implicit declaration of function 'fb_writeq'; did you mean 'fb_writel'? [-Werror=implicit-function-declaration]
      37 | #  define FB_WRITEL fb_writeq
         |                     ^~~~~~~~~
   drivers/video/fbdev/core/cfbcopyarea.c:73:25: note: in expansion of macro 'FB_WRITEL'
      73 |                         FB_WRITEL( comp( FB_READL(src), FB_READL(dst), first), dst);
         |                         ^~~~~~~~~
>> drivers/video/fbdev/core/cfbcopyarea.c:38:21: error: implicit declaration of function 'fb_readq'; did you mean 'fb_readl'? [-Werror=implicit-function-declaration]
      38 | #  define FB_READL  fb_readq
         |                     ^~~~~~~~
   drivers/video/fbdev/core/cfbcopyarea.c:73:42: note: in expansion of macro 'FB_READL'
      73 |                         FB_WRITEL( comp( FB_READL(src), FB_READL(dst), first), dst);
         |                                          ^~~~~~~~
   cc1: some warnings being treated as errors


vim +26 drivers/video/fbdev/core/cfbfillrect.c

^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  21  
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  22  #if BITS_PER_LONG = 32
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  23  #  define FB_WRITEL fb_writel
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  24  #  define FB_READL  fb_readl
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  25  #else
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16 @26  #  define FB_WRITEL fb_writeq
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16 @27  #  define FB_READL  fb_readq
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  28  #endif
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  29  
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  30      /*
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  31       *  Aligned pattern fill using 32/64-bit memory accesses
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  32       */
^1da177e4c3f41 drivers/video/cfbfillrect.c Linus Torvalds 2005-04-16  33  

-- 
0-DAY CI Kernel Test Service
https://github.com/intel/lkp-tests
