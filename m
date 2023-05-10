From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 10 May 2023 14:15:46 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
In-Reply-To: <202305102136.eMjTSPwH-lkp@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: kernel test robot <lkp@intel.com>, Thomas Zimmermann <tzimmermann@suse.de>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, suijingfeng@loongson.cn
Cc: oe-kbuild-all@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Wed, May 10, 2023, at 16:03, kernel test robot wrote:

>
>    cc1: warning: arch/sh/include/mach-hp6xx: No such file or directory 
> [-Wmissing-include-dirs]
>    cc1: warning: arch/sh/include/mach-hp6xx: No such file or directory 
> [-Wmissing-include-dirs]
>    In file included from drivers/video/fbdev/hitfb.c:27:
>    drivers/video/fbdev/hitfb.c: In function 'hitfb_accel_wait':
>>> arch/sh/include/asm/hd64461.h:18:33: warning: passing argument 1 of 'fb_readw' makes pointer from integer without a cast [-Wint-conversion]
>       18 | #define HD64461_IO_OFFSET(x)    (HD64461_IOBASE + (x))
>          |                                 ^~~~~~~~~~~~~~~~~~~~~~
>          |                                 |
>          |                                 unsigned int
>    arch/sh/include/asm/hd64461.h:93:33: note: in expansion of macro 
> 'HD64461_IO_OFFSET'
>       93 | #define HD64461_GRCFGR          HD64461_IO_OFFSET(0x1044)    
>    /* Accelerator Configuration Register */
>          |                                 ^~~~~~~~~~~~~~~~~
>    drivers/video/fbdev/hitfb.c:47:25: note: in expansion of macro 
> 'HD64461_GRCFGR'
>       47 |         while (fb_readw(HD64461_GRCFGR) & 
> HD64461_GRCFGR_ACCSTATUS) ;

I think that's a preexisting bug and I have no idea what the
correct solution is. Looking for HD64461 shows it being used
both with inw/outw and readw/writew, so there is no way to have
the correct type. The sh __raw_readw() definition hides this bug,
but that is a problem with arch/sh and it probably hides others
as well.

       Arnd
