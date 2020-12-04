From: Masahiro Yamada <masahiroy@kernel.org>
Date: Fri, 04 Dec 2020 05:43:46 +0000
Subject: Re: [PATCH 0/3] ia64: clean-up header dependency and build process, fix build warning
Message-Id: <CAK7LNARL88XGMuNSxAVKsTw+s74PY2GCU+QNJCh02ZKG5s9TNw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20200829051524.706585-1-masahiroy@kernel.org>
In-Reply-To: <20200829051524.706585-1-masahiroy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org
Cc: Randy Dunlap <rdunlap@infradead.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Ard Biesheuvel <ardb@kernel.org>, Arnd Bergmann <arnd@arndb.de>, Dmitry Safonov <0x7f454c46@gmail.com>, afzal mohammed <afzal.mohd.ma@gmail.com>, linux-efi <linux-efi@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi, IA64 maintainers,

Could you check this series, please?
The build warning is still remaining.



On Sat, Aug 29, 2020 at 2:16 PM Masahiro Yamada <masahiroy@kernel.org> wrote:
>
>
> Randy Dunlap reports the following warning with CONFIG_IA64_PALINFO=m:
>
> ../scripts/Makefile.build:68: 'arch/ia64/kernel/palinfo.ko' will not be built even though obj-m is specified.
> ../scripts/Makefile.build:69: You cannot use subdir-y/m to visit a module Makefile. Use obj-y/m instead.
>
> This comes from the fact Kbuild descends into arch/ia64/kernel/ twice.
>
> First, to generate <generated/nr-irqs.h>,
> Second, to build kernel and module objects.
>
> The warning is emitted in the first descend because it is not the
> intended usage.
>
> I looked into the code closely, and noticed arch/ia64/kernel/nr-irqs.c
> was not needed in the first place.
>
> It was separated out of arch/ia64/kernel/asm-offsets.c just because
> <asm/mca.h> was including too many bogus headers.
>
> IA64 is not actively maintained, and there exists unneeded obsolete code.
>
> The first two patches are the outcome when I played with ARCH=ia64 builds,
> but not prerequisites for 3/3. Anyway I believe they are nice cleanups
> and folded in this patch set.
>
> 3/3 is the important one to fix the false positive warning,
> and it is a nice cleanup too.
>
>
>
> Masahiro Yamada (3):
>   ia64: do not typedef struct pal_min_state_area_s
>   ia64: remove unneeded header includes from <asm/mca.h>
>   ia64: remove generated/nr-irqs.h generation to fix build warning
>
>  arch/ia64/Makefile             |  6 ------
>  arch/ia64/include/asm/irq.h    |  4 +++-
>  arch/ia64/include/asm/mca.h    | 11 ++++-------
>  arch/ia64/include/asm/pal.h    |  4 ++--
>  arch/ia64/include/asm/sal.h    |  2 +-
>  arch/ia64/kernel/Makefile      |  5 -----
>  arch/ia64/kernel/asm-offsets.c | 18 +++++++++---------
>  arch/ia64/kernel/efi.c         |  1 +
>  arch/ia64/kernel/mca.c         |  5 +++--
>  arch/ia64/kernel/mca_drv.c     |  2 +-
>  arch/ia64/kernel/nr-irqs.c     | 22 ----------------------
>  11 files changed, 24 insertions(+), 56 deletions(-)
>  delete mode 100644 arch/ia64/kernel/nr-irqs.c
>
> --
> 2.25.1
>


-- 
Best Regards
Masahiro Yamada
