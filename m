From: Grant Likely <grant.likely@linaro.org>
Date: Tue, 29 Apr 2014 09:36:37 +0000
Subject: Re: [PATCH v3 part1 01/11] ACPI / processor: Rework _PDC related stuff to make it more arch-independ
Message-Id: <20140429093637.75573C4095B@trevor.secretlab.ca>
List-Id: <linux-ia64.vger.kernel.org>
References: <1398432017-8506-1-git-send-email-hanjun.guo@linaro.org>
	<1398432017-8506-2-git-send-email-hanjun.guo@linaro.org>
In-Reply-To: <1398432017-8506-2-git-send-email-hanjun.guo@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Catalin Marinas <catalin.marinas@arm.com>, Arnd Bergmann <arnd@arndb.de>, Mark Brown <broonie@linaro.org>, Sudeep Holla <Sudeep.Holla@arm.com>, Olof Johansson <olof@lixom.net>, Mark Rutland <mark.rutland@arm.com>, Rob Herring <robh@kernel.org>, Will Deacon <will.deacon@arm.com>, Charles.Garcia-Tobin@arm.com, linaro-acpi@lists.linaro.org, Hanjun Guo <hanjun.guo@linaro.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-ia64@vger.kernel.org, Graeme Gregory <graeme.gregory@linaro.org>

On Fri, 25 Apr 2014 21:20:07 +0800, Hanjun Guo <hanjun.guo@linaro.org> wrote:
> _PDC related stuff in processor_core.c is little bit X86/IA64
> dependent, macros of ACPI_PDC_* are _PDC bit definitions for
> Intel processors, if we use these macros in processor_core.c,
> we will meet compile error when ACPI is enabled on ARM64.
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
>  arch/ia64/include/asm/acpi.h  |    5 +----
>  arch/ia64/kernel/acpi.c       |   15 +++++++++++++++
>  arch/x86/include/asm/acpi.h   |   19 +------------------
>  arch/x86/kernel/acpi/cstate.c |   27 +++++++++++++++++++++++++++
>  drivers/acpi/processor_core.c |   19 +------------------
>  5 files changed, 45 insertions(+), 40 deletions(-)
> 
> diff --git a/arch/ia64/include/asm/acpi.h b/arch/ia64/include/asm/acpi.h
> index d651102..d2b8b9d 100644
> --- a/arch/ia64/include/asm/acpi.h
> +++ b/arch/ia64/include/asm/acpi.h
> @@ -152,10 +152,7 @@ extern int __initdata nid_to_pxm_map[MAX_NUMNODES];
>  #endif
>  
>  static inline bool arch_has_acpi_pdc(void) { return true; }
> -static inline void arch_acpi_set_pdc_bits(u32 *buf)
> -{
> -	buf[2] |= ACPI_PDC_EST_CAPABILITY_SMP;
> -}
> +extern void arch_acpi_set_pdc_bits(u32 *buf);
>  
>  #define acpi_unlazy_tlb(x)
>  
> diff --git a/arch/ia64/kernel/acpi.c b/arch/ia64/kernel/acpi.c
> index 0d407b3..23e9b40 100644
> --- a/arch/ia64/kernel/acpi.c
> +++ b/arch/ia64/kernel/acpi.c
> @@ -996,3 +996,18 @@ EXPORT_SYMBOL(acpi_unregister_ioapic);
>   * TBD when when IA64 starts to support suspend...
>   */
>  int acpi_suspend_lowlevel(void) { return 0; }
> +
> +void arch_acpi_set_pdc_bits(u32 *buf)
> +{
> +	/* Enable coordination with firmware's _TSD info */
> +	buf[2] |= ACPI_PDC_SMP_T_SWCOORD | ACPI_PDC_EST_CAPABILITY_SMP;
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

The commit text makes no comment about why this function is being moved
from a static inline to an extern in the acpi.c file. I assume it is
because it needs access to the boot_option_idle_override global
variable, but it isn't immediately obvious, and should be described in
the commit text.

Otherwise, the patch looks sane.

Reviewed-by: Grant Likely <grant.likely@linaro.org>

> diff --git a/arch/x86/include/asm/acpi.h b/arch/x86/include/asm/acpi.h
> index c8c1e70..e9f71bc 100644
> --- a/arch/x86/include/asm/acpi.h
> +++ b/arch/x86/include/asm/acpi.h
> @@ -147,24 +147,7 @@ static inline bool arch_has_acpi_pdc(void)
>  		c->x86_vendor = X86_VENDOR_CENTAUR);
>  }
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
>  #else /* !CONFIG_ACPI */
>  
> diff --git a/arch/x86/kernel/acpi/cstate.c b/arch/x86/kernel/acpi/cstate.c
> index 4b28159..95127d0 100644
> --- a/arch/x86/kernel/acpi/cstate.c
> +++ b/arch/x86/kernel/acpi/cstate.c
> @@ -16,6 +16,33 @@
>  #include <asm/mwait.h>
>  #include <asm/special_insns.h>
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
> +	/* If mwait/monitor is unsupported, C2/C3_FFH will be disabled */
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
>  /*
>   * Initialize bm_flags based on the CPU cache properties
>   * On SMP it depends on cache configuration
> diff --git a/drivers/acpi/processor_core.c b/drivers/acpi/processor_core.c
> index 71e2065..5250327 100644
> --- a/drivers/acpi/processor_core.c
> +++ b/drivers/acpi/processor_core.c
> @@ -254,9 +254,6 @@ static void acpi_set_pdc_bits(u32 *buf)
>  	buf[0] = ACPI_PDC_REVISION_ID;
>  	buf[1] = 1;
>  
> -	/* Enable coordination with firmware's _TSD info */
> -	buf[2] = ACPI_PDC_SMP_T_SWCOORD;
> -
>  	/* Twiddle arch-specific bits needed for _PDC */
>  	arch_acpi_set_pdc_bits(buf);
>  }
> @@ -281,7 +278,7 @@ static struct acpi_object_list *acpi_processor_alloc_pdc(void)
>  		return NULL;
>  	}
>  
> -	buf = kmalloc(12, GFP_KERNEL);
> +	buf = kzalloc(12, GFP_KERNEL);
>  	if (!buf) {
>  		printk(KERN_ERR "Memory allocation error\n");
>  		kfree(obj);
> @@ -309,20 +306,6 @@ acpi_processor_eval_pdc(acpi_handle handle, struct acpi_object_list *pdc_in)
>  {
>  	acpi_status status = AE_OK;
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
>  	status = acpi_evaluate_object(handle, "_PDC", pdc_in, NULL);
>  
>  	if (ACPI_FAILURE(status))
> -- 
> 1.7.9.5
> 

