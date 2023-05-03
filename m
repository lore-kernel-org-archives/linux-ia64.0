From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 03 May 2023 08:21:50 +0000
Subject: Re: [PATCH v3 0/6] fbdev: Move framebuffer I/O helpers to <asm/fb.h>
Message-Id: <CAMuHMdV06LN17KzOh42vjyF504myT=D=a-zz3MduOmQPEmv5SA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230502130223.14719-1-tzimmermann@suse.de>
In-Reply-To: <20230502130223.14719-1-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: deller@gmx.de, javierm@redhat.com, daniel@ffwll.ch, vgupta@kernel.org, chenhuacai@kernel.org, kernel@xen0n.name, davem@davemloft.net, James.Bottomley@hansenpartnership.com, arnd@arndb.de, sam@ravnborg.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-arch@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org

Hi Thomas,

On Tue, May 2, 2023 at 3:02=E2=80=AFPM Thomas Zimmermann <tzimmermann@suse.=
de> wrote:
> (was: fbdev: Use regular I/O function for framebuffers)
>
> Fbdev provides helpers for framebuffer I/O, such as fb_readl(),
> fb_writel() or fb_memcpy_to_fb(). The implementation of each helper
> depends on the architecture, but they are all equivalent to regular
> I/O functions of similar names. So use regular functions instead and
> move all helpers into <asm-generic/fb.h>
>
> The first patch a simple whitespace cleanup.
>
> Until now, <linux/fb.h> contained an include of <asm/io.h>. As this
> will go away patches 2 to 4 prepare include statements in the various
> drivers. Source files that use regular I/O helpers, such as readl(),
> now include <linux/io.h>. Source files that use framebuffer I/O
> helpers, such as fb_readl(), also include <asm/fb.h>.
>
> Patch 5 replaces the architecture-based if-else branching in
> <linux/fb.h> by helpers in <asm-generic/fb.h>. All helpers use Linux'
> existing I/O functions.
>
> Patch 6 harmonizes naming among fbdev and existing I/O functions.
>
> The patchset has been built for a variety of platforms, such as x86-64,
> arm, aarch64, ppc64, parisc, m64k, mips and sparc.
>
> v3:
>         * add the new helpers in <asm-generic/fb.h>
>         * support reordering and native byte order (Geert, Arnd)

Thanks, this fixes the mangled display I was seeing on ARAnyM
with bpp=16.

BTW, this series seems to have mixed dependencies: the change
to include/asm-generic/fb.h depends on "[PATCH v3 00/19] arch:
Consolidate <asm/fb.h>"[1], but with that applied, I had to manually
fixup drivers/video/fbdev/core/fb_cfb_fops.c.

[1] https://lore.kernel.org/all/20230417125651.25126-1-tzimmermann@suse.de,

Gr{oetje,eeting}s,

                        Geert

--=20
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
