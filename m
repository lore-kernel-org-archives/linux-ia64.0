From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 28 Jan 2021 07:58:32 +0000
Subject: Re: [PATCH 11/27] m68k: add missing FORCE and fix 'targets' to make if_changed work
Message-Id: <CAMuHMdWTK7Xa-6E2yLHxv8sGkD-VYgDF2SMRCj4_tDTVS2Uw1A@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org> <20210128005110.2613902-12-masahiroy@kernel.org>
In-Reply-To: <20210128005110.2613902-12-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, alpha <linux-alpha@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Thu, Jan 28, 2021 at 1:54 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
> The rules in this Makefile cannot detect the command line change because
> the prerequisite 'FORCE' is missing.
>
> Adding 'FORCE' will result in the headers being rebuilt every time
> because the 'targets' addition is also wrong; the file paths in
> 'targets' must be relative to the current Makefile.
>
> Fix all of them so the if_changed rules work correctly.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
