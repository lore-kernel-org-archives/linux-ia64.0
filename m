From: Luca Tettamanti <kronos.it@gmail.com>
Date: Tue, 31 Jul 2007 20:33:12 +0000
Subject: Re: [PATCH] - SN: Add support for CPU disable
Message-Id: <20070731203312.GA19588@dreamland.darkstar.lan>
List-Id: <linux-ia64.vger.kernel.org>
In-Reply-To: <20070731194505.24177.41215.89690@attica.americas.sgi.com>
References: <20070731194505.24177.41215.89690@attica.americas.sgi.com>
In-Reply-To: <20070731194505.24177.41215.89690@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: John Keller <jpk@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org

Hi,
I've a couple of comments on the patch:

John Keller <jpk@sgi.com> ha scritto:
> Index: linux-2.6/arch/ia64/sn/kernel/huberror.c
> =================================> --- linux-2.6.orig/arch/ia64/sn/kernel/huberror.c       2007-07-31 09:09:55.414522005 -0500
> +++ linux-2.6/arch/ia64/sn/kernel/huberror.c    2007-07-31 09:38:14.634045360 -0500
> @@ -14,6 +14,7 @@
> #include <asm/sn/addrs.h>
> #include <asm/sn/shubio.h>
> #include <asm/sn/geo.h>
> +#include <asm/sn/sn_feature_sets.h>
> #include "xtalk/xwidgetdev.h"
> #include "xtalk/hubdev.h"
> #include <asm/sn/bte.h>
> @@ -185,11 +186,22 @@ void hubiio_crb_error_handler(struct hub
>  */
> void hub_error_init(struct hubdev_info *hubdev_info)
> {
> +
>        if (request_irq(SGI_II_ERROR, hub_eint_handler, IRQF_SHARED,
> -                       "SN_hub_error", (void *)hubdev_info))
> +                       "SN_hub_error", (void *)hubdev_info)) {
>                printk("hub_error_init: Failed to request_irq for 0x%p\n",
>                    hubdev_info);
> -       return;
> +               return;
> +       }
> +
> +#ifdef CONFIG_SMP
> +       /*
> +        * On systems which support CPU disabling (SHub2), all error interrupts
> +        * are targetted at the boot CPU.
> +        */
> +       if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
> +               set_irq_affinity_info(SGI_II_ERROR, 0, 0);
> +#endif

This snippet is repeated many times. You may want to use an inline
helper (defined as no-op for !CONFIG_SMP), something like this:

#ifdef CONFIG_SMP
static inline void migrate_error_int(void)
{
        /*
         * On systems which support CPU disabling (SHub2), all error interrupts
         * are targetted at the boot CPU.
         */
         if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
                set_irq_affinity_info(SGI_II_ERROR, 0, 0);
}
#else
static inline void migrate_error_int(void) { }
#endif

As as bonus you remove the #ifdef from the main code.

> --- linux-2.6.orig/arch/ia64/sn/kernel/sn2/sn2_smp.c    2007-07-31 09:09:55.418522496 -0500
> +++ linux-2.6/arch/ia64/sn/kernel/sn2/sn2_smp.c 2007-07-31 09:38:14.782063615 -0500
> @@ -40,6 +40,7 @@
> #include <asm/sn/shub_mmr.h>
> #include <asm/sn/nodepda.h>
> #include <asm/sn/rw_mmr.h>
> +#include <asm/sn/sn_feature_sets.h>
> 
> DEFINE_PER_CPU(struct ptc_stats, ptcstats);
> DECLARE_PER_CPU(struct ptc_stats, ptcstats);
> @@ -429,6 +430,29 @@ void sn2_send_IPI(int cpuid, int vector,
>        sn_send_IPI_phys(nasid, physid, vector, delivery_mode);
> }
> 
> +#ifdef CONFIG_HOTPLUG_CPU
> +/**
> + * sn_cpu_disable_allowed - Determine if a CPU can be disabled.
> + * @cpu - CPU that is requested to be disabled.
> + *
> + * CPU disable is only allowed on SHub2 systems running with a PROM
> + * that supports CPU disable. It is not permitted to disable the boot processor.
> + */
> +bool sn_cpu_disable_allowed(int cpu)
> +{
> +       if (is_shub2() && sn_prom_feature_available(PRF_CPU_DISABLE_SUPPORT))
> +               if (cpu != 0)
> +                       return true;
> +               else
> +                       printk("Disabling the boot processor is not allowed.\n");
> +
> +       else

Hum, brackets around the inner if statement?

Luca
-- 
Let me make your mind, leave yourself behind
Be not afraid
