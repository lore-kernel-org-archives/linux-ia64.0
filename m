From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Thu, 21 Feb 2008 23:22:54 +0000
Subject: Re: [PATCH 19/28] ia64/xen: xen domU irq chip introducing some helper
Message-Id: <47BE07CE.5090008@goop.org>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

yamahata@valinux.co.jp wrote:
> diff --git a/arch/ia64/kernel/irq_ia64.c b/arch/ia64/kernel/irq_ia64.c
> index 0b52f19..b5dcb49 100644
> --- a/arch/ia64/kernel/irq_ia64.c
> +++ b/arch/ia64/kernel/irq_ia64.c
> @@ -30,6 +30,9 @@
>  #include <linux/threads.h>
>  #include <linux/bitops.h>
>  #include <linux/irq.h>
> +#ifdef CONFIG_XEN
> +#include <linux/cpu.h>
> +#endif
>  
>  #include <asm/delay.h>
>  #include <asm/intrinsics.h>
> @@ -204,6 +207,13 @@ assign_irq_vector (int irq)
>  
>  	vector = -ENOSPC;
>  
> +#ifdef CONFIG_XEN
> +	if (is_running_on_xen()) {
> +		extern int xen_assign_irq_vector(int);
> +		return xen_assign_irq_vector(irq);
> +	}
> +#endif
>   

No extern prototypes in .c files; definitely not nested in block scope 
(here and elsewhere in the series).

> +static char timer_name[NR_CPUS][15];
> +static char ipi_name[NR_CPUS][15];
> +static char resched_name[NR_CPUS][15];
> +static char cmc_name[NR_CPUS][15];
> +static char cmcp_name[NR_CPUS][15];
> +static char cpep_name[NR_CPUS][15];

Why not use percpu?

> +/* FIXME: There's no obvious point to check whether slab is ready. So
> + * a hack is used here by utilizing a late time hook.
> + */
Could you hook onto paravirt_post_allocator_init()?

    J
