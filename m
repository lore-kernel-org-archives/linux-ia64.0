From: Alex Chiang <achiang@hp.com>
Date: Tue, 29 Apr 2008 23:20:37 +0000
Subject: Re: [PATCH 2/2] ia64: Provide ACPI fixup for
Message-Id: <20080429232037.GA3820@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECCBFA9D@orsmsx424.amr.corp.intel.com> <20080319233140.GD16237@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECE13C6E@orsmsx424.amr.corp.intel.com> <20080326185912.GA30749@ldl.fc.hp.com> <20080421052450.GA24055@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843EC012664E0@orsmsx424.amr.corp.intel.com> <20080424184417.GA32553@ldl.fc.hp.com> <20080424185222.GC32553@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843EC0138200C@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0138200C@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: lenb@kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tony,

* Luck, Tony <tony.luck@intel.com>:
> Alex,
> 
> I chewed on this a bit ... 

Thanks for all the fixups -- your version looks a lot nicer!

> diff --git a/include/asm-x86/topology.h b/include/asm-x86/topology.h
> +#define arch_fix_phys_package_id(num, slot)
> 
> Style preference is to now use a "static inline void" function for
> this to make sure args are correctly typed, and to avoid warnings about
> unused variables.

*nod*

I'll use that convention in the future, thanks.

> updated version of the patch looks like this ... ok???

Looks great to me.

/ac

> 
> -Tony
> 
> commit fe086a7bea7ab714930bd48addba961ceeef7634
> Author: Alex Chiang <achiang@hp.com>
> Date:   Tue Apr 29 15:05:29 2008 -0700
> 
>     [IA64] Provide ACPI fixup for /proc/cpuinfo/physical_id
>     
>     Legacy HP ia64 platforms currently cannot provide
>     /proc/cpuinfo/physical_id due to legacy SAL/PAL implementations.
>     However, that physical topology information can be obtained
>     via ACPI.
>     
>     Provide an interface that gives ACPI one last chance to provide
>     physical_id for these legacy platforms. This logic only comes
>     into play iff:
>     
>     - ACPI actually provides slot information for the CPU
>     - we lack a valid socket_id
>     
>     Otherwise, we don't do anything.
>     
>     Since x86 uses the ACPI processor driver as well, we provide a nop
>     stub function for arch_fix_phys_package_id() in asm-x86/topology.h
>     
>     Signed-off-by: Alex Chiang <achiang@hp.com>
>     Signed-off-by: Tony Luck <tony.luck@intel.com>
> 
> diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
> index a2484fc..abb17a6 100644
> --- a/arch/ia64/kernel/topology.c
> +++ b/arch/ia64/kernel/topology.c
> @@ -27,6 +27,15 @@
>  
>  static struct ia64_cpu *sysfs_cpus;
>  
> +void arch_fix_phys_package_id(int num, u32 slot)
> +{
> +#ifdef CONFIG_SMP
> +	if (cpu_data(num)->socket_id = -1)
> +		cpu_data(num)->socket_id = slot;
> +#endif
> +}
> +EXPORT_SYMBOL_GPL(arch_fix_phys_package_id);
> +
>  int arch_register_cpu(int num)
>  {
>  #if defined (CONFIG_ACPI) && defined (CONFIG_HOTPLUG_CPU)
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index dd28c91..5241e3f 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -603,6 +603,15 @@ static int acpi_processor_get_info(struct acpi_processor *pr, unsigned has_uid)
>  		request_region(pr->throttling.address, 6, "ACPI CPU throttle");
>  	}
>  
> +	/*
> +	 * If ACPI describes a slot number for this CPU, we can use it
> +	 * ensure we get the right value in the "physical id" field
> +	 * of /proc/cpuinfo
> +	 */
> +	status = acpi_evaluate_object(pr->handle, "_SUN", NULL, &buffer);
> +	if (ACPI_SUCCESS(status))
> +		arch_fix_phys_package_id(pr->id, object.integer.value);
> +
>  	return 0;
>  }
>  
> diff --git a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
> index f2f72ef..32863b3 100644
> --- a/include/asm-ia64/topology.h
> +++ b/include/asm-ia64/topology.h
> @@ -116,6 +116,8 @@ void build_cpu_to_node_map(void);
>  #define smt_capable() 				(smp_num_siblings > 1)
>  #endif
>  
> +extern void arch_fix_phys_package_id(int num, u32 slot);
> +
>  #define pcibus_to_cpumask(bus)	(pcibus_to_node(bus) = -1 ? \
>  					CPU_MASK_ALL : \
>  					node_to_cpumask(pcibus_to_node(bus)) \
> diff --git a/include/asm-x86/topology.h b/include/asm-x86/topology.h
> index 0e6d6b0..4f35a0f 100644
> --- a/include/asm-x86/topology.h
> +++ b/include/asm-x86/topology.h
> @@ -193,6 +193,10 @@ extern cpumask_t cpu_coregroup_map(int cpu);
>  #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
>  #endif
>  
> +static inline void arch_fix_phys_package_id(int num, u32 slot)
> +{
> +}
> +
>  struct pci_bus;
>  void set_pci_bus_resources_arch_default(struct pci_bus *b);
>  
> 
> 
