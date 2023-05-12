From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 12 May 2023 11:16:30 +0000
Subject: RE: [PATCH v7 1/7] fbdev/hitfb: Cast I/O offset to address
Message-Id: <c25758dd7b4a4563b0d33c751da8cf6d@AcuMS.aculab.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230512102444.5438-1-tzimmermann@suse.de>
 <20230512102444.5438-2-tzimmermann@suse.de>
In-Reply-To: <20230512102444.5438-2-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: 'Thomas Zimmermann' <tzimmermann@suse.de>, "deller@gmx.de" <deller@gmx.de>, "geert@linux-m68k.org" <geert@linux-m68k.org>, "javierm@redhat.com" <javierm@redhat.com>, "daniel@ffwll.ch" <daniel@ffwll.ch>, "vgupta@kernel.org" <vgupta@kernel.org>, "chenhuacai@kernel.org" <chenhuacai@kernel.org>, "kernel@xen0n.name" <kernel@xen0n.name>, "davem@davemloft.net" <davem@davemloft.net>, "James.Bottomley@HansenPartnership.com" <James.Bottomley@HansenPartnership.com>, "arnd@arndb.de" <arnd@arndb.de>, "sam@ravnborg.org" <sam@ravnborg.org>, "suijingfeng@loongson.cn" <suijingfeng@loongson.cn>
Cc: "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "loongarch@lists.linux.dev" <loongarch@lists.linux.dev>, "linux-m68k@lists.linux-m68k.org" <linux-m68k@lists.linux-m68k.org>, "sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>, kernel test robot <lkp@intel.com>, Artur
 Rojek <contact@artur-rojek.eu>

From: Thomas Zimmermann
> Sent: 12 May 2023 11:25
> 
> Cast I/O offsets to pointers to use them with I/O functions. The I/O
> functions expect pointers of type 'volatile void __iomem *', but the
> offsets are plain integers. Build warnings are
> 
>   ../drivers/video/fbdev/hitfb.c: In function 'hitfb_accel_wait':
>   ../arch/x86/include/asm/hd64461.h:18:33: warning: passing argument 1 of 'fb_readw' makes pointer
> from integer without a cast [-Wint-conversion]
>    18 | #define HD64461_IO_OFFSET(x)    (HD64461_IOBASE + (x))
>       |                                 ^~~~~~~~~~~~~~~~~~~~~~
...
>    52 | static inline u16 fb_readw(const volatile void __iomem *addr)
>       |                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~^~~~
> 
> This patch only fixes the build warnings. It's not clear if the I/O
> offsets can legally be passed to the I/O helpers. It was apparently
> broken in 2007 when custom inw()/outw() helpers got removed by
> commit 34a780a0afeb ("sh: hp6xx pata_platform support."). Fixing the
> driver would require setting the I/O base address.

Did you try changing the definition of HD64461_IOBASE to include
a (volatile void __iomem *) cast?
A lot less churn...

I'm guessing that 'sh' deosn't have in/out instructions so this
is something that is always mapped at a fixed kernel virtual address?

	David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1PT, UK
Registration No: 1397386 (Wales)
