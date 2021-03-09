From: Anshuman Khandual <anshuman.khandual@arm.com>
Date: Tue, 09 Mar 2021 09:16:17 +0000
Subject: Re: [PATCH 0/6] mm: some config cleanups
Message-Id: <a3cb7daf-641f-4e50-316f-60b9c53b3e51@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1615278790-18053-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1615278790-18053-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-mm@kvack.org
Cc: x86@kernel.org, linux-ia64@vger.kernel.org, linux-s390@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-sh@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


On 3/9/21 2:03 PM, Anshuman Khandual wrote:
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

Again the same thing happened.

https://patchwork.kernel.org/project/linux-mm/list/?seriesD4393
https://lore.kernel.org/linux-mm/1615278790-18053-1-git-send-email-anshuman.khandual@arm.com/

From past experiences, this problem might be just related to many
entries on the CC list. But this time even dropped the --cc-cover
parameter which would have expanded the CC list on each individual
patches further, like last time.

If it helps, have hosted these six patches on v5.12-rc2

https://gitlab.arm.com/linux-arm/linux-anshuman/-/commits/mm/mm_config_cleanups/v1/

- Anshuman
