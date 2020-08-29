From: Randy Dunlap <rdunlap@infradead.org>
Date: Sat, 29 Aug 2020 18:22:01 +0000
Subject: Re: [PATCH 3/3] ia64: remove generated/nr-irqs.h generation to fix build warning
Message-Id: <d98592ec-d74b-27c6-f7d2-9d304b1d9eda@infradead.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
 <20200829051524.706585-4-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-4-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Masahiro Yamada <masahiroy@kernel.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org

On 8/28/20 10:15 PM, Masahiro Yamada wrote:
> Randy reports the following warning when building ARCH=ia64 with
> CONFIG_IA64_PALINFO=m:
> 
> ../scripts/Makefile.build:68: 'arch/ia64/kernel/palinfo.ko' will not be built even though obj-m is specified.
> ../scripts/Makefile.build:69: You cannot use subdir-y/m to visit a module Makefile. Use obj-y/m instead.
> 
> This message is actually false-positive, and you can get palinfo.ko
> correctly built. It is emitted in the archprepare stage, where Kbuild
> descends into arch/ia64/kernel to generate include/generated/nr-irqs.h
> instead of any kind of kernel objects.
> 
> arch/ia64/kernel/nr-irqs.c was introduced by commit 213060a4d699
> ("[IA64] pvops: paravirtualize NR_IRQS") to pre-calculate:
> 
>    NR_IRQS = max(IA64_NATIVE_NR_IRQS, XEN_NR_IRQS, FOO_NR_IRQS...)
> 
> Since commit d52eefb47d4e ("ia64/xen: Remove Xen support for ia64"), this
> union contains just one field, making NR_IRQS and IA64_NATIVE_NR_IRQS
> always match.
> 
> So, the following hard-coding now works:
> 
>   #define NR_IRQS                IA64_NATIVE_NR_IRQS
> 
> If you need to re-introduce NR_IRQS = max(...) gimmick in the future,
> please try to implement it in asm-offsets.c instead of a separate file.
> It will be possible because the header inclusion has been consolidated
> to make asm-offsets.c independent of <asm/irqs.h>.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Masahiro Yamada <masahiroy@kernel.org>

Reviewed-by: Randy Dunlap <rdunlap@infradead.org>
Tested-by: Randy Dunlap <rdunlap@infradead.org>

> ---
> 
>  arch/ia64/Makefile          |  6 ------
>  arch/ia64/include/asm/irq.h |  4 +++-
>  arch/ia64/kernel/Makefile   |  5 -----
>  arch/ia64/kernel/nr-irqs.c  | 22 ----------------------
>  4 files changed, 3 insertions(+), 34 deletions(-)
>  delete mode 100644 arch/ia64/kernel/nr-irqs.c
> 


thanks.
-- 
~Randy
