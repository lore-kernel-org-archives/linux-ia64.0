From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 10 May 2023 14:34:34 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <CAMuHMdWQLF6QZi4j5Yg3oiy8dMbuApk+r=5c2tSLvYxvAaudMA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de> <20230510110557.14343-6-tzimmermann@suse.de>
 <CAMuHMdVV-MQV3C_o6JxPj23h3zo0kMmsn9ZEWJxsrzr6YpKmyg@mail.gmail.com> <487ff03b-d753-972f-7a06-a1d5efda917d@suse.de>
In-Reply-To: <487ff03b-d753-972f-7a06-a1d5efda917d@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, sam@ravnborg.org, suijingfeng@loongson.cn, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Wed, May 10, 2023 at 4:20 PM Thomas Zimmermann <tzimmermann@suse.de> wrote:
> Am 10.05.23 um 14:34 schrieb Geert Uytterhoeven:
> > On Wed, May 10, 2023 at 1:06 PM Thomas Zimmermann <tzimmermann@suse.de> wrote:
> >> Implement framebuffer I/O helpers, such as fb_read*() and fb_write*(),
> >> in the architecture's <asm/fb.h> header file or the generic one.
> >>
> >> The common case has been the use of regular I/O functions, such as
> >> __raw_readb() or memset_io(). A few architectures used plain system-
> >> memory reads and writes. Sparc used helpers for its SBus.
> >>
> >> The architectures that used special cases provide the same code in
> >> their __raw_*() I/O helpers. So the patch replaces this code with the
> >> __raw_*() functions and moves it to <asm-generic/fb.h> for all
> >> architectures.
> >>
> >> v6:
> >>          * fix fb_readq()/fb_writeq() on 64-bit mips (kernel test robot)
> >> v5:
> >>          * include <linux/io.h> in <asm-generic/fb>; fix s390 build
> >> v4:
> >>          * ia64, loongarch, sparc64: add fb_mem*() to arch headers
> >>            to keep current semantics (Arnd)
> >> v3:
> >>          * implement all architectures with generic helpers
> >>          * support reordering and native byte order (Geert, Arnd)
> >>
> >> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> >> Tested-by: Sui Jingfeng <suijingfeng@loongson.cn>
> >> Reviewed-by: Arnd Bergmann <arnd@arndb.de>

> >> --- a/arch/mips/include/asm/fb.h
> >> +++ b/arch/mips/include/asm/fb.h
> >> @@ -12,6 +12,28 @@ static inline void fb_pgprotect(struct file *file, struct vm_area_struct *vma,
> >>   }
> >>   #define fb_pgprotect fb_pgprotect
> >>
> >> +/*
> >> + * MIPS doesn't define __raw_ I/O macros, so the helpers
> >> + * in <asm-generic/fb.h> don't generate fb_readq() and
> >> + * fb_write(). We have to provide them here.
> >
> > MIPS does not include <asm-generic/io.h>,  nor define its own
>
> I know, that's why the TODO says to convert it to generic I/O.
>
> > __raw_readq() and __raw_writeq()...
>
> It doesn't define those macros, but it generates function calls of the
> same names. Follow the macros at
>
>
> https://elixir.bootlin.com/linux/latest/source/arch/mips/include/asm/io.h#L357
>
> It expands to a variety of helpers, including __raw_*().

Thanks, I forgot MIPS is using these grep-unfriendly factories...

> >> + *
> >> + * TODO: Convert MIPS to generic I/O. The helpers below can
> >> + *       then be removed.
> >> + */
> >> +#ifdef CONFIG_64BIT
> >> +static inline u64 fb_readq(const volatile void __iomem *addr)
> >> +{
> >> +       return __raw_readq(addr);
> >
> > ... so how can this call work?
>
> On 64-bit builds, there's __raw_readq() and __raw_writeq().
>
> At first, I tried to do the right thing and convert MIPS to work with
> <asm-generic/io.h>. But that created a ton of follow-up errors in other
> headers. So for now, it's better to handle this problem in asm/fb.h.

So isn't just adding

    #define __raw_readq __raw_readq
    #define __raw_writeq __raw_writeq

to arch/mips/include/asm/io.h sufficient to make <asm-generic/fb.h>
do the right thing?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
