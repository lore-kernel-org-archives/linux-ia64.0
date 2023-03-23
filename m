From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Thu, 23 Mar 2023 10:17:25 +0000
Subject: Re: [PATCH 00/14] arch,mm: cleanup Kconfig entries for ARCH_FORCE_MAX_ORDER
Message-Id: <20230323101725.2jmvpaqpzflr4mv2@box>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323092156.2545741-1-rppt@kernel.org>
In-Reply-To: <20230323092156.2545741-1-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Thu, Mar 23, 2023 at 11:21:42AM +0200, Mike Rapoport wrote:
> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> 
> Hi,
> 
> Several architectures have ARCH_FORCE_MAX_ORDER in their Kconfig and
> they all have wrong and misleading prompt and help text for this option.
> 
> Besides, some define insane limits for possible values of
> ARCH_FORCE_MAX_ORDER, some carefully define ranges only for a subset of
> possible configurations, some make this option configurable by users for no
> good reason.
> 
> This set updates the prompt and help text everywhere and does its best to
> update actual definitions of ranges where applicable.
> 
> Mike Rapoport (IBM) (14):
>   arm: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
>   arm64: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   csky: drop ARCH_FORCE_MAX_ORDER
>   ia64: don't allow users to override ARCH_FORCE_MAX_ORDER
>   m68k: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   nios2: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   nios2: drop ranges for definition of ARCH_FORCE_MAX_ORDER
>   powerpc: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   powerpc: drop ranges for definition of ARCH_FORCE_MAX_ORDER
>   sh: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   sh: drop ranges for definition of ARCH_FORCE_MAX_ORDER
>   sparc: reword ARCH_FORCE_MAX_ORDER prompt and help text
>   xtensa: reword ARCH_FORCE_MAX_ORDER prompt and help text
> 
>  arch/arm/Kconfig      | 16 +++++++++-------
>  arch/arm64/Kconfig    | 27 ++++++++++++---------------
>  arch/csky/Kconfig     |  4 ----
>  arch/ia64/Kconfig     |  3 +--
>  arch/m68k/Kconfig.cpu | 16 +++++++++-------
>  arch/nios2/Kconfig    | 17 +++++++++--------
>  arch/powerpc/Kconfig  | 22 +++++++++-------------
>  arch/sh/mm/Kconfig    | 19 +++++++++----------
>  arch/sparc/Kconfig    | 16 +++++++++-------
>  arch/xtensa/Kconfig   | 16 +++++++++-------
>  10 files changed, 76 insertions(+), 80 deletions(-)

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
  Kiryl Shutsemau / Kirill A. Shutemov
