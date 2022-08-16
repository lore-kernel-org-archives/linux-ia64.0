From: Catalin Marinas <catalin.marinas@arm.com>
Date: Tue, 16 Aug 2022 10:30:23 +0000
Subject: Re: [PATCH] arch: mm: rename FORCE_MAX_ZONEORDER to ARCH_FORCE_MAX_ORDER
Message-Id: <Yvtxv2jywm3+Q3ut@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815143959.1511278-1-zi.yan@sent.com>
In-Reply-To: <20220815143959.1511278-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, David Hildenbrand <david@redhat.com>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, John Hubbard <jhubbard@nvidia.com>, Yang Shi <shy828301@gmail.com>, David Rientjes <rientjes@google.com>, James Houghton <jthoughton@google.com>, Mike Rapoport <rppt@kernel.org>, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Shawn Guo <shawnguo@kernel.org>, Taichi Sugaya <sugaya.taichi@socionext.com>, Neil Armstrong <narmstrong@baylibre.com>, Qin Jian <qinjian@cqplus1.com>, Guo Ren <guoren@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Yoshinori Sato <ysato@users.sourceforge.jp>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Arnd Bergmann <arnd@arndb.de>, Ley Foon Tan <ley.foon.tan@intel.com>, Andrew Morton <akpm@linux-foundation.org>, NXP Linux Team <linux-imx@nxp.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-oxnas@groups.io, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org

On Mon, Aug 15, 2022 at 10:39:59AM -0400, Zi Yan wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 571cc234d0b3..c6fcd8746f60 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -1401,7 +1401,7 @@ config XEN
>  	help
>  	  Say Y if you want to run Linux in a Virtual Machine on Xen on ARM64.
>  
> -config FORCE_MAX_ZONEORDER
> +config ARCH_FORCE_MAX_ORDER
>  	int
>  	default "14" if ARM64_64K_PAGES
>  	default "12" if ARM64_16K_PAGES

For arm64:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
