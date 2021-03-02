From: Christophe Leroy <christophe.leroy@csgroup.eu>
Date: Tue, 02 Mar 2021 05:43:39 +0000
Subject: Re: [PATCH V2] mm: Generalize HUGETLB_PAGE_SIZE_VARIABLE
Message-Id: <a3772544-1e84-1969-b71c-ea2a3d013471@csgroup.eu>
List-Id: <linux-ia64.vger.kernel.org>
References: <1614661987-23881-1-git-send-email-anshuman.khandual@arm.com>
In-Reply-To: <1614661987-23881-1-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, Christoph Hellwig <hch@lst.de>



Le 02/03/2021 à 06:13, Anshuman Khandual a écrit :
> HUGETLB_PAGE_SIZE_VARIABLE need not be defined for each individual
> platform subscribing it. Instead just make it generic.
> 
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: linux-ia64@vger.kernel.org
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> Suggested-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
> This change was originally suggested in an earilier discussion. This
> applies on v5.12-rc1 and has been build tested on all applicable
> platforms i.e ia64 and powerpc.
> 
> https://patchwork.kernel.org/project/linux-mm/patch/1613024531-19040-3-git-send-email-anshuman.khandual@arm.com/
> 
> Changes in V2:
> 
> - Added a description for HUGETLB_PAGE_SIZE_VARIABLE

You are doing more than adding a description: you are making it user selectable. Is that what you want ?

> - Added HUGETLB_PAGE dependency while selecting HUGETLB_PAGE_SIZE_VARIABLE
> 
> Changes in V1:
> 
> https://patchwork.kernel.org/project/linux-mm/patch/1614577853-7452-1-git-send-email-anshuman.khandual@arm.com/
> 
>   arch/ia64/Kconfig    | 6 +-----
>   arch/powerpc/Kconfig | 6 +-----
>   mm/Kconfig           | 9 +++++++++
>   3 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
> index 2ad7a8d29fcc..dccf5bfebf48 100644
> --- a/arch/ia64/Kconfig
> +++ b/arch/ia64/Kconfig
> @@ -32,6 +32,7 @@ config IA64
>   	select TTY
>   	select HAVE_ARCH_TRACEHOOK
>   	select HAVE_VIRT_CPU_ACCOUNTING
> +	select HUGETLB_PAGE_SIZE_VARIABLE if HUGETLB_PAGE
>   	select VIRT_TO_BUS
>   	select GENERIC_IRQ_PROBE
>   	select GENERIC_PENDING_IRQ if SMP
> @@ -82,11 +83,6 @@ config STACKTRACE_SUPPORT
>   config GENERIC_LOCKBREAK
>   	def_bool n
>   
> -config HUGETLB_PAGE_SIZE_VARIABLE
> -	bool
> -	depends on HUGETLB_PAGE
> -	default y
> -
>   config GENERIC_CALIBRATE_DELAY
>   	bool
>   	default y
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index 3778ad17f56a..3fdec3e53256 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -232,6 +232,7 @@ config PPC
>   	select HAVE_HARDLOCKUP_DETECTOR_PERF	if PERF_EVENTS && HAVE_PERF_EVENTS_NMI && !HAVE_HARDLOCKUP_DETECTOR_ARCH
>   	select HAVE_PERF_REGS
>   	select HAVE_PERF_USER_STACK_DUMP
> +	select HUGETLB_PAGE_SIZE_VARIABLE	if PPC_BOOK3S_64 && HUGETLB_PAGE
>   	select MMU_GATHER_RCU_TABLE_FREE
>   	select MMU_GATHER_PAGE_SIZE
>   	select HAVE_REGS_AND_STACK_ACCESS_API
> @@ -416,11 +417,6 @@ config HIGHMEM
>   
>   source "kernel/Kconfig.hz"
>   
> -config HUGETLB_PAGE_SIZE_VARIABLE
> -	bool
> -	depends on HUGETLB_PAGE && PPC_BOOK3S_64
> -	default y
> -
>   config MATH_EMULATION
>   	bool "Math emulation"
>   	depends on 4xx || PPC_8xx || PPC_MPC832x || BOOKE
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 24c045b24b95..64f1e0503e4f 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -274,6 +274,15 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
>   config ARCH_ENABLE_THP_MIGRATION
>   	bool
>   
> +config HUGETLB_PAGE_SIZE_VARIABLE
> +	bool "Allows dynamic pageblock_order"
> +	def_bool n
> +	depends on HUGETLB_PAGE
> +	help
> +	  Allows the pageblock_order value to be dynamic instead of just standard
> +	  HUGETLB_PAGE_ORDER when there are multiple HugeTLB page sizes available
> +	  on a platform.
> +
>   config CONTIG_ALLOC
>   	def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
>   
> 
