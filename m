From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Sat, 31 Aug 2013 20:14:24 +0000
Subject: Re: [PATCH 3/6] x86: simplify _acpi_map_lsapic()
Message-Id: <8575859.HxOyLiBtGF@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org> <1377944162-18574-3-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1377944162-18574-3-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Jiang Liu <jiang.liu@huawei.com>

On Saturday, August 31, 2013 06:15:58 PM Hanjun Guo wrote:
> From: Jiang Liu <jiang.liu@huawei.com>
> 
> In acpi_register_lapic(), it will generates a new logical cpu
> number and maps to the local APIC id, this logical cpu number
> can be returned to simplify _acpi_map_lsapic() implementation.
> 
> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> ---
>  arch/x86/include/asm/mpspec.h |    2 +-
>  arch/x86/kernel/acpi/boot.c   |   48 +++++++++++++----------------------------
>  arch/x86/kernel/apic/apic.c   |    8 ++++---
>  3 files changed, 21 insertions(+), 37 deletions(-)
> 
> diff --git a/arch/x86/include/asm/mpspec.h b/arch/x86/include/asm/mpspec.h
> index 626cf70..3142a94 100644
> --- a/arch/x86/include/asm/mpspec.h
> +++ b/arch/x86/include/asm/mpspec.h
> @@ -94,7 +94,7 @@ static inline void early_reserve_e820_mpc_new(void) { }
>  #define default_get_smp_config x86_init_uint_noop
>  #endif
>  
> -void generic_processor_info(int apicid, int version);
> +int generic_processor_info(int apicid, int version);
>  #ifdef CONFIG_ACPI
>  extern void mp_register_ioapic(int id, u32 address, u32 gsi_base);
>  extern void mp_override_legacy_irq(u8 bus_irq, u8 polarity, u8 trigger,
> diff --git a/arch/x86/kernel/acpi/boot.c b/arch/x86/kernel/acpi/boot.c
> index 3e186d1..ca73370 100644
> --- a/arch/x86/kernel/acpi/boot.c
> +++ b/arch/x86/kernel/acpi/boot.c
> @@ -195,24 +195,31 @@ static int __init acpi_parse_madt(struct acpi_table_header *table)
>  	return 0;
>  }
>  
> -static void acpi_register_lapic(int id, u8 enabled)
> +/**
> + * acpi_register_lapic - register a local apic and generates a logic cpu number
> + * @id: local apic id to register
> + * @enabled: this cpu is enabled or not
> + *
> + * Returns the logic cpu number which maps to the local apic
> + */
> +static int acpi_register_lapic(int id, u8 enabled)
>  {
>  	unsigned int ver = 0;
>  
>  	if (id >= (MAX_LOCAL_APIC-1)) {
>  		printk(KERN_INFO PREFIX "skipped apicid that is too big\n");
> -		return;
> +		return -1;
>  	}
>  
>  	if (!enabled) {
>  		++disabled_cpus;
> -		return;
> +		return -1;
>  	}

If this returned -EINVAL instead of just -1, ->

>  
>  	if (boot_cpu_physical_apicid != -1U)
>  		ver = apic_version[boot_cpu_physical_apicid];
>  
> -	generic_processor_info(id, ver);
> +	return generic_processor_info(id, ver);

-> and this too (on errors), -->

>  }
>  
>  static int __init
> @@ -622,44 +629,19 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>  
>  static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
>  {
> -	cpumask_var_t tmp_map, new_map;
>  	int cpu;
> -	int retval = -ENOMEM;
> -
> -	if (!alloc_cpumask_var(&tmp_map, GFP_KERNEL))
> -		goto out;
>  
> -	if (!alloc_cpumask_var(&new_map, GFP_KERNEL))
> -		goto free_tmp_map;
> -
> -	cpumask_copy(tmp_map, cpu_present_mask);
> -	acpi_register_lapic(physid, ACPI_MADT_ENABLED);
> -
> -	/*
> -	 * If acpi_register_lapic successfully generates a new logical cpu
> -	 * number, then the following will get us exactly what was mapped
> -	 */
> -	cpumask_andnot(new_map, cpu_present_mask, tmp_map);
> -	if (cpumask_empty(new_map)) {
> +	cpu = acpi_register_lapic(physid, ACPI_MADT_ENABLED);
> +	if (cpu = -1) {
>  		printk ("Unable to map lapic to logical cpu number\n");
> -		retval = -EINVAL;
> -		goto free_new_map;
> +		return -EINVAL;
>  	}

--> then this could be

	if (cpu < 0) {
		...
		return cpu;
	}

>  
>  	acpi_processor_set_pdc(handle);
> -
> -	cpu = cpumask_first(new_map);
>  	acpi_map_cpu2node(handle, cpu, physid);
>  
>  	*pcpu = cpu;
> -	retval = 0;
> -
> -free_new_map:
> -	free_cpumask_var(new_map);
> -free_tmp_map:
> -	free_cpumask_var(tmp_map);
> -out:
> -	return retval;
> +	return 0;
>  }
>  
>  /* wrapper to silence section mismatch warning */
> diff --git a/arch/x86/kernel/apic/apic.c b/arch/x86/kernel/apic/apic.c
> index eca89c5..87128778 100644
> --- a/arch/x86/kernel/apic/apic.c
> +++ b/arch/x86/kernel/apic/apic.c
> @@ -2107,7 +2107,7 @@ void disconnect_bsp_APIC(int virt_wire_setup)
>  	apic_write(APIC_LVT1, value);
>  }
>  
> -void generic_processor_info(int apicid, int version)
> +int generic_processor_info(int apicid, int version)
>  {
>  	int cpu, max = nr_cpu_ids;
>  	bool boot_cpu_detected = physid_isset(boot_cpu_physical_apicid,
> @@ -2127,7 +2127,7 @@ void generic_processor_info(int apicid, int version)
>  			"  Processor %d/0x%x ignored.\n", max, thiscpu, apicid);
>  
>  		disabled_cpus++;
> -		return;
> +		return -1;
>  	}
>  
>  	if (num_processors >= nr_cpu_ids) {
> @@ -2138,7 +2138,7 @@ void generic_processor_info(int apicid, int version)
>  			"  Processor %d/0x%x ignored.\n", max, thiscpu, apicid);
>  
>  		disabled_cpus++;
> -		return;
> +		return -1;
>  	}
>  
>  	num_processors++;
> @@ -2183,6 +2183,8 @@ void generic_processor_info(int apicid, int version)
>  #endif
>  	set_cpu_possible(cpu, true);
>  	set_cpu_present(cpu, true);
> +
> +	return cpu;
>  }
>  
>  int hard_smp_processor_id(void)
> 
-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
