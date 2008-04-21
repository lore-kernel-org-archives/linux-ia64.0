From: Alex Chiang <achiang@hp.com>
Date: Mon, 21 Apr 2008 05:24:50 +0000
Subject: Re: [PATCH, RFC] Create 'slot' sysfs
Message-Id: <20080421052450.GA24055@ldl.fc.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECCBFA9D@orsmsx424.amr.corp.intel.com> <20080319233140.GD16237@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECE13C6E@orsmsx424.amr.corp.intel.com> <20080326185912.GA30749@ldl.fc.hp.com>
In-Reply-To: <20080326185912.GA30749@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>, lenb@kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Tony,

I noticed that this patch wasn't in the git tree you sent to
Linus for 2.6.26. I don't remember seeing a NACK though -- is
there something that I could rework to make it more acceptable?

Thanks.

/ac

* Alex Chiang <achiang@hp.com>:
> Hi Tony,
> 
> * Luck, Tony <tony.luck@intel.com>:
> > +	if (ACPI_SUCCESS(acpi_get_handle(pr->handle, "_SUN", &handle))) {
> > +		status = acpi_evaluate_object(pr->handle,
> > +						"_SUN", NULL, &buffer);
> > +		if (ACPI_FAILURE(status))
> > +			object.integer.value = -1;
> > +	} else {
> > +		object.integer.value = -1;
> > +	}
> > +	arch_set_topology_slot(pr->id, object.integer.value);
> > +
> >  	if (!object.processor.pblk_address)
> >  		ACPI_DEBUG_PRINT((ACPI_DB_INFO, "No PBLK (NULL address)\n"));
> >  	else if (object.processor.pblk_length != 6)
> > 
> > I'm still seeing these messages:
> > 
> >  "ACPI: Invalid PBLK length [0]"
> > 
> > for every cpu.  Presumably because "object" is a union and when
> > you did the "object.integer.value = -1;" you scribbled on some bits
> > that were needed in the subsequent code.
> 
> Yes, you're right. Sorry about the sloppy code.
> 
> Here is v3. I've verified that:
> 
> 	- it's benign on tiger (does not create errors/console
> 	  noise). You'll still see the -1 if you cat
> 	  /sys/devices/system/cpu/cpuN/topology/slot, but you
> 	  would also get the -1 if you cat physical_package_id
> 
> 	- it does the right thing on platforms that do supply
> 	  _SUN for processor objects. On my rx2600,
> 	  physical_package_id is -1, but I get valid values for
> 	  'slot' now.
> 
> Thanks.
> 
> /ac
> 
> Subject: [PATCH] Create 'slot' sysfs attribute in /sys/devices/system/cpu/cpuN/topology/
> From: Alex Chiang <achiang@hp.com>
> 
> /sys/devices/system/cpu/cpuN/topology/physical_package_id exists,
> but may contain incorrect information, especially on older ia64
> platforms that do not have modern firmware.
> 
> Create a 'slot' attribute and define an interface that may be
> populated via alternate sources, without breaking existing
> functionality.
> 
> Implement this interface on ia64 by invoking the _SUN method on a
> per cpu basis.
> 
> Leave other archs alone for now.
> 
> v2 -> v3:
> 	- Stop stomping on existing PBLK in the event of _SUN failure
> 
> v1 -> v2:
> 	- Check for _SUN object on CPU before blindly attempting
> 	  to call it
> 
> Signed-off-by: Alex Chiang <achiang@hp.com>
> ---
>  arch/ia64/kernel/setup.c      |    1 +
>  arch/ia64/kernel/topology.c   |    6 ++++++
>  drivers/acpi/processor_core.c |    8 ++++++++
>  drivers/base/topology.c       |    9 +++++++++
>  include/asm-ia64/cpu.h        |    1 +
>  include/asm-ia64/processor.h  |    7 ++++++-
>  include/asm-ia64/topology.h   |    3 +++
>  include/asm-x86/topology.h    |    2 ++
>  8 files changed, 36 insertions(+), 1 deletions(-)
> 
> diff --git a/arch/ia64/kernel/setup.c b/arch/ia64/kernel/setup.c
> index 4aa9eae..228d960 100644
> --- a/arch/ia64/kernel/setup.c
> +++ b/arch/ia64/kernel/setup.c
> @@ -735,6 +735,7 @@ identify_cpu (struct cpuinfo_ia64 *c)
>  	 */
>  	c->threads_per_core = c->cores_per_socket = c->num_log = 1;
>  	c->socket_id = -1;
> +	c->slot = -1;
>  
>  	identify_siblings(c);
>  
> diff --git a/arch/ia64/kernel/topology.c b/arch/ia64/kernel/topology.c
> index a2484fc..512de14 100644
> --- a/arch/ia64/kernel/topology.c
> +++ b/arch/ia64/kernel/topology.c
> @@ -27,6 +27,12 @@
>  
>  static struct ia64_cpu *sysfs_cpus;
>  
> +void ia64_set_topology_slot(int num, u32 slot)
> +{
> +	cpu_data(num)->slot = slot;
> +}
> +EXPORT_SYMBOL_GPL(ia64_set_topology_slot);
> +
>  int arch_register_cpu(int num)
>  {
>  #if defined (CONFIG_ACPI) && defined (CONFIG_HOTPLUG_CPU)
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index 36a68fa..a3a740d 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -612,6 +612,14 @@ static int acpi_processor_get_info(struct acpi_processor *pr, unsigned has_uid)
>  		request_region(pr->throttling.address, 6, "ACPI CPU throttle");
>  	}
>  
> +	/*
> +	 * If ACPI describes a slot number for this CPU, let's fill it in
> +	 */
> +	status = acpi_evaluate_object(pr->handle, "_SUN", NULL, &buffer);
> +	if (ACPI_FAILURE(status))
> +		object.integer.value = -1;
> +	arch_set_topology_slot(pr->id, object.integer.value);
> +
>  	return 0;
>  }
>  
> diff --git a/drivers/base/topology.c b/drivers/base/topology.c
> index e1d3ad4..4fcffca 100644
> --- a/drivers/base/topology.c
> +++ b/drivers/base/topology.c
> @@ -57,6 +57,14 @@ define_one_ro(physical_package_id);
>  #define ref_physical_package_id_attr
>  #endif
>  
> +#ifdef	topology_slot
> +define_id_show_func(slot);
> +define_one_ro(slot);
> +#define ref_slot_attr			&attr_slot.attr,
> +#else
> +#define ref_slot_attr
> +#endif
> +
>  #ifdef topology_core_id
>  define_id_show_func(core_id);
>  define_one_ro(core_id);
> @@ -83,6 +91,7 @@ define_one_ro(core_siblings);
>  
>  static struct attribute *default_attrs[] = {
>  	ref_physical_package_id_attr
> +	ref_slot_attr
>  	ref_core_id_attr
>  	ref_thread_siblings_attr
>  	ref_core_siblings_attr
> diff --git a/include/asm-ia64/cpu.h b/include/asm-ia64/cpu.h
> index e87fa32..393e545 100644
> --- a/include/asm-ia64/cpu.h
> +++ b/include/asm-ia64/cpu.h
> @@ -14,6 +14,7 @@ DECLARE_PER_CPU(struct ia64_cpu, cpu_devices);
>  
>  DECLARE_PER_CPU(int, cpu_state);
>  
> +extern void arch_set_topology_slot(int num, u32 slot);
>  extern int arch_register_cpu(int num);
>  #ifdef CONFIG_HOTPLUG_CPU
>  extern void arch_unregister_cpu(int);
> diff --git a/include/asm-ia64/processor.h b/include/asm-ia64/processor.h
> index 741f7ec..066553c 100644
> --- a/include/asm-ia64/processor.h
> +++ b/include/asm-ia64/processor.h
> @@ -125,6 +125,10 @@ struct ia64_psr {
>   */
>  struct cpuinfo_ia64 {
>  	__u32 softirq_pending;
> +
> +#ifdef CONFIG_SMP
> +	int cpu;
> +#endif
>  	__u64 itm_delta;	/* # of clock cycles between clock ticks */
>  	__u64 itm_next;		/* interval timer mask value to use for next clock tick */
>  	__u64 nsec_per_cyc;	/* (1000000000<<IA64_NSEC_PER_CYC_SHIFT)/itc_freq */
> @@ -140,7 +144,6 @@ struct cpuinfo_ia64 {
>  
>  #ifdef CONFIG_SMP
>  	__u64 loops_per_jiffy;
> -	int cpu;
>  	__u32 socket_id;	/* physical processor socket id */
>  	__u16 core_id;		/* core id */
>  	__u16 thread_id;	/* thread id */
> @@ -150,6 +153,8 @@ struct cpuinfo_ia64 {
>  	__u8  threads_per_core;	/* Threads per core */
>  #endif
>  
> +	__u32 slot;		/* physical slot; can differ from socket_id */
> +
>  	/* CPUID-derived information: */
>  	__u64 ppn;
>  	__u64 features;
> diff --git a/include/asm-ia64/topology.h b/include/asm-ia64/topology.h
> index 2d67b72..f986693 100644
> --- a/include/asm-ia64/topology.h
> +++ b/include/asm-ia64/topology.h
> @@ -110,12 +110,15 @@ void build_cpu_to_node_map(void);
>  
>  #ifdef CONFIG_SMP
>  #define topology_physical_package_id(cpu)	(cpu_data(cpu)->socket_id)
> +#define topology_slot(cpu)			(cpu_data(cpu)->slot)
>  #define topology_core_id(cpu)			(cpu_data(cpu)->core_id)
>  #define topology_core_siblings(cpu)		(cpu_core_map[cpu])
>  #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
>  #define smt_capable() 				(smp_num_siblings > 1)
>  #endif
>  
> +#define arch_set_topology_slot(num, slot)	ia64_set_topology_slot(num,slot)
> +
>  #include <asm-generic/topology.h>
>  
>  #endif /* _ASM_IA64_TOPOLOGY_H */
> diff --git a/include/asm-x86/topology.h b/include/asm-x86/topology.h
> index 8af05a9..d4c922c 100644
> --- a/include/asm-x86/topology.h
> +++ b/include/asm-x86/topology.h
> @@ -180,6 +180,8 @@ extern cpumask_t cpu_coregroup_map(int cpu);
>  #define topology_thread_siblings(cpu)		(per_cpu(cpu_sibling_map, cpu))
>  #endif
>  
> +#define arch_set_topology_slot(num, slot)
> +
>  #ifdef CONFIG_SMP
>  #define mc_capable()			(boot_cpu_data.x86_max_cores > 1)
>  #define smt_capable()			(smp_num_siblings > 1)
> -- 
> 1.5.3.1.g1e61
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-acpi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
