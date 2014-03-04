From: Hanjun Guo <hanjun.guo@linaro.org>
Date: Tue, 04 Mar 2014 02:28:59 +0000
Subject: Re: [RESEND][PATCH v5 2/5] ACPI / processor_core: Rework _PDC related stuff to make it more arch-ind
Message-Id: <53153A6B.1060205@linaro.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <1392786649-5516-1-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1392786649-5516-1-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Lan Tianyu <tianyu.lan@intel.com>, Joe Perches <joe@perches.com>, linux-acpi@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org, x86@kernel.org, linux-ia64@vger.kernel.org, Graeme Gregory <graeme.gregory@linaro.org>

On 2014年02月19日 13:10, Hanjun Guo wrote:
> _PDC related stuff in processor_core.c is little bit X86/IA64
> dependent, macros of ACPI_PDC_* are _PDC bit definitions for
> Intel processors, if we use these macros in processor_core.c,
> we can not compile it when ACPI is enabled on ARM/ARM64.
>
> This patch reworks the code to make it more arch-independent,
> moving Intel related _PDC bits into architecture directory,
> no functional change.
>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: Fenghua Yu <fenghua.yu@intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: x86@kernel.org
> Cc: linux-ia64@vger.kernel.org
> Signed-off-by: Hanjun Guo <hanjun.guo@linaro.org>
> Signed-off-by: Graeme Gregory <graeme.gregory@linaro.org>
> ---
> Hi Tony, Fenghua, Thomas, Peter, this patch was reviewed
> in ACPI mailling list, and updated for serveral versions,
> Rafael needs your opinion on this patch, could you please
> review and ack it?

Ping...

