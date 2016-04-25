From: Will Deacon <will.deacon@arm.com>
Date: Mon, 25 Apr 2016 11:13:39 +0000
Subject: Re: [PATCH v5 00/14]  ACPI NUMA support for ARM64
Message-Id: <20160425111338.GJ16065@arm.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1461116439-22991-1-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-kernel@vger.kernel.org, Robert Richter <rrichter@cavium.com>, David Daney <david.daney@cavium.com>

Hi David,

On Tue, Apr 19, 2016 at 06:40:25PM -0700, David Daney wrote:
> From: David Daney <david.daney@cavium.com>
> 
> Based on v16 of device-tree NUMA patch set for arm64 [1],this patch
> set introduce the ACPI based configuration to provide NUMA
> information.
> 
> ACPI 5.1 already introduced NUMA support for ARM64, which can get the
> NUMA domain information from SRAT and SLIT table, so parse those two
> tables to get mappings from cpu/mem to numa node configuration and
> system locality.

Whilst I've queued the main NUMA series for arm64, I'd really like to
see more movement on the generic header file cleanups that you posted
separately:

http://lkml.kernel.org/r/1456358528-24213-1-git-send-email-ddaney.cavm@gmail.com

Given that this ACPI series already requires some significant cross-arch
interaction (which is actually good!), perhaps extending the clean-up
patches to encompass some of the ACPI bits might make sense, and we can
get that queued as a pre-requisite.

Will

> v5 updates:
> 
>  - Fixed ia64 build failure by gating some unused functions with #if
>    CONFIG_{X86,ARM64}.
> 
>  - Fixed section mismatch errors for X86 case.
> 
>  - Removed unneeded #include from some files.
> 
>  - Tested to build cleanly on ARM64, X86_64, IA64
> 
> v4 updates:
> 
>  - Updated from Hanjun Guo's v3 patches.
> 
>  - Rebased on top of v16 of device-tree NUMA patches.
> 
>  - Reordered some of the changes so that we don't introduce code and
>    then change it several times in the patch set.  New code is
>    introduced in its final form.  Code reused from x86 is first moved
>    with no change, and then a separate patch to make any needed
>    changes.
> 
>  - code that is used only by ia64, moved to architecture specific
>    files.
> 
> v3 updates:
>  - Deep investigation about the ACPI_DEBUG_PRINT() and remvoe
>    that for acpi/numa.c (patch 2/12)
> 
>  - Remove the duplicate NULL check for table print (patch 3/12)
> 
>  - Introduce CONFIG_ACPI_HAS_NUMA_ARCH_FIXUP to remove duplicate
>    dummy function for acpi_numa_arch_fixup()
> 
>  - Solve the problem that the mapping from logical cpu to numa node
>    is wrong which spotted out by Lorenzo
> 
>  - cleanups for x86 and move acpi_numa_slit_init() and some other
>    functions to common place, then reduce the duplicate of x86
>    and arm64 (patch 7-12/12).
> 
>  - rebased on top of 4.4 and Ganapat's v9 patch set.
> 
> [1]: https://lkml.org/lkml/2016/4/8/571
> 
> David Daney (1):
>   acpi, numa, srat: Improve SRAT error detection and add messages.
> 
> Hanjun Guo (11):
>   acpi, numa: Use pr_fmt() instead of printk
>   acpi, numa: Replace ACPI_DEBUG_PRINT() with pr_debug()
>   acpi, numa: remove duplicate NULL check
>   acpi, numa: move acpi_numa_slit_init() to drivers/acpi/numa.c
>   arm64, numa: rework numa_add_memblk()
>   x86, acpi, numa: cleanup acpi_numa_processor_affinity_init()
>   acpi, numa: move bad_srat() and srat_disabled() to
>     drivers/acpi/numa.c
>   acpi, numa: remove unneeded acpi_numa=1
>   acpi, numa: Move acpi_numa_memory_affinity_init() to
>     drivers/acpi/numa.c
>   arm64, acpi, numa: NUMA support based on SRAT and SLIT
>   acpi, numa: Enable ACPI based NUMA on ARM64
> 
> Robert Richter (2):
>   acpi, numa: Move acpi_numa_arch_fixup() to ia64 only
>   arm64, acpi, numa: Default enable ACPI_NUMA with NUMA
> 
>  arch/arm64/include/asm/acpi.h |   8 ++
>  arch/arm64/include/asm/numa.h |   2 +
>  arch/arm64/kernel/Makefile    |   1 +
>  arch/arm64/kernel/acpi_numa.c | 149 ++++++++++++++++++++++++++++
>  arch/arm64/kernel/smp.c       |   2 +
>  arch/arm64/mm/numa.c          |  17 ++--
>  arch/ia64/include/asm/acpi.h  |   3 +
>  arch/ia64/kernel/acpi.c       |   2 +-
>  arch/ia64/kernel/setup.c      |   1 +
>  arch/x86/include/asm/acpi.h   |   1 -
>  arch/x86/mm/numa.c            |   2 +-
>  arch/x86/mm/srat.c            | 116 +---------------------
>  drivers/acpi/Kconfig          |   4 +-
>  drivers/acpi/numa.c           | 224 ++++++++++++++++++++++++++++++++----------
>  drivers/of/of_numa.c          |   4 +-
>  include/acpi/acpi_numa.h      |   4 +
>  include/linux/acpi.h          |  18 +++-
>  17 files changed, 375 insertions(+), 183 deletions(-)
>  create mode 100644 arch/arm64/kernel/acpi_numa.c
> 
> -- 
> 1.7.11.7
> 
