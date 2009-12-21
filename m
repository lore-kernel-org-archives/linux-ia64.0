From: Lin Ming <ming.m.lin@intel.com>
Date: Mon, 21 Dec 2009 01:34:52 +0000
Subject: Re: [PATCH v2 01/11] ACPI: processor: call _PDC early
Message-Id: <1261359292.10432.97.camel@minggr.sh.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20091220192731.5545.20582.stgit@bob.kio>
	 <20091220193028.5545.171.stgit@bob.kio>
In-Reply-To: <20091220193028.5545.171.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>
Cc: "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>, "lenb@kernel.org" <lenb@kernel.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 2009-12-21 at 03:30 +0800, Alex Chiang wrote:
> We discovered that at least one machine (HP Envy), methods in the DSDT
> attempt to call external methods defined in a dynamically loaded SSDT.
> 
> Unfortunately, the DSDT methods we are trying to call are part of the
> EC initialization, which happens very early, and the the dynamic SSDT
> is only loaded when a processor _PDC method runs much later.
> 
> This results in namespace lookup errors for the (as of yet) undefined
> methods.
> 
> Since Windows doesn't have any issues with this machine, we take it
> as a hint that they must be evaluating _PDC much earlier than we are.
> 
> Thus, the proper thing for Linux to do should be to match the Windows
> implementation more closely.
> 
> Provide a mechanism to call _PDC before we enable the EC. Doing so loads
> the dynamic tables, and allows the EC to be enabled correctly.
> 
> The ACPI processor driver will still evaluate _PDC in its .add() method
> to cover the hotplug case.
> 
> Resolves: http://bugzilla.kernel.org/show_bug.cgi?id824
> 
> Cc: ming.m.lin@intel.com
> Signed-off-by: Alex Chiang <achiang@hp.com>
> ---
> 
>  drivers/acpi/Makefile         |    1 
>  drivers/acpi/bus.c            |    2 +
>  drivers/acpi/internal.h       |    1 
>  drivers/acpi/processor_core.c |   69 --------------------------
>  drivers/acpi/processor_pdc.c  |  108 +++++++++++++++++++++++++++++++++++++++++
>  include/acpi/processor.h      |    3 +
>  6 files changed, 115 insertions(+), 69 deletions(-)
>  create mode 100644 drivers/acpi/processor_pdc.c
> 
> diff --git a/drivers/acpi/Makefile b/drivers/acpi/Makefile
> index c7b10b4..66cc3f3 100644
> --- a/drivers/acpi/Makefile
> +++ b/drivers/acpi/Makefile
> @@ -32,6 +32,7 @@ acpi-$(CONFIG_ACPI_SLEEP)	+= proc.o
>  #
>  acpi-y				+= bus.o glue.o
>  acpi-y				+= scan.o
> +acpi-y				+= processor_pdc.o
>  acpi-y				+= ec.o
>  acpi-$(CONFIG_ACPI_DOCK)	+= dock.o
>  acpi-y				+= pci_root.o pci_link.o pci_irq.o pci_bind.o
> diff --git a/drivers/acpi/bus.c b/drivers/acpi/bus.c
> index 65f7e33..0bdf24a 100644
> --- a/drivers/acpi/bus.c
> +++ b/drivers/acpi/bus.c
> @@ -888,6 +888,8 @@ static int __init acpi_bus_init(void)
>  		goto error1;
>  	}
>  
> +	acpi_early_processor_set_pdc();

acpi_bus_init(...) {
	acpi_ec_ecdt_probe();

	acpi_initialize_objects(ACPI_FULL_INITIALIZATION);

	acpi_early_processor_set_pdc();

	acpi_boot_ec_enable();
}

EC space handler may be installed in acpi_ec_ecdt_probe or
acpi_boot_ec_enable.
In your machine(HP Envy), EC space handler is installed in
acpi_boot_ec_enable.

It seems that this patch does not fix the problem if EC space hanlder is
installed in acpi_ec_ecdt_probe, right?

But clearly, we can not put acpi_early_processor_set_pdc before
acpi_ec_ecdt_probe because ACPI namespace objects have not been
initialized yet at that time.

Looks like a "chicken or the egg" problem.
Which came first, the chicken or the egg?

Lin Ming

