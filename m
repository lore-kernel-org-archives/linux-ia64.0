From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 10 May 2023 12:34:33 +0000
Subject: Re: [PATCH v6 5/6] fbdev: Move framebuffer I/O helpers into <asm/fb.h>
Message-Id: <CAMuHMdVV-MQV3C_o6JxPj23h3zo0kMmsn9ZEWJxsrzr6YpKmyg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230510110557.14343-1-tzimmermann@suse.de> <20230510110557.14343-6-tzimmermann@suse.de>
In-Reply-To: <20230510110557.14343-6-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, sam@ravnborg.org, suijingfeng@loongson.cn, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Wed, May 10, 2023 at 1:06=E2=80=AFPM Thomas Zimmermann <tzimmermann@suse=
.de> wrote:
> Implement framebuffer I/O helpers, such as fb_read*() and fb_write*(),
> in the architecture's <asm/fb.h> header file or the generic one.
>
> The common case has been the use of regular I/O functions, such as
> __raw_readb() or memset_io(). A few architectures used plain system-
> memory reads and writes. Sparc used helpers for its SBus.
>
> The architectures that used special cases provide the same code in
> their __raw_*() I/O helpers. So the patch replaces this code with the
> __raw_*() functions and moves it to <asm-generic/fb.h> for all
> architectures.
>
> v6:
>         * fix fb_readq()/fb_writeq() on 64-bit mips (kernel test robot)
> v5:
>         * include <linux/io.h> in <asm-generic/fb>; fix s390 build
> v4:
>         * ia64, loongarch, sparc64: add fb_mem*() to arch headers
>           to keep current semantics (Arnd)
> v3:
>         * implement all architectures with generic helpers
>         * support reordering and native byte order (Geert, Arnd)
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Tested-by: Sui Jingfeng <suijingfeng@loongson.cn>
> Reviewed-by: Arnd Bergmann <arnd@arndb.de>
>
> add mips fb_q()

> --- a/arch/mips/include/asm/fb.h
> +++ b/arch/mips/include/asm/fb.h
> @@ -12,6 +12,28 @@ static inline void fb_pgprotect(struct file *file, str=
uct vm_area_struct *vma,
>  }
>  #define fb_pgprotect fb_pgprotect
>
> +/*
> + * MIPS doesn't define __raw_ I/O macros, so the helpers
> + * in <asm-generic/fb.h> don't generate fb_readq() and
> + * fb_write(). We have to provide them here.

MIPS does not include <asm-generic/io.h>,  nor define its own
__raw_readq() and __raw_writeq()...

> + *
> + * TODO: Convert MIPS to generic I/O. The helpers below can
> + *       then be removed.
> + */
> +#ifdef CONFIG_64BIT
> +static inline u64 fb_readq(const volatile void __iomem *addr)
> +{
> +       return __raw_readq(addr);

... so how can this call work?

> +}
> +#define fb_readq fb_readq
> +
> +static inline void fb_writeq(u64 b, volatile void __iomem *addr)
> +{
> +       __raw_writeq(b, addr);
> +}
> +#define fb_writeq fb_writeq
> +#endif
> +
>  #include <asm-generic/fb.h>

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
