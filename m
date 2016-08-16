From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Tue, 16 Aug 2016 11:58:09 +0000
Subject: Re: [PATCH v7 14/15] arm64, acpi, numa: NUMA support based on SRAT and SLIT
Message-Id: <3ac8ffb3-f447-45ef-c118-dde4efe74911@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
 <1464129345-18985-15-git-send-email-ddaney.cavm@gmail.com>
 <20160815153546.GF22320@e104818-lin.cambridge.arm.com>
In-Reply-To: <20160815153546.GF22320@e104818-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: Catalin Marinas <catalin.marinas@arm.com>, David Daney <ddaney.cavm@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, Robert Richter <rrichter@cavium.com>, Ganapatrao Kulkarni <gkulkarni@caviumnetworks.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>

On 2016/8/15 23:35, Catalin Marinas wrote:
> On Tue, May 24, 2016 at 03:35:44PM -0700, David Daney wrote:
>> diff --git a/arch/arm64/include/asm/acpi.h b/arch/arm64/include/asm/acpi.h
>> index aee323b..4b13ecd 100644
>> --- a/arch/arm64/include/asm/acpi.h
>> +++ b/arch/arm64/include/asm/acpi.h
>> @@ -113,4 +113,12 @@ static inline const char *acpi_get_enable_method(int cpu)
>>  pgprot_t arch_apei_get_mem_attribute(phys_addr_t addr);
>>  #endif
>>
>> +#ifdef CONFIG_ACPI_NUMA
>> +int arm64_acpi_numa_init(void);
>> +int acpi_numa_get_nid(unsigned int cpu, u64 hwid);
>> +#else
>> +static inline int arm64_acpi_numa_init(void) { return -ENOSYS; }
>> +static inline int acpi_numa_get_nid(unsigned int cpu, u64 hwid) { return NUMA_NO_NODE; }
>> +#endif /* CONFIG_ACPI_NUMA */
>> +
>>  #endif /*_ASM_ACPI_H*/
>
> Apparently this doesn't always build since asm/acpi.h is conditionally
> included from linux/acpi.h only when CONFIG_ACPI is enabled. Disabling
> this option on arm64 leads to:
>
> arch/arm64/mm/numa.c: In function ‘arm64_numa_init’:
> arch/arm64/mm/numa.c:395:24: error: ‘arm64_acpi_numa_init’ undeclared (first use in this function)
>    if (!acpi_disabled && !numa_init(arm64_acpi_numa_init))
>
> I'll fix it in arch/arm64 by including asm/acpi.h directly as we do in a
> couple of other files:
>
> ------------------8<------------------------------
> From 9a83bf400e0b4ef066b83eeaecdbca909b8491ea Mon Sep 17 00:00:00 2001
> From: Catalin Marinas <catalin.marinas@arm.com>
> Date: Mon, 15 Aug 2016 16:33:10 +0100
> Subject: [PATCH] arm64: Fix NUMA build error when !CONFIG_ACPI
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
>
> Since asm/acpi.h is only included by linux/acpi.h when CONFIG_ACPI is
> enabled, disabling the latter leads to the following build error on
> arm64:
>
> arch/arm64/mm/numa.c: In function ‘arm64_numa_init’:
> arch/arm64/mm/numa.c:395:24: error: ‘arm64_acpi_numa_init’ undeclared (first use in this function)
>    if (!acpi_disabled && !numa_init(arm64_acpi_numa_init))
>
> This patch include the asm/acpi.h explicitly in arch/arm64/mm/numa.c for
> the arm64_acpi_numa_init() definition.
>
> Fixes: d8b47fca8c23 ("arm64, ACPI, NUMA: NUMA support based on SRAT and SLIT")
> Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>  arch/arm64/mm/numa.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
> index c7fe3ec70774..5bb15eab6f00 100644
> --- a/arch/arm64/mm/numa.c
> +++ b/arch/arm64/mm/numa.c
> @@ -23,6 +23,8 @@
>  #include <linux/module.h>
>  #include <linux/of.h>
>
> +#include <asm/acpi.h>
> +
>  struct pglist_data *node_data[MAX_NUMNODES] __read_mostly;
>  EXPORT_SYMBOL(node_data);
>  nodemask_t numa_nodes_parsed __initdata;


Thanks a lot!

Reviewed-by: Hanjun Guo <hanjun.guo@linaro.org>

Hanjun