> +
>  	/*
>  	 * Maybe EC region is required at bus_scan/acpi_get_devices. So it
>  	 * is necessary to enable it as early as possible.
> diff --git a/drivers/acpi/internal.h b/drivers/acpi/internal.h
> index 074cf86..cb28e05 100644
> --- a/drivers/acpi/internal.h
> +++ b/drivers/acpi/internal.h
> @@ -43,6 +43,7 @@ int acpi_power_transition(struct acpi_device *device, int state);
>  extern int acpi_power_nocheck;
>  
>  int acpi_wakeup_device_init(void);
> +void acpi_early_processor_set_pdc(void);
>  
>  /* --------------------------------------------------------------------------
>                                    Embedded Controller
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index 4173123..a19a4ff 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -124,29 +124,6 @@ static const struct file_operations acpi_processor_info_fops = {
>  
>  DEFINE_PER_CPU(struct acpi_processor *, processors);
>  struct acpi_processor_errata errata __read_mostly;
> -static int set_no_mwait(const struct dmi_system_id *id)
> -{
> -	printk(KERN_NOTICE PREFIX "%s detected - "
> -		"disabling mwait for CPU C-states\n", id->ident);
> -	idle_nomwait = 1;
> -	return 0;
> -}
> -
> -static struct dmi_system_id __cpuinitdata processor_idle_dmi_table[] = {
> -	{
> -	set_no_mwait, "IFL91 board", {
> -	DMI_MATCH(DMI_BIOS_VENDOR, "COMPAL"),
> -	DMI_MATCH(DMI_SYS_VENDOR, "ZEPTO"),
> -	DMI_MATCH(DMI_PRODUCT_VERSION, "3215W"),
> -	DMI_MATCH(DMI_BOARD_NAME, "IFL91") }, NULL},
> -	{
> -	set_no_mwait, "Extensa 5220", {
> -	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
> -	DMI_MATCH(DMI_SYS_VENDOR, "Acer"),
> -	DMI_MATCH(DMI_PRODUCT_VERSION, "0100"),
> -	DMI_MATCH(DMI_BOARD_NAME, "Columbia") }, NULL},
> -	{},
> -};
>  
>  /* --------------------------------------------------------------------------
>                                  Errata Handling
> @@ -277,45 +254,6 @@ static int acpi_processor_errata(struct acpi_processor *pr)
>  }
>  
>  /* --------------------------------------------------------------------------
> -                              Common ACPI processor functions
> -   -------------------------------------------------------------------------- */
> -
> -/*
> - * _PDC is required for a BIOS-OS handshake for most of the newer
> - * ACPI processor features.
> - */
> -static int acpi_processor_set_pdc(struct acpi_processor *pr)
> -{
> -	struct acpi_object_list *pdc_in = pr->pdc;
> -	acpi_status status = AE_OK;
> -
> -
> -	if (!pdc_in)
> -		return status;
> -	if (idle_nomwait) {
> -		/*
> -		 * If mwait is disabled for CPU C-states, the C2C3_FFH access
> -		 * mode will be disabled in the parameter of _PDC object.
> -		 * Of course C1_FFH access mode will also be disabled.
> -		 */
> -		union acpi_object *obj;
> -		u32 *buffer = NULL;
> -
> -		obj = pdc_in->pointer;
> -		buffer = (u32 *)(obj->buffer.pointer);
> -		buffer[2] &= ~(ACPI_PDC_C_C2C3_FFH | ACPI_PDC_C_C1_FFH);
> -
> -	}
> -	status = acpi_evaluate_object(pr->handle, "_PDC", pdc_in, NULL);
> -
> -	if (ACPI_FAILURE(status))
> -		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
> -		    "Could not evaluate _PDC, using legacy perf. control...\n"));
> -
> -	return status;
> -}
> -
> -/* --------------------------------------------------------------------------
>                                FS Interface (/proc)
>     -------------------------------------------------------------------------- */
>  
> @@ -825,9 +763,7 @@ static int __cpuinit acpi_processor_add(struct acpi_device *device)
>  	}
>  
>  	/* _PDC call should be done before doing anything else (if reqd.). */
> -	arch_acpi_processor_init_pdc(pr);
>  	acpi_processor_set_pdc(pr);
> -	arch_acpi_processor_cleanup_pdc(pr);
>  
>  #ifdef CONFIG_CPU_FREQ
>  	acpi_processor_ppc_has_changed(pr, 0);
> @@ -1145,11 +1081,6 @@ static int __init acpi_processor_init(void)
>  	if (!acpi_processor_dir)
>  		return -ENOMEM;
>  #endif
> -	/*
> -	 * Check whether the system is DMI table. If yes, OSPM
> -	 * should not use mwait for CPU-states.
> -	 */
> -	dmi_check_system(processor_idle_dmi_table);
>  	result = cpuidle_register_driver(&acpi_idle_driver);
>  	if (result < 0)
>  		goto out_proc;
> diff --git a/drivers/acpi/processor_pdc.c b/drivers/acpi/processor_pdc.c
> new file mode 100644
> index 0000000..b416c32
> --- /dev/null
> +++ b/drivers/acpi/processor_pdc.c
> @@ -0,0 +1,108 @@
> +#include <linux/dmi.h>
> +
> +#include <acpi/acpi_drivers.h>
> +#include <acpi/processor.h>
> +
> +#include "internal.h"
> +
> +#define PREFIX			"ACPI: "
> +#define _COMPONENT		ACPI_PROCESSOR_COMPONENT
> +ACPI_MODULE_NAME("processor_pdc");
> +
> +static int set_no_mwait(const struct dmi_system_id *id)
> +{
> +	printk(KERN_NOTICE PREFIX "%s detected - "
> +		"disabling mwait for CPU C-states\n", id->ident);
> +	idle_nomwait = 1;
> +	return 0;
> +}
> +
> +static struct dmi_system_id __cpuinitdata processor_idle_dmi_table[] = {
> +	{
> +	set_no_mwait, "IFL91 board", {
> +	DMI_MATCH(DMI_BIOS_VENDOR, "COMPAL"),
> +	DMI_MATCH(DMI_SYS_VENDOR, "ZEPTO"),
> +	DMI_MATCH(DMI_PRODUCT_VERSION, "3215W"),
> +	DMI_MATCH(DMI_BOARD_NAME, "IFL91") }, NULL},
> +	{
> +	set_no_mwait, "Extensa 5220", {
> +	DMI_MATCH(DMI_BIOS_VENDOR, "Phoenix Technologies LTD"),
> +	DMI_MATCH(DMI_SYS_VENDOR, "Acer"),
> +	DMI_MATCH(DMI_PRODUCT_VERSION, "0100"),
> +	DMI_MATCH(DMI_BOARD_NAME, "Columbia") }, NULL},
> +	{},
> +};
> +
> +/*
> + * _PDC is required for a BIOS-OS handshake for most of the newer
> + * ACPI processor features.
> + */
> +static int acpi_processor_eval_pdc(struct acpi_processor *pr)
> +{
> +	struct acpi_object_list *pdc_in = pr->pdc;
> +	acpi_status status = AE_OK;
> +
> +	if (!pdc_in)
> +		return status;
> +	if (idle_nomwait) {
> +		/*
> +		 * If mwait is disabled for CPU C-states, the C2C3_FFH access
> +		 * mode will be disabled in the parameter of _PDC object.
> +		 * Of course C1_FFH access mode will also be disabled.
> +		 */
> +		union acpi_object *obj;
> +		u32 *buffer = NULL;
> +
> +		obj = pdc_in->pointer;
> +		buffer = (u32 *)(obj->buffer.pointer);
> +		buffer[2] &= ~(ACPI_PDC_C_C2C3_FFH | ACPI_PDC_C_C1_FFH);
> +
> +	}
> +	status = acpi_evaluate_object(pr->handle, "_PDC", pdc_in, NULL);
> +
> +	if (ACPI_FAILURE(status))
> +		ACPI_DEBUG_PRINT((ACPI_DB_INFO,
> +		    "Could not evaluate _PDC, using legacy perf. control.\n"));
> +
> +	return status;
> +}
> +
> +void acpi_processor_set_pdc(struct acpi_processor *pr)
> +{
> +	arch_acpi_processor_init_pdc(pr);
> +	acpi_processor_eval_pdc(pr);
> +	arch_acpi_processor_cleanup_pdc(pr);
> +}
> +EXPORT_SYMBOL_GPL(acpi_processor_set_pdc);
> +
> +static acpi_status
> +early_init_pdc(acpi_handle handle, u32 lvl, void *context, void **rv)
> +{
> +	struct acpi_processor pr;
> +
> +	pr.handle = handle;
> +
> +	/* x86 implementation looks at pr.id to determine some
> +	 * CPU capabilites. We can just hard code to 0 since we're
> +	 * assuming the CPUs in the system are homogenous and all
> +	 * have the same capabilities.
> +	 */
> +	pr.id = 0;
> +
> +	acpi_processor_set_pdc(&pr);
> +
> +	return AE_OK;
> +}
> +
> +void acpi_early_processor_set_pdc(void)
> +{
> +	/*
> +	 * Check whether the system is DMI table. If yes, OSPM
> +	 * should not use mwait for CPU-states.
> +	 */
> +	dmi_check_system(processor_idle_dmi_table);
> +
> +	acpi_walk_namespace(ACPI_TYPE_PROCESSOR, ACPI_ROOT_OBJECT,
> +			    ACPI_UINT32_MAX,
> +			    early_init_pdc, NULL, NULL, NULL);
> +}
> diff --git a/include/acpi/processor.h b/include/acpi/processor.h
> index 29245c6..a1b748a 100644
> --- a/include/acpi/processor.h
> +++ b/include/acpi/processor.h
> @@ -325,6 +325,9 @@ static inline int acpi_processor_get_bios_limit(int cpu, unsigned int *limit)
>  
>  #endif				/* CONFIG_CPU_FREQ */
>  
> +/* in processor_pdc.c */
> +void acpi_processor_set_pdc(struct acpi_processor *pr);
> +
>  /* in processor_throttling.c */
>  int acpi_processor_tstate_has_changed(struct acpi_processor *pr);
>  int acpi_processor_get_throttling_info(struct acpi_processor *pr);
> 