>
> Thanks
> Hanjun
> ---
>   arch/ia64/include/asm/acpi.h  |    5 +----
>   arch/ia64/kernel/acpi.c       |   14 ++++++++++++++
>   arch/x86/include/asm/acpi.h   |   19 +------------------
>   arch/x86/kernel/acpi/cstate.c |   29 +++++++++++++++++++++++++++++
>   drivers/acpi/processor_core.c |   19 +------------------
>   5 files changed, 46 insertions(+), 40 deletions(-)
>
> diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
> index d651102..d2b8b9d 100644
> --- a/arch/ia64/include/asm/acpi.h
> +++ b/arch/ia64/include/asm/acpi.h
> @@ -152,10 +152,7 @@ extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
>   #endif
>   
>   static inline bool arch_has_acpi_pdc(void) { return true; }
> -static inline void arch_acpi_set_pdc_bits(u32 *buf)
> -{
> -	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
> -}
> +extern void arch_acpi_set_pdc_bits(u32 *buf);
>   
>   #define acpi_unlazy_tlb(x)
>   
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 07d209c..af9d9e4 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -1014,3 +1014,17 @@ EXPORT_SYMBOL(acpi_unregister_ioapic);
>    * TBD when when IA64 starts to support suspend...
>    */
>   int acpi_suspend_lowlevel(void) { return 0; }
> +
> +void arch_acpi_set_pdc_bits(u32 *buf)
> +{
> +	/* Enable coordination with firmware's _TSD info */
> +	buf[2] |= ACPI_PDC_SMP_T_SWCOORD | ACPI_PDC_EST_CAPABILITY_SMP;
> +	if (boot_option_idle_override = IDLE_NOMWAIT) {
> +		/*
> +		 * If mwait is disabled for CPU C-states, the C2C3_FFH access
> +		 * mode will be disabled in the parameter of _PDC object.
> +		 * Of course C1_FFH access mode will also be disabled.
> +		 */
> +		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH | ACPI_PDC_C_C1_FFH);
> +	}
> +}
> diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
> index c8c1e70..e9f71bc 100644
> --- a/arch/x86/include/asm/acpi.h
> +++ b/arch/x86/include/asm/acpi.h
> @@ -147,24 +147,7 @@ static inline bool arch_has_acpi_pdc(void)
>   		c->x86_vendor = X86_VENDOR_CENTAUR);
>   }
>   
> -static inline void arch_acpi_set_pdc_bits(u32 *buf)
> -{
> -	struct cpuinfo_x86 *c = &cpu_data(0);
> -
> -	buf[2] |= ACPI_PDC_C_CAPABILITY_SMP;
> -
> -	if (cpu_has(c, X86_FEATURE_EST))
> -		buf[2] |= ACPI_PDC_EST_CAPABILITY_SWSMP;
> -
> -	if (cpu_has(c, X86_FEATURE_ACPI))
> -		buf[2] |= ACPI_PDC_T_FFH;
> -
> -	/*
> -	 * If mwait/monitor is unsupported, C2/C3_FFH will be disabled
> -	 */
> -	if (!cpu_has(c, X86_FEATURE_MWAIT))
> -		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH);
> -}
> +extern void arch_acpi_set_pdc_bits(u32 *buf);
>   
>   #else /* !CONFIG_ACPI */
>   
> diff --git a/arch/x86/kernel/acpi/cstate.c b/arch/x86/kernel/acpi/cstate.c
> index e69182f..a36638f 100644
> --- a/arch/x86/kernel/acpi/cstate.c
> +++ b/arch/x86/kernel/acpi/cstate.c
> @@ -16,6 +16,35 @@
>   #include <asm/mwait.h>
>   #include <asm/special_insns.h>
>   
> +void arch_acpi_set_pdc_bits(u32 *buf)
> +{
> +	struct cpuinfo_x86 *c = &cpu_data(0);
> +
> +	/* Enable coordination with firmware's _TSD info */
> +	buf[2] |= ACPI_PDC_SMP_T_SWCOORD | ACPI_PDC_C_CAPABILITY_SMP;
> +
> +	if (cpu_has(c, X86_FEATURE_EST))
> +		buf[2] |= ACPI_PDC_EST_CAPABILITY_SWSMP;
> +
> +	if (cpu_has(c, X86_FEATURE_ACPI))
> +		buf[2] |= ACPI_PDC_T_FFH;
> +
> +	/*
> +	 * If mwait/monitor is unsupported, C2/C3_FFH will be disabled
> +	 */
> +	if (!cpu_has(c, X86_FEATURE_MWAIT))
> +		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH);
> +
> +	if (boot_option_idle_override = IDLE_NOMWAIT) {
> +		/*
> +		 * If mwait is disabled for CPU C-states, the C2C3_FFH access
> +		 * mode will be disabled in the parameter of _PDC object.
> +		 * Of course C1_FFH access mode will also be disabled.
> +		 */
> +		buf[2] &= ~(ACPI_PDC_C_C2C3_FFH | ACPI_PDC_C_C1_FFH);
> +	}
> +}
> +
>   /*
>    * Initialize bm_flags based on the CPU cache properties
>    * On SMP it depends on cache configuration
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index 4d91b32..4dcf776 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -255,9 +255,6 @@ static void acpi_set_pdc_bits(u32 *buf)
>   	buf[0] = ACPI_PDC_REVISION_ID;
>   	buf[1] = 1;
>   
> -	/* Enable coordination with firmware's _TSD info */
> -	buf[2] = ACPI_PDC_SMP_T_SWCOORD;
> -
>   	/* Twiddle arch-specific bits needed for _PDC */
>   	arch_acpi_set_pdc_bits(buf);
>   }
> @@ -282,7 +279,7 @@ static struct acpi_object_list *acpi_processor_alloc_pdc(void)
>   		return NULL;
>   	}
>   
> -	buf = kmalloc(12, GFP_KERNEL);
> +	buf = kzalloc(12, GFP_KERNEL);
>   	if (!buf) {
>   		printk(KERN_ERR "Memory allocation error\n");
>   		kfree(obj);
> @@ -310,20 +307,6 @@ acpi_processor_eval_pdc(acpi_handle handle, struct acpi_object_list *pdc_in)
>   {
>   	acpi_status status = AE_OK;
>   
> -	if (boot_option_idle_override = IDLE_NOMWAIT) {
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
>   	status = acpi_evaluate_object(handle, "_PDC", pdc_in, NULL);
>   
>   	if (ACPI_FAILURE(status))

