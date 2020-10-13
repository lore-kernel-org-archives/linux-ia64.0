From: Masahiro Yamada <masahiroy@kernel.org>
Date: Tue, 13 Oct 2020 16:16:59 +0000
Subject: Re: [PATCH v2 1/2] kconfig: use interpreters to invoke scripts
Message-Id: <CAK7LNAQUXwH0KoNNQo9F1UCkkah2S1gJZKJFB1+91M3ZGSHQSQ@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20201012170631.1241502-1-ujjwalkumar0501@gmail.com> <20201012170631.1241502-2-ujjwalkumar0501@gmail.com>
In-Reply-To: <20201012170631.1241502-2-ujjwalkumar0501@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
Cc: Michal Marek <michal.lkml@markovi.net>, Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@chromium.org>, Lukas Bulwahn <lukas.bulwahn@gmail.com>, Nathan Chancellor <natechancellor@gmail.com>, Nick Desaulniers <ndesaulniers@google.com>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, linux-ia64@vger.kernel.org, clang-built-linux <clang-built-linux@googlegroups.com>, linux-kernel-mentees@lists.linuxfoundation.org

On Tue, Oct 13, 2020 at 2:08 AM Ujjwal Kumar <ujjwalkumar0501@gmail.com> wrote:
>
> We cannot rely on execute bits to be set on files in the repository.
> The build script should use the explicit interpreter when invoking any
> script from the repository.
>
> Link: https://lore.kernel.org/lkml/20200830174409.c24c3f67addcce0cea9a9d4c@linux-foundation.org/
> Link: https://lore.kernel.org/lkml/202008271102.FEB906C88@keescook/
>
> Suggested-by: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Kees Cook <keescook@chromium.org>
> Suggested-by: Lukas Bulwahn <lukas.bulwahn@gmail.com>
> Signed-off-by: Ujjwal Kumar <ujjwalkumar0501@gmail.com>
> ---



The patch prefix 'kconfig:' should be used for changes
under scripts/kconfig/.


I want to see both prefixed with "kbuild:".

1/2:   kbuild: use interpreters in Kconfig files to invoke scripts
2/2:   kbuild: use interpreters in Makefiles to invoke scripts


More preferably, those two patches should be squashed into a
single patch titled "kbuild: use interpreters to invoke scripts"



BTW, I notice some code left unconverted.

For example,
https://github.com/torvalds/linux/blob/master/init/Kconfig#L68
https://github.com/torvalds/linux/blob/v5.9/certs/Makefile#L25

Maybe more...



I know it is difficult to cover everything, but please
re-check the remaining code.







>  init/Kconfig | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/init/Kconfig b/init/Kconfig
> index c9446911cf41..8adf3194d26f 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -30,12 +30,12 @@ config CC_IS_GCC
>
>  config GCC_VERSION
>         int
> -       default $(shell,$(srctree)/scripts/gcc-version.sh $(CC)) if CC_IS_GCC
> +       default $(shell,$(CONFIG_SHELL) $(srctree)/scripts/gcc-version.sh $(CC)) if CC_IS_GCC
>         default 0
>
>  config LD_VERSION
>         int
> -       default $(shell,$(LD) --version | $(srctree)/scripts/ld-version.sh)
> +       default $(shell,$(LD) --version | $(AWK) -f $(srctree)/scripts/ld-version.sh)
>
>  config CC_IS_CLANG
>         def_bool $(success,echo "$(CC_VERSION_TEXT)" | grep -q clang)
> @@ -45,20 +45,20 @@ config LD_IS_LLD
>
>  config CLANG_VERSION
>         int
> -       default $(shell,$(srctree)/scripts/clang-version.sh $(CC))
> +       default $(shell,$(CONFIG_SHELL) $(srctree)/scripts/clang-version.sh $(CC))
>
>  config CC_CAN_LINK
>         bool
> -       default $(success,$(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m64-flag)) if 64BIT
> -       default $(success,$(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m32-flag))
> +       default $(success,$(CONFIG_SHELL) $(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m64-flag)) if 64BIT
> +       default $(success,$(CONFIG_SHELL) $(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m32-flag))
>
>  config CC_CAN_LINK_STATIC
>         bool
> -       default $(success,$(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m64-flag) -static) if 64BIT
> -       default $(success,$(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m32-flag) -static)
> +       default $(success,$(CONFIG_SHELL) $(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m64-flag) -static) if 64BIT
> +       default $(success,$(CONFIG_SHELL) $(srctree)/scripts/cc-can-link.sh $(CC) $(CLANG_FLAGS) $(m32-flag) -static)
>
>  config CC_HAS_ASM_GOTO
> -       def_bool $(success,$(srctree)/scripts/gcc-goto.sh $(CC))
> +       def_bool $(success,$(CONFIG_SHELL) $(srctree)/scripts/gcc-goto.sh $(CC))
>
>  config CC_HAS_ASM_GOTO_OUTPUT
>         depends on CC_HAS_ASM_GOTO
> --
> 2.25.1
>
> --
> You received this message because you are subscribed to the Google Groups "Clang Built Linux" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to clang-built-linux+unsubscribe@googlegroups.com.
> To view this discussion on the web visit https://groups.google.com/d/msgid/clang-built-linux/20201012170631.1241502-2-ujjwalkumar0501%40gmail.com.



-- 
Best Regards
Masahiro Yamada
