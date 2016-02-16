From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Date: Tue, 16 Feb 2016 20:13:09 +0000
Subject: Re: [PATCH v3 2/5] ACPI / sleep: move acpi_processor_sleep to sleep.c
Message-Id: <2288656.HghHDFBFlP@vostro.rjw.lan>
List-Id: <linux-ia64.vger.kernel.org>
References: <1449065446-26115-1-git-send-email-sudeep.holla@arm.com> <1449065446-26115-3-git-send-email-sudeep.holla@arm.com>
In-Reply-To: <1449065446-26115-3-git-send-email-sudeep.holla@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sudeep Holla <sudeep.holla@arm.com>
Cc: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, x86@kernel.org, Al Stone <al.stone@linaro.org>, Lorenzo Pieralisi <Lorenzo.Pieralisi@arm.com>, Mahesh Sivasubramanian <msivasub@codeaurora.org>, Ashwin Chaugule <ashwin.chaugule@linaro.org>, Prashanth Prakash <pprakash@codeaurora.org>

On Wednesday, December 02, 2015 02:10:43 PM Sudeep Holla wrote:
> acpi_processor_sleep is neither related nor used by CPUIdle framework.
> It's used in system suspend/resume path as a syscore operation. It makes
> more sense to move it to acpi/sleep.c where all the S-state transition
> (a.k.a. Linux system suspend/hiberate) related code are present.
> 
> Also make it depend on CONFIG_ACPI_SYSTEM_POWER_STATES_SUPPORT so that
> it's not compiled on architecture like ARM64 where S-states are not
> yet defined in ACPI.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Signed-off-by: Sudeep Holla <sudeep.holla@arm.com>

To me this goes in the right direction, but I'd take it a bit further.

> ---
>  drivers/acpi/processor_driver.c |  2 --
>  drivers/acpi/processor_idle.c   | 37 -------------------------------------
>  drivers/acpi/sleep.c            | 35 +++++++++++++++++++++++++++++++++++
>  include/acpi/processor.h        |  8 --------
>  4 files changed, 35 insertions(+), 47 deletions(-)
> 
> diff --git a/drivers/acpi/processor_driver.c b/drivers/acpi/processor_driver.c
> index f4e02ae93f58..29f787b2493f 100644
> --- a/drivers/acpi/processor_driver.c
> +++ b/drivers/acpi/processor_driver.c
> @@ -313,7 +313,6 @@ static int __init acpi_processor_driver_init(void)
>  	if (result < 0)
>  		return result;
>  
> -	acpi_processor_syscore_init();
>  	register_hotcpu_notifier(&acpi_cpu_notifier);
>  	acpi_thermal_cpufreq_init();
>  	acpi_processor_ppc_init();
> @@ -329,7 +328,6 @@ static void __exit acpi_processor_driver_exit(void)
>  	acpi_processor_ppc_exit();
>  	acpi_thermal_cpufreq_exit();
>  	unregister_hotcpu_notifier(&acpi_cpu_notifier);
> -	acpi_processor_syscore_exit();
>  	driver_unregister(&acpi_processor_driver);
>  }
>  
> diff --git a/drivers/acpi/processor_idle.c b/drivers/acpi/processor_idle.c
> index 175c86bee3a9..a24067b850d2 100644
> --- a/drivers/acpi/processor_idle.c
> +++ b/drivers/acpi/processor_idle.c
> @@ -30,7 +30,6 @@
>  #include <linux/sched.h>       /* need_resched() */
>  #include <linux/tick.h>
>  #include <linux/cpuidle.h>
> -#include <linux/syscore_ops.h>
>  #include <acpi/processor.h>
>  
>  /*
> @@ -194,42 +193,6 @@ static void lapic_timer_state_broadcast(struct acpi_processor *pr,
>  
>  #endif
>  
> -#ifdef CONFIG_PM_SLEEP
> -static u32 saved_bm_rld;
> -
> -static int acpi_processor_suspend(void)
> -{
> -	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &saved_bm_rld);
> -	return 0;
> -}
> -
> -static void acpi_processor_resume(void)
> -{
> -	u32 resumed_bm_rld = 0;
> -
> -	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &resumed_bm_rld);
> -	if (resumed_bm_rld = saved_bm_rld)
> -		return;
> -
> -	acpi_write_bit_register(ACPI_BITREG_BUS_MASTER_RLD, saved_bm_rld);
> -}
> -
> -static struct syscore_ops acpi_processor_syscore_ops = {
> -	.suspend = acpi_processor_suspend,
> -	.resume = acpi_processor_resume,
> -};
> -
> -void acpi_processor_syscore_init(void)
> -{
> -	register_syscore_ops(&acpi_processor_syscore_ops);
> -}
> -
> -void acpi_processor_syscore_exit(void)
> -{
> -	unregister_syscore_ops(&acpi_processor_syscore_ops);
> -}
> -#endif /* CONFIG_PM_SLEEP */
> -
>  #if defined(CONFIG_X86)
>  static void tsc_check_state(int state)
>  {
> diff --git a/drivers/acpi/sleep.c b/drivers/acpi/sleep.c
> index 0d94621dc856..73604d8ccfad 100644
> --- a/drivers/acpi/sleep.c
> +++ b/drivers/acpi/sleep.c
> @@ -19,6 +19,7 @@
>  #include <linux/reboot.h>
>  #include <linux/acpi.h>
>  #include <linux/module.h>
> +#include <linux/syscore_ops.h>
>  #include <asm/io.h>
>  #include <trace/events/power.h>
>  
> @@ -677,6 +678,39 @@ static void acpi_sleep_suspend_setup(void)
>  static inline void acpi_sleep_suspend_setup(void) {}
>  #endif /* !CONFIG_SUSPEND */
>  
> +#ifdef CONFIG_PM_SLEEP
> +static u32 saved_bm_rld;
> +
> +static int acpi_processor_suspend(void)

Why do we need mention processor in the function name here (and below)?

I'd call it something like acpi_save/restore_bm_rld() (maybe with a short comment
explaining what the BM RLD is).

