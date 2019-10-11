From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 11 Oct 2019 07:49:12 +0000
Subject: Re: [PATCH v2 13/29] vmlinux.lds.h: Replace RW_DATA_SECTION with RW_DATA
Message-Id: <CAMuHMdXiSboG2xum0ZgjpwBxEaP-owywvPpmUubr1nuqzDPJ4Q@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20191011000609.29728-1-keescook@chromium.org> <20191011000609.29728-14-keescook@chromium.org>
In-Reply-To: <20191011000609.29728-14-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Kees Cook <keescook@chromium.org>
Cc: Borislav Petkov <bp@alien8.de>, Rick Edgecombe <rick.p.edgecombe@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Michael Ellerman <mpe@ellerman.id.au>, Heiko Carstens <heiko.carstens@de.ibm.com>, Will Deacon <will@kernel.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, alpha <linux-alpha@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-c6x-dev@linux-c6x.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Michal Simek <monstr@monstr.eu>, Parisc List <linux-parisc@vger.kernel.org>, linux-xtensa@linux-xtensa.org, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Oct 11, 2019 at 2:07 AM Kees Cook <keescook@chromium.org> wrote:
> Rename RW_DATA_SECTION to RW_DATA. (Calling this a "section" is a lie,
> since it's multiple sections and section flags cannot be applied to
> the macro.)
>
> Signed-off-by: Kees Cook <keescook@chromium.org>

>  arch/m68k/kernel/vmlinux-nommu.lds   | 2 +-
>  arch/m68k/kernel/vmlinux-std.lds     | 2 +-
>  arch/m68k/kernel/vmlinux-sun3.lds    | 2 +-

For m68k:
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
