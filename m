From: Catalin Marinas <catalin.marinas@arm.com>
Date: Thu, 23 Mar 2023 10:15:33 +0000
Subject: Re: [PATCH 02/14] arm64: drop ranges in definition of ARCH_FORCE_MAX_ORDER
Message-Id: <ZBwmxbRJrF8RxZEp@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230323092156.2545741-1-rppt@kernel.org>
 <20230323092156.2545741-3-rppt@kernel.org>
In-Reply-To: <20230323092156.2545741-3-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org

On Thu, Mar 23, 2023 at 11:21:44AM +0200, Mike Rapoport wrote:
> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> 
> It is not a good idea to change fundamental parameters of core memory
> management. Having predefined ranges suggests that the values within
> those ranges are sensible, but one has to *really* understand
> implications of changing MAX_ORDER before actually amending it and
> ranges don't help here.
> 
> Drop ranges in definition of ARCH_FORCE_MAX_ORDER
> 
> Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
> ---
>  arch/arm64/Kconfig | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index e60baf7859d1..bab6483e4317 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1489,9 +1489,7 @@ config XEN
>  config ARCH_FORCE_MAX_ORDER
>  	int "Maximum zone order" if ARM64_4K_PAGES || ARM64_16K_PAGES
>  	default "13" if ARM64_64K_PAGES
> -	range 11 13 if ARM64_16K_PAGES
>  	default "11" if ARM64_16K_PAGES
> -	range 10 15 if ARM64_4K_PAGES
>  	default "10"

I don't mind rewriting the help text as in the subsequent patch but I'd
keep the ranges as a safety measure. It's less wasted time explaining to
people why some random max order doesn't work. Alternatively, we can
drop the ranges but make this option configurable only if EXPERT.

-- 
Catalin
