From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 15 Aug 2022 15:53:22 +0000
Subject: Re: [PATCH] arch: mm: rename FORCE_MAX_ZONEORDER to ARCH_FORCE_MAX_ORDER
Message-Id: <CAK8P3a0TcnXHVsxBkpqLi63XC62Jkg3HChtK4RgB6-giYb+hnw@mail.gmail.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220815143959.1511278-1-zi.yan@sent.com>
In-Reply-To: <20220815143959.1511278-1-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Zi Yan <ziy@nvidia.com>
Cc: linux-mm@kvack.org, David Hildenbrand <david@redhat.com>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, John Hubbard <jhubbard@nvidia.com>, Yang Shi <shy828301@gmail.com>, David Rientjes <rientjes@google.com>, James Houghton <jthoughton@google.com>, Mike Rapoport <rppt@kernel.org>, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>, Vineet Gupta <vgupta@synopsys.com>, Shawn Guo <shawnguo@kernel.org>, Taichi Sugaya <sugaya.taichi@socionext.com>, Neil Armstrong <narmstrong@baylibre.com>, Qin Jian <qinjian@cqplus1.com>, Catalin Marinas <catalin.marinas@arm.com>, Guo Ren <guoren@kernel.org>, Huacai Chen <chenhuacai@kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Thomas Bogendoerfer <tsbogend@alpha.franken.de>, Dinh Nguyen <dinguyen@kernel.org>, Christophe Leroy <christophe.leroy@csgroup.eu>, Yoshinori Sato <ysato@users.sourceforge.jp>, "David S. Miller" <davem@davemloft.net>, Chris Zankel <chris@zankel.net>, Arnd Bergmann <arnd@arndb.de>, Ley Foon Tan <ley.foon.tan@intel.com>, Andrew Morton <akpm@linux-foundation.org>, NXP Linux Team <linux-imx@nxp.com>, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-oxnas@groups.io, linux-csky@vger.kernel.org, linux-ia64@vger.kernel.org, loongarch@lists.linux.dev, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org

On Mon, Aug 15, 2022 at 4:39 PM Zi Yan <zi.yan@sent.com> wrote:
>
> ---
>  arch/arc/Kconfig                             | 2 +-
>  arch/arm/Kconfig                             | 2 +-
>  arch/arm/configs/imx_v6_v7_defconfig         | 2 +-
>  arch/arm/configs/milbeaut_m10v_defconfig     | 2 +-
>  arch/arm/configs/oxnas_v6_defconfig          | 2 +-
>  arch/arm/configs/pxa_defconfig               | 2 +-
>  arch/arm/configs/sama7_defconfig             | 2 +-
>  arch/arm/configs/sp7021_defconfig            | 2 +-
>  arch/arm64/Kconfig                           | 2 +-
>  arch/csky/Kconfig                            | 2 +-
>  arch/ia64/Kconfig                            | 2 +-
>  arch/ia64/include/asm/sparsemem.h            | 6 +++---
>  arch/loongarch/Kconfig                       | 2 +-
>  arch/m68k/Kconfig.cpu                        | 2 +-
>  arch/mips/Kconfig                            | 2 +-
>  arch/nios2/Kconfig                           | 2 +-
>  arch/powerpc/Kconfig                         | 2 +-
>  arch/powerpc/configs/85xx/ge_imp3a_defconfig | 2 +-
>  arch/powerpc/configs/fsl-emb-nonhw.config    | 2 +-
>  arch/sh/configs/ecovec24_defconfig           | 2 +-
>  arch/sh/mm/Kconfig                           | 2 +-
>  arch/sparc/Kconfig                           | 2 +-
>  arch/xtensa/Kconfig                          | 2 +-
>  include/linux/mmzone.h                       | 4 ++--

Acked-by: Arnd Bergmann <arnd@arndb.de>
