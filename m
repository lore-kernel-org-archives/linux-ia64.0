From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 28 Jan 2021 08:17:09 +0000
Subject: Re: [PATCH 12/27] m68k: syscalls: switch to generic syscalltbl.sh
Message-Id: <CAMuHMdV_AHcnGoVToHLXa95JEd4wcL3eTqYfk6=7Ou0W8VJR5w@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20210128005110.2613902-1-masahiroy@kernel.org> <20210128005110.2613902-13-masahiroy@kernel.org>
In-Reply-To: <20210128005110.2613902-13-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: Linux-Arch <linux-arch@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, "open list:TENSILICA XTENSA PORT (xtensa)" <linux-xtensa@linux-xtensa.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Parisc List <linux-parisc@vger.kernel.org>, linux-kbuild <linux-kbuild@vger.kernel.org>, Linux-sh list <linux-sh@vger.kernel.org>, linux-um <linux-um@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "open list:BROADCOM NVRAM DRIVER" <linux-mips@vger.kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, alpha <linux-alpha@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>

Hi Yamada-san,

On Thu, Jan 28, 2021 at 1:54 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
> As of v5.11-rc1, 12 architectures duplicate similar shell scripts in
> order to generate syscall table headers. My goal is to unify them into
> the single scripts/syscalltbl.sh.
>
> This commit converts m68k to use scripts/syscalltbl.sh.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Thanks a lot!

Tested-by: Geert Uytterhoeven <geert@linux-m68k.org>
Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
