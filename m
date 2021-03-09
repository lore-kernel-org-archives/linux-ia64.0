From: Heiko Carstens <hca@linux.ibm.com>
Date: Tue, 09 Mar 2021 10:12:26 +0000
Subject: Re: [PATCH 0/6] mm: some config cleanups
Message-Id: <YEdKCvxlFQa4noI8@osiris>
List-Id: <linux-ia64.vger.kernel.org>
References: <1615278790-18053-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1615278790-18053-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Mar 09, 2021 at 02:03:04PM +0530, Anshuman Khandual wrote:
> This series contains config cleanup patches which reduces code duplication
> across platforms and also improves maintainability. There is no functional
> change intended with this series. This has been boot tested on arm64 but
> only build tested on some other platforms.
> 
> This applies on 5.12-rc2
> 
> Cc: x86@kernel.org
> Cc: linux-ia64@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> Cc: linux-snps-arc@lists.infradead.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-mips@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-riscv@lists.infradead.org
> Cc: linux-sh@vger.kernel.org
> Cc: linux-fsdevel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> 
> Anshuman Khandual (6):
>   mm: Generalize ARCH_HAS_CACHE_LINE_SIZE
>   mm: Generalize SYS_SUPPORTS_HUGETLBFS (rename as ARCH_SUPPORTS_HUGETLBFS)
>   mm: Generalize ARCH_ENABLE_MEMORY_[HOTPLUG|HOTREMOVE]
>   mm: Drop redundant ARCH_ENABLE_[HUGEPAGE|THP]_MIGRATION
>   mm: Drop redundant ARCH_ENABLE_SPLIT_PMD_PTLOCK
>   mm: Drop redundant HAVE_ARCH_TRANSPARENT_HUGEPAGE
> 
>  arch/arc/Kconfig                       |  9 ++------
>  arch/arm/Kconfig                       | 10 ++-------
>  arch/arm64/Kconfig                     | 30 ++++++--------------------
>  arch/ia64/Kconfig                      |  8 ++-----
>  arch/mips/Kconfig                      |  6 +-----
>  arch/parisc/Kconfig                    |  5 +----
>  arch/powerpc/Kconfig                   | 11 ++--------
>  arch/powerpc/platforms/Kconfig.cputype | 16 +++++---------
>  arch/riscv/Kconfig                     |  5 +----
>  arch/s390/Kconfig                      | 12 +++--------
>  arch/sh/Kconfig                        |  7 +++---
>  arch/sh/mm/Kconfig                     |  8 -------
>  arch/x86/Kconfig                       | 29 ++++++-------------------
>  fs/Kconfig                             |  5 ++++-
>  mm/Kconfig                             |  9 ++++++++
>  15 files changed, 48 insertions(+), 122 deletions(-)

for the s390 bits:
Acked-by: Heiko Carstens <hca@linux.ibm.com>
