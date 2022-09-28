From: Masahiro Yamada <masahiroy@kernel.org>
Date: Wed, 28 Sep 2022 19:29:41 +0000
Subject: Re: [PATCH v3 3/8] kbuild: generate KSYMTAB entries by modpost
Message-Id: <CAK7LNASLf0Jbyfu7HB1qLRbc6-3QeZiw3okb6O+c5YhHA-a_bA@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220928063947.299333-1-masahiroy@kernel.org> <20220928063947.299333-4-masahiroy@kernel.org>
In-Reply-To: <20220928063947.299333-4-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-kbuild@vger.kernel.org
Cc: linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>, Ard Biesheuvel <ardb@kernel.org>, Nicolas Pitre <npitre@baylibre.com>, Arnd Bergmann <arnd@arndb.de>, Luis Chamberlain <mcgrof@kernel.org>, Michal Marek <michal.lkml@markovi.net>, Nick Desaulniers <ndesaulniers@google.com>, linux-modules@vger.kernel.org

On Wed, Sep 28, 2022 at 3:41 PM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
> Commit 7b4537199a4a ("kbuild: link symbol CRCs at final link, removing
> CONFIG_MODULE_REL_CRCS") made modpost output CRCs in the same way
> whether the EXPORT_SYMBOL() is placed in *.c or *.S.
>
> This commit applies a similar approach to the entire data structure of
> EXPORT_SYMBOL() for further cleanups. The EXPORT_SYMBOL() compilation
> is split into two stages.
>
> When a source file is compiled, EXPORT_SYMBOL() is converted into a
> dummy symbol in the .discard.export_symbol section.
>
> For example,
>
>     EXPORT_SYMBOL(foo);
>     EXPORT_SYMBOL_NS_GPL(bar, BAR_NAMESPACE);
>
> will be encoded into the following assembly code:
>
>     .section .discard.export_symbol
>     __export_symbol.foo:
>             .asciz ""
>     .previous
>
>     .section .discard.export_symbol
>     __export_symbol_gpl.bar:
>             .asciz "BAR_NAMESPACE"
>     .previous
>
> They are just markers to tell modpost the name, license, and namespace
> of the symbols. They will be dropped from the final vmlinux and modules
> because the section name starts with ".discard.".
>
> Then, modpost extracts all the information about EXPORT_SYMBOL() from the
> .discard.export_symbol section, and generates C code:
>
>     KSYMTAB_FUNC(foo, "", "");
>     KSYMTAB_FUNC(bar, "_gpl", "BAR_NAMESPACE");
>
> KSYMTAB_FUNC() (or KSYMTAB_DATA() if it is data) is expanded to struct
> kernel_symbol that will be linked to the vmlinux or a module.
>
> With this change, EXPORT_SYMBOL() works in the same way for *.c and *.S
> files, providing the following benefits.
>
> [1] Deprecate EXPORT_DATA_SYMBOL()
>
> In the old days, EXPORT_SYMBOL() was only available in C files. To export
> a symbol in *.S, EXPORT_SYMBOL() was placed in a separate *.c file.
> arch/arm/kernel/armksyms.c is one example written in the classic manner.
>
> Commit 22823ab419d8 ("EXPORT_SYMBOL() for asm") removed this limitation.
> Since then, EXPORT_SYMBOL() can be placed close to the symbol definition
> in *.S files. It was a nice improvement.
>
> However, as that commit mentioned, you need to use EXPORT_DATA_SYMBOL()
> for data objects on some architectures.
>
> In the new approach, modpost checks symbol's type (STT_FUNC or not),
> and outputs KSYMTAB_FUNC() or KSYMTAB_DATA() accordingly.
>
> There are only two users of EXPORT_DATA_SYMBOL:
>
>   EXPORT_DATA_SYMBOL_GPL(empty_zero_page)    (arch/ia64/kernel/head.S)
>   EXPORT_DATA_SYMBOL(ia64_ivt)               (arch/ia64/kernel/ivt.S)
>
> They are transformed as follows and output into .vmlinux.export.c
>
>   KSYMTAB_DATA(empty_zero_page, "_gpl", "");
>   KSYMTAB_DATA(ia64_ivt, "", "");
>
> The other EXPORT_SYMBOL users in ia64 assembly are output as
> KSYMTAB_FUNC().
>
> EXPORT_DATA_SYMBOL() is now deprecated.
>
> [2] merge <linux/export.h> and <asm-generic/export.h>
>
> There are two similar header implementations:
>
>   include/linux/export.h        for .c files
>   include/asm-generic/export.h  for .S files
>
> Ideally, the functionality should be consistent between them, but they
> tend to diverge.
>
> Commit 8651ec01daed ("module: add support for symbol namespaces.") did
> not support the namespace for *.S files.
>
> This commit shifts the essential implementation part to C, which supports
> EXPORT_SYMBOL_NS() for *.S files.
>
> <asm/export.h> and <asm-generic/export.h> will remain as a wrapper of
> <linux/export.h> for a while.
>
> They will be removed after #include <asm/export.h> directives are all
> replaced with #include <linux/export.h>.
>
> [3] Implement CONFIG_TRIM_UNUSED_KSYMS in one-pass algorithm (by a later commit)
>
> When CONFIG_TRIM_UNUSED_KSYMS is enabled, Kbuild recursively traverses
> the directory tree to determine which EXPORT_SYMBOL to trim. If an
> EXPORT_SYMBOL turns out to be unused by anyone, Kbuild begins the
> second traverse, where some source files are recompiled with their
> EXPORT_SYMBOL() tuned into a no-op.
>
> We can do this better now; modpost can selectively emit KSYMTAB entries
> that are really used by modules.
>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>



After some more tests, I noticed this introduced
false positive warnings:

  ERROR: modpost: phy_init .init.text vmlinux: EXPORT_SYMBOL used for
init symbol. Remove __init or EXPORT_SYMBOL.
  ERROR: modpost: phy_exit .exit.text vmlinux: EXPORT_SYMBOL used for
exit symbol. Remove __exit or EXPORT_SYMBOL.


If I find how to fix it, I will send v4.





-- 
Best Regards
Masahiro Yamada
