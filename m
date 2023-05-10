From: "Arnd Bergmann" <arnd@arndb.de>
Date: Wed, 10 May 2023 15:54:18 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <743d2b1e-c843-4fb2-b252-0006be2e2bd8@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
 <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
 <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
In-Reply-To: <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Thomas Zimmermann <tzimmermann@suse.de>, kernel test robot <lkp@intel.com>, Helge Deller <deller@gmx.de>, Geert Uytterhoeven <geert@linux-m68k.org>, Javier Martinez Canillas <javierm@redhat.com>, Daniel Vetter <daniel@ffwll.ch>, Vineet Gupta <vgupta@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, WANG Xuerui <kernel@xen0n.name>, "David S . Miller" <davem@davemloft.net>, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, Sam Ravnborg <sam@ravnborg.org>, suijingfeng@loongson.cn
Cc: oe-kbuild-all@lists.linux.dev, Linux-Arch <linux-arch@vger.kernel.org>, linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, sparclinux@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Wed, May 10, 2023, at 16:27, Thomas Zimmermann wrote:
> Am 10.05.23 um 16:15 schrieb Arnd Bergmann:
>> On Wed, May 10, 2023, at 16:03, kernel test robot wrote:
 
>> I think that's a preexisting bug and I have no idea what the
>> correct solution is. Looking for HD64461 shows it being used
>> both with inw/outw and readw/writew, so there is no way to have
>> the correct type. The sh __raw_readw() definition hides this bug,
>> but that is a problem with arch/sh and it probably hides others
>> as well.
>
> The constant HD64461_IOBASE is defined as integer at
>
> 
> https://elixir.bootlin.com/linux/latest/source/arch/sh/include/asm/hd64461.h#L17
>
> but fb_readw() expects a volatile-void pointer. I guess we could add a 
> cast somewhere to silence the problem. In the current upstream code, 
> that appears to be done by sh's __raw_readw() internally:
>
> 
> https://elixir.bootlin.com/linux/latest/source/arch/sh/include/asm/io.h#L35

Sure, that would make it build again, but that still doesn't make the
code correct, since it's completely unclear what base address the
HD64461_IOBASE is relative to. The hp6xx platform code only passes it
through inw()/outw(), which take an offset relative to sh_io_port_base,
but that is not initialized on hp6xx. I tried to find in the history
when it broke, apparently that was in 2007 commit 34a780a0afeb ("sh:
hp6xx pata_platform support."), which removed the custom inw/outw
implementations.

      Arnd
