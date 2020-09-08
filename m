From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Tue, 08 Sep 2020 06:59:48 +0000
Subject: Re: [PATCH v2] kbuild: preprocess module linker script
Message-Id: <CAMuHMdVobzKWKnN0ScqSY+Jv3N1ri8=mWEd-SZfH5+je+CVVcQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200908042708.2511528-1-masahiroy@kernel.org>
In-Reply-To: <20200908042708.2511528-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>
Cc: linux-kbuild <linux-kbuild@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, Catalin Marinas <catalin.marinas@arm.com>, Paul Mackerras <paulus@samba.org>, linux-riscv <linux-riscv@lists.infradead.org>, Will Deacon <will@kernel.org>, Anton Ivanov <anton.ivanov@cambridgegreys.com>, Linux-Arch <linux-arch@vger.kernel.org>, Richard Weinberger <richard@nod.at>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Fenghua Yu <fenghua.yu@intel.com>, Albert Ou <aou@eecs.berkeley.edu>, Arnd Bergmann <arnd@arndb.de>, Jeff Dike <jdike@addtoit.com>, Jessica Yu <jeyu@kernel.org>, linux-um <linux-um@lists.infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Michal Marek <michal.lkml@markovi.net>, Paul Walmsley <paul.walmsley@sifive.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Tony Luck <tony.luck@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Palmer Dabbelt <palmer@dabbelt.com>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Tue, Sep 8, 2020 at 6:29 AM Masahiro Yamada <masahiroy@kernel.org> wrote:
> There was a request to preprocess the module linker script like we
> do for the vmlinux one. (https://lkml.org/lkml/2020/8/21/512)
>
> The difference between vmlinux.lds and module.lds is that the latter
> is needed for external module builds, thus must be cleaned up by
> 'make mrproper' instead of 'make clean'. Also, it must be created
> by 'make modules_prepare'.
>
> You cannot put it in arch/$(SRCARCH)/kernel/, which is cleaned up by
> 'make clean'. I moved arch/$(SRCARCH)/kernel/module.lds to
> arch/$(SRCARCH)/include/asm/module.lds.h, which is included from
> scripts/module.lds.S.
>
> scripts/module.lds is fine because 'make clean' keeps all the
> build artifacts under scripts/.
>
> You can add arch-specific sections in <asm/module.lds.h>.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>
> Tested-by: Jessica Yu <jeyu@kernel.org>
> Acked-by: Will Deacon <will@kernel.org>

>  arch/m68k/Makefile                                     |  1 -
>  .../{kernel/module.lds => include/asm/module.lds.h}    |  0

Acked-by: Geert Uytterhoeven <geert@linux-m68k.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
