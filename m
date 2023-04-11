From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 11 Apr 2023 08:08:47 +0000
Subject: Re: [PATCH v2 01/19] fbdev: Prepare generic architecture helpers
Message-Id: <CAMuHMdUfViWzPbB+GcGUwxmGNxAohfq71Jed3DzS=Cb+gBzotg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de> <20230406143019.6709-2-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-2-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

Hi Thomas,

On Thu, Apr 6, 2023 at 4:30=E2=80=AFPM Thomas Zimmermann <tzimmermann@suse.=
de> wrote:
> Generic implementations of fb_pgprotect() and fb_is_primary_device()
> have been in the source code for a long time. Prepare the header file
> to make use of them.
>
> Improve the code by using an inline function for fb_pgprotect()
> and by removing include statements. The default mode set by
> fb_pgprotect() is now writecombine, which is what most platforms
> want.
>
> Symbols are protected by preprocessor guards. Architectures that
> provide a symbol need to define a preprocessor token of the same
> name and value. Otherwise the header file will provide a generic
> implementation. This pattern has been taken from <asm/io.h>.
>
> v2:
>         *  use writecombine mappings by default (Arnd)
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>

Thanks for your patch!

> --- a/include/asm-generic/fb.h
> +++ b/include/asm-generic/fb.h
> @@ -1,13 +1,32 @@
>  /* SPDX-License-Identifier: GPL-2.0 */
> +
>  #ifndef __ASM_GENERIC_FB_H_
>  #define __ASM_GENERIC_FB_H_
> -#include <linux/fb.h>
>
> -#define fb_pgprotect(...) do {} while (0)
> +/*
> + * Only include this header file from your architecture's <asm/fb.h>.
> + */
> +
> +#include <asm/page.h>
> +
> +struct fb_info;
> +struct file;
> +
> +#ifndef fb_pgprotect
> +#define fb_pgprotect fb_pgprotect
> +static inline void fb_pgprotect(struct file *file, struct vm_area_struct=
 *vma,
> +                               unsigned long off)

Does this affect any noMMU platforms that relied on fb_pgprotect()
doing nothing before?
Perhaps the body below should be protected by "#ifdef CONFIG_MMU"?

> +{
> +       vma->vm_page_prot =3D pgprot_writecombine(vma->vm_page_prot);

Shouldn't this use the pgprot_val() wrapper?

> +}
> +#endif

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
