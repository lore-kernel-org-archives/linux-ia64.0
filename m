From: Masahiro Yamada <yamada.masahiro@socionext.com>
Date: Wed, 03 May 2017 05:23:17 +0000
Subject: Re: [PATCH] ia64: beatify build log for gate.so and gate-syms.o
Message-Id: <CAK7LNATsg8kA-DqxEJ7mZv3Ek4Vw6e8yWT_2oOPCXVzmQ6wfkg@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1491953792-19760-1-git-send-email-yamada.masahiro@socionext.com>
In-Reply-To: <1491953792-19760-1-git-send-email-yamada.masahiro@socionext.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

2017-04-12 8:36 GMT+09:00 Masahiro Yamada <yamada.masahiro@socionext.com>:
> Currently, the object path is not aligned in the build log:
>
>   LDS     arch/ia64/kernel/gate.lds
>   AS      arch/ia64/kernel/gate.o
>   GATE arch/ia64/kernel/gate.so
>   AS      arch/ia64/kernel/gate-data.o
>
> Signed-off-by: Masahiro Yamada <yamada.masahiro@socionext.com>
> ---
>
>  arch/ia64/kernel/Makefile.gate | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/arch/ia64/kernel/Makefile.gate b/arch/ia64/kernel/Makefile.gate
> index ceeffc5..a32903a 100644
> --- a/arch/ia64/kernel/Makefile.gate
> +++ b/arch/ia64/kernel/Makefile.gate
> @@ -6,7 +6,7 @@ extra-y += gate.so gate-syms.o gate.lds gate.o
>
>  CPPFLAGS_gate.lds := -P -C -U$(ARCH)
>
> -quiet_cmd_gate = GATE $@
> +quiet_cmd_gate = GATE    $@
>        cmd_gate = $(CC) -nostdlib $(GATECFLAGS_$(@F)) -Wl,-T,$(filter-out FORCE,$^) -o $@
>
>  GATECFLAGS_gate.so = -shared -s -Wl,-soname=linux-gate.so.1 \
> --
> 2.7.4
>

I got no response from the ia64 maintainers,
but this patch is trivial enough to be applied to kbuild tree.

Applied to linux-kbuild/kbuild.



-- 
Best Regards
Masahiro Yamada
