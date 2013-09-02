From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Mon, 02 Sep 2013 02:13:54 +0000
Subject: Re: [PATCH 3/6] x86: simplify _acpi_map_lsapic()
Message-Id: <5223F462.7090500@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1377944162-18574-1-git-send-email-hanjun.guo@linaro.org> <1377944162-18574-3-git-send-email-hanjun.guo@linaro.org> <8575859.HxOyLiBtGF@vostro.rjw.lan>
In-Reply-To: <8575859.HxOyLiBtGF@vostro.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Ingo Molnar <mingo@redhat.com>, linux-acpi@vger.kernel.org, x86@kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, patches@linaro.org, linaro-kernel@lists.linaro.org, linaro-acpi@lists.linaro.org, Jiang Liu <jiang.liu@huawei.com>

On 2013-9-1 4:14, Rafael J. Wysocki wrote:
> On Saturday, August 31, 2013 06:15:58 PM Hanjun Guo wrote:
[...]
>> +static int acpi_register_lapic(int id, u8 enabled)
>>  {
>>  	unsigned int ver = 0;
>>  
>>  	if (id >= (MAX_LOCAL_APIC-1)) {
>>  		printk(KERN_INFO PREFIX "skipped apicid that is too big\n");
>> -		return;
>> +		return -1;
>>  	}
>>  
>>  	if (!enabled) {
>>  		++disabled_cpus;
>> -		return;
>> +		return -1;
>>  	}
> 
> If this returned -EINVAL instead of just -1, ->
> 
>>  
>>  	if (boot_cpu_physical_apicid != -1U)
>>  		ver = apic_version[boot_cpu_physical_apicid];
>>  
>> -	generic_processor_info(id, ver);
>> +	return generic_processor_info(id, ver);
> 
> -> and this too (on errors), -->
> 
>>  }
>>  
>>  static int __init
>> @@ -622,44 +629,19 @@ static void acpi_map_cpu2node(acpi_handle handle, int cpu, int physid)
>>  
>>  static int _acpi_map_lsapic(acpi_handle handle, int physid, int *pcpu)
>>  {
>> -	cpumask_var_t tmp_map, new_map;
>>  	int cpu;
>> -	int retval = -ENOMEM;
>> -
>> -	if (!alloc_cpumask_var(&tmp_map, GFP_KERNEL))
>> -		goto out;
>>  
>> -	if (!alloc_cpumask_var(&new_map, GFP_KERNEL))
>> -		goto free_tmp_map;
>> -
>> -	cpumask_copy(tmp_map, cpu_present_mask);
>> -	acpi_register_lapic(physid, ACPI_MADT_ENABLED);
>> -
>> -	/*
>> -	 * If acpi_register_lapic successfully generates a new logical cpu
>> -	 * number, then the following will get us exactly what was mapped
>> -	 */
>> -	cpumask_andnot(new_map, cpu_present_mask, tmp_map);
>> -	if (cpumask_empty(new_map)) {
>> +	cpu = acpi_register_lapic(physid, ACPI_MADT_ENABLED);
>> +	if (cpu = -1) {
>>  		printk ("Unable to map lapic to logical cpu number\n");
>> -		retval = -EINVAL;
>> -		goto free_new_map;
>> +		return -EINVAL;
>>  	}
> 
> --> then this could be
> 
> 	if (cpu < 0) {
> 		...
> 		return cpu;
> 	}

Thanks for the suggestion, and I find out some grammar mistake in the
changelog too, I will update this patch set and send out soon.

Thanks
Hanjun

