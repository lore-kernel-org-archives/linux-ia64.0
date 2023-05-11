From: "Arnd Bergmann" <arnd@arndb.de>
Date: Thu, 11 May 2023 13:40:28 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <d27e359c-1ea3-4d08-b124-e794fd372b28@app.fastmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-6-tzimmermann@suse.de>
 <202305102136.eMjTSPwH-lkp@intel.com>
 <f6b2d541-d235-4e98-afcc-9137fb8afa35@app.fastmail.com>
 <49684d58-c19d-b147-5e9f-2ac526dd50f0@suse.de>
 <743d2b1e-c843-4fb2-b252-0006be2e2bd8@app.fastmail.com>
 <CAMuHMdVvR1jdbZS8KoMf4R3zhLRWKv9XbG61iBGOGGZPHB+taA@mail.gmail.com>
 <9c4be198444e9987c826c87b592e9dc6@artur-rojek.eu>
In-Reply-To: <9c4be198444e9987c826c87b592e9dc6@artur-rojek.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Artur Rojek <contact@artur-rojek.eu>, Geert Uytterhoeven <geert@linux-m68k.org>
Cc: linux-fbdev@vger.kernel.org, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, "James E . J . Bottomley" <James.Bottomley@hansenpartnership.com>, sparclinux@vger.kernel.org, WANG Xuerui <kernel@xen0n.name>, Sam Ravnborg <sam@ravnborg.org>, Linux-Arch <linux-arch@vger.kernel.org>, kernel test robot <lkp@intel.com>, Helge Deller <deller@gmx.de>, Huacai Chen <chenhuacai@kernel.org>, Javier Martinez Canillas <javierm@redhat.com>, Vineet Gupta <vgupta@kernel.org>, linux-snps-arc@lists.infradead.org, suijingfeng@loongson.cn, linux-m68k@lists.linux-m68k.org, loongarch@lists.linux.dev, oe-kbuild-all@lists.linux.dev, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Zimmermann <tzimmermann@suse.de>, "David S . Miller" <davem@davemloft.net>

On Thu, May 11, 2023, at 15:22, Artur Rojek wrote:
> On 2023-05-11 14:35, Geert Uytterhoeven wrote:
>> 
>> CC Artur, who's working on HP Jornada 680.
> Thanks for CC'ing me - I faced this exact issue while working on my
> (still not upstreamed) hd6446x PCMCIA controller driver. The PCMCIA
> subsystem uses `inb/outb`, which expect the `sh_io_port_base` to be set
> to something else than the default `-1`. At first I tried to set it to
> `0xa0000000`, so that all I/O goes through the fixed, non-cacheable P2
> area. That however broke some other driver code (I had no time to debug
> which one). Eventually I ended up taking a suggestion from a MIPS PCMCIA
> driver [1] and simply substract the broken `sh_io_port_base` address
> from `HD64461_IOBASE`, as the base for `socket.io_offset`. This way all
> the PCMCIA `inb/outb` accesses are absolute, no matter what the
> `sh_io_port_base` is set to. This of course is a very ugly solution and
> we should instead fix the root cause of this mess. I will have a better
> look at this patch set and the problem at hand at a later date.
>
> Cheers,
> Artur
>
> [1] 
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/pcmcia/db1xxx_ss.c?h=v6.4-rc1#n527

I think the best fix would be to change all those drivers away
from using inb/outb to readb/writeb, except when they access the
actual PCMCIA I/O space behind the bridge.

On most of the modern architectures, inb(addr) now turns into
approximately readb(PCI_IOBASE + addr), with a bit of extra
logic to deal with endianess and barrier semantics.

PCI_IOBASE in turn tends to be a hardcoded virtual address
to which the physical I/O space window gets mapped during
early boot, though you can also #define it to sh_io_port_base
if you want to allocate the virtual address dynamically and
leave the existing logic unchanged.

Setting sh_io_port_base to zero however is a problem for any
driver that passes a small port number into it -- this then
turns into a user space pointer dereference, which is trivially
exploitable.

     Arnd
