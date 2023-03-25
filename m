From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Sat, 25 Mar 2023 06:38:15 +0000
Subject: Re: [PATCH v3 05/14] ia64: don't allow users to override ARCH_FORCE_MAX_ORDER
Message-Id: <02dd2437-32fa-31aa-4ff3-b33a058f2363@huawei.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20230325060828.2662773-1-rppt@kernel.org>
 <20230325060828.2662773-6-rppt@kernel.org>
In-Reply-To: <20230325060828.2662773-6-rppt@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Mike Rapoport <rppt@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, Christophe Leroy <christophe.leroy@csgroup.eu>, "David S. Miller" <davem@davemloft.net>, Dinh Nguyen <dinguyen@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Guo Ren <guoren@kernel.org>, John Paul Adrian Glaubitz <glaubitz@physik.fu-berlin.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Max Filippov <jcmvbkbc@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Will Deacon <will@kernel.org>, Yoshinori Sato <ysato@users.sourceforge.jp>, Zi Yan <ziy@nvidia.com>, linux-arm-kernel@lists.infradead.org, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linux-xtensa@linux-xtensa.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org



On 2023/3/25 14:08, Mike Rapoport wrote:
> From: "Mike Rapoport (IBM)" <rppt@kernel.org>
> 
> It is enough to keep default values for base and huge pages without
> letting users to override ARCH_FORCE_MAX_ORDER.
> 
> Drop the prompt to make the option unvisible in *config.
> 
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reviewed-by: Zi Yan <ziy@nvidia.com>
> Signed-off-by: Mike Rapoport (IBM) <rppt@kernel.org>
> ---
>   arch/ia64/Kconfig | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index 0d2f41fa56ee..b61437cae162 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -202,8 +202,7 @@ config IA64_CYCLONE
>   	  If you're unsure, answer N.
>   
>   config ARCH_FORCE_MAX_ORDER
> -	int "MAX_ORDER (10 - 16)"  if !HUGETLB_PAGE
> -	range 10 16  if !HUGETLB_PAGE
> +	int
>   	default "16" if HUGETLB_PAGE
>   	default "10"
>   

It seems that we could drop the following part?

diff --git a/arch/ia64/include/asm/sparsemem.h 
b/arch/ia64/include/asm/sparsemem.h
index a58f8b466d96..18187551b183 100644
--- a/arch/ia64/include/asm/sparsemem.h
+++ b/arch/ia64/include/asm/sparsemem.h
@@ -11,11 +11,6 @@

  #define SECTION_SIZE_BITS      (30)
  #define MAX_PHYSMEM_BITS       (50)
-#ifdef CONFIG_ARCH_FORCE_MAX_ORDER
-#if (CONFIG_ARCH_FORCE_MAX_ORDER + PAGE_SHIFT > SECTION_SIZE_BITS)
-#undef SECTION_SIZE_BITS
-#define SECTION_SIZE_BITS (CONFIG_ARCH_FORCE_MAX_ORDER + PAGE_SHIFT)
-#endif
  #endif