> +{
> +	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &saved_bm_rld);
> +	return 0;
> +}
> +
> +static void acpi_processor_resume(void)
> +{
> +	u32 resumed_bm_rld = 0;
> +
> +	acpi_read_bit_register(ACPI_BITREG_BUS_MASTER_RLD, &resumed_bm_rld);
> +	if (resumed_bm_rld = saved_bm_rld)
> +		return;
> +
> +	acpi_write_bit_register(ACPI_BITREG_BUS_MASTER_RLD, saved_bm_rld);
> +}
> +
> +static struct syscore_ops acpi_processor_syscore_ops = {
> +	.suspend = acpi_processor_suspend,
> +	.resume = acpi_processor_resume,
> +};
> +
> +void acpi_processor_syscore_init(void)
> +{
> +	register_syscore_ops(&acpi_processor_syscore_ops);
> +}
> +#else
> +static inline void acpi_processor_syscore_init(void) {}
> +#endif /* CONFIG_PM_SLEEP */
> +
>  #ifdef CONFIG_HIBERNATION
>  static unsigned long s4_hardware_signature;
>  static struct acpi_table_facs *facs;
> @@ -839,6 +873,7 @@ int __init acpi_sleep_init(void)
>  
>  	sleep_states[ACPI_STATE_S0] = 1;
>  
> +	acpi_processor_syscore_init();
>  	acpi_sleep_suspend_setup();
>  	acpi_sleep_hibernate_setup();
>  
> diff --git a/include/acpi/processor.h b/include/acpi/processor.h
> index 54d7860cac11..6f1805dd5d3c 100644
> --- a/include/acpi/processor.h
> +++ b/include/acpi/processor.h
> @@ -395,14 +395,6 @@ static inline int acpi_processor_hotplug(struct acpi_processor *pr)
>  }
>  #endif /* CONFIG_ACPI_PROCESSOR_IDLE */
>  
> -#if defined(CONFIG_PM_SLEEP) & defined(CONFIG_ACPI_PROCESSOR_IDLE)
> -void acpi_processor_syscore_init(void);
> -void acpi_processor_syscore_exit(void);
> -#else
> -static inline void acpi_processor_syscore_init(void) {}
> -static inline void acpi_processor_syscore_exit(void) {}
> -#endif
> -
>  /* in processor_thermal.c */
>  int acpi_processor_get_limit_info(struct acpi_processor *pr);
>  extern const struct thermal_cooling_device_ops processor_cooling_ops;
> 

Thanks,
Rafael

