From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 11 Apr 2023 08:20:00 +0000
Subject: Re: [PATCH v2 08/19] arch/m68k: Implement <asm/fb.h> with generic helpers
Message-Id: <CAMuHMdVmZ2GRKqEnZgQKzJ1-Hy-Cz8yoUOhD0TMMqZriH82-tQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230406143019.6709-1-tzimmermann@suse.de> <20230406143019.6709-9-tzimmermann@suse.de>
In-Reply-To: <20230406143019.6709-9-tzimmermann@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: Thomas Zimmermann <tzimmermann@suse.de>
Cc: arnd@arndb.de, daniel.vetter@ffwll.ch, deller@gmx.de, javierm@redhat.com, gregkh@linuxfoundation.org, linux-arch@vger.kernel.org, linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Thu, Apr 6, 2023 at 4:30=E2=80=AFPM Thomas Zimmermann <tzimmermann@suse.=
de> wrote:
> Replace the architecture's fb_is_primary_device() with the generic
> one from <asm-generic/fb.h>. No functional changes.
>
> v2:
>         * provide empty fb_pgprotect() on non-MMU systems
>
> Signed-off-by: Thomas Zimmermann <tzimmermann@suse.de>
> Cc: Geert Uytterhoeven <geert@linux-m68k.org>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k=
.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like t=
hat.
                                -- Linus Torvalds
