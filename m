From: Matthias Brugger <mbrugger@suse.com>
Date: Thu, 09 Jun 2016 19:47:12 +0000
Subject: Re: [PATCH v7 15/15] acpi, numa: Enable ACPI based NUMA on ARM64
Message-Id: <5759C7C0.3050508@suse.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1464129345-18985-1-git-send-email-ddaney.cavm@gmail.com>
 <1464129345-18985-16-git-send-email-ddaney.cavm@gmail.com>
In-Reply-To: <1464129345-18985-16-git-send-email-ddaney.cavm@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: David Daney <ddaney.cavm@gmail.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Mark Rutland <mark.rutland@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Grant Likely <grant.likely@linaro.org>, Robert Moore <robert.moore@intel.com>, Lv Zheng <lv.zheng@intel.com>, Hanjun Guo <hanjun.guo@linaro.org>, Marc Zyngier <Marc.Zyngier@arm.com>, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org
Cc: Robert Richter <rrichter@cavium.com>, linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>



On 25/05/16 00:35, David Daney wrote:
> From: Hanjun Guo <hanjun.guo@linaro.org>
>
> Add function needed for cpu to node mapping, and enable ACPI based
> NUMA for ARM64 in Kconfig
>
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Signed-off-by: Robert Richter <rrichter@cavium.com>
> [david.daney@cavium.com added ACPI_NUMA default to y for ARM64]
> Signed-off-by: David Daney <david.daney@cavium.com>
> Acked-by: Catalin Marinas <catalin.marinas@arm.com>
> ---
>   drivers/acpi/Kconfig |  4 ++--
>   drivers/acpi/numa.c  | 37 ++++++++++++++++++++++++++++++++++++-
>   include/linux/acpi.h | 17 ++++++++++++++++-
>   3 files changed, 54 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
> index b7e2e77..dd76b36 100644
> --- a/drivers/acpi/Kconfig
> +++ b/drivers/acpi/Kconfig
> @@ -291,8 +291,8 @@ config ACPI_THERMAL
>   config ACPI_NUMA
>   	bool "NUMA support"
>   	depends on NUMA
> -	depends on (X86 || IA64)
> -	default y if IA64_GENERIC || IA64_SGI_SN2
> +	depends on (X86 || IA64 || ARM64)
> +	default y if IA64_GENERIC || IA64_SGI_SN2 || ARM64
>
>   config ACPI_CUSTOM_DSDT_FILE
>   	string "Custom DSDT Table file to include"
> diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
> index fad6d28..9b7ce40 100644
> --- a/drivers/acpi/numa.c
> +++ b/drivers/acpi/numa.c
> @@ -170,6 +170,18 @@ acpi_table_print_srat_entry(struct acpi_subtable_header *header)
>   		}
>   		break;
>
> +	case ACPI_SRAT_TYPE_GICC_AFFINITY:
> +		{
> +			struct acpi_srat_gicc_affinity *p > +			    (struct acpi_srat_gicc_affinity *)header;
> +			pr_debug("SRAT Processor (acpi id[0x%04x]) in proximity domain %d %s\n",
> +				 p->acpi_processor_uid,
> +				 p->proximity_domain,
> +				 (p->flags & ACPI_SRAT_GICC_ENABLED) ?
> +				 "enabled" : "disabled");
> +		}
> +		break;
> +
>   	default:
>   		pr_warn("Found unsupported SRAT entry (type = 0x%x)\n",
>   			header->type);
> @@ -360,6 +372,24 @@ acpi_parse_processor_affinity(struct acpi_subtable_header *header,
>   	return 0;
>   }
>
> +static int __init
> +acpi_parse_gicc_affinity(struct acpi_subtable_header *header,
> +			 const unsigned long end)
> +{
> +	struct acpi_srat_gicc_affinity *processor_affinity;
> +
> +	processor_affinity = (struct acpi_srat_gicc_affinity *)header;
> +	if (!processor_affinity)
> +		return -EINVAL;
> +
> +	acpi_table_print_srat_entry(header);
> +
> +	/* let architecture-dependent part to do it */
> +	acpi_numa_gicc_affinity_init(processor_affinity);
> +
> +	return 0;
> +}
> +
>   static int __initdata parsed_numa_memblks;
>
>   static int __init
> @@ -404,6 +434,9 @@ int __init acpi_numa_init(void)
>   {
>   	int cnt = 0;
>
> +	if (acpi_disabled)
> +		return -EINVAL;
> +
>   	/*
>   	 * Should not limit number with cpu num that is from NR_CPUS or nr_cpus>   	 * SRAT cpu entries could have different order with that in MADT.
> @@ -412,13 +445,15 @@ int __init acpi_numa_init(void)
>
>   	/* SRAT: Static Resource Affinity Table */
>   	if (!acpi_table_parse(ACPI_SIG_SRAT, acpi_parse_srat)) {
> -		struct acpi_subtable_proc srat_proc[2];
> +		struct acpi_subtable_proc srat_proc[3];
>
>   		memset(srat_proc, 0, sizeof(srat_proc));
>   		srat_proc[0].id = ACPI_SRAT_TYPE_CPU_AFFINITY;
>   		srat_proc[0].handler = acpi_parse_processor_affinity;
>   		srat_proc[1].id = ACPI_SRAT_TYPE_X2APIC_CPU_AFFINITY;
>   		srat_proc[1].handler = acpi_parse_x2apic_affinity;
> +		srat_proc[1].id = ACPI_SRAT_TYPE_GICC_AFFINITY;
> +		srat_proc[1].handler = acpi_parse_gicc_affinity;

Should be srat_proc[2].id and srat_proc[2].handler, right?

Regards,
Matthias

>
>   		acpi_table_parse_entries_array(ACPI_SIG_SRAT,
>   					sizeof(struct acpi_table_srat),
> diff --git a/include/linux/acpi.h b/include/linux/acpi.h
> index 8010b26..9515db6 100644
> --- a/include/linux/acpi.h
> +++ b/include/linux/acpi.h
> @@ -232,10 +232,25 @@ int acpi_table_parse_madt(enum acpi_madt_type id,
>   int acpi_parse_mcfg (struct acpi_table_header *header);
>   void acpi_table_print_madt_entry (struct acpi_subtable_header *madt);
>
> -/* the following four functions are architecture-dependent */
> +/* the following numa functions are architecture-dependent */
>   void acpi_numa_slit_init (struct acpi_table_slit *slit);
> +
> +#if defined(CONFIG_X86) || defined(CONFIG_IA64)
>   void acpi_numa_processor_affinity_init (struct acpi_srat_cpu_affinity *pa);
> +#else
> +static inline void
> +acpi_numa_processor_affinity_init(struct acpi_srat_cpu_affinity *pa) { }
> +#endif
> +
>   void acpi_numa_x2apic_affinity_init(struct acpi_srat_x2apic_cpu_affinity *pa);
> +
> +#ifdef CONFIG_ARM64
> +void acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa);
> +#else
> +static inline void
> +acpi_numa_gicc_affinity_init(struct acpi_srat_gicc_affinity *pa) { }
> +#endif
> +
>   int acpi_numa_memory_affinity_init (struct acpi_srat_mem_affinity *ma);
>
>   #ifndef PHYS_CPUID_INVALID
>
