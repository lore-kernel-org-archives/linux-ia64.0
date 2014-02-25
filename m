From: Matt Turner <mattst88@gmail.com>
Date: Tue, 25 Feb 2014 17:40:15 +0000
Subject: Re: [PATCH v2 1/1] audit: Add CONFIG_HAVE_ARCH_AUDITSYSCALL
Message-Id: <CAEdQ38Hf=vEXEKhYaduR8HAcXyChQ-Wo7rHPGs20DirVwkDAxw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1391407232-4623-1-git-send-email-takahiro.akashi@linaro.org>
 <1393319784-2758-1-git-send-email-takahiro.akashi@linaro.org>
 <1393319784-2758-2-git-send-email-takahiro.akashi@linaro.org>
In-Reply-To: <1393319784-2758-2-git-send-email-takahiro.akashi@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org

On Tue, Feb 25, 2014 at 1:16 AM, AKASHI Takahiro
<takahiro.akashi@linaro.org> wrote:
> Currently AUDITSYSCALL has a long list of architecture depencency:
>        depends on AUDIT && (X86 || PARISC || PPC || S390 || IA64 || UML ||
>                 SPARC64 || SUPERH || (ARM && AEABI && !OABI_COMPAT) || ALPHA)
> The purpose of this patch is to replace it with HAVE_ARCH_AUDITSYSCALL
> for simplicity.
>
> Signed-off-by: AKASHI Takahiro <takahiro.akashi@linaro.org>
> ---
>  arch/alpha/Kconfig     |    1 +
>  arch/arm/Kconfig       |    1 +
>  arch/ia64/Kconfig      |    1 +
>  arch/parisc/Kconfig    |    1 +
>  arch/powerpc/Kconfig   |    1 +
>  arch/s390/Kconfig      |    1 +
>  arch/sh/Kconfig        |    1 +
>  arch/sparc/Kconfig     |    1 +
>  arch/um/Kconfig.common |    1 +
>  arch/x86/Kconfig       |    1 +
>  init/Kconfig           |    5 ++++-
>  11 files changed, 14 insertions(+), 1 deletion(-)
>
> diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
> index f6c6b34..b7ff9a3 100644
> --- a/arch/alpha/Kconfig
> +++ b/arch/alpha/Kconfig
> @@ -22,6 +22,7 @@ config ALPHA
>         select GENERIC_SMP_IDLE_THREAD
>         select GENERIC_STRNCPY_FROM_USER
>         select GENERIC_STRNLEN_USER
> +       select HAVE_ARCH_AUDITSYSCALL
>         select HAVE_MOD_ARCH_SPECIFIC
>         select MODULES_USE_ELF_RELA
>         select ODD_RT_SIGACTION

Thanks.

Acked-by: Matt Turner <mattst88@gmail.com>
